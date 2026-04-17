import 'package:flutter/material.dart';

/// Small coloured chip displaying an HTTP status code.
class FFStatusCodeChip extends StatelessWidget {
  /// Creates the chip.
  const FFStatusCodeChip({required this.statusCode, super.key});

  /// HTTP status code. `null` renders a neutral "—" chip.
  final int? statusCode;

  /// Resolves the background colour for a status code family.
  static Color colorFor(int? code) {
    if (code == null) return Colors.grey;
    if (code >= 200 && code < 300) return Colors.green;
    if (code >= 300 && code < 400) return Colors.blue;
    if (code >= 400 && code < 500) return Colors.orange;
    if (code >= 500 && code < 600) return Colors.red;
    return Colors.black87;
  }

  @override
  Widget build(BuildContext context) {
    final Color bg = colorFor(statusCode);
    final String label = statusCode?.toString() ?? '—';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: bg.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: bg.withValues(alpha: 0.5), width: 1),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: bg,
          fontWeight: FontWeight.w600,
          fontSize: 11,
        ),
      ),
    );
  }
}
