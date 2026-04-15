import 'package:flutter/material.dart';
import 'dart:async';
import 'auth/login.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {

  // BG COLOR
  final Color bgYellow = const Color(0xFFECC84E);

  @override
  void initState() {
    super.initState();

    // DELAY THEN NAVIGATE
    Timer(const Duration(seconds: 2), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const LoginPage()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgYellow,
      body: Center(
        child: Container(
          width: 120,
          height: 120,
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white,
          ),
          padding: const EdgeInsets.all(16),
          child: Image.asset(
            "assets/mark_a_park_app_icon.png",
            fit: BoxFit.contain,
          ),
        ),
      ),
    );
  }
}