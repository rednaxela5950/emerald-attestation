# Step 3 — Custody challenges (Phase 2)

Status: In progress

Plan:
- Define challenge storage:
  - `struct CustodyChallenge { address operator; uint256 challengeIndex; bool responded; bool success; }`
  - `mapping(bytes32 => CustodyChallenge[]) challenges;`
- `startCustodyChallenges(postId)` gate on Phase1Passed, derive challenge index per operator, and emit events.
- `submitCustodyProof` using mock KZG verifier to mark success/fail.
- `finalizePostFromCustody` to set final status based on responses.
- Tests for success/failure/incomplete paths.

Progress:
- Added custody challenge creation per Phase 1 yes-voter (Phase1Passed required) with `CustodyChallengeStarted` events.
