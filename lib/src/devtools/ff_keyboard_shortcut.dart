import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

/// Global Alt+F12 hotkey wrapper.
///
/// Wraps [child] with a [Focus] + [Shortcuts] + [Actions] trio so the
/// shortcut works anywhere inside the subtree on desktop platforms.
class FFKeyboardShortcut extends StatelessWidget {
  /// Creates the shortcut wrapper.
  const FFKeyboardShortcut({
    required this.onTriggered,
    required this.child,
    this.enabled = true,
    super.key,
  });

  /// Callback fired when the shortcut is pressed.
  final VoidCallback onTriggered;

  /// Whether the shortcut is live.
  final bool enabled;

  /// Subtree that should receive the shortcut.
  final Widget child;

  @override
  Widget build(BuildContext context) {
    if (!enabled) return child;
    return Shortcuts(
      shortcuts: const <ShortcutActivator, Intent>{
        SingleActivator(LogicalKeyboardKey.f12, alt: true):
            _OpenDevToolsIntent(),
      },
      child: Actions(
        actions: <Type, Action<Intent>>{
          _OpenDevToolsIntent: CallbackAction<_OpenDevToolsIntent>(
            onInvoke: (_) {
              onTriggered();
              return null;
            },
          ),
        },
        child: Focus(child: child),
      ),
    );
  }
}

class _OpenDevToolsIntent extends Intent {
  const _OpenDevToolsIntent();
}
