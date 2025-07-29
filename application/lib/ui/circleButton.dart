import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:application/ui/theme.dart';

class PrimaryCircleButton extends HookWidget {
  final VoidCallback onPressed;

  const PrimaryCircleButton({
    super.key,
    required this.onPressed,
  });

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
        child: Padding(
          padding: EdgeInsets.all(12.w),
          child: SvgPicture.asset(
            'assets/images/arrow-big-right-line.svg',
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}
