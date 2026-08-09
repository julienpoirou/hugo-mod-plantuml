# Vendored third-party assets

Provenance and integrity of every third-party file shipped by this module. When updating a library: replace the file, update this table, and update [THIRD_PARTY_LICENSES.md](THIRD_PARTY_LICENSES.md) if the upstream license changed.

| Artifact | Library | Version | License | SHA-256 |
|---|---|---|---|---|
| `bin/plantuml.jar` (fetched, not committed) | [PlantUML (MIT build)](https://github.com/plantuml/plantuml) | 1.2026.2 | MIT | `397fe169dd408b0f039e8b7be2a12c2d52d35a3399802921b8c84f29cf39e45a` |

Source: `https://github.com/plantuml/plantuml/releases/download/v1.2026.2/plantuml-mit-1.2026.2.jar`

First-party files, under this repository's [LICENSE](LICENSE): `scripts/fetch-plantuml.sh`, `scripts/render-plantuml.sh`, and the shortcode layouts.

## Pinning a different build

Override the pinned values via environment variables before running the fetch/render scripts:

```bash
PLANTUML_VERSION=1.2026.2 \
PLANTUML_SHA256=397fe169dd408b0f039e8b7be2a12c2d52d35a3399802921b8c84f29cf39e45a \
sh scripts/fetch-plantuml.sh
```

## Verifying integrity

```bash
sh scripts/fetch-plantuml.sh          # downloads and verifies
sha256sum bin/plantuml.jar            # should match the table above
```
