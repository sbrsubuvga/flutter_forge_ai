# Contributing to FlutterForge AI

Thanks for helping build an AI-observable future for Flutter apps.

## Ground rules

1. **Keep it debuggable.** Anything we add should be traceable via the existing
   logger / snapshot surface.
2. **Debug-only devtools.** Every new devtool must be gated by
   `FlutterForgeAI.showDevTools` or an equivalent `kReleaseMode` check.
3. **Mask-by-default.** Any captured data that can contain user credentials
   goes through `FFSensitiveDataMasker`.

## Getting set up

```bash
flutter pub get
flutter analyze
flutter test --coverage
```

## Running the example app

```bash
cd example
flutter pub get
flutter run
```

## Commit style

We follow [Conventional Commits](https://www.conventionalcommits.org/en/v1.0.0/):

- `feat: add state viewer filter`
- `fix: mask cookies in interceptor`
- `docs: expand README quick start`
- `chore: bump dependencies`

## Opening a PR

1. Ensure `flutter analyze` is clean.
2. Ensure all tests pass (`flutter test`).
3. Add or update tests for new behaviour.
4. Update `CHANGELOG.md` under the *Unreleased* section.
5. Use the PR template checklist.

## Reporting issues

The fastest path to a fix is pasting an AI Debug Snapshot in your bug report —
see `.github/ISSUE_TEMPLATE/bug_report.md`.
