# hugo-mod-plantuml

[![CI](https://github.com/julienpoirou/hugo-mod-plantuml/actions/workflows/ci.yml/badge.svg?branch=main)](https://github.com/julienpoirou/hugo-mod-plantuml/actions/workflows/ci.yml)
[![CodeQL](https://github.com/julienpoirou/hugo-mod-plantuml/actions/workflows/codeql.yml/badge.svg)](https://github.com/julienpoirou/hugo-mod-plantuml/actions/workflows/codeql.yml)
[![Release](https://img.shields.io/github/v/release/julienpoirou/hugo-mod-plantuml?include_prereleases&sort=semver)](https://github.com/julienpoirou/hugo-mod-plantuml/releases)
[![Hugo Module](https://img.shields.io/badge/Hugo-Module-FF4088?logo=hugo&logoColor=white)](https://gohugo.io/hugo-modules/)
[![Java 21+](https://img.shields.io/badge/Java-21%2B-E76F00?logo=openjdk&logoColor=white)](https://openjdk.org/)
[![Conventional Commits](https://img.shields.io/badge/Conventional%20Commits-1.0.0-%23FE5196.svg)](https://www.conventionalcommits.org)

<p align="center">
  <img src="./logo.svg" alt="hugo-mod-plantuml logo" width="160" height="160">
</p>

Standalone Hugo module for local PlantUML rendering with Java, without Kroki or any remote rendering service. The MIT-licensed PlantUML jar is fetched on demand and checksum-verified rather than vendored.

## Features

- Render diagrams with `{{< plantuml src="..." >}}`
- Ship a local `render-plantuml.sh` pipeline for SVG generation
- Fetch the MIT-licensed PlantUML jar on demand, verified against a pinned SHA-256
- Render under the `SECURE` PlantUML security profile by default
- Render diagrams in parallel across CPU cores
- Work without external PlantUML servers
- Mirror `assets/**/*.puml` to `static/generated/plantuml/**/*.svg`
- Fail explicitly at build time when `src` is missing or the SVG was not rendered

## Requirements

- Hugo `>= 0.124`
- Java `21+`
- A Hugo site with Hugo Modules enabled

## Installation

Import the module in your Hugo site:

```toml
[module]
  [[module.imports]]
    path = "github.com/julienpoirou/hugo-mod-plantuml"
```

## Usage

Create a source file under `assets/`, for example:

```text
assets/renderers/plantuml.puml
```

Render it locally (this fetches and verifies the jar on first run, then
generates the SVGs) with a single command, run from the site directory:

```bash
go mod download github.com/julienpoirou/hugo-mod-plantuml && \
  sh "$(go list -m -f '{{.Dir}}' github.com/julienpoirou/hugo-mod-plantuml)/scripts/render.sh" .
```

Run this **before** `hugo`: the shortcode fails the build if the SVG for a
referenced source has not been generated.

`scripts/render.sh` is a thin wrapper around `render-plantuml.sh`: the
module's own directory (as resolved by `go list -m`) is read-only — it's
still sitting inside Go's module cache, which Go marks that way to protect
it — so `render.sh` transparently copies the module into a persistent,
writable cache directory (`${XDG_CACHE_HOME:-$HOME/.cache}/hugo-mod-plantuml`,
override with `HUGO_MOD_PLANTUML_CACHE`) the first time it's run, then
delegates to `render-plantuml.sh` from there. The downloaded PlantUML jar
lives in that same cache directory, so it survives across runs instead of
being re-fetched every time. If you've copied or cloned the module somewhere
writable yourself (e.g. while developing the module), `render.sh` detects
that and skips the caching step, delegating directly.

Both scripts locate their own module directory from their own path — neither
needs to live at a fixed path like `_modules/hugo-mod-plantuml` relative to
the site.

All diagrams that need rendering (new or changed since the last run) are
rendered in a **single JVM invocation**, not one process per file — the
dominant cost of running PlantUML from the CLI is JVM startup, so batching
avoids paying it once per diagram. This means the diagrams in a given run
succeed or fail **as a unit**: PlantUML's batch mode does not report which
specific file failed, so if any diagram in the batch is invalid, none of
that batch's outputs are published (already-published diagrams from a prior
successful run are untouched). Fix or remove the invalid source and rerun.

Tunable environment variables:

- `PLANTUML_SECURITY_PROFILE` — PlantUML security profile (default: `SECURE`)
- `PLANTUML_VERSION` / `PLANTUML_SHA256` / `PLANTUML_URL` — pin a different jar

Use the shortcode:

```text
{{< plantuml src="renderers/plantuml.puml" alt="PlantUML diagram" >}}
```

Alias available when needed:

```text
{{< puml src="renderers/plantuml.puml" alt="PlantUML diagram" >}}
```

## Security

Diagrams render under PlantUML's `SECURE` profile by default, and includes are
restricted to the site's `assets/` tree. This prevents diagram source from
reading arbitrary local files or reaching the network via `!include` and
similar directives. Override with `PLANTUML_SECURITY_PROFILE` only if you fully
trust every diagram source.

## Output assets

The module ships:

- `scripts/render.sh` (single-command entry point; caches the module in a
  writable directory when needed, then delegates below)
- `scripts/render-plantuml.sh` (renders every stale `.puml`/`.plantuml`/`.uml`
  found under `assets/`)
- `scripts/fetch-plantuml.sh` (downloads and verifies the MIT jar)
- shortcode layouts for `plantuml` and `puml`

The PlantUML jar is **not** committed; it is fetched to `bin/plantuml.jar`
(git-ignored) on first render. See [`VENDORED.md`](VENDORED.md).

## Development

```bash
git clone https://github.com/julienpoirou/hugo-mod-plantuml
cd hugo-mod-plantuml
```

The main verification is handled by GitHub Actions with Java enabled, a minimal Hugo site, and a local SVG render step before the Hugo build.

## Contributing

- Use Conventional Commits for branch history
- Update docs or changelog when behavior changes
- Keep shell and Java pipeline changes reproducible in CI
- See [`.github/CONTRIBUTING.md`](.github/CONTRIBUTING.md) for contribution guidance
