import { Router } from 'express';
import { z } from 'zod';
import { SnapshotStore } from '../store/snapshotStore';

const SnapshotBodySchema = z
  .object({
    flutterforge_version: z.string(),
    generated_at: z.string(),
    app: z.record(z.unknown()),
    device: z.record(z.unknown()),
    database: z.record(z.unknown()),
    api_logs: z.record(z.unknown()),
    app_state: z.record(z.unknown()),
    logs: z.record(z.unknown()),
    problem: z.string().nullish(),
  })
  .passthrough();

export function buildSnapshotsRouter(store: SnapshotStore): Router {
  const r = Router();

  r.post('/', async (req, res) => {
    const parsed = SnapshotBodySchema.safeParse(req.body);
    if (!parsed.success) {
      res.status(400).json({
        error: 'invalid_snapshot',
        details: parsed.error.flatten(),
      });
      return;
    }
    const id = await store.put(parsed.data);
    res.status(201).json({ id });
  });

  r.get('/', async (req, res) => {
    const limit = Math.min(Number(req.query.limit ?? 50), 200);
    const offset = Math.max(Number(req.query.offset ?? 0), 0);
    const items = await store.list({ limit, offset });
    res.json({ items, limit, offset });
  });

  r.get('/:id', async (req, res) => {
    const snap = await store.get(req.params.id);
    if (!snap) {
      res.status(404).json({ error: 'not_found' });
      return;
    }
    res.json(snap);
  });

  return r;
}
