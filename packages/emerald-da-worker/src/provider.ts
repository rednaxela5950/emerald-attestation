import { JsonRpcProvider, Log } from "ethers";
import { loadConfig } from "./config";

export function createProvider() {
  const cfg = loadConfig();
  return new JsonRpcProvider(cfg.rpcUrl);
}

export type LogListener = (log: Log) => Promise<void>;

export function subscribeToLogs(provider: JsonRpcProvider, address: string, topics: string[], listener: LogListener) {
  provider.on({ address, topics }, (log) => {
    void listener(log);
  });
}
