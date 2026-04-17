# 🛠️ FlutterForge AI

> **FlutterForge AI is a developer toolkit that makes Flutter apps _observable_ and _AI-debuggable_ — DB, API, state, and logs in one place, exportable as a single AI-ready JSON snapshot.**

[![pub version](https://img.shields.io/pub/v/flutterforge_ai.svg)](https://pub.dev/packages/flutterforge_ai)
[![pub points](https://img.shields.io/pub/points/flutterforge_ai)](https://pub.dev/packages/flutterforge_ai/score)
[![likes](https://img.shields.io/pub/likes/flutterforge_ai)](https://pub.dev/packages/flutterforge_ai)
[![popularity](https://img.shields.io/pub/popularity/flutterforge_ai)](https://pub.dev/packages/flutterforge_ai)
[![CI](https://github.com/sbrsubuvga/flutter_forge_ai/actions/workflows/ci.yml/badge.svg)](https://github.com/sbrsubuvga/flutter_forge_ai/actions/workflows/ci.yml)
[![license](https://img.shields.io/badge/license-MIT-blue.svg)](LICENSE)

> One tap. One snapshot. Your AI fixes the bug.

Tap the 🤖 button in your app, paste the generated JSON into ChatGPT / Claude / Cursor, and get an accurate fix in seconds — complete with the database state, API history, provider values, and logs at the moment things went wrong.

> 💡 This Flutter package is **one of four components**. The full ecosystem also ships a CLI (`flutterforge init`/`doctor`/`snapshot`), a VS Code extension, and an optional self-hosted cloud receiver. See [ECOSYSTEM.md](ECOSYSTEM.md) for the overview.

<p align="center">
  <img src="doc/images/hero.gif" alt="FlutterForge AI debug workflow" width="720" />
  <br/>
  <em>(Replace <code>doc/images/hero.gif</code> with your own recording — see <a href="doc/WORKFLOW.md">doc/WORKFLOW.md</a>.)</em>
</p>

---

## 🚀 30-second workflow

```
┌─ You hit a bug ─────────────────────────────────────────────────┐
│                                                                 │
│   1. Tap 🤖 in your app  (or shake, or Alt+F12)                 │
│   2. Type the symptom:  "Login loops after OAuth refresh"       │
│   3. Tap "Copy AI prompt"                                       │
│   4. Paste into ChatGPT / Claude / Cursor                       │
│   5. Get a contextual fix — the AI sees your DB rows, last      │
│      API calls, current provider state, and recent logs.        │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

The snapshot is structured JSON — no screenshots, no guessing, no "it works on my machine".

---

## ✅ What's actually in the box

Not promises — these are shipped and covered by tests.

| Capability                                   | One-call API                                           | UI                                   |
| -------------------------------------------- | ------------------------------------------------------ | ------------------------------------ |
| 4-tab DevTools dashboard                     | `FFDevWrapper(child: ...)`                             | `FFDevDashboard` — DB / API / State / Logs |
| Database console + raw-SQL runner            | `FFDbHelper.instance.database`                         | DB tab                               |
| Alice-style API inspector with cURL export   | `FFApiClient.instance.dio`                             | API tab + detail view                |
| Riverpod state viewer (live + history)       | `FFStateObserver()` (as `ProviderScope` observer)      | State tab                            |
| Colour-coded log viewer with filters         | `FFLogger.info` / `.error` / `.warning` / …            | Logs tab                             |
| AI Debug Snapshot (the killer flow)          | `FFSnapshotGenerator.generate(problem: '...')`         | 🤖 FAB → preview → Copy AI prompt    |
| Sensitive-data masking                       | automatic on all captures                              | —                                    |
| Release-mode auto-disable                    | `kReleaseMode` gate                                    | —                                    |
| Shake / Alt+F12 / draggable FAB triggers     | all wired by `FFDevWrapper`                            | —                                    |

> **No vaporware section in this README.** Everything above is in the latest published version on pub.dev.

---

## ✨ Why FlutterForge AI?

| Old paradigm                    | FlutterForge AI                      |
| ------------------------------- | ------------------------------------ |
| `print()` → guess → retry       | Tap button → paste → get fix         |
| Hours of back-and-forth         | 30 seconds                           |
| Screenshot + vague prompt       | Structured JSON with real runtime   |
| "It works on my machine"        | "Here's exactly what happened"       |

### How it's different from Alice / Talker / pretty_dio_logger

| Capability                            | FlutterForge AI | Alice | Talker | pretty_dio_logger |
| ------------------------------------- | :-------------: | :---: | :----: | :---------------: |
| Dio interceptor + API inspector        | ✅              | ✅    | ✅     | ✅                |
| Colour-coded log viewer                | ✅              | —     | ✅     | —                 |
| Live SQLite console + raw SQL runner   | ✅              | —     | —      | —                 |
| Riverpod state viewer (live + history) | ✅              | —     | —      | —                 |
| **Unified 4-tab devtools dashboard**   | ✅              | —     | —      | —                 |
| **One-tap AI debug snapshot (JSON)**   | ✅              | —     | —      | —                 |
| Sensitive-data masking                 | ✅              | —     | —      | —                 |
| Release-mode auto-disable              | ✅              | —     | —      | —                 |

FlutterForge AI is *not* another logger — it's a **debugging surface** that unifies every runtime signal into a single export designed for AI assistants.

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
- 🧪 **Well tested** — 45 unit tests covering ring buffer, masker, logger, interceptor, snapshot, and prompt formatter.
- 🌍 **All platforms** — Android, iOS, macOS, Windows, Linux, Web.

---

## 📦 Installation

```bash
flutter pub add flutterforge_ai
```

Or in `pubspec.yaml`:

```yaml
dependencies:
  flutterforge_ai: ^0.1.1
```

> **Dependency type:** `dependencies` (not `dev_dependencies`). The runtime APIs (`FFLogger`, `FFApiClient`, `FFDbHelper`) are called from production code paths; the devtools UI silently no-ops in release builds.

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
      observers: [FFStateObserver()],  // 2. Track Riverpod state
      child: MaterialApp(
        // 3. Inject the devtools overlay inside MaterialApp.builder.
        builder: (ctx, child) => FFDevWrapper(child: child ?? const SizedBox()),
        home: const MyHomePage(),
      ),
    ),
  );
}
```

That's it. Tap the purple FAB for devtools, tap 🤖 for an AI snapshot.

---

## 🛠️ Usage

### Make API calls (auto-captured)

```dart
final dio = FFApiClient.instance.dio;
final resp = await dio.get('/users');
```

Every request appears live in the **API Inspector** tab with method, URL, status, duration, full request/response, and a ready-to-paste cURL command.

### Log anything (auto-captured)

```dart
FFLogger.info('User logged in');
FFLogger.error('Payment failed', error: e, stackTrace: st);
```

All entries show up in the **Log Viewer**, filterable by level (verbose → fatal).

### Query the database (auto-visible)

```dart
final db = FFDbHelper.instance.database;
await db.insert('users', {'name': 'Alice'});
```

Open the **Database Console** tab to browse tables, inspect schema, and run ad-hoc SQL.

### Generate an AI snapshot (one call)

```dart
// Preferred: top-level facade on FlutterForgeAI.
final snap   = await FlutterForgeAI.generateSnapshot(problem: 'Login loop');
final prompt = FFPromptFormatter.format(snap);
await FFClipboardHelper.copy(prompt);
// Snackbar: "✅ Prompt copied. Paste to your AI assistant."
```

`FlutterForgeAI.generateSnapshot(...)` forwards to `FFSnapshotGenerator.generate(...)` — both APIs are supported; use whichever reads better at the call site.

Or just tap the 🤖 FAB and use the built-in preview screen.

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

For a release-tuned preset:

```dart
FFConfig.production(appName: 'My App');  // All devtools off, even in debug.
```

---

## 📸 Screenshots

The `doc/images/` folder is the home for all recordings. Drop these four in to make the README self-explanatory:

| File                       | Shows                                           |
| -------------------------- | ----------------------------------------------- |
| `doc/images/hero.gif`      | Full workflow: bug → snapshot → AI fix (hero).  |
| `doc/images/dashboard.png` | 4-tab devtools dashboard.                       |
| `doc/images/api.png`       | API Inspector with cURL export.                 |
| `doc/images/snapshot.png`  | Snapshot preview + "Copy AI prompt" button.     |

See [doc/WORKFLOW.md](doc/WORKFLOW.md) for the step-by-step script.

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
│   │Log store│ │Schema + │ │API store│   │State store│       │
│   │(ring)   │ │SQL runr.│ │(ring)   │   │(ring)    │        │
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
2. Tap the green 🤖 FAB (or shake, or Alt+F12 → **AI Snapshot**).
3. Optionally type the symptom ("Login loop after OAuth").
4. Tap **Copy AI prompt**.
5. Paste into ChatGPT / Claude / Cursor / Cody.
6. Get a targeted, contextual fix.

Example auto-generated prompt:

```
I'm debugging a Flutter app. Here's the complete app context captured by
FlutterForge AI. Please analyse and suggest a fix.

PROBLEM: Login loop after OAuth

APP CONTEXT:
{
  "flutterforge_version": "0.1.1",
  "app":    { "name": "My App", "version": "1.2.3" },
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
Yes, it's imported, but every devtool, the shake detector, the floating buttons, and the snapshot generator are gated behind `!kReleaseMode`. In release, `FFDevWrapper` becomes a pass-through and `FFSnapshotGenerator.generate()` returns an empty snapshot.

**Does the AI see my raw auth tokens?**
No — everything goes through `FFSensitiveDataMasker`. `Authorization`, `Cookie`, `X-API-Key` headers, `password` / `token` / `secret` body keys, and `?token=` URL params are replaced with `***` before the call is even stored.

**Should this be a `dependency` or `dev_dependency`?**
Normal **`dependencies:`**. `FFLogger`, `FFApiClient`, and `FFDbHelper` are called from production code and must compile in release. Use `FFConfig.production(appName: …)` if you want every devtool silent.

**Is `sqflite_dev` required?**
No. It's an **optional** peer dependency. Add it to your `dev_dependencies` and the web workbench starts on port 8080 in debug; without it, the rest of the DB features still work.

**Can I use a different state manager?**
The package ships a Riverpod `ProviderObserver`. For Bloc / Provider / etc., just don't mount `FFStateObserver` — the DB / API / log surfaces stay useful.

**Does it work on web?**
Yes. Native-only features (`sqflite` workbench, shake detection) are skipped automatically; everything else works.

**How much memory does it use?**
Everything lives in fixed-size ring buffers you configure (`maxLogsStored`, `maxApiCallsStored`, …). Default footprint in debug is ~1 MB.

**Can I persist snapshots?**
Set `persistSnapshots: true` and the last snapshot is stored via `SharedPreferences`. Read it back with `FFSnapshotGenerator.lastPersistedJson()`.

**How do I contribute?**
See [.github/CONTRIBUTING.md](.github/CONTRIBUTING.md).

---

## 🗺️ Roadmap

**Shipped** (this repo):

- ✅ Flutter package (`flutterforge_ai`, on pub.dev)
- ✅ CLI (`flutterforge init` / `doctor` / `snapshot`) — see [`cli/`](cli/)
- 🟡 VS Code extension v0.2 — tree view + rich webview, see [`vscode/`](vscode/) (needs `npm install && npm run compile` to build locally)
- 🟡 Cloud receiver scaffold — see [`cloud/`](cloud/) (dev-only; no auth / persistence yet — parked post-v1)

**Up next (ordered by impact, not effort):**

1. 🔴 **One-tap "Diagnose with AI"** — in-app LLM call (bring-your-own-key: Anthropic / OpenAI). The snapshot round-trips to the model and the fix streams back into the preview screen. *This is the magic moment; the clipboard copy is the fallback.*
2. 🔴 **CLI `init --auto-wire`** — run `flutter pub get` and patch `main.dart` when it matches a known shape (counter template, generated project), so "zero config" actually means zero.
3. 🔴 **`doctor --fix`** — apply the fixes the doctor suggests.
4. 🟠 Inline "diff" view in the State Viewer + time-travel scrubber.
5. 🟠 GraphQL interceptor parity.
6. 🟠 Bloc / Provider observer adapters.
7. 🟠 Supabase / Firebase adapters.
8. 🟠 VS Code live mode — attach to a running Flutter app via DevTools Extensions, pull snapshots without picking a file.
9. ⚪ Cloud v1 — auth, Postgres, agent inside the Flutter package that POSTs snapshots on uncaught error.

---

## 📄 License

MIT © FlutterForge AI contributors — see [LICENSE](LICENSE).
