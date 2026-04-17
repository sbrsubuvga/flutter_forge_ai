import 'package:flutter/material.dart';

/// Purple FAB that opens the FlutterForge DevTools dashboard.
class FFFloatingButton extends StatelessWidget {
  /// Creates the button.
  const FFFloatingButton({
    required this.onPressed,
    this.color = const Color(0xFF6366F1),
    super.key,
  });

  /// Tap handler — normally wired to `FlutterForgeAI.openDashboard()`.
  final VoidCallback onPressed;

  /// Background colour.
  final Color color;

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      heroTag: 'ff_devtools_fab',
      tooltip: 'FlutterForge DevTools',
      backgroundColor: color,
      foregroundColor: Colors.white,
      onPressed: onPressed,
      child: const Icon(Icons.developer_mode),
    );
  }
}
