# Step 1 — DA data model & core contracts

Status: Done

Plan:
- Define `EmeraldPostRegistry` data model and events.
- Stub `EmeraldDaAdapter` storage/events for Phase 1 decisions and custody placeholders.
- Add simple `MockKzgVerifier`.
- Cover registry/adapter interactions with Foundry tests for the shell flow.

Progress:
- Added `EmeraldPostRegistry` create/get with pending status default and `PostCreated` event.
- Added DA-only status setter on registry with `PostStatusChanged` event and tests.
- Added `EmeraldDaAdapter` Phase 1 handler storing stakes/voters, custody placeholders, and updating registry status.
- Added `MockKzgVerifier` with toggleable result for custody tests later.

Result:
- Registry now tracks posts with DA-only status updates and emits creation/status events.
- Adapter stores Phase 1 stake data, custody placeholders, and drives registry status changes.
- Mock KZG verifier toggles pass/fail; tests cover registry create/status flows and adapter Phase 1 handling.
