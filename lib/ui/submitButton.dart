// lib/ui/submitButton.dart
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'spacing.dart'; // <-- uses Space/Gaps/Insets

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
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    // Fallback shadow roughly matching your old "widgetShadow"
    final List<BoxShadow> shadows = [
      BoxShadow(
        color: Colors.black.withOpacity(0.10),
        offset: const Offset(0, 2),
        blurRadius: 4,
      ),
    ];

    return Padding(
      // AppSpacing.mediumHorizontal (24.w) -> Space.xl
      // AppSpacing.smallVertical  (8.h)  -> Space.sm
      padding: Insets.symmetric(h: Space.xl, v: Space.sm),
      child: SizedBox(
        width: double.infinity,
        height: 50.h,
        child: ElevatedButton(
          onPressed: isLoading ? null : onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: cs.primary,      // was AppTheme.goldenTan
            elevation: 0,
            shadowColor: Colors.transparent,
            shape: const RoundedRectangleBorder(),
            padding: EdgeInsets.zero,
          ),
          child: Container(
            decoration: BoxDecoration(boxShadow: shadows), // was AppTheme.widgetShadow
            alignment: Alignment.center,
            child: isLoading
                ? SizedBox(
                    height: 20.h,
                    width: 20.h,
                    child: const CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
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
