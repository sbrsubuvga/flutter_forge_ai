# Changelog

## [0.2.0] - 2026-04-17

### Added
- **Activity Bar panel** — dedicated FlutterForge sidebar listing recent snapshots (persisted per workspace). Click opens the webview; right-click removes from history; title actions for Open / Refresh / Clear History.
- **Status bar entry** — shows the current history count; click opens the snapshot picker.
- **Rich webview** — each top-level section (App / Device / DB / API / State / Logs) is a native `<details>` block with badge summaries (e.g. *"3, 1 failed"*). API-call rows are colour-coded by status class; log rows by level; DB/state sections render as tables instead of raw JSON dumps.
- **CLI integration commands** — `FlutterForge: Run Doctor in Terminal` and `FlutterForge: Run Init in Terminal` shell out to the companion `flutterforge` CLI in a VS Code Terminal.
- **ESLint config** + GitHub Actions workflow (`.github/workflows/vscode.yml`) lints and compiles on every PR touching `vscode/**`.

### Changed
- Package version bumped `0.1.0` → `0.2.0`.
- Activation events cleaned up — VS Code auto-derives them from the `contributes` block.
- Description tightened: "Open, explore, and copy AI prompts from AI Debug Snapshots".

## [0.1.0] - 2026-04-17

### Added
- Command: **FlutterForge: Open AI Debug Snapshot…** — pick a JSON file and render structured sections (app / device / DB / API / state / logs) in a Webview.
- Command: **FlutterForge: Copy AI Prompt from Snapshot…** — build an AI-ready prompt and copy it to the clipboard.
- `parseSnapshot` validator — rejects files missing the required top-level keys.
- Configurable default snapshot directory (`flutterforge.defaultSnapshotDirectory`).
