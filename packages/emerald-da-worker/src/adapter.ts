import { Interface, Log } from "ethers";

const adapterAbi = [
  "event CustodyChallengeStarted(bytes32 indexed postId, address indexed operator, uint256 challengeIndex)",
  "event CustodyProofSubmitted(bytes32 indexed postId, address indexed operator, bool success)",
  "event PostFinalized(bytes32 indexed postId, uint8 finalStatus)"
];

const adapterIface = new Interface(adapterAbi);

export type CustodyChallengeEvt = { postId: string; operator: string; challengeIndex: bigint };
export type CustodyProofEvt = { postId: string; operator: string; success: boolean };
export type PostFinalizedEvt = { postId: string; finalStatus: number };

export function parseCustodyChallenge(log: Log): CustodyChallengeEvt | null {
  const evt = adapterIface.getEvent("CustodyChallengeStarted")!;
  if (log.topics[0] !== evt.topicHash) return null;
  const parsed = adapterIface.parseLog(log);
  if (!parsed) return null;
  return { postId: parsed.args[0], operator: parsed.args[1], challengeIndex: parsed.args[2] };
}

export function parseCustodyProof(log: Log): CustodyProofEvt | null {
  const evt = adapterIface.getEvent("CustodyProofSubmitted")!;
  if (log.topics[0] !== evt.topicHash) return null;
  const parsed = adapterIface.parseLog(log);
  if (!parsed) return null;
  return { postId: parsed.args[0], operator: parsed.args[1], success: parsed.args[2] };
}

export function parsePostFinalized(log: Log): PostFinalizedEvt | null {
  const evt = adapterIface.getEvent("PostFinalized")!;
  if (log.topics[0] !== evt.topicHash) return null;
  const parsed = adapterIface.parseLog(log);
  if (!parsed) return null;
  return { postId: parsed.args[0], finalStatus: Number(parsed.args[1]) };
}
