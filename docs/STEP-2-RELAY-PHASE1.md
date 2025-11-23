# Step 2 — Relay Phase 1 attestation

Status: In progress

Plan:
- Add Relay-only entry point on `EmeraldDaAdapter` for Phase 1 attestations.
- Enforce cid/kzg matches plus stake threshold logic.
- Update registry status and store stake/voter details.
- Tests for pass, fail (low stake), and mismatch rejection.
