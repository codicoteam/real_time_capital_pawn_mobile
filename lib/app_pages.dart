import 'package:get/get.dart';
import 'package:real_time_pawn/config/routers/router.dart';
import 'package:real_time_pawn/features/auctions_mngmt/helpers/search_auctions_screen.dart';
import 'package:real_time_pawn/features/auctions_mngmt/screens/auction_bids_screen.dart';
import 'package:real_time_pawn/features/auctions_mngmt/screens/auction_details_screen.dart';
import 'package:real_time_pawn/features/auctions_mngmt/screens/auctions_list_screen.dart';
import 'package:real_time_pawn/features/auctions_mngmt/screens/live_auctions_screen.dart';
import 'package:real_time_pawn/features/auth_mngmt/screens/forgot_password_screen.dart';
import 'package:real_time_pawn/features/auth_mngmt/screens/login_screen.dart';
import 'package:real_time_pawn/features/auth_mngmt/screens/register_screen.dart';
import 'package:real_time_pawn/features/auth_mngmt/screens/verify_otp_screen.dart';
import 'package:real_time_pawn/features/auctions_mngmt/screens/user_bid_history_screen.dart';
import 'package:real_time_pawn/features/loan_application_mngmt/screens/loan_application_details_screen.dart'
    show LoanApplicationDetailsScreen;
import 'package:real_time_pawn/features/loan_application_mngmt/screens/loan_applications_list_screen.dart';
import 'package:real_time_pawn/features/welcome_page/splash_screen.dart';
import 'package:real_time_pawn/core/utils/page_transitions_classes.dart';
import 'package:real_time_pawn/models/loan_application_model.dart';

import 'features/auth_mngmt/screens/account_verification_screen.dart';
import 'features/auth_mngmt/screens/confirm_email_screen.dart';
import 'features/auth_mngmt/screens/reset_password_screen.dart'
    show ResetPasswordScreen;
import 'features/faq_mngmt/screens/faq_mngmt_screen.dart';
import 'features/home_management/screens/home_screen.dart';
import 'features/home_management/screens/main_screen.dart';
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
      page: () => const LoanApplicationsListScreen(),
      transition: Transition.fadeIn,
      transitionDuration: const Duration(milliseconds: 300),
      customTransition: CustomPageTransition(),
    ),

    GetPage(
      name: RoutesHelper.loanApplicationDetailsScreen,
      page: () {
        final application = Get.arguments as LoanApplication;
        return LoanApplicationDetailsScreen(application: application);
      },
      transition: Transition.fadeIn,
      transitionDuration: const Duration(milliseconds: 300),
      customTransition: CustomPageTransition(),
    ),

    // AUCTION SCREENS =========================================
    GetPage(
      name: RoutesHelper.auctionsListScreen,
      page: () => const AuctionsListScreen(),
      transition: Transition.fadeIn,
      transitionDuration: const Duration(milliseconds: 300),
      customTransition: CustomPageTransition(),
    ),

    GetPage(
      name: RoutesHelper.liveAuctionsScreen,
      page: () => const LiveAuctionsScreen(),
      transition: Transition.fadeIn,
      transitionDuration: const Duration(milliseconds: 300),
      customTransition: CustomPageTransition(),
    ),

    GetPage(
      name: RoutesHelper.auctionDetailsScreen,
      page: () {
        // Extract auction ID from route parameters
        final id = Get.parameters['id'] ?? '';
        return AuctionDetailsScreen(auctionId: id);
      },
      transition: Transition.fadeIn,
      transitionDuration: const Duration(milliseconds: 300),
      customTransition: CustomPageTransition(),
    ),
    // Add to AppPages
    GetPage(
      name: RoutesHelper.searchAuctionsScreen,
      page: () => const SearchAuctionsScreen(),
      transition: Transition.fadeIn,
      transitionDuration: const Duration(milliseconds: 300),
      customTransition: CustomPageTransition(),
    ),

    GetPage(
      name: RoutesHelper.auctionBidsScreen,
      page: () {
        final id = Get.parameters['id'] ?? '';
        final title = Get.arguments as String? ?? 'Auction Bids';
        return AuctionBidsScreen(auctionId: id, auctionTitle: title);
      },
      transition: Transition.fadeIn,
      transitionDuration: const Duration(milliseconds: 300),
      customTransition: CustomPageTransition(),
    ),
    // USER BIDDING HISTORY SCREEN ================================
    GetPage(
      name: RoutesHelper.userBiddingHistoryScreen,
      page: () => const UserBiddingHistoryScreen(),
      transition: Transition.fadeIn,
      transitionDuration: const Duration(milliseconds: 300),
      customTransition: CustomPageTransition(),
    ),

    // END AUCTION SCREENS =====================================

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
