import 'package:flutter/material.dart';

import '../config/ff_config.dart';
import '../flutterforge_core.dart';
import '../utils/ff_platform_checker.dart';
import 'ff_dev_dashboard.dart';
import 'ff_keyboard_shortcut.dart';
import 'ff_shake_detector.dart';
import 'screens/snapshot_preview_screen.dart';
import 'widgets/ff_ai_debug_button.dart';
import 'widgets/ff_bubble_overlay.dart';
import 'widgets/ff_floating_button.dart';

/// Wraps the application root with:
///   * a draggable devtools bubble (bottom-left)
///   * a draggable AI-debug bubble (bottom-right)
///   * a shake-to-open detector on mobile
///   * an Alt+F12 hotkey on desktop
///
/// In release mode or when [FFConfig.shouldShowDevTools] is false, this
/// widget renders only [child] and attaches nothing.
class FFDevWrapper extends StatefulWidget {
  /// Creates the wrapper.
  const FFDevWrapper({required this.child, super.key});

  /// The application subtree.
  final Widget child;

  @override
  State<FFDevWrapper> createState() => _FFDevWrapperState();
}

class _FFDevWrapperState extends State<FFDevWrapper> {
  FFShakeDetector? _shake;

  @override
  void initState() {
    super.initState();
    final bool active = FlutterForgeAI.isInitialized &&
        FlutterForgeAI.config.shouldShowDevTools;
    if (!active) return;
    final FFConfig cfg = FlutterForgeAI.config;

    if (cfg.enableShakeToOpen && FFPlatformChecker.supportsShake) {
      _shake = FFShakeDetector(
        onShake: _openDashboard,
        threshold: cfg.shakeThreshold,
      )..start();
    }
  }

  @override
  void dispose() {
    _shake?.stop();
    super.dispose();
  }

  void _openDashboard() {
    final NavigatorState? nav = _rootNavigator();
    if (nav == null) return;
    nav.push<void>(
      MaterialPageRoute<void>(
        builder: (_) => FFDevDashboard(
          config: FlutterForgeAI.config,
          stateStore: FlutterForgeAI.stateStore,
        ),
      ),
    );
  }

  void _openSnapshot() {
    final NavigatorState? nav = _rootNavigator();
    if (nav == null) return;
    nav.push<void>(
      MaterialPageRoute<void>(
        builder: (_) => const SnapshotPreviewScreen(),
      ),
    );
  }

  NavigatorState? _rootNavigator() {
    try {
      return Navigator.maybeOf(context, rootNavigator: true);
    } catch (_) {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool active = FlutterForgeAI.isInitialized &&
        FlutterForgeAI.config.shouldShowDevTools;
    if (!active) return widget.child;

    final FFConfig cfg = FlutterForgeAI.config;

    Widget body = widget.child;

    if (cfg.enableKeyboardShortcut &&
        FFPlatformChecker.supportsKeyboardShortcut) {
      body = FFKeyboardShortcut(
        onTriggered: _openDashboard,
        child: body,
      );
    }

    // The overlay renders above the user's Navigator, so we provide a
    // complete set of ancestors (Directionality, MediaQuery, Overlay,
    // Material) that descendants (FABs, Tooltips, etc.) expect.
    return Stack(
      children: <Widget>[
        body,
        Positioned.fill(
          child: Directionality(
            textDirection: TextDirection.ltr,
            child: MediaQuery(
              data: MediaQueryData.fromView(View.of(context)),
              child: Overlay(
                initialEntries: <OverlayEntry>[
                  OverlayEntry(
                    builder: (BuildContext _) => Material(
                      type: MaterialType.transparency,
                      child: Stack(
                        children: <Widget>[
                          FFBubbleOverlay(
                            initialAlignment: Alignment.bottomLeft,
                            child: FFFloatingButton(
                              color: cfg.primaryColor,
                              onPressed: _openDashboard,
                            ),
                          ),
                          if (cfg.enableAiDebugButton)
                            FFBubbleOverlay(
                              initialAlignment: Alignment.bottomRight,
                              child: FFAiDebugButton(onPressed: _openSnapshot),
                            ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
