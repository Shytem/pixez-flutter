import 'dart:async';
import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:pixez/main.dart';

/// Wraps [child] and handles ESC key on desktop platforms.
/// - Short press ESC: pop one route if possible.
/// - Long press ESC (~700ms): pop to root (home).
class KeyboardEscapeHandler extends StatefulWidget {
  final Widget child;
  const KeyboardEscapeHandler({super.key, required this.child});

  @override
  State<KeyboardEscapeHandler> createState() => _KeyboardEscapeHandlerState();
}

class _KeyboardEscapeHandlerState extends State<KeyboardEscapeHandler> {
  final FocusNode _focusNode = FocusNode(debugLabel: 'KeyboardEscapeFocus');
  Timer? _holdTimer;
  bool _longFired = false;

  bool get _isDesktop => Platform.isMacOS || Platform.isWindows || Platform.isLinux;

  @override
  void dispose() {
    _holdTimer?.cancel();
    _focusNode.dispose();
    super.dispose();
  }

  void _popOne() {
    final nav = appNavigatorKey.currentState;
    if (nav == null) return;
    if (nav.canPop()) nav.pop();
  }

  void _popToRoot() {
    final nav = appNavigatorKey.currentState;
    if (nav == null) return;
    nav.popUntil((route) => route.isFirst);
  }

  KeyEventResult _onKey(FocusNode node, RawKeyEvent event) {
    if (!_isDesktop) return KeyEventResult.ignored;
    // Handle ESC only.
    if (event.logicalKey != LogicalKeyboardKey.escape) {
      return KeyEventResult.ignored;
    }
    if (event is RawKeyDownEvent) {
      if (_holdTimer == null) {
        _longFired = false;
        _holdTimer = Timer(const Duration(milliseconds: 700), () {
          _longFired = true;
          _popToRoot();
        });
      }
      return KeyEventResult.handled;
    }
    if (event is RawKeyUpEvent) {
      final fired = _longFired;
      _holdTimer?.cancel();
      _holdTimer = null;
      _longFired = false;
      if (!fired) {
        _popOne();
      }
      return KeyEventResult.handled;
    }
    return KeyEventResult.ignored;
  }

  @override
  Widget build(BuildContext context) {
    if (!_isDesktop) return widget.child;
    return Focus(
      focusNode: _focusNode,
      autofocus: true,
      onKey: _onKey,
      child: widget.child,
    );
  }
}
