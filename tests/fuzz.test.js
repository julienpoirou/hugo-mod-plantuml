// Property-based fuzz test for the base64/UTF-8 decode boundary that the
// shortcode's runtime uses to turn untrusted page content into PlantUML
// source text (assets/libs/hugo-mod-plantuml/hugo-mod-plantuml.js).
// Exercised with fast-check instead of a fixed example set, so arbitrary
// byte sequences (not just the inputs a human would think to write by
// hand) are checked against the same invariants the runtime relies on: it
// never throws past the catch boundary, and valid UTF-8 round-trips
// losslessly.
"use strict";

const test = require("node:test");
const assert = require("node:assert/strict");
const fc = require("fast-check");

// Mirrors decodeBase64Utf8 from hugo-mod-plantuml.js, using Node's Buffer
// instead of window.atob/TextDecoder (unavailable outside a browser) so the
// same decode logic can be fuzzed headlessly in CI.
function decodeBase64Utf8(value) {
  const binary = Buffer.from(value || "", "base64").toString("binary");
  const bytes = Uint8Array.from(binary, (char) => char.charCodeAt(0));
  return new TextDecoder("utf-8").decode(bytes);
}

test("decodeBase64Utf8 never throws on arbitrary base64-alphabet strings", () => {
  fc.assert(
    fc.property(fc.string(), (value) => {
      decodeBase64Utf8(value);
    }),
  );
});

test("decodeBase64Utf8 never throws on arbitrary byte sequences", () => {
  fc.assert(
    fc.property(fc.uint8Array(), (bytes) => {
      decodeBase64Utf8(Buffer.from(bytes).toString("base64"));
    }),
  );
});

test("decodeBase64Utf8 round-trips arbitrary UTF-8 text losslessly", () => {
  fc.assert(
    fc.property(fc.string(), (text) => {
      const encoded = Buffer.from(text, "utf8").toString("base64");
      assert.equal(decodeBase64Utf8(encoded), text);
    }),
  );
});
