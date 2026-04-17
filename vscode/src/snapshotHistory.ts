import * as vscode from 'vscode';
import * as path from 'path';

/** One entry persisted in workspace state for the history tree. */
export interface HistoryEntry {
  readonly uri: string;
  readonly label: string;
  readonly appName?: string;
  readonly platform?: string;
  readonly generatedAt?: string;
  readonly problem?: string | null;
  readonly openedAt: number;
}

const STATE_KEY = 'flutterforge.history';
const MAX_ENTRIES = 50;

/** Loads / persists the list of recently opened snapshots. */
export class SnapshotHistory {
  constructor(private readonly memento: vscode.Memento) {}

  getAll(): HistoryEntry[] {
    return this.memento.get<HistoryEntry[]>(STATE_KEY, []);
  }

  async record(partial: Omit<HistoryEntry, 'openedAt' | 'label'>): Promise<void> {
    const existing = this.getAll().filter((e) => e.uri !== partial.uri);
    const entry: HistoryEntry = {
      ...partial,
      label: path.basename(partial.uri),
      openedAt: Date.now(),
    };
    const next = [entry, ...existing].slice(0, MAX_ENTRIES);
    await this.memento.update(STATE_KEY, next);
  }

  async remove(uri: string): Promise<void> {
    const next = this.getAll().filter((e) => e.uri !== uri);
    await this.memento.update(STATE_KEY, next);
  }

  async clear(): Promise<void> {
    await this.memento.update(STATE_KEY, []);
  }
}
