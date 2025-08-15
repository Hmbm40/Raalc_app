// lib/ui/keyboardWrapper.dart
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class KeyboardSafeDialog extends StatelessWidget {
  const KeyboardSafeDialog({
    super.key,
    required this.child,
    this.insetPadding,
    this.maxHeightFactor = 0.9,
    this.maxWidthFactor = 0.95,
    this.animationMs = 160,
  });

  final Widget child;
  final EdgeInsets? insetPadding;
  final double maxHeightFactor;
  final double maxWidthFactor;
  final int animationMs;

  @override
  Widget build(BuildContext context) {
    final size   = MediaQuery.of(context).size;
    final insets = MediaQuery.of(context).viewInsets; // keyboard

    return Dialog(
      clipBehavior: Clip.antiAlias,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
      insetPadding: insetPadding ?? EdgeInsets.symmetric(horizontal: 24.w, vertical: 20.h),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: size.height * maxHeightFactor,
          maxWidth:  size.width  * maxWidthFactor,
        ),
        child: AnimatedPadding(
          duration: Duration(milliseconds: animationMs),
          curve: Curves.easeOut,
          padding: EdgeInsets.only(bottom: insets.bottom),
          child: SingleChildScrollView(
            // lets the dialog shrink/scroll instead of overflow
            child: child,
          ),
        ),
      ),
    );
  }
}
