import Link from 'next/link';

interface StoredSnapshot {
  id: string;
  receivedAt: string;
  snapshot: {
    app?: { name?: string; version?: string };
    device?: { platform?: string };
    problem?: string | null;
  };
}

async function fetchSnapshots(): Promise<StoredSnapshot[]> {
  const api = process.env.NEXT_PUBLIC_API_URL ?? 'http://localhost:4000';
  try {
    const r = await fetch(`${api}/snapshots?limit=50`, {
      cache: 'no-store',
    });
    if (!r.ok) return [];
    const body = (await r.json()) as { items: StoredSnapshot[] };
    return body.items;
  } catch {
    return [];
  }
}

export default async function Home() {
  const items = await fetchSnapshots();
  return (
    <>
      <h1 style={{ fontSize: 22, marginBottom: 4 }}>Recent snapshots</h1>
      <p style={{ color: 'var(--muted)', marginTop: 0 }}>
        POST to <code>/snapshots</code> to add. Empty? Try{' '}
        <code>curl -X POST …</code> — see the{' '}
        <a href="https://github.com/sbrsubuvga/flutter_forge_ai/tree/main/cloud">
          cloud/README.md
        </a>
        .
      </p>
      {items.length === 0 ? (
        <p>No snapshots yet.</p>
      ) : (
        <table>
          <thead>
            <tr>
              <th>Received</th>
              <th>App</th>
              <th>Platform</th>
              <th>Problem</th>
              <th>Snapshot</th>
            </tr>
          </thead>
          <tbody>
            {items.map((s) => (
              <tr key={s.id}>
                <td>{new Date(s.receivedAt).toLocaleString()}</td>
                <td>
                  {s.snapshot.app?.name ?? '—'}{' '}
                  <span style={{ color: 'var(--muted)' }}>
                    {s.snapshot.app?.version ? `v${s.snapshot.app.version}` : ''}
                  </span>
                </td>
                <td>{s.snapshot.device?.platform ?? '—'}</td>
                <td style={{ maxWidth: 360 }}>{s.snapshot.problem ?? '—'}</td>
                <td>
                  <Link href={`/snapshots/${s.id}`}>open →</Link>
                </td>
              </tr>
            ))}
          </tbody>
        </table>
      )}
    </>
  );
}
