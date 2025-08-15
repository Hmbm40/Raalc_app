import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:overlay_support/overlay_support.dart';

import 'package:application/LoginSignup/start.dart';
import 'package:application/services/connectivityWrapper.dart';
import 'package:application/ui/theme.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  // optional: tune image cache if you have many large slides
  PaintingBinding.instance.imageCache.maximumSize = 200;
  PaintingBinding.instance.imageCache.maximumSizeBytes = 160 << 20;

  timeDilation = 1.0;

  runApp(const ProviderScope(child: MainApp()));
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(390, 844),
      minTextAdapt: true,
      splitScreenMode: true,
      // Pass your home as `child` so it doesn’t rebuild unnecessarily
      child: const StartPage(),
      // Use builder to ensure ScreenUtil is initialized before building MaterialApp
      builder: (context, child) {
        return OverlaySupport.global(
          child: ConnectivityWrapper(
            child: MaterialApp(
              debugShowCheckedModeBanner: false,
              theme: buildLightTheme(),
              home: child, // <= StartPage from `child`
            ),
          ),
        );
      },
    );
  }
}
