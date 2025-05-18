import 'package:flutter/material.dart';
import 'package:personal_finance/app/app_widget.dart';

class DSSnackbar {
  static OverlayEntry? _currentOverlay;

  static void showSuccess(String message) {
    _showOverlay(message, backgroundColor: Colors.green[600]!);
  }

  static void showError(String message) {
    _showOverlay(message, backgroundColor: Colors.red[600]!);
  }

  static void _showOverlay(String message, {required Color backgroundColor}) {
    _currentOverlay?.remove();

    final overlay = OverlayEntry(
      builder:
          (context) => Positioned(
            bottom: 40,
            left: 16,
            right: 16,
            child: Material(
              color: Colors.transparent,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                decoration: BoxDecoration(
                  color: backgroundColor,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 10)],
                ),
                child: Text(
                  message,
                  style: const TextStyle(color: Colors.white),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ),
    );

    _currentOverlay = overlay;
    navigatorKey.currentState?.overlay?.insert(overlay);

    Future.delayed(const Duration(seconds: 3), () {
      overlay.remove();
      _currentOverlay = null;
    });
  }
}
