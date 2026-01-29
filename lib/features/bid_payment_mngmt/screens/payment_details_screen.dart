import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:real_time_pawn/core/utils/pallete.dart';
import 'package:real_time_pawn/features/bid_payment_mngmt/controllers/bid_payment_mngmt_controller.dart';
import 'package:real_time_pawn/features/bid_payment_mngmt/helpers/bid_payment_mngmt_helper.dart';
import 'package:real_time_pawn/models/bid_payment_model.dart';

class PaymentDetailsScreen extends StatefulWidget {
  final String paymentId;

  const PaymentDetailsScreen({super.key, required this.paymentId});

  @override
  State<PaymentDetailsScreen> createState() => _PaymentDetailsScreenState();
}

class _PaymentDetailsScreenState extends State<PaymentDetailsScreen> {
  final BidPaymentController _controller = Get.find<BidPaymentController>();

  @override
  void initState() {
    super.initState();
    _loadPaymentDetails();
    _startPaymentPollingIfNeeded();
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
      // Start polling for status updates
      await BidPaymentHelper.pollPaymentStatus(
        paymentId: widget.paymentId,
        maxAttempts: 20,
        intervalSeconds: 3,
        onStatusUpdate: (statusData) {
          if (statusData != null && statusData['paid'] == true) {
            // Refresh details when payment is complete
            _loadPaymentDetails();
            BidPaymentHelper.showSuccess('Payment completed!');
          }
        },
      );
    }
  }

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
          Text(
            value,
            style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: valueColor ?? AppColors.textColor,
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
    );
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final payment = _controller.selectedPayment.value;
      final isLoading = _controller.isLoadingDetails.value;

      if (isLoading || payment == null) {
        return Scaffold(
          backgroundColor: AppColors.backgroundColor,
          body: Center(
            child: CircularProgressIndicator(color: AppColors.primaryColor),
          ),
        );
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
              ),

              Expanded(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Payment status header
                      Container(
                        margin: const EdgeInsets.all(16),
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: AppColors.surfaceColor,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: AppColors.borderColor),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
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
                              BidPaymentHelper.formatCurrency(payment.amount),
                              style: GoogleFonts.poppins(
                                fontSize: 32,
                                fontWeight: FontWeight.bold,
                                color: AppColors.primaryColor,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Payment Amount',
                              style: GoogleFonts.poppins(
                                fontSize: 14,
                                color: AppColors.subtextColor,
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Payment information
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
                              'Payment Information',
                              style: GoogleFonts.poppins(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textColor,
                              ),
                            ),
                            const SizedBox(height: 16),
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
                            const Divider(height: 16),
                            if (payment.payerPhone != null &&
                                payment.payerPhone!.isNotEmpty)
                              Column(
                                children: [
                                  _buildDetailRow(
                                    'Payer Phone',
                                    payment.payerPhone!,
                                  ),
                                  const Divider(height: 16),
                                ],
                              ),
                            _buildDetailRow(
                              'Payment Date',
                              '${dateFormat.format(payment.paidAt ?? payment.createdAt)} at ${timeFormat.format(payment.paidAt ?? payment.createdAt)}',
                            ),
                            const Divider(height: 16),
                            _buildDetailRow(
                              'Payment Status',
                              payment.statusText,
                              valueColor:
                                  BidPaymentHelper.getPaymentStatusColor(
                                    payment.statusText.toLowerCase(),
                                  ),
                            ),
                          ],
                        ),
                      ),

                      // Auction information
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
                              'Auction Information',
                              style: GoogleFonts.poppins(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textColor,
                              ),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              payment.auction.asset.title,
                              style: GoogleFonts.poppins(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textColor,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              payment.auction.auctionNo,
                              style: GoogleFonts.poppins(
                                fontSize: 14,
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
                          ],
                        ),
                      ),

                      // Notes section
                      if (payment.notes != null && payment.notes!.isNotEmpty)
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
                                'Notes',
                                style: GoogleFonts.poppins(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.textColor,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                payment.notes!,
                                style: GoogleFonts.poppins(
                                  fontSize: 14,
                                  color: AppColors.textColor,
                                ),
                              ),
                            ],
                          ),
                        ),

                      // Action buttons
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          children: [
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                onPressed: () {
                                  // Share receipt
                                  BidPaymentHelper.showSuccess(
                                    'Receipt sharing coming soon!',
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
                                child: const Text('Share Receipt'),
                              ),
                            ),
                            const SizedBox(height: 12),
                            if (payment.status == PaymentStatus.failed)
                              SizedBox(
                                width: double.infinity,
                                child: ElevatedButton(
                                  onPressed: () {
                                    // Retry payment
                                    Get.toNamed(
                                      '/select-payment-method',
                                      arguments: {
                                        'bidId': payment.bid.id,
                                        'amount': payment.amount,
                                      },
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
                                  child: const Text('Retry Payment'),
                                ),
                              ),
                            const SizedBox(height: 12),
                            SizedBox(
                              width: double.infinity,
                              child: OutlinedButton(
                                onPressed: () {
                                  Get.offAllNamed('/my-bid-payments');
                                },
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: AppColors.primaryColor,
                                  side: BorderSide(
                                    color: AppColors.primaryColor,
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 16,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                child: const Text('Back to Payments'),
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
}
