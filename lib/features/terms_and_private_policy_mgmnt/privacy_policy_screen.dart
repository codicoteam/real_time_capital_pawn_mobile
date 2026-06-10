// privacy_policy_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:real_time_pawn/core/utils/pallete.dart'
    show AppColors, RealTimeColors;
import 'package:lottie/lottie.dart';

class PrivacyPolicyScreen extends StatefulWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  State<PrivacyPolicyScreen> createState() => _PrivacyPolicyScreenState();
}

class _PrivacyPolicyScreenState extends State<PrivacyPolicyScreen> {
  final ScrollController _scrollController = ScrollController();

  // Privacy sections
  final List<PrivacySection> _privacySections = [
    PrivacySection(
      title: '🔒 Data Protection Commitment',
      icon: Icons.shield,
      content: '''
Real Time Capital is committed to protecting your privacy and personal data. This Privacy Policy explains how we collect, use, disclose, and safeguard your information when you use our financial services platform.

We comply with the Data Protection Act, 2019 of Kenya and other applicable privacy laws. Your trust is our most valuable asset.

**Controller Details:**
Real Time Capital Ltd
Registration No: PVT-XXXXX
Data Protection Officer: privacy@realtimecapital.co.ke
      ''',
      color: RealTimeColors.primaryGreen,
      iconColor: Colors.white,
    ),
    PrivacySection(
      title: '📊 Information We Collect',
      icon: Icons.collections_bookmark,
      content: '''
**Personal Identification:**
• Full name, date of birth, national ID/passport
• Contact details (email, phone, address)
• Photograph for identity verification
• Signature specimen

**Financial Information:**
• Bank account details
• Mobile money accounts
• Credit history (with consent)
• Income sources
• Tax identification numbers

**Collateral Information:**
• Asset photographs and descriptions
• Valuation reports
• Ownership documents
• Insurance details

**Technical Data:**
• Device information (model, OS, unique IDs)
• IP address and location data
• App usage statistics
• Cookie and tracking data

**Transactional Data:**
• Loan applications and history
• Payment records
• Auction bids and purchases
• Communication logs
      ''',
      color: RealTimeColors.primaryGreen,
      iconColor: Colors.white,
    ),
    PrivacySection(
      title: '🎯 How We Use Your Information',
      icon: Icons.auto_awesome,
      content: '''
**Service Provision:**
• Process loan applications and disbursements
• Manage collateral storage and insurance
• Facilitate auction transactions
• Provide customer support
• Send important service updates

**Legal Compliance:**
• Anti-money laundering checks
• Fraud prevention and detection
• Regulatory reporting requirements
• Tax compliance
• Court orders and legal requests

**Business Operations:**
• Improve our services and user experience
• Develop new products and features
• Conduct market research and analysis
• Monitor service performance
• Ensure platform security

**Marketing (with consent):**
• Send promotional offers
• Notify about new services
• Share educational content
• Invite to events and webinars
      ''',
      color: RealTimeColors.primaryGreen,
      iconColor: Colors.white,
    ),
    PrivacySection(
      title: '🤝 Information Sharing',
      icon: Icons.handshake,
      content: '''
**With Your Consent:**
We share information only with your explicit consent for specific purposes.

**Service Providers:**
• Payment processors and banks
• Cloud storage providers
• SMS and email service providers
• Analytics and monitoring tools
• Customer support platforms

**Legal Requirements:**
• Government authorities (for regulatory compliance)
• Law enforcement agencies (with proper warrants)
• Courts and tribunals
• Auditors and compliance officers

**Business Transfers:**
In case of merger, acquisition, or sale, your information may be transferred to the new entity.

**Aggregated Data:**
We may share anonymized, aggregated data for research and statistical purposes.

**Third Parties We Work With:**
• Credit reference bureaus
• Insurance companies
• Valuation experts
• Security and storage partners
      ''',
      color: RealTimeColors.primaryGreen,
      iconColor: Colors.white,
    ),
    PrivacySection(
      title: '🌍 International Data Transfers',
      icon: Icons.public,
      content: '''
**Cross-Border Processing:**
Some of our service providers may process data outside Kenya. We ensure adequate protection through:

• Standard Contractual Clauses
• Data Protection Agreements
• Adequacy decisions (where applicable)
• Your explicit consent when required

        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
          
**Countries Involved:**
• United States (cloud services)
• European Union (analytics)
• Regional partners in East Africa

**Safeguards Implemented:**
• Encryption during transfer
• Jurisdiction assessments
• Regular security audits
• Breach notification protocols
      ''',
      color: RealTimeColors.primaryGreen,
      iconColor: Colors.white,
    ),
    PrivacySection(
      title: '🛡️ Data Security Measures',
      icon: Icons.security,
      content: '''
**Technical Safeguards:**
• End-to-end encryption (AES-256)
• Secure socket layer (SSL) technology
• Two-factor authentication
• Regular security updates
• Intrusion detection systems

**Organizational Measures:**
• Employee privacy training
• Access controls and role-based permissions
• Data minimization principles
• Regular security assessments
• Incident response plans

**Physical Security:**
• Secured data centers
• Biometric access controls
• 24/7 surveillance
• Fire suppression systems
• Redundant power supply

**Your Role in Security:**
• Use strong, unique passwords
• Enable two-factor authentication
• Log out from shared devices
• Report suspicious activity immediately
• Keep your device software updated
      ''',
      color: RealTimeColors.primaryGreen,
      iconColor: Colors.white,
    ),
    PrivacySection(
      title: '📅 Data Retention',
      icon: Icons.schedule,
      content: '''
**Retention Periods:**
• Account information: 7 years after closure
• Transaction records: 10 years (legal requirement)
• Loan documents: 10 years after repayment
• Communication logs: 5 years
• Marketing consent: Until withdrawn

**Deletion Procedures:**
Upon expiry of retention periods, we:
• Anonymize data where possible
• Securely delete digital records
• Shred physical documents
• Provide deletion confirmation

**Backup Data:**
Backup copies may be retained for additional 6 months before permanent deletion.

**Right to Deletion:**
You may request early deletion, subject to legal obligations.
      ''',
      color: RealTimeColors.primaryGreen,
      iconColor: Colors.white,
    ),
    PrivacySection(
      title: '👥 Your Privacy Rights',
      icon: Icons.people,
      content: '''
**Access & Correction:**
• Request copies of your personal data
• Correct inaccurate information
• Update incomplete data

**Processing Controls:**
• Withdraw consent at any time
• Object to certain processing
• Restrict processing in specific cases

**Data Management:**
• Request data portability
• Exercise right to be forgotten
• Opt-out of marketing communications

**Automated Decisions:**
• Request human review of automated decisions
• Contest automated profiling
• Understand decision-making logic

**How to Exercise Rights:**
Contact our Data Protection Officer:
Email: privacy@realtimecapital.co.ke
Phone: +254 700 000 000
Address: P.O. Box 12345-00100, Nairobi

**Response Time:**
We respond within 30 days, extendable by 60 days for complex requests.
      ''',
      color: RealTimeColors.primaryGreen,
      iconColor: Colors.white,
    ),
    PrivacySection(
      title: '🍪 Cookies & Tracking',
      icon: Icons.cookie,
      content: '''
**Types of Cookies Used:**
• Essential cookies (required for operation)
• Preference cookies (remember your settings)
• Analytics cookies (understand usage)
• Marketing cookies (personalized ads)

**Cookie Management:**
You can control cookies through:
• Browser settings
• App preferences
• Opt-out mechanisms
• Private browsing modes

**Third-Party Tracking:**
We use services like:
• Google Analytics (anonymous usage data)
• Firebase (app performance)
• Sentry (error tracking)

**Do Not Track:**
We respect "Do Not Track" signals where technically feasible.
      ''',
      color: RealTimeColors.primaryGreen,
      iconColor: Colors.black,
    ),
    PrivacySection(
      title: '👶 Children\'s Privacy',
      icon: Icons.child_care,
      content: '''
Our services are not directed to individuals under 18 years of age. We do not knowingly collect personal information from children.

If you believe we have collected information from a child, please contact us immediately for deletion.

Parents and guardians are encouraged to monitor children's internet usage and use parental control tools.
      ''',
      color: RealTimeColors.primaryGreen,
      iconColor: Colors.white,
    ),
    PrivacySection(
      title: '📞 Contact & Complaints',
      icon: Icons.contact_support,
      content:
          '''
**Data Protection Officer:**
Email: privacy@realtimecapital.co.ke
Phone: +254 700 000 000
Hours: Mon-Fri, 8:00 AM - 5:00 PM EAT

**Office of the Data Protection Commissioner:**
If unsatisfied with our response, you may contact:
Office of the Data Protection Commissioner
P.O. Box 30920-00100, Nairobi
Tel: +254 202 212 222
Email: info@odpc.go.ke

**Policy Updates:**
We may update this policy periodically. Check the "Last Updated" date. Continued use constitutes acceptance.

**Last Updated:** ${DateTime.now().year}-${DateTime.now().month.toString().padLeft(2, '0')}-${DateTime.now().day.toString().padLeft(2, '0')}
      ''',
      color: RealTimeColors.primaryGreen,
      iconColor: Colors.white,
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
          _buildPrivacyContent(),
          _buildDownloadSection(),
        ],
      ),
    );
  }

  Widget _buildSliverAppBar() {
    return SliverAppBar(
      expandedHeight: 220,
      floating: false,
      pinned: true,
      backgroundColor: RealTimeColors.darkGreen,
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
                    'assets/lottie/password.json',
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
                            Icons.privacy_tip_rounded,
                            size: 60,
                            color: Colors.white.withValues(alpha: 0.9),
                          ),
                        )
                        .animate()
                        .scale(duration: 600.ms, curve: Curves.elasticOut)
                        .fadeIn(duration: 400.ms),
                    const SizedBox(height: 16),
                    Text(
                          'Your Data, Our Responsibility',
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
                      'Transparent, Secure, Compliant',
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

  Widget _buildPrivacyContent() {
    return SliverList(
      delegate: SliverChildBuilderDelegate((context, index) {
        final section = _privacySections[index];
        return _buildPrivacySection(section, index);
      }, childCount: _privacySections.length),
    );
  }

  Widget _buildPrivacySection(PrivacySection section, int index) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child:
          Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          section.color.withValues(alpha: 0.9),
                          section.color.withValues(alpha: 0.7),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: section.color.withValues(alpha: 0.3),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 50,
                          height: 50,
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.white, width: 2),
                          ),
                          child: Icon(
                            section.icon,
                            color: section.iconColor,
                            size: 28,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Text(
                            section.title,
                            style: GoogleFonts.poppins(
                              color: Colors.white,
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
                      border: Border.all(
                        color: section.color.withValues(alpha: 0.3),
                        width: 1.5,
                      ),
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

  Widget _buildDownloadSection() {
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
                    Text(
                      '📄 Download Policy',
                      style: GoogleFonts.poppins(
                        color: RealTimeColors.logoBlack,
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'You can download a copy of this Privacy Policy for your records:',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.poppins(
                        color: RealTimeColors.grey600,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            icon: Icon(
                              Icons.download,
                              color: RealTimeColors.primaryGreen,
                            ),
                            label: Text(
                              'PDF Version',
                              style: GoogleFonts.poppins(
                                color: RealTimeColors.primaryGreen,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            onPressed: () {
                              // Implement PDF download
                            },
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 15),
                              side: BorderSide(
                                color: RealTimeColors.primaryGreen,
                                width: 1.5,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: OutlinedButton.icon(
                            icon: Icon(
                              Icons.print,
                              color: RealTimeColors.primaryGreen,
                            ),
                            label: Text(
                              'Print',
                              style: GoogleFonts.poppins(
                                color: RealTimeColors.primaryGreen,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            onPressed: () {
                              // Implement print functionality
                            },
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 15),
                              side: BorderSide(
                                color: RealTimeColors.primaryGreen,
                                width: 1.5,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Divider(color: RealTimeColors.grey300, height: 1),
                    const SizedBox(height: 16),
                    Text(
                      'For questions about our privacy practices:',
                      style: GoogleFonts.poppins(
                        color: RealTimeColors.grey600,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 8),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          // Implement contact action
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: RealTimeColors.primaryGreen,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 15),
                        ),
                        child: Text(
                          'Contact Privacy Team',
                          style: GoogleFonts.poppins(
                            color: Colors.white,
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],
                )
                .animate(delay: 1200.ms)
                .slideY(begin: 0.2, duration: 400.ms, curve: Curves.easeOut)
                .fadeIn(duration: 300.ms),
      ),
    );
  }
}

class PrivacySection {
  final String title;
  final IconData icon;
  final String content;
  final Color color;
  final Color iconColor;

  PrivacySection({
    required this.title,
    required this.icon,
    required this.content,
    required this.color,
    this.iconColor = Colors.white,
  });
}
