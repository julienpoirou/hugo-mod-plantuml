#!/bin/bash
set -eu

# Downloads the MIT-licensed PlantUML jar and verifies it against a pinned
# SHA-256. The jar is NOT vendored in this repository: it is fetched on demand
# so the module itself ships only MIT-licensed first-party code. Override
# PLANTUML_VERSION / PLANTUML_SHA256 / PLANTUML_URL to pin a different build.

MODULE_DIR="${1:-$(cd "$(dirname "$0")/.." && pwd)}"
JAR_PATH="${MODULE_DIR}/bin/plantuml.jar"

PLANTUML_VERSION="${PLANTUML_VERSION:-1.2026.2}"
PLANTUML_SHA256="${PLANTUML_SHA256:-397fe169dd408b0f039e8b7be2a12c2d52d35a3399802921b8c84f29cf39e45a}"
PLANTUML_URL="${PLANTUML_URL:-https://github.com/plantuml/plantuml/releases/download/v${PLANTUML_VERSION}/plantuml-mit-${PLANTUML_VERSION}.jar}"

verify() {
  # Print the sha-256 of "$1" using whatever tool is available.
  if command -v sha256sum >/dev/null 2>&1; then
    sha256sum "$1" | cut -d' ' -f1
  else
    shasum -a 256 "$1" | cut -d' ' -f1
  fi
}

if [ -f "${JAR_PATH}" ]; then
  actual="$(verify "${JAR_PATH}")"
  if [ "${actual}" = "${PLANTUML_SHA256}" ]; then
    echo "[plantuml] jar already present and verified"
    exit 0
  fi
  echo "[plantuml] existing jar checksum mismatch, re-downloading" >&2
  rm -f "${JAR_PATH}"
fi

mkdir -p "$(dirname "${JAR_PATH}")"
tmp_file="${JAR_PATH}.tmp"
echo "[plantuml] downloading ${PLANTUML_URL}"
curl -fsSL -o "${tmp_file}" "${PLANTUML_URL}"

actual="$(verify "${tmp_file}")"
if [ "${actual}" != "${PLANTUML_SHA256}" ]; then
  rm -f "${tmp_file}"
  echo "[plantuml] checksum verification failed" >&2
  echo "[plantuml]   expected ${PLANTUML_SHA256}" >&2
  echo "[plantuml]   actual   ${actual}" >&2
  exit 1
fi

mv "${tmp_file}" "${JAR_PATH}"
echo "[plantuml] jar downloaded and verified: ${JAR_PATH}"
