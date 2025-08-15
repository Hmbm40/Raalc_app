// lib/ui/textButton.dart
import 'package:flutter/material.dart';

class CustomTextButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;

  // ---- Legacy overrides (kept for backward compatibility; prefer theme/textStyle going forward)
  final double? fontSize;
  final FontWeight? fontWeight;
  final String? fontFamily;
  final Color? color;
  final double opacity;

  // ---- Preferred modern overrides
  final TextStyle? textStyle;           // beats legacy fields if provided
  final TextAlign? textAlign;
  final int? maxLines;
  final bool? softWrap;
  final TextOverflow? overflow;
  final String? semanticsLabel;

  const CustomTextButton({
    super.key,
    required this.text,
    required this.onPressed,
    // legacy style knobs (optional)
    this.fontSize,
    this.fontWeight,
    this.fontFamily,
    this.color,
    this.opacity = 1.0,
    // modern style knobs (optional)
    this.textStyle,
    this.textAlign,
    this.maxLines,
    this.softWrap,
    this.overflow,
    this.semanticsLabel,
  });

  @override
  Widget build(BuildContext context) {
    // Start from themed style (so future global tweaks propagate)
    TextStyle base = Theme.of(context).textTheme.labelLarge ?? const TextStyle();

    // If a full textStyle override is provided, apply it on top of the base.
    if (textStyle != null) {
      base = base.merge(textStyle);
    } else {
      // Otherwise, apply legacy overrides for backward compatibility.
      base = base.copyWith(
        color: color ?? base.color ?? Colors.black,
        fontSize: fontSize ?? base.fontSize ?? 14,
        fontFamily: fontFamily ?? base.fontFamily ?? 'Montserrat',
        fontWeight: fontWeight ?? base.fontWeight ?? FontWeight.w600,
      );
    }

    // Keep your original “no splash / shrink-wrap” behavior.
    final buttonStyle = TextButton.styleFrom(
      splashFactory: NoSplash.splashFactory,
      padding: EdgeInsets.zero,
      minimumSize: Size.zero,
      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      // If a color was provided, also set it at the button level so disabled/pressed states are coherent.
      foregroundColor: color,
    );

    final child = Text(
      text,
      style: base,
      textAlign: textAlign,
      maxLines: maxLines,
      softWrap: softWrap,
      overflow: overflow,
    );

    return Semantics(
      button: true,
      label: semanticsLabel ?? text,
      enabled: onPressed != null,
      child: Opacity(
        opacity: opacity,
        child: TextButton(
          onPressed: onPressed,
          style: buttonStyle,
          child: child,
        ),
      ),
    );
  }
}
