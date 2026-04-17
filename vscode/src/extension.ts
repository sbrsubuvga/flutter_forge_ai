import * as vscode from 'vscode';
import { buildAiPrompt, parseSnapshot } from './snapshotParser';
import { renderSnapshotHtml } from './snapshotWebview';

/** Called on activation. Registers every contributed command. */
export function activate(context: vscode.ExtensionContext): void {
  context.subscriptions.push(
    vscode.commands.registerCommand(
      'flutterforge.openSnapshot',
      () => openSnapshotCommand(context),
    ),
    vscode.commands.registerCommand(
      'flutterforge.copyAiPrompt',
      () => copyPromptCommand(),
    ),
  );
}

/** Deactivation is a no-op — VS Code disposes registered subscriptions. */
export function deactivate(): void {
  // noop
}

async function openSnapshotCommand(
  context: vscode.ExtensionContext,
): Promise<void> {
  const file = await pickSnapshotFile();
  if (!file) return;

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
    `FlutterForge · ${snapshot.app?.name ?? file.path.split('/').pop()}`,
    vscode.ViewColumn.One,
    { enableScripts: false, retainContextWhenHidden: true },
  );
  panel.webview.html = renderSnapshotHtml(snapshot);
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
  const defaultUri = configured ? vscode.Uri.file(configured) : undefined;

  const picked = await vscode.window.showOpenDialog({
    canSelectMany: false,
    filters: { JSON: ['json'] },
    openLabel: 'Open snapshot',
    defaultUri,
  });
  return picked?.[0];
}
