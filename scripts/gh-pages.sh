#!/usr/bin/env bash
#
# Maintains the gh-pages branch.
#
# Layout:
#   /                 newest release
#   /<version>/       archived releases
#   /branches/<name>/ per-branch previews
#
# Every operation rewrites gh-pages as a single root commit. Pages serves only
# the current tree, and keeping history would retain every past build's
# binaries forever. That means pushing is always a force-push, so it uses a
# lease against the commit this run started from: a publish and a cleanup
# racing each other then produces a rejected push, which is retried, instead of
# one silently discarding the other's work.
set -euo pipefail

usage() {
  cat <<'EOF'
Usage:
  gh-pages.sh publish-preview <branch>    Publish output/ to branches/<branch>/
  gh-pages.sh publish-release <version>   Publish output/ to / and <version>/
  gh-pages.sh cleanup                     Drop branches/* without a live branch

Environment:
  REPO           owner/name of the repository (required)
  GITHUB_TOKEN   token with contents:write (required)
  OUTPUT_DIR     IG build output (default: output)
  WORK_DIR       gh-pages clone location (default: gh-pages)
  ATTEMPTS       retries when gh-pages moves underneath us (default: 3)
EOF
}

: "${REPO:?REPO is required}"
: "${GITHUB_TOKEN:?GITHUB_TOKEN is required}"
OUTPUT_DIR="${OUTPUT_DIR:-output}"
WORK_DIR="${WORK_DIR:-gh-pages}"
ATTEMPTS="${ATTEMPTS:-3}"

# PAGES_REMOTE exists so the script can be exercised against a local bare repo
# instead of GitHub; CI always takes the derived URL.
remote_url="${PAGES_REMOTE:-https://x-access-token:${GITHUB_TOKEN}@github.com/${REPO}.git}"

log() { printf '%s\n' "$*" >&2; }

# full-ig.zip is a ~6 MB convenience bundle that changes wholesale on every
# build and that nothing in the generated site links to, so it is dropped
# rather than published. Rebuild it from the sources if it is ever needed.
# The package tarballs stay: they let a consuming IG point at a branch build or
# at a released version.
prune_bulk() {
  rm -f "$1/full-ig.zip"
}

is_version() {
  [[ "$1" =~ ^[0-9]+\.[0-9]+\.[0-9]+([.-][A-Za-z0-9.-]+)?$ ]]
}

# Set by clone_pages: the commit gh-pages was at when this attempt started.
base_sha=""

clone_pages() {
  rm -rf "${WORK_DIR}"
  if git ls-remote --heads "${remote_url}" gh-pages | grep -q .; then
    git clone --depth 1 --branch gh-pages "${remote_url}" "${WORK_DIR}"
    base_sha="$(git -C "${WORK_DIR}" rev-parse HEAD)"
  else
    log "gh-pages does not exist yet; initializing it."
    mkdir -p "${WORK_DIR}"
    git -C "${WORK_DIR}" init -b gh-pages
    git -C "${WORK_DIR}" remote add origin "${remote_url}"
    touch "${WORK_DIR}/.nojekyll"
    base_sha=""
  fi
}

copy_output() {
  local dir="$1"
  rm -rf "${dir}"
  mkdir -p "${dir}"
  cp -R "${OUTPUT_DIR}/." "${dir}/"
  prune_bulk "${dir}"
}

# Commits the working tree as a fresh root commit and force-pushes it. Does
# nothing when the tree is unchanged, so quiet runs cause no Pages rebuild.
# Returns 2 when the remote moved since clone_pages, so the caller can retry.
push_pages() {
  local message="$1" rc=0
  cd "${WORK_DIR}"
  git config user.name "${GIT_AUTHOR_NAME:-github-actions[bot]}"
  git config user.email "${GIT_AUTHOR_EMAIL:-41898282+github-actions[bot]@users.noreply.github.com}"
  git add --all
  if git rev-parse --verify HEAD >/dev/null 2>&1; then
    if git diff --cached --quiet; then
      log "No updates to publish."
      cd - >/dev/null
      return 0
    fi
    git checkout --orphan publish
    git add --all
  fi
  git commit -m "${message}"

  if [ -n "${base_sha}" ]; then
    git push --force-with-lease="gh-pages:${base_sha}" origin HEAD:gh-pages || rc=$?
  else
    git push origin HEAD:gh-pages || rc=$?
  fi
  cd - >/dev/null
  [ "${rc}" -eq 0 ] && return 0
  return 2
}

publish_preview() {
  local branch="${1:?branch name is required}"
  clone_pages
  copy_output "${WORK_DIR}/branches/${branch}"
  push_pages "chore: publish preview for ${branch}"
}

publish_release() {
  local version="${1:?version is required}"
  is_version "${version}" || {
    log "Refusing to publish '${version}': not a version number."
    exit 1
  }

  clone_pages

  # The root holds the newest release, so clear it before copying the new one
  # in -- otherwise files dropped between releases would linger. Preserved:
  # Pages' own config, the previews, and the archive of older versions.
  local entry name
  for entry in "${WORK_DIR}"/* "${WORK_DIR}"/.[!.]*; do
    [ -e "${entry}" ] || continue
    name="$(basename "${entry}")"
    case "${name}" in
      .git | .nojekyll | branches) continue ;;
    esac
    if [ -d "${entry}" ] && is_version "${name}"; then
      continue
    fi
    rm -rf "${entry}"
  done

  copy_output "${WORK_DIR}/${version}"
  # The root serves the newest release directly rather than redirecting, so it
  # gets its own copy instead of a pointer into the archive directory.
  cp -R "${OUTPUT_DIR}/." "${WORK_DIR}/"
  prune_bulk "${WORK_DIR}"

  push_pages "chore: publish release ${version}"
}

is_live_branch() {
  grep -Fxq -- "$1" "${live_branches}"
}

# True when some live branch nests below this path, i.e. it is a path segment
# of a name like "feature/x" rather than a preview of its own.
leads_to_live_branch() {
  local branch
  while IFS= read -r branch; do
    case "${branch}" in "$1"/*) return 0 ;; esac
  done <"${live_branches}"
  return 1
}

# Descends branches/ one level at a time. Recursing only into path segments is
# what keeps a live preview's own subdirectories (assets/, package/, ...) from
# being mistaken for orphans.
sweep_previews() {
  local rel="$1" child name sub
  local dir="${branches_dir}${rel:+/${rel}}"
  for child in "${dir}"/*/; do
    [ -d "${child}" ] || continue
    name="$(basename "${child}")"
    sub="${rel:+${rel}/}${name}"
    if is_live_branch "${sub}"; then
      continue
    elif leads_to_live_branch "${sub}"; then
      sweep_previews "${sub}"
    else
      log "Removing orphaned preview: branches/${sub}"
      rm -rf "${child}"
      removed=$((removed + 1))
    fi
  done
}

cleanup() {
  clone_pages

  branches_dir="${WORK_DIR}/branches"
  if [ ! -d "${branches_dir}" ]; then
    log "No branches/ directory on gh-pages; nothing to clean."
    return 0
  fi

  removed=0
  live_branches="$(mktemp)"
  git ls-remote --heads "${remote_url}" | sed 's#.*refs/heads/##' >"${live_branches}"

  sweep_previews ""
  rm -f "${live_branches}"

  if [ "${removed}" -eq 0 ]; then
    log "No orphaned previews found."
    return 0
  fi
  push_pages "chore: remove ${removed} orphaned branch preview(s)"
}

run() {
  local i rc
  for i in $(seq 1 "${ATTEMPTS}"); do
    rc=0
    "$@" || rc=$?
    case "${rc}" in
      0) return 0 ;;
      2) log "gh-pages changed while publishing (attempt ${i}/${ATTEMPTS}); starting over." ;;
      *) return "${rc}" ;;
    esac
  done
  log "gh-pages kept changing under us; giving up after ${ATTEMPTS} attempts."
  return 1
}

case "${1:-}" in
  publish-preview) run publish_preview "${2:-}" ;;
  publish-release) run publish_release "${2:-}" ;;
  cleanup) run cleanup ;;
  -h | --help | "")
    usage
    [ -n "${1:-}" ] || exit 1
    ;;
  *)
    log "Unknown command: ${1}"
    usage
    exit 1
    ;;
esac
