import 'package:flutter/material.dart';

/// Clamp text scale to a reasonable range while still honoring user settings.
class AppTextScale extends StatelessWidget {
  final Widget child;
  final double min;
  final double max;

  const AppTextScale({
    super.key,
    required this.child,
    this.min = 0.85,
    this.max = 1.30,
  });

  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context);
    final clamped = mq.textScaler.clamp(minScaleFactor: min, maxScaleFactor: max);
    return MediaQuery(
      data: mq.copyWith(textScaler: clamped),
      child: child,
    );
  }
}

/// Wrap tappables to guarantee 48x48 dp min target.
class MinTapTarget extends StatelessWidget {
  final Widget child;
  final EdgeInsets padding;

  const MinTapTarget({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(12), // 48 target often reached with child size + padding
  });

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(minWidth: 48, minHeight: 48),
      child: Padding(padding: padding, child: Center(child: child)),
    );
  }
}

/// Quick semantics wrapper for non-Text tappables (icons, images, custom buttons).
class SemanticButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final Widget child;

  const SemanticButton({
    super.key,
    required this.label,
    required this.child,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: label,
      enabled: onPressed != null,
      child: GestureDetector(onTap: onPressed, child: MinTapTarget(child: child)),
    );
  }
}
