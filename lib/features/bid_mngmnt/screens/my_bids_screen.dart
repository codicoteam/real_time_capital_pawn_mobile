import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:real_time_pawn/core/utils/pallete.dart';
import 'package:real_time_pawn/features/bid_mngmnt/controllers/bid_mngmt_controller.dart';
import 'package:real_time_pawn/features/bid_mngmnt/helpers/bid_mngmt_helper.dart';
import 'package:real_time_pawn/models/user_bid_models.dart';

class MyBidsScreen extends StatefulWidget {
  const MyBidsScreen({super.key});

  @override
  State<MyBidsScreen> createState() => _MyBidsScreenState();
}

class _MyBidsScreenState extends State<MyBidsScreen> {
  final BidManagementController _controller = Get.put(
    BidManagementController(),
  );
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();
  bool _isLoadingMore = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_scrollListener);
    _loadInitialBids();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
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
    if (_isLoadingMore || !_controller.hasMoreBids.value) {
      return;
    }

    setState(() {
      _isLoadingMore = true;
    });

    await _controller.loadMoreBids();

    setState(() {
      _isLoadingMore = false;
    });
  }

  Future<void> _refreshBids() async {
    await BidManagementHelper.loadUserBids(showLoader: false);
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
              onPressed: () {
                Get.back(); // Go back to auctions
              },
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
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
        mainAxisSize: MainAxisSize.min,
        children: [
          // Total amount row
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
          // Stats grid - Fixed height to prevent overflow
          SizedBox(
            height: 80, // Fixed height for the grid
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

  Widget _buildBidCard(UserBid bid) {
    final dateFormat = DateFormat('MMM dd, yyyy');
    final timeFormat = DateFormat('h:mm a');

    // Get status strings
    final bidStatusText = BidManagementHelper.getBidStatusText(bid);
    final paymentStatus = bid.paymentStatus
        .toString()
        .split('.')
        .last
        .toLowerCase();
    final disputeStatus = bid.dispute.status
        .toString()
        .split('.')
        .last
        .toLowerCase();
    final auctionStatus = bid.auction.status.toLowerCase();

    // Check bid statuses
    final hasDispute = _controller.hasBidDispute(bid);
    final isPaid = _controller.isBidPaid(bid);
    // ignore: unused_local_variable
    final isWinning = _controller.isBidWinning(bid);
    final isWon = _controller.isBidWon(bid);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 2,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () {
          Get.toNamed('/bid-details/${bid.id}');
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Auction header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          bid.auction.asset.title,
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textColor,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          bid.auction.auctionNo,
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            color: AppColors.subtextColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                  BidStatusTextBadge(statusText: bidStatusText),
                ],
              ),

              const SizedBox(height: 12),

              // Bid amount and time
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Your Bid',
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            color: AppColors.subtextColor,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          BidManagementHelper.formatCurrency(
                            bid.amount,
                            bid.currency,
                          ),
                          style: GoogleFonts.poppins(
                            fontSize: 20,
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
                          'Placed',
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            color: AppColors.subtextColor,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          dateFormat.format(bid.placedAt),
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textColor,
                          ),
                        ),
                        Text(
                          timeFormat.format(bid.placedAt),
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            color: AppColors.subtextColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              // Status indicators
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  // Payment status
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: BidManagementHelper.getPaymentStatusColor(
                        paymentStatus,
                      ).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: BidManagementHelper.getPaymentStatusColor(
                          paymentStatus,
                        ).withOpacity(0.3),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 6,
                          height: 6,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: BidManagementHelper.getPaymentStatusColor(
                              paymentStatus,
                            ),
                          ),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          BidManagementHelper.getPaymentStatusText(
                            paymentStatus,
                          ),
                          style: GoogleFonts.poppins(
                            fontSize: 10,
                            color: AppColors.subtextColor,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Dispute status (if any)
                  if (hasDispute)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: BidManagementHelper.getDisputeStatusColor(
                          disputeStatus,
                        ).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: BidManagementHelper.getDisputeStatusColor(
                            disputeStatus,
                          ).withOpacity(0.3),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.warning_outlined,
                            size: 12,
                            color: BidManagementHelper.getDisputeStatusColor(
                              disputeStatus,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            BidManagementHelper.getDisputeStatusText(
                              disputeStatus,
                            ),
                            style: GoogleFonts.poppins(
                              fontSize: 10,
                              color: AppColors.subtextColor,
                            ),
                          ),
                        ],
                      ),
                    ),

                  // Auction status
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: _getAuctionStatusColor(
                        auctionStatus,
                      ).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: _getAuctionStatusColor(
                          auctionStatus,
                        ).withOpacity(0.3),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 6,
                          height: 6,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: _getAuctionStatusColor(auctionStatus),
                          ),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          auctionStatus.toUpperCase(),
                          style: GoogleFonts.poppins(
                            fontSize: 10,
                            color: AppColors.subtextColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              // Only show Pay Now button if needed, otherwise show nothing
              if (auctionStatus == 'closed' && isWon && !isPaid) ...[
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      // Navigate to select payment method
                      Get.toNamed(
                        '/select-payment-method',
                        arguments: {'bidId': bid.id, 'amount': bid.amount},
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.white,
                      backgroundColor: AppColors.primaryColor,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const Text('Pay Now'),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header - Fixed at top
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: AppColors.surfaceColor,
                border: Border(
                  bottom: BorderSide(color: AppColors.borderColor),
                ),
              ),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => Get.back(),
                    icon: const Icon(Icons.arrow_back),
                    color: AppColors.textColor,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'My Bids',
                    style: GoogleFonts.poppins(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textColor,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    onPressed: _refreshBids,
                    icon: const Icon(Icons.refresh_outlined),
                    color: AppColors.textColor,
                  ),
                ],
              ),
            ),

            // Everything in a single scrollable view
            Expanded(
              child: RefreshIndicator(
                onRefresh: _refreshBids,
                child: Obx(() {
                  if (_controller.isLoading.value) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  return ListView(
                    controller: _scrollController,
                    physics: const AlwaysScrollableScrollPhysics(),
                    children: [
                      // Search bar
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                        child: TextField(
                          controller: _searchController,
                          decoration: InputDecoration(
                            hintText: 'Search bids...',
                            prefixIcon: const Icon(Icons.search_outlined),
                            suffixIcon: _searchController.text.isNotEmpty
                                ? IconButton(
                                    onPressed: () {
                                      _searchController.clear();
                                      _controller.searchBids('');
                                    },
                                    icon: const Icon(Icons.close),
                                  )
                                : null,
                            filled: true,
                            fillColor: AppColors.surfaceColor,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none,
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 12,
                            ),
                          ),
                          onChanged: (value) {
                            _controller.searchBids(value);
                          },
                        ),
                      ),

                      // Status filter chips
                      SizedBox(
                        height: 48,
                        child: Obx(() {
                          return ListView.builder(
                            scrollDirection: Axis.horizontal,
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            itemCount: _controller.statusFilters.length,
                            itemBuilder: (context, index) {
                              final status = _controller.statusFilters[index];
                              final isSelected =
                                  _controller.selectedStatus.value == status;

                              return Padding(
                                padding: const EdgeInsets.only(right: 8),
                                child: FilterChip(
                                  label: Text(status),
                                  selected: isSelected,
                                  onSelected: (selected) {
                                    _controller.filterBidsByStatus(
                                      selected ? status : 'All',
                                    );
                                  },
                                  backgroundColor: AppColors.surfaceColor,
                                  selectedColor: AppColors.primaryColor
                                      .withOpacity(0.1),
                                  labelStyle: GoogleFonts.poppins(
                                    color: isSelected
                                        ? AppColors.primaryColor
                                        : AppColors.subtextColor,
                                    fontWeight: isSelected
                                        ? FontWeight.w600
                                        : FontWeight.normal,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(20),
                                    side: BorderSide(
                                      color: isSelected
                                          ? AppColors.primaryColor
                                          : AppColors.borderColor,
                                    ),
                                  ),
                                ),
                              );
                            },
                          );
                        }),
                      ),

                      // Summary card (only if there are bids)
                      if (_controller.userBids.isNotEmpty) _buildSummaryCard(),

                      // Bids list or empty state
                      if (_controller.userBids.isEmpty)
                        SizedBox(
                          height: MediaQuery.of(context).size.height * 0.6,
                          child: _buildEmptyState(),
                        )
                      else
                        ..._controller.userBids
                            .map((bid) => _buildBidCard(bid))
                            .toList(),

                      // Load more indicator
                      if (_isLoadingMore)
                        Padding(
                          padding: const EdgeInsets.all(16),
                          child: Center(
                            child: CircularProgressIndicator(
                              color: AppColors.primaryColor,
                            ),
                          ),
                        ),

                      // Add some bottom padding
                      const SizedBox(height: 20),
                    ],
                  );
                }),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Helper to get auction status color from string
  Color _getAuctionStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'live':
        return RealTimeColors.success;
      case 'closed':
        return RealTimeColors.error;
      case 'upcoming':
        return RealTimeColors.warning;
      case 'draft':
        return RealTimeColors.grey500;
      default:
        return RealTimeColors.grey400;
    }
  }
}

// Simple badge widget for bid status
class BidStatusTextBadge extends StatelessWidget {
  final String statusText;
  final double fontSize;

  const BidStatusTextBadge({
    super.key,
    required this.statusText,
    this.fontSize = 12,
  });

  @override
  Widget build(BuildContext context) {
    final statusColor = BidManagementHelper.getBidStatusColorFromText(
      statusText,
    );

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: statusColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        statusText,
        style: GoogleFonts.poppins(
          fontSize: fontSize,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
    );
  }
}
