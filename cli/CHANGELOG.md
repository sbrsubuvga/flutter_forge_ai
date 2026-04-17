# Changelog

## [0.1.0] - 2026-04-17

### Added
- `flutterforge init` — safely adds `flutterforge_ai` (and optionally `flutter_riverpod`) to an existing Flutter project's `pubspec.yaml` via `yaml_edit`, then prints the exact `main.dart` wiring snippet. Supports `--dry-run` and `--path`.
- `flutterforge doctor` — checks that the package is listed, `main.dart` calls `FlutterForgeAI.init()`, `FFDevWrapper` is present, and (optionally) `FFStateObserver` is registered. Exits with the number of failures.
- `flutterforge snapshot view|prompt|summary <file.json>` — inspects AI snapshots produced by `FFSnapshotGenerator.saveToFile`, emits AI-ready prompts, or one-line summaries (designed for piping into `pbcopy` / `xclip`).
- `flutterforge version` — prints both CLI version and target package constraint.
- Colour-aware logger that strips ANSI in non-TTY contexts.
- Unit tests for all commands.
