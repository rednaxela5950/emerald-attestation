import { Interface, Log } from "ethers";

const registryAbi = [
  "event PostCreated(bytes32 indexed postId, bytes32 cidHash, bytes32 kzgCommit, address indexed author)"
];

const registryIface = new Interface(registryAbi);
const postCreatedEvent = registryIface.getEvent("PostCreated")!;

export type PostCreatedEvent = { postId: string; cidHash: string; kzgCommit: string; author: string };

export function parsePostCreated(log: Log): PostCreatedEvent | null {
  if (log.topics[0] !== postCreatedEvent.topicHash) return null;
  const parsed = registryIface.parseLog(log);
  if (!parsed) return null;
  return {
    postId: parsed.args[0],
    cidHash: parsed.args[1],
    kzgCommit: parsed.args[2],
    author: parsed.args[3]
  };
}
