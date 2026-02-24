import 'package:get/get.dart';
import 'package:real_time_pawn/config/routers/router.dart';
import 'package:real_time_pawn/features/about_mngmt/screens/about_mngmt_screen.dart';
import 'package:real_time_pawn/features/auth_mngmt/auctions_mngmt/helpers/search_auctions_screen.dart';
import 'package:real_time_pawn/features/auth_mngmt/auctions_mngmt/screens/auction_bids_screen.dart';
import 'package:real_time_pawn/features/auth_mngmt/auctions_mngmt/screens/auction_details_screen.dart';
import 'package:real_time_pawn/features/auth_mngmt/auctions_mngmt/screens/auctions_list_screen.dart';
import 'package:real_time_pawn/features/auth_mngmt/auctions_mngmt/screens/live_auctions_screen.dart';
import 'package:real_time_pawn/features/auth_mngmt/auctions_mngmt/screens/user_bid_history_screen.dart';
import 'package:real_time_pawn/features/auth_mngmt/screens/forgot_password_screen.dart';
import 'package:real_time_pawn/features/auth_mngmt/screens/login_screen.dart';
import 'package:real_time_pawn/features/auth_mngmt/screens/register_screen.dart';
import 'package:real_time_pawn/features/auth_mngmt/screens/verify_otp_screen.dart';
import 'package:real_time_pawn/features/bid_mngmnt/screens/bid_details_screen.dart';
import 'package:real_time_pawn/features/bid_mngmnt/screens/my_bids_screen.dart';
import 'package:real_time_pawn/features/bid_payment_mngmt/screens/confirm_bid_payment_screen.dart';
import 'package:real_time_pawn/features/bid_payment_mngmt/screens/my_bid_payments_screen.dart';
import 'package:real_time_pawn/features/bid_payment_mngmt/screens/bid_payment_details_screen.dart';
import 'package:real_time_pawn/features/bid_payment_mngmt/screens/bid_payment_processing_screen.dart';
import 'package:real_time_pawn/features/bid_payment_mngmt/screens/select_bid_payment_method_screen.dart';
import 'package:real_time_pawn/features/loan_application_mngmt/screens/Loan%20application%20upload%20screen.dart';
import 'package:real_time_pawn/features/loan_application_mngmt/screens/loan_application_details_screen.dart';
import 'package:real_time_pawn/features/loan_application_mngmt/screens/loan_applications_list_screen.dart';
import 'package:real_time_pawn/features/loan_mngmt/screens/loan_mngmt_charges_screen.dart';
import 'package:real_time_pawn/features/loan_mngmt/screens/loan_mngmt_details_screen.dart';
import 'package:real_time_pawn/features/loan_mngmt/screens/loan_mngmt_screen.dart';
import 'package:real_time_pawn/features/loan_terms_mngmt/screens/loan_term_mngmt_details_screen.dart';
import 'package:real_time_pawn/features/loan_terms_mngmt/screens/loan_term_mngmt_timeline_screen.dart';
import 'package:real_time_pawn/features/loan_terms_mngmt/screens/loan_terms_mngmt_screen.dart';
import 'package:real_time_pawn/features/loan_terms_mngmt/screens/renew_loan_term_mngmt_screen.dart';
import 'package:real_time_pawn/features/payments_mngmt/screens/create_payment_screen.dart';
import 'package:real_time_pawn/features/payments_mngmt/screens/loan_payment_details_screen.dart';
import 'package:real_time_pawn/features/payments_mngmt/screens/payment_list_screen.dart';
import 'package:real_time_pawn/features/support_mngmt/screens/create_ticket_screen.dart';
import 'package:real_time_pawn/features/support_mngmt/screens/ticket_detail_screen.dart';
import 'package:real_time_pawn/features/support_mngmt/screens/ticket_list_screen.dart';
import 'package:real_time_pawn/features/welcome_page/splash_screen.dart';
import 'package:real_time_pawn/core/utils/page_transitions_classes.dart';
import 'package:real_time_pawn/models/loan_terms_model.dart';
import 'features/auth_mngmt/screens/account_verification_screen.dart';
import 'features/auth_mngmt/screens/confirm_email_screen.dart';
import 'features/auth_mngmt/screens/reset_password_screen.dart'
    show ResetPasswordScreen;
import 'features/faq_mngmt/screens/faq_mngmt_screen.dart';
import 'features/home_management/screens/home_screen.dart';
import 'features/home_management/screens/main_screen.dart';
import 'models/loan_application_model.dart';
// import 'package:mrpace/features/about_management/screens/about_screen.dart';
// import 'package:mrpace/features/auth_management/Screens/account_verfication.dart';
// import 'package:mrpace/features/auth_management/Screens/confirm_email.dart';
// import 'package:mrpace/features/auth_management/Screens/forgot_password.dart';
// import 'package:mrpace/features/auth_management/Screens/reset_password.dart';
// import 'package:mrpace/features/auth_management/Screens/sign_in.dart';
// import 'package:mrpace/features/auth_management/Screens/sign_up_page.dart';
// import 'package:mrpace/features/auth_management/Screens/verifyOtpScreen.dart';
// import 'package:mrpace/features/cart_management/controller/cart_controller.dart';
// import 'package:mrpace/features/cart_management/screen/cart_item_detail.dart';
// import 'package:mrpace/features/cart_management/screen/cart_screen.dart';
// import 'package:mrpace/features/coaching_course_management/screen/all_coaching_courses_screen.dart';
// import 'package:mrpace/features/coaching_course_management/screen/view_coaching_course_screen.dart';
// import 'package:mrpace/features/course_booking_management/screens/all_course_booking.dart';
// import 'package:mrpace/features/course_booking_management/screens/course_booking_success_screen.dart'; // Add this import
// import 'package:mrpace/features/course_booking_management/screens/view_coaching_course_detail_screen.dart';
// import 'package:mrpace/features/faq_management/screens/faq_screen.dart';
// import 'package:mrpace/features/help_and_support_management/screens/help_and_suport.dart';
// import 'package:mrpace/features/home_management/screens/home_screen.dart';
// import 'package:mrpace/features/home_management/screens/main_home_page.dart'
//     show MainHomePage;
// import 'package:mrpace/features/injury_management/screens/injury_solution_detail_screen.dart'
//     show InjurySolutionDetailScreen;
// import 'package:mrpace/features/membership_management/screens/membership_screen.dart';
// import 'package:mrpace/features/orders_management/screeens/all_orders_screen.dart';
// import 'package:mrpace/features/orders_management/screeens/order_detail_screen.dart';
// import 'package:mrpace/features/orders_management/screeens/order_success_screen.dart';
// import 'package:mrpace/features/payment_management/screens/payment_success.dart';
// import 'package:mrpace/features/products_management/screens/all_products_screen.dart';
// import 'package:mrpace/features/products_management/screens/product_details_screen.dart';
// import 'package:mrpace/features/profile_management/screens/create_profile_screen.dart';
// import 'package:mrpace/features/profile_management/screens/profile_screen.dart';
// import 'package:mrpace/features/race_experience_management/screens/all_race_experince_screen.dart';
// import 'package:mrpace/features/race_management/screen/all_races_screen.dart';
// import 'package:mrpace/features/race_management/screen/race_details_screen.dart';
// import 'package:mrpace/features/registration_management/screens/all_registration_screen.dart';
// import 'package:mrpace/features/registration_management/screens/race_details_registration.dart';
// import 'package:mrpace/features/registration_management/screens/success_registraion.dart';
// import 'package:mrpace/features/sports_news/screen/sport_news_details_screen.dart';
// import 'package:mrpace/features/sports_news/screen/sports_news_screen.dart';
// import 'package:mrpace/features/training_package_management/screens/all_training_package_screen.dart';
// import 'package:mrpace/features/training_program_management/screens/all_training_program_screens.dart';
// import 'package:mrpace/features/training_program_management/screens/training_program_detail_screen.dart';
// import 'package:mrpace/features/welcome_page/splash_screen.dart';
// import 'package:mrpace/models/all_order_model.dart';
// import 'package:mrpace/models/all_races_model.dart';
// import 'package:mrpace/models/coaching_course_model.dart';
// import 'package:mrpace/models/course_booking_model.dart';
// import 'package:mrpace/models/injury_bought_model.dart';
// import 'package:mrpace/models/product_model.dart';
// import 'package:mrpace/models/registration_model.dart';
// import 'package:mrpace/models/sports_news_model.dart';
// import 'package:mrpace/models/training_bought_package_model.dart';
// import 'package:mrpace/models/training_program_model.dart';
// import 'features/injury_management/screens/all_injury_screen.dart';
// import 'features/training_package_management/screens/training_program_detail_screen.dart';

class AppPages {
  static final pages = [
    GetPage(
      name: RoutesHelper.initialScreen,
      page: () => const SplashScreen(),
      transition: Transition.fadeIn,
      transitionDuration: const Duration(milliseconds: 300),
      customTransition: CustomPageTransition(),
    ),
    GetPage(
      name: RoutesHelper.loginScreen,
      page: () => const Login(),
      transition: Transition.fadeIn,
      transitionDuration: const Duration(milliseconds: 300),
      customTransition: CustomPageTransition(),
    ),

    GetPage(
      name: RoutesHelper.faqScreen,
      page: () => const FaqScreen(),
      transition: Transition.fadeIn,
      transitionDuration: const Duration(milliseconds: 300),
      customTransition: CustomPageTransition(),
    ),
    GetPage(
      name: RoutesHelper.signUpScreen,
      page: () => const SignUp(),
      transition: Transition.fadeIn,
      transitionDuration: const Duration(milliseconds: 300),
      customTransition: CustomPageTransition(),
    ),
    GetPage(
      name: RoutesHelper.ForgotPasswordScreen,
      page: () => const ForgotPasswordScreen(),
      transition: Transition.fadeIn,
      transitionDuration: const Duration(milliseconds: 300),
      customTransition: CustomPageTransition(),
    ),

    // Update your GetPage definition to handle Map
    GetPage(
      name: RoutesHelper.otpVerificationScreen,
      page: () {
        final args = Get.arguments as Map<String, dynamic>;
        final email = args['email'] as String;
        return VerifyOtpScreen(email: email);
      },
      transition: Transition.fadeIn,
      transitionDuration: const Duration(milliseconds: 300),
      customTransition: CustomPageTransition(),
    ),

    GetPage(
      name: RoutesHelper.resetPasswordScreen,
      page: () {
        final arguments = Get.arguments as Map<String, dynamic>;
        return ResetPasswordScreen(
          email: arguments['email'] ?? '',
          otp: arguments['otp'] ?? '',
        );
      },
      transition: Transition.fadeIn,
      transitionDuration: const Duration(milliseconds: 300),
      customTransition: CustomPageTransition(),
    ),
    GetPage(
      name: RoutesHelper.EmailVerificationScreen,
      page: () {
        final String email = Get.arguments as String;
        return EmailVerificationScreen(email: email);
      },
      transition: Transition.fadeIn,
      transitionDuration: const Duration(milliseconds: 300),
      customTransition: CustomPageTransition(),
    ),

    GetPage(
      name: RoutesHelper.AccountVerificationSuccessful,
      page: () => const AccountVerificationSuccessful(),
      transition: Transition.fadeIn,
      transitionDuration: const Duration(milliseconds: 300),
      customTransition: CustomPageTransition(),
    ),
    GetPage(
      name: RoutesHelper.HomePage,
      page: () => const HomePage(),
      transition: Transition.fadeIn,
      transitionDuration: const Duration(milliseconds: 300),
      customTransition: CustomPageTransition(),
    ),

    GetPage(
      name: RoutesHelper.main_home_page,
      page: () => const MainHomePage(),
      transition: Transition.fadeIn,
      transitionDuration: const Duration(milliseconds: 300),
      customTransition: CustomPageTransition(),
    ),

    GetPage(
      name: RoutesHelper.loanApplicationsScreen,
      page: () {
        // Safely extract customerUserId from arguments
        final args = Get.arguments;
        String customerUserId;

        if (args is Map && args['customerUserId'] != null) {
          // If arguments is a Map with customerUserId key
          customerUserId = args['customerUserId'] as String;
        } else if (args is String) {
          // If arguments is directly a String
          customerUserId = args;
        } else {
          // Fallback - throw error or return error screen
          throw Exception(
            'Customer User ID is required for Loan Applications screen',
          );
        }

        return LoanApplicationsListScreen(customerUserId: customerUserId);
      },
      transition: Transition.fadeIn,
      transitionDuration: const Duration(milliseconds: 300),
    ),

    GetPage(
      name: RoutesHelper.loanApplicationDetailsScreen,
      page: () {
        final application = Get.arguments as LoanApplicationModel;
        return LoanApplicationDetailsScreen(application: application);
      },
      transition: Transition.fadeIn,
      transitionDuration: const Duration(milliseconds: 300),
      customTransition: CustomPageTransition(),
    ),

    // Add this after your loanApplicationDetailsScreen GetPage
    GetPage(
      name: RoutesHelper.loanApplicationUploadScreen,
      page: () {
        final arguments = Get.arguments as Map<String, dynamic>;
        return LoanApplicationUploadScreen(
          loanId: arguments['loanId'] ?? '',
          loanCategory: arguments['loanCategory'] ?? '',
          applicationNo: arguments['applicationNo'] ?? '',
          userId: arguments['userId'] ?? '', // Add user ID parameter
        );
      },
      transition: Transition.fadeIn,
      transitionDuration: const Duration(milliseconds: 300),
      customTransition: CustomPageTransition(),
    ),

    // Loans Screen
    GetPage(
      name: RoutesHelper.LoansScreen,
      page: () => const LoansScreen(),
      transition: Transition.fadeIn,
      transitionDuration: const Duration(milliseconds: 300),
      customTransition: CustomPageTransition(),
    ),

    // Loan Details Screen - Extract loanId from arguments
    GetPage(
      name: RoutesHelper.LoanDetailsScreen,
      page: () {
        final arguments = Get.arguments as Map<String, dynamic>;
        return LoanDetailsScreen(loanId: arguments['loanId'] ?? '');
      },
      transition: Transition.fadeIn,
      transitionDuration: const Duration(milliseconds: 300),
      customTransition: CustomPageTransition(),
    ),

    // Loan Charges Screen - Extract loanId from arguments
    GetPage(
      name: RoutesHelper.LoanChargesScreen,
      page: () {
        final arguments = Get.arguments as Map<String, dynamic>;
        return LoanChargesScreen(loanId: arguments['loanId'] ?? '');
      },
      transition: Transition.fadeIn,
      transitionDuration: const Duration(milliseconds: 300),
      customTransition: CustomPageTransition(),
    ),

    // Loan Terms Pages
    GetPage(
      name: RoutesHelper.loanTermsScreen,
      page: () {
        final arguments = Get.arguments as Map<String, dynamic>;
        return LoanTermsScreen(
          loanId: arguments['loanId'] ?? '',
          loanNo: arguments['loanNo'] ?? '',
        );
      },
      transition: Transition.fadeIn,
      transitionDuration: const Duration(milliseconds: 300),
      customTransition: CustomPageTransition(),
    ),

    GetPage(
      name: RoutesHelper.loanTermDetailsScreen,
      page: () {
        final arguments = Get.arguments as Map<String, dynamic>;
        return LoanTermDetailsScreen(
          termId: arguments['termId'] ?? '',
          loanId: arguments['loanId'] ?? '',
        );
      },
      transition: Transition.fadeIn,
      transitionDuration: const Duration(milliseconds: 300),
      customTransition: CustomPageTransition(),
    ),

    GetPage(
      name: RoutesHelper.loanTermTimelineScreen,
      page: () {
        final arguments = Get.arguments as Map<String, dynamic>;
        return LoanTermTimelineScreen(loanId: arguments['loanId'] ?? '');
      },
      transition: Transition.fadeIn,
      transitionDuration: const Duration(milliseconds: 300),
      customTransition: CustomPageTransition(),
    ),

    GetPage(
      name: RoutesHelper.renewLoanTermScreen,
      page: () {
        final arguments = Get.arguments as Map<String, dynamic>;
        return RenewLoanTermScreen(
          loanId: arguments['loanId'] ?? '',
          currentTerm: arguments['currentTerm'] as LoanTerm?,
        );
      },
      transition: Transition.fadeIn,
      transitionDuration: const Duration(milliseconds: 300),
      customTransition: CustomPageTransition(),
    ),

    GetPage(
      name: RoutesHelper.PaymentListScreen,
      page: () {
        final arguments = Get.arguments as Map<String, dynamic>? ?? {};
        return PaymentListScreen(
          loanId: arguments['loanId'],
          isLoanPayments: arguments['loanId'] != null,
        );
      },
      transition: Transition.fadeIn,
      transitionDuration: const Duration(milliseconds: 300),
      customTransition: CustomPageTransition(),
    ),

    // ✅ LOAN PAYMENT DETAILS - CORRECT
    GetPage(
      name: RoutesHelper.PaymentDetailsScreen,
      page: () {
        final arguments = Get.arguments as Map<String, dynamic>;
        print(
          '🔍 Router - Navigating to PaymentDetailsScreen with paymentId: ${arguments['paymentId']}',
        );
        return LoanPaymentDetailsScreen(
          paymentId: arguments['paymentId'] ?? '',
        );
      },
      transition: Transition.fadeIn,
      transitionDuration: const Duration(milliseconds: 300),
    ),

    // Create Payment Screen - requires loanId, optional amount and chargesData
    GetPage(
      name: RoutesHelper.CreatePaymentScreen,
      page: () {
        final arguments = Get.arguments as Map<String, dynamic>;
        return CreatePaymentScreen(
          loanId: arguments['loanId'] ?? '',
          initialAmount: (arguments['amount'] as num?)?.toDouble(),
          chargesData: arguments['charges'],
        );
      },
      transition: Transition.fadeIn,
      transitionDuration: const Duration(milliseconds: 300),
      customTransition: CustomPageTransition(),
    ),

    // =============================================
    // AUCTION ROUTES
    // =============================================

    // Auctions List Screen
    GetPage(
      name: RoutesHelper.auctionsListScreen,
      page: () => const AuctionsListScreen(),
      transition: Transition.fadeIn,
      transitionDuration: const Duration(milliseconds: 300),
      customTransition: CustomPageTransition(),
    ),

    // Live Auctions Screen
    GetPage(
      name: RoutesHelper.liveAuctionsScreen,
      page: () => const LiveAuctionsScreen(),
      transition: Transition.fadeIn,
      transitionDuration: const Duration(milliseconds: 300),
      customTransition: CustomPageTransition(),
    ),

    // Auction Details Screen - With parameter extraction
    GetPage(
      name: RoutesHelper.auctionDetailsScreen,
      page: () {
        final auctionId = Get.parameters['id'] ?? '';
        return AuctionDetailsScreen(auctionId: auctionId);
      },
      transition: Transition.fadeIn,
      transitionDuration: const Duration(milliseconds: 300),
      customTransition: CustomPageTransition(),
    ),

    // Search Auctions Screen
    GetPage(
      name: RoutesHelper.searchAuctionsScreen,
      page: () => const SearchAuctionsScreen(),
      transition: Transition.fadeIn,
      transitionDuration: const Duration(milliseconds: 300),
      customTransition: CustomPageTransition(),
    ),

    // Auction Bids Screen - With parameter extraction
    // ✅ BID PAYMENT DETAILS - CORRECT
    GetPage(
      name: RoutesHelper.bidPaymentDetailsScreen, // ← USE DIFFERENT ROUTE NAME
      page: () {
        final arguments = Get.arguments as Map<String, dynamic>;
        return BidPaymentDetailsScreen(paymentId: arguments['paymentId'] ?? '');
      },
      transition: Transition.fadeIn,
      transitionDuration: const Duration(milliseconds: 300),
      customTransition: CustomPageTransition(),
    ),

    GetPage(
      name: RoutesHelper.auctionBidsScreen,
      page: () {
        final auctionId = Get.parameters['id'] ?? '';
        // Get auction title from arguments if available
        final args = Get.arguments as Map<String, dynamic>?;
        return AuctionBidsScreen(
          auctionId: auctionId,
          auctionTitle: args?['auctionTitle'] ?? 'Auction Details',
        );
      },
      transition: Transition.fadeIn,
      transitionDuration: const Duration(milliseconds: 300),
      customTransition: CustomPageTransition(),
    ),
    // Bidding History
    GetPage(
      name: RoutesHelper.userBiddingHistoryScreen,
      page: () => const UserBiddingHistoryScreen(),
      transition: Transition.fadeIn,
      transitionDuration: const Duration(milliseconds: 300),
      customTransition: CustomPageTransition(),
    ),

    // =============================================
    // BID MANAGEMENT ROUTES
    // =============================================

    // My Bids Screen
    GetPage(
      name: RoutesHelper.myBidsScreen,
      page: () => const MyBidsScreen(),
      transition: Transition.fadeIn,
      transitionDuration: const Duration(milliseconds: 300),
      customTransition: CustomPageTransition(),
    ),

    // Bid Details Screen - With parameter extraction
    GetPage(
      name: RoutesHelper.bidDetailsScreen,
      page: () {
        final bidId = Get.parameters['id'] ?? '';
        return BidDetailsScreen(bidId: bidId);
      },
      transition: Transition.fadeIn,
      transitionDuration: const Duration(milliseconds: 300),
      customTransition: CustomPageTransition(),
    ),

    // =============================================
    // BID PAYMENT ROUTES
    // =============================================

    // My Bid Payments Screen (already works)
    GetPage(
      name: RoutesHelper.myBidPaymentsScreen,
      page: () => const MyBidPaymentsScreen(),
      transition: Transition.fadeIn,
      transitionDuration: const Duration(milliseconds: 300),
      customTransition: CustomPageTransition(),
    ),

    // 🔴 ADD THIS MISSING ROUTE:
    GetPage(
      name: RoutesHelper.selectPaymentMethodScreen,
      page: () {
        final args = Get.arguments as Map<String, dynamic>;
        return SelectPaymentMethodScreen(
          bidId: args['bidId'] ?? '',
          amount: args['amount'] ?? 0.0,
        );
      },
      transition: Transition.fadeIn,
      transitionDuration: const Duration(milliseconds: 300),
      customTransition: CustomPageTransition(),
    ),

    // Confirm Bid Payment Screen - With arguments
    GetPage(
      name: RoutesHelper.confirmBidPaymentScreen,
      page: () {
        return ConfirmBidPaymentScreen();
      },
      transition: Transition.fadeIn,
      transitionDuration: const Duration(milliseconds: 300),
      customTransition: CustomPageTransition(),
    ),

    // =============================================
    // SUPPORT TICKET ROUTES (YOUR SCREENS ONLY)
    // =============================================

    // Create New Ticket (your CreateTicketScreen)
    GetPage(
      name: RoutesHelper.createTicketScreen,
      page: () => const CreateTicketScreen(),
      transition: Transition.fadeIn,
      transitionDuration: const Duration(milliseconds: 300),
      customTransition: CustomPageTransition(),
    ),

    // Ticket List (your TicketListScreen)
    GetPage(
      name: RoutesHelper.ticketListScreen,
      page: () => const TicketListScreen(),
      transition: Transition.fadeIn,
      transitionDuration: const Duration(milliseconds: 300),
      customTransition: CustomPageTransition(),
    ),

    // Ticket Details - With parameter extraction
    GetPage(
      name: RoutesHelper.ticketDetailsScreen,
      page: () {
        final ticketId = Get.parameters['id'] ?? '';
        return TicketDetailScreen(ticketId: ticketId);
      },
      transition: Transition.fadeIn,
      transitionDuration: const Duration(milliseconds: 300),
      customTransition: CustomPageTransition(),
    ),

    GetPage(
      name: RoutesHelper.paymentProcessingScreen,
      page: () {
        final args = Get.arguments as Map<String, dynamic>;
        return PaymentProcessingScreen(payment: args['payment']);
      },
      transition: Transition.fadeIn,
      transitionDuration: const Duration(milliseconds: 300),
    ),

    // File: lib/config/routers/app_pages.dart - Add this GetPage
    GetPage(
      name: RoutesHelper.aboutScreen,
      page: () => const AboutScreen(),
      transition: Transition.fadeIn,
      transitionDuration: const Duration(milliseconds: 300),
      customTransition: CustomPageTransition(),
    ),

    // File: lib/config/routers/app_pages.dart - Add this GetPage
    GetPage(
      name: '/faq',
      page: () => const FaqScreen(),
      transition: Transition.fadeIn,
      transitionDuration: const Duration(milliseconds: 300),
      customTransition: CustomPageTransition(),
    ),

    // Select Payment Method Screen - You need to create this
    // GetPage(
    //   name: RoutesHelper.selectPaymentMethodScreen,
    //   page: () {
    //     final args = Get.arguments as Map<String, dynamic>;
    //     return SelectPaymentMethodScreen(
    //       bidId: args['bidId'] ?? '',
    //       amount: (args['amount'] as num).toDouble(),
    //     );
    //   },
    //   transition: Transition.fadeIn,
    //   transitionDuration: const Duration(milliseconds: 300),
    //   customTransition: CustomPageTransition(),
    // ),

    // Payment Details Screen - Create this screen or skip for now
    // GetPage(
    //   name: RoutesHelper.paymentDetailsScreen,
    //   page: () {
    //     final paymentId = Get.parameters['id'] ?? '';
    //     return PaymentDetailsScreen(paymentId: paymentId);
    //   },
    //   transition: Transition.fadeIn,
    //   transitionDuration: const Duration(milliseconds: 300),
    //   customTransition: CustomPageTransition(),
    // ),

    // GetPage(
    //   name: RoutesHelper.all_races_page,
    //   page: () => const AllRacesScreen(),
    //   transition: Transition.fadeIn,
    //   transitionDuration: const Duration(milliseconds: 300),
    //   customTransition: CustomPageTransition(),
    // ),
    // GetPage(
    //   name: RoutesHelper.raceDetailsPage,
    //   page: () {
    //     final race = Get.arguments as AllRacesModel;
    //     return RaceDetailsScreen(race: race);
    //   },
    //   transition: Transition.fadeIn,
    //   transitionDuration: const Duration(milliseconds: 300),
    //   customTransition: CustomPageTransition(),
    // ),
    // GetPage(
    //   name: RoutesHelper.successRegistration,
    //   page: () {
    //     final args = Get.arguments as Map<String, dynamic>;
    //     return RaceRegistrationSuccess(
    //       raceName: args['raceName'],
    //       raceEvent: args['raceEvent'],
    //       registrationPrice: args['registrationPrice'],
    //       registration_number: args['registration_number'],
    //     );
    //   },
    //   transition: Transition.fadeIn,
    //   transitionDuration: const Duration(milliseconds: 300),
    //   customTransition: CustomPageTransition(),
    // ),
    // // GetPage(
    //   name: RoutesHelper.paymentPage,
    //   page: () {
    //     final args = Get.arguments as Map<String, dynamic>;
    //     return PaymentSuccess(phoneNumber: args['phoneNumber']);
    //   },
    //   transition: Transition.fadeIn,
    //   transitionDuration: const Duration(milliseconds: 300),
    //   customTransition: CustomPageTransition(),
    // ),

    // GetPage(
    //   name: RoutesHelper.profileScreen,
    //   page: () {
    //     return ProfileScreen();
    //   },
    //   transition: Transition.fadeIn,
    //   transitionDuration: const Duration(milliseconds: 300),
    //   customTransition: CustomPageTransition(),
    // ),

    // GetPage(
    //   name: RoutesHelper.allRegistrationsPage,
    //   page: () => const RegisteredRacesScreen(),
    //   transition: Transition.fadeIn,
    //   transitionDuration: const Duration(milliseconds: 300),
    //   customTransition: CustomPageTransition(),
    // ),

    // GetPage(
    //   name: RoutesHelper.allProductsScreen,
    //   page: () => const AllProductsScreen(),
    //   transition: Transition.fadeIn,
    //   transitionDuration: const Duration(milliseconds: 300),
    //   customTransition: CustomPageTransition(),
    // ),

    // GetPage(
    //   name: RoutesHelper.aboutScreen,
    //   page: () => const AboutScreen(),
    //   transition: Transition.fadeIn,
    //   transitionDuration: const Duration(milliseconds: 300),
    //   customTransition: CustomPageTransition(),
    // ),
    // GetPage(
    //   name: RoutesHelper.helpAndSupportScreen,
    //   page: () => const HelpSupportScreen(),
    //   transition: Transition.fadeIn,
    //   transitionDuration: const Duration(milliseconds: 300),
    //   customTransition: CustomPageTransition(),
    // ),

    // GetPage(
    //   name: RoutesHelper.registrationDetailsPage,
    //   page: () {
    //     final registration = Get.arguments as RegistrationModel;
    //     return ViewRegistrationDetails(registration: registration);
    //   },
    //   transition: Transition.fadeIn,
    //   transitionDuration: const Duration(milliseconds: 300),
    //   customTransition: CustomPageTransition(),
    // ),
    // GetPage(
    //   name: RoutesHelper.productDetailsScreen,
    //   page: () {
    //     final product = Get.arguments as ProductModel;
    //     return ProductDetailScreen(product: product);
    //   },
    //   transition: Transition.fadeIn,
    //   transitionDuration: const Duration(milliseconds: 300),
    //   customTransition: CustomPageTransition(),
    // ),
    // GetPage(
    //   name: RoutesHelper.cartItemDetailsScreen,
    //   page: () {
    //     final product = Get.arguments as CartItem;
    //     return CartItemDetailsScreen(cartItem: product);
    //   },
    //   transition: Transition.fadeIn,
    //   transitionDuration: const Duration(milliseconds: 300),
    //   customTransition: CustomPageTransition(),
    // ),
    // GetPage(
    //   name: RoutesHelper.cartScreen,
    //   page: () => const ProductsInCartScreen(),
    //   transition: Transition.fadeIn,
    //   transitionDuration: const Duration(milliseconds: 300),
    //   customTransition: CustomPageTransition(),
    // ),

    // GetPage(
    //   name: RoutesHelper.orderSuccessScreen,
    //   page: () => const OrderSuccessScreen(),
    //   transition: Transition.fadeIn,
    //   transitionDuration: const Duration(milliseconds: 300),
    //   customTransition: CustomPageTransition(),
    // ),
    // GetPage(
    //   name: RoutesHelper.allOrdersScreen,
    //   page: () => const AllOrderScreen(),
    //   transition: Transition.fadeIn,
    //   transitionDuration: const Duration(milliseconds: 300),
    //   customTransition: CustomPageTransition(),
    // ),
    // GetPage(
    //   name: RoutesHelper.orderDetailScreen,
    //   page: () {
    //     final order = Get.arguments as AllOrderModel;
    //     return AllOrderModelDetailScreen(order: order);
    //   },
    //   transition: Transition.fadeIn,
    //   transitionDuration: const Duration(milliseconds: 300),
    //   customTransition: CustomPageTransition(),
    // ),
    // GetPage(
    //   name: RoutesHelper.allNewsScreen,
    //   page: () => const AllSportNewsScreen(),
    //   transition: Transition.fadeIn,
    //   transitionDuration: const Duration(milliseconds: 300),
    //   customTransition: CustomPageTransition(),
    // ),
    // GetPage(
    //   name: RoutesHelper.newsDetailScreen,
    //   page: () {
    //     final newsModel = Get.arguments as SportNewsModel;
    //     return NewsDetailsScreen(newsModel: newsModel);
    //   },
    //   transition: Transition.fadeIn,
    //   transitionDuration: const Duration(milliseconds: 300),
    //   customTransition: CustomPageTransition(),
    // ),
    // GetPage(
    //   name: RoutesHelper.allNewsScreen,
    //   page: () => const AllSportNewsScreen(),
    //   transition: Transition.fadeIn,
    //   transitionDuration: const Duration(milliseconds: 300),
    //   customTransition: CustomPageTransition(),
    // ),
    // GetPage(
    //   name: RoutesHelper.createProfileScreen,
    //   page: () => const CreateProfileScreen(),
    //   transition: Transition.fadeIn,
    //   transitionDuration: const Duration(milliseconds: 300),
    //   customTransition: CustomPageTransition(),
    // ),
    // GetPage(
    //   name: RoutesHelper.viewCoachingCourseDetails,
    //   page: () {
    //     final course = Get.arguments as CoachingCourseModel;
    //     return ViewCoachingCourseDetailsScreen(course: course);
    //   },
    //   transition: Transition.fadeIn,
    //   transitionDuration: const Duration(milliseconds: 300),
    //   customTransition: CustomPageTransition(),
    // ),
    // GetPage(
    //   name: RoutesHelper.allCoachingCourseScreen,
    //   page: () => const AllCoachingCourseScreen(),
    //   transition: Transition.fadeIn,
    //   transitionDuration: const Duration(milliseconds: 300),
    //   customTransition: CustomPageTransition(),
    // ),

    // GetPage(
    //   name: RoutesHelper.viewCourseBookingDetails,
    //   page: () {
    //     final booking = Get.arguments as CourseBookingModel;
    //     return ViewCourseBookingDetailsScreen(booking: booking);
    //   },
    //   transition: Transition.fadeIn,
    //   transitionDuration: const Duration(milliseconds: 300),
    //   customTransition: CustomPageTransition(),
    // ),

    // GetPage(
    //   name: RoutesHelper.allCourseBookingsScreen,
    //   page: () => const AllCourseBookingsScreen(),
    //   transition: Transition.fadeIn,
    //   transitionDuration: const Duration(milliseconds: 300),
    //   customTransition: CustomPageTransition(),
    // ),

    // // Add the CourseBookingSuccess route
    // GetPage(
    //   name: RoutesHelper.coachingCourseBookingSuccess,
    //   page: () {
    //     final args = Get.arguments as Map<String, dynamic>;
    //     return CourseBookingSuccess(
    //       courseName: args['courseName'],
    //       bookingPrice: args['bookingPrice'],
    //       courseBookingId: args['courseBookingId'],
    //     );
    //   },
    //   transition: Transition.fadeIn,
    //   transitionDuration: const Duration(milliseconds: 300),
    //   customTransition: CustomPageTransition(),
    // ),
    // GetPage(
    //   name: RoutesHelper.trainingPackagesScreen,
    //   page: () => const AllTrainingPackagesScreen(),
    //   transition: Transition.fadeIn,
    //   transitionDuration: const Duration(milliseconds: 300),
    //   customTransition: CustomPageTransition(),
    // ),

    // GetPage(
    //   name: RoutesHelper.trainingProgramDetailScreen,
    //   page: () {
    //     final trainingpackageBoughtModel =
    //         Get.arguments as TrainingPackageBoughtModel;
    //     return TrainingProgramDetailScreen(
    //       trainingPackage: trainingpackageBoughtModel,
    //     );
    //   },
    //   transition: Transition.fadeIn,
    //   transitionDuration: const Duration(milliseconds: 300),
    //   customTransition: CustomPageTransition(),
    // ),
    // GetPage(
    //   name: RoutesHelper.allInjuriesManagementScreen,
    //   page: () => const AllInjuriesManagementScreen(),
    //   transition: Transition.fadeIn,
    //   transitionDuration: const Duration(milliseconds: 300),
    //   customTransition: CustomPageTransition(),
    // ),

    // GetPage(
    //   name: RoutesHelper.injuryDetailsScreen,
    //   page: () {
    //     final injurysolutionModel = Get.arguments as InjuryBoughtModel;
    //     return InjurySolutionDetailScreen(injurySolution: injurysolutionModel);
    //   },
    //   transition: Transition.fadeIn,
    //   transitionDuration: const Duration(milliseconds: 300),
    //   customTransition: CustomPageTransition(),
    // ),

    // GetPage(
    //   name: RoutesHelper.membershipScreen,
    //   page: () => const MembershipScreen(),
    //   transition: Transition.fadeIn,
    //   transitionDuration: const Duration(milliseconds: 300),
    //   customTransition: CustomPageTransition(),
    // ),
    // GetPage(
    //   name: RoutesHelper.allTrainingProgram,
    //   page: () => const AllTrainingProgramScreen(),
    //   transition: Transition.fadeIn,
    //   transitionDuration: const Duration(milliseconds: 300),
    //   customTransition: CustomPageTransition(),
    // ),
    // GetPage(
    //   name: RoutesHelper.trainingProgramDetailsScreen,
    //   page: () {
    //     final trainingProgramModel = Get.arguments as TrainingProgramModel;
    //     return TrainingProgramDetailScreenFirst(
    //       trainingProgram: trainingProgramModel,
    //     );
    //   },
    //   transition: Transition.fadeIn,
    //   transitionDuration: const Duration(milliseconds: 300),
    //   customTransition: CustomPageTransition(),
    // ),
    // GetPage(
    //   name: RoutesHelper.allRaceExperienceScreen,
    //   page: () {
    //     final arguments = Get.arguments as Map<String, dynamic>;
    //     return AllRacesExperienceScreen(
    //       userId: arguments['userId'] ?? '',
    //       membershipId: arguments['membershipId'] ?? '',
    //     );
    //   },
    //   transition: Transition.fadeIn,
    //   transitionDuration: const Duration(milliseconds: 300),
    //   customTransition: CustomPageTransition(),
    // ),
  ];
}
