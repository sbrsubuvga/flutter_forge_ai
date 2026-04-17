import { notFound } from 'next/navigation';
import Link from 'next/link';

interface StoredSnapshot {
  id: string;
  receivedAt: string;
  snapshot: Record<string, unknown>;
}

async function fetchSnapshot(id: string): Promise<StoredSnapshot | null> {
  const api = process.env.NEXT_PUBLIC_API_URL ?? 'http://localhost:4000';
  try {
    const r = await fetch(`${api}/snapshots/${id}`, { cache: 'no-store' });
    if (!r.ok) return null;
    return (await r.json()) as StoredSnapshot;
  } catch {
    return null;
  }
}

export default async function SnapshotDetail({
  params,
}: {
  params: { id: string };
}) {
  const data = await fetchSnapshot(params.id);
  if (!data) notFound();

  return (
    <>
      <p>
        <Link href="/">← all snapshots</Link>
      </p>
      <h1 style={{ fontSize: 20 }}>Snapshot {data.id}</h1>
      <p style={{ color: 'var(--muted)', fontSize: 13 }}>
        Received {new Date(data.receivedAt).toLocaleString()}
      </p>
      <pre>{JSON.stringify(data.snapshot, null, 2)}</pre>
    </>
  );
}
