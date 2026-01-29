import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:real_time_pawn/core/utils/pallete.dart';
import 'package:real_time_pawn/features/bid_payment_mngmt/controllers/bid_payment_mngmt_controller.dart';
import 'package:real_time_pawn/features/bid_payment_mngmt/helpers/bid_payment_mngmt_helper.dart';

class ConfirmBidPaymentScreen extends StatefulWidget {
  const ConfirmBidPaymentScreen({super.key});

  @override
  State<ConfirmBidPaymentScreen> createState() =>
      _ConfirmBidPaymentScreenState();
}

class _ConfirmBidPaymentScreenState extends State<ConfirmBidPaymentScreen> {
  final bidPaymentController = Get.find<BidPaymentController>();
  bool _isProcessing = false;
  Map<String, dynamic>? _paymentArgs;

  @override
  void initState() {
    super.initState();
    _paymentArgs = Get.arguments as Map<String, dynamic>?;
  }

  Future<void> _confirmPayment() async {
    if (_paymentArgs == null) {
      BidPaymentHelper.showError('Payment information not found');
      Get.back();
      return;
    }

    setState(() {
      _isProcessing = true;
    });

    try {
      final success = await BidPaymentHelper.createPayment(
        bidId: _paymentArgs!['bidId'],
        amount: _paymentArgs!['amount'],
        method: _paymentArgs!['methodName'],
        provider: _paymentArgs!['provider'],
        payerPhone: _paymentArgs!['payerPhone'],
        notes: _paymentArgs!['notes'],
      );

      if (success) {
        // Show success message
        BidPaymentHelper.showSuccess('Payment initiated successfully!');

        // Navigate back to payments list
        await Future.delayed(const Duration(seconds: 2));
        Get.offAllNamed('/my-bid-payments');
      } else {
        BidPaymentHelper.showError('Failed to create payment');
      }
    } catch (e) {
      BidPaymentHelper.showError('Error: ${e.toString()}');
    } finally {
      setState(() {
        _isProcessing = false;
      });
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

  @override
  Widget build(BuildContext context) {
    if (_paymentArgs == null) {
      return Scaffold(
        backgroundColor: AppColors.backgroundColor,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 64, color: RealTimeColors.error),
              const SizedBox(height: 16),
              Text(
                'Payment Information Not Found',
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textColor,
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => Get.back(),
                child: const Text('Go Back'),
              ),
            ],
          ),
        ),
      );
    }

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
                  Text(
                    'Confirm Payment',
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textColor,
                    ),
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
                    // Success icon
                    Container(
                      margin: const EdgeInsets.all(32),
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        color: RealTimeColors.success.withOpacity(0.1),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: RealTimeColors.success.withOpacity(0.3),
                          width: 3,
                        ),
                      ),
                      child: Center(
                        child: Icon(
                          Icons.check_circle_outline,
                          size: 64,
                          color: RealTimeColors.success,
                        ),
                      ),
                    ),

                    // Title
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 32),
                      child: Text(
                        'Confirm Your Payment',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.poppins(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textColor,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 32),
                      child: Text(
                        'Please review your payment details before confirming',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          color: AppColors.subtextColor,
                        ),
                      ),
                    ),

                    // Payment details card
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
                          // Amount
                          Text(
                            BidPaymentHelper.formatCurrency(
                              _paymentArgs!['amount'],
                            ),
                            style: GoogleFonts.poppins(
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                              color: AppColors.primaryColor,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Total Amount',
                            style: GoogleFonts.poppins(
                              fontSize: 14,
                              color: AppColors.subtextColor,
                            ),
                          ),
                          const Divider(height: 32),

                          // Payment details
                          _buildDetailRow(
                            'Payment Method',
                            BidPaymentHelper.getPaymentMethodDisplayName(
                              _paymentArgs!['methodName'],
                            ),
                          ),
                          _buildDetailRow(
                            'Provider',
                            _paymentArgs!['provider'].toString().toUpperCase(),
                          ),
                          if (_paymentArgs!['payerPhone'].isNotEmpty)
                            _buildDetailRow(
                              'Phone Number',
                              _paymentArgs!['payerPhone'],
                            ),
                          if (_paymentArgs!['notes'].isNotEmpty) ...[
                            const Divider(height: 16),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Notes',
                                  style: GoogleFonts.poppins(
                                    fontSize: 14,
                                    color: AppColors.subtextColor,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  _paymentArgs!['notes'],
                                  style: GoogleFonts.poppins(
                                    fontSize: 14,
                                    color: AppColors.textColor,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ],
                      ),
                    ),

                    // Important notes
                    Container(
                      margin: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: RealTimeColors.warning.withOpacity(0.05),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: RealTimeColors.warning.withOpacity(0.2),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.info_outline,
                                color: RealTimeColors.warning,
                                size: 20,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Important Information',
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
                            '• Payments are processed immediately\n'
                            '• Please ensure you have sufficient funds\n'
                            '• Payment reference will be provided upon completion\n'
                            '• Failed payments will be refunded within 24 hours',
                            style: GoogleFonts.poppins(
                              fontSize: 13,
                              color: AppColors.subtextColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Action buttons
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.surfaceColor,
                border: Border(top: BorderSide(color: AppColors.borderColor)),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _isProcessing ? null : () => Get.back(),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.primaryColor,
                        side: BorderSide(color: AppColors.primaryColor),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text('Go Back'),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _isProcessing ? null : _confirmPayment,
                      style: ElevatedButton.styleFrom(
                        foregroundColor: Colors.white,
                        backgroundColor: RealTimeColors.success,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        disabledBackgroundColor: RealTimeColors.success
                            .withOpacity(0.5),
                      ),
                      child: _isProcessing
                          ? const SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : Text(
                              'Confirm Payment',
                              style: GoogleFonts.poppins(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
