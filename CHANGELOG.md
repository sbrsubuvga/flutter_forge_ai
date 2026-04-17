# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [0.2.0] - 2026-04-17

### Added — "Diagnose with AI" (the killer moment)
- **New `src/ai/` module** wiring a bring-your-own-key LLM call directly into the snapshot preview:
  - `FFAiProvider` enum — `anthropic` (Claude Messages API) + `openai` (Chat Completions, also works with Azure OpenAI / Ollama proxies via the `baseUrl` override).
  - `FFAiConfig` — immutable config with `effectiveModel` / `effectiveBaseUrl` fallbacks. `toJsonSansKey()` guarantees the API key is never serialised alongside snapshots.
  - `FFAiClient.forConfig(config)` factory dispatching to the right provider implementation; tests inject a mock `Dio`.
  - `FFAnthropicClient` + `FFOpenAiClient` — concrete impls, both handle non-2xx responses as `FFAiException` (with status code + raw provider body for easier debugging).
  - `FFAiSettingsStore` — `SharedPreferences`-backed persistence under the `flutterforge.ai.*` namespace.
  - `FFAiPrompt` — opinionated system prompt + user-prompt builder that embeds the snapshot JSON and the problem statement.
- **New UI**:
  - `AiSettingsScreen` — provider picker, key/model/base-URL inputs, show/hide toggle, clear-key action.
  - `DiagnoseResultScreen` — fires the diagnosis, shows a spinner, renders the response as selectable text with `FFAiResponse` metadata chips (provider, model, token counts, finish reason), retry button, settings shortcut.
  - Snapshot preview screen now has a **"Diagnose with AI"** primary button (plus a settings gear in the app bar); the old "Copy AI prompt" stays as a secondary action so the manual workflow remains available.
- Tests: `FFAiConfig` behaviour, `FFAnthropicClient` happy path + auth-error path (mocked Dio), `FFAiProviderX` defaults.

### Changed
- Version bumped `0.1.2` → `0.2.0` (new public API surface).
- Barrel re-exports the new `ai/` modules and the two new screens.

## [0.1.2] - 2026-04-17

### Added
- `FlutterForgeAI.generateSnapshot(problem: '…')` — thin top-level facade over `FFSnapshotGenerator.generate(...)`. Both continue to work; prefer the facade at call sites that already reference `FlutterForgeAI`.

### Changed
- **README**: new "What's actually in the box" capability table right after the 30-second workflow, so reviewers can see the shipped feature set (DevDashboard / snapshot / interceptor / masking / etc.) without scrolling. Roadmap section rewritten with an honest shipped/next split — CLI marked ✅, cloud parked, "Diagnose with AI" flagged as the real next move.
- **ECOSYSTEM.md**: status table now labels the VS Code extension as v0.2 in-repo (not just a scaffold), the CLI with its current limits, and the cloud as "parked post-v1".

## [0.1.1] - 2026-04-17

### Changed
- **Docs**: README rewritten with sharper one-line positioning, a 30-second workflow diagram, a comparison table vs Alice / Talker / pretty_dio_logger, explicit `dependency` vs `dev_dependency` guidance, and a screenshot slot reference list.
- **Docs**: Added [doc/WORKFLOW.md](doc/WORKFLOW.md) — step-by-step recording script and asset-layout guide for the `doc/images/` screenshots + hero GIF.
- Version bumped so the published pub.dev page picks up the new README.

### Fixed
- `FFSensitiveDataMasker.maskUrl` — `Uri.replace` URL-encodes the `***` mask as `%2A%2A%2A`; the masker now decodes it back so the devtools UI shows `token=***` instead of `token=%2A%2A%2A`.

## [0.1.0] - 2026-04-17

### Added
- Database console with table browser, row viewer, and raw SQL runner via `FFDbHelper`.
- Optional `sqflite_dev` web workbench enabler (no-ops if the dev package is absent).
- In-app API Inspector (`FFApiStore`) powered by a Dio interceptor with cURL export.
- Riverpod state viewer (`FFStateObserver`) tracking provider adds, updates, disposals, and failures.
- Log viewer (`FFLogger` + `FFLogStore`) with level filtering, search, and full stack traces.
- AI Debug Snapshot generator (`FFSnapshotGenerator`) capturing DB schema, API calls, state, logs, device, and app info as structured JSON for pasting to AI assistants.
- Clipboard / share / save-to-file actions for snapshots.
- Floating access buttons (DevTools FAB + AI FAB), draggable bubble overlay, shake-to-open (mobile), and Alt+F12 keyboard shortcut (desktop).
- Automatic sensitive-data masking for headers, body keys, and URL query params.
- Release-mode safety: every devtool, snapshot generator, and trigger is automatically disabled when `kReleaseMode` is true.
- Cross-platform support: Android, iOS, macOS, Windows, Linux, Web.
- 80%+ unit-test coverage across ring buffer, masker, logger, API interceptor, snapshot generator, and prompt formatter.
- Fully working example app demonstrating CRUD, real HTTP calls, Riverpod state, error capture, and snapshot generation.
