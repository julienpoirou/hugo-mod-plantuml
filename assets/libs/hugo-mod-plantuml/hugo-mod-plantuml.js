(() => {
  if (window.__hugoModPlantUMLInit) return;
  window.__hugoModPlantUMLInit = true;

  // Shortcodes pass source through base64 so Hugo does not mangle PlantUML
  // content (angle brackets, quotes, unicode, leading whitespace).
  const decodeBase64Utf8 = (value) => {
    const binary = window.atob(value || "");
    if (typeof TextDecoder !== "undefined") {
      const bytes = Uint8Array.from(binary, (char) => char.charCodeAt(0));
      return new TextDecoder("utf-8").decode(bytes);
    }

    let escaped = "";
    for (let index = 0; index < binary.length; index += 1) {
      escaped += `%${binary.charCodeAt(index).toString(16).padStart(2, "0")}`;
    }
    return decodeURIComponent(escaped);
  };

  // The engine (`plantuml.js`) is an ES module; it is imported dynamically
  // from the fingerprinted URL the shortcode stamps on each wrapper. The
  // import is memoised so the ~7 MB engine downloads and initialises once
  // per page, no matter how many diagrams are present.
  let enginePromise = null;
  const loadEngine = (src) => {
    if (!enginePromise) {
      // Resolve against the document base so a relative RelPermalink is not
      // mistaken for a bare module specifier by the dynamic import.
      const url = new URL(src, document.baseURI).href;
      enginePromise = import(url);
    }
    return enginePromise;
  };

  // `viz-global.js` is a classic deferred script that defines `window.Viz`
  // (the Graphviz layout engine the PlantUML engine calls for dot-based
  // diagrams). Deferred scripts run in document order before rendering
  // starts, but guard anyway in case rendering is triggered manually.
  const waitForViz = (timeoutMs = 15000) =>
    new Promise((resolve, reject) => {
      if (typeof window.Viz !== "undefined") {
        resolve();
        return;
      }
      const start = Date.now();
      const timer = setInterval(() => {
        if (typeof window.Viz !== "undefined") {
          clearInterval(timer);
          resolve();
        } else if (Date.now() - start > timeoutMs) {
          clearInterval(timer);
          reject(new Error("viz-global.js did not load in time"));
        }
      }, 30);
    });

  // The TeaVM-compiled engine keeps shared internal state across calls, so
  // two concurrent renders in the same JS context clobber each other. Every
  // render is therefore chained onto a single promise so at most one runs at
  // a time. Lazy loading already spreads most renders out; this makes the
  // "two diagrams enter the viewport together" case correct too.
  let renderChain = Promise.resolve();

  const renderOne = (element) =>
    new Promise((resolve) => {
      const output = element.querySelector("[data-plantuml-output]");
      if (!output) {
        resolve();
        return;
      }

      const finishError = (message) => {
        output.textContent = message;
        output.classList.add("is-error");
        element.dataset.rendered = "true";
        resolve();
      };

      let source;
      try {
        source = decodeBase64Utf8(element.dataset.source || "").trim();
      } catch (error) {
        finishError(`PlantUML source could not be decoded: ${error.message}`);
        return;
      }
      if (!source) {
        finishError("PlantUML source is empty");
        return;
      }

      const dark = element.dataset.dark === "true";
      const lines = source.split(/\r\n|\r|\n/);

      loadEngine(element.dataset.engineSrc)
        .then((engine) => waitForViz().then(() => engine))
        .then((engine) => {
          engine.renderToString(
            lines,
            (svg) => {
              output.innerHTML = svg;
              output.classList.remove("is-error");
              element.dataset.rendered = "true";
              resolve();
            },
            (message) => finishError(message || "PlantUML rendering failed"),
            { dark }
          );
        })
        .catch((error) => finishError(error.message));
    });

  const renderElement = (element) => {
    if (element.dataset.rendered === "true" || element.dataset.queued === "true") {
      return;
    }
    element.dataset.queued = "true";
    renderChain = renderChain.then(() => renderOne(element));
  };

  // Rendering instantiates the Graphviz WASM runtime and a heavy engine,
  // which is expensive. Defer each diagram until it approaches the viewport
  // instead of paying that cost during page load.
  let observer = null;
  const observeElement = (element) => {
    if (typeof IntersectionObserver === "undefined") {
      renderElement(element);
      return;
    }
    if (!observer) {
      observer = new IntersectionObserver((entries) => {
        entries.forEach((entry) => {
          if (!entry.isIntersecting) return;
          observer.unobserve(entry.target);
          renderElement(entry.target);
        });
      }, { rootMargin: "200px" });
    }
    observer.observe(element);
  };

  const observeAll = (root = document) => {
    root.querySelectorAll("[data-hugo-mod-plantuml]").forEach(observeElement);
  };

  // Immediate rendering, kept for dynamically injected content and as an
  // escape hatch when lazy rendering is not wanted.
  const renderAll = (root = document) => {
    root.querySelectorAll("[data-hugo-mod-plantuml]").forEach(renderElement);
  };

  if (document.readyState === "loading") {
    document.addEventListener("DOMContentLoaded", () => observeAll(), { once: true });
  } else {
    observeAll();
  }

  window.HugoModPlantUML = { renderAll, observeAll };
})();
