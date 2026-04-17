import express, { NextFunction, Request, Response } from 'express';
import { buildSnapshotsRouter } from './routes/snapshots';
import { MemoryStore } from './store/memoryStore';

export function createApp(): express.Express {
  const app = express();
  app.use(express.json({ limit: '5mb' }));

  const store = new MemoryStore();
  app.use('/snapshots', buildSnapshotsRouter(store));

  app.get('/healthz', (_req, res) => {
    res.json({ ok: true, time: new Date().toISOString() });
  });

  app.use((err: Error, _req: Request, res: Response, _next: NextFunction) => {
    // eslint-disable-next-line no-console
    console.error(err);
    res.status(500).json({ error: err.message });
  });

  return app;
}

if (require.main === module) {
  const port = Number(process.env.PORT ?? 4000);
  createApp().listen(port, () => {
    // eslint-disable-next-line no-console
    console.log(`[flutterforge-cloud-api] listening on :${port}`);
  });
}
