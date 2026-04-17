import 'package:flutter/material.dart';

import '../../core/db/ff_db_helper.dart';
import '../../core/db/ff_db_query_runner.dart';
import '../../core/db/ff_db_schema_reader.dart';
import '../widgets/ff_empty_state.dart';
import '../widgets/ff_json_viewer.dart';

/// Database console: table list, schema viewer, row browser, raw SQL runner.
class DbConsoleScreen extends StatefulWidget {
  /// Creates the screen.
  const DbConsoleScreen({super.key});

  @override
  State<DbConsoleScreen> createState() => _DbConsoleScreenState();
}

class _DbConsoleScreenState extends State<DbConsoleScreen> {
  Future<List<_TableSummary>>? _future;

  Future<List<_TableSummary>> _load() async {
    if (!FFDbHelper.instance.isInitialized) return <_TableSummary>[];
    final FFDbSchemaReader reader =
        FFDbSchemaReader(FFDbHelper.instance.database);
    final List<String> tables = await reader.getAllTables();
    final List<_TableSummary> out = <_TableSummary>[];
    for (final String t in tables) {
      out.add(_TableSummary(
        name: t,
        rowCount: await reader.getRowCount(t),
      ));
    }
    return out;
  }

  @override
  void initState() {
    super.initState();
    _future = _load();
  }

  @override
  Widget build(BuildContext context) {
    if (!FFDbHelper.instance.isInitialized) {
      return const FFEmptyState(
        title: 'Database not initialised',
        message: 'Call FlutterForgeAI.init() first.',
        icon: Icons.storage_outlined,
      );
    }
    return FutureBuilder<List<_TableSummary>>(
      future: _future,
      builder: (BuildContext c, AsyncSnapshot<List<_TableSummary>> snap) {
        if (snap.connectionState != ConnectionState.done) {
          return const Center(child: CircularProgressIndicator());
        }
        final List<_TableSummary> tables = snap.data ?? const <_TableSummary>[];
        return Column(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: <Widget>[
                  Expanded(
                    child: Text(
                      '${tables.length} table(s)',
                      style: Theme.of(context).textTheme.titleSmall,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.refresh),
                    onPressed: () => setState(() => _future = _load()),
                  ),
                  IconButton(
                    icon: const Icon(Icons.code),
                    tooltip: 'Run SQL',
                    onPressed: () => Navigator.of(context).push<void>(
                      MaterialPageRoute<void>(
                        builder: (_) => const _SqlRunnerScreen(),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            Expanded(
              child: tables.isEmpty
                  ? const FFEmptyState(
                      title: 'No tables yet',
                      message: 'Create a table and refresh.',
                      icon: Icons.table_chart_outlined,
                    )
                  : ListView.separated(
                      itemCount: tables.length,
                      separatorBuilder: (_, __) => const Divider(height: 1),
                      itemBuilder: (BuildContext c, int i) {
                        final _TableSummary t = tables[i];
                        return ListTile(
                          leading: const Icon(Icons.table_rows_outlined),
                          title: Text(t.name),
                          subtitle: Text(
                            '${t.rowCount} row(s)',
                            style: const TextStyle(fontSize: 11),
                          ),
                          onTap: () => Navigator.of(context).push<void>(
                            MaterialPageRoute<void>(
                              builder: (_) => _TableDetailScreen(table: t.name),
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        );
      },
    );
  }
}

class _TableSummary {
  const _TableSummary({required this.name, required this.rowCount});
  final String name;
  final int rowCount;
}

class _TableDetailScreen extends StatefulWidget {
  const _TableDetailScreen({required this.table});
  final String table;

  @override
  State<_TableDetailScreen> createState() => _TableDetailScreenState();
}

class _TableDetailScreenState extends State<_TableDetailScreen> {
  Future<_TableDetailData>? _future;

  Future<_TableDetailData> _load() async {
    final FFDbSchemaReader reader =
        FFDbSchemaReader(FFDbHelper.instance.database);
    return _TableDetailData(
      columns: await reader.getColumns(widget.table),
      rows: await reader.getSampleRows(widget.table, limit: 50),
      rowCount: await reader.getRowCount(widget.table),
    );
  }

  @override
  void initState() {
    super.initState();
    _future = _load();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.table),
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => setState(() => _future = _load()),
          ),
        ],
      ),
      body: FutureBuilder<_TableDetailData>(
        future: _future,
        builder: (BuildContext c, AsyncSnapshot<_TableDetailData> s) {
          if (s.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          final _TableDetailData d = s.data!;
          return SingleChildScrollView(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                Text('${d.rowCount} row(s)',
                    style: Theme.of(context).textTheme.titleSmall),
                const SizedBox(height: 12),
                FFJsonViewer(
                  title: 'Schema',
                  value: d.columns
                      .map((FFDbColumn c) => c.toJson())
                      .toList(growable: false),
                ),
                const SizedBox(height: 12),
                FFJsonViewer(
                  title: 'Sample rows (up to 50)',
                  value: d.rows,
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _TableDetailData {
  const _TableDetailData({
    required this.columns,
    required this.rows,
    required this.rowCount,
  });
  final List<FFDbColumn> columns;
  final List<Map<String, Object?>> rows;
  final int rowCount;
}

class _SqlRunnerScreen extends StatefulWidget {
  const _SqlRunnerScreen();

  @override
  State<_SqlRunnerScreen> createState() => _SqlRunnerScreenState();
}

class _SqlRunnerScreenState extends State<_SqlRunnerScreen> {
  final TextEditingController _sql = TextEditingController();
  FFDbQueryResult? _result;
  bool _running = false;

  @override
  void dispose() {
    _sql.dispose();
    super.dispose();
  }

  Future<void> _run() async {
    setState(() => _running = true);
    final FFDbQueryRunner runner =
        FFDbQueryRunner(FFDbHelper.instance.database);
    final FFDbQueryResult r = await runner.run(_sql.text);
    if (!mounted) return;
    setState(() {
      _result = r;
      _running = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('SQL Runner')),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            TextField(
              controller: _sql,
              maxLines: 5,
              style: const TextStyle(fontFamily: 'monospace', fontSize: 13),
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'SELECT * FROM users LIMIT 10',
              ),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: <Widget>[
                FilledButton.icon(
                  icon: _running
                      ? const SizedBox(
                          width: 14,
                          height: 14,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.play_arrow),
                  label: const Text('Run'),
                  onPressed: _running ? null : _run,
                ),
              ],
            ),
            const SizedBox(height: 12),
            Expanded(
              child: SingleChildScrollView(
                child: _result == null
                    ? const FFEmptyState(
                        title: 'Run a query to see results',
                        icon: Icons.play_circle_outline,
                      )
                    : FFJsonViewer(
                        title: _result!.isSuccess
                            ? 'Result (${_result!.durationMs} ms)'
                            : 'Error',
                        value: _result!.toJson(),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
