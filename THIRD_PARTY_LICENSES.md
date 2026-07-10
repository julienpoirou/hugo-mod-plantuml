# Third-party licenses

This module does not redistribute any third-party binary. The PlantUML jar is
fetched on demand by `scripts/fetch-plantuml.sh`; see `VENDORED.md` for the
exact version, source, and checksum.

---

## PlantUML (MIT build)

- Upstream: <https://github.com/plantuml/plantuml>
- Distribution fetched: `plantuml-mit-<version>.jar` (the MIT-licensed build)
- License: MIT

```text
Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
```

> Note: PlantUML also publishes GPL, Apache (asl), BSD, and EPL builds. This
> module intentionally fetches the MIT build to stay compatible with its own
> MIT license. If you point `PLANTUML_URL` at a different build, review that
> build's license and your redistribution obligations.
