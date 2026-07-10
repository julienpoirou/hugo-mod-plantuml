# Vendored / fetched third-party assets

This module does **not** vendor the PlantUML jar. PlantUML's default
distribution is GPL-licensed, so shipping it inside this MIT-licensed module
would be a redistribution conflict. Instead, `scripts/fetch-plantuml.sh`
downloads the **MIT-licensed** PlantUML jar on demand and verifies it against
a pinned SHA-256. The jar is git-ignored (`bin/*.jar`).

| Artifact | Library | Version | Source | License | SHA-256 |
|---|---|---|---|---|---|
| `bin/plantuml.jar` (fetched, not committed) | [PlantUML (MIT build)](https://github.com/plantuml/plantuml) | 1.2026.2 | `https://github.com/plantuml/plantuml/releases/download/v1.2026.2/plantuml-mit-1.2026.2.jar` | MIT | `397fe169dd408b0f039e8b7be2a12c2d52d35a3399802921b8c84f29cf39e45a` |

First-party files: `scripts/fetch-plantuml.sh`, `scripts/render-plantuml.sh`,
and the shortcode layouts — licensed under this repository's [LICENSE](LICENSE).

## Pinning a different build

Override the pinned values via environment variables before running the
fetch/render scripts:

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
