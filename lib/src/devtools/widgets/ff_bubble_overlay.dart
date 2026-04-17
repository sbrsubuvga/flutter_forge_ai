import 'package:flutter/material.dart';

/// Draggable floating bubble that stays pinned inside the screen bounds
/// (like Alice's chat-head style trigger).
///
/// The child receives taps normally — drag state is independent and never
/// consumes tap gestures.
class FFBubbleOverlay extends StatefulWidget {
  /// Creates a bubble.
  const FFBubbleOverlay({
    required this.child,
    this.initialAlignment = Alignment.bottomLeft,
    this.margin = const EdgeInsets.all(16),
    super.key,
  });

  /// The bubble content (typically a FAB).
  final Widget child;

  /// Initial corner alignment before the user drags.
  final Alignment initialAlignment;

  /// Safe-area margin.
  final EdgeInsets margin;

  @override
  State<FFBubbleOverlay> createState() => _FFBubbleOverlayState();
}

class _FFBubbleOverlayState extends State<FFBubbleOverlay> {
  Offset? _position;
  Size _bubbleSize = const Size(56, 56);

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (BuildContext ctx, BoxConstraints c) {
      final double w = c.maxWidth, h = c.maxHeight;
      _position ??= _initialPosition(w, h);
      final Offset p = _clamp(_position!, w, h);
      return Stack(
        children: <Widget>[
          Positioned(
            left: p.dx,
            top: p.dy,
            child: _BubbleMeasurement(
              onSize: (Size s) {
                if (_bubbleSize != s) {
                  _bubbleSize = s;
                }
              },
              child: GestureDetector(
                behavior: HitTestBehavior.translucent,
                onPanUpdate: (DragUpdateDetails d) {
                  setState(() {
                    _position = (_position ?? Offset.zero) + d.delta;
                  });
                },
                child: widget.child,
              ),
            ),
          ),
        ],
      );
    });
  }

  Offset _initialPosition(double w, double h) {
    final double x = widget.initialAlignment.x < 0
        ? widget.margin.left
        : w - _bubbleSize.width - widget.margin.right;
    final double y = widget.initialAlignment.y < 0
        ? widget.margin.top
        : h - _bubbleSize.height - widget.margin.bottom;
    return Offset(x, y);
  }

  Offset _clamp(Offset raw, double w, double h) {
    final double minX = widget.margin.left;
    final double maxX = w - _bubbleSize.width - widget.margin.right;
    final double minY = widget.margin.top;
    final double maxY = h - _bubbleSize.height - widget.margin.bottom;
    return Offset(
      raw.dx.clamp(minX, maxX < minX ? minX : maxX),
      raw.dy.clamp(minY, maxY < minY ? minY : maxY),
    );
  }
}

class _BubbleMeasurement extends StatelessWidget {
  const _BubbleMeasurement({required this.child, required this.onSize});

  final Widget child;
  final ValueChanged<Size> onSize;

  @override
  Widget build(BuildContext context) {
    return NotificationListener<SizeChangedLayoutNotification>(
      onNotification: (_) {
        final RenderBox? box = context.findRenderObject() as RenderBox?;
        if (box != null && box.hasSize) onSize(box.size);
        return false;
      },
      child: SizeChangedLayoutNotifier(child: child),
    );
  }
}
