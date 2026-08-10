# Vendored third-party assets

Provenance and integrity of every third-party file shipped by this module. When updating a library: replace the file, update this table and the matching `sha256` in [.vendored/package.json](.vendored/package.json), and update [THIRD_PARTY_LICENSES.md](THIRD_PARTY_LICENSES.md) if the upstream license changed.

All files live in `assets/libs/hugo-mod-plantuml/`.

| File | Library | Version | License | SHA-256 |
|---|---|---|---|---|
| `plantuml.js` | [PlantUML](https://github.com/plantuml/plantuml), compiled to JavaScript with TeaVM | 1.2026.6 | MIT | `48bf2790629d84a3573a109c305acc3eee84f69cbb5c11cd93395a018c1fe3b2` |
| `viz-global.js` | [Viz.js](https://github.com/mdaines/viz-js) (Graphviz, the layout engine PlantUML calls for dot-based diagrams) | 3.29.0 | MIT | `d94405c431c23f674e740f042514231e559d60fffc93dc557b22fafc295fbbc0` |

Source for `viz-global.js`: `https://cdn.jsdelivr.net/npm/@viz-js/viz@3.29.0/dist/viz-global.js`

Source for `plantuml.js`: the `plantuml.js` entry of `https://github.com/plantuml/plantuml/releases/download/v1.2026.6/js-plantuml-1.2026.6.zip`

The copy shipped before 1.2026.6 came from an unstamped local build: rendering an invalid diagram made it draw `PlantUML version $version$ / $git.commit.id$ [Unknown compile time]`, placeholders an official release always substitutes. That is why its checksum matched no published archive. It has been replaced by the release build above, which renders the same diagrams identically.

First-party files, under this repository's [LICENSE](LICENSE): `hugo-mod-plantuml.js`, `hugo-mod-plantuml.css`, and the shortcode layouts.

## How updates reach us

[.vendored/package.json](.vendored/package.json) pins the same versions as ordinary npm dependencies. Nothing ever installs it. It exists so Dependabot opens a pull request when one of these libraries releases, and so GitHub raises a security alert against the exact code this module serves to readers.

Dependabot can bump that manifest but cannot re-download a minified bundle, so a merged bump would otherwise leave the declared version and the shipped bytes silently out of sync. `scripts/check-vendored.mjs` closes that gap: it fails the build unless the pinned version, this table and the checksum of the committed file all agree.

PlantUML is not on npm, so Dependabot cannot see it. `plantuml.js` therefore pins its version inline in the manifest, enforced by the same check, and [.github/workflows/plantuml-release.yml](.github/workflows/plantuml-release.yml) runs weekly to compare that pin against the latest PlantUML release, opening an issue when it falls behind.

## Verifying integrity

```bash
node scripts/check-vendored.mjs
sha256sum assets/libs/hugo-mod-plantuml/plantuml.js
sha256sum assets/libs/hugo-mod-plantuml/viz-global.js
```
