import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:real_time_pawn/core/utils/pallete.dart';
import 'package:real_time_pawn/features/bid_payment_mngmt/controllers/bid_payment_mngmt_controller.dart';
import 'package:real_time_pawn/features/bid_payment_mngmt/helpers/bid_payment_mngmt_helper.dart';
import 'package:real_time_pawn/models/bid_payment_model.dart';

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
  final BidPaymentController _controller = Get.find<BidPaymentController>();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();
  String? _selectedMethodId;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadPaymentMethods();
  }

  Future<void> _loadPaymentMethods() async {
    await BidPaymentHelper.loadPaymentMethods();
  }

  Future<void> _proceedToPayment() async {
    if (_selectedMethodId == null) {
      BidPaymentHelper.showError('Please select a payment method');
      return;
    }

    final selectedMethod = _controller.paymentMethods.firstWhere(
      (method) => method.id == _selectedMethodId,
      orElse: () => PaymentMethod(
        id: '',
        name: '',
        description: '',
        supportedCountries: [],
      ),
    );

    if (selectedMethod.id.isEmpty) {
      BidPaymentHelper.showError('Selected payment method not found');
      return;
    }

    // Validate phone number for mobile money
    if (selectedMethod.name.toLowerCase().contains('mobile') ||
        selectedMethod.name.toLowerCase().contains('cash')) {
      if (_phoneController.text.isEmpty) {
        BidPaymentHelper.showError('Please enter your phone number');
        return;
      }

      if (!BidPaymentHelper.isValidPhoneNumber(_phoneController.text)) {
        BidPaymentHelper.showError('Please enter a valid phone number');
        return;
      }
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Navigate to confirm payment screen
      Get.toNamed(
        '/confirm-payment',
        arguments: {
          'bidId': widget.bidId,
          'amount': widget.amount,
          'methodId': _selectedMethodId!,
          'methodName': selectedMethod.name,
          'provider': _getProviderFromMethod(selectedMethod.name),
          'payerPhone': _phoneController.text.isNotEmpty
              ? BidPaymentHelper.formatPhoneNumber(_phoneController.text)
              : '',
          'notes': _notesController.text,
        },
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  String _getProviderFromMethod(String methodName) {
    switch (methodName.toLowerCase()) {
      case 'ecocash':
        return 'ecocash';
      case 'onemoney':
        return 'onemoney';
      case 'telecash':
        return 'telecash';
      case 'cash':
        return 'cash';
      case 'bank transfer':
        return 'bank_transfer';
      default:
        return methodName.toLowerCase().replaceAll(' ', '_');
    }
  }

  Widget _buildPaymentMethodCard(PaymentMethod method) {
    final isSelected = _selectedMethodId == method.id;

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
            _selectedMethodId = method.id;
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
                    _getMethodIcon(method.name),
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
                    Row(
                      children: [
                        Text(
                          method.name,
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textColor,
                          ),
                        ),
                        if (method.isDefault)
                          Padding(
                            padding: const EdgeInsets.only(left: 8),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: RealTimeColors.success.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(4),
                                border: Border.all(
                                  color: RealTimeColors.success.withOpacity(
                                    0.3,
                                  ),
                                ),
                              ),
                              child: Text(
                                'Default',
                                style: GoogleFonts.poppins(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600,
                                  color: RealTimeColors.success,
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      method.description,
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: AppColors.subtextColor,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (method.supportedCountries.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Wrap(
                        spacing: 4,
                        children: method.supportedCountries
                            .map(
                              (country) => Chip(
                                label: Text(
                                  country,
                                  style: GoogleFonts.poppins(fontSize: 10),
                                ),
                                backgroundColor: AppColors.surfaceColor,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 4,
                                  vertical: 0,
                                ),
                                visualDensity: VisualDensity.compact,
                              ),
                            )
                            .toList(),
                      ),
                    ],
                  ],
                ),
              ),
              // Radio button
              Radio<String>(
                value: method.id,
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

  IconData _getMethodIcon(String methodName) {
    switch (methodName.toLowerCase()) {
      case 'ecocash':
        return Icons.phone_android;
      case 'onemoney':
        return Icons.account_balance_wallet;
      case 'telecash':
        return Icons.phone_iphone;
      case 'cash':
        return Icons.money;
      case 'bank transfer':
        return Icons.account_balance;
      default:
        return Icons.payment;
    }
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

            Expanded(
              child: Obx(() {
                if (_controller.isLoadingMethods.value) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (_controller.paymentMethods.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.payment_outlined,
                          size: 64,
                          color: RealTimeColors.grey400,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No Payment Methods',
                          style: GoogleFonts.poppins(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: AppColors.subtextColor,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 32),
                          child: Text(
                            'Payment methods are not available at the moment.',
                            textAlign: TextAlign.center,
                            style: GoogleFonts.poppins(
                              fontSize: 14,
                              color: RealTimeColors.grey500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Payment methods list
                      ..._controller.paymentMethods
                          .map((method) => _buildPaymentMethodCard(method))
                          .toList(),

                      // Phone number input (for mobile payments)
                      if (_selectedMethodId != null &&
                          (_controller.paymentMethods
                                  .firstWhere(
                                    (m) => m.id == _selectedMethodId,
                                    orElse: () => PaymentMethod(
                                      id: '',
                                      name: '',
                                      description: '',
                                      supportedCountries: [],
                                    ),
                                  )
                                  .name
                                  .toLowerCase()
                                  .contains('mobile') ||
                              _controller.paymentMethods
                                  .firstWhere(
                                    (m) => m.id == _selectedMethodId,
                                    orElse: () => PaymentMethod(
                                      id: '',
                                      name: '',
                                      description: '',
                                      supportedCountries: [],
                                    ),
                                  )
                                  .name
                                  .toLowerCase()
                                  .contains('cash')))
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
                                hintText: 'Add any notes for this payment...',
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
                          onPressed: _isLoading ? null : _proceedToPayment,
                          style: ElevatedButton.styleFrom(
                            foregroundColor: Colors.white,
                            backgroundColor: AppColors.primaryColor,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            disabledBackgroundColor: AppColors.primaryColor
                                .withOpacity(0.5),
                          ),
                          child: _isLoading
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
                );
              }),
            ),
          ],
        ),
      ),
    );
  }
}
