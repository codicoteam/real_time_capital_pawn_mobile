import 'package:get/get.dart';
import 'package:real_time_pawn/config/routers/router.dart';
import 'package:real_time_pawn/features/about_mngmt/screens/about_mngmt_screen.dart';
import 'package:real_time_pawn/features/auctions_mngmt/helpers/search_auctions_screen.dart';
import 'package:real_time_pawn/features/auctions_mngmt/screens/auction_bids_screen.dart';
import 'package:real_time_pawn/features/auctions_mngmt/screens/auction_details_screen.dart';
import 'package:real_time_pawn/features/auctions_mngmt/screens/auctions_list_screen.dart';
import 'package:real_time_pawn/features/auctions_mngmt/screens/live_auctions_screen.dart';
import 'package:real_time_pawn/features/auctions_mngmt/screens/user_bid_history_screen.dart';
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
import 'package:real_time_pawn/features/loan_terms_mngmt/screens/loan_terms_display_screen.dart';
import 'package:real_time_pawn/features/payments_mngmt/screens/create_payment_screen.dart';
import 'package:real_time_pawn/features/payments_mngmt/screens/customer_payments_screen.dart';
import 'package:real_time_pawn/features/payments_mngmt/screens/loan_payment_details_screen.dart';
import 'package:real_time_pawn/features/payments_mngmt/screens/payment_list_screen.dart';
import 'package:real_time_pawn/features/support_mngmt/screens/create_ticket_screen.dart';
import 'package:real_time_pawn/features/support_mngmt/screens/ticket_detail_screen.dart';
import 'package:real_time_pawn/features/support_mngmt/screens/ticket_list_screen.dart';
import 'package:real_time_pawn/features/payments_mngmt/screens/welcome_page/splash_screen.dart';
import 'package:real_time_pawn/core/utils/page_transitions_classes.dart';
import 'package:real_time_pawn/models/loan_mngmt_model.dart';
import 'package:real_time_pawn/models/support_ticket_model.dart';
import 'features/auth_mngmt/screens/account_verification_screen.dart';
import 'features/auth_mngmt/screens/confirm_email_screen.dart';
import 'features/auth_mngmt/screens/reset_password_screen.dart'
    show ResetPasswordScreen;
import 'features/faq_mngmt/screens/faq_mngmt_screen.dart';
import 'features/home_management/screens/home_screen.dart';
import 'features/home_management/screens/main_screen.dart';
import 'features/loan_application_mngmt/screens/loan_application_step1.dart' show LoanApplicationScreen;
import 'features/loan_application_mngmt/screens/update_loan_application_screen.dart'
    show UpdateLoanApplicationScreen;
import 'models/loan_application_model.dart';
// import 'package:mrpace/features/about_management/screens/about_screen.dart';
// import 'package:mrpace/features/auth_management/Screens/account_verfication.dart';

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
        final arguments = Get.arguments as Map<String, dynamic>?;
        // Provide a fallback to avoid runtime errors if arguments are missing
        return ResetPasswordScreen(email: arguments?['email'] ?? '');
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
      name: RoutesHelper.createLoanApplication,
      page: () => const LoanApplicationScreen(),
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

    GetPage(
      name: RoutesHelper.updateLoanApplication,
      page: () {
        final application = Get.arguments as LoanApplicationModel;
        return UpdateLoanApplicationScreen(application: application);
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
        final loan = Get.arguments as LoanModel;
        return LoanDetailsScreen(loan: loan);
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
    // REPLACE the old loan terms GetPages with this single one:
    GetPage(
      name: RoutesHelper.loanTermsDisplayScreen,
      page: () {
        final arguments = Get.arguments as Map<String, dynamic>;
        return LoanTermsDisplayScreen(
          loanId: arguments['loanId'] ?? '',
          loanNo: arguments['loanNo'] ?? '',
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
        final ticket = Get.arguments as SupportTicket;
        return TicketDetailScreen(ticket: ticket);
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

    GetPage(
      name: RoutesHelper.CustomerPaymentsScreen,
      page: () => const CustomerPaymentsScreen(),
      transition: Transition.fadeIn,
      transitionDuration: const Duration(milliseconds: 300),
      customTransition: CustomPageTransition(),
    ),
  ];
}
