// File: lib/features/about_mngmt/about_mngmt_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:real_time_pawn/config/routers/router.dart';
import 'package:real_time_pawn/core/utils/pallete.dart';
import 'package:url_launcher/url_launcher.dart'; // Add this package

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

  final List<Map<String, dynamic>> _stats = [
    {'value': '10K+', 'label': 'Happy Clients', 'icon': Icons.people},
    {'value': '5★', 'label': 'Rating', 'icon': Icons.star_rounded},
    {'value': '24/7', 'label': 'Support', 'icon': Icons.headset_mic_outlined},
    {'value': '100%', 'label': 'Secure', 'icon': Icons.shield_outlined},
  ];

  // Contact information
  final String _email = 'support@rtcapital.co.zw';
  final String _phone = '+263242791234'; // Removed spaces for dialing

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
    super.dispose();
  }

  // ─── LAUNCHER METHODS ───────────────────────────────────────────────────────
  Future<void> _launchEmail() async {
    final Uri emailUri = Uri(
      scheme: 'mailto',
      path: _email, // Make sure this is a valid email string
      queryParameters: {'subject': 'Inquiry from Real Time Capital App'},
    );

    try {
      if (await canLaunchUrl(emailUri)) {
        await launchUrl(
          emailUri,
          mode: LaunchMode.externalApplication, // 🔥 Important
        );
      } else {
        _showErrorDialog('Could not launch email app');
      }
    } catch (e) {
      _showErrorDialog('An error occurred: $e');
    }
  }

  Future<void> _launchPhone() async {
    final Uri phoneUri = Uri(scheme: 'tel', path: _phone);

    try {
      if (await canLaunchUrl(phoneUri)) {
        await launchUrl(phoneUri);
      } else {
        _showErrorDialog('Could not launch phone app');
      }
    } catch (e) {
      _showErrorDialog('An error occurred: $e');
    }
  }

  void _showErrorDialog(String message) {
    Get.dialog(
      AlertDialog(
        title: Text(
          'Error',
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
        ),
        content: Text(message, style: GoogleFonts.poppins()),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text(
              'OK',
              style: GoogleFonts.poppins(
                color: RealTimeColors.primaryGreen,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          _buildSliverAppBar(),
          SliverToBoxAdapter(child: _buildStatsBar()),
          _buildAboutContent(),
          const SliverToBoxAdapter(child: SizedBox(height: 32)),
        ],
      ),
    );
  }

  // ─── HERO APP BAR ────────────────────────────────────────────────────────────

  Widget _buildSliverAppBar() {
    return SliverAppBar(
      expandedHeight: 300,
      floating: false,
      pinned: true,
      backgroundColor: RealTimeColors.primaryGreen,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
        onPressed: () => Navigator.pop(context),
      ),
      flexibleSpace: FlexibleSpaceBar(
        titlePadding: const EdgeInsets.only(bottom: 16),
        title: Text(
          'About Us',
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontWeight: FontWeight.w700,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
        background: _buildHeroBackground(),
      ),
    );
  }

  Widget _buildHeroBackground() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [RealTimeColors.primaryGreen, RealTimeColors.darkGreen],
          stops: [0.3, 1.0],
        ),
      ),
      child: Stack(
        children: [
          // Decorative circles
          Positioned(
            right: -50,
            top: -30,
            child: Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.05),
              ),
            ),
          ),
          Positioned(
            left: -40,
            bottom: 30,
            child: Container(
              width: 150,
              height: 150,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.05),
              ),
            ),
          ),
          Positioned(
            right: 30,
            bottom: 60,
            child: Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.07),
              ),
            ),
          ),
          // Content
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 40),
                // Logo container with glow
                Container(
                      width: 90,
                      height: 90,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(28),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.35),
                          width: 1.5,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.15),
                            blurRadius: 20,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: Icon(
                        Icons.storefront_rounded,
                        size: 46,
                        color: Colors.white.withOpacity(0.95),
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
                        fontSize: 26,
                        fontWeight: FontWeight.w700,
                        letterSpacing: -0.3,
                      ),
                    )
                    .animate(delay: 150.ms)
                    .slideY(begin: 0.4, duration: 500.ms, curve: Curves.easeOut)
                    .fadeIn(duration: 400.ms),
                const SizedBox(height: 6),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: Colors.white.withOpacity(0.2),
                      width: 1,
                    ),
                  ),
                  child: Text(
                    'Your Trusted Financial Partner',
                    style: GoogleFonts.poppins(
                      color: Colors.white.withOpacity(0.9),
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ).animate(delay: 250.ms).fadeIn(duration: 400.ms),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ─── STATS BAR ───────────────────────────────────────────────────────────────

  Widget _buildStatsBar() {
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 20, 20, 0),
      padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 12),
      decoration: BoxDecoration(
        color: AppColors.surfaceColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: RealTimeColors.primaryGreen.withOpacity(0.1),
            blurRadius: 20,
            spreadRadius: 0,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: _stats.asMap().entries.map((e) {
          final i = e.key;
          final stat = e.value;
          return Expanded(
            child:
                Column(
                      children: [
                        Text(
                          stat['value'] as String,
                          style: GoogleFonts.poppins(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            color: RealTimeColors.primaryGreen,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          stat['label'] as String,
                          style: GoogleFonts.poppins(
                            fontSize: 10,
                            color: AppColors.subtextColor,
                            fontWeight: FontWeight.w500,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    )
                    .animate(delay: Duration(milliseconds: 200 + i * 80))
                    .fadeIn(duration: 400.ms)
                    .slideY(begin: 0.3),
          );
        }).toList(),
      ),
    ).animate().fadeIn(duration: 500.ms, delay: 100.ms);
  }

  // ─── MAIN CONTENT ─────────────────────────────────────────────────────────

  Widget _buildAboutContent() {
    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      sliver: SliverList(
        delegate: SliverChildListDelegate([
          const SizedBox(height: 20),
          _buildOverviewSection(),
          const SizedBox(height: 20),
          _buildMissionVisionSection(),
          const SizedBox(height: 20),
          _buildCoreValuesSection(),
          const SizedBox(height: 20),
          _buildContactSection(),
          const SizedBox(height: 20),
          Center(
            child: Text(
              'Version 1.0.0  ·  © 2025 Real Time Capital',
              style: GoogleFonts.poppins(
                fontSize: 10,
                color: AppColors.subtextColor.withOpacity(0.6),
              ),
            ),
          ).animate().fadeIn(duration: 600.ms, delay: 900.ms),
        ]),
      ),
    );
  }

  // ─── OVERVIEW ────────────────────────────────────────────────────────────────

  Widget _buildOverviewSection() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section header with accent bar
          Container(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
            child: Row(
              children: [
                Container(
                  width: 5,
                  height: 26,
                  decoration: BoxDecoration(
                    color: RealTimeColors.primaryGreen,
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
                const SizedBox(width: 10),
                Text(
                  'Who We Are',
                  style: GoogleFonts.poppins(
                    fontSize: 19,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textColor,
                  ),
                ),
              ],
            ),
          ).animate().fadeIn(duration: 400.ms).slideX(begin: -0.1),
          const SizedBox(height: 14),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Text(
              _companyOverview,
              style: GoogleFonts.poppins(
                fontSize: 13.5,
                color: AppColors.subtextColor,
                height: 1.65,
              ),
            ).animate().fadeIn(duration: 500.ms, delay: 100.ms),
          ),
          Obx(
            () => AnimatedCrossFade(
              firstChild: const SizedBox.shrink(),
              secondChild: Padding(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'This modernization is reflected in our growing emphasis on transparency and customer service. We invest in training staff to provide knowledgeable assistance and create a welcoming environment, supported by integrated software systems that improve efficiency and accuracy.',
                      style: GoogleFonts.poppins(
                        fontSize: 13.5,
                        color: AppColors.subtextColor,
                        height: 1.65,
                      ),
                    ).animate().fadeIn(duration: 300.ms),
                    const SizedBox(height: 10),
                    Text(
                      'As consumers increasingly seek alternative financing options, we position ourselves as a legitimate and convenient choice for those needing quick cash, redefining our role in the financial landscape through the effective use of modern systems.',
                      style: GoogleFonts.poppins(
                        fontSize: 13.5,
                        color: AppColors.subtextColor,
                        height: 1.65,
                      ),
                    ).animate().fadeIn(duration: 300.ms),
                  ],
                ),
              ),
              crossFadeState: _isExpanded.value
                  ? CrossFadeState.showSecond
                  : CrossFadeState.showFirst,
              duration: const Duration(milliseconds: 300),
            ),
          ),
          // Read more toggle
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 18),
            child: GestureDetector(
              onTap: () {
                _isExpanded.toggle();
                if (_isExpanded.value) {
                  _expandController.forward();
                  HapticFeedback.lightImpact();
                } else {
                  _expandController.reverse();
                }
              },
              child: Obx(
                () => Row(
                  mainAxisSize: MainAxisSize.min,
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
                          ? Icons.keyboard_arrow_up_rounded
                          : Icons.keyboard_arrow_down_rounded,
                      color: RealTimeColors.primaryGreen,
                      size: 20,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 600.ms, delay: 300.ms).slideY(begin: 0.15);
  }

  // ─── MISSION & VISION ────────────────────────────────────────────────────────

  Widget _buildMissionVisionSection() {
    return Column(
      children: [
        _buildMVCard(
          delay: 400,
          color: RealTimeColors.primaryGreen,
          icon: Icons.flag_rounded,
          title: 'Our Mission',
          body: _missionStatement,
          slideDir: -0.1,
        ),
        const SizedBox(height: 12),
        _buildMVCard(
          delay: 500,
          color: RealTimeColors.darkGreen,
          icon: Icons.visibility_rounded,
          title: 'Our Vision',
          body: _visionStatement,
          slideDir: 0.1,
        ),
      ],
    );
  }

  Widget _buildMVCard({
    required int delay,
    required Color color,
    required IconData icon,
    required String title,
    required String body,
    required double slideDir,
  }) {
    return Container(
          decoration: BoxDecoration(
            color: AppColors.surfaceColor,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Left accent strip + icon
              Container(
                width: 68,
                padding: const EdgeInsets.symmetric(vertical: 22),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.09),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(20),
                    bottomLeft: Radius.circular(20),
                  ),
                ),
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: color.withOpacity(0.18),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(icon, color: color, size: 24),
                    ),
                  ],
                ),
              ),
              // Content
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 20, 16, 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: GoogleFonts.poppins(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textColor,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        body,
                        style: GoogleFonts.poppins(
                          fontSize: 12.5,
                          color: AppColors.subtextColor,
                          height: 1.6,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        )
        .animate()
        .fadeIn(
          duration: 500.ms,
          delay: Duration(milliseconds: delay),
        )
        .slideX(begin: slideDir);
  }

  // ─── CORE VALUES ─────────────────────────────────────────────────────────────

  Widget _buildCoreValuesSection() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 5,
                height: 26,
                decoration: BoxDecoration(
                  color: RealTimeColors.primaryGreen,
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
              const SizedBox(width: 10),
              Text(
                'Our Core Values',
                style: GoogleFonts.poppins(
                  fontSize: 19,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textColor,
                ),
              ),
            ],
          ).animate().fadeIn(duration: 400.ms).slideX(begin: -0.1),
          const SizedBox(height: 16),
          // 2-column grid for values
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
              childAspectRatio: 1.0,
            ),
            itemCount: _coreValues.length,
            itemBuilder: (context, index) {
              final value = _coreValues[index];
              final isExpanded = expandedValueIndex == index;
              final color = value['color'] as Color;
              return GestureDetector(
                onTap: () {
                  setState(() {
                    expandedValueIndex = isExpanded ? null : index;
                    if (!isExpanded) HapticFeedback.lightImpact();
                  });
                },
                child:
                    AnimatedContainer(
                          duration: const Duration(milliseconds: 250),
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: isExpanded
                                ? color.withOpacity(0.1)
                                : AppColors.backgroundColor,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: isExpanded ? color : AppColors.borderColor,
                              width: isExpanded ? 1.5 : 1,
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                padding: const EdgeInsets.all(9),
                                decoration: BoxDecoration(
                                  color: color.withOpacity(0.12),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Icon(
                                  value['icon'] as IconData,
                                  color: color,
                                  size: 20,
                                ),
                              ),
                              const SizedBox(height: 10),
                              Text(
                                value['title'] as String,
                                style: GoogleFonts.poppins(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.textColor,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Expanded(
                                child: Text(
                                  isExpanded
                                      ? value['description'] as String
                                      : 'Tap to learn more',
                                  style: GoogleFonts.poppins(
                                    fontSize: 10.5,
                                    color: isExpanded
                                        ? AppColors.subtextColor
                                        : AppColors.subtextColor.withOpacity(
                                            0.6,
                                          ),
                                    height: 1.45,
                                  ),
                                  overflow: TextOverflow.fade,
                                ),
                              ),
                            ],
                          ),
                        )
                        .animate()
                        .fadeIn(
                          duration: 400.ms,
                          delay: Duration(milliseconds: 600 + index * 90),
                        )
                        .scale(begin: const Offset(0.95, 0.95)),
              );
            },
          ),
        ],
      ),
    );
  }

  // ─── CONTACT ─────────────────────────────────────────────────────────────────

  Widget _buildContactSection() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [RealTimeColors.primaryGreen, RealTimeColors.darkGreen],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: RealTimeColors.primaryGreen.withOpacity(0.35),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.18),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(
                  Icons.support_agent_rounded,
                  color: Colors.white,
                  size: 32,
                ),
              ),
              const SizedBox(width: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Need Assistance?',
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    'We\'re here 24/7 for you',
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: Colors.white.withOpacity(0.8),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 20),
          // Contact cards row - Now interactive
          Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: _launchEmail,
                  child: _buildContactCard(
                    icon: Icons.email_rounded,
                    label: 'Email',
                    value: 'support@rtcapital.co.zw',
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: GestureDetector(
                  onTap: _launchPhone,
                  child: _buildContactCard(
                    icon: Icons.phone_rounded,
                    label: 'Phone',
                    value: '+263 24 279 1234', // Display format
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              icon: const Icon(Icons.chat_bubble_outline_rounded, size: 18),
              label: Text(
                'Contact Support',
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                ),
              ),
              onPressed: () {
                Get.offAllNamed(RoutesHelper.ticketListScreen);
              }, // Navigate back
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: RealTimeColors.primaryGreen,
                padding: const EdgeInsets.symmetric(vertical: 15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                elevation: 0,
              ),
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 600.ms, delay: 800.ms).slideY(begin: 0.15);
  }

  Widget _buildContactCard({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.2), width: 1),
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.white, size: 18),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: GoogleFonts.poppins(
                    fontSize: 10,
                    color: Colors.white.withOpacity(0.7),
                  ),
                ),
                Text(
                  value,
                  style: GoogleFonts.poppins(
                    fontSize: 10.5,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
