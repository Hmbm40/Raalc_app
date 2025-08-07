import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../ui/theme.dart';

class CountryCodeSelector extends StatelessWidget {
  final String selectedCode;
  final VoidCallback onTap;

  const CountryCodeSelector({
    super.key,
    required this.selectedCode,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final textScale = MediaQuery.textScaleFactorOf(context);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 48.h,
        padding: EdgeInsets.symmetric(horizontal: 12.w),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: AppTheme.goldenTan,
              width: 1.5,
            ),
          ),
        ),
        alignment: Alignment.centerLeft,
        child: Text(
          selectedCode,
          style: TextStyle(
            fontSize: 14.sp * textScale,
            fontFamily: 'Montserrat',
            color: AppTheme.black,
          ),
        ),
      ),
    );
  }
}
