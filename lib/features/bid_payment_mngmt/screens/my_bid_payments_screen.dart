import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:real_time_pawn/core/utils/pallete.dart';
import 'package:real_time_pawn/features/bid_payment_mngmt/controllers/bid_payment_mngmt_controller.dart';
import 'package:real_time_pawn/features/bid_payment_mngmt/helpers/bid_payment_mngmt_helper.dart';
import 'package:real_time_pawn/models/bid_payment_model.dart';
import '../../../widgets/cards/bid_payment_card.dart' show PaymentCard;

// Curved edges clipper (copied from MyBidsScreen)
class _CurvedEdgeClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    var path = Path();
    path.lineTo(0, size.height - 30);
    var firstControlPoint = Offset(size.width / 4, size.height);
    var firstEndPoint = Offset(size.width / 2, size.height);
    path.quadraticBezierTo(
      firstControlPoint.dx,
      firstControlPoint.dy,
      firstEndPoint.dx,
      firstEndPoint.dy,
    );
    var secondControlPoint = Offset(size.width * 3 / 4, size.height - 30);
    var secondEndPoint = Offset(size.width, size.height - 30);
    path.quadraticBezierTo(
      secondControlPoint.dx,
      secondControlPoint.dy,
      secondEndPoint.dx,
      secondEndPoint.dy,
    );
    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}

class MyBidPaymentsScreen extends StatefulWidget {
  const MyBidPaymentsScreen({super.key});

  @override
  State<MyBidPaymentsScreen> createState() => _MyBidPaymentsScreenState();
}

class _MyBidPaymentsScreenState extends State<MyBidPaymentsScreen>
    with TickerProviderStateMixin {
  final BidPaymentController _controller = Get.put(BidPaymentController());
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();

  // List of status filters
  final List<String> statusFilters = [
    'All',
    'Successful',
    'Pending',
    'Failed',
    'Refunded',
  ];

  // Track active status filter
  String? _activeStatusFilter;

  bool _isLoadingMore = false;
  bool _isRefreshing = false;
  bool _isReversed = false; // true = oldest first, false = newest first

  late AnimationController _headerAnimationController;
  late AnimationController _contentAnimationController;

  Timer? _searchDebounceTimer;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_scrollListener);
    _loadInitialPayments();

    _headerAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
    _contentAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    _headerAnimationController.forward();
    _contentAnimationController.forward();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    _searchDebounceTimer?.cancel();
    _headerAnimationController.dispose();
    _contentAnimationController.dispose();
    super.dispose();
  }

  void _loadInitialPayments() async {
    await BidPaymentHelper.loadPayerPayments(showLoader: true);
  }

  void _scrollListener() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      _loadMorePayments();
    }
  }

  Future<void> _loadMorePayments() async {
    if (_isLoadingMore || !_controller.hasMorePayments.value) return;
    setState(() => _isLoadingMore = true);
    await _controller.loadMorePayments();
    setState(() => _isLoadingMore = false);
  }

  void _handleSearch(String query) {
    _searchDebounceTimer?.cancel();
    _searchDebounceTimer = Timer(const Duration(milliseconds: 500), () {
      if (query.isEmpty) {
        _clearSearch();
      } else if (query.length >= 2) {
        if (_controller.bidPayments.isEmpty) {
          BidPaymentHelper.showError(
            'No payments to search. You have no payments yet.',
          );
          return;
        }
        final results = _searchPaymentsLocallyImpl(query);
        if (results.isNotEmpty) {
          _controller.bidPayments.value = results;
          BidPaymentHelper.showSuccess('Found ${results.length} payments');
        } else {
          BidPaymentHelper.showError('No payments found matching "$query"');
        }
      } else {
        BidPaymentHelper.showError('Search requires at least 2 characters');
      }
    });
  }

  List<BidPayment> _searchPaymentsLocallyImpl(String query) {
    if (query.isEmpty || query.length < 2) return _controller.bidPayments;
    final searchLower = query.toLowerCase();
    return _controller.bidPayments.where((payment) {
      return payment.auction.asset.title.toLowerCase().contains(searchLower) ||
          payment.auction.auctionNo.toLowerCase().contains(searchLower) ||
          payment.method.toLowerCase().contains(searchLower) ||
          payment.provider.toLowerCase().contains(searchLower) ||
          payment.statusText.toLowerCase().contains(searchLower) ||
          (payment.receiptNo?.toLowerCase().contains(searchLower) ?? false) ||
          (payment.payerPhone?.toLowerCase().contains(searchLower) ?? false);
    }).toList();
  }

  List<BidPayment> _filterPaymentsByStatus(String statusText) {
    if (statusText == 'All') return _controller.bidPayments;
    PaymentStatus status;
    switch (statusText.toLowerCase()) {
      case 'successful':
        status = PaymentStatus.success;
        break;
      case 'pending':
        status = PaymentStatus.pending;
        break;
      case 'failed':
        status = PaymentStatus.failed;
        break;
      case 'refunded':
        status = PaymentStatus.refunded;
        break;
      default:
        return _controller.bidPayments;
    }
    return _controller.bidPayments
        .where((payment) => payment.status == status)
        .toList();
  }

  void _clearSearch() {
    setState(() => _activeStatusFilter = null);
    _controller.clearSearch();
    _refreshPayments();
  }

  Future<void> _refreshPayments() async {
    setState(() => _isRefreshing = true);
    await BidPaymentHelper.loadPayerPayments(showLoader: false);
    setState(() {
      _isRefreshing = false;
      _activeStatusFilter = null;
    });
  }

  void _toggleReverse() {
    setState(() {
      _isReversed = !_isReversed;
    });
  }

  List<BidPayment> _getSortedPayments() {
    final payments = _controller.bidPayments.toList();
    payments.sort((a, b) {
      final aDate = a.paidAt ?? a.createdAt;
      final bDate = b.paidAt ?? b.createdAt;
      return _isReversed ? aDate.compareTo(bDate) : bDate.compareTo(aDate);
    });
    return payments;
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.payments_outlined,
            size: 64,
            color: RealTimeColors.grey400,
          ),
          const SizedBox(height: 16),
          Text(
            'No Payments Yet',
            style: GoogleFonts.poppins(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: AppColors.subtextColor,
            ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Column(
              children: [
                Text(
                  'You haven\'t made any bid payments yet.',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: RealTimeColors.grey500,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Payments will appear here after you:',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: RealTimeColors.grey500,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.check_circle,
                      size: 12,
                      color: RealTimeColors.success,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Win an auction',
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: RealTimeColors.grey500,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.check_circle,
                      size: 12,
                      color: RealTimeColors.success,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Make a payment for your won bid',
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: RealTimeColors.grey500,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () => Get.offAllNamed('/auctions'),
            style: ElevatedButton.styleFrom(
              foregroundColor: Colors.white,
              backgroundColor: AppColors.primaryColor,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text(
              'Browse Auctions',
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(height: 12),
          OutlinedButton(
            onPressed: () => Get.toNamed('/my-bids'),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.primaryColor,
              side: BorderSide(color: AppColors.primaryColor),
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text(
              'View My Bids',
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCard() {
    final stats = _controller.getPaymentStatistics();
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 0, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderColor),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            spreadRadius: 0,
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Total Paid',
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: AppColors.subtextColor,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    BidPaymentHelper.formatCurrency(
                      _controller.totalPaidAmount,
                    ),
                    style: GoogleFonts.poppins(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: RealTimeColors.success,
                    ),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    'Pending',
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: AppColors.subtextColor,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    BidPaymentHelper.formatCurrency(
                      _controller.pendingPaymentAmount,
                    ),
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: RealTimeColors.warning,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          GridView.count(
            crossAxisCount: 4,
            crossAxisSpacing: 8,
            mainAxisSpacing: 8,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            children: [
              _buildStatItem(
                value: stats['total']?.toString() ?? '0',
                label: 'Total',
                color: AppColors.primaryColor,
              ),
              _buildStatItem(
                value: stats['successful']?.toString() ?? '0',
                label: 'Paid',
                color: RealTimeColors.success,
              ),
              _buildStatItem(
                value: stats['pending']?.toString() ?? '0',
                label: 'Pending',
                color: RealTimeColors.warning,
              ),
              _buildStatItem(
                value: stats['failed']?.toString() ?? '0',
                label: 'Failed',
                color: RealTimeColors.error,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem({
    required String value,
    required String label,
    required Color color,
  }) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            shape: BoxShape.circle,
            border: Border.all(color: color.withOpacity(0.3)),
          ),
          child: Center(
            child: Text(
              value,
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 10,
            color: AppColors.subtextColor,
          ),
        ),
      ],
    );
  }

  // Helper for glass card effect
  Widget _buildGlassCard({required Widget child}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppColors.primaryColor.withOpacity(0.15),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryColor.withOpacity(0.08),
            blurRadius: 16,
            offset: const Offset(0, 6),
            spreadRadius: 0,
          ),
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: child,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      body: Stack(
        children: [
          // Main scrollable content
          RefreshIndicator(
            onRefresh: _refreshPayments,
            child: CustomScrollView(
              controller: _scrollController,
              physics: const AlwaysScrollableScrollPhysics(),
              slivers: [
                // Animated curved header
                SliverToBoxAdapter(
                  child: AnimatedBuilder(
                    animation: _headerAnimationController,
                    builder: (context, child) {
                      return Transform.translate(
                        offset: Offset(
                          0,
                          -20 * (1 - _headerAnimationController.value),
                        ),
                        child: Opacity(
                          opacity: _headerAnimationController.value,
                          child: ClipPath(
                            clipper: _CurvedEdgeClipper(),
                            child: Container(
                              height: 200,
                              padding: const EdgeInsets.fromLTRB(
                                24,
                                50,
                                24,
                                24,
                              ),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: [
                                    AppColors.primaryColor,
                                    AppColors.primaryColor.withOpacity(0.7),
                                  ],
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: AppColors.primaryColor.withOpacity(
                                      0.3,
                                    ),
                                    blurRadius: 20,
                                    offset: const Offset(0, 10),
                                  ),
                                ],
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.all(8),
                                        decoration: BoxDecoration(
                                          color: Colors.white.withOpacity(0.2),
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                        ),
                                        child: const Icon(
                                          Icons.payments_outlined,
                                          color: Colors.white,
                                          size: 24,
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Text(
                                          'My Bid Payments',
                                          style: GoogleFonts.poppins(
                                            color: Colors.white,
                                            fontSize: 28,
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),

                // Content section
                SliverPadding(
                  padding: const EdgeInsets.all(20),
                  sliver: SliverList(
                    delegate: SliverChildListDelegate([
                      // Search bar
                      _buildGlassCard(
                            child: TextField(
                              controller: _searchController,
                              decoration: InputDecoration(
                                hintText: 'Search payments...',
                                prefixIcon: const Icon(
                                  Icons.search_outlined,
                                  size: 20,
                                ),
                                suffixIcon: _searchController.text.isNotEmpty
                                    ? IconButton(
                                        onPressed: () {
                                          _searchController.clear();
                                          _clearSearch();
                                        },
                                        icon: const Icon(Icons.close, size: 18),
                                      )
                                    : null,
                                border: InputBorder.none,
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 12,
                                ),
                              ),
                              onChanged: _handleSearch,
                            ),
                          )
                          .animate(controller: _contentAnimationController)
                          .fadeIn()
                          .slideY(
                            begin: 0.2,
                            duration: 400.ms,
                            curve: Curves.easeOutQuad,
                          ),

                      const SizedBox(height: 12),

                      // Status filter chips
                      SizedBox(
                            height: 48,
                            child: ListView.builder(
                              scrollDirection: Axis.horizontal,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 0,
                              ),
                              itemCount: statusFilters.length,
                              itemBuilder: (context, index) {
                                final status = statusFilters[index];
                                return Padding(
                                  padding: const EdgeInsets.only(right: 8),
                                  child: FilterChip(
                                    label: Text(status),
                                    selected: _activeStatusFilter == status,
                                    onSelected: (selected) {
                                      setState(() {
                                        if (selected) {
                                          _activeStatusFilter = status;
                                        } else {
                                          _activeStatusFilter = null;
                                        }
                                      });

                                      if (selected) {
                                        if (status == 'All') {
                                          _refreshPayments();
                                        } else {
                                          if (_controller.bidPayments.isEmpty) {
                                            BidPaymentHelper.showError(
                                              'No payments to filter. You have no payments yet.',
                                            );
                                            setState(
                                              () => _activeStatusFilter = null,
                                            );
                                            return;
                                          }
                                          final filtered =
                                              _filterPaymentsByStatus(status);
                                          if (filtered.isNotEmpty) {
                                            _controller.bidPayments.value =
                                                filtered;
                                            BidPaymentHelper.showSuccess(
                                              'Found ${filtered.length} ${status.toLowerCase()} payments',
                                            );
                                          } else {
                                            BidPaymentHelper.showError(
                                              'No ${status.toLowerCase()} payments found',
                                            );
                                          }
                                        }
                                      } else {
                                        _refreshPayments();
                                      }
                                    },
                                    backgroundColor: AppColors.surfaceColor,
                                    selectedColor: AppColors.primaryColor
                                        .withOpacity(0.1),
                                    labelStyle: GoogleFonts.poppins(
                                      color: _activeStatusFilter == status
                                          ? AppColors.primaryColor
                                          : AppColors.subtextColor,
                                      fontWeight: _activeStatusFilter == status
                                          ? FontWeight.w600
                                          : FontWeight.normal,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(20),
                                      side: BorderSide(
                                        color: _activeStatusFilter == status
                                            ? AppColors.primaryColor
                                            : AppColors.borderColor,
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                          )
                          .animate(controller: _contentAnimationController)
                          .fadeIn()
                          .slideY(
                            begin: 0.2,
                            delay: 50.ms,
                            duration: 400.ms,
                            curve: Curves.easeOutQuad,
                          ),

                      const SizedBox(height: 8),

                      // Summary card (only if there are payments)
                      Obx(() {
                        if (_controller.bidPayments.isEmpty)
                          return const SizedBox.shrink();
                        return _buildSummaryCard()
                            .animate(controller: _contentAnimationController)
                            .fadeIn()
                            .slideY(
                              begin: 0.2,
                              delay: 100.ms,
                              duration: 400.ms,
                              curve: Curves.easeOutQuad,
                            );
                      }),

                      const SizedBox(height: 8),

                      // Payments list or empty state
                      Obx(() {
                        if (_controller.isLoading.value &&
                            _controller.bidPayments.isEmpty) {
                          return const Center(
                            child: CircularProgressIndicator(),
                          );
                        }

                        final sortedPayments = _getSortedPayments();
                        final hasAnyPayments =
                            _controller.bidPayments.isNotEmpty;

                        if (sortedPayments.isEmpty) {
                          if (!hasAnyPayments) {
                            return SizedBox(
                              height: MediaQuery.of(context).size.height * 0.4,
                              child: _buildEmptyState(),
                            );
                          } else {
                            return Center(
                              child: Padding(
                                padding: const EdgeInsets.all(32),
                                child: Text(
                                  'No payments match your search.',
                                  style: GoogleFonts.poppins(
                                    color: AppColors.subtextColor,
                                  ),
                                ),
                              ),
                            );
                          }
                        }

                        return Column(
                          children: sortedPayments
                              .map((payment) => PaymentCard(payment: payment))
                              .toList(),
                        );
                      }),

                      // Load more indicator
                      if (_isLoadingMore)
                        const Padding(
                          padding: EdgeInsets.all(16),
                          child: Center(child: CircularProgressIndicator()),
                        ),
                      const SizedBox(height: 20),
                    ]),
                  ),
                ),
              ],
            ),
          ),

          // Custom floating app bar with back, sort toggle, refresh
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                child: Row(
                  children: [
                    // Back button
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(30),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.3),
                          width: 1.5,
                        ),
                      ),
                      child: IconButton(
                        icon: const Icon(
                          Icons.arrow_back_ios_new_rounded,
                          color: Colors.white,
                          size: 20,
                        ),
                        onPressed: () => Get.back(),
                      ),
                    ),
                    const Spacer(),
                    // Sort toggle (newest/oldest)
                    Container(
                      margin: const EdgeInsets.only(right: 8),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(30),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.3),
                          width: 1.5,
                        ),
                      ),
                      child: IconButton(
                        onPressed: _toggleReverse,
                        icon: Icon(
                          _isReversed
                              ? Icons.arrow_upward
                              : Icons.arrow_downward,
                          color: Colors.white,
                          size: 22,
                        ),
                        tooltip: _isReversed ? 'Oldest first' : 'Newest first',
                      ),
                    ),
                    // Refresh button
                    if (!_isRefreshing)
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(30),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.3),
                            width: 1.5,
                          ),
                        ),
                        child: IconButton(
                          icon: const Icon(
                            Icons.refresh_rounded,
                            color: Colors.white,
                            size: 24,
                          ),
                          onPressed: _refreshPayments,
                        ),
                      )
                    else
                      Container(
                        width: 46,
                        height: 46,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(30),
                        ),
                        child: const Center(
                          child: SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
