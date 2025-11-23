import { createBlobApp } from "./blobService";
import { handlePostCreated, submitCustodyProof } from "./worker";
import { loadConfig } from "./config";
import { createProvider, subscribeToLogs } from "./provider";
import { parsePostCreated } from "./registry";
import { parseCustodyChallenge } from "./adapter";

export async function main() {
  const app = createBlobApp();
  const port = Number(process.env.PORT || 4000);
  app.listen(port, () => console.log(`blob service listening on :${port}`));

  const cfg = loadConfig();
  console.log(`worker ready, blob service ${cfg.blobServiceUrl}, rpc ${cfg.rpcUrl}, registry ${cfg.registryAddress || "(not set)"}`);
  if (!cfg.registryAddress || !cfg.adapterAddress) {
    console.warn("REGISTRY_ADDRESS or ADAPTER_ADDRESS not set; skipping on-chain subscription");
    return;
  }

  const provider = createProvider();
  subscribeToLogs(provider, cfg.registryAddress, [], async (log) => {
    const event = parsePostCreated(log);
    if (event) {
      console.log(`PostCreated received for ${event.postId}`);
      await handlePostCreated(
        { postId: event.postId, cidHash: event.cidHash, kzgCommit: event.kzgCommit },
        cfg.blobServiceUrl,
        cfg.lazyMode
      );
    }
  });

  subscribeToLogs(provider, cfg.adapterAddress, [], async (log) => {
    const chall = parseCustodyChallenge(log);
    if (chall) {
      console.log(`CustodyChallenge for ${chall.postId} operator ${chall.operator} index ${chall.challengeIndex}`);
      await submitCustodyProof(chall.postId, chall.operator, cfg.adapterAddress, cfg.rpcUrl, cfg.lazyMode);
    }
  });
}

if (require.main === module) {
  void main();
}
