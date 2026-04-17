import 'package:flutter/material.dart';

import '../../ai/ff_ai_config.dart';
import '../../ai/ff_ai_provider.dart';
import '../../ai/ff_ai_settings_store.dart';

/// Form for the one-tap "Diagnose with AI" feature.
///
/// The key is stored locally via [FFAiSettingsStore] and is **never**
/// surfaced in an AI snapshot — the stored value has its own namespace and
/// is written only by this screen.
class AiSettingsScreen extends StatefulWidget {
  /// Creates the screen.
  const AiSettingsScreen({super.key});

  @override
  State<AiSettingsScreen> createState() => _AiSettingsScreenState();
}

class _AiSettingsScreenState extends State<AiSettingsScreen> {
  FFAiSettingsStore? _store;
  FFAiConfig _config = const FFAiConfig(
    provider: FFAiProvider.anthropic,
    apiKey: '',
  );
  final TextEditingController _keyController = TextEditingController();
  final TextEditingController _modelController = TextEditingController();
  final TextEditingController _baseUrlController = TextEditingController();
  bool _showKey = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final FFAiSettingsStore store = await FFAiSettingsStore.load();
    final FFAiConfig cfg = store.read();
    if (!mounted) return;
    setState(() {
      _store = store;
      _config = cfg;
      _keyController.text = cfg.apiKey;
      _modelController.text = cfg.model;
      _baseUrlController.text = cfg.baseUrl;
    });
  }

  @override
  void dispose() {
    _keyController.dispose();
    _modelController.dispose();
    _baseUrlController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final FFAiSettingsStore? store = _store;
    if (store == null) return;
    final FFAiConfig cfg = _config.copyWith(
      apiKey: _keyController.text.trim(),
      model: _modelController.text.trim(),
      baseUrl: _baseUrlController.text.trim(),
    );
    await store.write(cfg);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('✓ AI settings saved.')),
    );
    Navigator.of(context).pop(cfg);
  }

  Future<void> _clearKey() async {
    final FFAiSettingsStore? store = _store;
    if (store == null) return;
    await store.clear();
    if (!mounted) return;
    setState(() {
      _config = const FFAiConfig(
        provider: FFAiProvider.anthropic,
        apiKey: '',
      );
      _keyController.clear();
      _modelController.clear();
      _baseUrlController.clear();
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('AI settings cleared.')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool loaded = _store != null;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Diagnose with AI — settings'),
        actions: <Widget>[
          if (loaded && _config.isConfigured)
            IconButton(
              tooltip: 'Clear key',
              icon: const Icon(Icons.delete_outline),
              onPressed: _clearKey,
            ),
        ],
      ),
      body: !loaded
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  const Text(
                    'Bring your own key. The API key stays on this device — '
                    'it is never written into a snapshot or sent anywhere '
                    'except to the provider you choose.',
                    style: TextStyle(fontSize: 12),
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<FFAiProvider>(
                    // `initialValue` requires Flutter 3.33+; this package's
                    // minimum is 3.19, so we keep the deprecated `value`.
                    // ignore: deprecated_member_use
                    value: _config.provider,
                    decoration: const InputDecoration(
                      labelText: 'Provider',
                      border: OutlineInputBorder(),
                    ),
                    items: FFAiProvider.values
                        .map((FFAiProvider p) => DropdownMenuItem<FFAiProvider>(
                              value: p,
                              child: Text(p.label),
                            ))
                        .toList(),
                    onChanged: (FFAiProvider? p) {
                      if (p == null) return;
                      setState(() {
                        _config = _config.copyWith(provider: p);
                      });
                    },
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _keyController,
                    obscureText: !_showKey,
                    decoration: InputDecoration(
                      labelText: 'API key',
                      hintText: _config.provider == FFAiProvider.anthropic
                          ? 'sk-ant-…'
                          : 'sk-…',
                      border: const OutlineInputBorder(),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _showKey ? Icons.visibility_off : Icons.visibility,
                        ),
                        onPressed: () => setState(() => _showKey = !_showKey),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _modelController,
                    decoration: InputDecoration(
                      labelText: 'Model (optional)',
                      hintText: 'default: ${_config.provider.defaultModel}',
                      border: const OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _baseUrlController,
                    decoration: InputDecoration(
                      labelText: 'Base URL (optional)',
                      hintText: 'default: ${_config.provider.defaultBaseUrl}',
                      border: const OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 24),
                  FilledButton.icon(
                    icon: const Icon(Icons.save),
                    label: const Text('Save'),
                    onPressed: _save,
                  ),
                ],
              ),
            ),
    );
  }
}
