import assert from "assert";
import { Interface } from "ethers";
import { parseCustodyChallenge, parseCustodyProof, parsePostFinalized } from "../src/adapter";

const abi = [
  "event CustodyChallengeStarted(bytes32 indexed postId, address indexed operator, uint256 challengeIndex)",
  "event CustodyProofSubmitted(bytes32 indexed postId, address indexed operator, bool success)",
  "event PostFinalized(bytes32 indexed postId, uint8 finalStatus)"
];
const iface = new Interface(abi);

function encode(name: string, args: any[]) {
  const evt = iface.getEvent(name)!;
  const log = iface.encodeEventLog(evt, args);
  return { data: log.data, topics: log.topics } as any;
}

function main() {
  const postId = "0x" + "01".padStart(64, "0");
  const op = "0x0000000000000000000000000000000000000004";

  const chall = parseCustodyChallenge(encode("CustodyChallengeStarted", [postId, op, 7n]));
  assert.ok(chall);
  assert.strictEqual(chall?.challengeIndex, 7n);

  const proof = parseCustodyProof(encode("CustodyProofSubmitted", [postId, op, true]));
  assert.ok(proof);
  assert.strictEqual(proof?.success, true);

  const finalized = parsePostFinalized(encode("PostFinalized", [postId, 2]));
  assert.ok(finalized);
  assert.strictEqual(finalized?.finalStatus, 2);

  console.log("adapter parser tests passed");
}

if (require.main === module) main();
