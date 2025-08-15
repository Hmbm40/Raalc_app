// lib/ui/notificationTextBox.dart
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:application/ui/theme.dart';    // for context.palette / context.t (ThemeX)
import 'package:application/ui/spacing.dart';  // for Space / Insets

class NotificationTextBox extends StatelessWidget {
  final String message;

  /// Optional overrides. If null, we use themed defaults:
  /// - borderColor: context.palette.lightGray
  /// - backgroundColor: Palette.surface (white in light theme)
  final Color? borderColor;
  final Color? backgroundColor;

  /// Optional style override; default keeps your previous look:
  /// Montserrat, 12.sp, w600, black87.
  final TextStyle? textStyle;

  const NotificationTextBox({
    super.key,
    required this.message,
    this.borderColor,
    this.backgroundColor,
    this.textStyle,
  });

  @override
  Widget build(BuildContext context) {
    final textScale = MediaQuery.textScaleFactorOf(context);
    final palette = context.palette; // from ThemeX extension
    final Color effectiveBorder = borderColor ?? palette.lightGray;
    final Color effectiveBg = backgroundColor ?? palette.surface;

    return Container(
      width: double.infinity,
      constraints: BoxConstraints(minHeight: 80.h),
      // OLD: AppSpacing.largeHorizontal (≈32.w)  -> Space.xxl
      //      AppSpacing.regularVertical  (≈16.h) -> Space.lg
      padding: Insets.symmetric(h: Space.xxl, v: Space.lg),
      decoration: BoxDecoration(
        color: effectiveBg,
        border: Border.all(color: effectiveBorder, width: 2),
        // Keep exact previous shape (no rounding):
        borderRadius: BorderRadius.zero,
      ),
      child: Text(
        message,
        style: textStyle ??
            TextStyle(
              fontSize: 12.sp * textScale,
              fontFamily: 'Montserrat',
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
      ),
    );
  }
}
