import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../utils/ff_pretty_printer.dart';
import 'ff_state_change_model.dart';
import 'ff_state_store.dart';

/// Riverpod [ProviderObserver] that feeds [FFStateStore].
///
/// Uses the Riverpod 3.x observer API (`ProviderObserverContext`). Older
/// Riverpod 2.x apps should continue to work against flutterforge_ai
/// `0.2.x` which pinned `^2.5.1` — see the v0.3.0 CHANGELOG for the
/// upgrade path.
///
/// ```dart
/// ProviderScope(
///   observers: [FFStateObserver()],
///   child: MyApp(),
/// );
/// ```
final class FFStateObserver extends ProviderObserver {
  /// Creates the observer.
  ///
  /// * [store] — where events are sent. Defaults to the global store owned
  ///   by the SDK (lazy-looked-up each time to avoid ordering issues).
  /// * [trackingPrefixes] — if non-empty, only providers whose runtimeType
  ///   string starts with one of the prefixes are reported.
  /// * [maxValueLength] — values are truncated to this length.
  FFStateObserver({
    FFStateStore? store,
    List<String>? trackingPrefixes,
    this.maxValueLength = 500,
  })  : _store = store,
        _prefixes = trackingPrefixes ?? const <String>[];

  final FFStateStore? _store;
  final List<String> _prefixes;

  /// Maximum length of stringified values stored.
  final int maxValueLength;

  /// Test hook allowing injection of a store after construction.
  FFStateStore? _overrideStore;

  /// Overrides the resolved store (tests only).
  set storeForTesting(FFStateStore s) => _overrideStore = s;

  FFStateStore? get _resolved =>
      _overrideStore ?? _store ?? _FFStateObserverStoreResolver.resolve();

  bool _allow(ProviderObserverContext context) {
    if (_prefixes.isEmpty) return true;
    final String type = context.provider.runtimeType.toString();
    return _prefixes.any(type.startsWith);
  }

  String _name(ProviderObserverContext context) =>
      context.provider.name ?? context.provider.runtimeType.toString();

  String _type(ProviderObserverContext context) =>
      context.provider.runtimeType.toString();

  String _stringify(Object? value) =>
      FFPrettyPrinter.truncate(value?.toString() ?? 'null',
          maxLength: maxValueLength);

  @override
  void didAddProvider(ProviderObserverContext context, Object? value) {
    if (!_allow(context)) return;
    _resolved?.add(
      FFStateChange(
        type: FFStateChangeType.added,
        providerName: _name(context),
        providerType: _type(context),
        newValue: _stringify(value),
      ),
    );
  }

  @override
  void didUpdateProvider(
    ProviderObserverContext context,
    Object? previousValue,
    Object? newValue,
  ) {
    if (!_allow(context)) return;
    _resolved?.add(
      FFStateChange(
        type: FFStateChangeType.updated,
        providerName: _name(context),
        providerType: _type(context),
        previousValue: _stringify(previousValue),
        newValue: _stringify(newValue),
      ),
    );
  }

  @override
  void didDisposeProvider(ProviderObserverContext context) {
    if (!_allow(context)) return;
    _resolved?.add(
      FFStateChange(
        type: FFStateChangeType.disposed,
        providerName: _name(context),
        providerType: _type(context),
      ),
    );
  }

  @override
  void providerDidFail(
    ProviderObserverContext context,
    Object error,
    StackTrace stackTrace,
  ) {
    if (!_allow(context)) return;
    _resolved?.add(
      FFStateChange(
        type: FFStateChangeType.failed,
        providerName: _name(context),
        providerType: _type(context),
        error: error,
        stackTrace: stackTrace,
      ),
    );
  }
}

/// Lazy resolver so observers created before `FlutterForgeAI.init()` still
/// capture events once the SDK is ready.
class _FFStateObserverStoreResolver {
  _FFStateObserverStoreResolver._();

  static FFStateStore? _store;

  static void register(FFStateStore store) => _store = store;

  static void clear() => _store = null;

  static FFStateStore? resolve() => _store;
}

/// Internal binding point used by `FlutterForgeAI.init()` — not part of the
/// public API.
// ignore: public_member_api_docs
void ffStateObserverRegisterStore(FFStateStore store) =>
    _FFStateObserverStoreResolver.register(store);

/// Internal reset hook.
// ignore: public_member_api_docs
void ffStateObserverClearStore() => _FFStateObserverStoreResolver.clear();
