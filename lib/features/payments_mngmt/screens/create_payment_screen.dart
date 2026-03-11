import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:real_time_pawn/config/routers/router.dart';
import 'package:real_time_pawn/core/utils/pallete.dart';
import 'package:real_time_pawn/features/payments_mngmt/controllers/payments_mngmt_controller.dart';
import 'package:url_launcher/url_launcher.dart';

class CreatePaymentScreen extends StatefulWidget {
  final String loanId;
  final double? initialAmount;
  final Map<String, dynamic>? chargesData;

  const CreatePaymentScreen({
    super.key,
    required this.loanId,
    this.initialAmount,
    this.chargesData,
  });

  @override
  State<CreatePaymentScreen> createState() => _CreatePaymentScreenState();
}

class _CreatePaymentScreenState extends State<CreatePaymentScreen> {
  final PaymentController _controller = Get.put(PaymentController());
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();

  String _selectedProvider = 'ecocash';
  double _paymentAmount = 0.0;

  // Simplified providers - only EcoCash and PayNow
  final List<Map<String, dynamic>> _providers = [
    {'id': 'ecocash', 'name': 'EcoCash', 'icon': Icons.phone_android},
    {'id': 'paynow', 'name': 'PayNow', 'icon': Icons.credit_card},
  ];

  // Phone validation for Zimbabwe numbers
  bool _isValidZimbabwePhone(String phone) {
    // Remove any non-digit characters
    final cleaned = phone.replaceAll(RegExp(r'[^\d]'), '');

    // Zimbabwe mobile numbers: exactly 9 digits starting with 7
    if (cleaned.length != 9 || !cleaned.startsWith('7')) {
      return false;
    }

    // Check for valid network prefixes
    final prefix = cleaned.substring(0, 2);
    final validPrefixes = ['77', '78', '79', '71', '73'];
    return validPrefixes.contains(prefix);
  }

  @override
  void initState() {
    super.initState();
    if (widget.initialAmount != null) {
      _paymentAmount = widget.initialAmount!;
      _amountController.text = _paymentAmount.toStringAsFixed(2);
    }
  }

  @override
  void dispose() {
    _amountController.dispose();
    _notesController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _submitPayment() async {
    if (_paymentAmount <= 0) {
      Get.snackbar(
        'Error',
        'Please enter a valid payment amount',
        backgroundColor: RealTimeColors.error,
        colorText: Colors.white,
      );
      return;
    }

    // Validate phone number for EcoCash
    if (_selectedProvider == 'ecocash') {
      if (_phoneController.text.isEmpty) {
        Get.snackbar(
          'Error',
          'Please enter your mobile number',
          backgroundColor: RealTimeColors.error,
          colorText: Colors.white,
        );
        return;
      }

      if (!_isValidZimbabwePhone(_phoneController.text)) {
        Get.snackbar(
          'Error',
          'Please enter a valid Zimbabwe mobile number (e.g., 0771234567)',
          backgroundColor: RealTimeColors.error,
          colorText: Colors.white,
        );
        return;
      }
    }

    // Calculate components based on loan charges or use default allocation
    Map<String, dynamic> components;

    if (widget.chargesData != null) {
      // Use actual charges from loan data
      components = {
        'principalComponent':
            (widget.chargesData!['principal'] as num?)?.toDouble() ?? 0.0,
        'interestComponent':
            (widget.chargesData!['interest_accrued'] as num?)?.toDouble() ??
            0.0,
        'storageComponent':
            (widget.chargesData!['storage_charge'] as num?)?.toDouble() ?? 0.0,
        'penaltyComponent':
            (widget.chargesData!['penalty'] as num?)?.toDouble() ?? 0.0,
      };

      // Adjust components to match payment amount if needed
      final totalCharges = components.values.fold(
        0.0,
        (sum, value) => sum + value,
      );
      if (totalCharges > 0 && _paymentAmount <= totalCharges) {
        // Scale components proportionally
        final scale = _paymentAmount / totalCharges;
        components.forEach((key, value) {
          components[key] = value * scale;
        });
      }
    } else {
      // Default allocation
      final totalAmount = _paymentAmount;
      components = {
        'principalComponent': totalAmount * 0.7,
        'interestComponent': totalAmount * 0.2,
        'storageComponent': totalAmount * 0.05,
        'penaltyComponent': totalAmount * 0.05,
      };
    }

    // Format phone number for API - send in 263 format (12 digits)
    String? formattedPhone;
    if (_selectedProvider == 'ecocash' && _phoneController.text.isNotEmpty) {
      // Extract just the 9 digits
      final cleanedPhone = _phoneController.text.replaceAll(
        RegExp(r'[^\d]'),
        '',
      );

      if (cleanedPhone.length == 9 && cleanedPhone.startsWith('7')) {
        // ✅ FIX: Send as 263 + 9 digits (12 digits total)
        formattedPhone = '263$cleanedPhone'; // e.g., "263780197542"
      } else {
        Get.snackbar(
          'Invalid Phone Number',
          'Please enter a valid 9-digit Zimbabwe mobile number starting with 7 (e.g., 780197542)',
          backgroundColor: RealTimeColors.error,
          colorText: Colors.white,
        );
        return;
      }
    }

    // Set payment method based on provider
    String paymentMethod;
    if (_selectedProvider == 'ecocash') {
      paymentMethod = 'ecocash';
    } else if (_selectedProvider == 'paynow') {
      paymentMethod = 'card';
    } else {
      paymentMethod = _selectedProvider;
    }

    final result = await _controller.createPayment(
      loanId: widget.loanId,
      loanTermId: widget.loanId,
      amount: _paymentAmount,
      provider: _selectedProvider,
      method: paymentMethod,
      interestComponent: components['interestComponent'],
      principalComponent: components['principalComponent'],
      storageComponent: components['storageComponent'],
      penaltyComponent: components['penaltyComponent'],
      notes: _notesController.text.isNotEmpty ? _notesController.text : null,
      phoneNumber: formattedPhone,
    );

    if (result != null) {
      _showPaymentSuccess(result);
    }
  }

  void _showPaymentSuccess(Map<String, dynamic> paymentResult) {
    // Extract payment data
    final paymentData = paymentResult['payment'] ?? paymentResult;
    final isPayNow = _selectedProvider == 'paynow';

    // Get the redirect URL for PayNow
    final String? redirectUrl =
        paymentResult['redirect_url'] ?? paymentData['meta']?['redirect_url'];

    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Column(
          children: [
            Icon(
              isPayNow ? Icons.launch : Icons.check_circle,
              color: isPayNow ? Colors.orange : RealTimeColors.success,
              size: 48,
            ),
            const SizedBox(height: 12),
            Text(
              isPayNow ? 'Complete Payment' : 'Payment Initiated!',
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppColors.textColor,
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              isPayNow
                  ? 'Click the button below to complete your payment on the PayNow secure page.'
                  : 'Please check your EcoCash wallet and approve the payment request.',
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: AppColors.subtextColor,
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.surfaceColor,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                children: [
                  _buildReceiptRow(
                    'Receipt No:',
                    paymentData['receipt_no'] ??
                        paymentData['paynow_invoice_id'] ??
                        'N/A',
                  ),
                  _buildReceiptRow(
                    'Payment ID:',
                    paymentData['_id']?.substring(0, 8) ?? 'N/A',
                  ),
                  _buildReceiptRow(
                    'Amount:',
                    'USD \$${_paymentAmount.toStringAsFixed(2)}',
                  ),
                  _buildReceiptRow('Status:', 'Pending'),
                  if (_selectedProvider == 'ecocash' &&
                      _phoneController.text.isNotEmpty)
                    _buildReceiptRow(
                      'Mobile:',
                      '+263 ${_phoneController.text}',
                    ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Get.back(); // Close dialog
              Get.back(); // Go back
            },
            child: Text('Cancel', style: GoogleFonts.poppins()),
          ),
          if (isPayNow && redirectUrl != null)
            ElevatedButton(
              onPressed: () {
                Get.back(); // Close dialog
                _openPayNowUrl(redirectUrl, paymentData['_id']);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                foregroundColor: Colors.white,
              ),
              child: const Text('Pay Now'),
            )
          else
            ElevatedButton(
              onPressed: () {
                Get.back(); // Close dialog
                Get.toNamed(
                  RoutesHelper.PaymentDetailsScreen,
                  arguments: {'paymentId': paymentData['_id']},
                );
              },
              child: const Text('Track Payment'),
            ),
        ],
      ),
    );
  }

  // Add this new method RIGHT AFTER _showPaymentSuccess (around line 270)
  void _openPayNowUrl(String url, String paymentId) async {
    final Uri uri = Uri.parse(url);

    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
      // After returning from browser, go to payment details
      Get.toNamed(
        RoutesHelper.PaymentDetailsScreen,
        arguments: {'paymentId': paymentId},
      );
    } else {
      Get.snackbar('Error', 'Could not open payment page');
    }
  }

  @override
  Widget build(BuildContext context) {
    // Calculate allocation percentages for display
    final Map<String, double> allocationPercentages = {
      'principal': 70.0,
      'interest': 20.0,
      'storage': 5.0,
      'penalty': 5.0,
    };

    if (widget.chargesData != null) {
      // Calculate actual percentages from charges data
      final total =
          (widget.chargesData!['total_due'] as num?)?.toDouble() ??
          _paymentAmount;
      if (total > 0) {
        allocationPercentages['principal'] =
            ((widget.chargesData!['principal'] as num?)?.toDouble() ?? 0.0) /
            total *
            100;
        allocationPercentages['interest'] =
            ((widget.chargesData!['interest_accrued'] as num?)?.toDouble() ??
                0.0) /
            total *
            100;
        allocationPercentages['storage'] =
            ((widget.chargesData!['storage_charge'] as num?)?.toDouble() ??
                0.0) /
            total *
            100;
        allocationPercentages['penalty'] =
            ((widget.chargesData!['penalty'] as num?)?.toDouble() ?? 0.0) /
            total *
            100;
      }
    }

    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
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
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Make Payment',
                          style: GoogleFonts.poppins(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textColor,
                          ),
                        ),
                        Text(
                          Get.arguments['loanNo'] != null
                              ? 'Loan ${Get.arguments['loanNo']}'
                              : 'Loan ${widget.loanId.length > 8 ? '${widget.loanId.substring(0, 8)}...' : widget.loanId}',
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            color: AppColors.subtextColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Payment Amount
                    Text(
                      'Payment Amount',
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textColor,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceColor,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppColors.borderColor),
                      ),
                      child: Column(
                        children: [
                          TextField(
                            controller: _amountController,
                            decoration: InputDecoration(
                              labelText: 'Enter Amount',
                              prefixText: 'USD \$ ',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            keyboardType: TextInputType.numberWithOptions(
                              decimal: true,
                            ),
                            style: GoogleFonts.poppins(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                            ),
                            onChanged: (value) {
                              setState(() {
                                _paymentAmount = double.tryParse(value) ?? 0.0;
                              });
                            },
                          ),
                          const SizedBox(height: 12),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: [
                              _buildQuickAmountButton('50'),
                              _buildQuickAmountButton('100'),
                              _buildQuickAmountButton('200'),
                              _buildQuickAmountButton('500'),
                              _buildQuickAmountButton('1000'),
                              if (widget.chargesData != null &&
                                  (widget.chargesData!['total_due'] as num?)
                                          ?.toDouble() !=
                                      null)
                                _buildQuickAmountButton(
                                  (widget.chargesData!['total_due'] as num)
                                      .toDouble()
                                      .toStringAsFixed(0),
                                ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Payment Provider
                    Text(
                      'Payment Method',
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textColor,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceColor,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppColors.borderColor),
                      ),
                      child: GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              crossAxisSpacing: 12,
                              mainAxisSpacing: 12,
                              childAspectRatio: 2.5,
                            ),
                        itemCount: _providers.length,
                        itemBuilder: (context, index) {
                          final provider = _providers[index];
                          return _buildProviderButton(provider);
                        },
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Mobile Number Input (only for EcoCash)
                    if (_selectedProvider == 'ecocash') ...[
                      Text(
                        'Mobile Number',
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textColor,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppColors.surfaceColor,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: AppColors.borderColor),
                        ),
                        child: Column(
                          children: [
                            TextField(
                              controller: _phoneController,
                              decoration: InputDecoration(
                                labelText: 'Mobile Number',
                                hintText: '780197542',
                                prefixText: '+263 ',
                                prefixStyle: GoogleFonts.poppins(
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.textColor,
                                ),
                                prefixIcon: const Icon(Icons.phone),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                suffixIcon: _phoneController.text.isNotEmpty
                                    ? IconButton(
                                        icon: Icon(
                                          _isValidZimbabwePhone(
                                                _phoneController.text,
                                              )
                                              ? Icons.check_circle
                                              : Icons.error,
                                          color:
                                              _isValidZimbabwePhone(
                                                _phoneController.text,
                                              )
                                              ? RealTimeColors.success
                                              : RealTimeColors.error,
                                        ),
                                        onPressed: () {},
                                      )
                                    : null,
                              ),
                              keyboardType: TextInputType.number,
                              maxLength: 9,
                              buildCounter:
                                  (
                                    context, {
                                    required currentLength,
                                    required isFocused,
                                    maxLength,
                                  }) => null,
                              onChanged: (value) {
                                // Remove any spaces or non-digits
                                final cleaned = value.replaceAll(
                                  RegExp(r'[^\d]'),
                                  '',
                                );
                                // Update controller with cleaned value
                                if (cleaned != value) {
                                  _phoneController.value = TextEditingValue(
                                    text: cleaned,
                                    selection: TextSelection.collapsed(
                                      offset: cleaned.length,
                                    ),
                                  );
                                }
                                setState(() {});
                              },
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Enter 9-digit number starting with 7 (e.g., 780197542)',
                              style: GoogleFonts.poppins(
                                fontSize: 11,
                                color: AppColors.subtextColor,
                              ),
                            ),
                            if (_phoneController.text.isNotEmpty &&
                                !_isValidZimbabwePhone(_phoneController.text))
                              Text(
                                'Number must be 9 digits starting with 7',
                                style: GoogleFonts.poppins(
                                  fontSize: 11,
                                  color: RealTimeColors.error,
                                ),
                              ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                    ],

                    // Notes
                    Container(
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
                            'Payment Notes (Optional)',
                            style: GoogleFonts.poppins(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textColor,
                            ),
                          ),
                          const SizedBox(height: 12),
                          TextField(
                            controller: _notesController,
                            decoration: InputDecoration(
                              hintText: 'Add any payment notes...',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            maxLines: 3,
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Allocation Preview
                    Container(
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
                            'Payment Allocation',
                            style: GoogleFonts.poppins(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textColor,
                            ),
                          ),
                          const SizedBox(height: 12),
                          _buildAllocationRow(
                            'Principal',
                            '\$${(_paymentAmount * allocationPercentages['principal']! / 100).toStringAsFixed(2)}',
                            allocationPercentages['principal']!.toInt(),
                            color: AppColors.primaryColor,
                          ),
                          _buildAllocationRow(
                            'Interest',
                            '\$${(_paymentAmount * allocationPercentages['interest']! / 100).toStringAsFixed(2)}',
                            allocationPercentages['interest']!.toInt(),
                            color: RealTimeColors.warning,
                          ),
                          _buildAllocationRow(
                            'Storage',
                            '\$${(_paymentAmount * allocationPercentages['storage']! / 100).toStringAsFixed(2)}',
                            allocationPercentages['storage']!.toInt(),
                            color: AppColors.primaryColor.withOpacity(0.7),
                          ),
                          _buildAllocationRow(
                            'Penalty',
                            '\$${(_paymentAmount * allocationPercentages['penalty']! / 100).toStringAsFixed(2)}',
                            allocationPercentages['penalty']!.toInt(),
                            color: RealTimeColors.error,
                          ),
                          const SizedBox(height: 12),
                          Divider(color: AppColors.borderColor),
                          const SizedBox(height: 12),
                          _buildAllocationRow(
                            'Total Payment',
                            'USD \$${_paymentAmount.toStringAsFixed(2)}',
                            100,
                            isTotal: true,
                            color: AppColors.primaryColor,
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),

            // Pay Button
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.surfaceColor,
                border: Border(top: BorderSide(color: AppColors.borderColor)),
              ),
              child: Obx(() {
                // Validate button state
                bool isValid = _paymentAmount > 0;

                if (_selectedProvider == 'ecocash') {
                  isValid =
                      isValid &&
                      _phoneController.text.isNotEmpty &&
                      _isValidZimbabwePhone(_phoneController.text);
                }

                return ElevatedButton(
                  onPressed: isValid && !_controller.isProcessingPayment.value
                      ? _submitPayment
                      : null,
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.white,
                    backgroundColor: AppColors.primaryColor,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    disabledBackgroundColor: AppColors.primaryColor.withOpacity(
                      0.5,
                    ),
                  ),
                  child: _controller.isProcessingPayment.value
                      ? SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : Text(
                          'Proceed to Payment - USD \$${_paymentAmount.toStringAsFixed(2)}',
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                );
              }),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickAmountButton(String amount) {
    final amountValue = double.tryParse(amount) ?? 0.0;
    return InkWell(
      onTap: () {
        setState(() {
          _paymentAmount = amountValue;
          _amountController.text = _paymentAmount.toStringAsFixed(2);
        });
      },
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: _paymentAmount == amountValue
              ? AppColors.primaryColor.withOpacity(0.1)
              : AppColors.surfaceColor,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: _paymentAmount == amountValue
                ? AppColors.primaryColor
                : AppColors.borderColor,
          ),
        ),
        child: Text(
          'USD \$$amount',
          style: GoogleFonts.poppins(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: _paymentAmount == amountValue
                ? AppColors.primaryColor
                : AppColors.textColor,
          ),
        ),
      ),
    );
  }

  Widget _buildProviderButton(Map<String, dynamic> provider) {
    final isSelected = _selectedProvider == provider['id'];
    return InkWell(
      onTap: () {
        setState(() {
          _selectedProvider = provider['id'];
          _phoneController.clear();
        });
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primaryColor.withOpacity(0.1)
              : AppColors.surfaceColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? AppColors.primaryColor : AppColors.borderColor,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Icon(
              provider['icon'] as IconData,
              color: isSelected ? AppColors.primaryColor : AppColors.textColor,
              size: 20,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                provider['name'],
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: isSelected
                      ? AppColors.primaryColor
                      : AppColors.textColor,
                ),
              ),
            ),
            if (isSelected)
              Icon(Icons.check_circle, color: AppColors.primaryColor, size: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildAllocationRow(
    String label,
    String amount,
    int percentage, {
    bool isTotal = false,
    Color color = AppColors.textColor,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: isTotal ? 16 : 14,
              fontWeight: isTotal ? FontWeight.w600 : FontWeight.normal,
              color: isTotal ? AppColors.textColor : AppColors.textColor,
            ),
          ),
          Row(
            children: [
              if (!isTotal)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    '$percentage%',
                    style: GoogleFonts.poppins(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: color,
                    ),
                  ),
                ),
              if (!isTotal) const SizedBox(width: 8),
              Text(
                amount,
                style: GoogleFonts.poppins(
                  fontSize: isTotal ? 18 : 14,
                  fontWeight: isTotal ? FontWeight.bold : FontWeight.w500,
                  color: isTotal ? AppColors.primaryColor : color,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildReceiptRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 12,
              color: AppColors.subtextColor,
            ),
          ),
          Text(
            value,
            style: GoogleFonts.poppins(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppColors.textColor,
            ),
          ),
        ],
      ),
    );
  }
}
