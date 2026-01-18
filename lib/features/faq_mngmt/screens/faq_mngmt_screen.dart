import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:lottie/lottie.dart'; // Add this to pubspec.yaml: lottie: ^2.7.0

import '../../../core/utils/pallete.dart' show AppColors;

class FaqScreen extends StatefulWidget {
  const FaqScreen({super.key});

  @override
  State<FaqScreen> createState() => _FaqScreenState();
}

class _FaqScreenState extends State<FaqScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  int? expandedIndex;
  String searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  final List<FaqItem> _faqItems = [
    FaqItem(
      category: 'Loan Products',
      question: 'What types of collateral-based loans do you offer?',
      answer:
          'We offer three specialized collateral loans: 1) Electric Gadget Collateral Loan (smartphones, laptops, tablets), 2) Motor Vehicle Loan (cars, motorcycles), and 3) Jewellery Loan (gold, diamonds, watches). Simply bring your item to our nearest office for valuation.',
      icon: Icons.credit_card,
      iconColor: Colors.blue,
    ),
    FaqItem(
      category: 'Loan Application',
      question: 'How do I apply for a loan through the app?',
      answer:
          '1. Download the Real Time Capital app\n2. Complete registration with your details\n3. Select "Apply for Loan" and choose loan type\n4. Book an appointment at your nearest branch\n5. Bring your collateral item for valuation\n6. Receive instant approval & funds transfer',
      icon: Icons.app_registration,
      iconColor: Colors.green,
    ),
    FaqItem(
      category: 'Collateral Process',
      question: 'What happens to my collateral item?',
      answer:
          'Your collateral is securely stored in our insured vault facilities. We provide you with a detailed receipt and storage certificate. You can track your item status in the app. All items are professionally maintained and insured for their full value during the loan period.',
      icon: Icons.security,
      iconColor: Colors.orange,
    ),
    FaqItem(
      category: 'Loan Repayment',
      question: 'How do I repay my loan through the app?',
      answer:
          'Repayments are seamless in our app! Go to "My Loans" → Select active loan → Tap "Make Payment" → Choose payment method (Mobile Money, Bank Transfer, or Card) → Enter amount → Confirm. You\'ll receive instant confirmation and updated loan statement. Early payments are welcomed with no penalties!',
      icon: Icons.payment,
      iconColor: Colors.purple,
    ),
    FaqItem(
      category: 'Asset Auctions',
      question: 'How do auctions work in the app?',
      answer:
          'Our live auctions let you buy quality items at great prices! Browse available assets → View detailed photos & descriptions → Place your bid → Get notified if outbid → Win the auction → Collect item from our office. Auctions refresh daily with new collateral items.',
      icon: Icons.gavel,
      iconColor: Colors.red,
    ),
    FaqItem(
      category: 'Valuation Process',
      question: 'How is my collateral valued?',
      answer:
          'Our certified valuers use market data and condition assessment:\n• Gadgets: Brand, model, condition, market demand\n• Vehicles: Year, mileage, condition, service history\n• Jewellery: Karat purity, weight, gem quality, craftsmanship\nYou receive a transparent valuation report in the app.',
      icon: Icons.assessment,
      iconColor: Colors.teal,
    ),
    FaqItem(
      category: 'Loan Amounts',
      question: 'How much can I borrow against my collateral?',
      answer:
          'Loan amounts vary by collateral type:\n• Electronics: 40-60% of current market value\n• Vehicles: 50-70% of valuation\n• Jewellery: 60-80% of gold/metal value\nExample: A Ksh 100,000 smartphone can secure Ksh 40,000-60,000 instantly.',
      icon: Icons.attach_money,
      iconColor: Colors.amber,
    ),
    FaqItem(
      category: 'Interest & Fees',
      question: 'What are the interest rates and fees?',
      answer:
          'We offer competitive rates:\n• Monthly interest: 3-5% depending on loan type\n• Processing fee: 2% of loan amount (one-time)\n• Storage fee: 1% monthly for physical storage\n• No hidden charges! All fees displayed upfront in app.\nEarly repayment discounts available!',
      icon: Icons.account_balance_wallet,
      iconColor: Colors.indigo,
    ),
    FaqItem(
      category: 'Auction Participation',
      question: 'Can I auction items without taking a loan?',
      answer:
          'Absolutely! Our "Sell via Auction" feature lets you:\n1. List items for auction (we handle valuation)\n2. Set minimum reserve price\n3. Items displayed to thousands of buyers\n4. We handle payments & security\n5. Receive proceeds minus 10% commission\nGreat for quick cash without loans!',
      icon: Icons.storefront,
      iconColor: Colors.deepOrange,
    ),
    FaqItem(
      category: 'Loan Duration',
      question: 'How long are the loan repayment periods?',
      answer:
          'Flexible terms tailored to your needs:\n• Short-term: 1-3 months (electronics)\n• Medium-term: 3-12 months (vehicles)\n• Long-term: 6-24 months (jewellery)\nYou can extend the period in-app with a simple fee. Automatic reminders before due dates.',
      icon: Icons.calendar_today,
      iconColor: Colors.blueGrey,
    ),
    FaqItem(
      category: 'Security',
      question: 'Is my collateral safe with Real Time Capital?',
      answer:
          'MAXIMUM SECURITY GUARANTEED:\n• 24/7 armed security at all storage facilities\n• Fireproof, climate-controlled vaults\n• Comprehensive insurance coverage\n• Digital tracking with tamper-proof seals\n• Live CCTV accessible in your app\n• Regular audit reports shared with clients',
      icon: Icons.verified_user,
      iconColor: Colors.green,
    ),
    FaqItem(
      category: 'Default & Recovery',
      question: 'What happens if I cannot repay my loan?',
      answer:
          'We work with you! Options include:\n1. Loan restructuring (extend period)\n2. Partial payment arrangements\n3. Additional collateral top-up\n4. Voluntary surrender of collateral\nIf no arrangement, collateral goes to auction. Any surplus after loan clearance is returned to you!',
      icon: Icons.help_outline,
      iconColor: Colors.brown,
    ),
    FaqItem(
      category: 'Mobile Features',
      question: 'What can I do in the Real Time Capital app?',
      answer:
          'FULL-SERVICE FINANCE APP:\n✓ Apply for loans & track progress\n✓ Make payments & view statements\n✓ Browse & bid in live auctions\n✓ Sell items via auction\n✓ Track collateral status\n✓ Schedule branch visits\n✓ Chat with loan officers\n✓ Get market value alerts\nAll in one secure platform!',
      icon: Icons.phone_iphone,
      iconColor: Colors.deepPurple,
    ),
    FaqItem(
      category: 'Contact & Support',
      question: 'How do I contact customer support?',
      answer:
          'Multiple support channels:\n• IN-APP CHAT: 24/7 with loan officers\n• CALL: 0700 000 000 / 0722 000 000\n• WHATSAPP: +254 700 000 000\n• EMAIL: support@realtimecapital.co.ke\n• BRANCHES: Nairobi, Mombasa, Kisumu, Nakuru\n• SOCIAL: @RealTimeCapitalKE\nAverage response time: 15 minutes!',
      icon: Icons.headset_mic,
      iconColor: Colors.cyan,
    ),
  ];

  List<FaqItem> get filteredFaqItems {
    if (searchQuery.isEmpty) return _faqItems;
    return _faqItems
        .where(
          (item) =>
              item.question.toLowerCase().contains(searchQuery.toLowerCase()) ||
              item.answer.toLowerCase().contains(searchQuery.toLowerCase()) ||
              item.category.toLowerCase().contains(searchQuery.toLowerCase()),
        )
        .toList();
  }

  Map<String, List<FaqItem>> get groupedFaqItems {
    final Map<String, List<FaqItem>> grouped = {};
    for (final item in filteredFaqItems) {
      grouped.putIfAbsent(item.category, () => []).add(item);
    }
    return grouped;
  }

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      body: CustomScrollView(
        slivers: [
          _buildSliverAppBar(),
          SliverToBoxAdapter(child: _buildSearchBar()),
          SliverToBoxAdapter(child: _buildQuickStats()),
          _buildFaqContent(),
        ],
      ),
    );
  }

  Widget _buildSliverAppBar() {
    return SliverAppBar(
      expandedHeight: 250,
      floating: false,
      pinned: true,
      backgroundColor: const Color(0xFF1A237E), // Deep blue for finance
      flexibleSpace: FlexibleSpaceBar(
        title: Text(
          'Real Time Capital FAQ',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        background: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xFF1A237E), // Dark blue
                Color(0xFF283593), // Medium blue
                Color(0xFF5C6BC0), // Light blue
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
                    'assets/animations/finance.json', // Add finance animation
                    width: 200,
                    height: 200,
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
                            color: Colors.white.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(25),
                            border: Border.all(color: Colors.white30, width: 2),
                          ),
                          child: Icon(
                            Icons.quiz_rounded,
                            size: 60,
                            color: Colors.white.withOpacity(0.9),
                          ),
                        )
                        .animate()
                        .scale(duration: 600.ms, curve: Curves.elasticOut)
                        .fadeIn(duration: 400.ms),
                    const SizedBox(height: 16),
                    Text(
                          'Instant Collateral Loans & Auctions',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.9),
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
                      'Your assets. Your money. Real time.',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.7),
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

  Widget _buildSearchBar() {
    return Container(
          margin: const EdgeInsets.all(16),
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(15),
            boxShadow: [
              BoxShadow(
                color: Colors.blue.withOpacity(0.1),
                blurRadius: 15,
                offset: const Offset(0, 4),
                spreadRadius: 1,
              ),
            ],
            border: Border.all(color: Colors.blue.shade100, width: 1.5),
          ),
          child: Row(
            children: [
              Icon(Icons.search, color: Colors.blue.shade600, size: 24),
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
                    hintText: 'Search loans, auctions, payments...',
                    hintStyle: TextStyle(color: Colors.grey.shade500),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  style: TextStyle(
                    color: Colors.grey.shade800,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              if (searchQuery.isNotEmpty)
                IconButton(
                  icon: Icon(
                    Icons.clear,
                    color: Colors.blue.shade600,
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
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          _buildStatCard('3 Loan Types', Icons.diversity_3, Colors.blue),
          const SizedBox(width: 10),
          _buildStatCard('Instant Approval', Icons.bolt, Colors.amber),
          const SizedBox(width: 10),
          _buildStatCard('Live Auctions', Icons.gavel, Colors.red),
          const SizedBox(width: 10),
          _buildStatCard('App Payments', Icons.payment, Colors.green),
        ],
      ),
    ).animate(delay: 100.ms).fadeIn(duration: 300.ms);
  }

  Widget _buildStatCard(String title, IconData icon, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.3), width: 1),
        ),
        child: Column(
          children: [
            Icon(icon, size: 20, color: color),
            const SizedBox(height: 6),
            Text(
              title,
              style: TextStyle(
                color: Colors.grey.shade800,
                fontSize: 10,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFaqContent() {
    if (filteredFaqItems.isEmpty) {
      return SliverToBoxAdapter(child: _buildEmptyState());
    }

    return SliverList(
      delegate: SliverChildBuilderDelegate((context, index) {
        final categories = groupedFaqItems.keys.toList();
        final category = categories[index];
        final items = groupedFaqItems[category]!;

        return _buildCategorySection(category, items, index);
      }, childCount: groupedFaqItems.keys.length),
    );
  }

  Widget _buildCategorySection(
    String category,
    List<FaqItem> items,
    int sectionIndex,
  ) {
    return Container(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    height: 24,
                    width: 5,
                    decoration: BoxDecoration(
                      color: _getCategoryColor(category),
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      category,
                      style: TextStyle(
                        color: Colors.grey.shade800,
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: _getCategoryColor(category).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      '${items.length} FAQs',
                      style: TextStyle(
                        color: _getCategoryColor(category),
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              ...items.asMap().entries.map((entry) {
                final itemIndex = entry.key;
                final item = entry.value;
                final globalIndex = _faqItems.indexOf(item);

                return _buildFaqItem(item, globalIndex, itemIndex * 100);
              }),
            ],
          ),
        )
        .animate(delay: (sectionIndex * 100).ms)
        .slideX(begin: 0.1, duration: 400.ms, curve: Curves.easeOut)
        .fadeIn(duration: 300.ms);
  }

  Color _getCategoryColor(String category) {
    switch (category) {
      case 'Loan Products':
        return Colors.blue;
      case 'Loan Application':
        return Colors.green;
      case 'Collateral Process':
        return Colors.orange;
      case 'Loan Repayment':
        return Colors.purple;
      case 'Asset Auctions':
        return Colors.red;
      default:
        return Colors.blue.shade600;
    }
  }

  Widget _buildFaqItem(FaqItem item, int index, int delay) {
    final isExpanded = expandedIndex == index;

    return Container(
          margin: const EdgeInsets.only(bottom: 16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.15),
                blurRadius: 12,
                offset: const Offset(0, 4),
                spreadRadius: 1,
              ),
            ],
            border: Border.all(
              color: isExpanded ? item.iconColor : Colors.grey.shade200,
              width: isExpanded ? 1.5 : 1,
            ),
          ),
          child: Theme(
            data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
            child: ExpansionTile(
              leading: Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      item.iconColor.withOpacity(0.2),
                      item.iconColor.withOpacity(0.1),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: item.iconColor.withOpacity(0.3)),
                ),
                child: Icon(item.icon, color: item.iconColor, size: 26),
              ),
              title: Text(
                item.question,
                style: TextStyle(
                  color: Colors.grey.shade900,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  height: 1.3,
                ),
              ),
              trailing: Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: isExpanded
                      ? item.iconColor.withOpacity(0.1)
                      : Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: AnimatedRotation(
                  duration: const Duration(milliseconds: 300),
                  turns: isExpanded ? 0.5 : 0,
                  child: Icon(
                    Icons.expand_more_rounded,
                    color: isExpanded ? item.iconColor : Colors.grey.shade600,
                  ),
                ),
              ),
              onExpansionChanged: (expanded) {
                setState(() {
                  expandedIndex = expanded ? index : null;
                });
                if (expanded) {
                  HapticFeedback.lightImpact();
                }
              },
              children: [
                Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      margin: const EdgeInsets.only(
                        top: 8,
                        left: 16,
                        right: 16,
                      ),
                      decoration: BoxDecoration(
                        color: item.iconColor.withOpacity(0.03),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: item.iconColor.withOpacity(0.1),
                          width: 1,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.info_outline_rounded,
                                size: 18,
                                color: item.iconColor,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Detailed Answer',
                                style: TextStyle(
                                  color: item.iconColor,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Text(
                            item.answer,
                            style: TextStyle(
                              color: Colors.grey.shade700,
                              fontSize: 15,
                              height: 1.6,
                            ),
                          ),
                          if (item.question.contains('contact') ||
                              item.question.contains('support'))
                            const SizedBox(height: 16),
                          if (item.question.contains('contact') ||
                              item.question.contains('support'))
                            _buildContactButtons(),
                        ],
                      ),
                    )
                    .animate()
                    .slideY(
                      begin: -0.2,
                      duration: 300.ms,
                      curve: Curves.easeOut,
                    )
                    .fadeIn(duration: 250.ms),
              ],
            ),
          ),
        )
        .animate(delay: delay.ms)
        .slideX(begin: 0.1, duration: 400.ms, curve: Curves.easeOut)
        .fadeIn(duration: 300.ms);
  }

  Widget _buildContactButtons() {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton.icon(
            icon: Icon(Icons.chat, size: 18, color: Colors.blue),
            label: Text(
              'Live Chat',
              style: TextStyle(fontSize: 13, color: Colors.blue),
            ),
            onPressed: () {},
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 10),
              side: BorderSide(color: Colors.blue.shade300),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: ElevatedButton.icon(
            icon: Icon(Icons.call, size: 18, color: Colors.white),
            label: Text('Call Now', style: TextStyle(fontSize: 13)),
            onPressed: () {},
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              padding: const EdgeInsets.symmetric(vertical: 10),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
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
                width: 150,
                height: 150,
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(75),
                  border: Border.all(color: Colors.blue.shade100, width: 2),
                ),
                child: Icon(
                  Icons.search_off_rounded,
                  size: 80,
                  color: Colors.blue.shade300,
                ),
              )
              .animate()
              .scale(duration: 600.ms, curve: Curves.elasticOut)
              .fadeIn(duration: 400.ms),
          const SizedBox(height: 24),
          Text(
                'No matches found',
                style: TextStyle(
                  color: Colors.grey.shade900,
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                ),
              )
              .animate(delay: 200.ms)
              .slideY(begin: 0.3, duration: 400.ms, curve: Curves.easeOut)
              .fadeIn(duration: 300.ms),
          const SizedBox(height: 12),
          Text(
                'Try searching for "loan application", "auction", "payment", or "collateral"',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey.shade600, fontSize: 15),
              )
              .animate(delay: 400.ms)
              .slideY(begin: 0.3, duration: 400.ms, curve: Curves.easeOut)
              .fadeIn(duration: 300.ms),
          const SizedBox(height: 24),
          ElevatedButton.icon(
                icon: Icon(Icons.explore, size: 18),
                label: Text('Browse All Categories'),
                onPressed: () {
                  _searchController.clear();
                  setState(() {
                    searchQuery = '';
                  });
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue.shade600,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 14,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              )
              .animate(delay: 600.ms)
              .scale(duration: 400.ms, curve: Curves.easeOutBack)
              .fadeIn(duration: 300.ms),
        ],
      ),
    );
  }
}

class FaqItem {
  final String category;
  final String question;
  final String answer;
  final IconData icon;
  final Color iconColor;

  FaqItem({
    required this.category,
    required this.question,
    required this.answer,
    required this.icon,
    this.iconColor = Colors.blue,
  });
}
