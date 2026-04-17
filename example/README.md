# FlutterForge AI — Example App

A runnable demo that exercises every feature of `flutterforge_ai`:

- Riverpod state management (`StateNotifierProvider`)
- HTTP requests via `FFApiClient` to `jsonplaceholder.typicode.com`
- SQLite CRUD via `FFDbHelper`
- Logging via `FFLogger`
- AI Snapshot generation

## Run

```bash
cd example
flutter pub get
flutter run
```

Trigger the devtools by:
- Tapping the purple FAB (bottom-left), or
- Tapping the green 🤖 FAB (bottom-right) for the AI snapshot, or
- Shaking the device (mobile), or
- Pressing **Alt + F12** (desktop).
