import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:real_time_pawn/core/utils/pallete.dart';
import 'package:real_time_pawn/features/auctions_mngmt/controllers/auctions_mngmt_controller.dart';

class AuctionBidsScreen extends StatefulWidget {
  final String auctionId;
  final String auctionTitle;

  const AuctionBidsScreen({
    super.key,
    required this.auctionId,
    required this.auctionTitle,
  });

  @override
  State<AuctionBidsScreen> createState() => _AuctionBidsScreenState();
}

class _AuctionBidsScreenState extends State<AuctionBidsScreen> {
  final AuctionsController _auctionsController = Get.find<AuctionsController>();
  static const bool IS_DEVELOPMENT = true; // Change to false for production

  @override
  void initState() {
    super.initState();
    _loadBids();
  }

  Future<void> _loadBids() async {
    final success = await _auctionsController.getAuctionBidsRequest(
      auctionId: widget.auctionId,
    );

    if (!success) {
      Get.snackbar(
        'Error',
        _auctionsController.errorMessage.value,
        snackPosition: SnackPosition.TOP,
        backgroundColor: RealTimeColors.error,
        colorText: Colors.white,
      );
    }
  }

  Future<void> _refreshBids() async {
    await _loadBids();
  }

  String _formatTimeAgo(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays > 365) {
      final years = (difference.inDays / 365).floor();
      return '$years year${years > 1 ? 's' : ''} ago';
    } else if (difference.inDays > 30) {
      final months = (difference.inDays / 30).floor();
      return '$months month${months > 1 ? 's' : ''} ago';
    } else if (difference.inDays > 0) {
      return '${difference.inDays} day${difference.inDays > 1 ? 's' : ''} ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} hour${difference.inHours > 1 ? 's' : ''} ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} minute${difference.inMinutes > 1 ? 's' : ''} ago';
    } else {
      return 'Just now';
    }
  }

  // Mock Preview Widgets
  Widget _buildMockBid({
    required String name,
    required double amount,
    required String timeAgo,
    required bool isWinning,
  }) {
    return Container(
      margin: const EdgeInsets.all(8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                name,
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textColor,
                ),
              ),
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
                        'WINNING',
                        style: GoogleFonts.poppins(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: RealTimeColors.success,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            '\$${amount.toStringAsFixed(0)}',
            style: GoogleFonts.poppins(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppColors.primaryColor,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            timeAgo,
            style: GoogleFonts.poppins(
              fontSize: 12,
              color: AppColors.subtextColor,
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
      body: SafeArea(
        child: Column(
          children: [
            // Header
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
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Bidding History',
                          style: GoogleFonts.poppins(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textColor,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          widget.auctionTitle,
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            color: AppColors.subtextColor,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  Obx(() {
                    final bidCount = _auctionsController.auctionBids.length;
                    final displayCount = bidCount > 0
                        ? bidCount
                        : 3; // Show 3 for mock preview
                    return Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.primaryColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '$displayCount bids',
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: AppColors.primaryColor,
                        ),
                      ),
                    );
                  }),
                ],
              ),
            ),

            // Bids List
            Expanded(
              child: Obx(() {
                if (_auctionsController.isLoadingBids.value) {
                  return const Center(child: CircularProgressIndicator());
                }

                final bids = _auctionsController.auctionBids;

                if (bids.isEmpty) {
                  return RefreshIndicator(
                    onRefresh: _refreshBids,
                    child: SingleChildScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      child: SizedBox(
                        height: MediaQuery.of(context).size.height * 0.7,
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.gavel_outlined,
                                size: 64,
                                color: RealTimeColors.grey400,
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'No Bids Yet',
                                style: GoogleFonts.poppins(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.subtextColor,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Be the first to place a bid!',
                                style: GoogleFonts.poppins(
                                  fontSize: 14,
                                  color: RealTimeColors.grey500,
                                ),
                              ),
                              const SizedBox(height: 16),
                              ElevatedButton(
                                onPressed: _refreshBids,
                                style: ElevatedButton.styleFrom(
                                  foregroundColor: Colors.white,
                                  backgroundColor: AppColors.primaryColor,
                                ),
                                child: const Text('Refresh'),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                }

                return RefreshIndicator(
                  onRefresh: _refreshBids,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: bids.length,
                    itemBuilder: (context, index) {
                      final bid = bids[index];
                      final isWinning = bid.isWinning;
                      final isLast = index == bids.length - 1;

                      return Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        decoration: BoxDecoration(
                          color: AppColors.surfaceColor,
                          borderRadius: BorderRadius.circular(12),
                          border: isWinning
                              ? Border.all(
                                  color: RealTimeColors.success.withOpacity(
                                    0.3,
                                  ),
                                  width: 2,
                                )
                              : null,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              spreadRadius: 0,
                              blurRadius: 8,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Bid Header
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  // Bidder Info
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          bid.bidderName,
                                          style: GoogleFonts.poppins(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w600,
                                            color: AppColors.textColor,
                                          ),
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          _formatTimeAgo(bid.timestamp),
                                          style: GoogleFonts.poppins(
                                            fontSize: 12,
                                            color: AppColors.subtextColor,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),

                                  // Winning Badge
                                  if (isWinning)
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 4,
                                      ),
                                      decoration: BoxDecoration(
                                        color: RealTimeColors.success
                                            .withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(6),
                                        border: Border.all(
                                          color: RealTimeColors.success
                                              .withOpacity(0.3),
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
                                            'Winning',
                                            style: GoogleFonts.poppins(
                                              fontSize: 10,
                                              fontWeight: FontWeight.w600,
                                              color: RealTimeColors.success,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                ],
                              ),

                              const SizedBox(height: 12),

                              // Bid Amount
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Bid Amount',
                                    style: GoogleFonts.poppins(
                                      fontSize: 12,
                                      color: AppColors.subtextColor,
                                    ),
                                  ),
                                  Text(
                                    '\$${bid.amount.toStringAsFixed(0)}',
                                    style: GoogleFonts.poppins(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      color: isWinning
                                          ? RealTimeColors.success
                                          : AppColors.primaryColor,
                                    ),
                                  ),
                                ],
                              ),

                              const SizedBox(height: 8),

                              // Detailed Time
                              Row(
                                children: [
                                  Icon(
                                    Icons.access_time_outlined,
                                    size: 14,
                                    color: AppColors.subtextColor,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    DateFormat(
                                      'MMM dd, yyyy - hh:mm a',
                                    ).format(bid.timestamp),
                                    style: GoogleFonts.poppins(
                                      fontSize: 12,
                                      color: AppColors.subtextColor,
                                    ),
                                  ),
                                ],
                              ),

                              // Rank Indicator
                              if (!isLast)
                                Padding(
                                  padding: const EdgeInsets.only(top: 12),
                                  child: Row(
                                    children: [
                                      Container(
                                        width: 24,
                                        height: 24,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: AppColors.primaryColor,
                                        ),
                                        child: Center(
                                          child: Text(
                                            '${index + 1}',
                                            style: GoogleFonts.poppins(
                                              fontSize: 12,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.white,
                                            ),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        'Rank ${index + 1} of ${bids.length}',
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
                        ),
                      );
                    },
                  ),
                );
              }),
            ),

            // Summary Section (Only show if we have real bids, not mock preview)
            Obx(() {
              final bids = _auctionsController.auctionBids;
              if (bids.isEmpty || IS_DEVELOPMENT)
                return const SizedBox.shrink();

              final highestBid = bids.isNotEmpty ? bids.first : null;
              final totalBids = bids.length;

              return Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.surfaceColor,
                  border: Border(top: BorderSide(color: AppColors.borderColor)),
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
                              'Highest Bid',
                              style: GoogleFonts.poppins(
                                fontSize: 12,
                                color: AppColors.subtextColor,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '\$${highestBid?.amount.toStringAsFixed(0) ?? '0'}',
                              style: GoogleFonts.poppins(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: AppColors.primaryColor,
                              ),
                            ),
                          ],
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              'Total Bids',
                              style: GoogleFonts.poppins(
                                fontSize: 12,
                                color: AppColors.subtextColor,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '$totalBids',
                              style: GoogleFonts.poppins(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textColor,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Bidding started ${_formatTimeAgo(bids.last.timestamp)}',
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: AppColors.subtextColor,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}
