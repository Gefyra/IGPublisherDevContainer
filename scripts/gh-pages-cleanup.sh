#!/usr/bin/env bash
#
# Removes branch previews from gh-pages whose branch no longer exists.
#
# Layout published by .github/workflows/ig-publisher.yml:
#   /<branch>/   one directory per branch, the branch name used verbatim
#
# A branch named "feature/x" therefore lands in /feature/x/, so the sweep
# descends one path segment at a time instead of treating every top-level
# directory as a preview.
#
# The publishing workflow pushes to the same branch without coordinating with
# this one, so a push here can be rejected as non-fast-forward. That is not an
# error worth failing on: the whole pass is simply repeated against the updated
# gh-pages.
set -euo pipefail

: "${REPO:?REPO is required}"
: "${GITHUB_TOKEN:?GITHUB_TOKEN is required}"
WORK_DIR="${WORK_DIR:-gh-pages}"
ATTEMPTS="${ATTEMPTS:-3}"

# PAGES_REMOTE exists so the script can be exercised against a local bare repo
# instead of GitHub; CI always takes the derived URL.
remote_url="${PAGES_REMOTE:-https://x-access-token:${GITHUB_TOKEN}@github.com/${REPO}.git}"

log() { printf '%s\n' "$*" >&2; }

live_branches=""
cleanup_tmp() { [ -n "${live_branches}" ] && rm -f "${live_branches}"; }
trap cleanup_tmp EXIT

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

# Recursing only into path segments is what keeps a live preview's own
# subdirectories (assets/, package/, ...) from being mistaken for orphans.
# The */ glob skips dotfiles, so .git and .nojekyll are never considered.
sweep() {
  local rel="$1" child name sub
  local dir="${WORK_DIR}${rel:+/${rel}}"
  for child in "${dir}"/*/; do
    [ -d "${child}" ] || continue
    name="$(basename "${child}")"
    sub="${rel:+${rel}/}${name}"
    if is_live_branch "${sub}"; then
      continue
    elif leads_to_live_branch "${sub}"; then
      sweep "${sub}"
    else
      log "Removing orphaned preview: ${sub}"
      rm -rf "${child}"
      removed=$((removed + 1))
    fi
  done
}

# 0 = done, 2 = gh-pages moved underneath us, retry.
attempt() {
  rm -rf "${WORK_DIR}"
  git clone --depth 1 --branch gh-pages "${remote_url}" "${WORK_DIR}"

  cleanup_tmp
  live_branches="$(mktemp)"
  git ls-remote --heads "${remote_url}" | sed 's#.*refs/heads/##' >"${live_branches}"
  # gh-pages itself holds no preview, and it is never a branch we published for.
  grep -Fxv -- 'gh-pages' "${live_branches}" >"${live_branches}.tmp" || true
  mv "${live_branches}.tmp" "${live_branches}"

  removed=0
  sweep ""

  if [ "${removed}" -eq 0 ]; then
    log "No orphaned previews found."
    return 0
  fi

  cd "${WORK_DIR}"
  git config user.name "${GIT_AUTHOR_NAME:-github-actions[bot]}"
  git config user.email "${GIT_AUTHOR_EMAIL:-41898282+github-actions[bot]@users.noreply.github.com}"
  git add --all
  if git diff --cached --quiet; then
    log "Nothing staged after sweep; leaving gh-pages untouched."
    cd - >/dev/null
    return 0
  fi
  git commit -m "chore: remove ${removed} orphaned branch preview(s)"

  if git push origin HEAD:gh-pages; then
    log "Removed ${removed} orphaned preview(s)."
    cd - >/dev/null
    return 0
  fi

  cd - >/dev/null
  return 2
}

if ! git ls-remote --heads "${remote_url}" gh-pages | grep -q .; then
  log "No gh-pages branch; nothing to clean."
  exit 0
fi

for i in $(seq 1 "${ATTEMPTS}"); do
  rc=0
  attempt || rc=$?
  case "${rc}" in
    0) exit 0 ;;
    2) log "gh-pages changed while cleaning up (attempt ${i}/${ATTEMPTS}); starting over." ;;
    *) exit "${rc}" ;;
  esac
done

log "gh-pages kept changing under us; giving up after ${ATTEMPTS} attempts."
exit 1
