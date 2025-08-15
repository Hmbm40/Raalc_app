// lib/ui/circleButton.dart

import 'package:application/ui/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// Generic, reusable circular icon button without material ink/ripple
/// (keeps visuals identical to your original GestureDetector-based button).
class CircleIconButton extends StatelessWidget {
  final VoidCallback? onPressed;

  /// Logical size (unscaled). Final width/height is `size.w`.
  final double size;

  /// Inner padding for the icon area (logical; scaled via .w).
  final double padding;

  /// Background color of the circle.
  final Color? backgroundColor;

  /// Optional icon color (passed to SVG).
  final Color? iconColor;

  /// Asset path for the SVG icon.
  final String asset;

  /// Optional box shadow list (keeps your old widgetShadow look).
  final List<BoxShadow>? boxShadow;

  /// A11y label for screen readers. Defaults to empty if not provided.
  final String? semanticsLabel;

  const CircleIconButton({
    super.key,
    required this.onPressed,
    required this.asset,
    this.size = 48,           // ⬅️ same visual size as before (48.w)
    this.padding = 12,        // ⬅️ same visual padding as before (12.w)
    this.backgroundColor,
    this.iconColor,
    this.boxShadow,
    this.semanticsLabel,
  });

  @override
  Widget build(BuildContext context) {
    final Color bg = backgroundColor ?? Theme.of(context).colorScheme.primary;
    final Color ic = iconColor ?? Colors.white;

    // Sensible default shadow approximating common "widgetShadow"
    final List<BoxShadow> shadow = boxShadow ??
        [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ];

    return Semantics(
      button: true,
      label: semanticsLabel ?? '',
      enabled: onPressed != null,
      child: GestureDetector(
        onTap: onPressed,
        behavior: HitTestBehavior.opaque, // catch taps even on transparent pixels
        child: Container(
          width: size.w,
          height: size.w,
          decoration: BoxDecoration(
            color: bg,
            shape: BoxShape.circle,
            boxShadow: shadow,
          ),
          alignment: Alignment.center,
          padding: EdgeInsets.all(padding.w),
          child: SvgPicture.asset(
            asset,
            color: ic,
            fit: BoxFit.contain,
          ),
        ),
      ),
    );
  }
}

/// Backwards-compatible wrapper that preserves your old API and visuals.
/// Use this where you previously used `PrimaryCircleButton`.
class PrimaryCircleButton extends StatelessWidget {
  final VoidCallback onPressed;

  const PrimaryCircleButton({
    super.key,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return CircleIconButton(
      onPressed: onPressed,
      size: 48, // 48.w
      padding: 12, // 12.w
      backgroundColor: context.palette.goldenTan, // replaces AppTheme.goldenTan
      iconColor: Colors.white,
      // If you have a central icon registry, reference it here.
      asset: 'assets/images/arrow-big-right-line.svg',
      // Optional: if you’ve defined a themed shadow extension, pass it in.
      // boxShadow: context.tokens.widgetShadow, // example if you add it later
      semanticsLabel: 'Next',
    );
  }
}
