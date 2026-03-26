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

Standalone Hugo module for local PlantUML rendering with Java and a vendored `plantuml.jar`, without Kroki or any remote rendering service.

## Features

- Render diagrams with `{{< plantuml src="..." />}}`
- Ship a local `render-plantuml.sh` pipeline for SVG generation
- Work without external PlantUML servers
- Mirror `assets/**/*.puml` to `static/generated/plantuml/**/*.svg`
- Fail explicitly at build time when `src` is missing

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

Render it locally:

```bash
sh _modules/hugo-mod-plantuml/scripts/render-plantuml.sh .
```

Use the shortcode:

```text
{{< plantuml src="renderers/plantuml.puml" alt="PlantUML diagram" />}}
```

Alias available when needed:

```text
{{< puml src="renderers/plantuml.puml" alt="PlantUML diagram" />}}
```

## Output assets

The module publishes or ships:

- `bin/plantuml.jar`
- `scripts/render-plantuml.sh`
- shortcode layouts for `plantuml` and `puml`

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
