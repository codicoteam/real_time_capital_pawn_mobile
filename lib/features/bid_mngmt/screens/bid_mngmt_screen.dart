// bid_mngmt_screen.dart
// lib/features/user_bids/screens/user_bidding_history_screen.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:real_time_pawn/config/routers/router.dart';
import 'package:real_time_pawn/core/utils/pallete.dart';
import 'package:real_time_pawn/features/bid_mngmt/controllers/bid_mngmt_controller.dart';
import 'package:real_time_pawn/features/bid_mngmt/helpers/bid_mngmt_helper.dart';
import 'package:real_time_pawn/models/user_bid_models.dart';

class UserBiddingHistoryScreen extends StatefulWidget {
  const UserBiddingHistoryScreen({super.key});

  @override
  State<UserBiddingHistoryScreen> createState() =>
      _UserBiddingHistoryScreenState();
}

class _UserBiddingHistoryScreenState extends State<UserBiddingHistoryScreen> {
  final UserBidsController _controller = Get.put(UserBidsController());
  final ScrollController _scrollController = ScrollController();
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
    super.dispose();
  }

  void _loadInitialBids() async {
    await UserBidsHelper.loadUserBids(showLoader: true);
  }

  void _scrollListener() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      _loadMoreBids();
    }
  }

  Future<void> _loadMoreBids() async {
    if (_isLoadingMore ||
        _controller.currentPage.value >= _controller.pagination.value.pages) {
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
    await UserBidsHelper.loadUserBids(showLoader: false);
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.gavel_outlined, size: 64, color: RealTimeColors.grey400),
          const SizedBox(height: 16),
          Text(
            'No Bidding History',
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppColors.subtextColor,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'You haven\'t placed any bids yet',
            style: GoogleFonts.poppins(
              fontSize: 14,
              color: RealTimeColors.grey500,
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              // Navigate to auctions screen
              Get.offAllNamed(RoutesHelper.auctionsListScreen);
            },
            style: ElevatedButton.styleFrom(
              foregroundColor: Colors.white,
              backgroundColor: AppColors.primaryColor,
            ),
            child: const Text('Browse Auctions'),
          ),
        ],
      ),
    );
  }

  Widget _buildBidCard(UserBid bid) {
    final isWinning = UserBidsHelper.isWinningBid(bid);
    final dateFormat = DateFormat('MMM dd, yyyy');
    final timeFormat = DateFormat('h:mm a');

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          UserBidsHelper.navigateToAuctionDetails(
            auctionId: bid.auction.id,
            context: context,
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Auction Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      bid.auction.asset.title,
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
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
                      color: UserBidsHelper.getAuctionStatusColor(
                        bid.auction.status,
                      ),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      UserBidsHelper.getAuctionStatusText(bid.auction.status),
                      style: GoogleFonts.poppins(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 8),

              // Auction Number and Date
              Row(
                children: [
                  Text(
                    bid.auction.auctionNo,
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: AppColors.subtextColor,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '•',
                    style: GoogleFonts.poppins(color: AppColors.subtextColor),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    dateFormat.format(bid.placedAt),
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: AppColors.subtextColor,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              // Bid Details
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.backgroundColor,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.borderColor),
                ),
                child: Column(
                  children: [
                    // Bid Amount
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Your Bid',
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            color: AppColors.subtextColor,
                          ),
                        ),
                        Text(
                          UserBidsHelper.formatCurrency(
                            bid.amount,
                            bid.currency,
                          ),
                          style: GoogleFonts.poppins(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primaryColor,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 8),

                    // Winning Status
                    if (isWinning)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: RealTimeColors.success.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(
                            color: RealTimeColors.success.withOpacity(0.3),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.emoji_events_outlined,
                              size: 12,
                              color: RealTimeColors.success,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              'WINNING BID',
                              style: GoogleFonts.poppins(
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                                color: RealTimeColors.success,
                              ),
                            ),
                          ],
                        ),
                      ),

                    if (!isWinning && bid.auction.winningBidAmount != null)
                      Text(
                        'Winning bid: ${UserBidsHelper.formatCurrency(bid.auction.winningBidAmount!, bid.currency)}',
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          color: RealTimeColors.error,
                          fontStyle: FontStyle.italic,
                        ),
                      ),

                    const SizedBox(height: 8),

                    // Payment Status
                    Row(
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: UserBidsHelper.getPaymentStatusColor(
                              bid.paymentStatus,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Payment: ${UserBidsHelper.getPaymentStatusText(bid.paymentStatus)}',
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            color: AppColors.subtextColor,
                          ),
                        ),
                        if (bid.paidAmount > 0)
                          Expanded(
                            child: Text(
                              ' (Paid: ${UserBidsHelper.formatCurrency(bid.paidAmount, bid.currency)})',
                              textAlign: TextAlign.end,
                              style: GoogleFonts.poppins(
                                fontSize: 12,
                                color: AppColors.subtextColor,
                              ),
                            ),
                          ),
                      ],
                    ),

                    // Dispute Status (if any)
                    if (bid.dispute.status != BidDisputeStatus.none)
                      Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Row(
                          children: [
                            Container(
                              width: 8,
                              height: 8,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: UserBidsHelper.getDisputeStatusColor(
                                  bid.dispute.status,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'Dispute: ${UserBidsHelper.getDisputeStatusText(bid.dispute.status)}',
                                style: GoogleFonts.poppins(
                                  fontSize: 12,
                                  color: AppColors.subtextColor,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),

              const SizedBox(height: 12),

              // Action Buttons
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        UserBidsHelper.navigateToAuctionDetails(
                          auctionId: bid.auction.id,
                          context: context,
                        );
                      },
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.primaryColor,
                        side: BorderSide(color: AppColors.primaryColor),
                      ),
                      child: const Text('View Auction'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  if (bid.paymentStatus == BidPaymentStatus.unpaid &&
                      bid.auction.status == 'closed' &&
                      isWinning)
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          // TODO: Implement payment flow
                          Get.snackbar(
                            'Coming Soon',
                            'Payment feature will be available soon',
                            backgroundColor: AppColors.primaryColor,
                            colorText: Colors.white,
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          foregroundColor: Colors.white,
                          backgroundColor: AppColors.primaryColor,
                        ),
                        child: const Text('Pay Now'),
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSummaryCard() {
    final summary = UserBidsHelper.getBidSummary(_controller.userBids);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildSummaryItem(
                  label: 'Total Bids',
                  value: '${summary['total']}',
                  color: AppColors.primaryColor,
                ),
                _buildSummaryItem(
                  label: 'Auctions Won',
                  value: '${summary['won']}',
                  color: RealTimeColors.success,
                ),
                _buildSummaryItem(
                  label: 'Active',
                  value: '${summary['active']}',
                  color: RealTimeColors.warning,
                ),
                _buildSummaryItem(
                  label: 'Pending Payment',
                  value: '${summary['pendingPayment']}',
                  color: RealTimeColors.error,
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Total Bid Amount:',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textColor,
                  ),
                ),
                Text(
                  UserBidsHelper.formatCurrency(
                    _controller.totalBidAmount,
                    'USD',
                  ),
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primaryColor,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryItem({
    required String label,
    required String value,
    required Color color,
  }) {
    return Column(
      children: [
        Container(
          width: 40,
          height: 40,
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: AppBar(
        backgroundColor: AppColors.surfaceColor,
        elevation: 0,
        title: Text(
          'My Bidding History',
          style: GoogleFonts.poppins(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: AppColors.textColor,
          ),
        ),
        centerTitle: false,
        actions: [
          IconButton(
            onPressed: _refreshBids,
            icon: const Icon(Icons.refresh),
            color: AppColors.textColor,
          ),
        ],
      ),
      body: Obx(() {
        if (_controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!_controller.hasBids) {
          return _buildEmptyState();
        }

        return RefreshIndicator(
          onRefresh: _refreshBids,
          child: Column(
            children: [
              // Status Filter
              SizedBox(
                height: 48,
                child: ListView.builder(
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
                        selectedColor: AppColors.primaryColor.withOpacity(0.1),
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
                ),
              ),

              // Summary Card
              _buildSummaryCard(),

              // Bids List
              Expanded(
                child: ListView.builder(
                  controller: _scrollController,
                  itemCount:
                      _controller.userBids.length + (_isLoadingMore ? 1 : 0),
                  itemBuilder: (context, index) {
                    if (index >= _controller.userBids.length) {
                      return Padding(
                        padding: const EdgeInsets.all(16),
                        child: Center(
                          child: CircularProgressIndicator(
                            color: AppColors.primaryColor,
                          ),
                        ),
                      );
                    }

                    return _buildBidCard(_controller.userBids[index]);
                  },
                ),
              ),
            ],
          ),
        );
      }),
    );
  }
}
