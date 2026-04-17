import '../snapshot/ff_snapshot_model.dart';

/// Builds the system + user prompts sent to the LLM for in-app diagnosis.
///
/// Kept deliberately small and opinionated: one system prompt that frames the
/// model as a Flutter debugging assistant, one user prompt that embeds the
/// snapshot JSON and the problem description.
class FFAiPrompt {
  FFAiPrompt._();

  /// The system message — constant across snapshots.
  static const String systemPrompt = '''
You are a senior Flutter debugging assistant. The developer will paste a
FlutterForge AI runtime snapshot (structured JSON with DB rows, API calls,
Riverpod state, and recent logs). Your job:

1. Identify the root cause of the reported problem.
2. Suggest concrete code fixes (name files, providers, API endpoints).
3. Flag anomalies in logs, state changes, or API responses.
4. Keep the answer terse: bullet points + short code blocks. No fluff.

If the snapshot is empty or the problem is ambiguous, ask exactly one
clarifying question instead of guessing.
''';

  /// Builds the user message for [snapshot] + [problem].
  static String user({
    required FFSnapshot snapshot,
    required String problem,
  }) {
    final String effectiveProblem = problem.trim().isEmpty
        ? (snapshot.problem?.trim().isNotEmpty == true
            ? snapshot.problem!.trim()
            : '(not specified — please infer from the snapshot)')
        : problem.trim();
    return '''PROBLEM: $effectiveProblem

APP CONTEXT:
```json
${snapshot.toPrettyJson()}
```
''';
  }
}
