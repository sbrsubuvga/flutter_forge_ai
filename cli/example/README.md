# flutterforge_ai_cli — example workflows

End-to-end usage examples. Every snippet is copy-pasteable and assumes the
CLI is already on your `PATH`:

```bash
dart pub global activate flutterforge_ai_cli
```

---

## 1. Add `flutterforge_ai` to a fresh Flutter app

```bash
flutter create my_app
cd my_app
flutterforge init --auto-wire
```

What happens:

1. `pubspec.yaml` gets `flutterforge_ai` (and `flutter_riverpod`) added under
   `dependencies`.
2. `lib/main.dart` is detected as the default `flutter create` counter
   template and rewritten to:
   - call `FlutterForgeAI.init(config: FFConfig(appName: 'my_app'))`
   - wrap the root in `ProviderScope(observers: [FFStateObserver()])`
   - inject `FFDevWrapper` through `MaterialApp.builder`
3. The original file is preserved as `lib/main.dart.bak`.
4. `flutter pub get` runs automatically.

Then just:

```bash
flutter run
```

You'll see the purple DevTools FAB bottom-left and the 🤖 AI FAB
bottom-right the moment the app boots.

---

## 2. Scaffold without touching `main.dart`

When your project is non-standard (custom router, `ProviderScope` already
higher up, multi-MaterialApp, etc.) the CLI refuses to guess. Use:

```bash
flutterforge init            # edits pubspec only
flutterforge init --dry-run  # show what would change, write nothing
```

Then paste the printed snippet into your `main.dart` manually.

---

## 3. Check whether a project is wired up

Run from the project root:

```bash
flutterforge doctor
```

Typical output:

```
✓ pubspec.yaml exists
✓ flutterforge_ai listed in dependencies
✓ flutter_riverpod listed (optional, for FFStateObserver)
✓ lib/main.dart found
✗ FlutterForgeAI.init(...) called
  → See: flutterforge init --auto-wire (patches main.dart for you).
✗ FFDevWrapper present
  → Wrap inside MaterialApp.builder: builder: (ctx, c) => FFDevWrapper(child: c!)
⚠ FFStateObserver registered (optional) — not configured (optional)
  → ProviderScope(observers: [FFStateObserver()], child: ...) enables the State Viewer.
```

Apply the safe remediations (pubspec edits only — never touches
`main.dart`):

```bash
flutterforge doctor --fix
```

Exit code is the number of failed checks — great for CI pipelines:

```yaml
- name: FlutterForge setup check
  run: flutterforge doctor
```

---

## 4. Inspect a snapshot produced on another device

Any JSON file produced by `FFSnapshotGenerator.saveToFile(...)` on a QA
device can be opened with the CLI:

```bash
# Pretty-print the whole snapshot.
flutterforge snapshot view ./snap.json

# One-line summary — good for a triage dashboard.
flutterforge snapshot summary ./snap.json
# → FlutterForge snapshot v0.3.0 — My App v1.2.3 (android 14 Pixel 7)
# → API: total=12, failed=2 · Logs: total=37, errors=1, warnings=3
# → Problem: Login loop after OAuth refresh

# Build an AI-ready prompt and pipe straight to the clipboard.
flutterforge snapshot prompt ./snap.json \
  --problem "Auth loops after refresh" | pbcopy          # macOS
flutterforge snapshot prompt ./snap.json | xclip -sel clip  # Linux
```

---

## 5. Common flags

| Flag                    | Command        | Effect                                              |
| ----------------------- | -------------- | --------------------------------------------------- |
| `--path <dir>`          | `init`/`doctor`| Point at a project root other than `.`              |
| `--dry-run`             | `init`         | Show diff, write nothing                            |
| `--no-run-pub-get`      | `init`         | Skip the trailing `flutter pub get`                 |
| `--no-include-riverpod` | `init`         | Don't add `flutter_riverpod`                         |
| `--auto-wire`           | `init`         | Rewrite `main.dart` when it matches a template      |
| `--app-name "My App"`   | `init`         | Override the generated `FFConfig(appName: …)` value |
| `--fix`                 | `doctor`       | Apply safe pubspec remediations                     |
| `-v` / `--verbose`      | *(global)*     | Emit debug lines                                    |
| `--version`             | *(global)*     | Print CLI version                                    |

---

## 6. Exit codes

| Code | Meaning                                 |
| ---- | --------------------------------------- |
| 0    | Success — no-op or all work completed.  |
| 1    | Missing / invalid project state.        |
| 64   | Usage error (unknown command or flag).  |
| 65   | Invalid JSON in a snapshot file.        |
| 66   | Snapshot file not found.                |
| n    | `doctor` — number of failed checks.     |

See the [main README](../README.md) for command reference and source
links.
