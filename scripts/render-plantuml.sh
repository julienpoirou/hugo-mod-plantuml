#!/bin/sh
set -eu

SITE_DIR="${1:-/src}"
MODULE_DIR="${SITE_DIR}/_modules/hugo-mod-plantuml"
ASSETS_DIR="${SITE_DIR}/assets"
OUT_DIR="${SITE_DIR}/static/generated/plantuml"
JAR_PATH="${MODULE_DIR}/bin/plantuml.jar"

# Render under a restricted PlantUML security profile so diagram source cannot
# read arbitrary local files or reach the network via !include / sprite / etc.
# Legitimate includes are still allowed from within the site's assets/ tree.
PLANTUML_SECURITY_PROFILE="${PLANTUML_SECURITY_PROFILE:-SECURE}"

# Number of diagrams to render in parallel. Defaults to the CPU count.
if [ -z "${PLANTUML_JOBS:-}" ]; then
  PLANTUML_JOBS="$( (command -v nproc >/dev/null 2>&1 && nproc) || echo 4)"
fi

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

# xargs spawns one `sh -c` worker per parallel job. Exported shell functions
# are a bash-only extension (undefined in POSIX sh / dash, which is /bin/sh
# on Debian and Ubuntu), so the per-file render logic is inlined as a plain
# command string instead of an exported function. It only reads plain
# exported variables, which every POSIX shell inherits from the environment.
export ASSETS_DIR OUT_DIR SITE_DIR JAR_PATH PLANTUML_SECURITY_PROFILE

# Render every PlantUML source under assets/ into a mirrored SVG tree under
# static/, up to PLANTUML_JOBS diagrams at a time, rebuilding a file only when
# its source or the renderer jar changed. -print0/-0 keep paths with spaces
# intact; xargs exits non-zero if any render fails, failing the build.
# shellcheck disable=SC2016 # single-quoted on purpose: expansion must happen
# in the spawned worker's shell, not here, since it reads $ASSETS_DIR etc.
# from the environment (exported above), not from this outer substitution.
find "${ASSETS_DIR}" -type f \( -name '*.puml' -o -name '*.plantuml' -o -name '*.uml' \) -print0 \
  | xargs -0 -P "${PLANTUML_JOBS}" -I{} sh -c '
      source_file="$1"
      rel_path="${source_file#"$ASSETS_DIR"/}"
      out_rel="$(printf "%s" "$rel_path" | sed "s/\.[^.]*\$/.svg/")"
      out_file="$OUT_DIR/$out_rel"

      mkdir -p "$(dirname "$out_file")"

      if [ -f "$out_file" ] && [ ! "$source_file" -nt "$out_file" ] && [ ! "$JAR_PATH" -nt "$out_file" ]; then
        exit 0
      fi

      tmp_file="$out_file.tmp.$$"
      echo "[plantuml] render $rel_path -> ${out_file#"$SITE_DIR"/}"
      # This worker runs under set -e-less xargs, so java exit status must be
      # checked explicitly: on failure, drop the partial file and exit
      # non-zero so xargs (and thus the build) fails instead of shipping a
      # broken SVG.
      if ! java -Djava.awt.headless=true \
        -DPLANTUML_SECURITY_PROFILE="$PLANTUML_SECURITY_PROFILE" \
        -Dplantuml.include.path="$ASSETS_DIR" \
        -jar "$JAR_PATH" -charset UTF-8 -tsvg -pipe < "$source_file" > "$tmp_file"; then
        rm -f "$tmp_file"
        echo "[plantuml] render failed: $rel_path" >&2
        exit 1
      fi
      mv "$tmp_file" "$out_file"
    ' _ {}
