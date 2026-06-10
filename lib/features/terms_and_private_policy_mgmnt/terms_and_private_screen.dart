// terms_of_service_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:real_time_pawn/core/utils/pallete.dart'
    show AppColors, RealTimeColors;
import 'package:lottie/lottie.dart';

class TermsOfServiceScreen extends StatefulWidget {
  const TermsOfServiceScreen({super.key});

  @override
  State<TermsOfServiceScreen> createState() => _TermsOfServiceScreenState();
}

class _TermsOfServiceScreenState extends State<TermsOfServiceScreen> {
  final ScrollController _scrollController = ScrollController();
  bool _hasAccepted = false;

  // Terms sections
  final List<TermsSection> _termsSections = [
    TermsSection(
      title: '📋 Agreement Overview',
      icon: Icons.description,
      content:
          '''
Welcome to Real Time Capital. These Terms of Service ("Terms") govern your use of our mobile application, website, and services (collectively, the "Services"). By accessing or using our Services, you agree to be bound by these Terms.

Real Time Capital provides collateral-based lending services, auction platforms, and financial management tools through our digital platform.

Last Updated: ${DateTime.now().year}-${DateTime.now().month.toString().padLeft(2, '0')}-${DateTime.now().day.toString().padLeft(2, '0')}
      ''',
      color: RealTimeColors.primaryGreen,
    ),
    TermsSection(
      title: '👤 Eligibility & Registration',
      icon: Icons.person_add,
      content: '''
• You must be at least 18 years old to use our Services
• Must possess legal capacity to enter binding contracts
• Must provide accurate, current, and complete information
• Maintain the security of your account credentials
• Notify us immediately of any unauthorized account access
• Comply with all applicable laws and regulations

Accounts are non-transferable and may be suspended for violation of these Terms.
      ''',
      color: RealTimeColors.primaryGreen,
    ),
    TermsSection(
      title: '💰 Loan Services Terms',
      icon: Icons.monetization_on,
      content: '''
**Collateral-Based Loans:**
• You pledge assets (electronics, vehicles, jewelry) as collateral
• Loan amount determined by current market valuation
• Interest rates range from 3-5% monthly
• Minimum loan term: 1 month | Maximum: 24 months
• Early repayment discounts available

**Valuation Process:**
• Our certified valuers determine asset value
• Valuation reports provided in-app
• Right to refuse any collateral item

**Default & Recovery:**
• Grace period: 7 days from due date
• Late fees: 2% per week on overdue amounts
• Collateral may be auctioned after 60 days default
• Any surplus from auction returned to you
      ''',
      color: RealTimeColors.primaryGreen,
    ),
    TermsSection(
      title: '⚖️ Auction Platform Rules',
      icon: Icons.gavel,
      content: '''
**For Sellers:**
• Must own the assets being auctioned
• Accurate description of items required
• Reserve price minimum: 60% of valuation
• Commission fee: 10% of final sale price
• Payment processed within 3 business days

**For Buyers:**
• Bids are binding commitments to purchase
• Winning bidder must complete payment within 24 hours
• Items collected within 5 business days
• Inspection period: 48 hours from collection

**Platform Rules:**
• No fraudulent listings
• No shill bidding
• Reserve the right to cancel suspicious auctions
• Dispute resolution through our arbitration process
      ''',
      color: RealTimeColors.primaryGreen,
    ),
    TermsSection(
      title: '📱 App Usage & Restrictions',
      icon: Icons.phone_iphone,
      content: '''
**Permitted Use:**
• Personal, non-commercial use
• Loan applications and management
• Auction participation
• Financial tracking
• Communication with loan officers

**Prohibited Activities:**
• Reverse engineering or decompiling app
• Creating multiple accounts for fraud
• Using bots or automated systems
• Harassing other users
• Uploading malicious content
• Attempting to circumvent security measures

**Intellectual Property:**
• All app content is owned by Real Time Capital
• Limited license granted for personal use
• No copying, modifying, or distributing without permission
      ''',
      color: RealTimeColors.primaryGreen,
    ),
    TermsSection(
      title: '🛡️ Liability & Disclaimers',
      icon: Icons.security,
      content: '''
**Service Availability:**
• We strive for 24/7 availability but don't guarantee uptime
• May suspend services for maintenance
• Not liable for service interruptions

**Financial Disclaimers:**
• Not financial advice - seek professional guidance
• Past performance doesn't guarantee future results
• Market conditions affect collateral values
• We're not responsible for investment decisions

**Limitation of Liability:**
• Maximum liability limited to fees paid in last 6 months
• Not liable for indirect, incidental, or consequential damages
• Not liable for third-party actions
• Force majeure clause applies

**Indemnification:**
You agree to indemnify Real Time Capital against claims arising from your:
• Violation of these Terms
• Use of the Services
• Infringement of third-party rights
      ''',
      color: RealTimeColors.primaryGreen,
    ),
    TermsSection(
      title: '📝 Amendments & Termination',
      icon: Icons.edit_document,
      content: '''
**Changes to Terms:**
• We may update these Terms periodically
• Continued use constitutes acceptance of changes
• Major changes will be notified 30 days in advance

**Account Termination:**
You may terminate your account at any time by:
1. Contacting customer support
2. Clearing all outstanding balances
3. Collecting pledged collateral

We may terminate or suspend your account for:
• Violation of these Terms
• Fraudulent activity
• Non-payment for 90+ days
• Legal compliance requirements

**Survival:**
Certain provisions survive termination:
• Intellectual property rights
• Liability limitations
• Indemnification obligations
• Dispute resolution
      ''',
      color: RealTimeColors.primaryGreen,
    ),
    TermsSection(
      title: '⚖️ Governing Law & Disputes',
      icon: Icons.balance,
      content: '''
**Governing Law:**
These Terms are governed by the laws of Kenya, without regard to conflict of law principles.

**Dispute Resolution:**
1. Informal Negotiation: 30-day negotiation period
2. Mediation: Through Nairobi arbitration center
3. Arbitration: Binding arbitration in Nairobi
4. Class Action Waiver: No class actions permitted

**Jurisdiction:**
Any legal proceedings shall be in the courts of Nairobi, Kenya.

**Contact for Legal Notices:**
Real Time Capital Legal Department
P.O. Box 12345-00100, Nairobi
legal@realtimecapital.co.ke
+254 700 000 000
      ''',
      color: RealTimeColors.primaryGreen,
    ),
  ];

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      body: CustomScrollView(
        controller: _scrollController,
        slivers: [
          _buildSliverAppBar(),
          _buildTermsContent(),
          _buildAcceptanceSection(),
        ],
      ),
    );
  }

  Widget _buildSliverAppBar() {
    return SliverAppBar(
      expandedHeight: 220,
      floating: false,
      pinned: true,
      backgroundColor: RealTimeColors.primaryGreen,
      iconTheme: const IconThemeData(color: Colors.white), // Add this
      actionsIconTheme: const IconThemeData(color: Colors.white), // Add this
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                RealTimeColors.primaryGreen,
                RealTimeColors.darkGreen,
                Color(0xFF48BB78),
              ],
            ),
          ),
          child: Stack(
            children: [
              Positioned(
                right: 20,
                top: 60,
                child: Opacity(
                  opacity: 0.1,
                  child: Lottie.asset(
                    'assets/lottie/terms.json',
                    width: 180,
                    height: 180,
                  ),
                ),
              ),
              Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                          width: 100,
                          height: 100,
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(25),
                            border: Border.all(color: Colors.white30, width: 2),
                          ),
                          child: Icon(
                            Icons.verified_user_rounded,
                            size: 60,
                            color: Colors.white.withValues(alpha: 0.9),
                          ),
                        )
                        .animate()
                        .scale(duration: 600.ms, curve: Curves.elasticOut)
                        .fadeIn(duration: 400.ms),
                    const SizedBox(height: 16),
                    Text(
                          'Legal Agreement & User Terms',
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.9),
                            fontSize: 18,
                            fontWeight: FontWeight.w500,
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
                      'Please read carefully before using our services',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.7),
                        fontSize: 14,
                      ),
                    ).animate(delay: 300.ms).fadeIn(duration: 400.ms),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTermsContent() {
    return SliverList(
      delegate: SliverChildBuilderDelegate((context, index) {
        final section = _termsSections[index];
        return _buildTermsSection(section, index);
      }, childCount: _termsSections.length),
    );
  }

  Widget _buildTermsSection(TermsSection section, int index) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child:
          Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: section.color.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: section.color.withValues(alpha: 0.3),
                        width: 1.5,
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 50,
                          height: 50,
                          decoration: BoxDecoration(
                            color: section.color.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: section.color, width: 2),
                          ),
                          child: Icon(
                            section.icon,
                            color: section.color,
                            size: 28,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Text(
                            section.title,
                            style: GoogleFonts.poppins(
                              color: RealTimeColors.logoBlack,
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceColor,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withValues(alpha: 0.1),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                      border: Border.all(color: RealTimeColors.grey200),
                    ),
                    child: Text(
                      section.content,
                      style: GoogleFonts.poppins(
                        color: RealTimeColors.grey700,
                        fontSize: 14.5,
                        height: 1.6,
                      ),
                    ),
                  ),
                ],
              )
              .animate(delay: (index * 100).ms)
              .slideX(begin: 0.1, duration: 400.ms, curve: Curves.easeOut)
              .fadeIn(duration: 300.ms),
    );
  }

  Widget _buildAcceptanceSection() {
    return SliverToBoxAdapter(
      child: Container(
        margin: const EdgeInsets.all(16),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppColors.surfaceColor,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: RealTimeColors.primaryGreen.withValues(alpha: 0.1),
              blurRadius: 15,
              offset: const Offset(0, 5),
            ),
          ],
          border: Border.all(color: RealTimeColors.grey300, width: 1.5),
        ),
        child:
            Column(
                  children: [
                    Row(
                      children: [
                        Checkbox(
                          value: _hasAccepted,
                          onChanged: (value) {
                            setState(() {
                              _hasAccepted = value ?? false;
                            });
                          },
                          activeColor: RealTimeColors.primaryGreen,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(6),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'I have read, understood, and agree to the Terms of Service',
                            style: GoogleFonts.poppins(
                              color: RealTimeColors.logoBlack,
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        onPressed: _hasAccepted
                            ? () {
                                Navigator.pop(context, true);
                              }
                            : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: RealTimeColors.primaryGreen,
                          disabledBackgroundColor: RealTimeColors.grey400,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 3,
                        ),
                        child: Text(
                          'Accept & Continue',
                          style: GoogleFonts.poppins(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextButton(
                      onPressed: () {
                        Navigator.pop(context, false);
                      },
                      child: Text(
                        'Decline & Exit',
                        style: GoogleFonts.poppins(
                          color: RealTimeColors.grey600,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ],
                )
                .animate(delay: 800.ms)
                .slideY(begin: 0.2, duration: 400.ms, curve: Curves.easeOut)
                .fadeIn(duration: 300.ms),
      ),
    );
  }
}

class TermsSection {
  final String title;
  final IconData icon;
  final String content;
  final Color color;

  TermsSection({
    required this.title,
    required this.icon,
    required this.content,
    required this.color,
  });
}
