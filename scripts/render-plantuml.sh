#!/bin/bash
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

# Render every PlantUML source under assets/ into a mirrored SVG tree under static/.
find "${ASSETS_DIR}" -type f \( -name '*.puml' -o -name '*.plantuml' -o -name '*.uml' \) | while IFS= read -r source_file; do
  rel_path="${source_file#"${ASSETS_DIR}"/}"
  out_rel="$(printf '%s' "${rel_path}" | sed 's/\.[^.]*$/.svg/')"
  out_file="${OUT_DIR}/${out_rel}"
  out_dir="$(dirname "${out_file}")"

  mkdir -p "${out_dir}"

  # Rebuild only when the source or the renderer jar changed.
  if [ ! -f "${out_file}" ] || [ "${source_file}" -nt "${out_file}" ] || [ "${JAR_PATH}" -nt "${out_file}" ]; then
    tmp_file="${out_file}.tmp"
    echo "[plantuml] render ${rel_path} -> ${out_file#"${SITE_DIR}"/}"
    java -Djava.awt.headless=true \
      -DPLANTUML_SECURITY_PROFILE="${PLANTUML_SECURITY_PROFILE}" \
      -Dplantuml.include.path="${ASSETS_DIR}" \
      -jar "${JAR_PATH}" -charset UTF-8 -tsvg -pipe < "${source_file}" > "${tmp_file}"
    mv "${tmp_file}" "${out_file}"
  fi
done
