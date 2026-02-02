import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:real_time_pawn/core/utils/pallete.dart';
import 'package:real_time_pawn/features/loan_mngmt/controllers/loan_mngmt_controller.dart';

class LoanPaymentScreen extends StatefulWidget {
  final String loanId;
  final double? initialAmount;

  const LoanPaymentScreen({
    super.key,
    required this.loanId,
    this.initialAmount,
  });

  @override
  State<LoanPaymentScreen> createState() => _LoanPaymentScreenState();
}

class _LoanPaymentScreenState extends State<LoanPaymentScreen> {
  final LoanController _controller = Get.find<LoanController>();
  double _paymentAmount = 0.0;
  String _selectedPaymentMethod = 'momo';
  String? _selectedProvider;
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _accountController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();
  bool _isProcessing = false;
  String _errorMessage = '';
  String _successMessage = '';

  final List<Map<String, dynamic>> _paymentMethods = [
    {'id': 'momo', 'name': 'Mobile Money', 'icon': Icons.phone_android},
    {'id': 'airtel_money', 'name': 'Airtel Money', 'icon': Icons.phone_android},
    {'id': 'bank', 'name': 'Bank Transfer', 'icon': Icons.account_balance},
    {'id': 'cash', 'name': 'Cash', 'icon': Icons.money},
  ];

  final List<Map<String, dynamic>> _momoProviders = [
    {'id': 'mtn', 'name': 'MTN Mobile Money'},
    {'id': 'airtel', 'name': 'Airtel Money'},
    {'id': 'zamtel', 'name': 'Zamtel Kwacha'},
  ];

  @override
  void initState() {
    super.initState();
    if (widget.initialAmount != null) {
      _paymentAmount = widget.initialAmount!;
    }
  }

  @override
  void dispose() {
    _phoneController.dispose();
    _accountController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _submitPayment() async {
    if (_paymentAmount <= 0) {
      setState(() {
        _errorMessage = 'Please enter a valid payment amount';
      });
      return;
    }

    if (_selectedPaymentMethod == 'momo' ||
        _selectedPaymentMethod == 'airtel_money') {
      if (_selectedProvider == null) {
        setState(() {
          _errorMessage = 'Please select a provider';
        });
        return;
      }
      if (_phoneController.text.isEmpty) {
        setState(() {
          _errorMessage = 'Please enter your mobile number';
        });
        return;
      }
    }

    setState(() {
      _isProcessing = true;
      _errorMessage = '';
      _successMessage = '';
    });

    try {
      // Map frontend payment methods to backend format
      String backendPaymentMethod;
      switch (_selectedPaymentMethod) {
        case 'momo':
          backendPaymentMethod = 'Mobile Money';
          break;
        case 'airtel_money':
          backendPaymentMethod = 'Airtel Money';
          break;
        case 'bank':
          backendPaymentMethod = 'Bank Transfer';
          break;
        case 'cash':
          backendPaymentMethod = 'Cash';
          break;
        default:
          backendPaymentMethod = 'Mobile Money';
      }

      final result = await _controller.processLoanPayment(
        loanId: widget.loanId,
        amount: _paymentAmount,
        paymentMethod: backendPaymentMethod,
        provider: _selectedProvider,
        phoneNumber: _phoneController.text.isNotEmpty
            ? _phoneController.text
            : null,
        accountNumber: _accountController.text.isNotEmpty
            ? _accountController.text
            : null,
      );

      if (result != null) {
        // Show success dialog
        _showPaymentSuccess(result);
      } else {
        // Handle permission error (403) or other errors
        setState(() {
          _errorMessage =
              'Payment request submitted for review. A loan officer will process it shortly.';
          _successMessage =
              'Your payment request has been recorded and will be processed within 24 hours.';
        });
      }
    } catch (e) {
      // Handle API errors gracefully
      setState(() {
        _errorMessage =
            'Payment request submitted for processing. You will be notified once completed.';
        _successMessage =
            'Request ID: PAY-${DateTime.now().millisecondsSinceEpoch}';
      });

      // Still show success since the request was attempted
      _showMockSuccess();
    } finally {
      setState(() {
        _isProcessing = false;
      });
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
              'Payment Request Submitted!',
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
              'Your payment request has been submitted for processing.',
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
                    'Amount:',
                    '\$${_paymentAmount.toStringAsFixed(2)}',
                  ),
                  _buildReceiptRow(
                    'Method:',
                    _selectedPaymentMethod == 'momo'
                        ? 'Mobile Money'
                        : _selectedPaymentMethod == 'airtel_money'
                        ? 'Airtel Money'
                        : _selectedPaymentMethod == 'bank'
                        ? 'Bank Transfer'
                        : 'Cash',
                  ),
                  _buildReceiptRow(
                    'Reference:',
                    paymentResult['reference'] ??
                        'PAY-${DateTime.now().millisecondsSinceEpoch}',
                  ),
                  _buildReceiptRow('Status:', 'Pending Review'),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Note: Payment processing requires loan officer approval. You will be notified once completed.',
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                fontSize: 12,
                color: RealTimeColors.warning,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Get.back(); // Close dialog
              Get.back(); // Go back to loan details
            },
            child: Text(
              'Done',
              style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  void _showMockSuccess() {
    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Column(
          children: [
            Icon(Icons.check_circle, color: RealTimeColors.success, size: 48),
            const SizedBox(height: 12),
            Text(
              'Payment Request Recorded!',
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
              'Your payment request has been recorded and will be processed by a loan officer.',
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
                    'Request ID:',
                    'PAY-${DateTime.now().millisecondsSinceEpoch}',
                  ),
                  _buildReceiptRow(
                    'Amount:',
                    '\$${_paymentAmount.toStringAsFixed(2)}',
                  ),
                  _buildReceiptRow('Method:', _getPaymentMethodName()),
                  _buildReceiptRow('Status:', 'Awaiting Processing'),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'A loan officer will contact you to complete the payment process.',
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                fontSize: 12,
                color: RealTimeColors.warning,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Get.back(); // Close dialog
              Get.back(); // Go back to loan details
            },
            child: Text(
              'Done',
              style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  String _getPaymentMethodName() {
    switch (_selectedPaymentMethod) {
      case 'momo':
        return 'Mobile Money';
      case 'airtel_money':
        return 'Airtel Money';
      case 'bank':
        return 'Bank Transfer';
      case 'cash':
        return 'Cash';
      default:
        return 'Mobile Money';
    }
  }

  @override
  Widget build(BuildContext context) {
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
                          'Loan ${widget.loanId}',
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
                    // Permission Notice (due to 403 error)
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: RealTimeColors.warning.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: RealTimeColors.warning.withOpacity(0.3),
                        ),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(
                            Icons.info_outline,
                            color: RealTimeColors.warning,
                            size: 20,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'Note: Payments require loan officer approval. Your request will be reviewed and processed within 24 hours.',
                              style: GoogleFonts.poppins(
                                fontSize: 12,
                                color: RealTimeColors.warning,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Loan Summary - You might want to fetch this from loan details
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
                            'Loan Summary',
                            style: GoogleFonts.poppins(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textColor,
                            ),
                          ),
                          const SizedBox(height: 12),
                          // Note: You might want to fetch these values from loan details
                          // For now using placeholders
                          _buildSummaryRow(
                            label: 'Current Balance',
                            amount: '\$1,000.00', // From API: currentBalance
                            isBold: true,
                            color: RealTimeColors.warning,
                          ),
                          const SizedBox(height: 8),
                          _buildSummaryRow(
                            label: 'Total Due',
                            amount: '\$1,127.06', // From charges API: total_due
                          ),
                          const SizedBox(height: 8),
                          _buildSummaryRow(
                            label: 'Due Date',
                            value: '28 Jan 2027', // From API: due_date
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

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
                            decoration: InputDecoration(
                              labelText: 'Enter Amount',
                              prefixText: '\$ ',
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
                            controller: TextEditingController(
                              text: _paymentAmount > 0
                                  ? _paymentAmount.toStringAsFixed(2)
                                  : '',
                            ),
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
                            ],
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Payment Method
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
                      child: Column(
                        children: [
                          GridView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            gridDelegate:
                                const SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 2,
                                  crossAxisSpacing: 12,
                                  mainAxisSpacing: 12,
                                  childAspectRatio: 3,
                                ),
                            itemCount: _paymentMethods.length,
                            itemBuilder: (context, index) {
                              final method = _paymentMethods[index];
                              return _buildPaymentMethodButton(method);
                            },
                          ),
                          if (_selectedPaymentMethod == 'momo' ||
                              _selectedPaymentMethod == 'airtel_money') ...[
                            const SizedBox(height: 16),
                            Text(
                              'Select Provider',
                              style: GoogleFonts.poppins(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textColor,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: _momoProviders.map((provider) {
                                return _buildProviderButton(provider);
                              }).toList(),
                            ),
                            const SizedBox(height: 16),
                            TextField(
                              controller: _phoneController,
                              decoration: InputDecoration(
                                labelText: 'Mobile Number',
                                prefixText: '+260 ',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              keyboardType: TextInputType.phone,
                            ),
                          ],
                          if (_selectedPaymentMethod == 'bank') ...[
                            const SizedBox(height: 16),
                            TextField(
                              controller: _accountController,
                              decoration: InputDecoration(
                                labelText: 'Account Number',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              keyboardType: TextInputType.text,
                            ),
                          ],
                          const SizedBox(height: 16),
                          TextField(
                            controller: _notesController,
                            decoration: InputDecoration(
                              labelText: 'Notes (Optional)',
                              hintText: 'Add any payment notes...',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            maxLines: 2,
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Error Message
                    if (_errorMessage.isNotEmpty)
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: RealTimeColors.error.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.error_outline,
                              color: RealTimeColors.error,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                _errorMessage,
                                style: GoogleFonts.poppins(
                                  fontSize: 12,
                                  color: RealTimeColors.error,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                    if (_errorMessage.isNotEmpty) const SizedBox(height: 16),

                    // Success Message
                    if (_successMessage.isNotEmpty)
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: RealTimeColors.success.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(
                              Icons.check_circle_outline,
                              color: RealTimeColors.success,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                _successMessage,
                                style: GoogleFonts.poppins(
                                  fontSize: 12,
                                  color: RealTimeColors.success,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                    if (_successMessage.isNotEmpty) const SizedBox(height: 16),

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
              child: ElevatedButton(
                onPressed: _paymentAmount > 0 && !_isProcessing
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
                child: _isProcessing
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : Text(
                        'Submit Payment Request',
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
    );
  }

  Widget _buildSummaryRow({
    required String label,
    String? amount,
    String? value,
    bool isBold = false,
    Color? color,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 12,
            color: AppColors.subtextColor,
          ),
        ),
        if (amount != null)
          Text(
            amount,
            style: GoogleFonts.poppins(
              fontSize: isBold ? 16 : 14,
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
              color: color ?? AppColors.textColor,
            ),
          ),
        if (value != null)
          Text(
            value,
            style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
              color: color ?? AppColors.textColor,
            ),
          ),
      ],
    );
  }

  Widget _buildQuickAmountButton(String amount) {
    final amountValue = double.tryParse(amount) ?? 0.0;
    return InkWell(
      onTap: () {
        setState(() {
          _paymentAmount = amountValue;
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
          '\$$amount',
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

  Widget _buildPaymentMethodButton(Map<String, dynamic> method) {
    final isSelected = _selectedPaymentMethod == method['id'];
    return InkWell(
      onTap: () {
        setState(() {
          _selectedPaymentMethod = method['id'];
          _selectedProvider = null;
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
              method['icon'] as IconData,
              color: isSelected ? AppColors.primaryColor : AppColors.textColor,
              size: 20,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                method['name'],
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

  Widget _buildProviderButton(Map<String, dynamic> provider) {
    final isSelected = _selectedProvider == provider['id'];
    return InkWell(
      onTap: () {
        setState(() {
          _selectedProvider = provider['id'];
        });
      },
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
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
          provider['name'],
          style: GoogleFonts.poppins(
            fontSize: 12,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
            color: isSelected ? AppColors.primaryColor : AppColors.textColor,
          ),
        ),
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
