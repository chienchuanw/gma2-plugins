#!/usr/bin/env bash
#
# build-release.sh — package each first-party plugin into a downloadable zip.
#
# For every plugin folder under plugins/, this bundles its .lua + .xml pair
# into dist/<plugin>.zip (filenames preserved so the console matches the
# .xml's luafile= attribute to the .lua on import).
#
# Usage:
#   ./scripts/build-release.sh
#   gh release create vX.Y.Z --target main dist/*.zip
#
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
PLUGINS_DIR="$REPO_ROOT/plugins"
DIST_DIR="$REPO_ROOT/dist"

rm -rf "$DIST_DIR"
mkdir -p "$DIST_DIR"

shopt -s nullglob
built=0
for dir in "$PLUGINS_DIR"/*/; do
  name="$(basename "$dir")"
  # collect the .lua / .xml pair for this plugin
  files=("$dir"*.lua "$dir"*.xml)
  if [ ${#files[@]} -eq 0 ]; then
    echo "skip: $name (no .lua/.xml)"
    continue
  fi
  zip -j "$DIST_DIR/$name.zip" "${files[@]}" >/dev/null
  echo "built: dist/$name.zip"
  built=$((built + 1))
done

echo "done — $built plugin(s) packaged into dist/"
