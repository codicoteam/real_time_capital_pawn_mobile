import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:real_time_pawn/core/utils/pallete.dart';
import 'package:real_time_pawn/features/payments_mngmt/controllers/payments_mngmt_controller.dart';
import 'package:real_time_pawn/features/payments_mngmt/screens/payment_details_screen.dart';

class CreatePaymentScreen extends StatefulWidget {
  final String loanId;
  final double? initialAmount;
  final Map<String, dynamic>?
  chargesData; // Add this to get actual allocation from loan charges

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
  final PaymentController _controller = Get.find<PaymentController>();
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _accountController = TextEditingController();

  String _selectedProvider = 'ecocash'; // Default to EcoCash for Zimbabwe
  String _selectedMethod = 'mobile'; // Default method for mobile money
  double _paymentAmount = 0.0;

  // Zimbabwe-specific payment providers
  final List<Map<String, dynamic>> _providers = [
    {'id': 'ecocash', 'name': 'EcoCash', 'icon': Icons.phone_android},
    {'id': 'onemoney', 'name': 'OneMoney', 'icon': Icons.phone_android},
    {'id': 'telecash', 'name': 'Telecash', 'icon': Icons.phone_android},
    {'id': 'bank', 'name': 'Bank Transfer', 'icon': Icons.account_balance},
    {'id': 'paynow', 'name': 'PayNow (Card)', 'icon': Icons.credit_card},
    {'id': 'cash', 'name': 'Cash', 'icon': Icons.money},
  ];

  // For bank transfers
  final List<Map<String, dynamic>> _bankMethods = [
    {'id': 'rtgs', 'name': 'RTGS Transfer'},
    {'id': 'zipit', 'name': 'ZIPIT'},
    {'id': 'direct', 'name': 'Direct Deposit'},
  ];

  // For EcoCash methods
  final List<Map<String, dynamic>> _ecocashMethods = [
    {'id': 'mobile', 'name': 'Mobile Wallet'},
    {'id': 'ussd', 'name': 'USSD *151#'},
    {'id': 'agent', 'name': 'EcoCash Agent'},
  ];

  String? _selectedBankMethod;
  String? _selectedEcocashMethod = 'mobile'; // Default to mobile wallet

  // Phone validation for Zimbabwe numbers
  bool _isValidZimbabwePhone(String phone) {
    // Remove any non-digit characters
    final cleaned = phone.replaceAll(RegExp(r'[^\d]'), '');

    // Zimbabwe mobile numbers are typically 9 digits starting with 7 or 71-79
    // Format: +263 7X XXX XXXX or 07X XXX XXXX
    if (cleaned.length == 9) {
      return RegExp(r'^7[0-9]{8}$').hasMatch(cleaned);
    } else if (cleaned.length == 10) {
      // If starts with 0 then 7
      return RegExp(r'^07[0-9]{8}$').hasMatch(cleaned);
    } else if (cleaned.length == 12) {
      // If includes +263
      return RegExp(r'^2637[0-9]{9}$').hasMatch(cleaned);
    }
    return false;
  }

  String _formatZimbabwePhone(String phone) {
    // Remove any non-digit characters
    String cleaned = phone.replaceAll(RegExp(r'[^\d]'), '');

    // Convert to international format: +263 7X XXX XXXX
    if (cleaned.startsWith('0')) {
      cleaned = '263' + cleaned.substring(1);
    }

    if (cleaned.startsWith('263') && cleaned.length == 12) {
      // Format as +263 7X XXX XXXX
      return '+${cleaned.substring(0, 3)} ${cleaned.substring(3, 5)} ${cleaned.substring(5, 8)} ${cleaned.substring(8)}';
    } else if (cleaned.length == 9) {
      // Assume it's 7X XXX XXXX
      return '+263 $cleaned';
    }

    return phone; // Return as is if can't format
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
    _accountController.dispose();
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

    // Validate phone number for mobile money
    if (_selectedProvider == 'ecocash' ||
        _selectedProvider == 'onemoney' ||
        _selectedProvider == 'telecash') {
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
          'Please enter a valid Zimbabwe mobile number (e.g., 077 123 4567 or +263 77 123 4567)',
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
      // Default allocation (should be overridden by actual charges)
      final totalAmount = _paymentAmount;
      components = {
        'principalComponent': totalAmount * 0.7,
        'interestComponent': totalAmount * 0.2,
        'storageComponent': totalAmount * 0.05,
        'penaltyComponent': totalAmount * 0.05,
      };
    }

    // Format phone number for API
    String? formattedPhone;
    if (_phoneController.text.isNotEmpty) {
      formattedPhone = _formatZimbabwePhone(_phoneController.text);
    }

    final result = await _controller.createPayment(
      loanId: widget.loanId,
      amount: _paymentAmount,
      provider: _selectedProvider,
      method: _selectedProvider == 'ecocash'
          ? (_selectedEcocashMethod ?? 'mobile')
          : (_selectedBankMethod ?? 'rtgs'),
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
    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Column(
          children: [
            Icon(Icons.check_circle, color: RealTimeColors.success, size: 48),
            const SizedBox(height: 12),
            Text(
              'Payment Initiated!',
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
              'Your payment has been initiated successfully.',
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
                    'Reference:',
                    paymentResult['reference'] ?? 'N/A',
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
                      _formatZimbabwePhone(_phoneController.text),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: RealTimeColors.primaryGreen.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: RealTimeColors.primaryGreen),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.info_outline,
                        size: 16,
                        color: RealTimeColors.primaryGreen,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Important:',
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: RealTimeColors.primaryGreen,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _selectedProvider == 'ecocash'
                        ? 'Please check your EcoCash wallet for a payment request and approve it to complete the transaction.'
                        : 'Your payment is being processed. You will receive a confirmation once completed.',
                    style: GoogleFonts.poppins(
                      fontSize: 11,
                      color: AppColors.textColor,
                    ),
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
              Get.back(); // Go back to previous screen
            },
            child: Text(
              'Done',
              style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Get.back(); // Close dialog
              Get.offAll(
                () => PaymentDetailsScreen(paymentId: paymentResult['_id']),
              );
            },
            child: const Text('Track Payment'),
          ),
        ],
      ),
    );
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
                          'Loan ${widget.loanId.length > 8 ? '${widget.loanId.substring(0, 8)}...' : widget.loanId}',
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

                    // EcoCash Methods
                    if (_selectedProvider == 'ecocash') ...[
                      Text(
                        'EcoCash Payment Method',
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
                        child: Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: _ecocashMethods.map((method) {
                            return _buildEcocashMethodButton(method);
                          }).toList(),
                        ),
                      ),
                      const SizedBox(height: 24),
                    ],

                    // Bank Transfer Methods
                    if (_selectedProvider == 'bank') ...[
                      Text(
                        'Bank Transfer Method',
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
                        child: Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: _bankMethods.map((method) {
                            return _buildBankMethodButton(method);
                          }).toList(),
                        ),
                      ),
                      const SizedBox(height: 24),
                    ],

                    // Mobile Number Input (for mobile money)
                    if (_selectedProvider == 'ecocash' ||
                        _selectedProvider == 'onemoney' ||
                        _selectedProvider == 'telecash') ...[
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
                                labelText: 'Enter Mobile Number',
                                hintText:
                                    'e.g., 077 123 4567 or +263 77 123 4567',
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
                              keyboardType: TextInputType.phone,
                              onChanged: (value) {
                                setState(() {});
                              },
                            ),
                            const SizedBox(height: 8),
                            if (_phoneController.text.isNotEmpty &&
                                !_isValidZimbabwePhone(_phoneController.text))
                              Text(
                                'Enter a valid Zimbabwe mobile number (e.g., 077 123 4567)',
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

                    // Account Number Input (for bank transfers)
                    if (_selectedProvider == 'bank' &&
                        (_selectedBankMethod == 'rtgs' ||
                            _selectedBankMethod == 'direct')) ...[
                      Text(
                        'Account Details',
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
                        child: TextField(
                          controller: _accountController,
                          decoration: InputDecoration(
                            labelText: 'Account Number',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          keyboardType: TextInputType.text,
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

                if (_selectedProvider == 'ecocash' ||
                    _selectedProvider == 'onemoney' ||
                    _selectedProvider == 'telecash') {
                  isValid =
                      isValid &&
                      _phoneController.text.isNotEmpty &&
                      _isValidZimbabwePhone(_phoneController.text);
                }

                if (_selectedProvider == 'bank' &&
                    (_selectedBankMethod == 'rtgs' ||
                        _selectedBankMethod == 'direct')) {
                  isValid = isValid && _accountController.text.isNotEmpty;
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
          _selectedEcocashMethod = 'mobile'; // Reset to default
          _selectedBankMethod = null;
          _phoneController.clear();
          _accountController.clear();
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

  Widget _buildEcocashMethodButton(Map<String, dynamic> method) {
    final isSelected = _selectedEcocashMethod == method['id'];
    return InkWell(
      onTap: () {
        setState(() {
          _selectedEcocashMethod = method['id'];
        });
      },
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primaryColor.withOpacity(0.1)
              : AppColors.surfaceColor,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? AppColors.primaryColor : AppColors.borderColor,
          ),
        ),
        child: Text(
          method['name'],
          style: GoogleFonts.poppins(
            fontSize: 12,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
            color: isSelected ? AppColors.primaryColor : AppColors.textColor,
          ),
        ),
      ),
    );
  }

  Widget _buildBankMethodButton(Map<String, dynamic> method) {
    final isSelected = _selectedBankMethod == method['id'];
    return InkWell(
      onTap: () {
        setState(() {
          _selectedBankMethod = method['id'];
        });
      },
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primaryColor.withOpacity(0.1)
              : AppColors.surfaceColor,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? AppColors.primaryColor : AppColors.borderColor,
          ),
        ),
        child: Text(
          method['name'],
          style: GoogleFonts.poppins(
            fontSize: 12,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
            color: isSelected ? AppColors.primaryColor : AppColors.textColor,
          ),
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
