import '../../utils/ff_ring_buffer.dart';
import 'ff_state_change_model.dart';

/// Ring-buffer backed store of captured [FFStateChange] events.
class FFStateStore {
  /// Creates a store retaining [maxSize] entries.
  FFStateStore({required int maxSize})
      : _buffer = FFRingBuffer<FFStateChange>(maxSize: maxSize),
        _current = <String, FFStateChange>{};

  final FFRingBuffer<FFStateChange> _buffer;
  final Map<String, FFStateChange> _current;

  /// Adds an event.
  void add(FFStateChange change) {
    _buffer.add(change);
    if (change.type == FFStateChangeType.disposed) {
      _current.remove(change.providerName);
    } else {
      _current[change.providerName] = change;
    }
  }

  /// Snapshot of all captured changes (oldest first).
  List<FFStateChange> getAll() => _buffer.items;

  /// Snapshot newest-first for UI.
  List<FFStateChange> getAllNewestFirst() => _buffer.reversed;

  /// All events for [providerName].
  List<FFStateChange> getHistory(String providerName) =>
      _buffer.where((FFStateChange c) => c.providerName == providerName);

  /// Most recent value per currently-live provider.
  Map<String, FFStateChange> get activeProviders =>
      Map<String, FFStateChange>.unmodifiable(_current);

  /// Case-insensitive search over provider name.
  List<FFStateChange> search(String query) {
    if (query.isEmpty) return getAll();
    final String q = query.toLowerCase();
    return _buffer.where((FFStateChange c) =>
        c.providerName.toLowerCase().contains(q) ||
        c.providerType.toLowerCase().contains(q));
  }

  /// Stream fired on every new event.
  Stream<FFStateChange> get stream => _buffer.stream;

  /// Stream fired whenever [clear] is called.
  Stream<void> get clearStream => _buffer.clearStream;

  /// Number of retained events.
  int get length => _buffer.length;

  /// Removes every stored event.
  void clear() {
    _buffer.clear();
    _current.clear();
  }

  /// Releases resources.
  Future<void> dispose() => _buffer.dispose();
}
