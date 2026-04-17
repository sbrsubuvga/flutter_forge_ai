import 'package:flutter/material.dart';

import '../../core/logger/ff_log_level.dart';
import '../../core/logger/ff_log_model.dart';
import '../../core/logger/ff_logger.dart';
import '../../utils/ff_clipboard_helper.dart';
import '../../utils/ff_stream_merger.dart';
import '../widgets/ff_empty_state.dart';
import '../widgets/ff_json_viewer.dart';
import '../widgets/ff_log_level_chip.dart';
import '../widgets/ff_search_bar.dart';

/// Talker-style list of captured logs with level filtering and search.
class LogViewerScreen extends StatefulWidget {
  /// Creates the screen.
  const LogViewerScreen({super.key});

  @override
  State<LogViewerScreen> createState() => _LogViewerScreenState();
}

class _LogViewerScreenState extends State<LogViewerScreen> {
  String _query = '';
  final Set<FFLogLevel> _activeLevels = <FFLogLevel>{...FFLogLevel.values};

  List<FFLogEntry> _filtered() {
    final List<FFLogEntry> base = _query.isEmpty
        ? FFLogger.store.getAll()
        : FFLogger.store.search(_query);
    return base
        .where((FFLogEntry e) => _activeLevels.contains(e.level))
        .toList()
        .reversed
        .toList(growable: false);
  }

  void _toggleLevel(FFLogLevel level) {
    setState(() {
      if (_activeLevels.contains(level)) {
        _activeLevels.remove(level);
      } else {
        _activeLevels.add(level);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!FFLogger.isInitialized) {
      return const FFEmptyState(
        title: 'Logger not initialised',
        message: 'Call FlutterForgeAI.init() first.',
        icon: Icons.warning_amber,
      );
    }
    return Column(
      children: <Widget>[
        FFSearchBar(
          hint: 'Search logs…',
          onChanged: (String v) => setState(() => _query = v),
        ),
        SizedBox(
          height: 40,
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            children: <Widget>[
              for (final FFLogLevel l in FFLogLevel.values)
                Padding(
                  padding: const EdgeInsets.only(right: 6),
                  child: FilterChip(
                    label: Text(l.label),
                    selected: _activeLevels.contains(l),
                    onSelected: (_) => _toggleLevel(l),
                    selectedColor: l.color.withValues(alpha: 0.2),
                    checkmarkColor: l.color,
                  ),
                ),
            ],
          ),
        ),
        const Divider(height: 1),
        Expanded(
          child: StreamBuilder<void>(
            stream: FFStreamMerger.merge<void>(<Stream<void>>[
              FFLogger.store.stream.map((_) {}),
              FFLogger.store.clearStream,
            ]),
            builder: (BuildContext ctx, AsyncSnapshot<void> _) {
              final List<FFLogEntry> entries = _filtered();
              if (entries.isEmpty) {
                return const FFEmptyState(
                  title: 'No logs match',
                  message: 'Try broadening your filters.',
                  icon: Icons.notes,
                );
              }
              return ListView.separated(
                itemCount: entries.length,
                separatorBuilder: (_, __) => const Divider(height: 1),
                itemBuilder: (BuildContext c, int i) =>
                    _LogTile(entry: entries[i]),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _LogTile extends StatelessWidget {
  const _LogTile({required this.entry});

  final FFLogEntry entry;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      dense: true,
      leading: FFLogLevelChip(level: entry.level, compact: true),
      title: Text(
        entry.message,
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: Text(
        '${entry.timestamp.toIso8601String()}'
        '${entry.tag != null ? '  ·  ${entry.tag}' : ''}',
        style: const TextStyle(fontSize: 11),
      ),
      onTap: () => Navigator.of(context).push<void>(
        MaterialPageRoute<void>(
          builder: (_) => _LogDetailScreen(entry: entry),
        ),
      ),
    );
  }
}

class _LogDetailScreen extends StatelessWidget {
  const _LogDetailScreen({required this.entry});

  final FFLogEntry entry;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${entry.level.label} log'),
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.copy),
            tooltip: 'Copy',
            onPressed: () async {
              final String text = entry.toJson().toString();
              await FFClipboardHelper.copy(text);
              if (!context.mounted) return;
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Copied')),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(12),
        child: FFJsonViewer(
          value: entry.toJson(),
          title: entry.message,
        ),
      ),
    );
  }
}
