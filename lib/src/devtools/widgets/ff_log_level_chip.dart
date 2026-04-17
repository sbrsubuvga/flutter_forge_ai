import 'package:flutter/material.dart';

import '../../core/logger/ff_log_level.dart';

/// Small chip showing a [FFLogLevel] label with its semantic colour.
class FFLogLevelChip extends StatelessWidget {
  /// Creates the chip.
  const FFLogLevelChip({required this.level, this.compact = false, super.key});

  /// Level to render.
  final FFLogLevel level;

  /// If true, shows only the short label (V/D/I/W/E/F).
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final Color color = level.color;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withValues(alpha: 0.5), width: 1),
      ),
      child: Text(
        compact ? level.shortLabel : level.label.toUpperCase(),
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.w600,
          fontSize: 11,
        ),
      ),
    );
  }
}
