import 'package:flutter/material.dart';
import 'login.dart';
import 'package:application/data/public/shared_preferences.dart';


class IntroPage extends StatelessWidget {
  const IntroPage({super.key});

  void _completeIntro(BuildContext context) async {
    await SharedPrefsService.setHasSeenIntro();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const LoginPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.deepPurple[50],
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                "Welcome to the App!",
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 30),
              const Text(
                "This intro page will only appear the first time you open the app.",
                style: TextStyle(fontSize: 16),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 40),
              ElevatedButton(
                onPressed: () => _completeIntro(context),
                child: const Text("Get Started"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
