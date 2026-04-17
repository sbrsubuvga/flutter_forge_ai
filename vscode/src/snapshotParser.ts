/** Typed shape of a FlutterForge AI Debug Snapshot. */
export interface Snapshot {
  flutterforge_version: string;
  generated_at: string;
  problem?: string | null;
  app: Record<string, unknown>;
  device: Record<string, unknown>;
  database: Record<string, unknown>;
  api_logs: Record<string, unknown>;
  app_state: Record<string, unknown>;
  logs: Record<string, unknown>;
}

/** Parses raw JSON text into a Snapshot, validating the minimum shape. */
export function parseSnapshot(raw: string): Snapshot {
  let parsed: unknown;
  try {
    parsed = JSON.parse(raw);
  } catch (err) {
    throw new Error(`Invalid JSON: ${(err as Error).message}`);
  }
  if (typeof parsed !== 'object' || parsed === null) {
    throw new Error('Snapshot must be a JSON object');
  }
  const o = parsed as Record<string, unknown>;
  for (const key of [
    'flutterforge_version',
    'generated_at',
    'app',
    'device',
    'database',
    'api_logs',
    'app_state',
    'logs',
  ]) {
    if (!(key in o)) {
      throw new Error(`Missing required key: ${key}`);
    }
  }
  return o as unknown as Snapshot;
}

/** Builds an AI-ready prompt wrapping the snapshot JSON. */
export function buildAiPrompt(snapshot: Snapshot, problemOverride?: string): string {
  const problem =
    problemOverride?.trim() ||
    (typeof snapshot.problem === 'string' ? snapshot.problem : '') ||
    '(not specified — please infer from context below)';

  return [
    "I'm debugging a Flutter app. Here's the complete app context captured by",
    'FlutterForge AI. Please analyse and suggest a fix.',
    '',
    `PROBLEM: ${problem}`,
    '',
    'APP CONTEXT:',
    '```json',
    JSON.stringify(snapshot, null, 2),
    '```',
    '',
    'Please:',
    '1. Identify the root cause.',
    '2. Suggest specific code fixes (include file paths if visible).',
    '3. Point to the exact provider / API call / DB query that is failing.',
    '',
  ].join('\n');
}
