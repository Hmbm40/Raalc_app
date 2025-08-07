// lib/ui/errorText.dart
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class FormErrorText extends StatelessWidget {
  final String? message;
  final Duration duration;

  /// Use EdgeInsetsGeometry so you can pass EdgeInsets or EdgeInsetsDirectional.
  final EdgeInsetsGeometry padding;

  const FormErrorText({
    super.key,
    required this.message,
    this.duration = const Duration(milliseconds: 180),
    this.padding = const EdgeInsets.only(left: 4, top: 4), // default is non-directional
  });

  @override
  Widget build(BuildContext context) {
    final hasError = message != null && message!.isNotEmpty;

    return AnimatedSize(
      duration: duration,
      curve: Curves.easeInOut,
      child: AnimatedOpacity(
        opacity: hasError ? 1 : 0,
        duration: duration,
        child: hasError
            ? Padding(
                padding: padding,
                child: Text(
                  message!,
                  style: TextStyle(
                    color: Colors.red,
                    fontSize: 10.sp,
                    fontFamily: 'Montserrat',
                  ),
                ),
              )
            : const SizedBox.shrink(),
      ),
    );
  }
}
