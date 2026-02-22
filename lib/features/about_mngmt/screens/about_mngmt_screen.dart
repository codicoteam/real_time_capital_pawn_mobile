// File: lib/features/about_mngmt/about_mngmt_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:real_time_pawn/core/utils/pallete.dart';

class AboutScreen extends StatefulWidget {
  const AboutScreen({super.key});

  @override
  State<AboutScreen> createState() => _AboutScreenState();
}

class _AboutScreenState extends State<AboutScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _expandController;
  final RxBool _isExpanded = false.obs;
  int? expandedValueIndex;
  String searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  // About content from the BRD
  final String _companyOverview =
      "The pawn business has evolved significantly in recent years, transforming from a traditional, often stigmatized industry into a modern financial service that caters to a diverse clientele. Offering loans against assets, pawnshops provide a quick and accessible solution for individuals seeking immediate cash without the lengthy processes typically associated with banks.";

  final String _missionStatement =
      "To provide a vibrant and efficient pawn service tailored to the unique needs of the creative industry, enhancing cash flow while maintaining the integrity of the assets involved.";

  final String _visionStatement =
      "To position ourselves as a legitimate and convenient choice for those needing quick cash, redefining our role in the financial landscape through the effective use of modern systems and technology.";

  final List<Map<String, dynamic>> _coreValues = [
    {
      'title': 'Transparency',
      'description':
          'We maintain high standards of transparency in all our transactions, ensuring customers understand loan terms, interest rates, and asset valuations clearly.',
      'icon': Icons.visibility_outlined,
      'color': RealTimeColors.primaryGreen,
    },
    {
      'title': 'Integrity',
      'description':
          'We handle all assets with the utmost care and respect, maintaining the integrity of every item entrusted to us.',
      'icon': Icons.verified_outlined,
      'color': RealTimeColors.success,
    },
    {
      'title': 'Innovation',
      'description':
          'We embrace modern technology to streamline operations, enhance customer experiences, and provide innovative financial solutions.',
      'icon': Icons.lightbulb_outline,
      'color': RealTimeColors.warning,
    },
    {
      'title': 'Customer Focus',
      'description':
          'We build strong relationships with clients through personalized service and a genuine commitment to meeting their financial needs.',
      'icon': Icons.people_outline,
      'color': RealTimeColors.darkGreen,
    },
  ];

  final List<Map<String, dynamic>> _keyFeatures = [
    {
      'title': 'Asset Management',
      'description':
          'Comprehensive tools for submitting, tracking, and managing assets for pawn, with detailed valuation and documentation capabilities.',
      'icon': Icons.inventory_outlined,
    },
    {
      'title': 'Loan Management',
      'description':
          'End-to-end loan processing with automated interest calculations, payment tracking, and flexible repayment options.',
      'icon': Icons.account_balance_wallet_outlined,
    },
    {
      'title': 'Auction Module',
      'description':
          'Real-time bidding platform with registration deposit fees, bid management, and automated notifications for auction participants.',
      'icon': Icons.gavel_outlined,
    },
    {
      'title': 'Secure Payments',
      'description':
          'Integrated payment processing supporting multiple methods including mobile money, bank transfers, and card payments.',
      'icon': Icons.payment_outlined,
    },
    {
      'title': 'Customer Support',
      'description':
          'Multi-channel support with ticketing system, live chat, and comprehensive knowledge base for customer assistance.',
      'icon': Icons.support_agent_outlined,
    },
    {
      'title': 'Reporting & Analytics',
      'description':
          'Detailed reports on inventory, loan performance, auction revenue, and customer engagement for data-driven decisions.',
      'icon': Icons.analytics_outlined,
    },
  ];

  final List<Map<String, String>> _stats = [
    {'label': 'Active Users', 'value': '500+', 'icon': '👥'},
    {'label': 'Assets Pawned', 'value': '1,200+', 'icon': '📦'},
    {'label': 'Loans Processed', 'value': '₵2.5M+', 'icon': '💰'},
    {'label': 'Auctions Held', 'value': '48+', 'icon': '🔨'},
  ];

  List<Map<String, dynamic>> get filteredCoreValues {
    if (searchQuery.isEmpty) return _coreValues;
    return _coreValues
        .where(
          (item) =>
              item['title'].toString().toLowerCase().contains(
                searchQuery.toLowerCase(),
              ) ||
              item['description'].toString().toLowerCase().contains(
                searchQuery.toLowerCase(),
              ),
        )
        .toList();
  }

  @override
  void initState() {
    super.initState();
    _expandController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
  }

  @override
  void dispose() {
    _expandController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.sizeOf(context).width;
    double screenHeight = MediaQuery.sizeOf(context).height;

    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          _buildSliverAppBar(),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                children: [
                  SizedBox(height: screenHeight * 0.02),
                  _buildSearchBar(),
                  SizedBox(height: screenHeight * 0.02),
                  _buildQuickStats(),
                  SizedBox(height: screenHeight * 0.02),
                ],
              ),
            ),
          ),
          _buildAboutContent(),
          const SliverToBoxAdapter(child: SizedBox(height: 24)),
        ],
      ),
    );
  }

  Widget _buildSliverAppBar() {
    return SliverAppBar(
      expandedHeight: 280,
      floating: false,
      pinned: true,
      backgroundColor: RealTimeColors.primaryGreen,
      leading: IconButton(
        icon: Icon(Icons.arrow_back_ios, color: Colors.white),
        onPressed: () => Navigator.pop(context),
      ),
      flexibleSpace: FlexibleSpaceBar(
        title: Text(
          'About Us',
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontWeight: FontWeight.w600,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
        background: Stack(
          children: [
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    RealTimeColors.primaryGreen,
                    RealTimeColors.darkGreen,
                    RealTimeColors.primaryGreen.withOpacity(0.8),
                  ],
                ),
              ),
              child: Stack(
                children: [
                  Positioned(
                    right: -30,
                    top: 40,
                    child: Opacity(
                      opacity: 0.1,
                      child: Icon(
                        Icons.storefront_outlined,
                        size: 200,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  Positioned(
                    left: -20,
                    bottom: 20,
                    child: Opacity(
                      opacity: 0.1,
                      child: Icon(
                        Icons.account_balance_outlined,
                        size: 150,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                              width: 90,
                              height: 90,
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.15),
                                borderRadius: BorderRadius.circular(25),
                                border: Border.all(
                                  color: Colors.white.withOpacity(0.3),
                                  width: 2,
                                ),
                              ),
                              child: Icon(
                                Icons.storefront_outlined,
                                size: 50,
                                color: Colors.white.withOpacity(0.9),
                              ),
                            )
                            .animate()
                            .scale(duration: 600.ms, curve: Curves.elasticOut)
                            .fadeIn(duration: 400.ms),
                        const SizedBox(height: 16),
                        Text(
                              'Real Time Capital',
                              style: GoogleFonts.poppins(
                                color: Colors.white,
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                              textAlign: TextAlign.center,
                            )
                            .animate(delay: 200.ms)
                            .slideY(
                              begin: 0.5,
                              duration: 500.ms,
                              curve: Curves.easeOut,
                            )
                            .fadeIn(duration: 400.ms),
                        const SizedBox(height: 8),
                        Text(
                          'Your Trusted Financial Partner',
                          style: GoogleFonts.poppins(
                            color: Colors.white.withOpacity(0.9),
                            fontSize: 14,
                            fontStyle: FontStyle.italic,
                          ),
                        ).animate(delay: 300.ms).fadeIn(duration: 400.ms),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: AppColors.surfaceColor,
            borderRadius: BorderRadius.circular(15),
            boxShadow: [
              BoxShadow(
                color: RealTimeColors.primaryGreen.withOpacity(0.1),
                blurRadius: 15,
                offset: const Offset(0, 4),
                spreadRadius: 1,
              ),
            ],
            border: Border.all(
              color: RealTimeColors.primaryGreen.withOpacity(0.3),
              width: 1.5,
            ),
          ),
          child: Row(
            children: [
              Icon(Icons.search, color: RealTimeColors.primaryGreen, size: 24),
              const SizedBox(width: 12),
              Expanded(
                child: TextField(
                  controller: _searchController,
                  onChanged: (value) {
                    setState(() {
                      searchQuery = value;
                    });
                  },
                  decoration: InputDecoration(
                    hintText: 'Search values, features...',
                    hintStyle: GoogleFonts.poppins(
                      color: AppColors.subtextColor,
                      fontSize: 14,
                    ),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  style: GoogleFonts.poppins(
                    color: AppColors.textColor,
                    fontSize: 14,
                  ),
                ),
              ),
              if (searchQuery.isNotEmpty)
                IconButton(
                  icon: Icon(
                    Icons.clear,
                    color: RealTimeColors.primaryGreen,
                    size: 22,
                  ),
                  onPressed: () {
                    _searchController.clear();
                    setState(() {
                      searchQuery = '';
                    });
                  },
                ),
            ],
          ),
        )
        .animate()
        .slideY(begin: -0.2, duration: 400.ms, curve: Curves.easeOut)
        .fadeIn(duration: 300.ms);
  }

  Widget _buildQuickStats() {
    return Container(
      width: double.infinity,
      child: Row(
        children: [
          _buildStatCard(
            '500+ Users',
            Icons.people,
            RealTimeColors.primaryGreen,
          ),
          const SizedBox(width: 8),
          _buildStatCard(
            '1.2K+ Assets',
            Icons.inventory,
            RealTimeColors.success,
          ),
          const SizedBox(width: 8),
          _buildStatCard(
            '₵2.5M+ Loans',
            Icons.attach_money,
            RealTimeColors.warning,
          ),
          const SizedBox(width: 8),
          _buildStatCard('48+ Auctions', Icons.gavel, RealTimeColors.darkGreen),
        ],
      ),
    ).animate().fadeIn(duration: 600.ms, delay: 300.ms);
  }

  Widget _buildStatCard(String title, IconData icon, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.2), width: 1),
        ),
        child: Column(
          children: [
            Icon(icon, size: 18, color: color),
            const SizedBox(height: 6),
            Text(
              title,
              style: GoogleFonts.poppins(
                color: AppColors.textColor,
                fontSize: 9,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAboutContent() {
    if (searchQuery.isNotEmpty && filteredCoreValues.isEmpty) {
      return SliverToBoxAdapter(child: _buildEmptyState());
    }

    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      sliver: SliverList(
        delegate: SliverChildListDelegate([
          // Overview Section
          _buildOverviewSection(),
          const SizedBox(height: 20),

          // Mission & Vision
          _buildMissionVisionSection(),
          const SizedBox(height: 20),

          // Stats Section
          _buildStatsSection(),
          const SizedBox(height: 20),

          // Core Values Section
          _buildCoreValuesSection(),
          const SizedBox(height: 20),

          // Key Features Section
          _buildKeyFeaturesSection(),
          const SizedBox(height: 20),

          // Contact Section
          _buildContactSection(),
          const SizedBox(height: 24),

          // Footer
          Center(
            child: Text(
              'Version 1.0.0 | © 2025 Real Time Capital',
              style: GoogleFonts.poppins(
                fontSize: 10,
                color: AppColors.subtextColor.withOpacity(0.7),
              ),
            ),
          ).animate().fadeIn(duration: 600.ms, delay: 900.ms),
        ]),
      ),
    );
  }

  Widget _buildOverviewSection() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surfaceColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            spreadRadius: 0,
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 6,
                height: 28,
                decoration: BoxDecoration(
                  color: RealTimeColors.primaryGreen,
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'Who We Are',
                style: GoogleFonts.poppins(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textColor,
                ),
              ),
            ],
          ).animate().fadeIn(duration: 400.ms).slideX(begin: -0.1),
          const SizedBox(height: 16),
          Text(
            _companyOverview,
            style: GoogleFonts.poppins(
              fontSize: 14,
              color: AppColors.subtextColor,
              height: 1.6,
            ),
          ).animate().fadeIn(duration: 500.ms, delay: 100.ms),
          const SizedBox(height: 12),
          Obx(
            () => AnimatedCrossFade(
              firstChild: const SizedBox.shrink(),
              secondChild: Column(
                children: [
                  const SizedBox(height: 8),
                  Text(
                    'This modernization is reflected in our growing emphasis on transparency and customer service. We invest in training staff to provide knowledgeable assistance and create a welcoming environment, supported by integrated software systems that improve efficiency and accuracy.',
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      color: AppColors.subtextColor,
                      height: 1.6,
                    ),
                  ).animate().fadeIn(duration: 300.ms),
                  const SizedBox(height: 8),
                  Text(
                    'As consumers increasingly seek alternative financing options, we position ourselves as a legitimate and convenient choice for those needing quick cash, redefining our role in the financial landscape through the effective use of modern systems.',
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      color: AppColors.subtextColor,
                      height: 1.6,
                    ),
                  ).animate().fadeIn(duration: 300.ms),
                ],
              ),
              crossFadeState: _isExpanded.value
                  ? CrossFadeState.showSecond
                  : CrossFadeState.showFirst,
              duration: const Duration(milliseconds: 300),
            ),
          ),
          const SizedBox(height: 8),
          GestureDetector(
            onTap: () {
              _isExpanded.toggle();
              if (_isExpanded.value) {
                _expandController.forward();
                HapticFeedback.lightImpact();
              } else {
                _expandController.reverse();
              }
            },
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text(
                  _isExpanded.value ? 'Read Less' : 'Read More',
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    color: RealTimeColors.primaryGreen,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(width: 4),
                Icon(
                  _isExpanded.value
                      ? Icons.keyboard_arrow_up
                      : Icons.keyboard_arrow_down,
                  color: RealTimeColors.primaryGreen,
                  size: 20,
                ),
              ],
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 600.ms, delay: 300.ms).slideY(begin: 0.2);
  }

  Widget _buildMissionVisionSection() {
    return Row(
      children: [
        Expanded(
          child:
              Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: RealTimeColors.primaryGreen.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: RealTimeColors.primaryGreen.withOpacity(0.2),
                        width: 1,
                      ),
                    ),
                    child: Column(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: RealTimeColors.primaryGreen.withOpacity(0.2),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.flag_outlined,
                            color: RealTimeColors.primaryGreen,
                            size: 28,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Our Mission',
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textColor,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _missionStatement,
                          style: GoogleFonts.poppins(
                            fontSize: 11,
                            color: AppColors.subtextColor,
                            height: 1.5,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  )
                  .animate()
                  .fadeIn(duration: 500.ms, delay: 400.ms)
                  .slideX(begin: -0.1),
        ),
        const SizedBox(width: 12),
        Expanded(
          child:
              Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: RealTimeColors.darkGreen.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: RealTimeColors.darkGreen.withOpacity(0.2),
                        width: 1,
                      ),
                    ),
                    child: Column(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: RealTimeColors.darkGreen.withOpacity(0.2),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.visibility_outlined,
                            color: RealTimeColors.darkGreen,
                            size: 28,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Our Vision',
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textColor,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _visionStatement,
                          style: GoogleFonts.poppins(
                            fontSize: 11,
                            color: AppColors.subtextColor,
                            height: 1.5,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  )
                  .animate()
                  .fadeIn(duration: 500.ms, delay: 500.ms)
                  .slideX(begin: 0.1),
        ),
      ],
    );
  }

  Widget _buildStatsSection() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [RealTimeColors.primaryGreen, RealTimeColors.darkGreen],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: RealTimeColors.primaryGreen.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Our Impact',
            style: GoogleFonts.poppins(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ).animate().fadeIn(duration: 400.ms),
          const SizedBox(height: 20),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 1.2,
            ),
            itemCount: _stats.length,
            itemBuilder: (context, index) {
              final stat = _stats[index];
              return Container(
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.3),
                        width: 1,
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          stat['icon']!,
                          style: const TextStyle(fontSize: 28),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          stat['value']!,
                          style: GoogleFonts.poppins(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        Text(
                          stat['label']!,
                          style: GoogleFonts.poppins(
                            fontSize: 11,
                            color: Colors.white.withOpacity(0.9),
                          ),
                        ),
                      ],
                    ),
                  )
                  .animate()
                  .fadeIn(
                    duration: 400.ms,
                    delay: Duration(milliseconds: 500 + (index * 100)),
                  )
                  .scale(begin: const Offset(0.9, 0.9));
            },
          ),
        ],
      ),
    ).animate().fadeIn(duration: 600.ms, delay: 600.ms).slideY(begin: 0.2);
  }

  Widget _buildCoreValuesSection() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surfaceColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            spreadRadius: 0,
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 6,
                height: 28,
                decoration: BoxDecoration(
                  color: RealTimeColors.primaryGreen,
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'Our Core Values',
                style: GoogleFonts.poppins(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textColor,
                ),
              ),
            ],
          ).animate().fadeIn(duration: 400.ms).slideX(begin: -0.1),
          const SizedBox(height: 20),
          if (searchQuery.isNotEmpty && filteredCoreValues.isEmpty)
            Center(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    Icon(
                      Icons.search_off,
                      size: 48,
                      color: AppColors.subtextColor,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'No matching values found',
                      style: GoogleFonts.poppins(
                        color: AppColors.subtextColor,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            )
          else
            ...filteredCoreValues.asMap().entries.map((entry) {
              final index = entry.key;
              final value = entry.value;
              return GestureDetector(
                    onTap: () {
                      setState(() {
                        if (expandedValueIndex == index) {
                          expandedValueIndex = null;
                        } else {
                          expandedValueIndex = index;
                          HapticFeedback.lightImpact();
                        }
                      });
                    },
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.backgroundColor,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: expandedValueIndex == index
                              ? (value['color'] as Color)
                              : AppColors.borderColor,
                          width: expandedValueIndex == index ? 1.5 : 1,
                        ),
                      ),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Container(
                                width: 48,
                                height: 48,
                                decoration: BoxDecoration(
                                  color: (value['color'] as Color).withOpacity(
                                    0.1,
                                  ),
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                child: Icon(
                                  value['icon'] as IconData,
                                  color: value['color'] as Color,
                                  size: 24,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  value['title'] as String,
                                  style: GoogleFonts.poppins(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.textColor,
                                  ),
                                ),
                              ),
                              Icon(
                                expandedValueIndex == index
                                    ? Icons.keyboard_arrow_up
                                    : Icons.keyboard_arrow_down,
                                color: value['color'] as Color,
                                size: 24,
                              ),
                            ],
                          ),
                          if (expandedValueIndex == index)
                            Padding(
                              padding: const EdgeInsets.only(top: 12),
                              child:
                                  Text(
                                        value['description'] as String,
                                        style: GoogleFonts.poppins(
                                          fontSize: 13,
                                          color: AppColors.subtextColor,
                                          height: 1.5,
                                        ),
                                      )
                                      .animate()
                                      .fadeIn(duration: 300.ms)
                                      .slideY(begin: -0.1),
                            ),
                        ],
                      ),
                    ),
                  )
                  .animate()
                  .fadeIn(
                    duration: 400.ms,
                    delay: Duration(milliseconds: 600 + (index * 100)),
                  )
                  .slideX(begin: -0.1);
            }),
        ],
      ),
    );
  }

  Widget _buildKeyFeaturesSection() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surfaceColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            spreadRadius: 0,
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 6,
                height: 28,
                decoration: BoxDecoration(
                  color: RealTimeColors.primaryGreen,
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'Key Features',
                style: GoogleFonts.poppins(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textColor,
                ),
              ),
            ],
          ).animate().fadeIn(duration: 400.ms).slideX(begin: -0.1),
          const SizedBox(height: 20),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 0.9,
            ),
            itemCount: _keyFeatures.length,
            itemBuilder: (context, index) {
              final feature = _keyFeatures[index];
              return Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.backgroundColor,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: AppColors.borderColor,
                        width: 1,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: RealTimeColors.primaryGreen.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Icon(
                            feature['icon'] as IconData,
                            color: RealTimeColors.primaryGreen,
                            size: 22,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          feature['title'] as String,
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textColor,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          feature['description'] as String,
                          style: GoogleFonts.poppins(
                            fontSize: 10,
                            color: AppColors.subtextColor,
                            height: 1.4,
                          ),
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  )
                  .animate()
                  .fadeIn(
                    duration: 400.ms,
                    delay: Duration(milliseconds: 700 + (index * 50)),
                  )
                  .scale(begin: const Offset(0.9, 0.9));
            },
          ),
        ],
      ),
    ).animate().fadeIn(duration: 600.ms, delay: 700.ms);
  }

  Widget _buildContactSection() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            RealTimeColors.primaryGreen.withOpacity(0.1),
            RealTimeColors.darkGreen.withOpacity(0.1),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: RealTimeColors.primaryGreen.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: RealTimeColors.primaryGreen.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.support_agent_outlined,
              color: RealTimeColors.primaryGreen,
              size: 40,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Need Assistance?',
            style: GoogleFonts.poppins(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: AppColors.textColor,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Our support team is ready to help you 24/7',
            style: GoogleFonts.poppins(
              fontSize: 13,
              color: AppColors.subtextColor,
            ),
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildContactOption(
                icon: Icons.email_outlined,
                label: 'Email',
                value: 'support@rtcapital.co.zw',
              ),
              Container(height: 40, width: 1, color: AppColors.borderColor),
              _buildContactOption(
                icon: Icons.phone_outlined,
                label: 'Phone',
                value: '+263 24 279 1234',
              ),
            ],
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              icon: const Icon(Icons.chat_outlined, size: 18),
              label: Text(
                'Contact Support',
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              onPressed: () {
                // Navigate to support screen
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: RealTimeColors.primaryGreen,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                elevation: 2,
              ),
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 600.ms, delay: 800.ms).slideY(begin: 0.2);
  }

  Widget _buildContactOption({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Column(
      children: [
        Icon(icon, color: RealTimeColors.primaryGreen, size: 22),
        const SizedBox(height: 6),
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 11,
            color: AppColors.subtextColor,
          ),
        ),
        Text(
          value,
          style: GoogleFonts.poppins(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: AppColors.textColor,
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Container(
      padding: const EdgeInsets.all(40),
      child: Column(
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: RealTimeColors.primaryGreen.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.search_off_rounded,
              size: 60,
              color: RealTimeColors.primaryGreen.withOpacity(0.5),
            ),
          ).animate().scale(duration: 600.ms, curve: Curves.elasticOut),
          const SizedBox(height: 20),
          Text(
            'No matches found',
            style: GoogleFonts.poppins(
              color: AppColors.textColor,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ).animate(delay: 200.ms).fadeIn(),
          const SizedBox(height: 8),
          Text(
            'Try searching for "transparency", "innovation", or "support"',
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              color: AppColors.subtextColor,
              fontSize: 13,
            ),
          ).animate(delay: 300.ms).fadeIn(),
          const SizedBox(height: 20),
          ElevatedButton.icon(
            icon: const Icon(Icons.explore, size: 18),
            label: const Text('Clear Search'),
            onPressed: () {
              _searchController.clear();
              setState(() {
                searchQuery = '';
              });
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: RealTimeColors.primaryGreen,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ).animate(delay: 400.ms).scale(),
        ],
      ),
    );
  }
}
