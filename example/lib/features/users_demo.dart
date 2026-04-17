import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutterforge_ai/flutterforge_ai.dart';

/// Simple user model.
class User {
  /// Creates a user.
  const User({required this.id, required this.name, required this.email});

  /// Creates a user from jsonplaceholder's response shape.
  factory User.fromJson(Map<String, Object?> json) => User(
        id: (json['id'] as num).toInt(),
        name: json['name']?.toString() ?? '',
        email: json['email']?.toString() ?? '',
      );

  /// Stable ID.
  final int id;

  /// Display name.
  final String name;

  /// Email.
  final String email;

  /// JSON encode.
  Map<String, Object?> toJson() =>
      <String, Object?>{'id': id, 'name': name, 'email': email};
}

/// Immutable state for the users screen.
class UsersState {
  /// Creates a state snapshot.
  const UsersState({
    this.users = const <User>[],
    this.loading = false,
    this.error,
  });

  /// Current users.
  final List<User> users;

  /// Whether a request is in flight.
  final bool loading;

  /// Last error message, if any.
  final String? error;

  /// Returns a copy with overrides.
  UsersState copyWith({
    List<User>? users,
    bool? loading,
    Object? error = _sentinel,
  }) =>
      UsersState(
        users: users ?? this.users,
        loading: loading ?? this.loading,
        error: identical(error, _sentinel) ? this.error : error as String?,
      );

  static const Object _sentinel = Object();
}

/// Riverpod controller that loads users and persists them to SQLite.
class UsersController extends StateNotifier<UsersState> {
  /// Creates the controller.
  UsersController() : super(const UsersState());

  /// Loads users from the API and caches them in SQLite.
  Future<void> load() async {
    state = state.copyWith(loading: true, error: null);
    FFLogger.info('Loading users…', tag: 'users');
    try {
      final List<Map<String, Object?>> rows = await _loadFromApi();
      final List<User> users = rows.map(User.fromJson).toList();
      await _cacheLocally(users);
      state = state.copyWith(users: users, loading: false);
      FFLogger.info('Loaded ${users.length} users', tag: 'users');
    } catch (e, st) {
      FFLogger.error('Failed to load users',
          error: e, stackTrace: st, tag: 'users');
      state = state.copyWith(loading: false, error: e.toString());
    }
  }

  Future<List<Map<String, Object?>>> _loadFromApi() async {
    final dynamic response =
        await FFApiClient.instance.dio.get<List<dynamic>>('/users');
    final List<dynamic> data = response.data as List<dynamic>;
    return data.cast<Map<String, Object?>>();
  }

  Future<void> _cacheLocally(List<User> users) async {
    if (!FFDbHelper.instance.isInitialized) return;
    try {
      await FFDbHelper.instance.database.execute('''
        CREATE TABLE IF NOT EXISTS users(
          id INTEGER PRIMARY KEY,
          name TEXT NOT NULL,
          email TEXT NOT NULL
        )
      ''');
      await FFDbHelper.instance.database.delete('users');
      for (final User u in users) {
        await FFDbHelper.instance.insert('users', u.toJson());
      }
    } catch (e, st) {
      FFLogger.warning('Could not cache users locally: $e', tag: 'users');
      FFLogger.debug(st.toString(), tag: 'users');
    }
  }

  /// Intentionally throws to demo error capture.
  void triggerError() {
    FFLogger.warning('User triggered intentional error', tag: 'demo');
    throw StateError('Intentional error from "Trigger Error" button.');
  }
}

/// Riverpod provider for the controller.
final StateNotifierProvider<UsersController, UsersState> usersProvider =
    StateNotifierProvider<UsersController, UsersState>(
  (StateNotifierProviderRef<UsersController, UsersState> ref) =>
      UsersController(),
  name: 'usersProvider',
);

/// Screen listing users, with demo buttons for each SDK feature.
class UsersScreen extends ConsumerWidget {
  /// Creates the screen.
  const UsersScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final UsersState state = ref.watch(usersProvider);
    return Scaffold(
      appBar: AppBar(
        title: const Text('FlutterForge Example'),
      ),
      body: Column(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(12),
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: <Widget>[
                FilledButton.icon(
                  icon: const Icon(Icons.cloud_download),
                  label: const Text('Load users'),
                  onPressed: () => ref.read(usersProvider.notifier).load(),
                ),
                OutlinedButton.icon(
                  icon: const Icon(Icons.bug_report),
                  label: const Text('Trigger error'),
                  onPressed: () {
                    try {
                      ref.read(usersProvider.notifier).triggerError();
                    } catch (e, st) {
                      FFLogger.error('Caught error in UI',
                          error: e, stackTrace: st, tag: 'ui');
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Error logged: $e')),
                      );
                    }
                  },
                ),
                OutlinedButton.icon(
                  icon: const Icon(Icons.auto_awesome),
                  label: const Text('Generate snapshot'),
                  onPressed: () async {
                    final FFSnapshot snap = await FFSnapshotGenerator.generate(
                        problem: 'Tapped the demo button');
                    final String prompt = FFPromptFormatter.format(snap);
                    await FFClipboardHelper.copy(prompt);
                    if (!context.mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                            '✅ AI prompt copied. Paste to ChatGPT/Claude.'),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
          if (state.loading) const LinearProgressIndicator(),
          if (state.error != null)
            Padding(
              padding: const EdgeInsets.all(12),
              child: Text('Error: ${state.error}',
                  style: const TextStyle(color: Colors.red)),
            ),
          Expanded(
            child: state.users.isEmpty
                ? const Center(child: Text('Tap "Load users" to start.'))
                : ListView.separated(
                    itemCount: state.users.length,
                    separatorBuilder: (_, __) => const Divider(height: 1),
                    itemBuilder: (BuildContext c, int i) {
                      final User u = state.users[i];
                      return ListTile(
                        leading: CircleAvatar(child: Text(u.name[0])),
                        title: Text(u.name),
                        subtitle: Text(u.email),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
