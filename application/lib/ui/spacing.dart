// lib/ui/spacing.dart

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// A collection of spacing constants and helpers for layout consistency.
class AppSpacing {
  // 🔸 Vertical Spacing (double values)
  static double tinyVertical = 4.h;
  static double smallVertical = 8.h;
  static double smallerVertical = 6.h;
  static double semiRegularVertical = 12.h;
  static double regularVertical = 16.h;
  static double mediumVertical = 24.h;
  static double largeVertical = 32.h;
  static double largerVertical = 40.h;
  static double xlVertical = 48.h;

  // 🔸 Horizontal Spacing (double values)
  static double tinyHorizontal = 4.w;
  static double smallHorizontal = 8.w;
  static double regularHorizontal = 16.w;
  static double mediumHorizontal = 24.w;
  static double largeHorizontal = 32.w;
  static double xlHorizontal = 48.w;

  // 🔸 Page and section padding
  static double page = 20.w;
  static double section = 32.h;
  static double block = 16.h;
  static double small = 8.h;
}

/// 🔁 Extension for `num.verticalSpace` / `num.horizontalSpace`
extension SpacingExtensions on num {
  SizedBox get verticalSpace => SizedBox(height: h);
  SizedBox get horizontalSpace => SizedBox(width: w);
}
