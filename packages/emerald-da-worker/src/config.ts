export type WorkerConfig = {
  blobServiceUrl: string;
  rpcUrl: string;
  registryAddress: string;
  adapterAddress: string;
  lazyMode: boolean;
};

export function loadConfig(): WorkerConfig {
  return {
    blobServiceUrl: process.env.BLOB_SERVICE_URL || "http://127.0.0.1:4000",
    rpcUrl: process.env.RPC_URL || "http://127.0.0.1:8545",
    registryAddress: process.env.REGISTRY_ADDRESS || "",
    adapterAddress: process.env.ADAPTER_ADDRESS || "",
    lazyMode: process.env.LAZY_WORKER === "1"
  };
}
