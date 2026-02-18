import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:real_time_pawn/core/utils/pallete.dart';
import 'package:real_time_pawn/features/bid_payment_mngmt/helpers/bid_payment_mngmt_helper.dart';
import 'package:real_time_pawn/models/bid_payment_model.dart';
import 'package:url_launcher/url_launcher.dart';

class PaymentProcessingScreen extends StatefulWidget {
  final BidPayment payment;

  const PaymentProcessingScreen({super.key, required this.payment});

  @override
  State<PaymentProcessingScreen> createState() =>
      _PaymentProcessingScreenState();
}

class _PaymentProcessingScreenState extends State<PaymentProcessingScreen> {
  bool _isCheckingStatus = false;
  String? _statusMessage;
  Timer? _pollingTimer;
  int _pollingAttempts = 0;
  final int _maxPollingAttempts = 30;

  @override
  void initState() {
    super.initState();
    _startAutoPolling();
  }

  @override
  void dispose() {
    _pollingTimer?.cancel();
    super.dispose();
  }

  void _startAutoPolling() {
    // Start checking payment status every 3 seconds
    _pollingTimer = Timer.periodic(const Duration(seconds: 3), (timer) {
      if (_pollingAttempts >= _maxPollingAttempts) {
        timer.cancel();
        setState(() {
          _statusMessage =
              'Payment status check timed out. Please check manually.';
        });
        return;
      }
      _pollingAttempts++;
      _checkPaymentStatus();
    });
  }

  Future<void> _checkPaymentStatus() async {
    if (_isCheckingStatus) return;

    setState(() {
      _isCheckingStatus = true;
    });

    try {
      final statusData = await BidPaymentHelper.checkPaymentStatus(
        paymentId: widget.payment.id,
      );

      if (statusData != null) {
        final paid = statusData['paid'] == true;
        final gatewayStatus = statusData['gateway_status']
            ?.toString()
            .toLowerCase();

        if (paid || gatewayStatus == 'paid' || gatewayStatus == 'success') {
          _pollingTimer?.cancel();

          // Show success and navigate
          if (mounted) {
            BidPaymentHelper.showSuccess('Payment completed successfully!');
            Future.delayed(const Duration(seconds: 2), () {
              Get.offAllNamed('/my-bid-payments');
            });
          }
        } else if (gatewayStatus == 'failed' || gatewayStatus == 'cancelled') {
          _pollingTimer?.cancel();
          setState(() {
            _statusMessage = 'Payment failed. Please try again.';
          });
        }
      }
    } catch (e) {
      debugPrint('Error checking payment status: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isCheckingStatus = false;
        });
      }
    }
  }

  Future<void> _launchRedirectUrl() async {
    final redirectUrl =
        widget.payment.redirectUrl ??
        widget.payment.meta?['redirect_url']?.toString();

    if (redirectUrl != null && redirectUrl.isNotEmpty) {
      final Uri url = Uri.parse(redirectUrl);
      if (await canLaunchUrl(url)) {
        await launchUrl(url, mode: LaunchMode.externalApplication);
      } else {
        BidPaymentHelper.showError('Could not open payment page');
      }
    }
  }

  void _copyToClipboard(String text) {
    Clipboard.setData(ClipboardData(text: text));
    BidPaymentHelper.showSuccess('Copied to clipboard');
  }

  @override
  Widget build(BuildContext context) {
    final isEcoCash = widget.payment.method.toLowerCase() == 'ecocash';
    final isPayNow = widget.payment.method.toLowerCase() == 'paynow';

    final redirectUrl =
        widget.payment.redirectUrl ??
        widget.payment.meta?['redirect_url']?.toString();

    final pollUrl = widget.payment.pollUrl;
    final instructions = widget.payment.paymentInstructions;

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
                    'Processing Payment',
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
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Amount Card
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceColor,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppColors.borderColor),
                      ),
                      child: Column(
                        children: [
                          Text(
                            'Payment Amount',
                            style: GoogleFonts.poppins(
                              fontSize: 14,
                              color: AppColors.subtextColor,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            BidPaymentHelper.formatCurrency(
                              widget.payment.amount,
                            ),
                            style: GoogleFonts.poppins(
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                              color: AppColors.primaryColor,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Receipt: ${widget.payment.receiptNo ?? 'N/A'}',
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                              color: AppColors.subtextColor,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),

                    // 🔴 PAYNOW SPECIFIC: Show redirect button
                    if (isPayNow &&
                        redirectUrl != null &&
                        redirectUrl.isNotEmpty)
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: RealTimeColors.primaryGreen.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: RealTimeColors.primaryGreen,
                          ),
                        ),
                        child: Column(
                          children: [
                            const Icon(
                              Icons.open_in_browser,
                              size: 48,
                              color: RealTimeColors.primaryGreen,
                            ),
                            const SizedBox(height: 12),
                            Text(
                              'Complete Payment Online',
                              style: GoogleFonts.poppins(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textColor,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Click the button below to complete your payment on the PayNow secure page.',
                              textAlign: TextAlign.center,
                              style: GoogleFonts.poppins(
                                fontSize: 14,
                                color: AppColors.subtextColor,
                              ),
                            ),
                            const SizedBox(height: 20),
                            ElevatedButton.icon(
                              onPressed: _launchRedirectUrl,
                              icon: const Icon(Icons.launch),
                              label: const Text('Open PayNow Payment Page'),
                              style: ElevatedButton.styleFrom(
                                foregroundColor: Colors.white,
                                backgroundColor: RealTimeColors.primaryGreen,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 16,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                            ),
                            const SizedBox(height: 12),
                            InkWell(
                              onTap: () => _copyToClipboard(redirectUrl),
                              child: Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: AppColors.surfaceColor,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        redirectUrl,
                                        style: GoogleFonts.poppins(
                                          fontSize: 12,
                                          color: RealTimeColors.primaryGreen,
                                        ),
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    const Icon(Icons.copy, size: 16),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                    // 🔴 ECOCASH SPECIFIC: Show USSD instructions
                    if (isEcoCash && instructions != null)
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: RealTimeColors.warning.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: RealTimeColors.warning),
                        ),
                        child: Column(
                          children: [
                            const Icon(
                              Icons.phone_android,
                              size: 48,
                              color: RealTimeColors.warning,
                            ),
                            const SizedBox(height: 12),
                            Text(
                              'Complete Payment on Your Phone',
                              style: GoogleFonts.poppins(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textColor,
                              ),
                            ),
                            const SizedBox(height: 16),
                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: AppColors.surfaceColor,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                instructions,
                                style: GoogleFonts.poppins(
                                  fontSize: 14,
                                  color: AppColors.textColor,
                                ),
                              ),
                            ),
                            const SizedBox(height: 20),
                            if (widget.payment.ussdCode != null)
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: AppColors.primaryColor.withOpacity(
                                    0.1,
                                  ),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      'USSD Code:',
                                      style: GoogleFonts.poppins(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    Row(
                                      children: [
                                        Text(
                                          widget.payment.ussdCode!,
                                          style: GoogleFonts.poppins(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                            color: AppColors.primaryColor,
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        IconButton(
                                          icon: const Icon(
                                            Icons.copy,
                                            size: 20,
                                          ),
                                          onPressed: () => _copyToClipboard(
                                            widget.payment.ussdCode!,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                          ],
                        ),
                      ),

                    const SizedBox(height: 20),

                    // Poll URL (for checking status)
                    if (pollUrl != null)
                      Container(
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
                              children: [
                                Icon(
                                  Icons.sync,
                                  size: 20,
                                  color: _isCheckingStatus
                                      ? RealTimeColors.warning
                                      : RealTimeColors.success,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'Payment Status',
                                  style: GoogleFonts.poppins(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            if (_statusMessage != null)
                              Padding(
                                padding: const EdgeInsets.only(bottom: 12),
                                child: Text(
                                  _statusMessage!,
                                  style: GoogleFonts.poppins(
                                    fontSize: 14,
                                    color: RealTimeColors.error,
                                  ),
                                ),
                              ),
                            Row(
                              children: [
                                Expanded(
                                  child: OutlinedButton(
                                    onPressed: _isCheckingStatus
                                        ? null
                                        : _checkPaymentStatus,
                                    style: OutlinedButton.styleFrom(
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 14,
                                      ),
                                    ),
                                    child: _isCheckingStatus
                                        ? const SizedBox(
                                            width: 20,
                                            height: 20,
                                            child: CircularProgressIndicator(
                                              strokeWidth: 2,
                                            ),
                                          )
                                        : const Text('Check Status'),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),

                    const SizedBox(height: 20),

                    // Action buttons
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () {
                              Get.offAllNamed('/my-bid-payments');
                            },
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: const Text('View My Payments'),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
