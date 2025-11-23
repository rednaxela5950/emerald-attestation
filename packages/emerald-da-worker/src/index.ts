import { createBlobApp } from "./blobService";
import { handlePostCreated } from "./worker";
import { loadConfig } from "./config";
import { createProvider, subscribeToLogs } from "./provider";
import { parsePostCreated } from "./registry";

export async function main() {
  const app = createBlobApp();
  const port = Number(process.env.PORT || 4000);
  app.listen(port, () => console.log(`blob service listening on :${port}`));

  const cfg = loadConfig();
  console.log(`worker ready, blob service ${cfg.blobServiceUrl}, rpc ${cfg.rpcUrl}, registry ${cfg.registryAddress || "(not set)"}`);
  if (!cfg.registryAddress) {
    console.warn("REGISTRY_ADDRESS not set; skipping on-chain subscription");
    return;
  }

  const provider = createProvider();
  subscribeToLogs(provider, cfg.registryAddress, [], async (log) => {
    const event = parsePostCreated(log);
    if (event) {
      console.log(`PostCreated received for ${event.postId}`);
      await handlePostCreated({ postId: event.postId, cidHash: event.cidHash, kzgCommit: event.kzgCommit }, cfg.blobServiceUrl);
    }
  });
}

if (require.main === module) {
  void main();
}
