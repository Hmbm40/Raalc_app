// lib/ui/squareButtons.dart
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// ---------------------------------------------------------------------------
///  BASE SQUARE BUTTON (SHARED LOGIC)
/// ---------------------------------------------------------------------------
class _BaseSquareButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;

  /// If null, falls back to themed colors in build().
  final Color? backgroundColor;
  final Color? textColor;

  final double height;     // logical; scaled with .h
  final double width;      // logical; scaled with .w
  final FontWeight fontWeight;
  final double fontSize;   // logical; scaled with .sp
  final String fontFamily;

  const _BaseSquareButton({
    required this.text,
    required this.onPressed,
    required this.backgroundColor,
    required this.textColor,
    required this.height,
    required this.width,
    required this.fontWeight,
    required this.fontSize,
    required this.fontFamily,
  });

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    final cs = t.colorScheme;
    final textScale = MediaQuery.textScaleFactorOf(context);

    // Themed defaults (close to old look). Call sites can override for exact legacy colors.
    final Color bg = backgroundColor ?? cs.primary;
    final Color fg = textColor ?? cs.onPrimary;

    return SizedBox(
      width: width.w,
      height: height.h,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: bg,
          foregroundColor: fg,
          splashFactory: NoSplash.splashFactory, // consistent with your other buttons
          shape: const RoundedRectangleBorder(), // square corners as before
        ),
        child: Text(
          text,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontFamily: fontFamily,
            fontSize: fontSize.sp * textScale,
            fontWeight: fontWeight,
            color: fg, // ensure text color matches foreground
          ),
        ),
      ),
    );
  }
}

/// ---------------------------------------------------------------------------
///  FULL-WIDTH OR CUSTOM WIDTH BUTTON
/// ---------------------------------------------------------------------------
class SquareButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;

  /// Pass to force exact legacy palette; otherwise theme colors are used.
  final Color? backgroundColor;
  final Color? textColor;

  final double height;
  final double? width; // null = full width
  final FontWeight fontWeight;
  final double fontSize;
  final EdgeInsetsGeometry? margin;
  final String fontFamily;

  const SquareButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.backgroundColor,                // (was AppTheme.navyBlue)
    this.textColor,                      // (was Colors.white)
    this.height = 48.0,
    this.width,
    this.fontWeight = FontWeight.w600,
    this.fontSize = 14.0,
    this.margin,
    this.fontFamily = 'Montserrat',
  });

  @override
  Widget build(BuildContext context) {
    final button = _BaseSquareButton(
      text: text,
      onPressed: onPressed,
      backgroundColor: backgroundColor,
      textColor: textColor,
      height: height,
      width: width ?? double.infinity,
      fontWeight: fontWeight,
      fontSize: fontSize,
      fontFamily: fontFamily,
    );

    return margin != null ? Container(margin: margin, child: button) : button;
  }
}

/// ---------------------------------------------------------------------------
///  COMPACT FIXED-WIDTH BUTTON (CENTERED)
/// ---------------------------------------------------------------------------
class CompactSquareButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final double width; // default 250

  /// Pass to force exact legacy palette; otherwise themed secondary is used.
  final Color? backgroundColor;
  final Color? textColor;

  final String fontFamily;

  const CompactSquareButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.width = 250.0,
    this.backgroundColor,               // (was AppTheme.gray)
    this.textColor,                     // (was Colors.white)
    this.fontFamily = 'Montserrat',
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    // Compact variant defaults to a softer tone (secondary) if not provided.
    final Color? bg = backgroundColor ?? cs.secondary;
    final Color? fg = textColor ?? cs.onSecondary;

    return Align(
      alignment: Alignment.center,
      child: _BaseSquareButton(
        text: text,
        onPressed: onPressed,
        backgroundColor: bg,
        textColor: fg,
        height: 44,
        width: width,
        fontWeight: FontWeight.w700,
        fontSize: 14,
        fontFamily: fontFamily,
      ),
    );
    }
}
