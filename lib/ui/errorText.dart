// lib/ui/errorText.dart
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class FormErrorText extends StatelessWidget {
  /// Error message to display; when null/empty, the widget collapses (AnimatedSize + fade).
  final String? message;

  /// Animation duration for both size and opacity.
  final Duration duration;

  /// Padding around the error text. Defaults to directional (RTL-friendly).
  final EdgeInsetsGeometry padding;

  /// Optional text style override. If null, keeps your legacy look:
  /// red color, 10.sp, 'Montserrat'.
  ///
  /// When you’re ready to move fully to theme-driven styles, pass:
  ///   Theme.of(context).textTheme.labelSmall?.copyWith(
  ///     color: Theme.of(context).colorScheme.error,
  ///     fontSize: 10.sp,
  ///   )
  final TextStyle? style;

  /// Optional text alignment and layout controls
  final TextAlign textAlign;
  final int? maxLines;
  final bool? softWrap;
  final TextOverflow? overflow;

  const FormErrorText({
    super.key,
    required this.message,
    this.duration = const Duration(milliseconds: 180),
    this.padding = const EdgeInsetsDirectional.only(start: 4, top: 4),
    this.style,
    this.textAlign = TextAlign.start,
    this.maxLines,
    this.softWrap,
    this.overflow,
  });

  @override
  Widget build(BuildContext context) {
    final hasError = message != null && message!.isNotEmpty;

    // Keep legacy visuals by default to ensure identical look.
    final TextStyle effectiveStyle = style ??
        TextStyle(
          color: Colors.red,
          fontSize: 10.sp,
          fontFamily: 'Montserrat',
        );

    // If no error, fully collapse with AnimatedSize + fade.
    return AnimatedSize(
      duration: duration,
      curve: Curves.easeInOut,
      alignment: Alignment.topLeft,
      child: AnimatedOpacity(
        opacity: hasError ? 1 : 0,
        duration: duration,
        curve: Curves.easeInOut,
        child: hasError
            ? Padding(
                padding: padding,
                child: Semantics(
                  liveRegion: true,
                  // Announce as "error" for assistive tech
                  label: 'Error',
                  // Merging semantics so only one announcement is made
                  child: Text(
                    message!,
                    style: effectiveStyle,
                    textAlign: textAlign,
                    maxLines: maxLines,
                    softWrap: softWrap,
                    overflow: overflow,
                  ),
                ),
              )
            : const SizedBox.shrink(),
      ),
    );
  }
}
