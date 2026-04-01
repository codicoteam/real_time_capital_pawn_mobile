import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:persistent_bottom_nav_bar/persistent_bottom_nav_bar.dart';
import 'package:real_time_pawn/features/auctions_mngmt/screens/auctions_list_screen.dart'
    show AuctionsListScreen;
import 'package:real_time_pawn/features/profile_mngmt/controllers/profile_mngmt_controller.dart';

import '../../../config/routers/router.dart';
import '../../../core/utils/pallete.dart';
import '../../../global/user_controller.dart';
import '../../../widgets/drawers/customer_drawer.dart';

import '../../loan_mngmt/screens/loan_mngmt_screen.dart';
import '../../profile_mngmt/screens/profile_mngmt_screen.dart' as MyProfile;
import 'home_screen.dart';

class MainHomePage extends StatefulWidget {
  const MainHomePage({super.key});

  @override
  State<MainHomePage> createState() => _MainHomePageState();
}

class _MainHomePageState extends State<MainHomePage> {
  final PersistentTabController _tabController = PersistentTabController(
    initialIndex: 0,
  );
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  final UserController userController = Get.find<UserController>();

  // Initialize ProfileController if not already done
  late final ProfileController _profileController;

  @override
  void initState() {
    super.initState();
    // Initialize ProfileController
    _profileController = Get.put(ProfileController(), permanent: true);

    // Fetch user profile data when the page loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _profileController.fetchUserProfile();
    });
  }

  // Actual screens for each tab
  final List<Widget> _pages = [
    const HomePage(),
    const LoansScreen(), // Loans tab now shows real LoansScreen
    Container(
      color: AppColors.backgroundColor,
    ), // Apply placeholder (navigation only)
    const AuctionsListScreen(), // Auction tab shows real AuctionsListScreen
    const MyProfile.ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      // Remove the parameters - CustomDrawer now gets data from ProfileController
      drawer: CustomDrawer(),
      body: PersistentTabView(
        context,
        controller: _tabController,
        screens: _pages,
        items: _navBarItems(),
        backgroundColor: AppColors.surfaceColor,
        navBarStyle: NavBarStyle.style15,
        navBarHeight: 65,
        decoration: NavBarDecoration(
          borderRadius: BorderRadius.circular(12),
          colorBehindNavBar: Colors.transparent,
          boxShadow: [
            BoxShadow(
              color: AppColors.borderColor.withOpacity(0.5),
              offset: const Offset(5, 5),
              blurRadius: 5,
            ),
            BoxShadow(
              color: AppColors.backgroundColor,
              offset: const Offset(3, 3),
              blurRadius: 6,
            ),
          ],
        ),
        handleAndroidBackButtonPress: true,
        resizeToAvoidBottomInset: true,
        stateManagement: true,
        onItemSelected: (index) {
          // Only the Apply tab (index 2) triggers navigation + reset
          if (index == 2) {
            // Immediately jump back to Home to avoid visual flicker
            _tabController.jumpToTab(0);
            // Navigate to the loan application screen
            Get.toNamed(RoutesHelper.createLoanApplication);
          }
          // All other tabs (0,1,3,4) simply stay on their screen – no extra navigation
        },
      ),
    );
  }

  List<PersistentBottomNavBarItem> _navBarItems() {
    return [
      PersistentBottomNavBarItem(
        icon: const Icon(Icons.home_rounded, size: 24),
        title: "Home",
        activeColorPrimary: AppColors.primaryColor,
        inactiveColorPrimary: AppColors.subtextColor,
        activeColorSecondary: AppColors.primaryColor,
      ),
      PersistentBottomNavBarItem(
        icon: const Icon(Icons.account_balance_wallet_rounded, size: 24),
        title: "Loans",
        activeColorPrimary: AppColors.primaryColor,
        inactiveColorPrimary: AppColors.subtextColor,
        activeColorSecondary: AppColors.primaryColor,
      ),
      PersistentBottomNavBarItem(
        icon: const Icon(Icons.add_circle, size: 40),
        title: "Apply",
        activeColorPrimary: AppColors.primaryColor,
        inactiveColorPrimary: AppColors.primaryColor,
        activeColorSecondary: AppColors.backgroundColor,
      ),
      PersistentBottomNavBarItem(
        icon: const Icon(Icons.gavel_rounded, size: 24),
        title: "Auction",
        activeColorPrimary: AppColors.primaryColor,
        inactiveColorPrimary: AppColors.subtextColor,
        activeColorSecondary: AppColors.primaryColor,
      ),
      PersistentBottomNavBarItem(
        icon: const Icon(Icons.person_rounded, size: 24),
        title: "Profile",
        activeColorPrimary: AppColors.primaryColor,
        inactiveColorPrimary: AppColors.subtextColor,
        activeColorSecondary: AppColors.primaryColor,
      ),
    ];
  }
}
