# Contributing

Thanks for your interest in **hugo-mod-plantuml**.

## Prerequisites
- Hugo 0.159+
- Go 1.22+ for Hugo module metadata
- Node 22+ (only to run the headless-browser render tests)

Rendering itself needs nothing at build time, the PlantUML engine runs
client-side in the reader's browser.

## Getting started
```bash
git clone https://github.com/julienpoirou/hugo-mod-plantuml
cd hugo-mod-plantuml
npm ci
npx playwright install --with-deps chromium
```

The main verification runs in GitHub Actions: it builds a minimal Hugo site
that mounts this module, then drives a real headless browser to confirm the
shortcodes render to actual `<svg>`.

## Branches & commits
- Branch off `main`: `feat/x`, `fix/y`, etc.
- **Conventional Commits** required:
  - `feat(scope): ...` (minor)
  - `fix(scope): ...` (patch)
  - `feat!(scope): ...` or `refactor!: ...` (major)
- CI enforces the format via **commitlint**.

## Tests
- Run the CI-equivalent by mounting the module in a minimal Hugo site
- Keep `README.md` and `CHANGELOG.md` aligned with behavior changes

## Open a PR
- Fill the PR template.
- Checklist: CI green, docs updated if needed, changelog updated when appropriate.

## Discussion
- Questions: issues or discussions.
- First contributions welcome: **good first issue** label.
