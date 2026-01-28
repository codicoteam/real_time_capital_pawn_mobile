import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:real_time_pawn/core/utils/pallete.dart';
import 'package:real_time_pawn/features/auctions_mngmt/helpers/auctions_mngmt_helper.dart';
import 'package:real_time_pawn/features/bid_mngmnt/controllers/bid_mngmt_controller.dart';
import 'package:real_time_pawn/features/bid_mngmnt/helpers/bid_mngmt_helper.dart';
import 'package:real_time_pawn/models/auction_models.dart';
import 'package:real_time_pawn/models/user_bid_models.dart';
import 'package:real_time_pawn/widgets/bid_status_badge.dart';

class BidDetailsScreen extends StatefulWidget {
  final String bidId;

  const BidDetailsScreen({super.key, required this.bidId});

  @override
  State<BidDetailsScreen> createState() => _BidDetailsScreenState();
}

class _BidDetailsScreenState extends State<BidDetailsScreen> {
  // Change this line:
  final BidManagementController _controller = Get.put(
    BidManagementController(),
  );
  final TextEditingController _disputeReasonController =
      TextEditingController();
  bool _showDisputeForm = false;

  @override
  void initState() {
    super.initState();
    _loadBidDetails();
  }

  Future<void> _loadBidDetails() async {
    await BidManagementHelper.loadBidDetails(bidId: widget.bidId);
  }

  Future<void> _raiseDispute() async {
    if (_disputeReasonController.text.isEmpty) {
      Get.snackbar(
        'Error',
        'Please enter a reason for the dispute',
        backgroundColor: AppColors.errorColor,
        colorText: Colors.white,
      );
      return;
    }

    final success = await _controller.raiseDisputeRequest(
      bidId: widget.bidId,
      reason: _disputeReasonController.text,
    );

    if (success) {
      setState(() {
        _showDisputeForm = false;
        _disputeReasonController.clear();
      });
      BidManagementHelper.showSuccess('Dispute raised successfully');
    } else {
      BidManagementHelper.showError(_controller.errorMessage.value);
    }
  }

  Widget _buildDisputeSection(UserBid bid) {
    // Check dispute status
    final hasDispute = bid.dispute.status != BidDisputeStatus.none;
    final disputeStatus = bid.dispute.status
        .toString()
        .split('.')
        .last
        .toLowerCase();

    if (hasDispute) {
      return Container(
        padding: const EdgeInsets.all(16),
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: BidManagementHelper.getDisputeStatusColor(
            disputeStatus,
          ).withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: BidManagementHelper.getDisputeStatusColor(
              disputeStatus,
            ).withOpacity(0.3),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.warning_outlined,
                  color: BidManagementHelper.getDisputeStatusColor(
                    disputeStatus,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  'Dispute: ${BidManagementHelper.getDisputeStatusText(disputeStatus)}',
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textColor,
                  ),
                ),
              ],
            ),
            if (bid.dispute.reason != null &&
                bid.dispute.reason!.isNotEmpty) ...[
              const SizedBox(height: 12),
              Text(
                'Reason: ${bid.dispute.reason!}',
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  color: AppColors.subtextColor,
                ),
              ),
            ],
          ],
        ),
      );
    }

    // Check if can raise dispute
    final auctionStatus = bid.auction.status.toLowerCase();
    final canRaiseDispute = auctionStatus == 'closed' && !hasDispute;

    if (!canRaiseDispute) {
      return const SizedBox.shrink();
    }

    if (_showDisputeForm) {
      return Container(
        padding: const EdgeInsets.all(16),
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: AppColors.surfaceColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.borderColor),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Raise a Dispute',
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors.textColor,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Please explain why you are disputing this bid:',
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: AppColors.subtextColor,
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _disputeReasonController,
              maxLines: 4,
              decoration: InputDecoration(
                hintText: 'Enter reason...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      setState(() {
                        _showDisputeForm = false;
                        _disputeReasonController.clear();
                      });
                    },
                    child: const Text('Cancel'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _raiseDispute,
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.white,
                      backgroundColor: RealTimeColors.warning,
                    ),
                    child: const Text('Submit Dispute'),
                  ),
                ),
              ],
            ),
          ],
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: RealTimeColors.warning.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: RealTimeColors.warning.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.info_outlined, color: RealTimeColors.warning),
              const SizedBox(width: 8),
              Text(
                'Have an issue with this bid?',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'If you believe there was an error with this bid or the auction process, you can raise a dispute.',
            style: GoogleFonts.poppins(
              fontSize: 14,
              color: AppColors.subtextColor,
            ),
          ),
          const SizedBox(height: 12),
          ElevatedButton(
            onPressed: () {
              setState(() {
                _showDisputeForm = true;
              });
            },
            style: ElevatedButton.styleFrom(
              foregroundColor: Colors.white,
              backgroundColor: RealTimeColors.warning,
            ),
            child: const Text('Raise a Dispute'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final bid = _controller.selectedBid.value;
      if (_controller.isLoadingDetails.value || bid == null) {
        return Scaffold(
          backgroundColor: AppColors.backgroundColor,
          body: Center(
            child: CircularProgressIndicator(color: AppColors.primaryColor),
          ),
        );
      }

      final dateFormat = DateFormat('MMM dd, yyyy');
      final timeFormat = DateFormat('h:mm a');

      // Check if bid is winning
      // ignore: unused_local_variable
      final isWinning = _controller.isBidWinning(bid);
      final isWon = _controller.isBidWon(bid);
      final isPaid = _controller.isBidPaid(bid);
      final paymentStatus = bid.paymentStatus
          .toString()
          .split('.')
          .last
          .toLowerCase();

      return Scaffold(
        backgroundColor: AppColors.backgroundColor,
        body: SafeArea(
          child: Column(
            children: [
              // App bar
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
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
                      'Bid Details',
                      style: GoogleFonts.poppins(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textColor,
                      ),
                    ),
                    const Spacer(),
                    BidStatusBadge(bid: bid),
                  ],
                ),
              ),

              Expanded(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Auction info card
                      Container(
                        margin: const EdgeInsets.all(16),
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
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              bid.auction.asset.title,
                              style: GoogleFonts.poppins(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textColor,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              bid.auction.auctionNo,
                              style: GoogleFonts.poppins(
                                fontSize: 14,
                                color: AppColors.subtextColor,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 6,
                                  ),
                                  decoration: BoxDecoration(
                                    color: AuctionsHelper.getStatusColor(
                                      _getAuctionStatusFromString(
                                        bid.auction.status,
                                      ),
                                    ),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Text(
                                    bid.auction.status.toUpperCase(),
                                    style: GoogleFonts.poppins(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 6,
                                  ),
                                  decoration: BoxDecoration(
                                    color: AppColors.primaryColor.withOpacity(
                                      0.1,
                                    ),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Text(
                                    bid.auction.auctionType.toUpperCase(),
                                    style: GoogleFonts.poppins(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.primaryColor,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),

                      // Bid details card
                      Container(
                        margin: const EdgeInsets.symmetric(horizontal: 16),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppColors.surfaceColor,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: AppColors.borderColor),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Bid Information',
                              style: GoogleFonts.poppins(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textColor,
                              ),
                            ),
                            const SizedBox(height: 16),

                            // Bid amount
                            _buildDetailRow(
                              label: 'Bid Amount',
                              value: BidManagementHelper.formatCurrency(
                                bid.amount,
                                bid.currency,
                              ),
                              valueStyle: GoogleFonts.poppins(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: AppColors.primaryColor,
                              ),
                            ),
                            const Divider(height: 24),

                            // Bid time
                            _buildDetailRow(
                              label: 'Bid Placed',
                              value:
                                  '${dateFormat.format(bid.placedAt)} at ${timeFormat.format(bid.placedAt)}',
                            ),
                            const Divider(height: 24),

                            // Current highest bid
                            _buildDetailRow(
                              label: 'Current Highest Bid',
                              value: BidManagementHelper.formatCurrency(
                                bid.auction.winningBidAmount ??
                                    bid.auction.startingBidAmount,
                                bid.currency,
                              ),
                            ),
                            const Divider(height: 24),

                            // Starting bid
                            _buildDetailRow(
                              label: 'Starting Bid',
                              value: BidManagementHelper.formatCurrency(
                                bid.auction.startingBidAmount,
                                bid.currency,
                              ),
                            ),
                            if (bid.auction.reservePrice != null) ...[
                              const Divider(height: 24),
                              _buildDetailRow(
                                label: 'Reserve Price',
                                value: BidManagementHelper.formatCurrency(
                                  bid.auction.reservePrice!,
                                  bid.currency,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),

                      // Payment details card
                      Container(
                        margin: const EdgeInsets.all(16),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppColors.surfaceColor,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: AppColors.borderColor),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Payment Information',
                              style: GoogleFonts.poppins(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textColor,
                              ),
                            ),
                            const SizedBox(height: 16),

                            _buildDetailRow(
                              label: 'Payment Status',
                              value: BidManagementHelper.getPaymentStatusText(
                                paymentStatus,
                              ),
                              valueColor:
                                  BidManagementHelper.getPaymentStatusColor(
                                    paymentStatus,
                                  ),
                            ),
                            const Divider(height: 24),

                            _buildDetailRow(
                              label: 'Amount Paid',
                              value: BidManagementHelper.formatCurrency(
                                bid.paidAmount,
                                bid.currency,
                              ),
                              valueColor: bid.paidAmount > 0
                                  ? RealTimeColors.success
                                  : AppColors.textColor,
                            ),
                            const Divider(height: 24),

                            if (bid.paidAt != null) ...[
                              _buildDetailRow(
                                label: 'Paid On',
                                value: dateFormat.format(bid.paidAt!),
                              ),
                              const Divider(height: 24),
                            ],

                            if (bid.paymentReference != null) ...[
                              _buildDetailRow(
                                label: 'Payment Reference',
                                value: bid.paymentReference!,
                              ),
                              const Divider(height: 24),
                            ],
                          ],
                        ),
                      ),

                      // Dispute section
                      _buildDisputeSection(bid),

                      // Action buttons
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          children: [
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                onPressed: () {
                                  BidManagementHelper.navigateToAuctionDetails(
                                    auctionId: bid.auction.id,
                                    context: context,
                                  );
                                },
                                style: ElevatedButton.styleFrom(
                                  foregroundColor: Colors.white,
                                  backgroundColor: AppColors.primaryColor,
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 16,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                child: const Text('View Auction Details'),
                              ),
                            ),
                            const SizedBox(height: 12),
                            if (bid.auction.status.toLowerCase() == 'closed' &&
                                isWon &&
                                !isPaid)
                              SizedBox(
                                width: double.infinity,
                                child: ElevatedButton(
                                  onPressed: () {
                                    // TODO: Implement payment
                                    Get.snackbar(
                                      'Coming Soon',
                                      'Payment feature will be available soon',
                                      backgroundColor: AppColors.primaryColor,
                                      colorText: Colors.white,
                                    );
                                  },
                                  style: ElevatedButton.styleFrom(
                                    foregroundColor: Colors.white,
                                    backgroundColor: RealTimeColors.success,
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 16,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                  child: const Text('Make Payment'),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    });
  }

  Widget _buildDetailRow({
    required String label,
    required String value,
    TextStyle? valueStyle,
    Color? valueColor,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 14,
            color: AppColors.subtextColor,
          ),
        ),
        Text(
          value,
          style:
              valueStyle ??
              GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: valueColor ?? AppColors.textColor,
              ),
        ),
      ],
    );
  }

  // Helper to convert string status to AuctionStatus enum
  AuctionStatus _getAuctionStatusFromString(String status) {
    switch (status.toLowerCase()) {
      case 'live':
        return AuctionStatus.live;
      case 'closed':
        return AuctionStatus.closed;
      case 'upcoming':
        return AuctionStatus.upcoming;
      case 'draft':
        return AuctionStatus.draft;
      default:
        return AuctionStatus.draft;
    }
  }
}
