# hugo-mod-plantuml

[![CI](https://github.com/julienpoirou/hugo-mod-plantuml/actions/workflows/ci.yml/badge.svg?branch=main)](https://github.com/julienpoirou/hugo-mod-plantuml/actions/workflows/ci.yml)
[![CodeQL](https://github.com/julienpoirou/hugo-mod-plantuml/actions/workflows/codeql.yml/badge.svg)](https://github.com/julienpoirou/hugo-mod-plantuml/actions/workflows/codeql.yml)
[![Release](https://img.shields.io/github/v/release/julienpoirou/hugo-mod-plantuml?include_prereleases&sort=semver)](https://github.com/julienpoirou/hugo-mod-plantuml/releases)
[![Hugo Module](https://img.shields.io/badge/Hugo-Module-FF4088?logo=hugo&logoColor=white)](https://gohugo.io/hugo-modules/)
[![Conventional Commits](https://img.shields.io/badge/Conventional%20Commits-1.0.0-%23FE5196.svg)](https://www.conventionalcommits.org)

<p align="center">
  <img src="./logo.svg" alt="hugo-mod-plantuml logo" width="160" height="160">
</p>

Standalone Hugo module for PlantUML rendering with vendored TeaVM, PlantUML, and Viz assets.

## Features

- Render diagrams with `{{< plantuml >}}`
- 100% client-side: works with `hugo server` live reload, static hosts, and offline
- Vendored, fingerprinted assets served with Subresource Integrity (SRI)
- Lazy rendering: each diagram is rendered only as it approaches the viewport (`IntersectionObserver`)
- Light and dark output (`dark="true"`)
- Three source inputs: inline content, `src="…"` (from `assets/`), or pre-encoded `b64="…"`

## Requirements

- Hugo `>= 0.124`
- A Hugo site with Hugo Modules enabled

## Installation

Import the module in your Hugo site config:

```toml
[module]
  [[module.imports]]
    path = "github.com/julienpoirou/hugo-mod-plantuml"
```

## Usage

Inline source:

```text
{{< plantuml >}}
@startuml
Alice -> Bob : Hello
return ok
@enduml
{{< /plantuml >}}
```

File source:

```text
{{< plantuml src="renderers/plantuml.puml" />}}
```

Dark mode:

```text
{{< plantuml dark="true" >}}
@startuml
class Foo
class Bar
Foo --> Bar
@enduml
{{< /plantuml >}}
```

Pre-encoded base64 (useful when generating content programmatically):

```text
{{< plantuml b64="QHN0YXJ0dW1sCkFsaWNlIC0+IEJvYgpAZW5kdW1s" />}}
```

The `puml` shortcode is a drop-in alias for `plantuml` and accepts the same parameters.

### Parameters

| Param | Applies to | Description |
|---|---|---|
| inner content | `{{< plantuml >}} … {{< /plantuml >}}` | Raw PlantUML source |
| `src` | self-closing | Path (relative to `assets/`) of a `.puml`/`.plantuml`/`.uml` file to read |
| `b64` | self-closing | Base64-encoded PlantUML source |
| `dark` | both | `true`/`1`/`yes` to render a dark-mode SVG |
| `class` | both | Extra CSS class added to the wrapper |

## How it works

Each page that uses the shortcode injects, once:

- `viz-global.js` — the Graphviz layout engine (classic script, SRI)
- `plantuml.js` — the PlantUML engine (ES module, `modulepreload` + SRI)
- `hugo-mod-plantuml.js` — the first-party glue (classic script, SRI)
- `hugo-mod-plantuml.css` — minimal styling (SRI)

Every diagram becomes a `data-hugo-mod-plantuml` wrapper carrying its source
as base64 (so Hugo never mangles the PlantUML text). The glue lazily renders
each wrapper as it nears the viewport. Because the TeaVM engine keeps shared
internal state, renders on a page are **serialized** — one diagram finishes
before the next begins — so multiple diagrams on one page never clobber each
other.

## Security

Rendering happens in the reader's browser sandbox; no diagram source touches
your build server or any third-party service. PlantUML preprocessor
directives that reach the local filesystem or network (`!include` of a URL,
etc.) are constrained by the browser's same-origin and CSP policies rather
than a PlantUML security profile — review untrusted diagram source as you
would any other user-supplied HTML/JS on your site.

## Output assets

The module ships:

- `assets/libs/hugo-mod-plantuml/plantuml.js` (TeaVM PlantUML engine)
- `assets/libs/hugo-mod-plantuml/viz-global.js` (Viz.js / Graphviz layout)
- `assets/libs/hugo-mod-plantuml/hugo-mod-plantuml.js` (first-party glue)
- `assets/libs/hugo-mod-plantuml/hugo-mod-plantuml.css`
- `layouts/partials/hugo-mod-plantuml/render.html` (shared renderer)
- shortcode layouts for `plantuml` and `puml`

See [`VENDORED.md`](VENDORED.md) for provenance and checksums, and
[`THIRD_PARTY_LICENSES.md`](THIRD_PARTY_LICENSES.md) for licenses.

## Development

```bash
git clone https://github.com/julienpoirou/hugo-mod-plantuml
cd hugo-mod-plantuml
npm ci
npx playwright install --with-deps chromium
```

CI builds a minimal Hugo site with the shortcodes, then verifies in a real
headless browser that the diagrams render to actual `<svg>` (not just that
Hugo emitted the right tags).

## Contributing

- Use Conventional Commits for branch history
- Update docs or changelog when behavior changes
- Keep PlantUML examples valid across current Mermaid runtime versions
- See [`.github/CONTRIBUTING.md`](.github/CONTRIBUTING.md) for contribution guidance
