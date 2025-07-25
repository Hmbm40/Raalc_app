import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:application/ui/theme.dart';
import 'package:application/ui/appIcons.dart'; // ✅ Add this import

class PrimaryCircleButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onPressed;

  const PrimaryCircleButton({
    Key? key,
    required this.icon,
    required this.onPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        width: 48.w,
        height: 48.w,
        decoration: BoxDecoration(
          color: AppTheme.goldenTan,
          shape: BoxShape.circle,
          boxShadow: AppTheme.widgetShadow,
        ),
        child: Icon(
          icon,
          size: 24.sp,
          color: Colors.white,
        ),
      ),
    );
  }
}
