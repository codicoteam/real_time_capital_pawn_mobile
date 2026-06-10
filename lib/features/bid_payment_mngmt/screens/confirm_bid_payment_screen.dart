import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:real_time_pawn/core/utils/pallete.dart';
import 'package:real_time_pawn/features/bid_payment_mngmt/controllers/bid_payment_mngmt_controller.dart';
import 'package:real_time_pawn/features/bid_payment_mngmt/helpers/bid_payment_mngmt_helper.dart';

class ConfirmBidPaymentScreen extends StatefulWidget {
  const ConfirmBidPaymentScreen({super.key});

  @override
  State<ConfirmBidPaymentScreen> createState() => _ConfirmBidPaymentScreenState();
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

    setState(() => _isProcessing = true);

    try {
      final success = await BidPaymentHelper.createPayment(
        bidId: _paymentArgs!['bidId'],
        amount: _paymentArgs!['amount'],
        method: _paymentArgs!['method'],
        provider: _paymentArgs!['provider'],
        payerPhone: _paymentArgs!['payerPhone'],
        notes: _paymentArgs!['notes'],
      );

      if (success) {
        BidPaymentHelper.showSuccess('Payment initiated successfully!');
      } else {
        BidPaymentHelper.showError('Failed to create payment');
        setState(() => _isProcessing = false);
      }
    } catch (e) {
      BidPaymentHelper.showError('Error: ${e.toString()}');
      setState(() => _isProcessing = false);
    }
  }

  IconData _methodIcon(String method) {
    switch (method.toLowerCase()) {
      case 'ecocash':
        return Icons.phone_android_rounded;
      case 'paynow':
        return Icons.open_in_browser_rounded;
      default:
        return Icons.payment_rounded;
    }
  }

  Color _methodColor(String method) {
    switch (method.toLowerCase()) {
      case 'ecocash':
        return RealTimeColors.success;
      case 'paynow':
        return AppColors.primaryColor;
      default:
        return AppColors.primaryColor;
    }
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
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryColor,
                  foregroundColor: Colors.white,
                ),
                child: const Text('Go Back'),
              ),
            ],
          ),
        ),
      );
    }

    final amount = _paymentArgs!['amount'] as double;
    final methodName = _paymentArgs!['methodName'] as String? ?? '';
    final method = _paymentArgs!['method'] as String? ?? '';
    final provider = _paymentArgs!['provider'] as String? ?? '';
    final payerPhone = _paymentArgs!['payerPhone'] as String? ?? '';
    final notes = _paymentArgs!['notes'] as String? ?? '';
    final methodColor = _methodColor(method);

    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            // App Bar
            _buildAppBar(),

            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Hero amount section
                    _buildAmountHero(amount, methodColor, method)
                        .animate()
                        .fadeIn(duration: 350.ms)
                        .slideY(begin: 0.05, end: 0),

                    const SizedBox(height: 20),

                    // Payment method card
                    _buildPaymentMethodCard(methodName, method, provider, payerPhone, methodColor)
                        .animate()
                        .fadeIn(delay: 80.ms, duration: 300.ms)
                        .slideY(begin: 0.05, end: 0, delay: 80.ms),

                    if (notes.isNotEmpty) ...[
                      const SizedBox(height: 12),
                      _buildNotesCard(notes)
                          .animate()
                          .fadeIn(delay: 120.ms, duration: 300.ms),
                    ],

                    const SizedBox(height: 12),

                    // Info card
                    _buildInfoCard(method, methodColor)
                        .animate()
                        .fadeIn(delay: 160.ms, duration: 300.ms),

                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),

            // Bottom action bar
            _buildActionBar(),
          ],
        ),
      ),
    );
  }

  Widget _buildAppBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.surfaceColor,
        border: Border(bottom: BorderSide(color: AppColors.borderColor)),
      ),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Get.back(),
            icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
            color: AppColors.textColor,
          ),
          Expanded(
            child: Text(
              'Confirm Payment',
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AppColors.textColor,
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            margin: const EdgeInsets.only(right: 8),
            decoration: BoxDecoration(
              color: RealTimeColors.success.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: RealTimeColors.success.withValues(alpha: 0.3)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.lock_rounded, size: 12, color: RealTimeColors.success),
                const SizedBox(width: 4),
                Text(
                  'Secure',
                  style: GoogleFonts.poppins(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: RealTimeColors.success,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAmountHero(double amount, Color methodColor, String method) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 20, 16, 0),
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [methodColor, methodColor.withValues(alpha: 0.7)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: methodColor.withValues(alpha: 0.35),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(_methodIcon(method), color: Colors.white, size: 32),
          ),
          const SizedBox(height: 16),
          Text(
            'Amount Due',
            style: GoogleFonts.poppins(
              fontSize: 13,
              color: Colors.white.withValues(alpha: 0.85),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            BidPaymentHelper.formatCurrency(amount),
            style: GoogleFonts.poppins(
              fontSize: 38,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          )
              .animate()
              .fadeIn(delay: 100.ms)
              .scaleXY(begin: 0.85, end: 1.0, delay: 100.ms, duration: 350.ms),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              'Review carefully before confirming',
              style: GoogleFonts.poppins(
                fontSize: 11,
                color: Colors.white.withValues(alpha: 0.9),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentMethodCard(
    String methodName,
    String method,
    String provider,
    String payerPhone,
    Color methodColor,
  ) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: AppColors.surfaceColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderColor),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: methodColor.withValues(alpha: 0.05),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            ),
            child: Row(
              children: [
                Icon(Icons.payment_rounded, size: 16, color: methodColor),
                const SizedBox(width: 8),
                Text(
                  'Payment Details',
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
            child: Column(
              children: [
                // Method row with icon
                Row(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: methodColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(_methodIcon(method), color: methodColor, size: 22),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            BidPaymentHelper.getPaymentMethodDisplayName(methodName),
                            style: GoogleFonts.poppins(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textColor,
                            ),
                          ),
                          Text(
                            provider.toUpperCase(),
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                              color: AppColors.subtextColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: methodColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        method.toUpperCase(),
                        style: GoogleFonts.poppins(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: methodColor,
                        ),
                      ),
                    ),
                  ],
                ),

                if (payerPhone.isNotEmpty) ...[
                  const Divider(height: 24),
                  _detailRow(Icons.phone_rounded, 'Phone Number', payerPhone),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNotesCard(String notes) {
    return Container(
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
          Row(
            children: [
              Icon(Icons.notes_rounded, size: 16, color: AppColors.subtextColor),
              const SizedBox(width: 6),
              Text(
                'Payment Notes',
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.subtextColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            notes,
            style: GoogleFonts.poppins(fontSize: 14, color: AppColors.textColor),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard(String method, Color methodColor) {
    final isPayNow = method.toLowerCase() == 'paynow';
    final infoLines = isPayNow
        ? [
            'You will be redirected to the PayNow secure page',
            'Complete the payment in the browser that opens',
            'Return to this app after payment to check status',
            'Status updates within 60 seconds automatically',
          ]
        : [
            'An EcoCash push notification will be sent to your phone',
            'Approve the payment prompt on your phone',
            'Do not close this app while waiting',
            'Status updates within 60 seconds automatically',
          ];

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: RealTimeColors.warning.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: RealTimeColors.warning.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.info_outline_rounded, color: RealTimeColors.warning, size: 18),
              const SizedBox(width: 8),
              Text(
                'What happens next',
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ...infoLines.map(
            (line) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 3),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.chevron_right_rounded, size: 16, color: RealTimeColors.warning),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      line,
                      style: GoogleFonts.poppins(
                        fontSize: 13,
                        color: AppColors.subtextColor,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _detailRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 15, color: AppColors.subtextColor),
        const SizedBox(width: 8),
        Text(
          label,
          style: GoogleFonts.poppins(fontSize: 13, color: AppColors.subtextColor),
        ),
        const Spacer(),
        Text(
          value,
          style: GoogleFonts.poppins(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: AppColors.textColor,
          ),
        ),
      ],
    );
  }

  Widget _buildActionBar() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
      decoration: BoxDecoration(
        color: AppColors.surfaceColor,
        border: Border(top: BorderSide(color: AppColors.borderColor)),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.06), blurRadius: 12, offset: const Offset(0, -4)),
        ],
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
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: Text(
                'Go Back',
                style: GoogleFonts.poppins(fontSize: 15, fontWeight: FontWeight.w600),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            flex: 2,
            child: ElevatedButton(
              onPressed: _isProcessing ? null : _confirmPayment,
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.white,
                backgroundColor: RealTimeColors.success,
                disabledBackgroundColor: RealTimeColors.success.withValues(alpha: 0.5),
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                elevation: 2,
              ),
              child: _isProcessing
                  ? const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                    )
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.check_circle_rounded, size: 20),
                        const SizedBox(width: 8),
                        Text(
                          'Confirm & Pay',
                          style: GoogleFonts.poppins(fontSize: 15, fontWeight: FontWeight.w700),
                        ),
                      ],
                    ),
            ),
          ),
        ],
      ),
    );
  }
}
