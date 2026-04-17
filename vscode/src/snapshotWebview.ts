import { Snapshot } from './snapshotParser';

/** Minimal HTML renderer for the Webview panel. No external assets / JS. */
export function renderSnapshotHtml(snapshot: Snapshot): string {
  const esc = (v: unknown) => escapeHtml(JSON.stringify(v, null, 2));
  const sections: Array<[string, unknown]> = [
    ['App', snapshot.app],
    ['Device', snapshot.device],
    ['Database', snapshot.database],
    ['API logs', snapshot.api_logs],
    ['App state', snapshot.app_state],
    ['Logs', snapshot.logs],
  ];

  return `<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<title>FlutterForge AI — Snapshot</title>
<style>
  body { font-family: var(--vscode-font-family); padding: 16px; color: var(--vscode-foreground); }
  h1 { margin: 0 0 4px; font-size: 18px; }
  h2 { margin: 20px 0 6px; font-size: 14px; text-transform: uppercase; letter-spacing: .04em; color: var(--vscode-descriptionForeground); }
  pre { background: var(--vscode-textCodeBlock-background); padding: 10px; border-radius: 6px; overflow-x: auto; font-size: 12.5px; }
  .meta { font-size: 12px; color: var(--vscode-descriptionForeground); margin-bottom: 12px; }
  .problem { background: var(--vscode-editorWarning-background, #fffbe6); padding: 8px 12px; border-left: 3px solid var(--vscode-editorWarning-foreground, #d29922); border-radius: 4px; margin: 8px 0 16px; }
</style>
</head>
<body>
  <h1>FlutterForge AI — Snapshot</h1>
  <div class="meta">
    v${escapeHtml(snapshot.flutterforge_version)}
    · generated ${escapeHtml(snapshot.generated_at)}
  </div>
  ${
    snapshot.problem
      ? `<div class="problem"><strong>Problem:</strong> ${escapeHtml(
          String(snapshot.problem),
        )}</div>`
      : ''
  }
  ${sections
    .map(
      ([title, data]) => `
    <h2>${escapeHtml(title)}</h2>
    <pre>${esc(data)}</pre>
  `,
    )
    .join('')}
</body>
</html>`;
}

function escapeHtml(input: string): string {
  return input
    .replace(/&/g, '&amp;')
    .replace(/</g, '&lt;')
    .replace(/>/g, '&gt;');
}
