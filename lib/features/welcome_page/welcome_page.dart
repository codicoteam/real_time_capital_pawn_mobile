import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:introduction_screen/introduction_screen.dart';
import 'package:real_time_pawn/core/utils/pallete.dart';
import 'package:real_time_pawn/core/utils/shared_pref_methods.dart';
import 'package:real_time_pawn/features/auth_mngmt/screens/login_screen.dart';
import 'package:real_time_pawn/features/home_management/screens/main_screen.dart';

import '../../config/routers/router.dart';

/// Welcome screen with introduction_screen package using AppColors class
class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return IntroductionScreen(
      pages: _buildPages(),
      onDone: () => _onIntroEnd(context),
      onSkip: () => _onIntroEnd(context),
      showSkipButton: true,
      skip: Text(
        'Skip',
        style: TextStyle(
          fontWeight: FontWeight.w600,
          color: AppColors.primaryColor,
          fontSize: 14, // Added smaller font size
        ),
      ),
      next: Icon(Icons.arrow_forward, color: AppColors.primaryColor),
      done: Text(
        'Next',
        style: TextStyle(
          fontWeight: FontWeight.w600,
          color: AppColors.primaryColor,
          fontSize: 14, // Added smaller font size
        ),
      ),
      // Dots styling
      dotsDecorator: DotsDecorator(
        size: const Size(7.0, 7.0),
        color: AppColors.borderColor,
        activeSize: const Size(15.0, 10.0),
        activeColor: AppColors.primaryColor,
        activeShape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20.0),
        ),
      ),
      // Global styling
      globalBackgroundColor: AppColors.backgroundColor,
      skipStyle: ButtonStyle(
        foregroundColor: MaterialStateProperty.all(AppColors.primaryColor),
        padding: MaterialStateProperty.all(
          const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        ),
        minimumSize: MaterialStateProperty.all(
          const Size(60, 40),
        ), // Reduced minimum width
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        overlayColor: MaterialStateProperty.all(
          AppColors.primaryColor.withOpacity(0.1),
        ),
      ),
      doneStyle: ButtonStyle(
        foregroundColor: MaterialStateProperty.all(AppColors.primaryColor),
        backgroundColor: MaterialStateProperty.all(
          AppColors.primaryColor.withOpacity(0.1),
        ),
        shape: MaterialStateProperty.all(
          RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ), // Slightly smaller border radius
        ),
        padding: MaterialStateProperty.all(
          const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        ),
        minimumSize: MaterialStateProperty.all(
          const Size(80, 40),
        ), // Reduced minimum width
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
      nextStyle: ButtonStyle(
        foregroundColor: MaterialStateProperty.all(AppColors.primaryColor),
        backgroundColor: MaterialStateProperty.all(
          AppColors.primaryColor.withOpacity(0.1),
        ),
        shape: MaterialStateProperty.all(
          RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ), // Slightly smaller border radius
        ),
        padding: MaterialStateProperty.all(
          const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        ),
        minimumSize: MaterialStateProperty.all(
          const Size(60, 40),
        ), // Reduced minimum width
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
    );
  }

  List<PageViewModel> _buildPages() {
    return [
      PageViewModel(
        title: "Welcome to Real Time Capital",
        body:
            "Your trusted partner for instant collateral-based loans! Get quick loans using your valuable assets as security with our transparent pawn system.",
        image: _buildImage('assets/images/realtimecapital.png'),
        decoration: _getPageDecoration(),
      ),

      PageViewModel(
        title: "Electric Gadget Loans",
        body:
            "Need quick cash? Use your smartphones, laptops, tablets, or other electronics as collateral. Get instant valuation and fast disbursement.",
        image: _buildImage('assets/images/gadgets.png'),
        decoration: _getPageDecoration(),
      ),
      PageViewModel(
        title: "Motor Vehicle Collateral",
        body:
            "Get substantial loans using your car, motorcycle, or other vehicles as security. Keep driving your vehicle while enjoying your loan benefits.",
        image: _buildImage('assets/images/cars_loan.png'),
        decoration: _getPageDecoration(),
      ),
      PageViewModel(
        title: "Jewelry & Valuables",
        body:
            "Use your gold, diamonds, watches, and other precious items as collateral. Professional valuation and secure storage for your peace of mind.",
        image: _buildImage('assets/images/jewellery.png'),
        decoration: _getPageDecoration(),
      ),
      PageViewModel(
        title: "Asset Auctions",
        body:
            "Explore our auction platform to bid on various assets. Find great deals on unredeemed items and other valuable products.",
        image: _buildImage('assets/images/bid_closed.png'),
        decoration: _getPageDecoration(),
      ),
    ];
  }

  Widget _buildImage(String assetName) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryColor.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Image.asset(
          assetName,
          height: 250.0,
          width: 250.0,
          fit: BoxFit.contain,
        ),
      ),
    );
  }

  PageDecoration _getPageDecoration() {
    return PageDecoration(
      titleTextStyle: TextStyle(
        fontSize: 28.0,
        fontWeight: FontWeight.bold,
        color: AppColors.textColor,
      ),
      bodyTextStyle: TextStyle(
        fontSize: 16.0,
        color: AppColors.subtextColor,
        height: 1.5,
      ),
      imagePadding: const EdgeInsets.all(24),
      pageColor: AppColors.backgroundColor,
      bodyPadding: const EdgeInsets.fromLTRB(16.0, 0.0, 16.0, 16.0),
      titlePadding: const EdgeInsets.fromLTRB(16.0, 50.0, 16.0, 16.0),
      contentMargin: const EdgeInsets.symmetric(horizontal: 16.0),
      imageFlex: 3,
      bodyFlex: 2,
    );
  }

  void _onIntroEnd(BuildContext context) async {
    await CacheUtils.updateOnboardingStatus(true).then((_) {
    Get.to(() => const Login());
    });
  }
}
