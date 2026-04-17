import * as vscode from 'vscode';
import { SnapshotHistory } from './snapshotHistory';

/** Persistent status-bar entry showing history size; click opens the picker. */
export class FlutterForgeStatusBar {
  private readonly item: vscode.StatusBarItem;

  constructor(private readonly history: SnapshotHistory) {
    this.item = vscode.window.createStatusBarItem(
      vscode.StatusBarAlignment.Right,
      100,
    );
    this.item.command = 'flutterforge.openSnapshot';
    this.item.tooltip = 'FlutterForge — open snapshot';
    this.item.show();
    this.refresh();
  }

  refresh(): void {
    const count = this.history.getAll().length;
    this.item.text =
      count === 0
        ? '$(debug-console) FlutterForge'
        : `$(debug-console) FlutterForge (${count})`;
  }

  dispose(): void {
    this.item.dispose();
  }
}
