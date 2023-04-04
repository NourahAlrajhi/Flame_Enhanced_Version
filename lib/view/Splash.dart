import 'package:flame/view/Auth/index.dart';
import 'package:flutter/material.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});
  static String id = "SplashScreen";

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    Artificialwaiting();
    super.initState();
  }

  Future<void> Artificialwaiting() async {
    await Future.delayed(const Duration(seconds: 3), () {});
    Navigator.pushNamed(context, IndexScreen.id);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Image.asset(
          'assets/filledLogo.png',
          height: 200,
          width: 200,
        ),
      ),
    );
  }
}
