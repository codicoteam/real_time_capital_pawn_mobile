import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:real_time_pawn/core/utils/pallete.dart';
import 'package:real_time_pawn/features/bid_mngmnt/controllers/bid_mngmt_controller.dart';
import 'package:real_time_pawn/features/bid_mngmnt/helpers/bid_mngmt_helper.dart';
import 'package:real_time_pawn/models/user_bid_models.dart';
import '../../../widgets/cards/bid_card.dart';

// Simple curved edges clipper (copied from TicketDetailScreen's dependency)
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

class MyBidsScreen extends StatefulWidget {
  const MyBidsScreen({super.key});

  @override
  State<MyBidsScreen> createState() => _MyBidsScreenState();
}

class _MyBidsScreenState extends State<MyBidsScreen>
    with TickerProviderStateMixin {
  final BidManagementController _controller = Get.put(
    BidManagementController(),
  );
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();
  bool _isLoadingMore = false;
  bool _isReversed = false; // true = oldest first, false = newest first
  bool _isRefreshing = false;

  late AnimationController _headerAnimationController;
  late AnimationController _contentAnimationController;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_scrollListener);
    _loadInitialBids();

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
    _headerAnimationController.dispose();
    _contentAnimationController.dispose();
    super.dispose();
  }

  void _loadInitialBids() async {
    await BidManagementHelper.loadUserBids(showLoader: true);
  }

  void _scrollListener() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      _loadMoreBids();
    }
  }

  Future<void> _loadMoreBids() async {
    if (_isLoadingMore || !_controller.hasMoreBids.value) return;
    setState(() => _isLoadingMore = true);
    await _controller.loadMoreBids();
    setState(() => _isLoadingMore = false);
  }

  Future<void> _refreshBids() async {
    setState(() => _isRefreshing = true);
    await BidManagementHelper.loadUserBids(showLoader: false);
    setState(() => _isRefreshing = false);
  }

  void _toggleReverse() {
    setState(() {
      _isReversed = !_isReversed;
    });
  }

  /// Returns the list of bids sorted by placedAt (newest first or oldest first)
  List<UserBid> _getSortedBids() {
    final bids = _controller.userBids.toList();
    bids.sort(
      (a, b) => _isReversed
          ? a.placedAt.compareTo(b.placedAt) // oldest first
          : b.placedAt.compareTo(a.placedAt), // newest first
    );
    return bids;
  }

  Widget _buildEmptyState() {
    return Center(
      child: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.gavel_outlined, size: 64, color: RealTimeColors.grey400),
            const SizedBox(height: 16),
            Text(
              'No Bids Yet',
              style: GoogleFonts.poppins(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: AppColors.subtextColor,
              ),
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Text(
                'You haven\'t placed any bids yet. Start bidding on auctions to see them here.',
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  color: RealTimeColors.grey500,
                ),
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => Get.back(),
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.white,
                backgroundColor: AppColors.primaryColor,
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 12,
                ),
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
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryCard() {
    final stats = _controller.getBidStatistics();
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 0, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderColor),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            spreadRadius: 0,
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Total Bid Amount',
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: AppColors.subtextColor,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      BidManagementHelper.formatCurrency(
                        _controller.totalBidAmount,
                      ),
                      style: GoogleFonts.poppins(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primaryColor,
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
                      'Paid Amount',
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: AppColors.subtextColor,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      BidManagementHelper.formatCurrency(
                        _controller.totalPaidAmount,
                      ),
                      style: GoogleFonts.poppins(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: RealTimeColors.success,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 80,
            child: GridView.count(
              crossAxisCount: 4,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                _buildStatItem(
                  value: stats['total']?.toString() ?? '0',
                  label: 'Total',
                  color: AppColors.primaryColor,
                ),
                _buildStatItem(
                  value: stats['active']?.toString() ?? '0',
                  label: 'Active',
                  color: RealTimeColors.warning,
                ),
                _buildStatItem(
                  value: stats['winning']?.toString() ?? '0',
                  label: 'Winning',
                  color: RealTimeColors.success,
                ),
                _buildStatItem(
                  value: stats['won']?.toString() ?? '0',
                  label: 'Won',
                  color: RealTimeColors.success,
                ),
              ],
            ),
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
            color: color.withValues(alpha: 0.1),
            shape: BoxShape.circle,
            border: Border.all(color: color.withValues(alpha: 0.3)),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      body: Stack(
        children: [
          // Main scrollable content
          RefreshIndicator(
            onRefresh: _refreshBids,
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
                                    AppColors.primaryColor.withValues(alpha: 0.7),
                                  ],
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: AppColors.primaryColor.withValues(alpha: 
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
                                          color: Colors.white.withValues(alpha: 0.2),
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                        ),
                                        child: const Icon(
                                          Icons.gavel_rounded,
                                          color: Colors.white,
                                          size: 24,
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Text(
                                          'My Bids',
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
                                hintText: 'Search bids...',
                                prefixIcon: const Icon(
                                  Icons.search_outlined,
                                  size: 20,
                                ),
                                suffixIcon: _searchController.text.isNotEmpty
                                    ? IconButton(
                                        onPressed: () {
                                          _searchController.clear();
                                          _controller.searchBids('');
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
                              onChanged: _controller.searchBids,
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

                      // Summary card (only if there are bids)
                      if (_controller.userBids.isNotEmpty)
                        _buildSummaryCard()
                            .animate(controller: _contentAnimationController)
                            .fadeIn()
                            .slideY(
                              begin: 0.2,
                              delay: 100.ms,
                              duration: 400.ms,
                              curve: Curves.easeOutQuad,
                            ),

                      const SizedBox(height: 8),

                      // Bids list or empty state
                      Obx(() {
                        if (_controller.isLoading.value &&
                            _controller.userBids.isEmpty) {
                          return const Center(
                            child: CircularProgressIndicator(),
                          );
                        }

                        final sortedBids = _getSortedBids();
                        final hasAnyBids = _controller.userBids.isNotEmpty;

                        if (sortedBids.isEmpty) {
                          if (!hasAnyBids) {
                            return SizedBox(
                              height: MediaQuery.of(context).size.height * 0.5,
                              child: _buildEmptyState(),
                            );
                          } else {
                            return Center(
                              child: Padding(
                                padding: const EdgeInsets.all(32),
                                child: Text(
                                  'No bids match your search.',
                                  style: GoogleFonts.poppins(
                                    color: AppColors.subtextColor,
                                  ),
                                ),
                              ),
                            );
                          }
                        }

                        return Column(
                          children: sortedBids
                              .map((bid) => BidCard(bid: bid))
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

          // Custom floating app bar with back, reverse toggle, refresh
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
                        color: Colors.white.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(30),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.3),
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
                    // Reverse order toggle
                    Container(
                      margin: const EdgeInsets.only(right: 8),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(30),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.3),
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
                          color: Colors.white.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(30),
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.3),
                            width: 1.5,
                          ),
                        ),
                        child: IconButton(
                          icon: const Icon(
                            Icons.refresh_rounded,
                            color: Colors.white,
                            size: 24,
                          ),
                          onPressed: _refreshBids,
                        ),
                      )
                    else
                      Container(
                        width: 46,
                        height: 46,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
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

  // Helper to build a subtle glass card for the search bar
  Widget _buildGlassCard({required Widget child}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppColors.primaryColor.withValues(alpha: 0.15),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryColor.withValues(alpha: 0.08),
            blurRadius: 16,
            offset: const Offset(0, 6),
            spreadRadius: 0,
          ),
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: child,
    );
  }
}
