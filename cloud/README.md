# FlutterForge Cloud

> **v0.1 scaffold — not production.** Receives AI Debug Snapshots from apps in the field, stores them, and lets your team browse them in a web dashboard.

## Components

```
cloud/
├── api/            # Node 20 / Express / TypeScript — receive + store
├── web/            # Next.js 14 — dashboard for browsing snapshots
└── docker-compose.yml
```

## What works today

- ✅ `POST /snapshots` — accepts a FlutterForge JSON body, validates the minimum shape, returns an id.
- ✅ `GET /snapshots` — lists all stored snapshots with pagination.
- ✅ `GET /snapshots/:id` — returns one by id.
- ✅ `GET /healthz` — liveness probe.
- ✅ In-memory store (trivial Map). Dev-only.
- ✅ Web dashboard home page lists snapshots and links to a detail page.
- ✅ `docker compose up` runs API + web together.

## What's deliberately NOT implemented yet

- 🔴 **Auth** — currently the API is open. Before production, add an API key per project or full JWT + org model.
- 🔴 **Persistence** — Postgres / SQLite wiring. `api/src/store` has a `MemoryStore`; swap in a real backend.
- 🔴 **Agent inside the Flutter app** — on-device sender from `flutterforge_ai` that POSTs snapshots on demand or on uncaught error.
- 🔴 **AI analysis** — server-side call to Claude / GPT that pre-annotates each incoming snapshot with a suggested root cause.
- 🔴 **Deployment** — no Dockerfile for production, no Terraform / Pulumi, no CI for the cloud subtree.

## Run locally

```bash
cd cloud
docker compose up --build
# API  → http://localhost:4000
# Web  → http://localhost:3000
```

Or without Docker:

```bash
cd cloud/api && npm install && npm run dev
cd cloud/web && npm install && npm run dev
```

Post a sample snapshot:

```bash
curl -X POST http://localhost:4000/snapshots \
  -H 'Content-Type: application/json' \
  --data @../example-snapshot.json
```

## License

MIT
