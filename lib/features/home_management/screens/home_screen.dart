import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:real_time_pawn/core/utils/pallete.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:real_time_pawn/features/home_management/controllers/home_controller.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late final HomeController _homeController;
  int _carouselIndex = 0;

  final List<CarouselItem> _carouselItems = [
    CarouselItem(
      title: 'Loan Application',
      subtitle: 'Apply for quick loans against your assets',
      icon: Icons.assignment,
      buttonText: 'Apply Loan',
      route: '/apply-loan',
    ),
    CarouselItem(
      title: 'Live Auctions',
      subtitle: 'Bid on premium assets up for auction',
      icon: Icons.gavel,
      buttonText: 'Join Now',
      route: '/live-auctions',
    ),
    CarouselItem(
      title: 'Loan Repayment',
      subtitle: 'Make payments for your existing loans',
      icon: Icons.payment,
      buttonText: 'Pay Now',
      route: '/pay-loan',
    ),
  ];

  final List<Map<String, dynamic>> loanTypes = [
    {
      'icon': Icons.directions_car,
      'title': 'Motor Vehicle',
      'color': Colors.blue,
      'route': '/motor-vehicle-loan',
    },
    {
      'icon': Icons.devices,
      'title': 'Electronics',
      'color': Colors.purple,
      'route': '/electronics-loan',
    },
    {
      'icon': Icons.diamond,
      'title': 'Jewelry',
      'color': Colors.amber,
      'route': '/jewelry-loan',
    },
  ];

  final List<Map<String, dynamic>> quickActions = [
    {'icon': Icons.add_chart, 'title': 'New Loan', 'route': '/new-loan'},
    {'icon': Icons.gavel, 'title': 'Auctions', 'route': '/auctions'},
    {'icon': Icons.description, 'title': 'Reports', 'route': '/reports'},
    {'icon': Icons.history, 'title': 'Applications', 'route': '/applications'},
  ];

  @override
  void initState() {
    super.initState();
    _homeController = Get.put(HomeController());
  }

  @override
  void dispose() {
    super.dispose();
  }

  String _formatCurrency(num amount) {
    final format = NumberFormat.currency(locale: 'en_US', symbol: '\$');
    return format.format(amount);
  }

  String _formatDate(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      return DateFormat('MMM dd, yyyy').format(date);
    } catch (e) {
      return dateString;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: AppBar(
        backgroundColor: AppColors.primaryColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.menu_rounded, color: Colors.white),
          onPressed: () => Scaffold.of(context).openDrawer(),
        ),
        title: Text(
          'Real Time Capital',
          style: GoogleFonts.nunito(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined, color: Colors.white),
            onPressed: () {},
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: Obx(() {
          if (_homeController.isLoading.value) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.primaryColor),
            );
          }

          if (_homeController.errorMessage.value.isNotEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.error_outline,
                      size: 64,
                      color: AppColors.errorColor,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Failed to load data',
                      style: GoogleFonts.nunito(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textColor,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _homeController.errorMessage.value,
                      textAlign: TextAlign.center,
                      style: GoogleFonts.nunito(
                        fontSize: 14,
                        color: AppColors.subtextColor,
                      ),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: () => _homeController.refreshData(),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryColor,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 32,
                          vertical: 12,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              ),
            );
          }

          return CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              // Welcome Section
              SliverToBoxAdapter(
                child:
                    Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: AppColors.primaryColor,
                            borderRadius: const BorderRadius.only(
                              bottomLeft: Radius.circular(24),
                              bottomRight: Radius.circular(24),
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Welcome back,',
                                style: GoogleFonts.nunito(
                                  fontSize: 14,
                                  color: Colors.white.withOpacity(0.9),
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                _homeController.getUserName,
                                style: GoogleFonts.nunito(
                                  fontSize: 24,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white,
                                ),
                              ),
                              if (_homeController
                                  .getUserPhone()
                                  .isNotEmpty) ...[
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    Icon(
                                      Icons.phone_outlined,
                                      size: 14,
                                      color: Colors.white.withOpacity(0.8),
                                    ),
                                    const SizedBox(width: 6),
                                    Text(
                                      _homeController.getUserPhone(),
                                      style: GoogleFonts.nunito(
                                        fontSize: 12,
                                        color: Colors.white.withOpacity(0.8),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ],
                          ),
                        )
                        .animate()
                        .fadeIn(duration: 500.ms)
                        .slideY(begin: -0.2, duration: 600.ms),
              ),

              // Main Content
              SliverToBoxAdapter(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 20),

                    // Promotional Carousel
                    _buildCarousel(),

                    const SizedBox(height: 15),

                    // Quick Stats Section
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child:
                          Row(
                                children: [
                                  Expanded(
                                    child: _buildStatCard(
                                      title: 'Active Loans',
                                      value: _homeController
                                          .activeLoansCount
                                          .value
                                          .toString(),
                                      icon: Icons.credit_card,
                                      color: AppColors.primaryColor,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: _buildStatCard(
                                      title: 'Total Balance',
                                      value: _formatCurrency(
                                        _homeController.totalDueAmount.value,
                                      ),
                                      icon: Icons.account_balance_wallet,
                                      color: AppColors.warningColor,
                                    ),
                                  ),
                                ],
                              )
                              .animate()
                              .fadeIn(duration: 600.ms, delay: 200.ms)
                              .slideY(begin: 0.2, duration: 600.ms),
                    ),

                    const SizedBox(height: 15),

                    // Loan Types Section
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child:
                          Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Apply for Loan',
                                    style: GoogleFonts.nunito(
                                      fontSize: 20,
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.textColor,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Choose your collateral type',
                                    style: GoogleFonts.nunito(
                                      fontSize: 14,
                                      color: AppColors.subtextColor,
                                    ),
                                  ),
                                ],
                              )
                              .animate()
                              .fadeIn(duration: 600.ms, delay: 400.ms)
                              .slideY(begin: 0.2, duration: 600.ms),
                    ),

                    const SizedBox(height: 8),

                    // Loan Type Grid
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child:
                          GridView.builder(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                gridDelegate:
                                    const SliverGridDelegateWithFixedCrossAxisCount(
                                      crossAxisCount: 3,
                                      crossAxisSpacing: 12,
                                      mainAxisSpacing: 12,
                                      childAspectRatio: 0.9,
                                    ),
                                itemCount: loanTypes.length,
                                itemBuilder: (context, index) {
                                  return _buildLoanTypeCard(
                                    icon: loanTypes[index]['icon'] as IconData,
                                    title: loanTypes[index]['title'] as String,
                                    color: loanTypes[index]['color'] as Color,
                                    route: loanTypes[index]['route'] as String,
                                  );
                                },
                              )
                              .animate()
                              .fadeIn(duration: 600.ms, delay: 600.ms)
                              .slideY(begin: 0.3, duration: 600.ms),
                    ),

                    const SizedBox(height: 15),

                    // Quick Actions Section
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Quick Actions',
                            style: GoogleFonts.nunito(
                              fontSize: 20,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textColor,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 8),

                    // Quick Actions Grid
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child:
                          GridView.builder(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                gridDelegate:
                                    const SliverGridDelegateWithFixedCrossAxisCount(
                                      crossAxisCount: 2,
                                      crossAxisSpacing: 12,
                                      mainAxisSpacing: 12,
                                      childAspectRatio: 1.5,
                                    ),
                                itemCount: quickActions.length,
                                itemBuilder: (context, index) {
                                  return _buildQuickActionCard(
                                    icon:
                                        quickActions[index]['icon'] as IconData,
                                    title:
                                        quickActions[index]['title'] as String,
                                    route:
                                        quickActions[index]['route'] as String,
                                  );
                                },
                              )
                              .animate()
                              .fadeIn(duration: 600.ms, delay: 800.ms)
                              .slideY(begin: 0.3, duration: 600.ms),
                    ),

                    const SizedBox(height: 15),

                    // Active Auctions Section
                    if (_homeController.activeAuctions.isNotEmpty) ...[
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Live Auctions',
                              style: GoogleFonts.nunito(
                                fontSize: 20,
                                fontWeight: FontWeight.w700,
                                color: AppColors.textColor,
                              ),
                            ),
                            TextButton(
                              onPressed: () {
                                Get.toNamed('/auctions');
                              },
                              child: Text(
                                'View All (${_homeController.activeAuctions.length})',
                                style: GoogleFonts.nunito(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.primaryColor,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 8),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: SizedBox(
                          height: 170, // Fixed height for horizontal list
                          child:
                              ListView.builder(
                                    scrollDirection: Axis.horizontal,
                                    itemCount:
                                        _homeController.activeAuctions.length >
                                            3
                                        ? 3
                                        : _homeController.activeAuctions.length,
                                    itemBuilder: (context, index) {
                                      final auction =
                                          _homeController.activeAuctions[index];
                                      return _buildAuctionItem(auction);
                                    },
                                  )
                                  .animate()
                                  .fadeIn(duration: 600.ms, delay: 900.ms)
                                  .slideX(begin: 0.3, duration: 600.ms),
                        ),
                      ),
                      const SizedBox(height: 20),
                    ],

                    // Active Loans Section
                    if (_homeController.latestLoans.isNotEmpty) ...[
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Active Loans',
                              style: GoogleFonts.nunito(
                                fontSize: 20,
                                fontWeight: FontWeight.w700,
                                color: AppColors.textColor,
                              ),
                            ),
                            TextButton(
                              onPressed: () {
                                Get.toNamed('/all-loans');
                              },
                              child: Text(
                                'View All (${_homeController.latestLoans.length})',
                                style: GoogleFonts.nunito(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.primaryColor,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 8),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child:
                            ListView.builder(
                                  shrinkWrap: true,
                                  physics: const NeverScrollableScrollPhysics(),
                                  itemCount:
                                      _homeController.latestLoans.length > 3
                                      ? 3
                                      : _homeController.latestLoans.length,
                                  itemBuilder: (context, index) {
                                    final loan =
                                        _homeController.latestLoans[index];
                                    return Padding(
                                      padding: const EdgeInsets.only(
                                        bottom: 12,
                                      ),
                                      child: _buildLoanItemFromApi(loan),
                                    );
                                  },
                                )
                                .animate()
                                .fadeIn(duration: 600.ms, delay: 1000.ms)
                                .slideY(begin: 0.3, duration: 600.ms),
                      ),
                    ],

                    // Recent Loan Applications Section
                    if (_homeController.latestLoanApplications.isNotEmpty) ...[
                      const SizedBox(height: 15),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Recent Applications',
                              style: GoogleFonts.nunito(
                                fontSize: 20,
                                fontWeight: FontWeight.w700,
                                color: AppColors.textColor,
                              ),
                            ),
                            TextButton(
                              onPressed: () {
                                Get.toNamed('/applications');
                              },
                              child: Text(
                                'View All',
                                style: GoogleFonts.nunito(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.primaryColor,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 8),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child:
                            ListView.builder(
                                  shrinkWrap: true,
                                  physics: const NeverScrollableScrollPhysics(),
                                  itemCount:
                                      _homeController
                                              .latestLoanApplications
                                              .length >
                                          2
                                      ? 2
                                      : _homeController
                                            .latestLoanApplications
                                            .length,
                                  itemBuilder: (context, index) {
                                    final application = _homeController
                                        .latestLoanApplications[index];
                                    return Padding(
                                      padding: const EdgeInsets.only(
                                        bottom: 12,
                                      ),
                                      child: _buildApplicationItem(application),
                                    );
                                  },
                                )
                                .animate()
                                .fadeIn(duration: 600.ms, delay: 1100.ms)
                                .slideY(begin: 0.3, duration: 600.ms),
                      ),
                    ],

                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ],
          );
        }),
      ),
    );
  }

  Widget _buildCarousel() {
    return Column(
          children: [
            CarouselSlider(
              items: _carouselItems.map((item) {
                return Container(
                  width: double.infinity,
                  margin: const EdgeInsets.symmetric(horizontal: 8),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    gradient: LinearGradient(
                      colors: [
                        AppColors.primaryColor,
                        AppColors.primaryColor.withOpacity(0.7),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primaryColor.withOpacity(0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Stack(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          color: Colors.black.withOpacity(0.1),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(item.icon, color: Colors.white, size: 30),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    item.title,
                                    style: GoogleFonts.nunito(
                                      fontSize: 22,
                                      fontWeight: FontWeight.w700,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 3),
                            Padding(
                              padding: const EdgeInsets.only(left: 42),
                              child: Text(
                                item.subtitle,
                                style: GoogleFonts.nunito(
                                  fontSize: 14,
                                  color: Colors.white.withOpacity(0.9),
                                ),
                              ),
                            ),
                            const Spacer(),
                            Align(
                              alignment: Alignment.bottomRight,
                              child: GestureDetector(
                                onTap: () {
                                  Get.toNamed(item.route);
                                },
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 20,
                                    vertical: 6,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(12),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.1),
                                        blurRadius: 5,
                                        offset: const Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                  child: Text(
                                    item.buttonText,
                                    style: GoogleFonts.nunito(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.primaryColor,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
              options: CarouselOptions(
                height: 183,
                autoPlay: true,
                autoPlayInterval: const Duration(seconds: 15),
                enlargeCenterPage: true,
                viewportFraction: 1.0,
                onPageChanged: (index, reason) {
                  setState(() => _carouselIndex = index);
                },
              ),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: _carouselItems.asMap().entries.map((entry) {
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _carouselIndex = entry.key;
                    });
                  },
                  child: Container(
                    width: _carouselIndex == entry.key ? 24 : 8,
                    height: 8,
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(4),
                      color: _carouselIndex == entry.key
                          ? AppColors.primaryColor
                          : AppColors.borderColor,
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        )
        .animate()
        .fadeIn(duration: 600.ms, delay: 200.ms)
        .slideY(begin: -0.2, duration: 600.ms);
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderColor),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: GoogleFonts.nunito(
              fontSize: 24,
              fontWeight: FontWeight.w800,
              color: AppColors.textColor,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: GoogleFonts.nunito(
              fontSize: 12,
              color: AppColors.subtextColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoanTypeCard({
    required IconData icon,
    required String title,
    required Color color,
    required String route,
  }) {
    return GestureDetector(
      onTap: () {
        Get.toNamed(route);
      },
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surfaceColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.borderColor),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 5,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 28, color: color),
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: GoogleFonts.nunito(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppColors.textColor,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActionCard({
    required IconData icon,
    required String title,
    required String route,
  }) {
    return GestureDetector(
      onTap: () {
        Get.toNamed(route);
      },
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surfaceColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.borderColor),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 5,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, size: 24, color: AppColors.primaryColor),
              ),
              const SizedBox(height: 8),
              Text(
                title,
                style: GoogleFonts.nunito(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textColor,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAuctionItem(Map<String, dynamic> auction) {
    final auctionNo = auction['auction_no'] ?? 'Auction';
    final startingBid =
        (auction['starting_bid_amount'] as num?)?.toDouble() ?? 0;
    final winningBid = (auction['winning_bid_amount'] as num?)?.toDouble();
    final status = auction['status'] ?? 'unknown';
    final endsAt = auction['ends_at'] ?? '';

    Color statusColor;
    String statusText;
    switch (status) {
      case 'live':
        statusColor = Colors.green;
        statusText = 'LIVE';
        break;
      case 'ended':
        statusColor = Colors.red;
        statusText = 'ENDED';
        break;
      case 'upcoming':
        statusColor = Colors.orange;
        statusText = 'UPCOMING';
        break;
      default:
        statusColor = AppColors.subtextColor;
        statusText = status.toUpperCase();
    }

    return Container(
      width: 260,
      height: 160, // FIXED HEIGHT - This is the key!
      margin: const EdgeInsets.only(right: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surfaceColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderColor),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  auctionNo,
                  style: GoogleFonts.nunito(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textColor,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  statusText,
                  style: GoogleFonts.nunito(
                    fontSize: 9,
                    fontWeight: FontWeight.w600,
                    color: statusColor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            'Starting Bid',
            style: GoogleFonts.nunito(
              fontSize: 10,
              color: AppColors.subtextColor,
            ),
          ),
          Text(
            _formatCurrency(startingBid),
            style: GoogleFonts.nunito(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: AppColors.textColor,
            ),
          ),
          if (winningBid != null) ...[
            Text(
              'Current: ${_formatCurrency(winningBid)}',
              style: GoogleFonts.nunito(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: Colors.green,
              ),
            ),
          ],
          const Spacer(),
          if (endsAt.isNotEmpty) ...[
            Row(
              children: [
                Icon(
                  Icons.access_time,
                  size: 11,
                  color: AppColors.subtextColor,
                ),
                const SizedBox(width: 3),
                Expanded(
                  child: Text(
                    'Ends: ${_formatDate(endsAt)}',
                    style: GoogleFonts.nunito(
                      fontSize: 9,
                      color: AppColors.subtextColor,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
          ],
          Align(
            alignment: Alignment.bottomRight,
            child: GestureDetector(
              onTap: () {
                Get.toNamed('/auction-details/${auction['_id']}');
              },
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: AppColors.primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  'View',
                  style: GoogleFonts.nunito(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primaryColor,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoanItemFromApi(Map<String, dynamic> loan) {
    final loanNo = loan['loan_no'] ?? 'Loan';
    final principal = (loan['principal_amount'] as num?)?.toDouble() ?? 0;
    final balance = (loan['current_balance'] as num?)?.toDouble() ?? 0;
    final dueDate = loan['due_date'] ?? '';
    final category = loan['collateral_category'] ?? 'Loan';

    double progress = 0.0;
    if (principal > 0) {
      progress = ((principal - balance) / principal).clamp(0.0, 1.0);
    }

    return GestureDetector(
      onTap: () {
        Get.toNamed('/loan-details/${loan['_id']}');
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surfaceColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.borderColor),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 5,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    loanNo,
                    style: GoogleFonts.nunito(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textColor,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    category
                        .toString()
                        .split('_')
                        .map(
                          (word) => word[0].toUpperCase() + word.substring(1),
                        )
                        .join(' '),
                    style: GoogleFonts.nunito(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primaryColor,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Principal',
                        style: GoogleFonts.nunito(
                          fontSize: 12,
                          color: AppColors.subtextColor,
                        ),
                      ),
                      Text(
                        _formatCurrency(principal),
                        style: GoogleFonts.nunito(
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textColor,
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        'Balance',
                        style: GoogleFonts.nunito(
                          fontSize: 12,
                          color: AppColors.subtextColor,
                        ),
                      ),
                      Text(
                        _formatCurrency(balance),
                        style: GoogleFonts.nunito(
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                          color: balance > 0
                              ? AppColors.warningColor
                              : Colors.green,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Repayment Progress',
                      style: GoogleFonts.nunito(
                        fontSize: 12,
                        color: AppColors.subtextColor,
                      ),
                    ),
                    Text(
                      '${(progress * 100).toStringAsFixed(0)}%',
                      style: GoogleFonts.nunito(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppColors.primaryColor,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: progress,
                    backgroundColor: AppColors.borderColor,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      AppColors.primaryColor,
                    ),
                    minHeight: 6,
                  ),
                ),
              ],
            ),
            if (dueDate.isNotEmpty) ...[
              const SizedBox(height: 12),
              Row(
                children: [
                  Icon(
                    Icons.calendar_today,
                    size: 14,
                    color: AppColors.subtextColor,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'Due: ${_formatDate(dueDate)}',
                    style: GoogleFonts.nunito(
                      fontSize: 12,
                      color: AppColors.subtextColor,
                    ),
                  ),
                  const Spacer(),
                  if (balance > 0)
                    GestureDetector(
                      onTap: () {
                        Get.toNamed('/payment/${loan['_id']}');
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.primaryColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          'Pay Now',
                          style: GoogleFonts.nunito(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: AppColors.primaryColor,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildApplicationItem(Map<String, dynamic> application) {
    final appNo = application['application_no'] ?? 'Application';
    final amount =
        (application['requested_loan_amount'] as num?)?.toDouble() ?? 0;
    final status = application['status'] ?? 'draft';
    final date = application['created_at'] ?? '';

    Color statusColor;
    switch (status) {
      case 'approved':
        statusColor = Colors.green;
        break;
      case 'pending':
        statusColor = Colors.orange;
        break;
      case 'rejected':
        statusColor = Colors.red;
        break;
      case 'draft':
        statusColor = AppColors.subtextColor;
        break;
      default:
        statusColor = AppColors.subtextColor;
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderColor),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              Icons.description_outlined,
              color: AppColors.primaryColor,
              size: 24,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  appNo,
                  style: GoogleFonts.nunito(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textColor,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Amount: ${_formatCurrency(amount)}',
                  style: GoogleFonts.nunito(
                    fontSize: 12,
                    color: AppColors.textColor,
                  ),
                ),
                if (date.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(
                    'Submitted: ${_formatDate(date)}',
                    style: GoogleFonts.nunito(
                      fontSize: 11,
                      color: AppColors.subtextColor,
                    ),
                  ),
                ],
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: statusColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              status.toUpperCase(),
              style: GoogleFonts.nunito(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: statusColor,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class CarouselItem {
  final String title;
  final String subtitle;
  final IconData icon;
  final String buttonText;
  final String route;

  CarouselItem({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.buttonText,
    required this.route,
  });
}
