import 'dart:async';

/// Minimal stream merger — avoids an extra dependency on `async`.
class FFStreamMerger {
  FFStreamMerger._();

  /// Merges a list of streams into a single broadcast-style stream.
  ///
  /// Subscriptions are cancelled when the returned stream is no longer listened
  /// to. Errors from any source propagate.
  static Stream<T> merge<T>(List<Stream<T>> streams) async* {
    final StreamController<T> out = StreamController<T>();
    final List<StreamSubscription<T>> subs = <StreamSubscription<T>>[];
    for (final Stream<T> s in streams) {
      subs.add(s.listen(out.add, onError: out.addError));
    }
    try {
      yield* out.stream;
    } finally {
      for (final StreamSubscription<T> sub in subs) {
        await sub.cancel();
      }
      await out.close();
    }
  }
}
