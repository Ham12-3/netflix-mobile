const http = require("http");
const fs = require("fs");
const path = require("path");
const { Readable } = require("stream");

const port = Number(process.env.MEDIA_PROXY_PORT || 8787);
const archiveOrigin = "https://archive.org";
const mediaDir = path.join(__dirname, "..", "dev_media");

const localFiles = new Map([
  ["/services/img/BigBuckBunny_328", {
    path: path.join(mediaDir, "BigBuckBunny_328.jpg"),
    type: "image/jpeg",
  }],
  ["/download/BigBuckBunny_328/BigBuckBunny_512kb.mp4", {
    path: path.join(mediaDir, "BigBuckBunny_512kb.mp4"),
    type: "video/mp4",
  }],
]);

function serveLocalFile(req, res, entry) {
  const stat = fs.statSync(entry.path);
  const range = req.headers.range;

  if (range) {
    const match = range.match(/bytes=(\d+)-(\d*)/);
    if (match) {
      const start = Number(match[1]);
      const end = match[2] ? Number(match[2]) : stat.size - 1;
      const chunkSize = end - start + 1;
      res.writeHead(206, {
        "accept-ranges": "bytes",
        "content-length": chunkSize,
        "content-range": `bytes ${start}-${end}/${stat.size}`,
        "content-type": entry.type,
        "access-control-allow-origin": "*",
      });
      if (req.method === "HEAD") {
        res.end();
        return;
      }
      fs.createReadStream(entry.path, { start, end }).pipe(res);
      return;
    }
  }

  res.writeHead(200, {
    "accept-ranges": "bytes",
    "content-length": stat.size,
    "content-type": entry.type,
    "access-control-allow-origin": "*",
    "cache-control": "public, max-age=3600",
  });
  if (req.method === "HEAD") {
    res.end();
    return;
  }
  fs.createReadStream(entry.path).pipe(res);
}

const server = http.createServer(async (req, res) => {
  try {
    if (req.url === "/health") {
      res.writeHead(200, { "content-type": "text/plain" });
      res.end("ok");
      return;
    }

    const localEntry = localFiles.get(decodeURI(req.url));
    if (localEntry && fs.existsSync(localEntry.path)) {
      serveLocalFile(req, res, localEntry);
      return;
    }

    if (!req.url.startsWith("/services/img/") && !req.url.startsWith("/download/")) {
      res.writeHead(404, { "content-type": "text/plain" });
      res.end("Only archive.org image and download paths are proxied.");
      return;
    }

    const targetUrl = archiveOrigin + req.url;
    const headers = {
      "user-agent": "LumaStreamDevProxy/1.0",
    };
    if (req.headers.range) {
      headers.range = req.headers.range;
    }

    const upstream = await fetch(targetUrl, {
      method: req.method === "HEAD" ? "HEAD" : "GET",
      headers,
      redirect: "follow",
    });

    const responseHeaders = {};
    for (const name of [
      "accept-ranges",
      "content-length",
      "content-range",
      "content-type",
      "last-modified",
      "etag",
    ]) {
      const value = upstream.headers.get(name);
      if (value) responseHeaders[name] = value;
    }
    responseHeaders["access-control-allow-origin"] = "*";
    responseHeaders["cache-control"] = "public, max-age=300";

    res.writeHead(upstream.status, responseHeaders);
    if (req.method === "HEAD" || !upstream.body) {
      res.end();
      return;
    }

    Readable.fromWeb(upstream.body).pipe(res);
  } catch (error) {
    res.writeHead(502, { "content-type": "text/plain" });
    res.end(`Proxy error: ${error.message}`);
  }
});

server.listen(port, "0.0.0.0", () => {
  console.log(`Luma media proxy listening on http://0.0.0.0:${port}`);
});
