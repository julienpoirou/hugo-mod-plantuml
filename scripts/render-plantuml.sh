#!/bin/sh
set -eu

SITE_DIR="${1:-/src}"
# Self-locate: this script always lives at <module dir>/scripts/render-plantuml.sh,
# so the module never has to be copied to a specific path (e.g. _modules/hugo-mod-plantuml)
# relative to the site. Matches the same pattern already used by fetch-plantuml.sh.
MODULE_DIR="$(cd "$(dirname "$0")/.." && pwd)"
ASSETS_DIR="${SITE_DIR}/assets"
OUT_DIR="${SITE_DIR}/static/generated/plantuml"
JAR_PATH="${MODULE_DIR}/bin/plantuml.jar"

# Render under a restricted PlantUML security profile so diagram source cannot
# read arbitrary local files or reach the network via !include / sprite / etc.
# Legitimate includes are still allowed from within the site's assets/ tree.
PLANTUML_SECURITY_PROFILE="${PLANTUML_SECURITY_PROFILE:-SECURE}"

# The jar is not vendored; fetch and verify it on demand.
if [ ! -f "${JAR_PATH}" ]; then
  if [ -x "${MODULE_DIR}/scripts/fetch-plantuml.sh" ] || [ -f "${MODULE_DIR}/scripts/fetch-plantuml.sh" ]; then
    sh "${MODULE_DIR}/scripts/fetch-plantuml.sh" "${MODULE_DIR}"
  else
    echo "[plantuml] missing jar and fetch script: ${JAR_PATH}" >&2
    exit 1
  fi
fi

if [ ! -d "${ASSETS_DIR}" ]; then
  exit 0
fi

STALE_LIST="$(mktemp)"
trap 'rm -f "${STALE_LIST}"' EXIT

export ASSETS_DIR OUT_DIR JAR_PATH

# Every worker here is a plain POSIX `sh -c` invocation (no exported shell
# functions: bash supports that, dash/POSIX sh does not), matching the
# portability fix already applied elsewhere in this script.
#
# shellcheck disable=SC2016 # single-quoted on purpose: expansion must happen
# in the spawned worker's shell, reading exported env vars, not here.
find "${ASSETS_DIR}" -type f \( -name '*.puml' -o -name '*.plantuml' -o -name '*.uml' \) -print0 \
  | xargs -0 -I{} sh -c '
      source_file="$1"
      rel_path="${source_file#"$ASSETS_DIR"/}"
      out_rel=$(printf "%s" "$rel_path" | sed "s/\.[^.]*\$/.svg/")
      out_file="$OUT_DIR/$out_rel"
      if [ -f "$out_file" ] && [ ! "$source_file" -nt "$out_file" ] && [ ! "$JAR_PATH" -nt "$out_file" ]; then
        exit 0
      fi
      printf "%s\0" "$source_file"
    ' _ {} > "${STALE_LIST}"

if [ ! -s "${STALE_LIST}" ]; then
  exit 0
fi

# Render every stale diagram in a single JVM invocation instead of spawning
# one process per file (the dominant cost is JVM startup, not per-diagram
# render time). PlantUML processes every file it's given even if one of them
# errors, and writes each output next to its source by default; those
# beside-source files are moved into the mirrored static/generated/plantuml/**
# tree below. xargs -0 parses the NUL-delimited list itself, so this does not
# depend on shell read support for NUL delimiters (also missing from dash).
if xargs -0 java -Djava.awt.headless=true \
    -DPLANTUML_SECURITY_PROFILE="${PLANTUML_SECURITY_PROFILE}" \
    -Dplantuml.include.path="${ASSETS_DIR}" \
    -jar "${JAR_PATH}" -charset UTF-8 -tsvg < "${STALE_LIST}"; then
  BATCH_OK=1
else
  BATCH_OK=0
fi
export BATCH_OK SITE_DIR

# If any diagram in the batch failed, none of the batch's outputs are
# published: a broken diagram must not silently ship, and PlantUML gives no
# reliable per-file exit status in batch mode to publish only the good ones.
# shellcheck disable=SC2016
xargs -0 -I{} sh -c '
    source_file="$1"
    rel_path="${source_file#"$ASSETS_DIR"/}"
    out_rel=$(printf "%s" "$rel_path" | sed "s/\.[^.]*\$/.svg/")
    out_file="$OUT_DIR/$out_rel"
    beside_svg=$(printf "%s" "$source_file" | sed "s/\.[^.]*\$/.svg/")

    if [ "$BATCH_OK" = "1" ]; then
      mkdir -p "$(dirname "$out_file")"
      mv "$beside_svg" "$out_file"
      echo "[plantuml] render $rel_path -> ${out_file#"$SITE_DIR"/}"
    else
      rm -f "$beside_svg"
    fi
  ' _ {} < "${STALE_LIST}"

if [ "${BATCH_OK}" = "0" ]; then
  echo "[plantuml] one or more diagrams failed to render; no outputs from this batch were published" >&2
  exit 1
fi
