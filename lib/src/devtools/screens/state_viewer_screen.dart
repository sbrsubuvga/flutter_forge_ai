import 'package:flutter/material.dart';

import '../../core/state/ff_state_change_model.dart';
import '../../core/state/ff_state_store.dart';
import '../../utils/ff_stream_merger.dart';
import '../widgets/ff_empty_state.dart';
import '../widgets/ff_json_viewer.dart';
import '../widgets/ff_search_bar.dart';

/// Riverpod state viewer — shows currently active providers and a timeline
/// of changes.
class StateViewerScreen extends StatefulWidget {
  /// Creates the screen.
  const StateViewerScreen({required this.store, super.key});

  /// The state store to display.
  final FFStateStore store;

  @override
  State<StateViewerScreen> createState() => _StateViewerScreenState();
}

class _StateViewerScreenState extends State<StateViewerScreen> {
  String _query = '';

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Column(
        children: <Widget>[
          const TabBar(tabs: <Tab>[
            Tab(text: 'Active'),
            Tab(text: 'Timeline'),
          ]),
          FFSearchBar(
            hint: 'Search by provider name…',
            onChanged: (String v) => setState(() => _query = v),
          ),
          const Divider(height: 1),
          Expanded(
            child: StreamBuilder<void>(
              stream: FFStreamMerger.merge<void>(<Stream<void>>[
                widget.store.stream.map((_) {}),
                widget.store.clearStream,
              ]),
              builder: (BuildContext c, AsyncSnapshot<void> _) => TabBarView(
                children: <Widget>[
                  _ActiveProvidersTab(query: _query, store: widget.store),
                  _TimelineTab(query: _query, store: widget.store),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ActiveProvidersTab extends StatelessWidget {
  const _ActiveProvidersTab({required this.query, required this.store});

  final String query;
  final FFStateStore store;

  @override
  Widget build(BuildContext context) {
    final List<FFStateChange> active = store.activeProviders.values.toList();
    final String q = query.toLowerCase();
    final List<FFStateChange> filtered = q.isEmpty
        ? active
        : active
            .where((FFStateChange c) =>
                c.providerName.toLowerCase().contains(q) ||
                c.providerType.toLowerCase().contains(q))
            .toList();
    if (filtered.isEmpty) {
      return const FFEmptyState(
        title: 'No active providers',
        message: 'Add FFStateObserver() to ProviderScope.observers.',
        icon: Icons.memory,
      );
    }
    return ListView.separated(
      itemCount: filtered.length,
      separatorBuilder: (_, __) => const Divider(height: 1),
      itemBuilder: (BuildContext c, int i) {
        final FFStateChange p = filtered[i];
        return ExpansionTile(
          title: Text(p.providerName,
              style: const TextStyle(fontWeight: FontWeight.w600)),
          subtitle: Text(p.providerType,
              style: const TextStyle(fontSize: 11, color: Colors.grey)),
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.all(12),
              child: FFJsonViewer(value: p.newValue ?? 'null'),
            ),
          ],
        );
      },
    );
  }
}

class _TimelineTab extends StatelessWidget {
  const _TimelineTab({required this.query, required this.store});

  final String query;
  final FFStateStore store;

  Color _color(FFStateChangeType t) {
    switch (t) {
      case FFStateChangeType.added:
        return Colors.green;
      case FFStateChangeType.updated:
        return Colors.blue;
      case FFStateChangeType.disposed:
        return Colors.grey;
      case FFStateChangeType.failed:
        return Colors.red;
    }
  }

  @override
  Widget build(BuildContext context) {
    final List<FFStateChange> all = store.getAllNewestFirst();
    final String q = query.toLowerCase();
    final List<FFStateChange> filtered = q.isEmpty
        ? all
        : all
            .where(
                (FFStateChange c) => c.providerName.toLowerCase().contains(q))
            .toList();
    if (filtered.isEmpty) {
      return const FFEmptyState(
        title: 'No state changes',
        message: 'Modify a Riverpod provider to see events.',
        icon: Icons.timeline,
      );
    }
    return ListView.separated(
      itemCount: filtered.length,
      separatorBuilder: (_, __) => const Divider(height: 1),
      itemBuilder: (BuildContext c, int i) {
        final FFStateChange e = filtered[i];
        return ListTile(
          dense: true,
          leading: CircleAvatar(
            radius: 10,
            backgroundColor: _color(e.type),
          ),
          title: Text('${e.type.name.toUpperCase()} · ${e.providerName}'),
          subtitle: Text(
            e.type == FFStateChangeType.updated
                ? '${e.previousValue ?? '—'} → ${e.newValue ?? '—'}'
                : e.newValue ?? e.error?.toString() ?? '',
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 11),
          ),
          trailing: Text(
            e.timestamp.toIso8601String().split('T').last.substring(0, 8),
            style: const TextStyle(fontSize: 10),
          ),
        );
      },
    );
  }
}
