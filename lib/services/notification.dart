import 'package:flutter/material.dart';
import 'package:overlay_support/overlay_support.dart';

class NotificationDropdown {
  /// Shows a dropdown notification at top.
  static void show({
    required BuildContext context,
    required Widget content,
    Duration duration = const Duration(seconds: 3),
  }) {
    showOverlayNotification(
      (context) {
        return SafeArea(
          child: Card(
            elevation: 2,
            margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: content,
            ),
          ),
        );
      },
      duration: duration,
    );
  }
}
