import * as vscode from 'vscode';
import { HistoryEntry, SnapshotHistory } from './snapshotHistory';
import { SnapshotTreeProvider } from './snapshotTreeProvider';
import { FlutterForgeStatusBar } from './statusBar';
import { buildAiPrompt, parseSnapshot } from './snapshotParser';
import { renderSnapshotHtml } from './snapshotWebview';
import { runCliInTerminal } from './runCli';

export function activate(context: vscode.ExtensionContext): void {
  const history = new SnapshotHistory(context.workspaceState);
  const tree = new SnapshotTreeProvider(history);
  const statusBar = new FlutterForgeStatusBar(history);

  context.subscriptions.push(
    vscode.window.registerTreeDataProvider('flutterforgeExplorer', tree),
    statusBar,
    vscode.commands.registerCommand(
      'flutterforge.openSnapshot',
      () => openSnapshotCommand(history, tree, statusBar),
    ),
    vscode.commands.registerCommand(
      'flutterforge.copyAiPrompt',
      () => copyPromptCommand(),
    ),
    vscode.commands.registerCommand(
      'flutterforge.openSnapshotFromHistory',
      (entry: HistoryEntry) => openFromHistory(entry, history, tree, statusBar),
    ),
    vscode.commands.registerCommand(
      'flutterforge.removeSnapshotFromHistory',
      async (entry: HistoryEntry) => {
        await history.remove(entry.uri);
        tree.refresh();
        statusBar.refresh();
      },
    ),
    vscode.commands.registerCommand(
      'flutterforge.clearHistory',
      async () => {
        const choice = await vscode.window.showWarningMessage(
          'Clear FlutterForge snapshot history?',
          { modal: true },
          'Clear',
        );
        if (choice === 'Clear') {
          await history.clear();
          tree.refresh();
          statusBar.refresh();
        }
      },
    ),
    vscode.commands.registerCommand(
      'flutterforge.runDoctor',
      () => runCliInTerminal(['doctor']),
    ),
    vscode.commands.registerCommand(
      'flutterforge.runInit',
      () => runCliInTerminal(['init']),
    ),
    vscode.commands.registerCommand(
      'flutterforge.refreshHistory',
      () => {
        tree.refresh();
        statusBar.refresh();
      },
    ),
  );
}

export function deactivate(): void {
  // noop
}

async function openSnapshotCommand(
  history: SnapshotHistory,
  tree: SnapshotTreeProvider,
  statusBar: FlutterForgeStatusBar,
): Promise<void> {
  const file = await pickSnapshotFile();
  if (!file) return;
  await openAndRecord(file, history, tree, statusBar);
}

async function openFromHistory(
  entry: HistoryEntry,
  history: SnapshotHistory,
  tree: SnapshotTreeProvider,
  statusBar: FlutterForgeStatusBar,
): Promise<void> {
  const uri = vscode.Uri.file(entry.uri);
  try {
    await vscode.workspace.fs.stat(uri);
  } catch {
    const choice = await vscode.window.showWarningMessage(
      `Snapshot no longer exists: ${entry.label}. Remove from history?`,
      'Remove',
      'Cancel',
    );
    if (choice === 'Remove') {
      await history.remove(entry.uri);
      tree.refresh();
      statusBar.refresh();
    }
    return;
  }
  await openAndRecord(uri, history, tree, statusBar);
}

async function openAndRecord(
  file: vscode.Uri,
  history: SnapshotHistory,
  tree: SnapshotTreeProvider,
  statusBar: FlutterForgeStatusBar,
): Promise<void> {
  const raw = (await vscode.workspace.fs.readFile(file)).toString();
  let snapshot;
  try {
    snapshot = parseSnapshot(raw);
  } catch (err) {
    vscode.window.showErrorMessage(
      `Not a valid FlutterForge snapshot: ${(err as Error).message}`,
    );
    return;
  }

  const panel = vscode.window.createWebviewPanel(
    'flutterforgeSnapshot',
    `FlutterForge · ${asString(snapshot.app?.name) ?? file.path.split('/').pop()}`,
    vscode.ViewColumn.One,
    { enableScripts: false, retainContextWhenHidden: true },
  );
  panel.webview.html = renderSnapshotHtml(snapshot);

  await history.record({
    uri: file.fsPath,
    appName: asString(snapshot.app?.name),
    platform: asString(snapshot.device?.platform),
    generatedAt: snapshot.generated_at,
    problem: snapshot.problem ?? null,
  });
  tree.refresh();
  statusBar.refresh();
}

async function copyPromptCommand(): Promise<void> {
  const file = await pickSnapshotFile();
  if (!file) return;
  const raw = (await vscode.workspace.fs.readFile(file)).toString();
  try {
    const snapshot = parseSnapshot(raw);
    const prompt = buildAiPrompt(snapshot);
    await vscode.env.clipboard.writeText(prompt);
    vscode.window.showInformationMessage(
      '✓ AI prompt copied. Paste into your assistant.',
    );
  } catch (err) {
    vscode.window.showErrorMessage(
      `Could not build prompt: ${(err as Error).message}`,
    );
  }
}

async function pickSnapshotFile(): Promise<vscode.Uri | undefined> {
  const configured = vscode.workspace
    .getConfiguration('flutterforge')
    .get<string>('defaultSnapshotDirectory');
  const defaultUri =
    configured && configured.length > 0
      ? vscode.Uri.file(configured)
      : undefined;

  const picked = await vscode.window.showOpenDialog({
    canSelectMany: false,
    filters: { JSON: ['json'] },
    openLabel: 'Open snapshot',
    defaultUri,
  });
  return picked?.[0];
}

function asString(value: unknown): string | undefined {
  return typeof value === 'string' ? value : undefined;
}
