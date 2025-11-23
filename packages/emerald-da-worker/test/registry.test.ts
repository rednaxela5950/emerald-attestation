import assert from "assert";
import { Interface, Log } from "ethers";
import { parsePostCreated } from "../src/registry";

const abi = [
  "event PostCreated(bytes32 indexed postId, bytes32 cidHash, bytes32 kzgCommit, address indexed author)"
];
const iface = new Interface(abi);

function encodePostCreated(): Log {
  const postId = "0x" + "01".padStart(64, "0");
  const cidHash = "0x" + "02".padStart(64, "0");
  const kzgCommit = "0x" + "03".padStart(64, "0");
  const author = "0x0000000000000000000000000000000000000004";
  const log = iface.encodeEventLog(iface.getEvent("PostCreated")!, [postId, cidHash, kzgCommit, author]);
  return { data: log.data, topics: log.topics } as unknown as Log;
}

function main() {
  const parsed = parsePostCreated(encodePostCreated());
  assert.ok(parsed);
  assert.strictEqual(parsed?.postId, "0x0000000000000000000000000000000000000000000000000000000000000001");
  assert.strictEqual(parsed?.author.toLowerCase(), "0x0000000000000000000000000000000000000004");
  console.log("registry parser test passed");
}

if (require.main === module) main();
