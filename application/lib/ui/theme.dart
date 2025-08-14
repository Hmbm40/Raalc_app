// lib/ui/theme.dart
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// =======================
/// Design Tokens
/// =======================
@immutable
class AppTokens extends ThemeExtension<AppTokens> {
  final EdgeInsets screenPadding;     // Global default page padding
  final double radiusSm;
  final double radiusMd;
  final double radiusLg;

  const AppTokens({
    required this.screenPadding,
    required this.radiusSm,
    required this.radiusMd,
    required this.radiusLg,
  });

  @override
  AppTokens copyWith({
    EdgeInsets? screenPadding,
    double? radiusSm,
    double? radiusMd,
    double? radiusLg,
  }) {
    return AppTokens(
      screenPadding: screenPadding ?? this.screenPadding,
      radiusSm: radiusSm ?? this.radiusSm,
      radiusMd: radiusMd ?? this.radiusMd,
      radiusLg: radiusLg ?? this.radiusLg,
    );
  }

  @override
  AppTokens lerp(ThemeExtension<AppTokens>? other, double t) => this;
}

/// =======================
/// Brand Colors (centralized)
/// =======================
class Palette {
  static const seed = Color(0xFF524686);   // your footer color
  static const textPrimary = Color(0xFF111111);
  static const textSecondary = Color(0xFF5E5E5E);

  static const surface = Colors.white;
  static const surfaceDark = Color(0xFF0E0E11);
}

/// =======================
/// Typography
/// =======================
TextTheme buildTextTheme() {
  final base = Typography.englishLike2018.apply(fontFamily: 'Poppins');

  // Scale *once* centrally via ScreenUtil; pages never set sizes.
  return base.copyWith(
    displayLarge:   base.displayLarge?.copyWith(  fontSize: 57.sp, color: Palette.textPrimary),
    displayMedium:  base.displayMedium?.copyWith( fontSize: 45.sp, color: Palette.textPrimary),
    displaySmall:   base.displaySmall?.copyWith(  fontSize: 36.sp, color: Palette.textPrimary),
    headlineLarge:  base.headlineLarge?.copyWith( fontSize: 32.sp, color: Palette.textPrimary),
    headlineMedium: base.headlineMedium?.copyWith(fontSize: 28.sp, color: Palette.textPrimary),
    headlineSmall:  base.headlineSmall?.copyWith( fontSize: 24.sp, color: Palette.textPrimary),
    titleLarge:     base.titleLarge?.copyWith(    fontSize: 22.sp, fontWeight: FontWeight.w600, color: Palette.textPrimary),
    titleMedium:    base.titleMedium?.copyWith(   fontSize: 16.sp, fontWeight: FontWeight.w600, color: Palette.textPrimary),
    titleSmall:     base.titleSmall?.copyWith(    fontSize: 14.sp, fontWeight: FontWeight.w600, color: Palette.textPrimary),
    bodyLarge:      base.bodyLarge?.copyWith(     fontSize: 16.sp, color: Palette.textPrimary),
    bodyMedium:     base.bodyMedium?.copyWith(    fontSize: 14.sp, color: Palette.textPrimary),
    bodySmall:      base.bodySmall?.copyWith(     fontSize: 12.sp, color: Palette.textSecondary),
    labelLarge:     base.labelLarge?.copyWith(    fontSize: 14.sp, fontWeight: FontWeight.w600, color: Palette.textPrimary),
    labelMedium:    base.labelMedium?.copyWith(   fontSize: 12.sp, color: Palette.textSecondary),
    labelSmall:     base.labelSmall?.copyWith(    fontSize: 11.sp, color: Palette.textSecondary),
  );
}

/// =======================
/// Component Themes
/// =======================
InputDecorationTheme buildInputDecorationTheme(TextTheme t) {
  final border = OutlineInputBorder(
    borderRadius: BorderRadius.circular(10.r),
    borderSide: const BorderSide(color: Color(0xFFE3E3E3)),
  );
  return InputDecorationTheme(
    isDense: true,
    contentPadding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
    hintStyle: t.bodyMedium?.copyWith(color: Palette.textSecondary),
    labelStyle: t.bodyMedium,
    border: border,
    enabledBorder: border,
    focusedBorder: border.copyWith(borderSide: const BorderSide(color: Color(0xFF9C9C9C))),
    errorBorder: border.copyWith(borderSide: const BorderSide(color: Colors.red)),
  );
}

TextButtonThemeData buildTextButtonTheme(TextTheme t) {
  return TextButtonThemeData(
    style: TextButton.styleFrom(
      foregroundColor: Palette.textPrimary,
      textStyle: t.labelLarge,
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 6.h),
      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      minimumSize: const Size(0, 0),
    ),
  );
}

ElevatedButtonThemeData buildElevatedButtonTheme(TextTheme t, ColorScheme cs) {
  return ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      foregroundColor: Colors.white,
      backgroundColor: cs.primary,
      textStyle: t.labelLarge,
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
      elevation: 0,
    ),
  );
}

/// =======================
/// ThemeData (Light/Dark)
/// =======================
ThemeData buildLightTheme() {
  final scheme = ColorScheme.fromSeed(seedColor: Palette.seed, brightness: Brightness.light);
  final textTheme = buildTextTheme();

  return ThemeData(
    useMaterial3: true,
    colorScheme: scheme,
    fontFamily: 'Poppins',
    textTheme: textTheme,
    scaffoldBackgroundColor: Palette.surface,
    appBarTheme: AppBarTheme(
      backgroundColor: Palette.surface,
      foregroundColor: Palette.textPrimary,
      elevation: 0,
      centerTitle: true,
      titleTextStyle: textTheme.titleLarge,
    ),
    inputDecorationTheme: buildInputDecorationTheme(textTheme),
    textButtonTheme: buildTextButtonTheme(textTheme),
    elevatedButtonTheme: buildElevatedButtonTheme(textTheme, scheme),
    visualDensity: VisualDensity.adaptivePlatformDensity,
    extensions: [
      AppTokens(
        screenPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
        radiusSm: 8.r,
        radiusMd: 12.r,
        radiusLg: 20.r,
      ),
    ],
  );
}

ThemeData buildDarkTheme() {
  final light = buildLightTheme();
  final scheme = ColorScheme.fromSeed(seedColor: Palette.seed, brightness: Brightness.dark);
  return light.copyWith(
    colorScheme: scheme,
    scaffoldBackgroundColor: Palette.surfaceDark,
    textTheme: light.textTheme.apply(bodyColor: Colors.white, displayColor: Colors.white),
    appBarTheme: light.appBarTheme.copyWith(
      backgroundColor: Palette.surfaceDark,
      foregroundColor: Colors.white,
      titleTextStyle: light.textTheme.titleLarge?.copyWith(color: Colors.white),
    ),
  );
}

/// =======================
/// Ergonomics on BuildContext
/// =======================
extension ThemeX on BuildContext {
  TextTheme get t => Theme.of(this).textTheme;
  ColorScheme get cs => Theme.of(this).colorScheme;
  AppTokens get tokens => Theme.of(this).extension<AppTokens>()!;
}
