// Minimal static file server for CI render verification.
// Hugo emits root-relative asset paths (e.g. /libs/...), which do not
// resolve under a file:// URL, so the built site must be served over http.
"use strict";

const http = require("http");
const fs = require("fs");
const path = require("path");

const CONTENT_TYPES = {
  ".html": "text/html; charset=utf-8",
  ".js": "text/javascript; charset=utf-8",
  ".css": "text/css; charset=utf-8",
  ".json": "application/json; charset=utf-8",
  ".svg": "image/svg+xml",
  ".woff": "font/woff",
  ".woff2": "font/woff2",
  ".ttf": "font/ttf",
};

function serve(rootDir, port) {
  const resolvedRoot = path.resolve(rootDir);
  const server = http.createServer((req, res) => {
    const urlPath = decodeURIComponent(req.url.split("?")[0]);
    let filePath = path.join(resolvedRoot, urlPath);
    if (urlPath.endsWith("/")) {
      filePath = path.join(filePath, "index.html");
    }
    const resolvedPath = path.resolve(filePath);
    if (resolvedPath !== resolvedRoot && !resolvedPath.startsWith(resolvedRoot + path.sep)) {
      res.writeHead(400);
      res.end("bad request");
      return;
    }
    fs.readFile(resolvedPath, (error, data) => {
      if (error) {
        res.writeHead(404);
        res.end("not found");
        return;
      }
      const ext = path.extname(resolvedPath);
      res.writeHead(200, { "Content-Type": CONTENT_TYPES[ext] || "application/octet-stream" });
      res.end(data);
    });
  });
  return new Promise((resolve) => {
    server.listen(port, "127.0.0.1", () => resolve(server));
  });
}

module.exports = { serve };
