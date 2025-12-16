// lib/utils/fullscreen_helper.dart

import 'package:flutter/foundation.dart';
import 'package:window_manager/window_manager.dart';

class FullscreenHelper {
  static bool _isFullscreen = false;
  static final List<VoidCallback> _listeners = [];

  static bool get _supportsWindowManager {
    if (kIsWeb) {
      return false;
    }
    return defaultTargetPlatform == TargetPlatform.windows ||
        defaultTargetPlatform == TargetPlatform.linux ||
        defaultTargetPlatform == TargetPlatform.macOS;
  }

  static bool get isFullscreen => _isFullscreen;

  static void addListener(VoidCallback listener) {
    _listeners.add(listener);
  }

  static void removeListener(VoidCallback listener) {
    _listeners.remove(listener);
  }

  static void _notifyListeners() {
    for (var listener in _listeners) {
      listener();
    }
  }

  static Future<void> toggleFullscreen() async {
    if (_isFullscreen) {
      await exitFullscreen();
    } else {
      await enterFullscreen();
    }
  }

  static Future<void> enterFullscreen() async {
    if (_supportsWindowManager) {
      await windowManager.setFullScreen(true);
    }
    _isFullscreen = true;
    _notifyListeners();
  }

  static Future<void> exitFullscreen() async {
    if (_supportsWindowManager) {
      await windowManager.setFullScreen(false);
    }
    _isFullscreen = false;
    _notifyListeners();
  }
}
