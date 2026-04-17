import 'dart:async';
import 'dart:collection';

/// A generic fixed-capacity ring buffer that automatically drops the
/// oldest item when a new item is added past the capacity.
///
/// Exposes a broadcast [stream] so UI layers can react to inserts,
/// and a [clearStream] for full-wipe notifications.
class FFRingBuffer<T> {
  /// Creates a new buffer with the given [maxSize].
  ///
  /// [maxSize] must be positive; otherwise an [ArgumentError] is thrown.
  FFRingBuffer({required this.maxSize})
      : assert(maxSize > 0, 'maxSize must be > 0'),
        _queue = Queue<T>(),
        _controller = StreamController<T>.broadcast(),
        _clearController = StreamController<void>.broadcast() {
    if (maxSize <= 0) {
      throw ArgumentError.value(maxSize, 'maxSize', 'must be > 0');
    }
  }

  /// Maximum number of items retained.
  final int maxSize;

  final Queue<T> _queue;
  final StreamController<T> _controller;
  final StreamController<void> _clearController;

  /// Unmodifiable snapshot of the current buffer, oldest first.
  List<T> get items => List<T>.unmodifiable(_queue);

  /// Unmodifiable snapshot, newest first. Useful for "latest" UI lists.
  List<T> get reversed => List<T>.unmodifiable(_queue.toList().reversed);

  /// Current item count.
  int get length => _queue.length;

  /// Whether the buffer contains no items.
  bool get isEmpty => _queue.isEmpty;

  /// Whether the buffer contains at least one item.
  bool get isNotEmpty => _queue.isNotEmpty;

  /// Broadcast stream of items added to the buffer.
  Stream<T> get stream => _controller.stream;

  /// Broadcast stream fired once every time [clear] is called.
  Stream<void> get clearStream => _clearController.stream;

  /// The most recently added item, or null if the buffer is empty.
  T? get latest => _queue.isEmpty ? null : _queue.last;

  /// The oldest item currently retained, or null if empty.
  T? get oldest => _queue.isEmpty ? null : _queue.first;

  /// Adds [item] to the buffer, evicting the oldest entry if full.
  void add(T item) {
    if (_queue.length >= maxSize) {
      _queue.removeFirst();
    }
    _queue.addLast(item);
    if (!_controller.isClosed) {
      _controller.add(item);
    }
  }

  /// Adds all [items], evicting as needed.
  void addAll(Iterable<T> items) {
    for (final T item in items) {
      add(item);
    }
  }

  /// Removes all items and notifies [clearStream] listeners.
  void clear() {
    _queue.clear();
    if (!_clearController.isClosed) {
      _clearController.add(null);
    }
  }

  /// Returns items where [test] is true.
  List<T> where(bool Function(T) test) =>
      _queue.where(test).toList(growable: false);

  /// Closes both controllers. After disposal, [add] and [clear] become no-ops.
  Future<void> dispose() async {
    _queue.clear();
    await _controller.close();
    await _clearController.close();
  }
}
