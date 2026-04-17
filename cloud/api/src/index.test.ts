import { describe, expect, it } from 'vitest';
import { createApp } from './index';

async function call(
  path: string,
  init: RequestInit = {},
): Promise<{ status: number; body: unknown }> {
  // Minimal integration helper without supertest — the app is an Express
  // fetch-compatible handler via node's built-in http module.
  const app = createApp();
  return new Promise((resolve, reject) => {
    const server = app.listen(0, () => {
      const addr = server.address();
      if (!addr || typeof addr === 'string') {
        reject(new Error('no address'));
        return;
      }
      fetch(`http://127.0.0.1:${addr.port}${path}`, init)
        .then(async (r) => ({
          status: r.status,
          body: await r.json().catch(() => ({})),
        }))
        .then((v) => {
          server.close();
          resolve(v);
        })
        .catch((e) => {
          server.close();
          reject(e);
        });
    });
  });
}

const validSnapshot = {
  flutterforge_version: '0.1.1',
  generated_at: new Date().toISOString(),
  app: { name: 'Demo' },
  device: { platform: 'android' },
  database: {},
  api_logs: { total_count: 0, failed_count: 0 },
  app_state: {},
  logs: { total_count: 0, error_count: 0, warning_count: 0 },
};

describe('FlutterForge Cloud API', () => {
  it('GET /healthz returns ok', async () => {
    const r = await call('/healthz');
    expect(r.status).toBe(200);
    expect((r.body as { ok: boolean }).ok).toBe(true);
  });

  it('POST /snapshots accepts a valid snapshot', async () => {
    const r = await call('/snapshots', {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify(validSnapshot),
    });
    expect(r.status).toBe(201);
    expect(typeof (r.body as { id: string }).id).toBe('string');
  });

  it('POST /snapshots rejects invalid payload', async () => {
    const r = await call('/snapshots', {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ only: 'garbage' }),
    });
    expect(r.status).toBe(400);
  });
});
