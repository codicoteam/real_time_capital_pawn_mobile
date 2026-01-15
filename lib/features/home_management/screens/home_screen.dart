import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:real_time_pawn/core/utils/pallete.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:get/get.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final String userName = "John";
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
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            // Welcome Section with Green Background
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
                              'Welcome,',
                              style: GoogleFonts.nunito(
                                fontSize: 14,
                                color: Colors.white.withOpacity(0.9),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              userName,
                              style: GoogleFonts.nunito(
                                fontSize: 24,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                              ),
                            ),
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
                                    value: '3',
                                    icon: Icons.credit_card,
                                    color: AppColors.primaryColor,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: _buildStatCard(
                                    title: 'Due Soon',
                                    value: '\$1,200',
                                    icon: Icons.access_time,
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
                                  icon: quickActions[index]['icon'] as IconData,
                                  title: quickActions[index]['title'] as String,
                                  route: quickActions[index]['route'] as String,
                                );
                              },
                            )
                            .animate()
                            .fadeIn(duration: 600.ms, delay: 800.ms)
                            .slideY(begin: 0.3, duration: 600.ms),
                  ),

                  const SizedBox(height: 15),

                  // Active Loans Section
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
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
                      ],
                    ),
                  ),

                  // Active Loans List
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child:
                        ListView(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              children: [
                                _buildLoanItem(
                                  title: 'Toyota Camry 2020',
                                  type: 'Motor Vehicle',
                                  amount: '\$15,000',
                                  progress: 0.65,
                                  dueDate: '2024-02-15',
                                  route: '/loan-details/1',
                                ),
                                const SizedBox(height: 12),
                                _buildLoanItem(
                                  title: 'MacBook Pro M2',
                                  type: 'Electronics',
                                  amount: '\$2,500',
                                  progress: 0.30,
                                  dueDate: '2024-01-30',
                                  route: '/loan-details/2',
                                ),
                                const SizedBox(height: 12),
                                _buildLoanItem(
                                  title: 'Gold Necklace',
                                  type: 'Jewelry',
                                  amount: '\$3,200',
                                  progress: 0.80,
                                  dueDate: '2024-02-10',
                                  route: '/loan-details/3',
                                ),
                              ],
                            )
                            .animate()
                            .fadeIn(duration: 600.ms, delay: 1000.ms)
                            .slideY(begin: 0.3, duration: 600.ms),
                  ),

                  const SizedBox(height: 40),
                ],
              ),
            ),
          ],
        ),
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
                      // Gradient overlay
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
                            // Top content
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

                            // Spacer to push button to bottom
                            const Spacer(),

                            // Button at bottom
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
                    // Navigate to specific carousel item
                    // We don't need controller for this simple implementation
                    // Just update the index directly
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

  Widget _buildLoanItem({
    required String title,
    required String type,
    required String amount,
    required double progress,
    required String dueDate,
    required String route,
  }) {
    return GestureDetector(
      onTap: () {
        Get.toNamed(route);
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
                    title,
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
                    type,
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
            Text(
              amount,
              style: GoogleFonts.nunito(
                fontSize: 24,
                fontWeight: FontWeight.w800,
                color: AppColors.textColor,
              ),
            ),
            const SizedBox(height: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Progress',
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
                  'Due: $dueDate',
                  style: GoogleFonts.nunito(
                    fontSize: 12,
                    color: AppColors.subtextColor,
                  ),
                ),
                const Spacer(),
                GestureDetector(
                  onTap: () {
                    Get.toNamed('/payment/$title');
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
        ),
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
