import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../utils/ff_pretty_printer.dart';
import 'ff_state_change_model.dart';
import 'ff_state_store.dart';

/// Riverpod [ProviderObserver] that feeds [FFStateStore].
///
/// Compatible with `flutter_riverpod ^2.5.x`.
///
/// Use by attaching to [ProviderScope.observers] at app startup:
/// ```dart
/// ProviderScope(
///   observers: [FFStateObserver()],
///   child: MyApp(),
/// );
/// ```
class FFStateObserver extends ProviderObserver {
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

  bool _allow(ProviderBase<Object?> provider) {
    if (_prefixes.isEmpty) return true;
    final String type = provider.runtimeType.toString();
    return _prefixes.any(type.startsWith);
  }

  String _name(ProviderBase<Object?> provider) =>
      provider.name ?? provider.runtimeType.toString();

  String _stringify(Object? value) =>
      FFPrettyPrinter.truncate(value?.toString() ?? 'null',
          maxLength: maxValueLength);

  @override
  void didAddProvider(
    ProviderBase<Object?> provider,
    Object? value,
    ProviderContainer container,
  ) {
    if (!_allow(provider)) return;
    _resolved?.add(
      FFStateChange(
        type: FFStateChangeType.added,
        providerName: _name(provider),
        providerType: provider.runtimeType.toString(),
        newValue: _stringify(value),
      ),
    );
  }

  @override
  void didUpdateProvider(
    ProviderBase<Object?> provider,
    Object? previousValue,
    Object? newValue,
    ProviderContainer container,
  ) {
    if (!_allow(provider)) return;
    _resolved?.add(
      FFStateChange(
        type: FFStateChangeType.updated,
        providerName: _name(provider),
        providerType: provider.runtimeType.toString(),
        previousValue: _stringify(previousValue),
        newValue: _stringify(newValue),
      ),
    );
  }

  @override
  void didDisposeProvider(
    ProviderBase<Object?> provider,
    ProviderContainer container,
  ) {
    if (!_allow(provider)) return;
    _resolved?.add(
      FFStateChange(
        type: FFStateChangeType.disposed,
        providerName: _name(provider),
        providerType: provider.runtimeType.toString(),
      ),
    );
  }

  @override
  void providerDidFail(
    ProviderBase<Object?> provider,
    Object error,
    StackTrace stackTrace,
    ProviderContainer container,
  ) {
    if (!_allow(provider)) return;
    _resolved?.add(
      FFStateChange(
        type: FFStateChangeType.failed,
        providerName: _name(provider),
        providerType: provider.runtimeType.toString(),
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

  /// The active store, set by FlutterForgeAI.init().
  static FFStateStore? _store;

  /// Called by the SDK once the store is ready.
  // ignore: use_setters_to_change_properties
  static void register(FFStateStore store) => _store = store;

  /// Called by [FlutterForgeAI.reset].
  static void clear() => _store = null;

  /// Currently-active store, if any.
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
