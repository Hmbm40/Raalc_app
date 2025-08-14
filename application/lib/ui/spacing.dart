// lib/ui/spacing.dart
//
// Spacing tokens + ergonomics (compile-safe).
// - Semantic tokens: Space.{xs, sm, md, lg, xl, xxl}
// - ScreenUtil-aware (h/w for axis, r for uniform)
// - Pages stay minimal: Gap.vx(Space.md), Insets.page(context)
// - No overrides of SizedBox internals; no uninitialized finals; no const traps.

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// Semantic spacing scale
enum Space { xs, sm, md, lg, xl, xxl }

/// Core spacing utilities
class Spacing {
  const Spacing._();

  /// Base (unscaled) values in logical pixels.
  static double base(Space s) {
    switch (s) {
      case Space.xs:  return 4.0;
      case Space.sm:  return 8.0;
      case Space.md:  return 12.0;
      case Space.lg:  return 16.0;
      case Space.xl:  return 24.0;
      case Space.xxl: return 32.0;
    }
  }

  /// Axis-aware scaled values
  static double v(Space s) => base(s).h; // vertical -> .h
  static double h(Space s) => base(s).w; // horizontal -> .w

  /// Uniform scaled value (use sparingly)
  static double r(Space s) => base(s).r;

  // Convenience getters (optional sugar)
  static double get xs  => base(Space.xs).r;
  static double get sm  => base(Space.sm).r;
  static double get md  => base(Space.md).r;
  static double get lg  => base(Space.lg).r;
  static double get xl  => base(Space.xl).r;
  static double get xxl => base(Space.xxl).r;
}

/// Gap widgets for vertical/horizontal spacing
class Gap extends StatelessWidget {
  final double? _height;
  final double? _width;

  const Gap._({Key? key, double? height, double? width})
      : _height = height,
        _width = width,
        super(key: key);

  /// Exact vertical gap in logical px (scaled via .h)
  factory Gap.v(double logical) => Gap._(height: logical.h);

  /// Exact horizontal gap in logical px (scaled via .w)
  factory Gap.h(double logical) => Gap._(width: logical.w);

  /// Token-based vertical gap
  factory Gap.vx(Space token) => Gap._(height: Spacing.v(token));

  /// Token-based horizontal gap
  factory Gap.hx(Space token) => Gap._(width: Spacing.h(token));

  @override
  Widget build(BuildContext context) => SizedBox(height: _height, width: _width);
}

/// Padding factories to avoid manual EdgeInsets everywhere
class Insets {
  const Insets._();

  static EdgeInsets all(Space s) {
    final v = Spacing.base(s).r; // uniform feel
    return EdgeInsets.all(v);
  }

  static EdgeInsets symmetric({Space? h, Space? v}) {
    return EdgeInsets.symmetric(
      horizontal: h != null ? Spacing.h(h) : 0,
      vertical: v != null ? Spacing.v(v) : 0,
    );
  }

  static EdgeInsets only({
    Space? left,
    Space? top,
    Space? right,
    Space? bottom,
  }) {
    return EdgeInsets.only(
      left:   left   != null ? Spacing.h(left)   : 0,
      top:    top    != null ? Spacing.v(top)    : 0,
      right:  right  != null ? Spacing.h(right)  : 0,
      bottom: bottom != null ? Spacing.v(bottom) : 0,
    );
  }

  /// Default page padding:
  /// - If your Theme has a ThemeExtension with `screenPadding`, we use it.
  /// - Otherwise fall back to 16.h / 16.w symmetric.
  static EdgeInsets page(BuildContext context) {
    final extensions = Theme.of(context).extensions.values;
    for (final ext in extensions) {
      try {
        final p = (ext as dynamic).screenPadding as EdgeInsets?;
        if (p != null) return p;
      } catch (_) {
        // Not the extension we want; continue.
      }
    }
    return EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h);
  }
}
