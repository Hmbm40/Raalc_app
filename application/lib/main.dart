import 'package:flutter/material.dart';
import 'package:application/LoginSignup/login.dart';
import 'package:application/LoginSignup/intro.dart';
import 'package:application/data/public/shared_preferences.dart';


void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  Future<Widget> _getStartPage() async {
    bool hasSeenIntro = await SharedPrefsService.getHasSeenIntro();
    return hasSeenIntro ? const LoginPage() : const IntroPage();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: FutureBuilder<Widget>(
        future: _getStartPage(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          } else {
            return snapshot.data!;
          }
        },
      ),
    );
  }
}
