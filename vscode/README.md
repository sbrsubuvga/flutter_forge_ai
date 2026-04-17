# FlutterForge AI — VS Code Extension

> **v0.1 scaffold.** Opens and explores AI Debug Snapshots produced by the [`flutterforge_ai`](https://pub.dev/packages/flutterforge_ai) Flutter package.

## Status

This is a **scaffold**, not a polished extension. What works today:

- ✅ `FlutterForge: Open AI Debug Snapshot…` — pick a JSON file, render a structured webview (app / device / DB / API / state / logs sections).
- ✅ `FlutterForge: Copy AI Prompt from Snapshot…` — same picker, then an AI-ready prompt is copied to your clipboard.
- ✅ Validates the snapshot's minimum shape before rendering.

## Roadmap (not yet implemented)

- 🔴 Live mode — read snapshots straight from a running Flutter app via the DevTools Extensions API or a local WebSocket bridge.
- 🔴 Inline code suggestions — use the VS Code chat participant API to push the prompt into Copilot Chat.
- 🔴 Tree view in the Activity Bar showing recent snapshots.
- 🔴 Deep-link from a snapshot row to the relevant Dart source.

## Develop locally

```bash
cd vscode
npm install
npm run compile
# Press F5 in VS Code to launch the Extension Host.
```

From the Extension Host window:

1. Run **FlutterForge: Open AI Debug Snapshot…** from the command palette.
2. Pick a `.json` file previously saved by `FFSnapshotGenerator.saveToFile(...)`.
3. The webview renders structured sections.

## Package & publish

```bash
npm install -g @vscode/vsce
vsce login sbrsubuvga     # personal access token
npm run compile
vsce package              # produces flutterforge-ai-0.1.0.vsix
vsce publish
```

## License

MIT
