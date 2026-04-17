import { randomUUID } from 'crypto';
import { SnapshotStore, StoredSnapshot } from './snapshotStore';

/**
 * Process-local, non-durable store. Dev and tests only.
 * Replace with a Postgres adapter before any real deployment.
 */
export class MemoryStore implements SnapshotStore {
  private readonly items = new Map<string, StoredSnapshot>();

  async put(snapshot: Record<string, unknown>): Promise<string> {
    const id = randomUUID();
    this.items.set(id, {
      id,
      receivedAt: new Date().toISOString(),
      snapshot,
    });
    return id;
  }

  async get(id: string): Promise<StoredSnapshot | undefined> {
    return this.items.get(id);
  }

  async list(opts: { limit: number; offset: number }): Promise<StoredSnapshot[]> {
    return [...this.items.values()]
      .sort((a, b) => b.receivedAt.localeCompare(a.receivedAt))
      .slice(opts.offset, opts.offset + opts.limit);
  }
}
