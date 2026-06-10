import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/utils/pallete.dart' show AppColors, RealTimeColors;

class FaqScreen extends StatefulWidget {
  const FaqScreen({super.key});

  @override
  State<FaqScreen> createState() => _FaqScreenState();
}

class _FaqScreenState extends State<FaqScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int? expandedIndex;
  String selectedCategory = 'All';

  final List<FaqItem> _faqItems = [
    FaqItem(
      category: 'Loan Products',
      question: 'What types of collateral-based loans do you offer?',
      answer:
          'We offer three specialized collateral loans:\n\n• Electric Gadget Loan — smartphones, laptops, tablets\n• Motor Vehicle Loan — cars, motorcycles\n• Jewellery Loan — gold, diamonds, watches\n\nSimply bring your item to our nearest office for valuation.',
      icon: Icons.credit_card_rounded,
      iconColor: RealTimeColors.primaryGreen,
    ),
    FaqItem(
      category: 'Loan Application',
      question: 'How do I apply for a loan through the app?',
      answer:
          '1. Download the Real Time Capital app\n2. Complete registration with your details\n3. Select "Apply for Loan" and choose loan type\n4. Book an appointment at your nearest branch\n5. Bring your collateral item for valuation\n6. Receive instant approval & funds transfer',
      icon: Icons.app_registration_rounded,
      iconColor: RealTimeColors.success,
    ),
    FaqItem(
      category: 'Collateral Process',
      question: 'What happens to my collateral item?',
      answer:
          'Your collateral is securely stored in our insured vault facilities. We provide you with a detailed receipt and storage certificate. You can track your item status in the app. All items are professionally maintained and insured for their full value during the loan period.',
      icon: Icons.security_rounded,
      iconColor: RealTimeColors.warning,
    ),
    FaqItem(
      category: 'Loan Repayment',
      question: 'How do I repay my loan through the app?',
      answer:
          'Repayments are seamless in our app!\n\nGo to "My Loans" → Select active loan → Tap "Make Payment" → Choose payment method (Mobile Money, Bank Transfer, or Card) → Enter amount → Confirm.\n\nYou\'ll receive instant confirmation and an updated loan statement. Early payments are welcomed with no penalties!',
      icon: Icons.payment_rounded,
      iconColor: RealTimeColors.darkGreen,
    ),
    FaqItem(
      category: 'Loan Repayment',
      question: 'Can I pay off my loan early?',
      answer:
          'Yes, you can settle your loan early. Please contact customer support for any early settlement terms that may apply.',
      icon: Icons.paid_rounded,
      iconColor: RealTimeColors.primaryGreen,
    ),
    FaqItem(
      category: 'Asset Auctions',
      question: 'How do auctions work in the app?',
      answer:
          'Our live auctions let you buy quality items at great prices!\n\nBrowse available assets → View detailed photos & descriptions → Place your bid → Get notified if outbid → Win the auction → Collect item from our office.\n\nAuctions refresh daily with new collateral items.',
      icon: Icons.gavel_rounded,
      iconColor: RealTimeColors.error,
    ),
    FaqItem(
      category: 'Valuation Process',
      question: 'How is my collateral valued?',
      answer:
          'Our certified valuers use market data and condition assessment:\n\n• Gadgets: Brand, model, condition, market demand\n• Vehicles: Year, mileage, condition, service history\n• Jewellery: Karat purity, weight, gem quality, craftsmanship\n\nYou receive a transparent valuation report in the app.',
      icon: Icons.assessment_rounded,
      iconColor: RealTimeColors.primaryGreen,
    ),
    FaqItem(
      category: 'Loan Amounts',
      question: 'How much can I borrow against my collateral?',
      answer:
          'Loan amounts vary by collateral type:\n\n• Electronics: 40–60% of current market value\n• Vehicles: 50–70% of valuation\n• Jewellery: 60–80% of gold/metal value\n\nExample: A \$100,000 smartphone can secure \$40,000–\$60,000 instantly.',
      icon: Icons.attach_money_rounded,
      iconColor: RealTimeColors.success,
    ),
    FaqItem(
      category: 'Interest & Fees',
      question: 'What are the interest rates and fees?',
      answer:
          'We offer competitive rates:\n\n• Monthly interest: 3–5% depending on loan type\n• Processing fee: 2% of loan amount (one-time)\n• Storage fee: 1% monthly for physical storage\n• No hidden charges! All fees displayed upfront in app.\n\nEarly repayment discounts available!',
      icon: Icons.account_balance_wallet_rounded,
      iconColor: RealTimeColors.darkGreen,
    ),
    FaqItem(
      category: 'Asset Auctions',
      question: 'Can I auction items without taking a loan?',
      answer:
          'Absolutely! Our "Sell via Auction" feature lets you:\n\n1. List items for auction (we handle valuation)\n2. Set minimum reserve price\n3. Items displayed to thousands of buyers\n4. We handle payments & security\n5. Receive proceeds minus 10% commission\n\nGreat for quick cash without loans!',
      icon: Icons.storefront_rounded,
      iconColor: RealTimeColors.warning,
    ),
    FaqItem(
      category: 'Loan Amounts',
      question: 'How long are the loan repayment periods?',
      answer:
          'Flexible terms tailored to your needs:\n\n• Short-term: 1–3 months (electronics)\n• Medium-term: 3–12 months (vehicles)\n• Long-term: 6–24 months (jewellery)\n\nYou can extend the period in-app with a simple fee. Automatic reminders before due dates.',
      icon: Icons.calendar_today_rounded,
      iconColor: RealTimeColors.primaryGreen,
    ),
    FaqItem(
      category: 'Security',
      question: 'Is my collateral safe with Real Time Capital?',
      answer:
          'Maximum security guaranteed:\n\n• 24/7 armed security at all storage facilities\n• Fireproof, climate-controlled vaults\n• Comprehensive insurance coverage\n• Digital tracking with tamper-proof seals\n• Regular audit reports shared with clients',
      icon: Icons.verified_user_rounded,
      iconColor: RealTimeColors.success,
    ),
    FaqItem(
      category: 'Security',
      question: 'Is my item safe while pawned?',
      answer:
          'Yes, all pawned items are securely stored in our insured facilities. We track each item\'s location and status to ensure its safety throughout the loan period.',
      icon: Icons.lock_rounded,
      iconColor: RealTimeColors.success,
    ),
    FaqItem(
      category: 'Default & Recovery',
      question: 'What happens if I cannot repay my loan?',
      answer:
          'We work with you! Options include:\n\n1. Loan restructuring (extend period)\n2. Partial payment arrangements\n3. Additional collateral top-up\n4. Voluntary surrender of collateral\n\nIf no arrangement is reached, collateral goes to auction. Any surplus after loan clearance is returned to you!',
      icon: Icons.help_outline_rounded,
      iconColor: RealTimeColors.error,
    ),
    FaqItem(
      category: 'Mobile Features',
      question: 'What can I do in the Real Time Capital app?',
      answer:
          'Full-service finance app:\n\n✓ Apply for loans & track progress\n✓ Make payments & view statements\n✓ Browse & bid in live auctions\n✓ Sell items via auction\n✓ Track collateral status\n✓ Schedule branch visits\n✓ Chat with loan officers\n✓ Get market value alerts',
      icon: Icons.phone_iphone_rounded,
      iconColor: RealTimeColors.primaryGreen,
    ),
    FaqItem(
      category: 'Contact & Support',
      question: 'How do I contact customer support?',
      answer:
          'Multiple support channels available:\n\n• IN-APP CHAT: 24/7 with loan officers\n• CALL: 0700 000 000 / 0722 000 000\n• WHATSAPP: +254 700 000 000\n• EMAIL: support@realtimecapital.co.zw\n• BRANCHES: Harare, Bulawayo, Mutare\n• SOCIAL: @RealTimeCapitalZW\n\nAverage response time: 15 minutes!',
      icon: Icons.headset_mic_rounded,
      iconColor: RealTimeColors.warning,
    ),

    // ── Status Guide ──────────────────────────────────────────────────────────
    FaqItem(
      category: 'Status Guide',
      question: 'What do the loan application statuses mean?',
      answer:
          'Your loan application moves through these stages:\n\n'
          '• Pending — Your application has been submitted and is waiting to be picked up by a loan officer.\n\n'
          '• Under Review — A loan officer is actively reviewing your documents and collateral details.\n\n'
          '• Approved — Congratulations! Your loan is approved and funds are being processed for disbursement.\n\n'
          '• Rejected — Your application was not approved at this time. The reason is shown in the app. You may reapply after addressing the noted issues.\n\n'
          '• Cancelled — The application was withdrawn (either by you or by our team before processing).',
      icon: Icons.assignment_turned_in_rounded,
      iconColor: RealTimeColors.success,
    ),
    FaqItem(
      category: 'Status Guide',
      question: 'What do the different loan statuses mean?',
      answer:
          'Once your loan is active, its status reflects your repayment journey:\n\n'
          '• Active — Your loan is running smoothly and the due date has not yet passed. No action needed.\n\n'
          '• Overdue — Your repayment due date has passed without a payment. Please pay immediately to avoid a penalty.\n\n'
          '• In Grace Period — You are within the 7-day grace window after the due date. A 10% penalty has been added to your balance. Pay within this window to reclaim your collateral.\n\n'
          '• Auction — Your 7-day grace period has expired. Your collateral item has been moved to our live auction to recover the outstanding loan amount.\n\n'
          '• Redeemed — You have fully repaid your loan. Your collateral item has been released and returned to you.\n\n'
          '• Closed — Your loan account is closed (fully settled or administratively written off).',
      icon: Icons.account_balance_rounded,
      iconColor: RealTimeColors.warning,
    ),
    FaqItem(
      category: 'Status Guide',
      question: 'What do the auction item statuses mean?',
      answer:
          'Items in our live auction can carry these statuses:\n\n'
          '• Active — The auction is live and accepting bids. Place your bid before the timer runs out!\n\n'
          '• Sold — The item was successfully sold to the highest bidder. Pickup arrangements are coordinated by our team.\n\n'
          '• Expired — The auction ended without a winning bid. The item may be relisted at a revised price.\n\n'
          '• Cancelled — The auction was cancelled by our team, usually because the borrower settled the loan before bidding closed.',
      icon: Icons.gavel_rounded,
      iconColor: RealTimeColors.error,
    ),
  ];

  List<String> get _categories {
    final cats = ['All', ..._faqItems.map((e) => e.category).toSet()];
    return cats;
  }

  List<FaqItem> get filteredItems {
    return selectedCategory == 'All'
        ? _faqItems
        : _faqItems.where((e) => e.category == selectedCategory).toList();
  }

  Color _categoryColor(String category) {
    switch (category) {
      case 'Loan Products':
        return RealTimeColors.primaryGreen;
      case 'Loan Application':
        return RealTimeColors.success;
      case 'Collateral Process':
        return RealTimeColors.warning;
      case 'Loan Repayment':
        return RealTimeColors.darkGreen;
      case 'Asset Auctions':
        return RealTimeColors.error;
      case 'Security':
        return RealTimeColors.success;
      case 'Valuation Process':
        return RealTimeColors.primaryGreen;
      case 'Loan Amounts':
        return RealTimeColors.darkGreen;
      case 'Interest & Fees':
        return RealTimeColors.warning;
      case 'Default & Recovery':
        return RealTimeColors.error;
      case 'Mobile Features':
        return RealTimeColors.primaryGreen;
      case 'Contact & Support':
        return RealTimeColors.warning;
      case 'Status Guide':
        return const Color(0xFF0891B2);
      default:
        return RealTimeColors.primaryGreen;
    }
  }

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _categories.length, vsync: this);
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        setState(() {
          selectedCategory = _categories[_tabController.index];
          expandedIndex = null;
        });
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        backgroundColor: AppColors.backgroundColor,
        body: NestedScrollView(
          headerSliverBuilder: (context, innerBoxIsScrolled) => [
            _buildSliverAppBar(innerBoxIsScrolled),
          ],
          body: Column(
            children: [
              _buildCategoryTabs(),
              Expanded(child: _buildFaqList()),
            ],
          ),
        ),
      ),
    );
  }

  // ─── SLIVER APP BAR ──────────────────────────────────────────────────────────

  Widget _buildSliverAppBar(bool innerBoxIsScrolled) {
    return SliverAppBar(
      expandedHeight: 220,
      floating: false,
      pinned: true,
      forceElevated: innerBoxIsScrolled,
      backgroundColor: RealTimeColors.primaryGreen,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
        onPressed: () => Navigator.pop(context),
      ),
      actions: [
        IconButton(
          icon: Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              Icons.chat_bubble_outline_rounded,
              color: Colors.white,
              size: 20,
            ),
          ),
          onPressed: () {},
          tooltip: 'Live Chat',
        ),
        const SizedBox(width: 8),
      ],
      flexibleSpace: FlexibleSpaceBar(
        titlePadding: const EdgeInsets.only(left: 20, bottom: 16),
        title: Text(
          'Help & FAQ',
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontWeight: FontWeight.w700,
            fontSize: 18,
          ),
        ),
        background: _buildHeroBg(),
      ),
    );
  }

  Widget _buildHeroBg() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [RealTimeColors.primaryGreen, RealTimeColors.darkGreen],
          stops: [0.2, 1.0],
        ),
      ),
      child: Stack(
        children: [
          // Decorative blobs
          Positioned(
            right: -40,
            top: -20,
            child: Container(
              width: 180,
              height: 180,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.05),
              ),
            ),
          ),
          Positioned(
            left: -30,
            bottom: 10,
            child: Container(
              width: 130,
              height: 130,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.05),
              ),
            ),
          ),
          Positioned(
            right: 50,
            bottom: 40,
            child: Container(
              width: 70,
              height: 70,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.07),
              ),
            ),
          ),
          // Hero content
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 60),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Icon badge
                  Container(
                        width: 72,
                        height: 72,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(22),
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.3),
                            width: 1.5,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.1),
                              blurRadius: 16,
                              offset: const Offset(0, 6),
                            ),
                          ],
                        ),
                        child: Icon(
                          Icons.quiz_rounded,
                          size: 38,
                          color: Colors.white.withValues(alpha: 0.95),
                        ),
                      )
                      .animate()
                      .scale(duration: 600.ms, curve: Curves.elasticOut)
                      .fadeIn(duration: 400.ms),
                  const SizedBox(width: 18),
                  // Text column
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                              'How can we help?',
                              style: GoogleFonts.poppins(
                                color: Colors.white,
                                fontSize: 22,
                                fontWeight: FontWeight.w700,
                                height: 1.2,
                              ),
                            )
                            .animate(delay: 150.ms)
                            .slideX(
                              begin: 0.2,
                              duration: 500.ms,
                              curve: Curves.easeOut,
                            )
                            .fadeIn(duration: 400.ms),
                        const SizedBox(height: 6),
                        Text(
                          '${_faqItems.length} answers to your questions',
                          style: GoogleFonts.poppins(
                            color: Colors.white.withValues(alpha: 0.8),
                            fontSize: 13,
                            fontWeight: FontWeight.w400,
                          ),
                        ).animate(delay: 250.ms).fadeIn(duration: 400.ms),
                        const SizedBox(height: 10),
            
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ─── CATEGORY TABS ───────────────────────────────────────────────────────────

  Widget _buildCategoryTabs() {
    return Container(
      color: AppColors.backgroundColor,
      padding: const EdgeInsets.only(top: 8, bottom: 8),
      child: SizedBox(
        height: 40,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          itemCount: _categories.length,
          separatorBuilder: (_, _) => const SizedBox(width: 8),
          itemBuilder: (context, i) {
            final cat = _categories[i];
            final isSelected = selectedCategory == cat;
            final color = cat == 'All'
                ? RealTimeColors.primaryGreen
                : _categoryColor(cat);
            return GestureDetector(
              onTap: () {
                HapticFeedback.selectionClick();
                setState(() {
                  selectedCategory = cat;
                  expandedIndex = null;
                });
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 220),
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: isSelected ? color : AppColors.surfaceColor,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isSelected ? color : AppColors.borderColor,
                    width: 1.2,
                  ),
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: color.withValues(alpha: 0.25),
                            blurRadius: 8,
                            offset: const Offset(0, 3),
                          ),
                        ]
                      : [],
                ),
                child: Text(
                  cat,
                  style: GoogleFonts.poppins(
                    fontSize: 12.5,
                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                    color: isSelected ? Colors.white : AppColors.subtextColor,
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  // ─── FAQ LIST ────────────────────────────────────────────────────────────────

  Widget _buildFaqList() {
    final items = filteredItems;

    if (items.isEmpty) return _buildEmptyState();

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 32),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        final globalIndex = _faqItems.indexOf(item);
        return _buildFaqCard(item, globalIndex, index)
            .animate(delay: Duration(milliseconds: index * 50))
            .fadeIn(duration: 300.ms)
            .slideY(begin: 0.08);
      },
    );
  }

  Widget _buildFaqCard(FaqItem item, int globalIndex, int listIndex) {
    final isExpanded = expandedIndex == globalIndex;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppColors.surfaceColor,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isExpanded
              ? item.iconColor.withValues(alpha: 0.5)
              : AppColors.borderColor,
          width: isExpanded ? 1.5 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: isExpanded
                ? item.iconColor.withValues(alpha: 0.08)
                : Colors.black.withValues(alpha: 0.04),
            blurRadius: isExpanded ? 20 : 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(18),
        child: Column(
          children: [
            // Question row
            InkWell(
              onTap: () {
                HapticFeedback.lightImpact();
                setState(() {
                  expandedIndex = isExpanded ? null : globalIndex;
                });
              },
              borderRadius: BorderRadius.circular(18),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Icon
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: item.iconColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(13),
                        border: Border.all(
                          color: item.iconColor.withValues(alpha: 0.2),
                          width: 1,
                        ),
                      ),
                      child: Icon(item.icon, color: item.iconColor, size: 22),
                    ),
                    const SizedBox(width: 14),
                    // Question
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Category chip
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: item.iconColor.withValues(alpha: 0.08),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              item.category,
                              style: GoogleFonts.poppins(
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                                color: item.iconColor,
                              ),
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            item.question,
                            style: GoogleFonts.poppins(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textColor,
                              height: 1.35,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    // Expand toggle
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 250),
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: isExpanded
                            ? item.iconColor.withValues(alpha: 0.12)
                            : AppColors.backgroundColor,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: AnimatedRotation(
                        duration: const Duration(milliseconds: 250),
                        turns: isExpanded ? 0.5 : 0.0,
                        child: Icon(
                          Icons.keyboard_arrow_down_rounded,
                          color: isExpanded
                              ? item.iconColor
                              : AppColors.subtextColor,
                          size: 22,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Answer section
            AnimatedCrossFade(
              firstChild: const SizedBox.shrink(),
              secondChild: _buildAnswerSection(item),
              crossFadeState: isExpanded
                  ? CrossFadeState.showSecond
                  : CrossFadeState.showFirst,
              duration: const Duration(milliseconds: 280),
              sizeCurve: Curves.easeInOut,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAnswerSection(FaqItem item) {
    final isContact = item.category == 'Contact & Support';
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: item.iconColor.withValues(alpha: 0.04),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: item.iconColor.withValues(alpha: 0.12), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // "Answer" label
          Row(
            children: [
              Container(
                width: 4,
                height: 14,
                decoration: BoxDecoration(
                  color: item.iconColor,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                'Answer',
                style: GoogleFonts.poppins(
                  fontSize: 11.5,
                  fontWeight: FontWeight.w700,
                  color: item.iconColor,
                  letterSpacing: 0.3,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            item.answer,
            style: GoogleFonts.poppins(
              fontSize: 13.5,
              color: AppColors.subtextColor,
              height: 1.65,
            ),
          ),
          if (isContact) ...[
            const SizedBox(height: 16),
            _buildContactButtons(item.iconColor),
          ],
        ],
      ),
    );
  }

  Widget _buildContactButtons(Color color) {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton.icon(
            icon: Icon(
              Icons.chat_rounded,
              size: 16,
              color: RealTimeColors.primaryGreen,
            ),
            label: Text(
              'Live Chat',
              style: GoogleFonts.poppins(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: RealTimeColors.primaryGreen,
              ),
            ),
            onPressed: () {},
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 11),
              side: BorderSide(
                color: RealTimeColors.primaryGreen.withValues(alpha: 0.5),
                width: 1.2,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: ElevatedButton.icon(
            icon: const Icon(
              Icons.phone_rounded,
              size: 16,
              color: Colors.white,
            ),
            label: Text(
              'Call Now',
              style: GoogleFonts.poppins(
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
            onPressed: () {},
            style: ElevatedButton.styleFrom(
              backgroundColor: RealTimeColors.primaryGreen,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 11),
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: RealTimeColors.primaryGreen.withValues(alpha: 0.08),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: RealTimeColors.primaryGreen.withValues(alpha: 0.2),
                      width: 2,
                    ),
                  ),
                  child: Icon(
                    Icons.search_off_rounded,
                    size: 52,
                    color: RealTimeColors.primaryGreen.withValues(alpha: 0.5),
                  ),
                )
                .animate()
                .scale(duration: 600.ms, curve: Curves.elasticOut)
                .fadeIn(duration: 400.ms),
            const SizedBox(height: 5),
            Text(
                  'No results found',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textColor,
                  ),
                )
                .animate(delay: 200.ms)
                .slideY(begin: 0.3, duration: 400.ms)
                .fadeIn(duration: 300.ms),
            const SizedBox(height: 8),

            ElevatedButton.icon(
                  icon: const Icon(Icons.refresh_rounded, size: 18),
                  label: Text(
                    'Clear Filters',
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  onPressed: () {
                    setState(() {
                      selectedCategory = 'All';
                      expandedIndex = null;
                    });
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: RealTimeColors.primaryGreen,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 28,
                      vertical: 14,
                    ),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                )
                .animate(delay: 400.ms)
                .scale(duration: 400.ms, curve: Curves.easeOutBack)
                .fadeIn(duration: 300.ms),
          ],
        ),
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

  const FaqItem({
    required this.category,
    required this.question,
    required this.answer,
    required this.icon,
    this.iconColor = RealTimeColors.primaryGreen,
  });
}
