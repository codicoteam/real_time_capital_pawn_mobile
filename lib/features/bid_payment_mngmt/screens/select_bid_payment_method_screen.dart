import 'package:flutter/material.dart';
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
  State<SelectPaymentMethodScreen> createState() =>
      _SelectPaymentMethodScreenState();
}

class _SelectPaymentMethodScreenState extends State<SelectPaymentMethodScreen> {
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();
  String? _selectedMethodId;
  bool _isProcessing = false;
  bool _isLoading = true;
  // ✅ CORRECTED - Use lowercase values that match API enum
  final List<Map<String, dynamic>> _paymentMethods = [
    {
      'id': 'ecocash',
      'name': 'EcoCash',
      'description': 'Pay instantly using EcoCash mobile money',
      'icon': Icons.phone_android,
      'provider': 'ecocash', // ✅ lowercase
      'method': 'ecocash', // ✅ ADD THIS - lowercase for API
      'requires_phone': true,
    },
    {
      'id': 'paynow',
      'name': 'PayNow',
      'description': 'Pay using PayNow (EcoCash, OneMoney, Telecash)',
      'icon': Icons.payment,
      'provider': 'paynow', // ✅ lowercase
      'method': 'paynow', // ✅ ADD THIS - lowercase for API
      'requires_phone': true,
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
    setState(() {
      _isLoading = true;
    });

    // Still call the API to get methods from server
    await BidPaymentHelper.loadPaymentMethods();

    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _proceedToPayment() async {
    if (_selectedMethodId == null) {
      BidPaymentHelper.showError('Please select a payment method');
      return;
    }

    // Find the selected method from our local list
    final selectedMethod = _paymentMethods.firstWhere(
      (method) => method['id'] == _selectedMethodId,
    );

    // Validate phone number (both EcoCash and PayNow require phone)
    if (_phoneController.text.isEmpty) {
      BidPaymentHelper.showError('Please enter your phone number');
      return;
    }

    if (!BidPaymentHelper.isValidPhoneNumber(_phoneController.text)) {
      BidPaymentHelper.showError('Please enter a valid phone number');
      return;
    }

    setState(() {
      _isProcessing = true;
    });

    try {
      // Navigate to confirm payment screen
      await Get.toNamed(
        '/confirm-payment',
        arguments: {
          'bidId': widget.bidId,
          'amount': widget.amount,
          'methodId': _selectedMethodId!,
          'methodName': selectedMethod['name'],
          // ✅ CRITICAL FIX: Use the lowercase method value for API
          'method': selectedMethod['method'], // ← THIS IS THE KEY FIELD
          'provider': selectedMethod['provider'],
          'payerPhone': BidPaymentHelper.formatPhoneNumber(
            _phoneController.text,
          ),
          'notes': _notesController.text,
        },
      );
    } catch (e) {
      BidPaymentHelper.showError('Navigation error: ${e.toString()}');
    } finally {
      setState(() {
        _isProcessing = false;
      });
    }
  }

  Widget _buildPaymentMethodCard(Map<String, dynamic> method) {
    final isSelected = _selectedMethodId == method['id'];

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: isSelected ? AppColors.primaryColor : AppColors.borderColor,
          width: isSelected ? 2 : 1,
        ),
      ),
      elevation: isSelected ? 4 : 1,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          setState(() {
            _selectedMethodId = method['id'];
          });
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Icon
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: AppColors.primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Icon(
                    method['icon'],
                    color: AppColors.primaryColor,
                    size: 24,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              // Method info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      method['name'],
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textColor,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      method['description'],
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: AppColors.subtextColor,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: RealTimeColors.success.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(
                          color: RealTimeColors.success.withOpacity(0.3),
                        ),
                      ),
                      child: Text(
                        'Recommended',
                        style: GoogleFonts.poppins(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: RealTimeColors.success,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              // Radio button
              Radio<String>(
                value: method['id'],
                groupValue: _selectedMethodId,
                onChanged: (value) {
                  setState(() {
                    _selectedMethodId = value;
                  });
                },
                activeColor: AppColors.primaryColor,
              ),
            ],
          ),
        ),
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
                  Text(
                    'Select Payment Method',
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textColor,
                    ),
                  ),
                ],
              ),
            ),

            // Amount display
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
                  Text(
                    'Amount to Pay',
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      color: AppColors.subtextColor,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    BidPaymentHelper.formatCurrency(widget.amount),
                    style: GoogleFonts.poppins(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primaryColor,
                    ),
                  ),
                ],
              ),
            ),

            // Payment methods
            Expanded(
              child: _isLoading
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CircularProgressIndicator(
                            color: AppColors.primaryColor,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Loading payment methods...',
                            style: GoogleFonts.poppins(
                              fontSize: 14,
                              color: AppColors.subtextColor,
                            ),
                          ),
                        ],
                      ),
                    )
                  : SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // Payment methods list (only EcoCash and PayNow)
                          ..._paymentMethods.map(
                            (method) => _buildPaymentMethodCard(method),
                          ),

                          // Phone number input (required for both)
                          Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 12,
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Phone Number',
                                  style: GoogleFonts.poppins(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.textColor,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                TextField(
                                  controller: _phoneController,
                                  decoration: InputDecoration(
                                    hintText: 'Enter your phone number',
                                    prefixIcon: const Icon(Icons.phone),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide: BorderSide(
                                        color: AppColors.borderColor,
                                      ),
                                    ),
                                    filled: true,
                                    fillColor: AppColors.surfaceColor,
                                  ),
                                  keyboardType: TextInputType.phone,
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Format: +263XXXXXXXXX or 0XXXXXXXXX',
                                  style: GoogleFonts.poppins(
                                    fontSize: 12,
                                    color: AppColors.subtextColor,
                                  ),
                                ),
                              ],
                            ),
                          ),

                          // Notes input
                          Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 12,
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Payment Notes (Optional)',
                                  style: GoogleFonts.poppins(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.textColor,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                TextField(
                                  controller: _notesController,
                                  decoration: InputDecoration(
                                    hintText:
                                        'Add any notes for this payment...',
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide: BorderSide(
                                        color: AppColors.borderColor,
                                      ),
                                    ),
                                    filled: true,
                                    fillColor: AppColors.surfaceColor,
                                  ),
                                  maxLines: 3,
                                ),
                              ],
                            ),
                          ),

                          // Proceed button
                          Padding(
                            padding: const EdgeInsets.all(16),
                            child: ElevatedButton(
                              onPressed: _isProcessing
                                  ? null
                                  : _proceedToPayment,
                              style: ElevatedButton.styleFrom(
                                foregroundColor: Colors.white,
                                backgroundColor: AppColors.primaryColor,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 16,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                disabledBackgroundColor: AppColors.primaryColor
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
                                      'Proceed to Payment',
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
            ),
          ],
        ),
      ),
    );
  }
}
