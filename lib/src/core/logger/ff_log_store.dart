import '../../utils/ff_ring_buffer.dart';
import 'ff_log_level.dart';
import 'ff_log_model.dart';

/// Ring-buffer backed store of captured [FFLogEntry] instances.
///
/// A single instance is created and owned by [FFLogger].
class FFLogStore {
  /// Creates a store retaining [maxSize] entries.
  FFLogStore({required int maxSize})
      : _buffer = FFRingBuffer<FFLogEntry>(maxSize: maxSize);

  final FFRingBuffer<FFLogEntry> _buffer;

  /// Pushes a new entry into the store.
  void add(FFLogEntry entry) => _buffer.add(entry);

  /// All entries, oldest first.
  List<FFLogEntry> getAll() => _buffer.items;

  /// All entries whose level equals [level].
  List<FFLogEntry> getByLevel(FFLogLevel level) =>
      _buffer.where((FFLogEntry e) => e.level == level);

  /// Entries whose level is at least `FFLogLevel.error`.
  List<FFLogEntry> getErrors() =>
      _buffer.where((FFLogEntry e) => e.level.isAtLeast(FFLogLevel.error));

  /// Entries whose level is at least `FFLogLevel.warning`.
  List<FFLogEntry> getWarnings() =>
      _buffer.where((FFLogEntry e) => e.level == FFLogLevel.warning);

  /// Case-insensitive search over message, tag, and error text.
  List<FFLogEntry> search(String query) {
    if (query.isEmpty) return getAll();
    final String q = query.toLowerCase();
    return _buffer.where((FFLogEntry e) =>
        e.message.toLowerCase().contains(q) ||
        (e.tag?.toLowerCase().contains(q) ?? false) ||
        (e.error?.toString().toLowerCase().contains(q) ?? false));
  }

  /// Number of retained entries.
  int get length => _buffer.length;

  /// Stream fired on every new entry.
  Stream<FFLogEntry> get stream => _buffer.stream;

  /// Stream fired whenever [clear] is called.
  Stream<void> get clearStream => _buffer.clearStream;

  /// Removes all entries.
  void clear() => _buffer.clear();

  /// Releases stream resources.
  Future<void> dispose() => _buffer.dispose();
}
