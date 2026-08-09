# hugo-mod-plantuml

[![CI](https://github.com/julienpoirou/hugo-mod-plantuml/actions/workflows/ci.yml/badge.svg?branch=main)](https://github.com/julienpoirou/hugo-mod-plantuml/actions/workflows/ci.yml)
[![CodeQL](https://github.com/julienpoirou/hugo-mod-plantuml/actions/workflows/codeql.yml/badge.svg)](https://github.com/julienpoirou/hugo-mod-plantuml/actions/workflows/codeql.yml)
[![OpenSSF Scorecard](https://api.securityscorecards.dev/projects/github.com/julienpoirou/hugo-mod-plantuml/badge)](https://scorecard.dev/viewer/?uri=github.com/julienpoirou/hugo-mod-plantuml)
[![Release](https://img.shields.io/github/v/release/julienpoirou/hugo-mod-plantuml?include_prereleases&sort=semver)](https://github.com/julienpoirou/hugo-mod-plantuml/releases)
[![Hugo Module](https://img.shields.io/badge/Hugo-Module-FF4088?logo=hugo&logoColor=white)](https://gohugo.io/hugo-modules/)
[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)

<p align="center">
  <img src="./logo.svg" alt="hugo-mod-plantuml logo" width="160" height="160">
</p>

<p align="center">
  <strong>PlantUML diagrams in your Hugo pages.</strong><br>
  100% client-side, no PlantUML server, no third-party service, works offline.
</p>

## Requires

- Hugo >= `0.124`. The extended edition is not required.

## Install

**Binary** - Hugo and Go installed locally:

```bash
hugo mod init example.com/my-site
hugo mod get github.com/julienpoirou/hugo-mod-plantuml
```

```toml
# hugo.toml
[module]
  [[module.imports]]
    path = "github.com/julienpoirou/hugo-mod-plantuml"
```

**Container** - Docker installed locally:

```bash
alias hugo='docker run --rm -v "$PWD":/src -p 1313:1313 hugomods/hugo:go-git hugo'
hugo mod init example.com/my-site
hugo mod get github.com/julienpoirou/hugo-mod-plantuml
```

## Usage

**Shortcode** - Raw diagram source between the tags:

```text
{{< plantuml >}}
@startuml
Alice -> Bob : Hello
return ok
@enduml
{{< /plantuml >}}
```

**Self-closing shortcode** - Source read from a file, optionally in dark mode:

```text
{{< plantuml src="renderers/plantuml.puml" />}}
{{< plantuml dark="true" src="renderers/plantuml.puml" />}}
```

**Self-closing shortcode** - Source passed as base64:

```text
{{< plantuml b64="QHN0YXJ0dW1sCkFsaWNlIC0+IEJvYgpAZW5kdW1s" />}}
```

> `puml` is a drop-in alias for `plantuml` and takes the same parameters.

### Parameters

| Param | Default | Description |
|---|---|---|
| inner content | - | Raw diagram source between the opening and closing tags |
| `src` | - | Path, relative to `assets/`, of a `.puml`/`.plantuml`/`.uml` file |
| `b64` | - | Base64-encoded diagram source |
| `dark` | `false` | `true`, `1` or `yes` to render a dark-mode SVG |
| `class` | *(none)* | Extra CSS class added to the wrapper |

> At least one source input is required. If several are given, `b64` wins over `src`, and `src` wins over the inner content, the others are ignored silently.

> A missing or empty source fails the build with an explicit error rather than emitting a blank page. A syntax error in the diagram is not caught at build time: it surfaces at render time, as PlantUML's message in place of the diagram.

> `src` is resolved with `readFile` from the project root, so the file must live in your own site's `assets/`. A file mounted from a theme or from another module will not be found.

## Security

Being fully client-side, no diagram source ever touches your build server or any external service. PlantUML preprocessor directives that reach the filesystem or the network (`!include` of a URL, and the like) are constrained by the browser's same-origin and Content-Security-Policy rules, not by a PlantUML security profile. Review untrusted diagram source as you would any other user-supplied content.

## Rendering

Each diagram is rendered in the reader's browser, to inline `<svg>`, by the PlantUML engine compiled to JavaScript.

- The Graphviz layout engine (`viz-global.js`), the stylesheet and the glue are injected once per page, at the first shortcode, in the flow of the content, not in `<head>`. Each one is fingerprinted and carries a Subresource Integrity hash.
- The PlantUML engine is an ES module: it is announced with `modulepreload`, then imported dynamically and memoised, so it downloads and initializes once per page however many diagrams are present.
- Rendering is lazy: each diagram starts as it approaches the viewport, with a 200px margin. Browsers without `IntersectionObserver` render everything immediately instead.
- The engine keeps shared internal state across calls, so renders on a page are serialized: one diagram finishes before the next starts, and two diagrams entering the viewport together never clobber each other.
- Everything runs in the browser, so it works with `hugo server` live reload, on any static host, and offline.
- For diagrams injected after page load, call `window.HugoModPlantUML.observeAll(root)` for lazy rendering, or `renderAll(root)` to render immediately.
- Without JavaScript the shortcode leaves an empty block: there is no server-side fallback.

## Vendored assets

The whole rendering stack ships inside the module, no CDN, no PlantUML server, no third-party request at page load:

| File | What it is | Size | License |
|---|---|---|---|
| `plantuml.js` | The PlantUML engine, compiled to JavaScript with TeaVM | 6.9 MB | MIT |
| `viz-global.js` | Viz.js / Graphviz, the layout engine PlantUML calls for dot-based diagrams | 1.4 MB | MIT |

Full license texts are in [THIRD_PARTY_LICENSES.md](THIRD_PARTY_LICENSES.md), upstream provenance and checksums in [VENDORED.md](VENDORED.md).

## License

MIT © 2025 [Julien Poirou](mailto:julienpoirou@protonmail.com)
