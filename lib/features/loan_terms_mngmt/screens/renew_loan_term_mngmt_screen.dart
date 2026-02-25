// lib/features/loan_terms_mngmt/screens/renew_loan_term_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:real_time_pawn/config/routers/router.dart';
import 'package:real_time_pawn/core/utils/pallete.dart';
import 'package:real_time_pawn/features/loan_terms_mngmt/controllers/loan_terms_mngmt_controller.dart';
import 'package:real_time_pawn/models/loan_terms_model.dart';
import 'package:real_time_pawn/widgets/text_fields/custom_text_field.dart';

class RenewLoanTermScreen extends StatefulWidget {
  final String loanId;
  final LoanTerm? currentTerm;

  const RenewLoanTermScreen({
    super.key,
    required this.loanId,
    required this.currentTerm,
  });

  @override
  State<RenewLoanTermScreen> createState() => _RenewLoanTermScreenState();
}

class _RenewLoanTermScreenState extends State<RenewLoanTermScreen> {
  final LoanTermsController _controller = Get.find<LoanTermsController>();
  final TextEditingController _principalController = TextEditingController();
  final TextEditingController _extensionDaysController =
      TextEditingController();
  final TextEditingController _interestRateController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();
  final TextEditingController _reasonController = TextEditingController();

  String _renewalType = 'full';
  String _nextTermNo = '1';
  bool _isCalculating = false;
  bool _isSubmitting = false;
  Map<String, dynamic>? _calculationResult;

  @override
  void initState() {
    super.initState();
    _initializeForm();
    _getNextTermNumber();
  }

  @override
  void dispose() {
    _principalController.dispose();
    _extensionDaysController.dispose();
    _interestRateController.dispose();
    _notesController.dispose();
    _reasonController.dispose();
    super.dispose();
  }

  Future<void> _initializeForm() async {
    if (widget.currentTerm != null) {
      // Pre-fill form with current term values
      _principalController.text = widget.currentTerm!.currentBalance
          .toStringAsFixed(2);
      _extensionDaysController.text = '30'; // Default 30 days extension
      _interestRateController.text = widget.currentTerm!.interestRatePercent
          .toStringAsFixed(2);
    }
  }

  Future<void> _getNextTermNumber() async {
    final nextTerm = await _controller.getNextTermNumber(widget.loanId);
    if (nextTerm != null) {
      setState(() {
        _nextTermNo = nextTerm;
      });
    }
  }

  Future<void> _calculateRenewal() async {
    if (!_validateForm()) return;

    setState(() {
      _isCalculating = true;
      _calculationResult = null;
    });

    // Simulate calculation delay
    await Future.delayed(const Duration(seconds: 1));

    final principal = double.tryParse(_principalController.text) ?? 0;
    final extensionDays = int.tryParse(_extensionDaysController.text) ?? 30;
    final interestRate =
        double.tryParse(_interestRateController.text) ??
        widget.currentTerm?.interestRatePercent ??
        5.0;

    // Calculate new values
    final interestAmount = (principal * interestRate) / 100;
    final totalAmount = principal + interestAmount;
    final dailyInterest = interestAmount / extensionDays;

    setState(() {
      _calculationResult = {
        'principal': principal,
        'extension_days': extensionDays,
        'interest_rate': interestRate,
        'interest_amount': interestAmount,
        'total_amount': totalAmount,
        'daily_interest': dailyInterest,
        'new_end_date': DateTime.now().add(Duration(days: extensionDays)),
      };
      _isCalculating = false;
    });
  }

  bool _validateForm() {
    if (_principalController.text.isEmpty) {
      Get.snackbar(
        'Validation Error',
        'Please enter the principal amount',
        backgroundColor: Colors.red[50],
        colorText: Colors.red[700],
        snackPosition: SnackPosition.TOP,
      );
      return false;
    }

    if (_extensionDaysController.text.isEmpty) {
      Get.snackbar(
        'Validation Error',
        'Please enter extension days',
        backgroundColor: Colors.red[50],
        colorText: Colors.red[700],
        snackPosition: SnackPosition.TOP,
      );
      return false;
    }

    final principal = double.tryParse(_principalController.text);
    if (principal == null || principal <= 0) {
      Get.snackbar(
        'Validation Error',
        'Please enter a valid principal amount',
        backgroundColor: Colors.red[50],
        colorText: Colors.red[700],
        snackPosition: SnackPosition.TOP,
      );
      return false;
    }

    final extensionDays = int.tryParse(_extensionDaysController.text);
    if (extensionDays == null || extensionDays < 1) {
      Get.snackbar(
        'Validation Error',
        'Please enter valid extension days (minimum 1 day)',
        backgroundColor: Colors.red[50],
        colorText: Colors.red[700],
        snackPosition: SnackPosition.TOP,
      );
      return false;
    }

    return true;
  }

  Future<void> _submitRenewalRequest() async {
    if (!_validateForm()) return;
    if (_calculationResult == null) {
      Get.snackbar(
        'Info',
        'Please calculate renewal first',
        snackPosition: SnackPosition.TOP,
      );
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      final request = RenewalRequest(
        loanId: widget.loanId,
        currentTermId: widget.currentTerm?.id ?? '',
        newPrincipal: double.parse(_principalController.text),
        extensionDays: int.parse(_extensionDaysController.text),
        renewalType: _renewalType,
        notes: _notesController.text.isNotEmpty ? _notesController.text : null,
        reason: _reasonController.text.isNotEmpty
            ? _reasonController.text
            : null,
        interestRate: double.tryParse(_interestRateController.text),
        storageChargeRate: null, // Add if applicable
        penaltyRate: null, // Add if applicable
      );

      final success = await _controller.requestLoanRenewal(request);

      if (success) {
        Get.snackbar(
          'Success',
          'Renewal request submitted successfully',
          backgroundColor: Colors.green[50],
          colorText: Colors.green[700],
          snackPosition: SnackPosition.TOP,
          duration: const Duration(seconds: 3),
        );

        // Navigate back after successful submission
        await Future.delayed(const Duration(seconds: 2));
        Get.until(
          (route) => route.settings.name == RoutesHelper.loanTermsScreen,
        );
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to submit renewal request: ${e.toString()}',
        backgroundColor: Colors.red[50],
        colorText: Colors.red[700],
        snackPosition: SnackPosition.TOP,
      );
    } finally {
      setState(() {
        _isSubmitting = false;
      });
    }
  }

  String _formatAmount(double amount) {
    return 'ZWL ${amount.toStringAsFixed(2)}';
  }

  String _formatDate(DateTime date) {
    final format = DateFormat('dd MMM yyyy');
    return format.format(date);
  }

  Widget _buildCurrentTermCard() {
    if (widget.currentTerm == null) return const SizedBox();

    final term = widget.currentTerm!;

    return Container(
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
            'Current Term Details',
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.textColor,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Term ${term.termNo}',
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: AppColors.textColor,
                      ),
                    ),
                    Text(
                      'Ends: ${_formatDate(term.endDate)}',
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: AppColors.subtextColor,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      'Balance',
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: AppColors.subtextColor,
                      ),
                    ),
                    Text(
                      term.formattedCurrentBalance,
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: RealTimeColors.warning,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Divider(color: AppColors.borderColor, height: 1),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Interest Rate',
                      style: GoogleFonts.poppins(
                        fontSize: 10,
                        color: AppColors.subtextColor,
                      ),
                    ),
                    Text(
                      term.formattedInterestRate,
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: AppColors.textColor,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      'Duration',
                      style: GoogleFonts.poppins(
                        fontSize: 10,
                        color: AppColors.subtextColor,
                      ),
                    ),
                    Text(
                      term.formattedTermDuration,
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: AppColors.textColor,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      'Status',
                      style: GoogleFonts.poppins(
                        fontSize: 10,
                        color: AppColors.subtextColor,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: term.isActive
                            ? RealTimeColors.success.withOpacity(0.1)
                            : RealTimeColors.warning.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        term.status.toUpperCase(),
                        style: GoogleFonts.poppins(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: term.isActive
                              ? RealTimeColors.success
                              : RealTimeColors.warning,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRenewalTypeSelector() {
    return Container(
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
            'Renewal Type',
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.textColor,
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _buildRenewalTypeChip(
                'Full',
                'full',
                'Renew full balance',
                Icons.autorenew_outlined,
              ),
              _buildRenewalTypeChip(
                'Partial',
                'partial',
                'Renew partial amount',
                Icons
                    .pie_chart_outline, // FIXED: Changed from partial_chart_outlined to pie_chart_outlined
              ),
              _buildRenewalTypeChip(
                'Interest Only',
                'interest_only',
                'Extend interest only',
                Icons.percent_outlined,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRenewalTypeChip(
    String label,
    String value,
    String description,
    IconData icon,
  ) {
    final isSelected = _renewalType == value;

    return GestureDetector(
      onTap: () {
        setState(() {
          _renewalType = value;
        });
      },
      child: Container(
        width: 150,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primaryColor : AppColors.surfaceColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? AppColors.primaryColor : AppColors.borderColor,
          ),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              size: 24,
              color: isSelected ? Colors.white : AppColors.primaryColor,
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: isSelected ? Colors.white : AppColors.textColor,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              description,
              style: GoogleFonts.poppins(
                fontSize: 10,
                color: isSelected
                    ? Colors.white.withOpacity(0.8)
                    : AppColors.subtextColor,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCalculationResult() {
    if (_calculationResult == null) return const SizedBox();

    return Container(
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
              Icon(
                Icons.calculate_outlined,
                color: AppColors.primaryColor,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'Renewal Calculation',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'New Term Number',
                      style: GoogleFonts.poppins(
                        fontSize: 10,
                        color: AppColors.subtextColor,
                      ),
                    ),
                    Text(
                      _nextTermNo,
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: RealTimeColors.primaryGreen,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      'New End Date',
                      style: GoogleFonts.poppins(
                        fontSize: 10,
                        color: AppColors.subtextColor,
                      ),
                    ),
                    Text(
                      _formatDate(
                        _calculationResult!['new_end_date'] as DateTime,
                      ),
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textColor,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Divider(color: AppColors.borderColor, height: 1),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildCalculationItem(
                  label: 'Principal',
                  amount: _formatAmount(
                    _calculationResult!['principal'] as double,
                  ),
                  color: AppColors.textColor,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildCalculationItem(
                  label: 'Interest',
                  amount: _formatAmount(
                    _calculationResult!['interest_amount'] as double,
                  ),
                  color: RealTimeColors.warning,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.backgroundColor,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: RealTimeColors.success.withOpacity(0.3),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.account_balance_wallet_outlined,
                  size: 16,
                  color: RealTimeColors.success,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Total Amount Due',
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          color: AppColors.subtextColor,
                        ),
                      ),
                      Text(
                        _formatAmount(
                          _calculationResult!['total_amount'] as double,
                        ),
                        style: GoogleFonts.poppins(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: RealTimeColors.success,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: Text(
                  'Extension: ${_calculationResult!['extension_days']} days',
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: AppColors.subtextColor,
                  ),
                ),
              ),
              Text(
                'Daily Interest: ${_formatAmount(_calculationResult!['daily_interest'] as double)}',
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  color: AppColors.subtextColor,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCalculationItem({
    required String label,
    required String amount,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.backgroundColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.borderColor.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 10,
              color: AppColors.subtextColor,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            amount,
            style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
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
                          'Renew Loan Term',
                          style: GoogleFonts.poppins(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textColor,
                          ),
                        ),
                        Text(
                          'Request a loan renewal',
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

            // Main Content
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Current Term Card
                    _buildCurrentTermCard()
                        .animate()
                        .fadeIn(duration: 600.ms)
                        .slideY(begin: 0.3),

                    const SizedBox(height: 20),

                    // Renewal Type Selector
                    _buildRenewalTypeSelector()
                        .animate()
                        .fadeIn(duration: 600.ms, delay: 200.ms)
                        .slideY(begin: 0.3),

                    const SizedBox(height: 20),

                    // Renewal Form
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceColor,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppColors.borderColor),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Text(
                            'Renewal Details',
                            style: GoogleFonts.poppins(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textColor,
                            ),
                          ).animate().fadeIn(duration: 600.ms, delay: 400.ms),
                          const SizedBox(height: 16),

                          // Principal Amount
                          CustomTextField(
                                controller: _principalController,
                                labelText: 'Principal Amount (ZWL)',
                                focusedBorderColor: AppColors.primaryColor,
                                fillColor: AppColors.surfaceColor,
                                keyboardType: TextInputType.number,
                                prefixIcon: Icon(
                                  Icons.account_balance_wallet_outlined,
                                  color: AppColors.subtextColor,
                                ),
                                // REMOVED: suffixText: 'ZWL' if your CustomTextField doesn't support it
                              )
                              .animate()
                              .fadeIn(duration: 600.ms, delay: 500.ms)
                              .slideY(begin: 0.3),

                          const SizedBox(height: 16),

                          // Extension Days
                          CustomTextField(
                                controller: _extensionDaysController,
                                labelText: 'Extension Days',
                                focusedBorderColor: AppColors.primaryColor,
                                fillColor: AppColors.surfaceColor,
                                keyboardType: TextInputType.number,
                                prefixIcon: Icon(
                                  Icons.calendar_today_outlined,
                                  color: AppColors.subtextColor,
                                ),
                                // REMOVED: suffixText: 'days' if your CustomTextField doesn't support it
                              )
                              .animate()
                              .fadeIn(duration: 600.ms, delay: 600.ms)
                              .slideY(begin: 0.3),

                          const SizedBox(height: 16),

                          // Interest Rate
                          CustomTextField(
                                controller: _interestRateController,
                                labelText: 'Interest Rate (%)',
                                focusedBorderColor: AppColors.primaryColor,
                                fillColor: AppColors.surfaceColor,
                                keyboardType: TextInputType.number,
                                prefixIcon: Icon(
                                  Icons.percent_outlined,
                                  color: AppColors.subtextColor,
                                ),
                                // REMOVED: suffixText: '%' if your CustomTextField doesn't support it
                              )
                              .animate()
                              .fadeIn(duration: 600.ms, delay: 700.ms)
                              .slideY(begin: 0.3),

                          const SizedBox(height: 16),

                          // Renewal Reason
                          CustomTextField(
                                controller: _reasonController,
                                labelText: 'Renewal Reason (Optional)',
                                focusedBorderColor: AppColors.primaryColor,
                                fillColor: AppColors.surfaceColor,
                                // REMOVED: maxLines: 3 if your CustomTextField doesn't support it
                                prefixIcon: Icon(
                                  Icons.receipt_long_outlined,
                                  color: AppColors.subtextColor,
                                ),
                              )
                              .animate()
                              .fadeIn(duration: 600.ms, delay: 800.ms)
                              .slideY(begin: 0.3),

                          const SizedBox(height: 16),

                          // Additional Notes
                          CustomTextField(
                                controller: _notesController,
                                labelText: 'Additional Notes (Optional)',
                                focusedBorderColor: AppColors.primaryColor,
                                fillColor: AppColors.surfaceColor,
                                // REMOVED: maxLines: 3 if your CustomTextField doesn't support it
                                prefixIcon: Icon(
                                  Icons.note_outlined,
                                  color: AppColors.subtextColor,
                                ),
                              )
                              .animate()
                              .fadeIn(duration: 600.ms, delay: 900.ms)
                              .slideY(begin: 0.3),

                          const SizedBox(height: 24),

                          // Calculate Button
                          Container(
                                decoration: BoxDecoration(
                                  color: AppColors.primaryColor,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: AppColors.borderColor,
                                    width: 1.5,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.05),
                                      spreadRadius: 0,
                                      blurRadius: 10,
                                      offset: const Offset(0, 5),
                                    ),
                                  ],
                                ),
                                child: Material(
                                  color: Colors.transparent,
                                  child: InkWell(
                                    borderRadius: BorderRadius.circular(12),
                                    onTap: _isCalculating
                                        ? null
                                        : _calculateRenewal,
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 16,
                                      ),
                                      child: Center(
                                        child: _isCalculating
                                            ? SizedBox(
                                                height: 20,
                                                width: 20,
                                                child:
                                                    CircularProgressIndicator(
                                                      strokeWidth: 2,
                                                      color: Colors.white,
                                                    ),
                                              )
                                            : Text(
                                                'Calculate Renewal',
                                                style: GoogleFonts.poppins(
                                                  color: Colors.white,
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              ),
                                      ),
                                    ),
                                  ),
                                ),
                              )
                              .animate()
                              .fadeIn(duration: 600.ms, delay: 1000.ms)
                              .slideY(begin: 0.3),
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Calculation Result
                    if (_calculationResult != null)
                      _buildCalculationResult()
                          .animate()
                          .fadeIn(duration: 800.ms)
                          .slideY(begin: 0.3),

                    const SizedBox(height: 20),

                    // Submit Button
                    if (_calculationResult != null)
                      Container(
                            decoration: BoxDecoration(
                              color: RealTimeColors.success,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: AppColors.borderColor,
                                width: 1.5,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.05),
                                  spreadRadius: 0,
                                  blurRadius: 10,
                                  offset: const Offset(0, 5),
                                ),
                              ],
                            ),
                            child: Material(
                              color: Colors.transparent,
                              child: InkWell(
                                borderRadius: BorderRadius.circular(12),
                                onTap: _isSubmitting
                                    ? null
                                    : _submitRenewalRequest,
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 16,
                                  ),
                                  child: Center(
                                    child: _isSubmitting
                                        ? SizedBox(
                                            height: 20,
                                            width: 20,
                                            child: CircularProgressIndicator(
                                              strokeWidth: 2,
                                              color: Colors.white,
                                            ),
                                          )
                                        : Text(
                                            'Submit Renewal Request',
                                            style: GoogleFonts.poppins(
                                              color: Colors.white,
                                              fontSize: 16,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                  ),
                                ),
                              ),
                            ),
                          )
                          .animate()
                          .fadeIn(duration: 600.ms, delay: 200.ms)
                          .slideY(begin: 0.3),

                    const SizedBox(height: 32),

                    // Important Information
                    Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: RealTimeColors.primaryGreen.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: RealTimeColors.primaryGreen.withOpacity(
                                0.3,
                              ),
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
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
                                    'Important Information',
                                    style: GoogleFonts.poppins(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                      color: RealTimeColors.primaryGreen,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Text(
                                '• Renewal requests require approval from loan officers\n'
                                '• New terms will start after current term ends\n'
                                '• Interest will be calculated based on extension days\n'
                                '• You will receive notification once approved',
                                style: GoogleFonts.poppins(
                                  fontSize: 12,
                                  color: AppColors.textColor,
                                  height: 1.5,
                                ),
                              ),
                            ],
                          ),
                        )
                        .animate()
                        .fadeIn(duration: 600.ms, delay: 400.ms)
                        .slideY(begin: 0.3),

                    const SizedBox(height: 32),
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
