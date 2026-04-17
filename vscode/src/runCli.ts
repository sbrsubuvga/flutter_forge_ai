import * as vscode from 'vscode';

/**
 * Shells out to the companion `flutterforge` CLI in a VS Code Terminal so
 * the user sees output and can re-run / copy exactly as in any shell.
 * The CLI must already be on PATH (`dart pub global activate flutterforge_ai_cli`).
 */
export async function runCliInTerminal(
  cmd: string[],
  opts: { cwd?: string; name?: string } = {},
): Promise<void> {
  const term = vscode.window.createTerminal({
    name: opts.name ?? 'FlutterForge',
    cwd: opts.cwd ?? resolveCwd(),
  });
  term.show();
  term.sendText(['flutterforge', ...cmd].join(' '));
}

function resolveCwd(): string | undefined {
  const folders = vscode.workspace.workspaceFolders;
  return folders && folders.length > 0 ? folders[0].uri.fsPath : undefined;
}
