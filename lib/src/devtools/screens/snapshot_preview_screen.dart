import 'package:flutter/material.dart';

import '../../ai/ff_ai_config.dart';
import '../../ai/ff_ai_settings_store.dart';
import '../../snapshot/ff_prompt_formatter.dart';
import '../../snapshot/ff_snapshot_generator.dart';
import '../../snapshot/ff_snapshot_model.dart';
import '../../utils/ff_clipboard_helper.dart';
import '../widgets/ff_empty_state.dart';
import '../widgets/ff_json_viewer.dart';
import 'ai_settings_screen.dart';
import 'diagnose_result_screen.dart';

/// Preview screen for a generated snapshot.
///
/// Offers one-tap copy, share, save, AND "Diagnose with AI" — the last of
/// these round-trips the snapshot through the configured LLM (BYO key) and
/// renders the response in [DiagnoseResultScreen].
class SnapshotPreviewScreen extends StatefulWidget {
  /// Creates the screen.
  const SnapshotPreviewScreen({this.initialProblem, super.key});

  /// Optional problem text pre-filled into the input.
  final String? initialProblem;

  @override
  State<SnapshotPreviewScreen> createState() => _SnapshotPreviewScreenState();
}

class _SnapshotPreviewScreenState extends State<SnapshotPreviewScreen> {
  late final TextEditingController _problem =
      TextEditingController(text: widget.initialProblem);
  FFSnapshot? _snapshot;
  bool _busy = false;

  @override
  void dispose() {
    _problem.dispose();
    super.dispose();
  }

  Future<void> _generate() async {
    setState(() => _busy = true);
    final FFSnapshot s =
        await FFSnapshotGenerator.generate(problem: _problem.text);
    if (!mounted) return;
    setState(() {
      _snapshot = s;
      _busy = false;
    });
  }

  Future<void> _copyPrompt() async {
    if (_snapshot == null) return;
    final String prompt = FFPromptFormatter.format(_snapshot!);
    final bool ok = await FFClipboardHelper.copy(prompt);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(ok
          ? '✅ Prompt copied. Paste it into ChatGPT / Claude / Cursor.'
          : 'Clipboard unavailable'),
      duration: const Duration(seconds: 3),
    ));
  }

  Future<void> _copyJson() async {
    if (_snapshot == null) return;
    await FFClipboardHelper.copy(_snapshot!.toPrettyJson());
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('JSON copied')),
    );
  }

  Future<void> _share() async {
    if (_snapshot == null) return;
    await FFSnapshotGenerator.share(_snapshot!);
  }

  Future<void> _diagnose() async {
    final FFSnapshot? snap = _snapshot;
    if (snap == null) return;

    final FFAiSettingsStore store = await FFAiSettingsStore.load();
    FFAiConfig config = store.read();

    if (!config.isConfigured) {
      if (!mounted) return;
      final FFAiConfig? returned = await Navigator.of(context).push<FFAiConfig>(
        MaterialPageRoute<FFAiConfig>(
          builder: (_) => const AiSettingsScreen(),
        ),
      );
      if (returned == null) return;
      config = returned;
      if (!config.isConfigured) return;
    }

    if (!mounted) return;
    await Navigator.of(context).push<void>(
      MaterialPageRoute<void>(
        builder: (_) => DiagnoseResultScreen(
          snapshot: snap,
          config: config,
          problem: _problem.text,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('AI Debug Snapshot'),
        actions: <Widget>[
          if (_snapshot != null) ...<Widget>[
            IconButton(
              icon: const Icon(Icons.share),
              onPressed: _share,
              tooltip: 'Share',
            ),
            IconButton(
              icon: const Icon(Icons.code),
              onPressed: _copyJson,
              tooltip: 'Copy JSON',
            ),
          ],
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            tooltip: 'AI settings',
            onPressed: () => Navigator.of(context).push<FFAiConfig>(
              MaterialPageRoute<FFAiConfig>(
                builder: (_) => const AiSettingsScreen(),
              ),
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            TextField(
              controller: _problem,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: 'What are you debugging?',
                hintText: 'e.g. "User data not saving after login"',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            FilledButton.icon(
              icon: _busy
                  ? const SizedBox(
                      width: 14,
                      height: 14,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.auto_awesome),
              label: Text(_snapshot == null
                  ? 'Generate snapshot'
                  : 'Regenerate snapshot'),
              onPressed: _busy ? null : _generate,
            ),
            const SizedBox(height: 12),
            Expanded(
              child: _snapshot == null
                  ? const FFEmptyState(
                      title: 'No snapshot yet',
                      message: 'Describe the issue (optional) and tap '
                          '"Generate snapshot".',
                      icon: Icons.auto_awesome,
                    )
                  : SingleChildScrollView(
                      child: FFJsonViewer(
                        title: 'Snapshot JSON',
                        value: _snapshot!.toJson(),
                      ),
                    ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: _snapshot == null
          ? null
          : SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  children: <Widget>[
                    Expanded(
                      child: FilledButton.icon(
                        icon: const Icon(Icons.auto_fix_high),
                        label: const Text('Diagnose with AI'),
                        style: FilledButton.styleFrom(
                          minimumSize: const Size.fromHeight(52),
                        ),
                        onPressed: _diagnose,
                      ),
                    ),
                    const SizedBox(width: 8),
                    IconButton.filledTonal(
                      tooltip: 'Copy AI prompt',
                      icon: const Icon(Icons.content_copy),
                      onPressed: _copyPrompt,
                      style: IconButton.styleFrom(
                        minimumSize: const Size.fromHeight(52),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
