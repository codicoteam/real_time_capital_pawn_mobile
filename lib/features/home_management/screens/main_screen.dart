import 'package:flutter/material.dart';
import 'package:persistent_bottom_nav_bar/persistent_bottom_nav_bar.dart';
import 'package:real_time_pawn/widgets/drawers/customer_drawer.dart';
import 'package:real_time_pawn/widgets/drawers/customer_drawer.dart'
    show CustomDrawer;

import '../../../core/utils/pallete.dart';
import '../../profile_mngmt/screens/profile_screen.dart' as MyProfile;
import 'home_screen.dart';
import '../../loan_application_mngmt/screens/loan_application_step1.dart'; // ADD THIS

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

  // List of pages for bottom navigation
  final List<Widget> _pages = [
    HomePage(),

    Container(
      color: AppColors.backgroundColor,
      child: const Center(
        child: Text('Loans Page', style: TextStyle(fontSize: 24)),
      ),
    ),

    // 👇 EMPTY CONTAINER - We'll navigate instead
    Container(color: AppColors.backgroundColor),

    Container(
      color: AppColors.backgroundColor,
      child: const Center(
        child: Text('Notifications', style: TextStyle(fontSize: 24)),
      ),
    ),

    MyProfile.ProfileScreen(),
  ];

  void _openDrawer() {
    _scaffoldKey.currentState?.openDrawer();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      drawer: CustomDrawer(
        userName: 'Guest',
        userEmail: 'guest@example.com',
        userId: '',
      ),
      body: PersistentTabView(
        context,
        controller: _tabController,
        screens: _pages,
        items: _navBarsItems(),
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
          if (index == 2) {
            // Center "Apply" button
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const LoanApplicationStep1(),
              ),
            );
            // Reset to home tab
            Future.delayed(Duration.zero, () {
              _tabController.index = 0;
            });
          }
        },
      ),
    );
  }

  List<PersistentBottomNavBarItem> _navBarsItems() {
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
      // 👇 APPLY LOAN (CENTER BUTTON)
      PersistentBottomNavBarItem(
        icon: const Icon(Icons.add_circle, size: 40),
        title: "Apply",
        activeColorPrimary: AppColors.primaryColor,
        inactiveColorPrimary: AppColors.primaryColor,
        activeColorSecondary: AppColors.backgroundColor,
      ),
      PersistentBottomNavBarItem(
        icon: const Icon(Icons.notifications_rounded, size: 24),
        title: "Alerts",
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
