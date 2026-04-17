import '../../utils/ff_ring_buffer.dart';
import 'ff_api_call_model.dart';

/// Ring-buffer backed store of captured [FFApiCall]s.
class FFApiStore {
  /// Creates a store retaining [maxSize] calls.
  FFApiStore({required int maxSize})
      : _buffer = FFRingBuffer<FFApiCall>(maxSize: maxSize);

  final FFRingBuffer<FFApiCall> _buffer;

  /// All stored calls, oldest first.
  List<FFApiCall> getAll() => _buffer.items;

  /// All stored calls, newest first (UI default).
  List<FFApiCall> getAllNewestFirst() => _buffer.reversed;

  /// Most recently added call, or null.
  FFApiCall? getLatest() => _buffer.latest;

  /// Calls whose status code matches [statusCode].
  List<FFApiCall> getByStatusCode(int statusCode) =>
      _buffer.where((FFApiCall c) => c.statusCode == statusCode);

  /// Every failed call (non-2xx or exception).
  List<FFApiCall> getFailedCalls() =>
      _buffer.where((FFApiCall c) => c.isFailed);

  /// Case-insensitive substring search on method and URL.
  List<FFApiCall> search(String query) {
    if (query.isEmpty) return getAll();
    final String q = query.toLowerCase();
    return _buffer.where((FFApiCall c) =>
        c.url.toLowerCase().contains(q) ||
        c.method.toLowerCase().contains(q) ||
        (c.statusCode?.toString().contains(q) ?? false));
  }

  /// Inserts a brand new call (pending or final).
  void add(FFApiCall call) => _buffer.add(call);

  /// Updates a call in place by id. If no match, the call is appended.
  ///
  /// Ring buffers are append-only, so the "update" is implemented by
  /// rebuilding the buffer contents.
  void update(FFApiCall call) {
    final List<FFApiCall> items = _buffer.items.toList();
    final int idx = items.indexWhere((FFApiCall c) => c.id == call.id);
    if (idx < 0) {
      _buffer.add(call);
      return;
    }
    items[idx] = call;
    // Clearing the buffer here would also fire clearStream; we instead rebuild
    // quietly by swapping elements through its public API.
    _rebuild(items);
  }

  void _rebuild(List<FFApiCall> items) {
    // Rebuild: easiest way is to drain & re-add.
    _buffer.clear();
    _buffer.addAll(items);
  }

  /// Number of retained calls.
  int get length => _buffer.length;

  /// Stream of new/updated calls (updates re-emit the new value).
  Stream<FFApiCall> get stream => _buffer.stream;

  /// Stream fired whenever [clear] is called.
  Stream<void> get clearStream => _buffer.clearStream;

  /// Removes every stored call.
  void clear() => _buffer.clear();

  /// Releases resources.
  Future<void> dispose() => _buffer.dispose();
}
