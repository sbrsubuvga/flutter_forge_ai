import 'package:flutter/material.dart';

import '../../ai/ff_ai_client.dart';
import '../../ai/ff_ai_config.dart';
import '../../ai/ff_ai_prompt.dart';
import '../../ai/ff_ai_provider.dart';
import '../../ai/ff_ai_response.dart';
import '../../snapshot/ff_snapshot_model.dart';
import '../../utils/ff_clipboard_helper.dart';
import 'ai_settings_screen.dart';

/// Screen that fires one diagnosis call against the configured provider and
/// renders the streaming response (non-streaming v1 — one round-trip).
class DiagnoseResultScreen extends StatefulWidget {
  /// Creates the screen.
  const DiagnoseResultScreen({
    required this.snapshot,
    required this.config,
    required this.problem,
    super.key,
  });

  /// Snapshot passed to the LLM.
  final FFSnapshot snapshot;

  /// Resolved config (provider + key).
  final FFAiConfig config;

  /// User-supplied problem description.
  final String problem;

  @override
  State<DiagnoseResultScreen> createState() => _DiagnoseResultScreenState();
}

class _DiagnoseResultScreenState extends State<DiagnoseResultScreen> {
  bool _loading = true;
  FFAiResponse? _response;
  FFAiException? _error;

  @override
  void initState() {
    super.initState();
    _run();
  }

  Future<void> _run() async {
    setState(() {
      _loading = true;
      _response = null;
      _error = null;
    });
    try {
      final FFAiClient client = FFAiClient.forConfig(widget.config);
      final FFAiResponse resp = await client.diagnose(
        snapshot: widget.snapshot,
        systemPrompt: FFAiPrompt.systemPrompt,
        userPrompt: FFAiPrompt.user(
          snapshot: widget.snapshot,
          problem: widget.problem,
        ),
      );
      if (!mounted) return;
      setState(() {
        _response = resp;
        _loading = false;
      });
    } on FFAiException catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = FFAiException(e.toString());
        _loading = false;
      });
    }
  }

  Future<void> _copy() async {
    final FFAiResponse? r = _response;
    if (r == null) return;
    await FFClipboardHelper.copy(r.text);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Response copied')),
    );
  }

  Future<void> _openSettings() async {
    await Navigator.of(context).push<FFAiConfig>(
      MaterialPageRoute<FFAiConfig>(
        builder: (_) => const AiSettingsScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: <Widget>[
            const Text('Diagnose with AI'),
            const SizedBox(width: 8),
            Text(
              '· ${widget.config.provider.label}',
              style: const TextStyle(fontSize: 12),
            ),
          ],
        ),
        actions: <Widget>[
          IconButton(
            tooltip: 'Settings',
            icon: const Icon(Icons.settings_outlined),
            onPressed: _openSettings,
          ),
          if (_response != null)
            IconButton(
              tooltip: 'Copy',
              icon: const Icon(Icons.copy_outlined),
              onPressed: _copy,
            ),
          IconButton(
            tooltip: 'Retry',
            icon: const Icon(Icons.refresh),
            onPressed: _loading ? null : _run,
          ),
        ],
      ),
      body: _buildBody(context),
    );
  }

  Widget _buildBody(BuildContext context) {
    if (_loading) {
      return const _LoadingPane();
    }
    final FFAiException? err = _error;
    if (err != null) {
      return _ErrorPane(error: err, onRetry: _run);
    }
    final FFAiResponse? r = _response;
    if (r == null) return const SizedBox.shrink();
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Wrap(
            spacing: 8,
            runSpacing: 4,
            children: <Widget>[
              _Chip(label: r.provider),
              _Chip(label: r.model, icon: Icons.memory),
              if (r.completionTokens != null)
                _Chip(
                  label: '${r.completionTokens} out',
                  icon: Icons.text_snippet_outlined,
                ),
              if (r.finishReason != null)
                _Chip(label: r.finishReason!, icon: Icons.flag_outlined),
            ],
          ),
          const SizedBox(height: 16),
          SelectableText(
            r.text,
            style: const TextStyle(fontSize: 14, height: 1.4),
          ),
        ],
      ),
    );
  }
}

class _LoadingPane extends StatelessWidget {
  const _LoadingPane();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          CircularProgressIndicator(),
          SizedBox(height: 16),
          Text('Asking the AI…', style: TextStyle(fontSize: 13)),
        ],
      ),
    );
  }
}

class _ErrorPane extends StatelessWidget {
  const _ErrorPane({required this.error, required this.onRetry});

  final FFAiException error;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          const Icon(Icons.error_outline, size: 48, color: Colors.redAccent),
          const SizedBox(height: 12),
          Text(
            'Diagnosis failed',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          SelectableText(
            error.message,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 13),
          ),
          if (error.providerBody != null) ...<Widget>[
            const SizedBox(height: 12),
            SelectableText(
              error.providerBody.toString(),
              style: const TextStyle(fontSize: 11, color: Colors.grey),
              textAlign: TextAlign.center,
              maxLines: 4,
            ),
          ],
          const SizedBox(height: 16),
          FilledButton.icon(
            icon: const Icon(Icons.refresh),
            label: const Text('Retry'),
            onPressed: onRetry,
          ),
        ],
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  const _Chip({required this.label, this.icon});
  final String label;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final Color bg = Theme.of(context).colorScheme.surfaceContainerHighest;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          if (icon != null) ...<Widget>[
            Icon(icon, size: 12),
            const SizedBox(width: 4),
          ],
          Text(label, style: const TextStyle(fontSize: 11)),
        ],
      ),
    );
  }
}
