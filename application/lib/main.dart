import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:application/LoginSignup/login.dart';
import 'package:application/LoginSignup/start.dart';
import 'package:application/LoginSignup/start.dart'; // Ensure this import exists

// import 'package:application/data/public/shared_preferences.dart'; // Temporarily disabled

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  // 🔧 Temporarily disabled logic to skip intro
  // Future<Widget> _getStartPage() async {
  //   bool hasSeenIntro = await SharedPrefsService.getHasSeenIntro();
  //   return hasSeenIntro ? const LoginPage() : const IntroPage();
  // }

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(390, 844), // iPhone 12 Pro Max size (safe modern baseline)
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          // Force showing StartPage during development
            theme: ThemeData(
            fontFamily: 'Poppins', // 👈 Default font for the whole app
            textTheme: Typography.englishLike2018.apply(fontFamily: 'Poppins'),
          ),
          home: const StartPage(),

          // 🔙 Restore this block when re-enabling intro flow
          // home: FutureBuilder<Widget>(
          //   future: _getStartPage(),
          //   builder: (context, snapshot) {
          //     if (snapshot.connectionState == ConnectionState.waiting) {
          //       return const Scaffold(
          //         body: Center(child: CircularProgressIndicator()),
          //       );
          //     } else {
          //       return snapshot.data!;
          //     }
          //   },
          // ),
        );
      },
    );
  }
}
