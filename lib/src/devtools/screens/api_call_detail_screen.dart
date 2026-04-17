import 'package:flutter/material.dart';

import '../../core/network/ff_api_call_model.dart';
import '../../utils/ff_clipboard_helper.dart';
import '../widgets/ff_json_viewer.dart';
import '../widgets/ff_status_code_chip.dart';

/// Full request / response / timing / actions view for a single API call.
class ApiCallDetailScreen extends StatelessWidget {
  /// Creates the screen.
  const ApiCallDetailScreen({required this.call, super.key});

  /// The call being viewed.
  final FFApiCall call;

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: Row(
            children: <Widget>[
              FFStatusCodeChip(statusCode: call.statusCode),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  '${call.method} ${call.url}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 15),
                ),
              ),
            ],
          ),
          bottom: const TabBar(tabs: <Tab>[
            Tab(text: 'Request'),
            Tab(text: 'Response'),
            Tab(text: 'Timing'),
          ]),
          actions: <Widget>[
            PopupMenuButton<_ApiAction>(
              icon: const Icon(Icons.more_vert),
              onSelected: (_ApiAction a) => _onAction(context, a),
              itemBuilder: (_) => const <PopupMenuEntry<_ApiAction>>[
                PopupMenuItem<_ApiAction>(
                  value: _ApiAction.copyCurl,
                  child: Text('Copy as cURL'),
                ),
                PopupMenuItem<_ApiAction>(
                  value: _ApiAction.copyUrl,
                  child: Text('Copy URL'),
                ),
                PopupMenuItem<_ApiAction>(
                  value: _ApiAction.copyResponse,
                  child: Text('Copy response JSON'),
                ),
                PopupMenuItem<_ApiAction>(
                  value: _ApiAction.copyAll,
                  child: Text('Copy full JSON'),
                ),
              ],
            ),
          ],
        ),
        body: TabBarView(children: <Widget>[
          _RequestTab(call: call),
          _ResponseTab(call: call),
          _TimingTab(call: call),
        ]),
      ),
    );
  }

  Future<void> _onAction(BuildContext context, _ApiAction a) async {
    late final String payload;
    switch (a) {
      case _ApiAction.copyCurl:
        payload = call.curl ?? '(no curl available)';
      case _ApiAction.copyUrl:
        payload = call.url;
      case _ApiAction.copyResponse:
        payload = (call.responseBody ?? '').toString();
      case _ApiAction.copyAll:
        payload = call.toJson().toString();
    }
    final bool ok = await FFClipboardHelper.copy(payload);
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(ok ? 'Copied to clipboard' : 'Copy failed')),
    );
  }
}

enum _ApiAction { copyCurl, copyUrl, copyResponse, copyAll }

class _RequestTab extends StatelessWidget {
  const _RequestTab({required this.call});
  final FFApiCall call;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          FFJsonViewer(
            title: 'Headers',
            value: call.requestHeaders,
          ),
          const SizedBox(height: 12),
          FFJsonViewer(
            title: 'Query parameters',
            value: call.queryParameters,
          ),
          const SizedBox(height: 12),
          FFJsonViewer(
            title: 'Body',
            value: call.requestBody,
          ),
          if (call.curl != null) ...<Widget>[
            const SizedBox(height: 12),
            FFJsonViewer(title: 'cURL', value: call.curl),
          ],
        ],
      ),
    );
  }
}

class _ResponseTab extends StatelessWidget {
  const _ResponseTab({required this.call});
  final FFApiCall call;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Row(
            children: <Widget>[
              FFStatusCodeChip(statusCode: call.statusCode),
              const SizedBox(width: 8),
              Text('Status: ${call.status.name}'),
            ],
          ),
          const SizedBox(height: 12),
          FFJsonViewer(title: 'Headers', value: call.responseHeaders),
          const SizedBox(height: 12),
          FFJsonViewer(title: 'Body', value: call.responseBody),
          if (call.error != null) ...<Widget>[
            const SizedBox(height: 12),
            FFJsonViewer(title: 'Error', value: call.error),
          ],
          if (call.stackTrace != null) ...<Widget>[
            const SizedBox(height: 12),
            FFJsonViewer(title: 'Stack trace', value: call.stackTrace),
          ],
        ],
      ),
    );
  }
}

class _TimingTab extends StatelessWidget {
  const _TimingTab({required this.call});
  final FFApiCall call;

  @override
  Widget build(BuildContext context) {
    final int? dur = call.durationMs;
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          _row('Request time', call.requestTime.toIso8601String()),
          _row('Response time',
              call.responseTime?.toIso8601String() ?? '(not received)'),
          _row('Duration', dur == null ? '(pending)' : '$dur ms'),
          _row('Method', call.method),
          _row('Status', call.status.name),
        ],
      ),
    );
  }

  Widget _row(String k, String v) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Row(
          children: <Widget>[
            SizedBox(
              width: 140,
              child:
                  Text(k, style: const TextStyle(fontWeight: FontWeight.w600)),
            ),
            Expanded(child: SelectableText(v)),
          ],
        ),
      );
}
