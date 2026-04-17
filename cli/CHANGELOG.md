# Changelog

## [0.2.0] - 2026-04-17

### Added
- **`flutterforge init --auto-wire`** — detects `lib/main.dart` shape and safely rewrites it when it matches a known template (the default `flutter create` counter template or a minimal `MyApp` shell). The original is preserved at `lib/main.dart.bak` and the rewrite uses the canonical pattern: `Future<void> main() async` + `FlutterForgeAI.init` + `ProviderScope(observers: [FFStateObserver()])` + `MaterialApp(builder: (…) => FFDevWrapper(…))`. Non-standard main.dart files are refused safely.
- **`flutterforge init` now runs `flutter pub get`** automatically at the end (disable with `--no-run-pub-get`).
- **`flutterforge doctor --fix`** — applies the safe remediations (currently: adding `flutterforge_ai` to `pubspec.yaml`). Changes to `main.dart` remain a separate `init --auto-wire` step.
- New `MainDartWiring` module with explicit shape detection (`WiringShape.counterTemplate` / `minimalMyApp` / `alreadyWired` / `unknown`) and unit tests.

### Changed
- Target package constraint bumped to `^0.1.2` (so `init` writes the version that ships the `FlutterForgeAI.generateSnapshot()` facade).
- Version bumped to `0.2.0`.
- Help output now documents `--auto-wire`, `--run-pub-get`, `--app-name`, and `--fix`.

## [0.1.0] - 2026-04-17

### Added
- `flutterforge init` — safely adds `flutterforge_ai` (and optionally `flutter_riverpod`) to an existing Flutter project's `pubspec.yaml` via `yaml_edit`, then prints the exact `main.dart` wiring snippet. Supports `--dry-run` and `--path`.
- `flutterforge doctor` — checks that the package is listed, `main.dart` calls `FlutterForgeAI.init()`, `FFDevWrapper` is present, and (optionally) `FFStateObserver` is registered. Exits with the number of failures.
- `flutterforge snapshot view|prompt|summary <file.json>` — inspects AI snapshots produced by `FFSnapshotGenerator.saveToFile`, emits AI-ready prompts, or one-line summaries (designed for piping into `pbcopy` / `xclip`).
- `flutterforge version` — prints both CLI version and target package constraint.
- Colour-aware logger that strips ANSI in non-TTY contexts.
- Unit tests for all commands.
