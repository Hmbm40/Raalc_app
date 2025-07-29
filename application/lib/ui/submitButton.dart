import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'theme.dart';
import 'spacing.dart';

class SubmitButton extends StatelessWidget {
  final String label;
  final bool isLoading;
  final VoidCallback? onPressed;

  const SubmitButton({
    super.key,
    required this.label,
    required this.isLoading,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: AppSpacing.mediumHorizontal,
        vertical: AppSpacing.smallVertical,
      ),
      child: SizedBox(
        width: double.infinity,
        height: 50.h,
        child: ElevatedButton(
          onPressed: isLoading ? null : onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppTheme.goldenTan,
            elevation: 0,
            shadowColor: Colors.transparent,
            shape: const RoundedRectangleBorder(
            ),
            padding: EdgeInsets.zero,
          ),
          child: Container(
            decoration: BoxDecoration(
              boxShadow: AppTheme.widgetShadow,
            ),
            alignment: Alignment.center,
            child: isLoading
                ? SizedBox(
                    height: 20.h,
                    width: 20.h,
                    child: const CircularProgressIndicator(color: Colors.white),
                  )
                : Text(
                    label,
                    style: TextStyle(
                      fontSize: 10.sp,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
          ),
        ),
      ),
    );
  }
}
