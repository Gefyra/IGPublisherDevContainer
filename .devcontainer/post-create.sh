#!/usr/bin/env bash
# Runs once after the devcontainer is created (and on every rebuild).
set -euo pipefail

cd "$(dirname "${BASH_SOURCE[0]}")/.."
. .devcontainer/lib.sh

# The IG Publisher scripts expect the jar in ./input-cache/, the image ships one
# at /opt/ig/publisher.jar. Symlink instead of copying so the ~220 MB jar exists
# exactly once. _genonce.sh only reads it, which works fine through the link.
#
# The link is NOT writable (root-owned /opt), so "Update IG Publisher" removes it
# first and downloads a real file in its place - see .vscode/tasks.json.
mkdir -p input-cache

# The workspace outlives the container, so a link from an earlier one may still
# be here pointing at nothing. Drop it before deciding what to do.
if [ -L "$CACHE_JAR" ] && [ ! -e "$CACHE_JAR" ]; then
  rm -f "$CACHE_JAR"
fi

if [ ! -e "$CACHE_JAR" ]; then
  if [ -f "$IMAGE_JAR" ]; then
    echo "Linking $CACHE_JAR -> $IMAGE_JAR"
    ln -s "$IMAGE_JAR" "$CACHE_JAR"
  else
    bash _updatePublisher.sh -y
  fi

elif [ ! -L "$CACHE_JAR" ] && [ -f "$IMAGE_JAR" ]; then
  # A real file left over from "Update IG Publisher". Once the image has caught
  # up, that copy buys nothing and just costs another ~220 MB, so fall back to
  # the link. Only ever replaces it with an equal or newer publisher; if either
  # version can't be read we keep the copy, because guessing could downgrade it.
  cached=$(jar_version "$CACHE_JAR")
  image=$(jar_version "$IMAGE_JAR")

  if [ -n "$cached" ] && [ -n "$image" ] && version_ge "$image" "$cached"; then
    freed=$(jar_mb "$CACHE_JAR")
    rm -f "$CACHE_JAR"
    ln -s "$IMAGE_JAR" "$CACHE_JAR"
    echo "Image publisher $image >= local copy $cached - relinked, freed ~${freed} MB."
  fi
fi

echo "Devcontainer ready."
