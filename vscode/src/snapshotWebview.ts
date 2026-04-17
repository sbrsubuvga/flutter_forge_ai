import { Snapshot } from './snapshotParser';

/** Renders a snapshot into a VS Code Webview HTML doc. No JS / external assets. */
export function renderSnapshotHtml(snapshot: Snapshot): string {
  const sections: Array<{ key: string; label: string; body: string; badge?: string }> = [
    { key: 'app',      label: '🛠️  App',         body: renderJson(snapshot.app) },
    { key: 'device',   label: '📱  Device',      body: renderJson(snapshot.device) },
    { key: 'database', label: '🗄️  Database',    body: renderDatabase(snapshot.database), badge: tableBadge(snapshot.database) },
    { key: 'api',      label: '🌐  API calls',   body: renderApi(snapshot.api_logs),       badge: summariseApi(snapshot.api_logs) },
    { key: 'state',    label: '🧠  App state',   body: renderState(snapshot.app_state),    badge: providersBadge(snapshot.app_state) },
    { key: 'logs',     label: '📝  Logs',        body: renderLogs(snapshot.logs),          badge: summariseLogs(snapshot.logs) },
  ];

  const problem = snapshot.problem
    ? `<div class="problem"><strong>Problem:</strong> ${esc(String(snapshot.problem))}</div>`
    : '';

  return `<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<meta http-equiv="Content-Security-Policy" content="default-src 'none'; style-src 'unsafe-inline';">
<title>FlutterForge AI — Snapshot</title>
<style>${styles()}</style>
</head>
<body>
  <h1>FlutterForge AI Snapshot</h1>
  <p class="meta">v${esc(snapshot.flutterforge_version)} · generated ${esc(snapshot.generated_at)}</p>
  ${problem}
  ${sections.map((s) => `
    <details ${s.key === 'api' || s.key === 'logs' ? 'open' : ''}>
      <summary>
        <span class="label">${s.label}</span>
        ${s.badge ? `<span class="badge">${esc(s.badge)}</span>` : ''}
      </summary>
      <div class="body">${s.body}</div>
    </details>
  `).join('')}
</body>
</html>`;
}

function renderJson(data: unknown): string {
  return `<pre>${esc(JSON.stringify(data, null, 2))}</pre>`;
}

function renderDatabase(db: Record<string, unknown>): string {
  const tables = toArray(db['tables']);
  if (tables.length === 0) return renderJson(db);
  const rows = tables.map((t) => {
    const o = t as Record<string, unknown>;
    const cols = toArray(o['columns']);
    return `<tr><td>${esc(String(o['name'] ?? ''))}</td><td>${esc(String(o['row_count'] ?? '?'))}</td><td>${cols.length}</td></tr>`;
  }).join('');
  return `<table class="rows"><thead><tr><th>Table</th><th>Rows</th><th>Cols</th></tr></thead><tbody>${rows}</tbody></table>
    <details><summary class="subtle">Raw JSON</summary>${renderJson(db)}</details>`;
}

function renderApi(api: Record<string, unknown>): string {
  const calls = toArray(api['recent_calls']);
  if (calls.length === 0) return `<p class="muted">No API calls captured.</p>${renderJson(api)}`;
  const rows = calls.map((c) => {
    const o = c as Record<string, unknown>;
    const status = o['status_code'];
    const cls = statusClass(typeof status === 'number' ? status : null);
    return `<tr class="${cls}">
      <td class="method">${esc(String(o['method'] ?? ''))}</td>
      <td class="url">${esc(truncate(String(o['url'] ?? ''), 70))}</td>
      <td>${esc(String(status ?? '—'))}</td>
      <td>${esc(String(o['duration_ms'] ?? '—'))}ms</td>
    </tr>`;
  }).join('');
  return `<table class="rows"><thead><tr><th>Method</th><th>URL</th><th>Status</th><th>Duration</th></tr></thead><tbody>${rows}</tbody></table>
    <details><summary class="subtle">Raw JSON</summary>${renderJson(api)}</details>`;
}

function renderState(state: Record<string, unknown>): string {
  const active = toArray(state['active_providers']);
  if (active.length === 0) return `<p class="muted">No active providers recorded.</p>${renderJson(state)}`;
  const rows = active.map((p) => {
    const o = p as Record<string, unknown>;
    return `<tr>
      <td>${esc(String(o['name'] ?? '?'))}</td>
      <td class="muted">${esc(String(o['type'] ?? ''))}</td>
      <td><code>${esc(truncate(String(o['current_value'] ?? ''), 80))}</code></td>
    </tr>`;
  }).join('');
  return `<table class="rows"><thead><tr><th>Provider</th><th>Type</th><th>Current value</th></tr></thead><tbody>${rows}</tbody></table>
    <details><summary class="subtle">Raw JSON</summary>${renderJson(state)}</details>`;
}

function renderLogs(logs: Record<string, unknown>): string {
  const entries = toArray(logs['recent_entries']);
  if (entries.length === 0) return `<p class="muted">No logs captured.</p>${renderJson(logs)}`;
  const rows = entries.slice(0, 80).map((l) => {
    const o = l as Record<string, unknown>;
    const level = String(o['level'] ?? 'info');
    return `<tr class="level-${esc(level)}">
      <td>${esc(String(o['timestamp'] ?? ''))}</td>
      <td class="level">${esc(level)}</td>
      <td>${esc(truncate(String(o['message'] ?? ''), 120))}</td>
    </tr>`;
  }).join('');
  return `<table class="rows"><thead><tr><th>Time</th><th>Level</th><th>Message</th></tr></thead><tbody>${rows}</tbody></table>
    <details><summary class="subtle">Raw JSON</summary>${renderJson(logs)}</details>`;
}

function summariseApi(api: Record<string, unknown>): string {
  const total = Number(api['total_count'] ?? 0);
  const failed = Number(api['failed_count'] ?? 0);
  if (total === 0) return 'none';
  return failed > 0 ? `${total}, ${failed} failed` : `${total}`;
}

function summariseLogs(logs: Record<string, unknown>): string {
  const total = Number(logs['total_count'] ?? 0);
  const errors = Number(logs['error_count'] ?? 0);
  const warnings = Number(logs['warning_count'] ?? 0);
  if (total === 0) return 'none';
  const parts: string[] = [`${total}`];
  if (errors > 0) parts.push(`${errors} err`);
  if (warnings > 0) parts.push(`${warnings} warn`);
  return parts.join(', ');
}

function tableBadge(db: Record<string, unknown>): string {
  const tables = toArray(db['tables']);
  return tables.length === 0 ? 'none' : `${tables.length} tables`;
}

function providersBadge(state: Record<string, unknown>): string {
  const active = toArray(state['active_providers']);
  return active.length === 0 ? 'none' : `${active.length} active`;
}

function toArray(value: unknown): unknown[] {
  return Array.isArray(value) ? value : [];
}

function truncate(s: string, max: number): string {
  return s.length <= max ? s : `${s.slice(0, max)}…`;
}

function statusClass(code: number | null): string {
  if (code == null) return 'pending';
  if (code >= 200 && code < 300) return 'ok-2xx';
  if (code >= 300 && code < 400) return 'ok-3xx';
  if (code >= 400 && code < 500) return 'err-4xx';
  return 'err-5xx';
}

function esc(input: string): string {
  return input
    .replace(/&/g, '&amp;')
    .replace(/</g, '&lt;')
    .replace(/>/g, '&gt;')
    .replace(/"/g, '&quot;');
}

function styles(): string {
  return `
    body { font-family: var(--vscode-font-family); padding: 16px 24px; color: var(--vscode-foreground); }
    h1 { margin: 0 0 2px; font-size: 18px; }
    p.meta { color: var(--vscode-descriptionForeground); font-size: 12px; margin: 0 0 12px; }
    .problem { background: var(--vscode-inputValidation-warningBackground, #fffbe6);
      border-left: 3px solid var(--vscode-inputValidation-warningBorder, #d29922);
      padding: 8px 12px; margin: 10px 0 16px; border-radius: 4px; }
    details { margin: 8px 0; border: 1px solid var(--vscode-panel-border, #3c3c3c);
      border-radius: 6px; background: var(--vscode-editor-background); }
    details > summary { list-style: none; cursor: pointer;
      padding: 10px 12px; display: flex; align-items: center; gap: 8px; }
    details > summary::-webkit-details-marker { display: none; }
    details > summary::before { content: '▸'; display: inline-block; transition: transform .15s; font-size: 11px; }
    details[open] > summary::before { transform: rotate(90deg); }
    summary .label { font-weight: 600; flex: 1; }
    summary .badge { font-size: 11px; color: var(--vscode-descriptionForeground);
      background: var(--vscode-badge-background); padding: 2px 8px; border-radius: 10px; }
    .body { padding: 0 12px 12px; }
    .subtle { color: var(--vscode-descriptionForeground); font-size: 12px; }
    pre { background: var(--vscode-textCodeBlock-background, rgba(127,127,127,0.1));
      padding: 10px; border-radius: 4px; overflow-x: auto; font-size: 12.5px; margin: 4px 0; }
    table.rows { width: 100%; border-collapse: collapse; font-size: 12.5px; }
    table.rows th { text-align: left; font-weight: 500; color: var(--vscode-descriptionForeground);
      border-bottom: 1px solid var(--vscode-panel-border); padding: 6px 8px; }
    table.rows td { padding: 4px 8px; border-bottom: 1px solid var(--vscode-panel-border); vertical-align: top; }
    table.rows td.method { font-family: var(--vscode-editor-font-family); font-weight: 600; }
    table.rows td.url { font-family: var(--vscode-editor-font-family); word-break: break-all; }
    tr.ok-2xx td { color: var(--vscode-charts-green, #16a34a); }
    tr.ok-3xx td { color: var(--vscode-charts-blue, #3b82f6); }
    tr.err-4xx td { color: var(--vscode-charts-orange, #f59e0b); }
    tr.err-5xx td { color: var(--vscode-charts-red, #ef4444); }
    tr.pending td { color: var(--vscode-descriptionForeground); }
    tr.level-error td, tr.level-fatal td { color: var(--vscode-charts-red, #ef4444); }
    tr.level-warning td { color: var(--vscode-charts-orange, #f59e0b); }
    td.level { text-transform: uppercase; font-size: 10px; font-weight: 700; letter-spacing: 0.06em; }
    .muted { color: var(--vscode-descriptionForeground); font-size: 12.5px; }
  `;
}
