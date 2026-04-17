import 'package:flutter/material.dart';

/// Green 🤖 FAB that triggers the AI Debug Snapshot flow.
class FFAiDebugButton extends StatelessWidget {
  /// Creates the button.
  const FFAiDebugButton({
    required this.onPressed,
    this.color = const Color(0xFF10B981),
    super.key,
  });

  /// Tap handler — normally opens the snapshot-preview screen.
  final VoidCallback onPressed;

  /// Background colour.
  final Color color;

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      heroTag: 'ff_ai_fab',
      tooltip: 'Generate AI Debug Snapshot',
      backgroundColor: color,
      foregroundColor: Colors.white,
      onPressed: onPressed,
      child: const Text('🤖', style: TextStyle(fontSize: 24)),
    );
  }
}
