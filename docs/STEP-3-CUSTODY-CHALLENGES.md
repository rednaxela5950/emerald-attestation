# Step 3 — Custody challenges (Phase 2)

Status: Done

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
- Added custody proof submission using mock KZG verifier and response tracking.
- Added finalization that sets posts to `Available` or `Unavailable` based on custody responses.

Result:
- Phase 2 flow: start challenges after Phase1Passed, accept custody proofs with mock KZG, and finalize registry status on majority success.
