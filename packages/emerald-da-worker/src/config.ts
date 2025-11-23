export type WorkerConfig = {
  blobServiceUrl: string;
};

export function loadConfig(): WorkerConfig {
  return {
    blobServiceUrl: process.env.BLOB_SERVICE_URL || "http://127.0.0.1:4000"
  };
}
