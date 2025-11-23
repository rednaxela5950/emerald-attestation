# Step 2 — Relay Phase 1 attestation

Status: Done

Plan:
- Add Relay-only entry point on `EmeraldDaAdapter` for Phase 1 attestations.
- Enforce cid/kzg matches plus stake threshold logic.
- Update registry status and store stake/voter details.
- Tests for pass, fail (low stake), and mismatch rejection.

Progress:
- Added Relay-gated `handleDaAttestation` that stores Phase 1 state, checks cid/kzg, enforces >50% yes stake, and updates registry status.
- Tests cover pass, low-stake fail, and mismatch revert.

Result:
- Relay-only attestation entry updates Phase 1 data and registry status with >50% yes stake threshold and cid/kzg validation.
- Tests assert pass, fail, and mismatch rejection flows.
