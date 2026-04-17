# Architecture

This document walks through FlutterForge AI's internals for contributors and
curious users.

## Top-level layout

```
lib/
├── flutterforge_ai.dart          # public barrel
└── src/
    ├── flutterforge_core.dart    # FlutterForgeAI.init() / singleton
    ├── config/                   # FFConfig + env loader
    ├── core/
    │   ├── db/                   # sqflite + schema reader + query runner
    │   ├── network/              # Dio client + interceptor + store
    │   ├── logger/               # FFLogger + log store
    │   └── state/                # Riverpod observer + state store
    ├── snapshot/                 # AI snapshot generator
    ├── devtools/
    │   ├── ff_dev_wrapper.dart
    │   ├── ff_dev_dashboard.dart
    │   ├── ff_shake_detector.dart
    │   ├── ff_keyboard_shortcut.dart
    │   ├── screens/              # 4 tabs + detail + snapshot preview
    │   └── widgets/              # chips, search bar, JSON viewer, bubble
    └── utils/                    # ring buffer, masker, platform, printer
```

## Initialisation sequence

```
FlutterForgeAI.init(config)
  │
  ├─▶ FFEnvironment.load(config.envFile)
  ├─▶ new FFLogStore(maxSize) → FFLogger.init()
  ├─▶ new FFStateStore(maxSize) → ffStateObserverRegisterStore()
  ├─▶ FFDbHelper.init(config)      (best-effort; logs a warning on failure)
  │     └─▶ FFDbDebugEnabler.enable() (optional sqflite_dev workbench)
  ├─▶ FFApiClient.init(config)
  │     └─▶ Dio + [FFApiInterceptor, PrettyDioLogger?, ...userInterceptors]
  ├─▶ FlutterError.onError     → FFLogger.error
  └─▶ PlatformDispatcher.onError → FFLogger.error
```

## Ring buffers

Every time-series captured by the package (logs, API calls, state changes)
lives in a `FFRingBuffer<T>` — a fixed-capacity queue with:

- O(1) amortised insert
- oldest-first snapshot via `items`
- newest-first snapshot via `reversed`
- broadcast `stream` for live UI
- broadcast `clearStream` so UI can also react to wipes

Why fixed size? Long-running sessions would otherwise blow memory. Every
buffer's capacity is controlled by `FFConfig`.

## Sensitive data flow

```
Incoming request
   │
   ▼
FFApiInterceptor.onRequest
   │      masker.maskHeaders(opts.headers)
   │      masker.maskBody(opts.data)
   │      masker.maskUrl(opts.uri)
   │      FFCurlExporter(masker).fromRequest(opts)
   ▼
FFApiCall (stored, already masked)
```

The raw (un-masked) Dio request still goes over the wire untouched — the
masker only rewrites what the devtools layer *stores*. Same principle applies
to responses via `onResponse`.

## Riverpod observer

`FFStateObserver` overrides the four hooks on `ProviderObserver`:

| Hook                  | FFStateChangeType |
| --------------------- | ----------------- |
| `didAddProvider`      | `added`           |
| `didUpdateProvider`   | `updated`         |
| `didDisposeProvider`  | `disposed`        |
| `providerDidFail`     | `failed`          |

Values are stringified (`toString()`) and truncated to
`config.maxStateValueLength`. A prefix filter
(`config.stateTrackingPrefixes`) lets you ignore framework/package-internal
providers.

The store resolves the active `FFStateStore` lazily via
`ffStateObserverRegisterStore`, so a `ProviderScope(observers: [FFStateObserver()])`
declared *before* `FlutterForgeAI.init()` still works.

## Snapshot shape

See `FFSnapshot.toJson()` — the top-level keys are:

- `flutterforge_version`
- `generated_at`
- `problem`
- `app` — name / version / buildNumber / packageName
- `device` — platform / osVersion / model / manufacturer / isPhysical
- `database` — tables, schema, row counts, first 10 rows per table
- `api_logs` — totals + 25 most recent masked calls (method/url/status/duration)
- `app_state` — active providers + last 40 state changes
- `logs` — totals + 60 most recent log entries

## Release safety

```dart
bool get shouldShowDevTools => isDebug && enableDevTools;
bool get isDebug => !kReleaseMode;
```

Every UI entrypoint (`FFDevWrapper`, `FFDevDashboard`, `FFAiDebugButton`)
checks `FlutterForgeAI.showDevTools` or `config.shouldShowDevTools`. Even
when the user forgets to remove `FFDevWrapper`, the widget reduces to
`return child` in release builds.

`FFSnapshotGenerator.generate()` short-circuits to `FFSnapshot.empty()` in
release to prevent accidental data leakage.

## Extending

- Adding a new tab: create a screen under `devtools/screens/`, append it to
  the `TabBarView` in `FFDevDashboard`, and register it in the barrel.
- Adding a capture source: implement a `FFRingBuffer`-backed store, create a
  listener/interceptor hook, and slot it into `FFSnapshotGenerator._collectX()`.
- Adding an additional cURL or export format: subclass `FFCurlExporter` or
  follow the same pattern (`fromParts(...)`).
