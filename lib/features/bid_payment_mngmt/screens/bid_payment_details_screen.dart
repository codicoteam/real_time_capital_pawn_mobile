import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:real_time_pawn/config/routers/router.dart';
import 'package:shimmer/shimmer.dart';
import 'package:real_time_pawn/core/utils/pallete.dart';
import 'package:real_time_pawn/features/bid_payment_mngmt/controllers/bid_payment_mngmt_controller.dart';
import 'package:real_time_pawn/features/bid_payment_mngmt/helpers/bid_payment_mngmt_helper.dart';
import 'package:real_time_pawn/models/bid_payment_model.dart';

class BidPaymentDetailsScreen extends StatefulWidget {
  final String paymentId;

  const BidPaymentDetailsScreen({super.key, required this.paymentId});

  @override
  State<BidPaymentDetailsScreen> createState() => _PaymentDetailsScreenState();
}

class _PaymentDetailsScreenState extends State<BidPaymentDetailsScreen> {
  final BidPaymentController _controller = Get.find<BidPaymentController>();

  @override
  void initState() {
    super.initState();
    // ✅ KEY FIX: Defer all state-changing calls until after the first frame.
    // Calling reactive updates directly in initState can trigger
    // "setState() called during build" because the parent widget tree
    // may still be building when this screen is pushed.
    SchedulerBinding.instance.addPostFrameCallback((_) {
      _loadPaymentDetails().then((_) => _startPaymentPollingIfNeeded());
    });
  }

  Future<void> _loadPaymentDetails() async {
    await BidPaymentHelper.loadPaymentDetails(paymentId: widget.paymentId);
  }

  Future<void> _refreshDetails() async {
    await _loadPaymentDetails();
  }

  Future<void> _startPaymentPollingIfNeeded() async {
    final payment = _controller.selectedPayment.value;
    if (payment != null &&
        (payment.status == PaymentStatus.pending ||
            payment.status == PaymentStatus.initiated ||
            payment.status == PaymentStatus.processing)) {
      await BidPaymentHelper.pollPaymentStatus(
        paymentId: widget.paymentId,
        maxAttempts: 20,
        intervalSeconds: 3,
        onStatusUpdate: (statusData) {
          if (statusData != null && statusData['paid'] == true) {
            _loadPaymentDetails();
            BidPaymentHelper.showSuccess('Payment completed!');
          }
        },
      );
    }
  }

  // ─── Shimmer Loading Skeleton ─────────────────────────────────────────────

  Widget _buildShimmerBox({
    double width = double.infinity,
    double height = 16,
    double radius = 8,
  }) {
    return Shimmer.fromColors(
      baseColor: Colors.grey.shade300,
      highlightColor: Colors.grey.shade100,
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(radius),
        ),
      ),
    );
  }

  Widget _buildShimmerCard() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildShimmerBox(height: 20, width: 140),
          const SizedBox(height: 16),
          _buildShimmerBox(height: 14),
          const SizedBox(height: 10),
          _buildShimmerBox(height: 14),
          const SizedBox(height: 10),
          _buildShimmerBox(height: 14, width: 200),
          const SizedBox(height: 10),
          _buildShimmerBox(height: 14),
        ],
      ),
    );
  }

  Widget _buildLoadingScreen() {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      body: SafeArea(
        child: Column(
          children: [
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
                  const SizedBox(width: 48),
                  const SizedBox(width: 8),
                  _buildShimmerBox(width: 150, height: 18),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                physics: const NeverScrollableScrollPhysics(),
                child: Column(
                  children: [
                    Container(
                      margin: const EdgeInsets.all(16),
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceColor,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppColors.borderColor),
                      ),
                      child: Column(
                        children: [
                          _buildShimmerBox(width: 100, height: 36, radius: 20),
                          const SizedBox(height: 16),
                          _buildShimmerBox(width: 160, height: 40, radius: 8),
                          const SizedBox(height: 8),
                          _buildShimmerBox(width: 100, height: 14),
                        ],
                      ),
                    ),
                    _buildShimmerCard(),
                    _buildShimmerCard(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─── UI Helpers ───────────────────────────────────────────────────────────

  Widget _buildDetailRow(String label, String value, {Color? valueColor}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 14,
              color: AppColors.subtextColor,
            ),
          ),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: valueColor ?? AppColors.textColor,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBadge(PaymentStatus status) {
    final statusColor = BidPaymentHelper.getPaymentStatusColor(
      status.toString().split('.').last,
    );
    final statusText = BidPaymentController.getPaymentStatusText(status);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: statusColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        statusText,
        style: GoogleFonts.poppins(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
    ).animate().scale(duration: 400.ms, curve: Curves.elasticOut);
  }

  Widget _buildSectionCard({
    required String title,
    required List<Widget> children,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
            title,
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.textColor,
            ),
          ),
          const SizedBox(height: 12),
          ...children,
        ],
      ),
    );
  }

  // ─── Build ────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final payment = _controller.selectedPayment.value;
      final isLoading = _controller.isLoadingDetails.value;

      if (isLoading || payment == null) {
        return _buildLoadingScreen();
      }

      final dateFormat = DateFormat('MMM dd, yyyy');
      final timeFormat = DateFormat('h:mm a');

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
                      'Payment Details',
                      style: GoogleFonts.poppins(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textColor,
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                      onPressed: _refreshDetails,
                      icon: const Icon(Icons.refresh_outlined),
                      color: AppColors.textColor,
                    ),
                  ],
                ),
              ).animate().fadeIn(duration: 300.ms).slideY(begin: -0.2, end: 0),

              Expanded(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Status & amount header
                      Container(
                            margin: const EdgeInsets.all(16),
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: AppColors.surfaceColor,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: AppColors.borderColor),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.05),
                                  blurRadius: 10,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Column(
                              children: [
                                _buildStatusBadge(payment.status),
                                const SizedBox(height: 16),
                                Text(
                                      BidPaymentHelper.formatCurrency(
                                        payment.amount,
                                      ),
                                      style: GoogleFonts.poppins(
                                        fontSize: 32,
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.primaryColor,
                                      ),
                                    )
                                    .animate()
                                    .fadeIn(delay: 200.ms, duration: 400.ms)
                                    .slideY(begin: 0.3, end: 0),
                                const SizedBox(height: 4),
                                Text(
                                  'Payment Amount',
                                  style: GoogleFonts.poppins(
                                    fontSize: 14,
                                    color: AppColors.subtextColor,
                                  ),
                                ).animate().fadeIn(
                                  delay: 300.ms,
                                  duration: 300.ms,
                                ),
                              ],
                            ),
                          )
                          .animate()
                          .fadeIn(duration: 400.ms)
                          .slideY(begin: 0.1, end: 0),

                      // Payment info
                      _buildSectionCard(
                            title: 'Payment Information',
                            children: [
                              _buildDetailRow(
                                'Payment Method',
                                BidPaymentHelper.getPaymentMethodDisplayName(
                                  payment.method,
                                ),
                              ),
                              const Divider(height: 16),
                              _buildDetailRow(
                                'Provider',
                                payment.provider.toUpperCase(),
                              ),
                              const Divider(height: 16),
                              _buildDetailRow(
                                'Transaction ID',
                                payment.providerTxnId ?? 'N/A',
                              ),
                              const Divider(height: 16),
                              _buildDetailRow(
                                'Receipt Number',
                                payment.receiptNo ?? 'N/A',
                              ),
                              if (payment.payerPhone != null &&
                                  payment.payerPhone!.isNotEmpty) ...[
                                const Divider(height: 16),
                                _buildDetailRow(
                                  'Payer Phone',
                                  payment.payerPhone!,
                                ),
                              ],
                              const Divider(height: 16),
                              _buildDetailRow(
                                'Payment Date',
                                '${dateFormat.format(payment.paidAt ?? payment.createdAt)} at ${timeFormat.format(payment.paidAt ?? payment.createdAt)}',
                              ),
                              const Divider(height: 16),
                              _buildDetailRow(
                                'Status',
                                payment.statusText,
                                valueColor:
                                    BidPaymentHelper.getPaymentStatusColor(
                                      payment.statusText.toLowerCase(),
                                    ),
                              ),
                            ],
                          )
                          .animate()
                          .fadeIn(delay: 100.ms, duration: 400.ms)
                          .slideY(begin: 0.1, end: 0),

                      // Auction info
                      _buildSectionCard(
                            title: 'Auction Information',
                            children: [
                              Text(
                                payment.auction.asset.title,
                                style: GoogleFonts.poppins(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.textColor,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                payment.auction.auctionNo,
                                style: GoogleFonts.poppins(
                                  fontSize: 13,
                                  color: AppColors.subtextColor,
                                ),
                              ),
                              const Divider(height: 16),
                              _buildDetailRow(
                                'Bid Amount',
                                BidPaymentHelper.formatCurrency(
                                  payment.bid.amount,
                                ),
                              ),
                              const Divider(height: 16),
                              _buildDetailRow(
                                'Bid Placed',
                                dateFormat.format(payment.bid.placedAt),
                              ),
                              const SizedBox(height: 12),
                              SizedBox(
                                width: double.infinity,
                                child: OutlinedButton.icon(
                                  onPressed: () {
                                    Get.toNamed(
                                      RoutesHelper.auctionDetailsScreen,
                                      arguments: {
                                        'auctionId': payment.auction.id,
                                      },
                                    );
                                  },
                                  icon: const Icon(
                                    Icons.gavel_outlined,
                                    size: 18,
                                  ),
                                  label: const Text('View Auction'),
                                  style: OutlinedButton.styleFrom(
                                    foregroundColor: AppColors.primaryColor,
                                    side: BorderSide(
                                      color: AppColors.primaryColor,
                                    ),
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 12,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          )
                          .animate()
                          .fadeIn(delay: 200.ms, duration: 400.ms)
                          .slideY(begin: 0.1, end: 0),

                      // Notes
                      if (payment.notes != null && payment.notes!.isNotEmpty)
                        _buildSectionCard(
                          title: 'Notes',
                          children: [
                            Text(
                              payment.notes!,
                              style: GoogleFonts.poppins(
                                fontSize: 14,
                                color: AppColors.textColor,
                              ),
                            ),
                          ],
                        ).animate().fadeIn(delay: 250.ms, duration: 400.ms),

                      // Action buttons
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          children: [
                            SizedBox(
                                  width: double.infinity,
                                  child: ElevatedButton.icon(
                                    onPressed: () {
                                      BidPaymentHelper.showSuccess(
                                        'Receipt sharing coming soon!',
                                      );
                                    },
                                    icon: const Icon(
                                      Icons.share_outlined,
                                      size: 18,
                                    ),
                                    label: const Text('Share Receipt'),
                                    style: ElevatedButton.styleFrom(
                                      foregroundColor: Colors.white,
                                      backgroundColor: AppColors.primaryColor,
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 14,
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                    ),
                                  ),
                                )
                                .animate()
                                .fadeIn(delay: 300.ms, duration: 400.ms)
                                .slideY(begin: 0.2, end: 0),

                            if (payment.status == PaymentStatus.failed) ...[
                              const SizedBox(height: 12),
                              SizedBox(
                                    width: double.infinity,
                                    child: ElevatedButton.icon(
                                      onPressed: () {
                                        Get.toNamed(
                                          '/select-payment-method',
                                          arguments: {
                                            'bidId': payment.bid.id,
                                            'amount': payment.amount,
                                          },
                                        );
                                      },
                                      icon: const Icon(Icons.refresh, size: 18),
                                      label: const Text('Retry Payment'),
                                      style: ElevatedButton.styleFrom(
                                        foregroundColor: Colors.white,
                                        backgroundColor: RealTimeColors.success,
                                        padding: const EdgeInsets.symmetric(
                                          vertical: 14,
                                        ),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                        ),
                                      ),
                                    ),
                                  )
                                  .animate()
                                  .fadeIn(delay: 350.ms, duration: 400.ms)
                                  .slideY(begin: 0.2, end: 0),
                            ],

                            const SizedBox(height: 12),
                            SizedBox(
                                  width: double.infinity,
                                  child: OutlinedButton(
                                    onPressed: () =>
                                        Get.offAllNamed('/my-bid-payments'),
                                    style: OutlinedButton.styleFrom(
                                      foregroundColor: AppColors.primaryColor,
                                      side: BorderSide(
                                        color: AppColors.primaryColor,
                                      ),
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 14,
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                    ),
                                    child: const Text('Back to Payments'),
                                  ),
                                )
                                .animate()
                                .fadeIn(delay: 400.ms, duration: 400.ms)
                                .slideY(begin: 0.2, end: 0),
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
}
