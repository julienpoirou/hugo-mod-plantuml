# Changelog

## [0.2.2](https://github.com/julienpoirou/hugo-mod-plantuml/compare/v0.2.1...v0.2.2) (2026-08-09)


### Corrections 🐛

* **security:** Resolve symlinks before the served-path root check ([03886eb](https://github.com/julienpoirou/hugo-mod-plantuml/commit/03886ebd5de5c6bdd6e888dd8cd48fb97233080c))

## [0.2.1](https://github.com/julienpoirou/hugo-mod-plantuml/compare/v0.2.0...v0.2.1) (2026-07-16)


### Corrections 🐛

* **shortcodes:** Replace Java pipeline with browser check ([b01d3cc](https://github.com/julienpoirou/hugo-mod-plantuml/commit/b01d3ccc26b1dafc1228802337885985a4d6bca9))

## [0.2.0](https://github.com/julienpoirou/hugo-mod-plantuml/compare/v0.1.2...v0.2.0) (2026-07-14)


### Features ✨

* **scripts:** Add a single-command wrapper around render-plantuml.sh ([7b761bb](https://github.com/julienpoirou/hugo-mod-plantuml/commit/7b761bb1c43aa34a432116c2927459b188e9b4a7))


### Corrections 🐛

* **scripts:** Make render-plantuml.sh locate its own module dir ([7b1b3dc](https://github.com/julienpoirou/hugo-mod-plantuml/commit/7b1b3dc6e772f14c110af8383b368066f925f384))

## [0.1.2](https://github.com/julienpoirou/hugo-mod-plantuml/compare/v0.1.1...v0.1.2) (2026-07-10)


### Corrections 🐛

* **bash:** Renderer plantuml ([92a2bd9](https://github.com/julienpoirou/hugo-mod-plantuml/commit/92a2bd988e13f3d0efda36504ed44a9cb0090e0b))
* **ci:** Use non-self-closing shortcode tag in CI test content ([6713d42](https://github.com/julienpoirou/hugo-mod-plantuml/commit/6713d42479655846c391b5ca0761e560f7c88dde))
* **release:** Use plain GITHUB_TOKEN for release-please ([04e7830](https://github.com/julienpoirou/hugo-mod-plantuml/commit/04e7830e6f0f9ceb1a69533a133441f360583bd3))
* **render:** Fail the build when a parallel render fails ([b4c9a4b](https://github.com/julienpoirou/hugo-mod-plantuml/commit/b4c9a4b81189abaa38d107edb506c70873a1441a))
* **render:** Make parallel rendering portable to posix sh ([3966bab](https://github.com/julienpoirou/hugo-mod-plantuml/commit/3966bab6c9fb60341a52e7651128f5e9896b9a2c))
* **security:** Render under the SECURE plantuml profile ([aba2060](https://github.com/julienpoirou/hugo-mod-plantuml/commit/aba2060f905db167c6e5a0bab1d4e86f4f90fea8))
* **shortcode:** Fail the build when the rendered SVG is missing ([6619610](https://github.com/julienpoirou/hugo-mod-plantuml/commit/6619610efa5a45d8ef006755aa7d7abda9deecd7))


### Performance ⚡

* **render:** Batch every stale diagram into a single JVM invocation ([2202d55](https://github.com/julienpoirou/hugo-mod-plantuml/commit/2202d557ef8fdcb3ac54c313cc4dc516f259222a))
* **render:** Render diagrams in parallel with xargs -P ([b1a59a1](https://github.com/julienpoirou/hugo-mod-plantuml/commit/b1a59a1145b05ad7911b61a10862dd2a559e4889))

## [0.1.1](https://github.com/julienpoirou/hugo-mod-plantuml/compare/v0.1.0...v0.1.1) (2026-03-26)


### Corrections 🐛

* **bash:** Renderer plantuml ([809901b](https://github.com/julienpoirou/hugo-mod-plantuml/commit/809901bc90253ca9553cd5f0465d09ef7a996684))
* **ci:** Use non-self-closing shortcode tag in CI test content ([5aa430d](https://github.com/julienpoirou/hugo-mod-plantuml/commit/5aa430d7d4da72569378d2d93f6a2692e255efc9))

## Changelog
