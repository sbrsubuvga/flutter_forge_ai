# 🛠️ FlutterForge AI

> **AI-Ready Flutter template** — build observable apps that AI can debug with full context.

[![pub version](https://img.shields.io/pub/v/flutterforge_ai.svg)](https://pub.dev/packages/flutterforge_ai)
[![pub points](https://img.shields.io/pub/points/flutterforge_ai)](https://pub.dev/packages/flutterforge_ai/score)
[![likes](https://img.shields.io/pub/likes/flutterforge_ai)](https://pub.dev/packages/flutterforge_ai)
[![popularity](https://img.shields.io/pub/popularity/flutterforge_ai)](https://pub.dev/packages/flutterforge_ai)
[![CI](https://github.com/sbrsubuvga/flutter_forge_ai/actions/workflows/ci.yml/badge.svg)](https://github.com/sbrsubuvga/flutter_forge_ai/actions/workflows/ci.yml)
[![coverage](https://img.shields.io/codecov/c/github/sbrsubuvga/flutter_forge_ai)](https://codecov.io/gh/sbrsubuvga/flutter_forge_ai)
[![license](https://img.shields.io/badge/license-MIT-blue.svg)](LICENSE)

**One tap. One snapshot. Your AI fixes the bug.**

FlutterForge AI turns `print()` debugging into a solved problem. Tap the 🤖
button in your app, paste the generated JSON into ChatGPT / Claude / Cursor,
and get an accurate fix in seconds — complete with the database state, API
history, provider values, and logs at the moment things went wrong.

---

## ✨ Why FlutterForge AI?

| Old paradigm                 | New paradigm                     |
| ---------------------------- | -------------------------------- |
| `print()` → guess → retry    | Tap button → paste → get fix     |
| Hours of debugging           | 30 seconds                       |
| Screenshots + vague prompts  | Structured JSON with real state  |
| "It works on my machine"     | "Here's exactly what happened"   |

---

## 🚀 Features

- 🗄️ **Database Console** — browse tables, inspect schema, run raw SQL, optional web workbench via `sqflite_dev`.
- 🌐 **API Inspector** — Alice-style list of every Dio request, one-tap cURL export, sensitive header masking.
- 🧠 **State Viewer** — Riverpod provider list with live values and a change timeline (add / update / dispose / fail).
- 📝 **Log Viewer** — Talker-style colour-coded log list with level filters, search, full stack traces.
- 🤖 **AI Debug Snapshot** — one call bundles DB + API + State + Logs + device info into an AI-ready prompt.
- 📱 **Multiple triggers** — draggable FAB, green 🤖 FAB, shake-to-open (mobile), Alt+F12 (desktop).
- 🛡️ **Sensitive-data masking** — headers, body keys, and URL query params automatically redacted.
- 🔒 **Release-safe** — every devtool auto-disabled in `kReleaseMode`.
- 🧪 **Well tested** — ring buffer, masker, logger, interceptor, snapshot generator unit-tested.
- 🌍 **All platforms** — Android, iOS, macOS, Windows, Linux, Web.

---

## 📦 Installation

```bash
flutter pub add flutterforge_ai
```

Or add to `pubspec.yaml`:

```yaml
dependencies:
  flutterforge_ai: ^0.1.0
```

---

## ⚡ Quick start (3 lines)

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutterforge_ai/flutterforge_ai.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 1. One-line init.
  await FlutterForgeAI.init(
    config: const FFConfig(appName: 'My App', baseUrl: 'https://api.example.com'),
  );

  runApp(
    ProviderScope(
      observers: [FFStateObserver()],   // 2. track Riverpod state
      child: const FFDevWrapper(child: MyApp()),  // 3. inject overlay
    ),
  );
}
```

That's it. Tap the purple FAB for devtools, tap 🤖 for an AI snapshot.

---

## 🛠️ Usage

### Make API calls

```dart
final dio = FFApiClient.instance.dio;
final resp = await dio.get('/users');
```

Every request appears live in the **API Inspector** tab with method, URL,
status, duration, full request/response, and a ready-to-paste cURL command.

### Log anything

```dart
FFLogger.info('User logged in');
FFLogger.error('Payment failed', error: e, stackTrace: st);
```

All entries show up in the **Log Viewer**, filterable by level.

### Query the database

```dart
final db = FFDbHelper.instance.database;
await db.insert('users', {'name': 'Alice'});
```

Open the **Database Console** tab to browse tables, inspect schema, and run
ad-hoc SQL.

### Generate an AI snapshot

```dart
final snap = await FFSnapshotGenerator.generate(problem: 'Login loop');
final prompt = FFPromptFormatter.format(snap);
await FFClipboardHelper.copy(prompt);
// Snackbar: "✅ Prompt copied. Paste to your AI assistant."
```

---

## 🔐 Configuration

```dart
const config = FFConfig(
  appName: 'My App',
  dbName: 'my_app.db',
  baseUrl: 'https://api.example.com',
  envFile: '.env',
  enableDevTools: true,
  enableDbWorkbench: true,
  dbWorkbenchPort: 8080,
  enableAiDebugButton: true,
  enableShakeToOpen: true,
  shakeThreshold: 15.0,
  enableKeyboardShortcut: true,
  maxApiCallsStored: 200,
  maxLogsStored: 500,
  maxStateChangesStored: 300,
  sensitiveHeaders: {'authorization', 'x-api-key', 'cookie'},
  sensitiveBodyKeys: {'password', 'token', 'secret'},
  apiTimeout: Duration(seconds: 30),
  enablePrettyDioLogger: true,
  persistSnapshots: false,
  minLogLevel: FFLogLevel.verbose,
  primaryColor: Color(0xFF6366F1),
  devToolsTheme: ThemeMode.system,
);
```

---

## 🏗️ Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                    FlutterForgeAI.init()                    │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│   ┌────────┐  ┌───────┐  ┌──────────┐  ┌───────────────┐    │
│   │ Logger │  │  DB   │  │ API/Dio  │  │ State Observer│    │
│   └───┬────┘  └───┬───┘  └────┬─────┘  └───────┬───────┘    │
│       ▼           ▼           ▼                ▼            │
│   ┌────────┐  ┌─────────┐ ┌─────────┐   ┌──────────┐        │
│   │Log store│ │Schema   │ │API store│   │State store│       │
│   │(ring)   │ │+ runner │ │(ring)   │   │(ring)    │        │
│   └────┬────┘ └─────────┘ └────┬────┘   └─────┬────┘        │
│        ▼           ▼           ▼              ▼             │
│       ┌──────────────────────────────────────────┐          │
│       │          FFSnapshotGenerator             │          │
│       │  → AI-ready JSON via FFPromptFormatter   │          │
│       └──────────────────────────────────────────┘          │
└─────────────────────────────────────────────────────────────┘
                        │
                        ▼
              ┌───────────────────┐
              │   FFDevDashboard  │
              │ DB │ API │ State │ Logs
              │   + 🤖 AI button  │
              └───────────────────┘
```

See [doc/architecture.md](doc/architecture.md) for the deep dive.

---

## 🤖 The AI Debug Workflow

1. Your app hits a bug in development.
2. Tap the green 🤖 FAB (or shake the device, or press Alt+F12 → **AI Snapshot**).
3. Optionally type the symptom ("Login loop after OAuth").
4. Tap **Copy AI prompt**.
5. Paste into ChatGPT / Claude / Cursor / Cody.
6. Get a targeted, contextual fix.

Example prompt (auto-generated):

```
I'm debugging a Flutter app. Here's the complete app context captured by
FlutterForge AI. Please analyse and suggest a fix.

PROBLEM: Login loop after OAuth

APP CONTEXT:
{
  "flutterforge_version": "0.1.0",
  "app": { "name": "My App", "version": "1.2.3" },
  "device": { "platform": "android", "os_version": "14", "model": "Pixel 7" },
  "database": { "tables": [ … ] },
  "api_logs": {
    "recent_calls": [
      { "method": "POST", "url": "…/oauth/refresh", "status_code": 401, … }
    ]
  },
  "app_state": {
    "active_providers": [
      { "name": "authProvider", "current_value": "AuthState(token: null)" }
    ]
  },
  "logs": { "recent_entries": [ … ] }
}

Please:
1. Identify the root cause.
2. Suggest specific code fixes.
3. Point to the exact provider / API call / DB query that's failing.
```

---

## ❓ FAQ

**Does FlutterForge AI ship in my release build?**
Every devtool, the shake detector, the floating buttons, and the snapshot
generator are gated behind `!kReleaseMode`. In release, `FFDevWrapper` becomes
a pass-through and `FFSnapshotGenerator.generate()` returns an empty snapshot.

**Does the AI see my raw auth tokens?**
No — everything goes through `FFSensitiveDataMasker`. `Authorization`,
`Cookie`, `X-API-Key` headers, `password` / `token` / `secret` body keys, and
`?token=` URL params are replaced with `***` before the call is even stored.

**What about my Bearer token in the cURL export?**
Same masker runs on `APICall.toCurl()`.

**Is `sqflite_dev` required?**
No. It's an **optional** peer dependency. If you add it to your
`dev_dependencies`, the web workbench starts on port 8080 in debug; if not,
the rest of the DB features still work.

**Can I use a different state manager?**
The package ships a Riverpod `ProviderObserver`. For Bloc, Provider, etc.,
just don't mount `FFStateObserver` — the rest of the devtools stays useful.

**Does the snapshot include PII?**
The automated masking covers common fields. Review the generated JSON before
pasting to a third-party AI if you handle regulated data.

**Does it work on web?**
Yes, with a few native features (sqflite workbench, shake detection) disabled
automatically.

**How much memory does it use?**
Everything lives in fixed-size ring buffers you configure
(`maxLogsStored`, `maxApiCallsStored`, …). Default total footprint in debug is
~1 MB.

**Can I persist snapshots?**
Set `persistSnapshots: true` and the last snapshot is stored via
`SharedPreferences`. Read it back with
`FFSnapshotGenerator.lastPersistedJson()`.

**How do I contribute?**
See [.github/CONTRIBUTING.md](.github/CONTRIBUTING.md).

---

## 🗺️ Roadmap

- GraphQL interceptor parity
- Bloc / Provider observer adapters
- Supabase / Firebase native adapters
- On-device AI assistant using a local LLM
- Inline "diff" in the State Viewer
- Time-travel debugger for state events

---

## 📄 License

MIT © FlutterForge AI contributors — see [LICENSE](LICENSE).
