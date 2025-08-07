import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:application/LoginSignup/start.dart';
import 'package:overlay_support/overlay_support.dart';
import 'package:application/services/connectivityWrapper.dart'; // ⬅️ Add this
// ✅ Added overlay support

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

      // 🔧 Temporarily disabled logic to skip intro
  // Future<Widget> _getStartPage() async {
  //   bool hasSeenIntro = await SharedPrefsService.getHasSeenIntro();
  //   return hasSeenIntro ? const LoginPage(title: lastSlideTitle, description: lastSlideDescription) : const StartPage();
  // }

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(390, 844),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return OverlaySupport.global(
          child: ConnectivityWrapper(
            child: MaterialApp(
              debugShowCheckedModeBanner: false,
              theme: ThemeData(
                fontFamily: 'Poppins',
                textTheme: Typography.englishLike2018.apply(fontFamily: 'Poppins'),
              ),
              home: const StartPage(), // Or LoginPage if skipping intro
            ),
          ),
        );
      },
    );


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


              }
} 