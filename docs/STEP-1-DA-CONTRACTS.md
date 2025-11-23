# Step 1 — DA data model & core contracts

Status: In progress

Plan:
- Define `EmeraldPostRegistry` data model and events.
- Stub `EmeraldDaAdapter` storage/events for Phase 1 decisions and custody placeholders.
- Add simple `MockKzgVerifier`.
- Cover registry/adapter interactions with Foundry tests for the shell flow.

Progress:
- Added `EmeraldPostRegistry` create/get with pending status default and `PostCreated` event.
- Added DA-only status setter on registry with `PostStatusChanged` event and tests.
- Added `EmeraldDaAdapter` Phase 1 handler storing stakes/voters and updating registry status.
