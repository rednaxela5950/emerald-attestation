import crypto from "crypto";
import express from "express";

const blobs = new Map<string, Buffer>();

export function createBlobApp() {
  const app = express();
  app.use(express.raw({ type: "*/*", limit: "10mb" }));

  app.post("/blob", (req, res) => {
    const body = Buffer.isBuffer(req.body) ? req.body : Buffer.from(req.body);
    const cidHash = "0x" + crypto.createHash("sha3-256").update(body).digest("hex");
    blobs.set(cidHash, body);
    res.json({ cidHash });
  });

  app.get("/blob/:cidHash", (req, res) => {
    const blob = blobs.get(req.params.cidHash);
    if (!blob) return res.sendStatus(404);
    res.type("application/octet-stream").send(blob);
  });

  return app;
}
