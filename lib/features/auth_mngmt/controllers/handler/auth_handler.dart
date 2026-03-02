import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:real_time_pawn/core/utils/logs.dart';
import '../../../../core/utils/shared_pref_methods.dart' show CacheUtils;
import '../../../../global/user_controller.dart' show UserController;
import '../../../../models/user_model.dart' show UserModel;
import '../../../home_management/screens/main_screen.dart' show MainHomePage;
import '../../../payments_mngmt/screens/welcome_page/welcome_page.dart';
import '../../screens/login_screen.dart' show Login;

class AuthHandler extends StatelessWidget {
  const AuthHandler({super.key});
  Future<UserModel?> _getUserFromToken() async {
    final token = await CacheUtils.checkToken();
    if (token != null && token.isNotEmpty) {
      if (JwtDecoder.isExpired(token)) {
        await CacheUtils.clearCachedToken();
        return null; // Token expired
      } else {
        final decodedToken = JwtDecoder.decode(token);
        DevLogs.logInfo("Decoded token: $decodedToken");
        return UserModel.fromMap(decodedToken);
      }
    }
    return null; // No token found
  }

  @override
  Widget build(BuildContext context) {
    final userController =
        Get.find<UserController>(); // <-- get existing controller

    return FutureBuilder<bool>(
      future: CacheUtils.checkOnBoardingStatus(),
      builder: (context, onboardingSnapshot) {
        if (onboardingSnapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final hasSeenOnboarding = onboardingSnapshot.data ?? false;

        if (!hasSeenOnboarding) {
          return const WelcomeScreen();
        }

        return FutureBuilder<UserModel?>(
          future: _getUserFromToken(),
          builder: (context, tokenSnapshot) {
            if (tokenSnapshot.connectionState == ConnectionState.waiting) {
              return const Scaffold(
                body: Center(child: CircularProgressIndicator()),
              );
            }

            if (!tokenSnapshot.hasData) {
              return const Login();
            }

            final user = tokenSnapshot.data!;
            DevLogs.logInfo("User: $user");

            userController.setUser(
              user,
            ); // <-- set user in the existing controller

            return const MainHomePage();
          },
        );
      },
    );
  }
}
