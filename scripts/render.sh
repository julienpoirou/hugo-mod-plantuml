#!/bin/sh
set -eu

# One-command entry point around render-plantuml.sh.
#
# The module's own directory is often read-only (e.g. Go's module cache
# marks it 555 to protect it from accidental writes), but render-plantuml.sh
# needs to write the downloaded PlantUML jar somewhere under the module
# directory. This script locates itself, and if it isn't writable, copies
# itself into a persistent, writable cache directory before delegating -
# so the jar downloaded on first run survives across invocations instead of
# being re-fetched every time.
#
# Usage: sh scripts/render.sh [site-dir]

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
MODULE_DIR="$(dirname "${SCRIPT_DIR}")"

if [ -w "${SCRIPT_DIR}" ]; then
  exec sh "${MODULE_DIR}/scripts/render-plantuml.sh" "$@"
fi

CACHE_DIR="${HUGO_MOD_PLANTUML_CACHE:-${XDG_CACHE_HOME:-$HOME/.cache}/hugo-mod-plantuml}"
echo "[plantuml] module directory is read-only, using writable cache: ${CACHE_DIR}" >&2
mkdir -p "${CACHE_DIR}"
cp -r "${MODULE_DIR}/." "${CACHE_DIR}/"
chmod -R u+w "${CACHE_DIR}"
exec sh "${CACHE_DIR}/scripts/render-plantuml.sh" "$@"
