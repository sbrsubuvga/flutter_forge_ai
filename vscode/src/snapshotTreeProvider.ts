import * as vscode from 'vscode';
import { HistoryEntry, SnapshotHistory } from './snapshotHistory';

/** TreeDataProvider backing the FlutterForge Activity Bar panel. */
export class SnapshotTreeProvider
  implements vscode.TreeDataProvider<HistoryEntry>
{
  private readonly _onDidChangeTreeData =
    new vscode.EventEmitter<HistoryEntry | undefined | void>();
  readonly onDidChangeTreeData = this._onDidChangeTreeData.event;

  constructor(private readonly history: SnapshotHistory) {}

  refresh(): void {
    this._onDidChangeTreeData.fire();
  }

  getTreeItem(element: HistoryEntry): vscode.TreeItem {
    const item = new vscode.TreeItem(
      element.label,
      vscode.TreeItemCollapsibleState.None,
    );
    item.description = describe(element);
    item.tooltip = tooltip(element);
    item.id = element.uri;
    item.resourceUri = vscode.Uri.file(element.uri);
    item.iconPath = new vscode.ThemeIcon('file-code');
    item.contextValue = 'flutterforge.snapshot';
    item.command = {
      command: 'flutterforge.openSnapshotFromHistory',
      title: 'Open snapshot',
      arguments: [element],
    };
    return item;
  }

  getChildren(element?: HistoryEntry): vscode.ProviderResult<HistoryEntry[]> {
    if (element !== undefined) return [];
    return this.history.getAll().sort((a, b) => b.openedAt - a.openedAt);
  }
}

function describe(e: HistoryEntry): string {
  const parts: string[] = [];
  if (e.appName) parts.push(e.appName);
  if (e.platform) parts.push(e.platform);
  if (e.problem) parts.push(`"${e.problem.slice(0, 40)}"`);
  return parts.join(' · ');
}

function tooltip(e: HistoryEntry): vscode.MarkdownString {
  const md = new vscode.MarkdownString();
  md.appendMarkdown(`**${e.label}**\n\n`);
  md.appendMarkdown(`Path: \`${e.uri}\`\n\n`);
  if (e.appName) md.appendMarkdown(`App: ${e.appName}\n\n`);
  if (e.platform) md.appendMarkdown(`Platform: ${e.platform}\n\n`);
  if (e.generatedAt) md.appendMarkdown(`Generated: ${e.generatedAt}\n\n`);
  if (e.problem) md.appendMarkdown(`Problem: ${e.problem}\n\n`);
  return md;
}
