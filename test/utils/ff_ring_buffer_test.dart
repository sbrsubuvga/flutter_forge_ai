import 'package:flutter_test/flutter_test.dart';
import 'package:flutterforge_ai/src/utils/ff_ring_buffer.dart';

void main() {
  group('FFRingBuffer', () {
    test('throws on non-positive maxSize', () {
      expect(() => FFRingBuffer<int>(maxSize: 0), throwsA(anything));
      expect(() => FFRingBuffer<int>(maxSize: -1), throwsA(anything));
    });

    test('retains items up to maxSize (oldest first)', () {
      final FFRingBuffer<int> b = FFRingBuffer<int>(maxSize: 3);
      b
        ..add(1)
        ..add(2)
        ..add(3);
      expect(b.items, <int>[1, 2, 3]);
      expect(b.length, 3);
    });

    test('evicts oldest when full', () {
      final FFRingBuffer<int> b = FFRingBuffer<int>(maxSize: 3);
      b
        ..add(1)
        ..add(2)
        ..add(3)
        ..add(4);
      expect(b.items, <int>[2, 3, 4]);
      expect(b.latest, 4);
      expect(b.oldest, 2);
    });

    test('reversed view returns newest first', () {
      final FFRingBuffer<int> b = FFRingBuffer<int>(maxSize: 3);
      b
        ..add(1)
        ..add(2)
        ..add(3);
      expect(b.reversed, <int>[3, 2, 1]);
    });

    test('clear empties the buffer and notifies stream', () async {
      final FFRingBuffer<int> b = FFRingBuffer<int>(maxSize: 3);
      b
        ..add(1)
        ..add(2);
      final Future<void> cleared = b.clearStream.first;
      b.clear();
      expect(b.length, 0);
      expect(b.items, <int>[]);
      await cleared;
    });

    test('stream emits added items', () async {
      final FFRingBuffer<int> b = FFRingBuffer<int>(maxSize: 3);
      final Future<int> next = b.stream.first;
      b.add(42);
      expect(await next, 42);
    });

    test('dispose closes streams', () async {
      final FFRingBuffer<int> b = FFRingBuffer<int>(maxSize: 3);
      await b.dispose();
      // add after dispose is a no-op but doesn't throw
      expect(() => b.add(1), returnsNormally);
    });
  });
}
