// Verifies, in a real headless browser, that the shortcode's runtime
// actually renders, not just that Hugo emitted the right HTML/script tags
// (which is all the shell-based CI assertions can check).
"use strict";

const path = require("path");
const { chromium } = require("playwright");
const { serve } = require("./serve.js");

const PORT = 4173;

async function main() {
  const publicDir = process.argv[2];
  const pagePath = process.argv[3] || "test/";
  if (!publicDir) {
    console.error("usage: node verify-render.js <public-dir> [page-path]");
    process.exit(1);
  }

  const server = await serve(path.resolve(publicDir), PORT);
  const browser = await chromium.launch();
  try {
    const page = await browser.newPage();
    const errors = [];
    const failedRequests = [];
    page.on("pageerror", (error) => errors.push(`pageerror: ${error.message}`));
    page.on("requestfailed", (req) => failedRequests.push(req.url()));

    await page.goto(`http://127.0.0.1:${PORT}/${pagePath}`);

    const wrappers = page.locator("[data-hugo-mod-plantuml]");
    const total = await wrappers.count();
    // Rendering is lazy (IntersectionObserver, 200px margin) and serialized
    // (the engine keeps shared state). Scroll each wrapper into view so it is
    // queued, then wait for every one to finish.
    for (let i = 0; i < total; i += 1) {
      await wrappers.nth(i).scrollIntoViewIfNeeded();
    }
    await page.waitForFunction(
      (expected) => {
        const els = document.querySelectorAll('[data-hugo-mod-plantuml][data-rendered="true"]');
        return els.length === expected;
      },
      total,
      { timeout: 60000 }
    );

    const svgCount = await page.locator("[data-hugo-mod-plantuml] svg").count();
    const errorClassCount = await page.locator(".is-error").count();

    // A favicon.ico 404 is emitted by the browser itself and is unrelated to
    // the module; ignore it. Any other failed request is a real problem.
    const realFailures = failedRequests.filter((u) => !u.endsWith("/favicon.ico"));

    if (errors.length > 0) {
      console.error("FAIL: page errors:", errors);
      process.exit(1);
    }
    if (realFailures.length > 0) {
      console.error("FAIL: failed network requests:", realFailures);
      process.exit(1);
    }
    if (svgCount < total) {
      console.error(`FAIL: only ${svgCount}/${total} diagrams rendered to <svg>`);
      process.exit(1);
    }
    if (errorClassCount > 0) {
      console.error("FAIL: an .is-error wrapper is present");
      process.exit(1);
    }

    console.log(`PASS: ${svgCount} diagram(s) rendered to real <svg> via the TeaVM engine, no errors, no failed requests`);
  } finally {
    await browser.close();
    server.close();
  }
}

main().catch((error) => {
  console.error(error);
  process.exit(1);
});
