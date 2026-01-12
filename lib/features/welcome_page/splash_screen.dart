import 'package:animated_splash_screen/animated_splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:real_time_pawn/core/contants/image_asset_constants.dart';
import 'package:real_time_pawn/features/auth_mngmt/controllers/handler/auth_handler.dart';
import 'package:real_time_pawn/features/welcome_page/welcome_page.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  Widget build(BuildContext context) {
    return AnimatedSplashScreen.withScreenFunction(
      // Use Lottie as a Widget
      splash: Image.asset(
        LocalImageConstants.realTimeLogo, // your Lottie JSON file path
        width: 150, // adjust size
        height: 150,
        fit: BoxFit.contain,
      ),
      splashIconSize: 150, // optional, you can control overall size
      screenFunction: () async {
        return const WelcomeScreen();
      },
      splashTransition: SplashTransition.fadeTransition,
      backgroundColor: Colors.white, // optional
    );
  }
}
