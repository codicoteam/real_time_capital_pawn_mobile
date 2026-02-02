import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:real_time_pawn/config/routers/router.dart';
import 'package:real_time_pawn/core/utils/pallete.dart';
import 'package:real_time_pawn/features/loan_mngmt/controllers/loan_mngmt_controller.dart';

class LoanChargesScreen extends StatefulWidget {
  final String loanId;

  const LoanChargesScreen({super.key, required this.loanId});

  @override
  State<LoanChargesScreen> createState() => _LoanChargesScreenState();
}

class _LoanChargesScreenState extends State<LoanChargesScreen> {
  final LoanController _controller = Get.find<LoanController>();
  Map<String, dynamic>? _chargesData;
  bool _isLoading = true;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _loadCharges();
  }

  Future<void> _loadCharges() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      final charges = await _controller.calculateLoanCharges(widget.loanId);

      if (charges != null) {
        setState(() {
          _chargesData = charges;
        });
      } else {
        setState(() {
          _errorMessage = 'Failed to load charges';
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Error loading charges: ${e.toString()}';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  String _formatCurrency(double amount) {
    // Assuming USD currency - you might want to get this from loan data
    return '\$${amount.toStringAsFixed(2)}';
  }

  String _formatDate(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      final monthNames = [
        'Jan',
        'Feb',
        'Mar',
        'Apr',
        'May',
        'Jun',
        'Jul',
        'Aug',
        'Sep',
        'Oct',
        'Nov',
        'Dec',
      ];
      return '${date.day} ${monthNames[date.month - 1]} ${date.year}';
    } catch (e) {
      return dateString;
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
                          'Charges Breakdown',
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
                  IconButton(
                    onPressed: _loadCharges,
                    icon: const Icon(Icons.refresh_outlined),
                    color: AppColors.textColor,
                  ),
                ],
              ),
            ),

            if (_isLoading)
              Expanded(
                child: Center(
                  child: CircularProgressIndicator(
                    color: AppColors.primaryColor,
                  ),
                ),
              )
            else if (_errorMessage.isNotEmpty)
              Expanded(
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.error_outline,
                          size: 64,
                          color: RealTimeColors.error,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          _errorMessage,
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            color: AppColors.textColor,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: _loadCharges,
                          style: ElevatedButton.styleFrom(
                            foregroundColor: Colors.white,
                            backgroundColor: AppColors.primaryColor,
                          ),
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  ),
                ),
              )
            else if (_chargesData == null)
              Expanded(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.receipt_long_outlined,
                        size: 64,
                        color: RealTimeColors.grey400,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'No charges data available',
                        style: GoogleFonts.poppins(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                          color: AppColors.subtextColor,
                        ),
                      ),
                    ],
                  ),
                ),
              )
            else
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Total Charges Summary
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppColors.surfaceColor,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: AppColors.borderColor),
                        ),
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: _buildChargeSummaryItem(
                                    label: 'Principal',
                                    amount: _formatCurrency(
                                      (_chargesData!['principal'] as num?)
                                              ?.toDouble() ??
                                          0.0,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: _buildChargeSummaryItem(
                                    label: 'Days Elapsed',
                                    amount:
                                        '${_chargesData!['days_elapsed'] ?? 0} days',
                                    color: AppColors.subtextColor,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Divider(color: AppColors.borderColor),
                            const SizedBox(height: 12),
                            _buildChargeSummaryItem(
                              label: 'Total Due',
                              amount: _formatCurrency(
                                (_chargesData!['total_due'] as num?)
                                        ?.toDouble() ??
                                    0.0,
                              ),
                              color: RealTimeColors.warning,
                              isLarge: true,
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 20),

                      // Interest Charges
                      Text(
                        'Interest Charges',
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textColor,
                        ),
                      ),
                      const SizedBox(height: 12),
                      _buildChargeTypeCard(
                        type: 'Principal Amount',
                        amount: _formatCurrency(
                          (_chargesData!['principal'] as num?)?.toDouble() ??
                              0.0,
                        ),
                        description: 'Original loan amount',
                      ),
                      const SizedBox(height: 8),
                      _buildChargeTypeCard(
                        type: 'Interest Rate',
                        amount: '${_chargesData!['interest_rate'] ?? 0.0}%',
                        description: 'Annual interest rate',
                      ),
                      const SizedBox(height: 8),
                      _buildChargeTypeCard(
                        type: 'Interest Accrued',
                        amount: _formatCurrency(
                          (_chargesData!['interest_accrued'] as num?)
                                  ?.toDouble() ??
                              0.0,
                        ),
                        description:
                            'Accrued interest for ${_chargesData!['days_elapsed'] ?? 0} days',
                        color: RealTimeColors.warning,
                      ),
                      const SizedBox(height: 20),

                      // Additional Charges
                      Text(
                        'Additional Charges',
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textColor,
                        ),
                      ),
                      const SizedBox(height: 12),
                      _buildChargeTypeCard(
                        type: 'Storage Charge',
                        amount: _formatCurrency(
                          (_chargesData!['storage_charge'] as num?)
                                  ?.toDouble() ??
                              0.0,
                        ),
                        description:
                            '${_chargesData!['storage_charge_percent'] ?? 0.0}% of principal',
                      ),
                      const SizedBox(height: 8),
                      _buildChargeTypeCard(
                        type: 'Penalty Charge',
                        amount: _formatCurrency(
                          (_chargesData!['penalty'] as num?)?.toDouble() ?? 0.0,
                        ),
                        description:
                            '${_chargesData!['penalty_percent'] ?? 0.0}% penalty',
                        color:
                            ((_chargesData!['penalty'] as num?)?.toDouble() ??
                                    0.0) >
                                0
                            ? RealTimeColors.error
                            : RealTimeColors.success,
                      ),

                      const SizedBox(height: 20),

                      // Loan Status Information
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
                              'Loan Status',
                              style: GoogleFonts.poppins(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textColor,
                              ),
                            ),
                            const SizedBox(height: 12),
                            _buildStatusRow(
                              label: 'Current Balance',
                              value: _formatCurrency(
                                (_chargesData!['current_balance'] as num?)
                                        ?.toDouble() ??
                                    0.0,
                              ),
                            ),
                            _buildStatusRow(
                              label: 'Total Loan Days',
                              value:
                                  '${_chargesData!['total_loan_days'] ?? 0} days',
                            ),
                            _buildStatusRow(
                              label: 'Due Date',
                              value: _formatDate(
                                _chargesData!['due_date']?.toString() ?? '',
                              ),
                            ),
                            _buildStatusRow(
                              label: 'Overdue Status',
                              value:
                                  (_chargesData!['is_overdue'] as bool?) == true
                                  ? '${_chargesData!['overdue_days'] ?? 0} days overdue'
                                  : 'Not overdue',
                              color:
                                  (_chargesData!['is_overdue'] as bool?) == true
                                  ? RealTimeColors.error
                                  : RealTimeColors.success,
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 20),

                      // Detailed Calculation
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppColors.surfaceColor.withOpacity(0.5),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: AppColors.borderColor.withOpacity(0.5),
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  Icons.calculate_outlined,
                                  size: 16,
                                  color: AppColors.subtextColor,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'Calculation Breakdown',
                                  style: GoogleFonts.poppins(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.textColor,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            _buildCalculationRow(
                              label: 'Principal',
                              value: _formatCurrency(
                                (_chargesData!['principal'] as num?)
                                        ?.toDouble() ??
                                    0.0,
                              ),
                            ),
                            _buildCalculationRow(
                              label:
                                  'Interest (${_chargesData!['interest_rate'] ?? 0.0}%)',
                              value: _formatCurrency(
                                (_chargesData!['interest_accrued'] as num?)
                                        ?.toDouble() ??
                                    0.0,
                              ),
                            ),
                            _buildCalculationRow(
                              label:
                                  'Storage (${_chargesData!['storage_charge_percent'] ?? 0.0}%)',
                              value: _formatCurrency(
                                (_chargesData!['storage_charge'] as num?)
                                        ?.toDouble() ??
                                    0.0,
                              ),
                            ),
                            _buildCalculationRow(
                              label:
                                  'Penalty (${_chargesData!['penalty_percent'] ?? 0.0}%)',
                              value: _formatCurrency(
                                (_chargesData!['penalty'] as num?)
                                        ?.toDouble() ??
                                    0.0,
                              ),
                            ),
                            Divider(
                              color: AppColors.borderColor,
                              height: 24,
                              thickness: 1,
                            ),
                            _buildCalculationRow(
                              label: 'Total Amount Due',
                              value: _formatCurrency(
                                (_chargesData!['total_due'] as num?)
                                        ?.toDouble() ??
                                    0.0,
                              ),
                              isTotal: true,
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Make Payment Button
                      if (((_chargesData!['total_due'] as num?)?.toDouble() ??
                              0.0) >
                          0)
                        ElevatedButton(
                          onPressed: () {
                            Get.toNamed(
                              RoutesHelper.CreatePaymentScreen,
                              arguments: {
                                'loanId': widget.loanId,
                                'amount':
                                    (_chargesData!['total_due'] as num?)
                                        ?.toDouble() ??
                                    0.0,
                                'charges': _chargesData,
                              },
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            foregroundColor: Colors.white,
                            backgroundColor: AppColors.primaryColor,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: Text(
                            'Make Payment - ${_formatCurrency((_chargesData!['total_due'] as num?)?.toDouble() ?? 0.0)}',
                            style: GoogleFonts.poppins(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
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

  Widget _buildChargeSummaryItem({
    required String label,
    required String amount,
    Color? color,
    bool isLarge = false,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surfaceColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.borderColor),
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
              fontSize: isLarge ? 18 : 14,
              fontWeight: FontWeight.bold,
              color: color ?? AppColors.textColor,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildChargeTypeCard({
    required String type,
    required String amount,
    required String description,
    Color? color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.borderColor),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: _getChargeTypeColor(type).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    type,
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: color ?? _getChargeTypeColor(type),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  description,
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: AppColors.subtextColor,
                  ),
                ),
              ],
            ),
          ),
          Text(
            amount,
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: color ?? AppColors.textColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusRow({
    required String label,
    required String value,
    Color? color,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
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
              fontWeight: FontWeight.w500,
              color: color ?? AppColors.textColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCalculationRow({
    required String label,
    required String value,
    bool isTotal = false,
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
              color: AppColors.textColor,
            ),
          ),
          Text(
            value,
            style: GoogleFonts.poppins(
              fontSize: isTotal ? 18 : 14,
              fontWeight: isTotal ? FontWeight.bold : FontWeight.w500,
              color: isTotal ? RealTimeColors.warning : AppColors.textColor,
            ),
          ),
        ],
      ),
    );
  }

  Color _getChargeTypeColor(String type) {
    switch (type.toLowerCase()) {
      case 'principal':
      case 'principal amount':
        return AppColors.primaryColor;
      case 'interest':
      case 'interest rate':
      case 'interest accrued':
        return RealTimeColors.warning;
      case 'storage':
      case 'storage charge':
        return AppColors.primaryColor.withOpacity(0.7);
      case 'penalty':
      case 'penalty charge':
        return RealTimeColors.error;
      default:
        return AppColors.textColor;
    }
  }
}
