import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
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
  final BidManagementController _controller = Get.find<BidManagementController>();
  final TextEditingController _disputeReasonController = TextEditingController();
  bool _showDisputeForm = false;

  @override
  void initState() {
    super.initState();
    _loadBidDetails();
  }

  @override
  void dispose() {
    _disputeReasonController.dispose();
    super.dispose();
  }

  Future<void> _loadBidDetails() async {
    await BidManagementHelper.loadBidDetails(bidId: widget.bidId);
  }

  Future<void> _raiseDispute() async {
    if (_disputeReasonController.text.isEmpty) {
      Get.snackbar('Error', 'Please enter a reason for the dispute',
          backgroundColor: AppColors.errorColor, colorText: Colors.white);
      return;
    }
    final success = await _controller.raiseDisputeRequest(
      bidId: widget.bidId,
      reason: _disputeReasonController.text,
    );
    if (success) {
      if (mounted) {
        setState(() {
          _showDisputeForm = false;
          _disputeReasonController.clear();
        });
      }
      BidManagementHelper.showSuccess('Dispute raised successfully');
    } else {
      BidManagementHelper.showError(_controller.errorMessage.value);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final bid = _controller.selectedBid.value;
      if (_controller.isLoadingDetails.value || bid == null) {
        return Scaffold(
          backgroundColor: AppColors.backgroundColor,
          body: Center(child: CircularProgressIndicator(color: AppColors.primaryColor)),
        );
      }

      final isWon = _controller.isBidWon(bid);
      final isPaid = _controller.isBidPaid(bid);
      final paymentStatus = bid.paymentStatus.toString().split('.').last.toLowerCase();

      return Scaffold(
        backgroundColor: AppColors.backgroundColor,
        body: SafeArea(
          child: Column(
            children: [
              _buildAppBar(bid),
              Expanded(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _buildHeroCard(bid),
                      _buildAuctionCard(bid),
                      _buildBidInfoCard(bid),
                      _buildPaymentCard(bid, paymentStatus),
                      _buildDisputeSection(bid),
                      _buildActionButtons(bid, isWon, isPaid),
                      const SizedBox(height: 24),
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

  Widget _buildAppBar(UserBid bid) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.surfaceColor,
        border: Border(bottom: BorderSide(color: AppColors.borderColor)),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 8, offset: const Offset(0, 2)),
        ],
      ),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Get.back(),
            icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
            color: AppColors.textColor,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'Bid Details',
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AppColors.textColor,
              ),
            ),
          ),
          BidStatusBadge(bid: bid),
        ],
      ),
    );
  }

  Widget _buildHeroCard(UserBid bid) {
    final imageUrl = bid.auction.asset.attachments.isNotEmpty
        ? bid.auction.asset.attachments.first.url
        : null;

    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.primaryColor, AppColors.primaryColor.withValues(alpha: 0.75)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryColor.withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Stack(
          children: [
            // Background image (blurred/dimmed)
            if (imageUrl != null)
              Positioned.fill(
                child: CachedNetworkImage(
                  imageUrl: imageUrl,
                  fit: BoxFit.cover,
                  color: Colors.black.withValues(alpha: 0.45),
                  colorBlendMode: BlendMode.darken,
                  placeholder: (ctx, url) => const SizedBox.shrink(),
                  errorWidget: (ctx, url, err) => const SizedBox.shrink(),
                ),
              ),

            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Your Bid Amount',
                    style: GoogleFonts.poppins(
                      fontSize: 13,
                      color: Colors.white.withValues(alpha: 0.8),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    BidManagementHelper.formatCurrency(bid.amount, bid.currency),
                    style: GoogleFonts.poppins(
                      fontSize: 36,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  )
                      .animate()
                      .fadeIn(duration: 400.ms)
                      .scaleXY(begin: 0.85, end: 1.0, duration: 400.ms, curve: Curves.easeOut),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      _heroPill(
                        Icons.tag_rounded,
                        bid.auction.auctionNo,
                      ),
                      const SizedBox(width: 8),
                      _heroPill(
                        Icons.access_time_rounded,
                        DateFormat('MMM dd, yyyy').format(bid.placedAt),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    ).animate().fadeIn(duration: 350.ms).slideY(begin: 0.06, end: 0);
  }

  Widget _heroPill(IconData icon, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: Colors.white),
          const SizedBox(width: 5),
          Text(
            text,
            style: GoogleFonts.poppins(fontSize: 11, color: Colors.white, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }

  Widget _buildAuctionCard(UserBid bid) {
    final auctionStatus = bid.auction.status.toLowerCase();
    final statusColor = AuctionsHelper.getStatusColor(_getAuctionStatus(auctionStatus));

    return _sectionCard(
      title: 'Auction',
      icon: Icons.gavel_rounded,
      delay: 80,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Asset image thumbnail
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: SizedBox(
                  width: 72,
                  height: 72,
                  child: bid.auction.asset.attachments.isNotEmpty
                      ? CachedNetworkImage(
                          imageUrl: bid.auction.asset.attachments.first.url,
                          fit: BoxFit.cover,
                          placeholder: (ctx, url) => Container(color: AppColors.borderColor),
                          errorWidget: (ctx, url, err) => _assetPlaceholder(),
                        )
                      : _assetPlaceholder(),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      bid.auction.asset.title,
                      style: GoogleFonts.poppins(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textColor,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      bid.auction.auctionNo,
                      style: GoogleFonts.poppins(fontSize: 12, color: AppColors.subtextColor),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        _statusChip(bid.auction.status.toUpperCase(), statusColor),
                        const SizedBox(width: 6),
                        _statusChip(
                          bid.auction.auctionType.toUpperCase(),
                          AppColors.primaryColor,
                          filled: false,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          _infoRow(Icons.event_rounded, 'Auction Ended',
              DateFormat('MMM dd, yyyy – h:mm a').format(bid.auction.endsAt)),
        ],
      ),
    );
  }

  Widget _buildBidInfoCard(UserBid bid) {
    return _sectionCard(
      title: 'Bid Information',
      icon: Icons.monetization_on_outlined,
      delay: 130,
      child: Column(
        children: [
          _infoRow(
            Icons.gavel_rounded,
            'Your Bid',
            BidManagementHelper.formatCurrency(bid.amount, bid.currency),
            valueColor: AppColors.primaryColor,
            valueBold: true,
          ),
          _divider(),
          _infoRow(
            Icons.trending_up_rounded,
            'Highest Bid',
            BidManagementHelper.formatCurrency(
              bid.auction.winningBidAmount ?? bid.auction.startingBidAmount,
              bid.currency,
            ),
          ),
          _divider(),
          _infoRow(
            Icons.flag_outlined,
            'Starting Bid',
            BidManagementHelper.formatCurrency(bid.auction.startingBidAmount, bid.currency),
          ),
          if (bid.auction.reservePrice != null) ...[
            _divider(),
            _infoRow(
              Icons.lock_outline_rounded,
              'Reserve Price',
              BidManagementHelper.formatCurrency(bid.auction.reservePrice!, bid.currency),
            ),
          ],
          _divider(),
          _infoRow(
            Icons.access_time_rounded,
            'Placed At',
            '${DateFormat('MMM dd, yyyy').format(bid.placedAt)} at ${DateFormat('h:mm a').format(bid.placedAt)}',
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentCard(UserBid bid, String paymentStatus) {
    final statusColor = BidManagementHelper.getPaymentStatusColor(paymentStatus);
    final statusText = BidManagementHelper.getPaymentStatusText(paymentStatus);

    return _sectionCard(
      title: 'Payment',
      icon: Icons.payment_rounded,
      delay: 180,
      child: Column(
        children: [
          // Payment status bar
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: statusColor.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: statusColor.withValues(alpha: 0.25)),
            ),
            child: Row(
              children: [
                Container(
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(color: statusColor, shape: BoxShape.circle),
                ),
                const SizedBox(width: 10),
                Text(
                  statusText,
                  style: GoogleFonts.poppins(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: statusColor,
                  ),
                ),
                const Spacer(),
                if (paymentStatus == 'paid')
                  Icon(Icons.verified_rounded, color: statusColor, size: 20),
              ],
            ),
          ),
          const SizedBox(height: 14),
          _infoRow(
            Icons.attach_money_rounded,
            'Amount Paid',
            BidManagementHelper.formatCurrency(bid.paidAmount, bid.currency),
            valueColor: bid.paidAmount > 0 ? RealTimeColors.success : AppColors.textColor,
          ),
          if (bid.paidAt != null) ...[
            _divider(),
            _infoRow(
              Icons.calendar_today_rounded,
              'Paid On',
              DateFormat('MMM dd, yyyy').format(bid.paidAt!),
            ),
          ],
          if (bid.paymentReference != null) ...[
            _divider(),
            _infoRow(
              Icons.receipt_long_rounded,
              'Reference',
              bid.paymentReference!,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildDisputeSection(UserBid bid) {
    final hasDispute = bid.dispute.status != BidDisputeStatus.none;
    final disputeStatus = bid.dispute.status.toString().split('.').last.toLowerCase();
    final auctionStatus = bid.auction.status.toLowerCase();
    final canRaiseDispute = auctionStatus == 'closed' && !hasDispute;

    if (hasDispute) {
      final color = BidManagementHelper.getDisputeStatusColor(disputeStatus);
      return _sectionCard(
        title: 'Dispute',
        icon: Icons.warning_amber_rounded,
        delay: 220,
        borderColor: color.withValues(alpha: 0.3),
        headerColor: color.withValues(alpha: 0.08),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.warning_amber_rounded, color: color, size: 20),
                const SizedBox(width: 8),
                Text(
                  'Status: ${BidManagementHelper.getDisputeStatusText(disputeStatus)}',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: color,
                  ),
                ),
              ],
            ),
            if (bid.dispute.reason != null && bid.dispute.reason!.isNotEmpty) ...[
              const SizedBox(height: 10),
              Text(
                bid.dispute.reason!,
                style: GoogleFonts.poppins(fontSize: 14, color: AppColors.subtextColor),
              ),
            ],
          ],
        ),
      );
    }

    if (!canRaiseDispute) return const SizedBox.shrink();

    return _sectionCard(
      title: 'Dispute',
      icon: Icons.report_problem_outlined,
      delay: 220,
      borderColor: RealTimeColors.warning.withValues(alpha: 0.3),
      child: _showDisputeForm ? _buildDisputeForm() : _buildDisputePrompt(),
    );
  }

  Widget _buildDisputePrompt() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Have an issue with this bid?',
          style: GoogleFonts.poppins(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppColors.textColor,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'If you believe there was an error with this bid or the auction process, you can raise a dispute.',
          style: GoogleFonts.poppins(fontSize: 13, color: AppColors.subtextColor),
        ),
        const SizedBox(height: 12),
        OutlinedButton.icon(
          onPressed: () => setState(() => _showDisputeForm = true),
          icon: Icon(Icons.flag_outlined, color: RealTimeColors.warning),
          label: Text(
            'Raise a Dispute',
            style: GoogleFonts.poppins(color: RealTimeColors.warning, fontWeight: FontWeight.w600),
          ),
          style: OutlinedButton.styleFrom(
            side: BorderSide(color: RealTimeColors.warning),
          ),
        ),
      ],
    );
  }

  Widget _buildDisputeForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Explain the issue:',
          style: GoogleFonts.poppins(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppColors.textColor,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _disputeReasonController,
          maxLines: 4,
          decoration: InputDecoration(
            hintText: 'Describe why you are disputing this bid...',
            hintStyle: GoogleFonts.poppins(color: AppColors.subtextColor, fontSize: 13),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
            filled: true,
            fillColor: AppColors.backgroundColor,
          ),
          style: GoogleFonts.poppins(fontSize: 14, color: AppColors.textColor),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: () => setState(() {
                  _showDisputeForm = false;
                  _disputeReasonController.clear();
                }),
                child: const Text('Cancel'),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: ElevatedButton(
                onPressed: _raiseDispute,
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.white,
                  backgroundColor: RealTimeColors.warning,
                ),
                child: const Text('Submit'),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildActionButtons(UserBid bid, bool isWon, bool isPaid) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        children: [
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () => BidManagementHelper.navigateToAuctionDetails(
                auctionId: bid.auction.id,
                context: context,
              ),
              icon: const Icon(Icons.open_in_new_rounded, size: 18),
              label: Text(
                'View Auction Details',
                style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w600),
              ),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ),
          if (bid.auction.status.toLowerCase() == 'closed' && isWon && !isPaid) ...[
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => BidManagementHelper.navigateToBidPayment(
                  bidId: bid.id,
                  amount: bid.amount,
                  context: context,
                ),
                icon: const Icon(Icons.payment_rounded, size: 18),
                label: Text(
                  'Make Payment',
                  style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w700),
                ),
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.white,
                  backgroundColor: RealTimeColors.success,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ),
          ],
        ],
      ),
    ).animate().fadeIn(delay: 280.ms);
  }

  // ── Helpers ──────────────────────────────────────────────────────────────

  Widget _sectionCard({
    required String title,
    required IconData icon,
    required Widget child,
    int delay = 0,
    Color? borderColor,
    Color? headerColor,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.surfaceColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor ?? AppColors.borderColor),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: headerColor ?? AppColors.primaryColor.withValues(alpha: 0.04),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            ),
            child: Row(
              children: [
                Icon(icon, size: 18, color: AppColors.primaryColor),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textColor,
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: child,
          ),
        ],
      ),
    ).animate().fadeIn(delay: delay.ms, duration: 300.ms).slideY(begin: 0.05, end: 0, delay: delay.ms);
  }

  Widget _infoRow(IconData icon, String label, String value,
      {Color? valueColor, bool valueBold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 16, color: AppColors.subtextColor),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              label,
              style: GoogleFonts.poppins(fontSize: 13, color: AppColors.subtextColor),
            ),
          ),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: GoogleFonts.poppins(
                fontSize: 13,
                fontWeight: valueBold ? FontWeight.w700 : FontWeight.w600,
                color: valueColor ?? AppColors.textColor,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _divider() => const Divider(height: 20);

  Widget _statusChip(String label, Color color, {bool filled = true}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: filled ? color : color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
        border: filled ? null : Border.all(color: color.withValues(alpha: 0.4)),
      ),
      child: Text(
        label,
        style: GoogleFonts.poppins(
          fontSize: 10,
          fontWeight: FontWeight.w700,
          color: filled ? Colors.white : color,
        ),
      ),
    );
  }

  Widget _assetPlaceholder() {
    return Container(
      color: AppColors.borderColor,
      child: Icon(Icons.image_outlined, color: RealTimeColors.grey400),
    );
  }

  AuctionStatus _getAuctionStatus(String status) {
    switch (status) {
      case 'live':
        return AuctionStatus.live;
      case 'closed':
        return AuctionStatus.closed;
      case 'upcoming':
        return AuctionStatus.upcoming;
      default:
        return AuctionStatus.draft;
    }
  }
}
