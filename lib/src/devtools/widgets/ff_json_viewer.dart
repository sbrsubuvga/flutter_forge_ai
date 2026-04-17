import 'dart:convert';

import 'package:flutter/material.dart';

import '../../utils/ff_clipboard_helper.dart';
import '../../utils/ff_pretty_printer.dart';

/// Renders any JSON-like value (Map/List/String/num/bool) as pretty,
/// monospace JSON with one-tap copy-to-clipboard.
class FFJsonViewer extends StatelessWidget {
  /// Creates the viewer.
  const FFJsonViewer({
    required this.value,
    this.title,
    this.scrollable = true,
    super.key,
  });

  /// Anything that can be passed to `jsonEncode`. Unsupported values fall back
  /// to their `toString()`.
  final Object? value;

  /// Optional leading title.
  final String? title;

  /// Whether the body scrolls. Disable when embedded in another scrollable.
  final bool scrollable;

  String get _pretty {
    if (value == null) return 'null';
    try {
      if (value is String) {
        return FFPrettyPrinter.json(jsonDecode(value as String));
      }
      return FFPrettyPrinter.json(value);
    } catch (_) {
      return value.toString();
    }
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final Widget body = SelectableText(
      _pretty,
      style: TextStyle(
        fontFamily: 'monospace',
        fontSize: 12.5,
        color: theme.colorScheme.onSurface,
        height: 1.4,
      ),
    );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        if (title != null)
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 8, 12, 4),
            child: Row(
              children: <Widget>[
                Expanded(
                  child: Text(
                    title!,
                    style: theme.textTheme.titleSmall,
                  ),
                ),
                IconButton(
                  tooltip: 'Copy',
                  icon: const Icon(Icons.copy, size: 18),
                  onPressed: () async {
                    final bool ok = await FFClipboardHelper.copy(_pretty);
                    if (!context.mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(ok ? 'Copied' : 'Clipboard unavailable'),
                        duration: const Duration(seconds: 2),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        Container(
          decoration: BoxDecoration(
            color: theme.colorScheme.surfaceContainerHighest
                .withValues(alpha: 0.6),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: theme.dividerColor),
          ),
          padding: const EdgeInsets.all(12),
          child: scrollable
              ? SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: body,
                )
              : body,
        ),
      ],
    );
  }
}
