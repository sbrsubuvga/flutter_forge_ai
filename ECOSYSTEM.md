# FlutterForge AI — Ecosystem Overview

FlutterForge AI is not a single package — it's a 4-component ecosystem unified around one idea:

> **Flutter apps should be observable systems that an AI can debug with full context.**

---

## The four components

```
┌──────────────────────────────────────────────────────────────────────────┐
│                         FlutterForge AI ecosystem                        │
├──────────────────────────────────────────────────────────────────────────┤
│                                                                          │
│  ┌─────────────────────┐   ┌─────────────────────┐                       │
│  │  1. Flutter package │   │  2. CLI tool        │                       │
│  │  flutterforge_ai    │◄──│  flutterforge_ai_cli│                       │
│  │  (runtime + UI)     │   │  init / doctor /    │                       │
│  │                     │   │  snapshot           │                       │
│  └────────┬────────────┘   └─────────────────────┘                       │
│           │                                                              │
│           │ JSON snapshot                                                │
│           ▼                                                              │
│  ┌─────────────────────┐   ┌─────────────────────┐                       │
│  │  3. VS Code         │   │  4. Cloud           │                       │
│  │  extension          │   │  (API + dashboard)  │                       │
│  │  view / copy prompt │   │  receive / store /  │                       │
│  │                     │   │  browse             │                       │
│  └─────────────────────┘   └─────────────────────┘                       │
│                                                                          │
└──────────────────────────────────────────────────────────────────────────┘
```

| Folder   | Component                    | Status                   | Ships as                                 |
| -------- | ---------------------------- | ------------------------ | ---------------------------------------- |
| root     | **Flutter package**          | ✅ **published**         | [pub.dev/packages/flutterforge_ai](https://pub.dev/packages/flutterforge_ai) |
| `cli/`   | **CLI tool**                 | ✅ ready to publish      | pub.dev global activate `flutterforge_ai_cli` |
| `vscode/`| **VS Code extension**        | 🟡 scaffold              | VS Code Marketplace (post-auth)          |
| `cloud/` | **Cloud receiver + dashboard** | 🟡 scaffold (dev only) | self-hosted Docker Compose               |

---

## What "scaffold" vs "ready" means

- **Ready** — real code, tests pass, `dart pub publish --dry-run` clean, immediately shippable.
- **Scaffold** — real project structure, valid config, minimum working example, clearly labeled unfinished surfaces in its own README.

The `cli/` tool is fully functional: `init`, `doctor`, `snapshot view|prompt|summary` all work end-to-end and have 16 unit tests.

The `vscode/` extension compiles, activates, picks a snapshot file, and renders it in a Webview — but live-mode (reading from a running app) is a clearly-called-out todo.

The `cloud/` service accepts `POST /snapshots`, lists them, and renders them — but persistence is in-memory only and there's no auth. Production shipping requires the work listed in [`cloud/README.md`](cloud/README.md).

---

## The data flow

1. Your app imports `flutterforge_ai` (root package) and calls `FlutterForgeAI.init(...)`.
2. At any point — in development or from a QA device — `FFSnapshotGenerator.generate()` produces a JSON object with DB rows, API calls, provider state, logs, and device info.
3. You pick one of three destinations for that JSON:
   - **Clipboard → AI** — the default one-tap flow in the Flutter package.
   - **File → CLI / VS Code extension** — offline review, diffing, piping into your own tooling.
   - **HTTP POST → cloud** — remote aggregation across a fleet of devices for a QA team.

Every component speaks the same JSON schema, described in [`doc/architecture.md`](doc/architecture.md) under "Snapshot shape".

---

## Per-component documentation

- [`README.md`](README.md) — the Flutter package (audience: app developers installing it from pub.dev).
- [`cli/README.md`](cli/README.md) — CLI tool usage + commands.
- [`vscode/README.md`](vscode/README.md) — extension features + dev setup.
- [`cloud/README.md`](cloud/README.md) — cloud service architecture + run locally.
- [`doc/architecture.md`](doc/architecture.md) — deep dive into the core runtime.
- [`doc/WORKFLOW.md`](doc/WORKFLOW.md) — demo recording script + image asset layout.

---

## Working on the whole repo

Each folder is independent — none of them share a build system or a lockfile. Common commands from the repo root:

```bash
# Flutter package (root).
flutter pub get && flutter analyze && flutter test

# CLI.
cd cli && dart pub get && dart analyze && dart test

# VS Code extension.
cd vscode && npm install && npm run compile

# Cloud — API.
cd cloud/api && npm install && npm run dev

# Cloud — web dashboard.
cd cloud/web && npm install && npm run dev
```

Or spin up the whole cloud stack together:

```bash
cd cloud && docker compose up --build
```

---

## Shipping discipline

The four components version and release **independently** — a README tweak for the Flutter package shouldn't require re-publishing the CLI.

| Component | Version source   | Publish trigger                         |
| --------- | ---------------- | --------------------------------------- |
| package   | `pubspec.yaml`   | `flutter pub publish` + pub.dev OAuth   |
| cli       | `cli/pubspec.yaml` | `dart pub publish` from `cli/`        |
| vscode    | `vscode/package.json` | `vsce publish` from `vscode/`      |
| cloud     | each sub-package | Docker image(s) to your own registry    |

Follow [Semantic Versioning](https://semver.org/); anything user-visible breaking → major bump, new capability → minor, fixes → patch.

---

## License

MIT across all components — see each folder's `LICENSE`.
