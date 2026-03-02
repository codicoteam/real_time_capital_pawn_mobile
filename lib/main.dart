import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:real_time_pawn/core/utils/pallete.dart';
import 'package:real_time_pawn/features/payments_mngmt/screens/welcome_page/splash_screen.dart';
import 'package:real_time_pawn/global/user_controller.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'app_pages.dart';
import 'config/api_config/api_keys.dart';
import 'features/attached_files_mngmt/controllers/attached_files_mngmt_controller.dart'
    show AttachmentController;
import 'features/auctions_mngmt/controllers/auctions_mngmt_controller.dart'
    show AuctionsController;
import 'features/auth_mngmt/controllers/auth_controller.dart';
import 'features/bid_mngmnt/controllers/bid_mngmt_controller.dart'
    show BidManagementController;
import 'features/bid_payment_mngmt/controllers/bid_payment_mngmt_controller.dart'
    show BidPaymentController;
import 'features/loan_application_mngmt/controllers/loan_application_controller.dart'
    show LoanApplicationControllerTwo;
import 'features/loan_application_mngmt/controllers/loan_application_mngmt_controller.dart';
import 'features/loan_terms_mngmt/controllers/loan_terms_mngmt_controller.dart'
    show LoanTermsController;
import 'features/support_mngmt/controllers/support_mngmt_controller.dart'
    show SupportTicketController;

void main() {
  runZonedGuarded(
    () async {
      WidgetsFlutterBinding.ensureInitialized();
      await Supabase.initialize(
        url: ApiKeys.supabaseUrl,
        anonKey: ApiKeys.supabaseKey,
        // Add this for persistence
      );
      Get.put(AuthController());
      Get.put(AttachmentController());
      Get.put(LoanApplicationController());
      Get.put(LoanApplicationControllerTwo());
      Get.put(UserController());
      Get.put(LoanTermsController());
      Get.put(BidPaymentController());
      Get.put(BidManagementController());
      Get.put(AuctionsController());
      Get.put(SupportTicketController());
      runApp(const MyApp());
    },
    (error, stack) {
      // Minimal crash logging so startup failures aren’t silent
      debugPrint('❌ Uncaught error in main(): $error');
      debugPrint('$stack');
    },
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Mr Pace Athletics',
      theme: Pallete.appTheme,
      initialRoute: '/',
      getPages: AppPages.pages,
      home: const SplashScreen(),
    );
  }
}
