import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:real_time_pawn/core/utils/pallete.dart';
import 'package:real_time_pawn/features/bid_payment_mngmt/helpers/bid_payment_mngmt_helper.dart';

class SelectPaymentMethodScreen extends StatefulWidget {
  final String bidId;
  final double amount;

  const SelectPaymentMethodScreen({
    super.key,
    required this.bidId,
    required this.amount,
  });

  @override
  State<SelectPaymentMethodScreen> createState() => _SelectPaymentMethodScreenState();
}

class _SelectPaymentMethodScreenState extends State<SelectPaymentMethodScreen> {
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();
  String? _selectedMethodId;
  bool _isProcessing = false;
  bool _isLoading = true;

  final List<Map<String, dynamic>> _paymentMethods = [
    {
      'id': 'ecocash',
      'name': 'EcoCash',
      'description': 'Mobile money push payment — approve on your phone',
      'icon': Icons.phone_android_rounded,
      'color': RealTimeColors.success,
      'provider': 'ecocash',
      'method': 'ecocash',
      'requires_phone': true,
      'tag': 'Instant',
    },
    {
      'id': 'paynow',
      'name': 'PayNow',
      'description': 'Secure online payment — opens in app browser',
      'icon': Icons.open_in_browser_rounded,
      'color': AppColors.primaryColor,
      'provider': 'paynow',
      'method': 'paynow',
      'requires_phone': false,
      'tag': 'Online',
    },
  ];

  @override
  void initState() {
    super.initState();
    _loadPaymentMethods();
  }

  @override
  void dispose() {
    _phoneController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _loadPaymentMethods() async {
    await BidPaymentHelper.loadPaymentMethods();
    if (mounted) setState(() => _isLoading = false);
  }

  Future<void> _proceedToPayment() async {
    if (_selectedMethodId == null) {
      BidPaymentHelper.showError('Please select a payment method');
      return;
    }

    final selectedMethod = _paymentMethods.firstWhere(
      (m) => m['id'] == _selectedMethodId,
      orElse: () => _paymentMethods.first,
    );

    final requiresPhone = selectedMethod['requires_phone'] == true;
    if (requiresPhone) {
      if (_phoneController.text.isEmpty) {
        BidPaymentHelper.showError('Please enter your EcoCash phone number');
        return;
      }
      if (!BidPaymentHelper.isValidPhoneNumber(_phoneController.text)) {
        BidPaymentHelper.showError('Please enter a valid phone number');
        return;
      }
    }

    if (!mounted) return;
    setState(() => _isProcessing = true);

    try {
      await Get.toNamed(
        '/confirm-payment',
        arguments: {
          'bidId': widget.bidId,
          'amount': widget.amount,
          'methodId': _selectedMethodId!,
          'methodName': selectedMethod['name'],
          'method': selectedMethod['method'],
          'provider': selectedMethod['provider'],
          'payerPhone': requiresPhone
              ? BidPaymentHelper.formatPhoneNumber(_phoneController.text)
              : '',
          'notes': _notesController.text,
        },
      );
    } catch (e) {
      BidPaymentHelper.showError('Navigation error: ${e.toString()}');
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            Expanded(
              child: _isLoading
                  ? Center(child: CircularProgressIndicator(color: AppColors.primaryColor))
                  : SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          _buildAmountCard(),
                          _buildMethodsSection(),
                          if (_selectedMethodId == 'ecocash') _buildPhoneSection(),
                          _buildNotesSection(),
                          _buildProceedButton(),
                          const SizedBox(height: 16),
                        ],
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
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
              'Select Payment Method',
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AppColors.textColor,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAmountCard() {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 20, 16, 8),
      padding: const EdgeInsets.all(24),
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
      child: Column(
        children: [
          Text(
            'Amount to Pay',
            style: GoogleFonts.poppins(
              fontSize: 13,
              color: Colors.white.withValues(alpha: 0.85),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            BidPaymentHelper.formatCurrency(widget.amount),
            style: GoogleFonts.poppins(
              fontSize: 36,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          )
              .animate()
              .fadeIn(duration: 400.ms)
              .scaleXY(begin: 0.85, end: 1.0, duration: 400.ms),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.shield_rounded, size: 14, color: Colors.white.withValues(alpha: 0.8)),
              const SizedBox(width: 5),
              Text(
                'Secured Payment',
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  color: Colors.white.withValues(alpha: 0.8),
                ),
              ),
            ],
          ),
        ],
      ),
    ).animate().fadeIn(duration: 300.ms).slideY(begin: 0.05, end: 0);
  }

  Widget _buildMethodsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 10),
          child: Text(
            'Choose Payment Method',
            style: GoogleFonts.poppins(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: AppColors.textColor,
            ),
          ),
        ),
        ..._paymentMethods.asMap().entries.map(
          (entry) => _buildMethodCard(entry.value, entry.key),
        ),
      ],
    );
  }

  Widget _buildMethodCard(Map<String, dynamic> method, int index) {
    final isSelected = _selectedMethodId == method['id'];
    final color = method['color'] as Color;

    return GestureDetector(
      onTap: () => setState(() => _selectedMethodId = method['id']),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? color.withValues(alpha: 0.06) : AppColors.surfaceColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? color : AppColors.borderColor,
            width: isSelected ? 2 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: isSelected ? color.withValues(alpha: 0.12) : Colors.black.withValues(alpha: 0.04),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            // Icon container
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: isSelected ? color.withValues(alpha: 0.15) : AppColors.backgroundColor,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: isSelected ? color.withValues(alpha: 0.4) : AppColors.borderColor,
                ),
              ),
              child: Icon(method['icon'] as IconData, color: color, size: 26),
            ),

            const SizedBox(width: 14),

            // Text content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        method['name'] as String,
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textColor,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: color.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          method['tag'] as String,
                          style: GoogleFonts.poppins(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            color: color,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 3),
                  Text(
                    method['description'] as String,
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: AppColors.subtextColor,
                    ),
                  ),
                ],
              ),
            ),

            // Radio
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 22,
              height: 22,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected ? color : AppColors.borderColor,
                  width: isSelected ? 0 : 2,
                ),
                color: isSelected ? color : Colors.transparent,
              ),
              child: isSelected
                  ? const Icon(Icons.check_rounded, color: Colors.white, size: 14)
                  : null,
            ),
          ],
        ),
      )
          .animate()
          .fadeIn(delay: (index * 70).ms, duration: 300.ms)
          .slideX(begin: 0.04, end: 0, delay: (index * 70).ms, duration: 300.ms),
    );
  }

  Widget _buildPhoneSection() {
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
          Row(
            children: [
              Icon(Icons.phone_rounded, size: 16, color: RealTimeColors.success),
              const SizedBox(width: 8),
              Text(
                'EcoCash Phone Number',
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          TextField(
            controller: _phoneController,
            keyboardType: TextInputType.phone,
            decoration: InputDecoration(
              hintText: 'e.g. 0771234567 or +263771234567',
              hintStyle: GoogleFonts.poppins(color: AppColors.subtextColor, fontSize: 13),
              prefixIcon: Icon(Icons.phone_android_rounded, color: RealTimeColors.success, size: 20),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: AppColors.borderColor),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: RealTimeColors.success, width: 2),
              ),
              filled: true,
              fillColor: AppColors.backgroundColor,
              contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
            ),
            style: GoogleFonts.poppins(fontSize: 14, color: AppColors.textColor),
          ),
          const SizedBox(height: 6),
          Text(
            'Format: +263XXXXXXXXX or 0XXXXXXXXX',
            style: GoogleFonts.poppins(fontSize: 11, color: AppColors.subtextColor),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 250.ms).slideY(begin: 0.04, end: 0);
  }

  Widget _buildNotesSection() {
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
          Row(
            children: [
              Icon(Icons.notes_rounded, size: 16, color: AppColors.subtextColor),
              const SizedBox(width: 8),
              Text(
                'Payment Notes',
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textColor,
                ),
              ),
              const SizedBox(width: 6),
              Text(
                '(Optional)',
                style: GoogleFonts.poppins(fontSize: 12, color: AppColors.subtextColor),
              ),
            ],
          ),
          const SizedBox(height: 10),
          TextField(
            controller: _notesController,
            maxLines: 2,
            decoration: InputDecoration(
              hintText: 'Add any notes...',
              hintStyle: GoogleFonts.poppins(color: AppColors.subtextColor, fontSize: 13),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: AppColors.borderColor),
              ),
              filled: true,
              fillColor: AppColors.backgroundColor,
              contentPadding: const EdgeInsets.all(14),
            ),
            style: GoogleFonts.poppins(fontSize: 14, color: AppColors.textColor),
          ),
        ],
      ),
    );
  }

  Widget _buildProceedButton() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
      child: ElevatedButton(
        onPressed: _isProcessing ? null : _proceedToPayment,
        style: ElevatedButton.styleFrom(
          foregroundColor: Colors.white,
          backgroundColor: AppColors.primaryColor,
          disabledBackgroundColor: AppColors.primaryColor.withValues(alpha: 0.5),
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
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
                  const Icon(Icons.arrow_forward_rounded, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    'Proceed to Confirm',
                    style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w700),
                  ),
                ],
              ),
      ),
    );
  }
}
