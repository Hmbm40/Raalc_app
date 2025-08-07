import 'package:application/ui/theme.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:application/ui/spacing.dart'; // make sure this path is correct

class NotificationTextBox extends StatelessWidget {
  final String message;
  final Color borderColor;
  final Color backgroundColor;
  final TextStyle? textStyle;

  const NotificationTextBox({
    super.key,
    required this.message,
    this.borderColor = AppTheme.gray,
    this.backgroundColor = AppTheme.ivoryWhite,
    this.textStyle,
  });

  @override
  Widget build(BuildContext context) {
    final textScale = MediaQuery.textScaleFactorOf(context);

    return Container(
      width: double.infinity,
      constraints: BoxConstraints(minHeight: 80.h),
      padding: EdgeInsets.symmetric(
        horizontal: AppSpacing.largeHorizontal, // ✅ Match form padding
        vertical: AppSpacing.regularVertical, // ✅ Comfortable vertical padding
      ),
      decoration: BoxDecoration(
        color: backgroundColor,
        border: Border.all(color: borderColor, width: 2),
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
