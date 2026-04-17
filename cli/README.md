# flutterforge_ai_cli

> Command-line companion for [`flutterforge_ai`](https://pub.dev/packages/flutterforge_ai).

## Install

```bash
dart pub global activate flutterforge_ai_cli
```

Make sure `$HOME/.pub-cache/bin` is on your `PATH`.

## Commands

### `flutterforge init`

Adds `flutterforge_ai` (and optionally `flutter_riverpod`) to an existing Flutter project's `pubspec.yaml`, then prints the minimal wiring snippet for `main.dart`.

```bash
flutterforge init                # run in the project root
flutterforge init --path ~/apps/my_app
flutterforge init --dry-run      # show what would change, don't write
flutterforge init --no-include-riverpod
```

### `flutterforge doctor`

Audits that an existing Flutter project is wired up correctly. Exits with the number of failures.

```bash
flutterforge doctor
flutterforge doctor --path ~/apps/my_app
```

Checks:

- ✓ `pubspec.yaml` exists
- ✓ `flutterforge_ai` is listed in `dependencies`
- ⚠ `flutter_riverpod` is listed (optional, for `FFStateObserver`)
- ✓ `lib/main.dart` exists
- ✓ `FlutterForgeAI.init(...)` is called
- ✓ `FFDevWrapper` is present
- ⚠ `FFStateObserver` is registered (optional)

### `flutterforge snapshot`

Inspects AI Debug Snapshot JSON files (produced by `FFSnapshotGenerator.saveToFile`).

```bash
# Pretty-print.
flutterforge snapshot view ./snap.json

# One-line summary.
flutterforge snapshot summary ./snap.json

# Emit an AI-ready prompt, pipe to clipboard.
flutterforge snapshot prompt ./snap.json --problem "Login loop" | pbcopy
```

### `flutterforge version`

Prints the CLI version and the version constraint it targets for the companion package.

## Exit codes

| Code | Meaning                               |
| ---- | ------------------------------------- |
| 0    | Success.                              |
| 1    | Missing / invalid project state.      |
| 64   | Usage error (unknown command / flag). |
| 65   | Invalid JSON input.                   |
| 66   | File not found.                       |

## License

MIT — see [LICENSE](LICENSE).
