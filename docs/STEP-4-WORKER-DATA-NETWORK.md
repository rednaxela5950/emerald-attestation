# Step 4 — Dummy data network & DA worker

Status: In progress

Plan:
- Scaffold dummy blob service (Fastify/Express) with POST/GET endpoints storing blobs and returning cid hashes.
- Create `packages/emerald-da-worker` entry that watches registry events, fetches blobs, and stubs Relay/custody responses.
- Add minimal tests (unit or integration) to cover honest vs lazy worker behaviour.
- Wire scripts/config for local dev (run service, run worker).

Progress:
- Added Express-based in-memory blob service with POST/GET endpoints under `packages/emerald-da-worker`.
- Added `processPost` worker helper to fetch blobs, check cid hash, and tests covering ok/mismatch/missing paths.
- Added config/env placeholders for blob service, RPC, and registry address to prep event wiring.
- Added registry log parser for `PostCreated` to prep event-driven worker flow.
- Worker now subscribes to registry logs and routes `PostCreated` to the decision helper.
- Added adapter log parsers and subscription to custody challenges; lazy mode skips proofs, eager mode stubs proof submission.
- Custody proof stub now issues an ethers contract call to adapter when not lazy.

Next:
- Hook worker stub to on-chain events (PostCreated, custody) and simulate Relay/custody responses.
