// lib/ui/showSuffix.dart
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ShowHideSuffix extends StatelessWidget {
  /// Whether the secret is currently visible.
  final bool isVisible;

  /// Tap handler to toggle visibility.
  final VoidCallback onTap;

  /// Optional custom labels (useful for localization).
  /// Defaults keep your existing "SHOW"/"HIDE" copy.
  final String? showLabel;
  final String? hideLabel;

  /// Optional text style override (keeps legacy look by default).
  final TextStyle? textStyle;

  /// If true, forces labels to uppercase (matches your current UI).
  final bool uppercase;

  const ShowHideSuffix({
    super.key,
    required this.isVisible,
    required this.onTap,
    this.showLabel,
    this.hideLabel,
    this.textStyle,
    this.uppercase = true,
  });

  @override
  Widget build(BuildContext context) {
    final String raw = isVisible ? (hideLabel ?? 'HIDE') : (showLabel ?? 'SHOW');
    final String label = uppercase ? raw.toUpperCase() : raw;

    // Keep your legacy look by default; allow theme overrides if provided.
    final TextStyle effectiveStyle = textStyle ??
        TextStyle(
          fontFamily: 'Montserrat',
          fontWeight: FontWeight.w600,
          fontSize: 14.sp,
          color: Colors.black,
        );

    return Semantics(
      button: true,
      label: isVisible ? 'Hide password' : 'Show password',
      enabled: true,
      child: SizedBox(
        width: 60.w, // identical width as before
        child: TextButton(
          onPressed: onTap,
          style: TextButton.styleFrom(
            padding: EdgeInsets.zero,
            minimumSize: Size.zero,
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            splashFactory: NoSplash.splashFactory,
            overlayColor: Colors.transparent, // keep no highlight
          ),
          child: Text(label, style: effectiveStyle),
        ),
      ),
    );
  }
}
