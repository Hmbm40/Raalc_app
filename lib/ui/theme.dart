// lib/ui/theme.dart
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// =======================
/// Design Tokens (radii, page padding)
/// =======================
@immutable
class AppTokens extends ThemeExtension<AppTokens> {
  final EdgeInsets screenPadding; // default page padding
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
/// App Colors — ONE canonical gray
/// =======================
@immutable
class AppColors extends ThemeExtension<AppColors> {
  final Color goldenTan;     // primary brand gold
  final Color navyBlue;      // headings
  final Color midnightBlue;  // body alt
  final Color ivoryWhite;    // light surface
  final Color gray;          // the ONLY gray used in the app
  final Color black;
  final Color lightGray;     // helper for dividers, muted text
  final Color surface;       // scaffold bg

  const AppColors({
    required this.goldenTan,
    required this.navyBlue,
    required this.midnightBlue,
    required this.ivoryWhite,
    required this.gray,
    required this.black,
    required this.lightGray,
    required this.surface,
  });

  static const AppColors light = AppColors(
    goldenTan: Color(0xFFdab460),
    navyBlue: Color(0xFF123055),
    midnightBlue: Color(0xFF1C2430),
    ivoryWhite: Color(0xFFFAFAFA),
    gray: Color(0xFF737373),
    black: Color(0xFF111111),
    lightGray: Color(0xFFBDBDBD),
    surface: Colors.white,
  );

  @override
  AppColors copyWith({
    Color? goldenTan,
    Color? navyBlue,
    Color? midnightBlue,
    Color? ivoryWhite,
    Color? gray,
    Color? black,
    Color? lightGray,
    Color? surface,
  }) {
    return AppColors(
      goldenTan: goldenTan ?? this.goldenTan,
      navyBlue: navyBlue ?? this.navyBlue,
      midnightBlue: midnightBlue ?? this.midnightBlue,
      ivoryWhite: ivoryWhite ?? this.ivoryWhite,
      gray: gray ?? this.gray,
      black: black ?? this.black,
      lightGray: lightGray ?? this.lightGray,
      surface: surface ?? this.surface,
    );
  }

  @override
  AppColors lerp(ThemeExtension<AppColors>? other, double t) => this;
}

/// =======================
/// Static palette (light-only convenience)
/// Lets you write `Palette.gray` anywhere (no BuildContext required).
/// If you add dark mode later, prefer using `context.palette` dynamically.
/// =======================
class Palette {
  static  Color goldenTan   = AppColors.light.goldenTan;
  static  Color navyBlue    = AppColors.light.navyBlue;
  static  Color midnightBlue= AppColors.light.midnightBlue;
  static  Color ivoryWhite  = AppColors.light.ivoryWhite;
  static  Color gray        = AppColors.light.gray;      // ✅ single canonical gray
  static  Color black       = AppColors.light.black;
  static  Color lightGray   = AppColors.light.lightGray;
  static  Color surface     = AppColors.light.surface;
}

/// =======================
/// Typography (Poppins + ScreenUtil scaling)
/// =======================
TextTheme buildTextTheme(ColorScheme cs) {
  final base = Typography.englishLike2018.apply(fontFamily: 'Poppins');

  return base.copyWith(
    displayLarge:   base.displayLarge?.copyWith(  fontSize: 57.sp, color: cs.onSurface),
    displayMedium:  base.displayMedium?.copyWith( fontSize: 45.sp, color: cs.onSurface),
    displaySmall:   base.displaySmall?.copyWith(  fontSize: 36.sp, color: cs.onSurface),
    headlineLarge:  base.headlineLarge?.copyWith( fontSize: 32.sp, color: cs.onSurface),
    headlineMedium: base.headlineMedium?.copyWith(fontSize: 28.sp, color: cs.onSurface),
    headlineSmall:  base.headlineSmall?.copyWith( fontSize: 24.sp, color: cs.onSurface),
    titleLarge:     base.titleLarge?.copyWith(    fontSize: 22.sp, fontWeight: FontWeight.w600, color: cs.onSurface),
    titleMedium:    base.titleMedium?.copyWith(   fontSize: 16.sp, fontWeight: FontWeight.w600, color: cs.onSurface),
    titleSmall:     base.titleSmall?.copyWith(    fontSize: 14.sp, fontWeight: FontWeight.w600, color: cs.onSurface),
    bodyLarge:      base.bodyLarge?.copyWith(     fontSize: 16.sp, color: cs.onSurface),
    bodyMedium:     base.bodyMedium?.copyWith(    fontSize: 14.sp, color: cs.onSurface),
    bodySmall:      base.bodySmall?.copyWith(     fontSize: 12.sp, color: cs.onSurface.withOpacity(0.7)),
    labelLarge:     base.labelLarge?.copyWith(    fontSize: 14.sp, fontWeight: FontWeight.w600, color: cs.onSurface),
    labelMedium:    base.labelMedium?.copyWith(   fontSize: 12.sp, color: cs.onSurface.withOpacity(0.7)),
    labelSmall:     base.labelSmall?.copyWith(    fontSize: 11.sp, color: cs.onSurface.withOpacity(0.6)),
  );
}

/// =======================
/// InputDecorationTheme — No outline/fill, custom underline
/// =======================
InputDecorationTheme buildInputDecorationTheme(
  TextTheme t,
  AppColors colors,
) {
  return InputDecorationTheme(
    isDense: true,
    filled: false,
    border: InputBorder.none,
    enabledBorder: InputBorder.none,
    focusedBorder: InputBorder.none,
    errorBorder: InputBorder.none,
    disabledBorder: InputBorder.none,
    focusedErrorBorder: InputBorder.none,
    contentPadding: EdgeInsets.zero,
    hintStyle: t.bodyMedium?.copyWith(color: colors.gray),
    labelStyle: t.bodyMedium,
  );
}

TextButtonThemeData buildTextButtonTheme(TextTheme t, AppColors colors) {
  return TextButtonThemeData(
    style: TextButton.styleFrom(
      foregroundColor: colors.black,
      textStyle: t.labelLarge,
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 6.h),
      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      minimumSize: const Size(0, 0),
    ),
  );
}

ElevatedButtonThemeData buildElevatedButtonTheme(
  TextTheme t,
  ColorScheme cs,
) {
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
/// ThemeData — Light only
/// =======================
ThemeData buildLightTheme() {
  final scheme = ColorScheme.fromSeed(
    seedColor: const Color(0xFF524686),
    brightness: Brightness.light,
  );

  const colors = AppColors.light;
  final textTheme = buildTextTheme(scheme);

  return ThemeData(
    useMaterial3: true,
    colorScheme: scheme,
    fontFamily: 'Poppins',
    textTheme: textTheme,
    scaffoldBackgroundColor: colors.surface,

    appBarTheme: AppBarTheme(
      backgroundColor: colors.surface,
      foregroundColor: scheme.onSurface,
      elevation: 0,
      centerTitle: true,
      titleTextStyle: textTheme.titleLarge,
    ),

    inputDecorationTheme: buildInputDecorationTheme(textTheme, colors),
    textButtonTheme: buildTextButtonTheme(textTheme, colors),
    elevatedButtonTheme: buildElevatedButtonTheme(textTheme, scheme),

    visualDensity: VisualDensity.adaptivePlatformDensity,

    extensions: <ThemeExtension<dynamic>>[
      colors,
      AppTokens(
        screenPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
        radiusSm: 8.r,
        radiusMd: 12.r,
        radiusLg: 20.r,
      ),
    ],
  );
}

/// =======================
/// Ergonomics on BuildContext
/// =======================
extension ThemeX on BuildContext {
  TextTheme get t => Theme.of(this).textTheme;
  ColorScheme get cs => Theme.of(this).colorScheme;
  AppTokens get tokens => Theme.of(this).extension<AppTokens>()!;
  AppColors get palette => Theme.of(this).extension<AppColors>()!;
}
