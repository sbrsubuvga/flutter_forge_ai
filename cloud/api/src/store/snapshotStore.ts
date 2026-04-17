/** Persistence interface — swap in Postgres / Redis / DynamoDB later. */
export interface SnapshotStore {
  put(snapshot: Record<string, unknown>): Promise<string>;
  get(id: string): Promise<StoredSnapshot | undefined>;
  list(opts: { limit: number; offset: number }): Promise<StoredSnapshot[]>;
}

export interface StoredSnapshot {
  id: string;
  receivedAt: string;
  snapshot: Record<string, unknown>;
}
