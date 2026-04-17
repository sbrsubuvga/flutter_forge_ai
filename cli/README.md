# flutterforge_ai_cli

> Command-line companion for [`flutterforge_ai`](https://pub.dev/packages/flutterforge_ai).

## Install

```bash
dart pub global activate flutterforge_ai_cli
```

Make sure `$HOME/.pub-cache/bin` is on your `PATH`.

## Commands

### `flutterforge init`

Adds `flutterforge_ai` (and optionally `flutter_riverpod`) to an existing Flutter project's `pubspec.yaml`. Runs `flutter pub get` automatically at the end. Can rewrite `lib/main.dart` for you when it matches a known template.

```bash
flutterforge init                      # add deps, print snippet, run `pub get`
flutterforge init --auto-wire          # …AND rewrite lib/main.dart (keeps .bak)
flutterforge init --path ~/apps/app
flutterforge init --dry-run            # show what would change, don't write
flutterforge init --no-run-pub-get     # skip the auto `flutter pub get`
flutterforge init --no-include-riverpod
flutterforge init --app-name "My App"  # override the generated FFConfig name
```

Auto-wire rules:

- Targets the default `flutter create` counter template **and** minimal `MyApp + runApp(const MyApp())` files.
- Writes `lib/main.dart.bak` before overwriting.
- Refuses anything it doesn't recognise — you'll get the manual snippet to paste.
- No-op if `main.dart` already imports or calls FlutterForge APIs.

### `flutterforge doctor`

Audits that an existing Flutter project is wired up correctly. Exits with the number of failures.

```bash
flutterforge doctor
flutterforge doctor --path ~/apps/my_app
flutterforge doctor --fix              # apply safe pubspec remediations
```

Checks:

- ✓ `pubspec.yaml` exists
- ✓ `flutterforge_ai` is listed in `dependencies`   (`--fix` applies)
- ⚠ `flutter_riverpod` is listed (optional, for `FFStateObserver`)
- ✓ `lib/main.dart` exists
- ✓ `FlutterForgeAI.init(...)` is called             (fix via `init --auto-wire`)
- ✓ `FFDevWrapper` is present                        (fix via `init --auto-wire`)
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
