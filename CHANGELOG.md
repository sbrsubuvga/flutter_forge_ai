# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

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
