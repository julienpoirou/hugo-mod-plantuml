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
  // realpath on the root too: otherwise the containment check below fails
  // whenever a parent directory is itself a symlink (e.g. /tmp on macOS).
  const resolvedRoot = fs.realpathSync(path.resolve(rootDir));
  const server = http.createServer((req, res) => {
    let urlPath;
    try {
      urlPath = decodeURIComponent(req.url.split("?")[0]);
    } catch {
      res.writeHead(400);
      res.end("bad request");
      return;
    }

    const normalizedUrlPath = path.posix.normalize(urlPath);
    const hasTraversal = normalizedUrlPath.split("/").includes("..");
    if (
      !normalizedUrlPath.startsWith("/") ||
      normalizedUrlPath.includes("\0") ||
      normalizedUrlPath.includes("\\") ||
      hasTraversal
    ) {
      res.writeHead(403);
      res.end("forbidden");
      return;
    }

    let filePath = path.join(resolvedRoot, normalizedUrlPath);
    if (normalizedUrlPath.endsWith("/")) {
      filePath = path.join(filePath, "index.html");
    }

    // Normalises and resolves symlinks, so a link inside the root cannot
    // point outside it. Throws ENOENT for a missing file, hence the 404.
    let resolvedPath;
    try {
      resolvedPath = fs.realpathSync(filePath);
    } catch {
      res.writeHead(404);
      res.end("not found");
      return;
    }
    if (resolvedPath !== resolvedRoot && !resolvedPath.startsWith(resolvedRoot + path.sep)) {
      res.writeHead(403);
      res.end("forbidden");
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
