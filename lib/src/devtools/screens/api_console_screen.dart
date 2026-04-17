import 'package:flutter/material.dart';

import '../../core/network/ff_api_call_model.dart';
import '../../core/network/ff_api_client.dart';
import '../../utils/ff_stream_merger.dart';
import '../widgets/ff_empty_state.dart';
import '../widgets/ff_search_bar.dart';
import '../widgets/ff_status_code_chip.dart';
import 'api_call_detail_screen.dart';

/// Filter mode for the API console.
enum _ApiFilter { all, success, failed, pending }

/// Alice-style list of captured HTTP calls.
class ApiConsoleScreen extends StatefulWidget {
  /// Creates the screen.
  const ApiConsoleScreen({super.key});

  @override
  State<ApiConsoleScreen> createState() => _ApiConsoleScreenState();
}

class _ApiConsoleScreenState extends State<ApiConsoleScreen> {
  String _query = '';
  _ApiFilter _filter = _ApiFilter.all;

  List<FFApiCall> _filter_(List<FFApiCall> all) {
    Iterable<FFApiCall> it = all;
    if (_query.isNotEmpty) {
      final String q = _query.toLowerCase();
      it = it.where((FFApiCall c) =>
          c.url.toLowerCase().contains(q) ||
          c.method.toLowerCase().contains(q) ||
          (c.statusCode?.toString().contains(q) ?? false));
    }
    switch (_filter) {
      case _ApiFilter.all:
        break;
      case _ApiFilter.success:
        it = it.where((FFApiCall c) => c.isSuccess);
      case _ApiFilter.failed:
        it = it.where((FFApiCall c) => c.isFailed);
      case _ApiFilter.pending:
        it = it.where((FFApiCall c) => c.status == FFApiCallStatus.pending);
    }
    return it.toList().reversed.toList(growable: false);
  }

  @override
  Widget build(BuildContext context) {
    if (!FFApiClient.instance.isInitialized) {
      return const FFEmptyState(
        title: 'API client not initialised',
        message: 'Call FlutterForgeAI.init() first.',
        icon: Icons.warning_amber,
      );
    }
    return Column(
      children: <Widget>[
        FFSearchBar(
          hint: 'Search method / URL / status…',
          onChanged: (String v) => setState(() => _query = v),
        ),
        SizedBox(
          height: 40,
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            children: <Widget>[
              for (final _ApiFilter f in _ApiFilter.values)
                Padding(
                  padding: const EdgeInsets.only(right: 6),
                  child: ChoiceChip(
                    label: Text(_labelFor(f)),
                    selected: _filter == f,
                    onSelected: (_) => setState(() => _filter = f),
                  ),
                ),
            ],
          ),
        ),
        const _StatsBanner(),
        const Divider(height: 1),
        Expanded(
          child: StreamBuilder<void>(
            stream: FFStreamMerger.merge<void>(<Stream<void>>[
              FFApiClient.instance.store.stream.map((_) {}),
              FFApiClient.instance.store.clearStream,
            ]),
            builder: (BuildContext _, AsyncSnapshot<void> __) {
              final List<FFApiCall> calls =
                  _filter_(FFApiClient.instance.store.getAll());
              if (calls.isEmpty) {
                return const FFEmptyState(
                  title: 'No API calls yet',
                  message: 'Make a request through FFApiClient.instance.dio '
                      'and it will appear here.',
                  icon: Icons.cloud_off,
                );
              }
              return ListView.separated(
                itemCount: calls.length,
                separatorBuilder: (_, __) => const Divider(height: 1),
                itemBuilder: (BuildContext c, int i) =>
                    _ApiTile(call: calls[i]),
              );
            },
          ),
        ),
      ],
    );
  }

  String _labelFor(_ApiFilter f) {
    switch (f) {
      case _ApiFilter.all:
        return 'All';
      case _ApiFilter.success:
        return 'Success';
      case _ApiFilter.failed:
        return 'Failed';
      case _ApiFilter.pending:
        return 'Pending';
    }
  }
}

class _ApiTile extends StatelessWidget {
  const _ApiTile({required this.call});
  final FFApiCall call;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      dense: true,
      leading: _MethodChip(method: call.method),
      title: Text(
        call.url,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: const TextStyle(fontSize: 13),
      ),
      subtitle: Row(
        children: <Widget>[
          FFStatusCodeChip(statusCode: call.statusCode),
          const SizedBox(width: 6),
          Text(
            call.durationMs == null ? '…' : '${call.durationMs} ms',
            style: const TextStyle(fontSize: 11),
          ),
          const SizedBox(width: 6),
          Text(
            call.requestTime.toIso8601String().split('T').last.substring(0, 8),
            style: const TextStyle(fontSize: 11),
          ),
        ],
      ),
      onTap: () => Navigator.of(context).push<void>(
        MaterialPageRoute<void>(
          builder: (_) => ApiCallDetailScreen(call: call),
        ),
      ),
    );
  }
}

class _MethodChip extends StatelessWidget {
  const _MethodChip({required this.method});
  final String method;

  Color _color() {
    switch (method.toUpperCase()) {
      case 'GET':
        return Colors.blue;
      case 'POST':
        return Colors.green;
      case 'PUT':
      case 'PATCH':
        return Colors.orange;
      case 'DELETE':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final Color c = _color();
    return Container(
      width: 50,
      padding: const EdgeInsets.symmetric(vertical: 4),
      decoration: BoxDecoration(
        color: c.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(6),
      ),
      alignment: Alignment.center,
      child: Text(
        method.toUpperCase(),
        style: TextStyle(
          color: c,
          fontSize: 10.5,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _StatsBanner extends StatelessWidget {
  const _StatsBanner();

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<void>(
      stream: FFStreamMerger.merge<void>(<Stream<void>>[
        FFApiClient.instance.store.stream.map((_) {}),
        FFApiClient.instance.store.clearStream,
      ]),
      builder: (BuildContext c, AsyncSnapshot<void> _) {
        final List<FFApiCall> all = FFApiClient.instance.store.getAll();
        final int total = all.length;
        final int failed = all.where((FFApiCall c) => c.isFailed).length;
        final int success = all.where((FFApiCall c) => c.isSuccess).length;
        final List<int> durations = all
            .map((FFApiCall c) => c.durationMs ?? 0)
            .where((int d) => d > 0)
            .toList();
        final int avg = durations.isEmpty
            ? 0
            : (durations.reduce((int a, int b) => a + b) / durations.length)
                .round();
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          child: Row(
            children: <Widget>[
              _Stat(label: 'Total', value: '$total'),
              _Stat(label: 'Success', value: '$success'),
              _Stat(label: 'Failed', value: '$failed'),
              _Stat(label: 'Avg', value: '${avg}ms'),
            ],
          ),
        );
      },
    );
  }
}

class _Stat extends StatelessWidget {
  const _Stat({required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: <Widget>[
          Text(value, style: const TextStyle(fontWeight: FontWeight.w700)),
          Text(label, style: const TextStyle(fontSize: 11, color: Colors.grey)),
        ],
      ),
    );
  }
}
