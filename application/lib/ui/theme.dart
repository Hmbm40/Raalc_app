// lib/theme/theme.dart
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class AppTheme {
  // ------------------ 🎨 COLOR PALETTE ------------------
  static const Color navyBlue = Color(0xFF223752);
  static const Color goldenTan = Color(0xFFC59D41);
  static const Color midnightBlue = Color(0xFF001431);
  static const Color warmGold = Color(0xFFDAB460);
  static const Color offWhiteVanilla = Color(0xFFF9F4EC);
  static const Color ivoryWhite = Color(0xFFF9F9F6);

  // ------------------ 🖋 FONT ------------------
  static const String fontFamily = 'Inter'; // Make sure it's registered in pubspec.yaml

  static TextStyle headline = TextStyle(
    fontSize: 20.sp,
    fontWeight: FontWeight.bold,
    fontFamily: fontFamily,
    color: navyBlue,
  );

  static TextStyle body = TextStyle(
    fontSize: 14.sp,
    fontWeight: FontWeight.normal,
    fontFamily: fontFamily,
    color: midnightBlue,
  );

  static TextStyle tag = TextStyle(
    fontSize: 12.sp,
    fontWeight: FontWeight.w400,
    fontFamily: fontFamily,
    color: goldenTan,
  );

  // ------------------ 🌫 SHADOWS ------------------
  static List<BoxShadow> darkShadow = [
    BoxShadow(color: Colors.black.withOpacity(0.35), offset: const Offset(0, 4), blurRadius: 6),
  ];

  static List<BoxShadow> lightShadow = [
    BoxShadow(color: Colors.black.withOpacity(0.15), offset: const Offset(0, 3), blurRadius: 3),
  ];

  static List<BoxShadow> widgetShadow = [
    BoxShadow(color: Colors.black.withOpacity(0.1), offset: const Offset(0, 4), blurRadius: 6),
  ];

  static List<BoxShadow> subtleShadow = [
    BoxShadow(color: Colors.black.withOpacity(0.05), offset: const Offset(0, 2), blurRadius: 8),
  ];

  static List<BoxShadow> boldShadow = [
    BoxShadow(color: Colors.black.withOpacity(0.2), offset: const Offset(0, 4), blurRadius: 4, spreadRadius: -1),
  ];

  static List<BoxShadow> neumorphicShadow = [
    BoxShadow(color: Colors.white.withOpacity(0.8), offset: const Offset(-3, -3), blurRadius: 6),
    BoxShadow(color: Colors.black.withOpacity(0.15), offset: const Offset(3, 3), blurRadius: 6),
  ];

  static List<BoxShadow> balancedShadow = [
    BoxShadow(color: Colors.black.withOpacity(0.1), offset: const Offset(0, 3), blurRadius: 4, spreadRadius: 1),
    BoxShadow(color: Colors.black.withOpacity(0.07), offset: const Offset(0, -3), blurRadius: 8, spreadRadius: 1),
  ];

  // ------------------ 🎯 RADII ------------------
  static double baseRadius = 12.r;
  static double fullRadius = 50.r;

  // ------------------ 📐 SIZES (ScreenUtil Based) ------------------
  static double buttonHeight = 50.h;
  static double buttonCorner = 8.r;
  static double inputHeight = 56.h;
  static double iconSize = 24.w;

  static double headlineFont = 20.sp;
  static double bodyFont = 14.sp;
  static double tagFont = 12.sp;

  static double pageHorizontalPadding = 20.w;
  static double pageVerticalPadding = 16.h;
  static double sectionSpacing = 32.h;
  static double blockSpacing = 16.h;
  static double smallSpacing = 8.h;

  static double borderWidth = 2.w;
  static double indicatorSize = 8.w;
  static double indicatorExpanded = 24.w;
  static double imagePadding = 20.w;
  static double logoHeight = 40.h;

  static var titleFont;
}
