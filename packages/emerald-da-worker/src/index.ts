import { createBlobApp } from "./blobService";
import { handlePostCreated } from "./worker";
import { loadConfig } from "./config";

export async function main() {
  const app = createBlobApp();
  const port = Number(process.env.PORT || 4000);
  app.listen(port, () => console.log(`blob service listening on :${port}`));

  const cfg = loadConfig();
  console.log(`worker ready, blob service ${cfg.blobServiceUrl}`);
  // Example: process a dummy post (placeholder for event wiring).
  await handlePostCreated({ postId: "0x0", cidHash: "0x0", kzgCommit: "0x0" }, cfg.blobServiceUrl).catch((err) =>
    console.warn("handlePostCreated demo failed (expected without data)", err.message)
  );
}

if (require.main === module) {
  void main();
}
