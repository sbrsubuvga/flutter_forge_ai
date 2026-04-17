import 'package:flutter/material.dart';

import '../../snapshot/ff_prompt_formatter.dart';
import '../../snapshot/ff_snapshot_generator.dart';
import '../../snapshot/ff_snapshot_model.dart';
import '../../utils/ff_clipboard_helper.dart';
import '../widgets/ff_empty_state.dart';
import '../widgets/ff_json_viewer.dart';

/// Preview screen for a generated snapshot.
///
/// Offers one-tap copy / share / save actions; copying the AI-ready prompt
/// is the main flow.
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
                child: FilledButton.icon(
                  icon: const Icon(Icons.content_copy),
                  label: const Text('Copy AI prompt & paste to assistant'),
                  style: FilledButton.styleFrom(
                    minimumSize: const Size.fromHeight(52),
                  ),
                  onPressed: _copyPrompt,
                ),
              ),
            ),
    );
  }
}
