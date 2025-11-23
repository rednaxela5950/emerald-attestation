# Step 4 — Dummy data network & DA worker

Status: In progress

Plan:
- Scaffold dummy blob service (Fastify/Express) with POST/GET endpoints storing blobs and returning cid hashes.
- Create `packages/emerald-da-worker` entry that watches registry events, fetches blobs, and stubs Relay/custody responses.
- Add minimal tests (unit or integration) to cover honest vs lazy worker behaviour.
- Wire scripts/config for local dev (run service, run worker).
