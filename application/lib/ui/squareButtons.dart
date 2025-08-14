import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../ui/theme.dart';

/// ---------------------------------------------------------------------------
///  GENERIC SQUARE (FULL‑WIDTH OR CUSTOM WIDTH) BUTTON
/// ---------------------------------------------------------------------------
class SquareButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final Color backgroundColor;
  final Color textColor;
  final double height;
  final double? width;               // null ⇒ full‑width
  final FontWeight fontWeight;
  final double fontSize;
  final EdgeInsetsGeometry? margin;
  final String fontFamily;

  const SquareButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.backgroundColor = AppTheme.navyBlue,
    this.textColor       = Colors.white,
    this.height          = 48.0,
    this.width,                         // optional
    this.fontWeight      = FontWeight.w600,
    this.fontSize        = 14.0,
    this.margin,
    this.fontFamily      = 'Montserrat',
  });

  @override
  Widget build(BuildContext context) {
    final button = SizedBox(
      width : (width ?? double.infinity).w,
      height: height.h,
      child : ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor,
          shape: const RoundedRectangleBorder(
          ),
        ),
        child: Text(
          text,
          style: TextStyle(
            fontFamily: fontFamily,
            fontSize  : fontSize.sp,
            fontWeight: fontWeight,
            color     : textColor,
          ),
        ),
      ),
    );

    return margin != null ? Container(margin: margin, child: button) : button;
  }
}

/// ---------------------------------------------------------------------------
///  COMPACT (FIXED‑WIDTH) SQUARE BUTTON – CENTRED AUTOMATICALLY
/// ---------------------------------------------------------------------------
class CompactSquareButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final double width;                // default 180
  final Color backgroundColor;
  final Color textColor;
  final String fontFamily;

  const CompactSquareButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.width           = 250.0,
    this.backgroundColor = AppTheme.gray,
    this.textColor       = Colors.white,
    this.fontFamily      = 'Montserrat',
  });

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.center,   // keeps it from stretching in a Column
      child: SizedBox(
        width : width.w,
        height: 44.h,
        child : ElevatedButton(
          onPressed: onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: backgroundColor,
            shape: const RoundedRectangleBorder(
            ),
          ),
          child: Text(
            text,
            style: TextStyle(
              fontFamily: fontFamily,
              fontSize  : 14.sp,
              fontWeight: FontWeight.w700,
              color     : textColor,
            ),
          ),
        ),
      ),
    );
  }
}
