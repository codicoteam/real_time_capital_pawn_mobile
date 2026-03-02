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
    // Use WidgetsBinding to ensure we don't call setState during build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadCharges();
    });
  }

  Future<void> _loadCharges() async {
    if (!mounted) return;

    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      final charges = await _controller.calculateLoanCharges(widget.loanId);

      if (!mounted) return;

      setState(() {
        _chargesData = charges;
        _isLoading = false;
        if (charges == null) {
          _errorMessage = 'No charges data available';
        }
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = 'Failed to load charges';
        _isLoading = false;
      });
    }
  }

  String _formatCurrency(double amount) {
    return '\$${amount.toStringAsFixed(2)}';
  }

  String _formatDate(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      const months = [
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
      return '${date.day} ${months[date.month - 1]} ${date.year}';
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
                          'Loan ${widget.loanId.substring(0, 8)}...',
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

            // Body
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _errorMessage.isNotEmpty
                  ? Center(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.error_outline,
                              size: 64,
                              color: Colors.red,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              _errorMessage,
                              style: GoogleFonts.poppins(fontSize: 16),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 16),
                            ElevatedButton(
                              onPressed: _loadCharges,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primaryColor,
                                foregroundColor: Colors.white,
                              ),
                              child: const Text('Retry'),
                            ),
                          ],
                        ),
                      ),
                    )
                  : _chargesData == null
                  ? const Center(child: Text('No data available'))
                  : _buildContent(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Summary Card
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
                  children: [
                    Expanded(
                      child: _buildSummaryItem(
                        'Principal',
                        _formatCurrency(_chargesData!['principal'] ?? 0),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildSummaryItem(
                        'Days Elapsed',
                        '${_chargesData!['days_elapsed'] ?? 0}',
                      ),
                    ),
                  ],
                ),
                const Divider(height: 24),
                _buildSummaryItem(
                  'Total Due',
                  _formatCurrency(_chargesData!['total_due'] ?? 0),
                  large: true,
                  color: RealTimeColors.warning,
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
            ),
          ),
          const SizedBox(height: 12),
          _buildChargeCard(
            'Principal Amount',
            _formatCurrency(_chargesData!['principal'] ?? 0),
            'Original loan amount',
          ),
          _buildChargeCard(
            'Interest Rate',
            '${_chargesData!['interest_rate'] ?? 0}%',
            'Annual interest rate',
          ),
          _buildChargeCard(
            'Interest Accrued',
            _formatCurrency(_chargesData!['interest_accrued'] ?? 0),
            'Accrued for ${_chargesData!['days_elapsed'] ?? 0} days',
            color: RealTimeColors.warning,
          ),

          const SizedBox(height: 20),

          // Additional Charges
          Text(
            'Additional Charges',
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          _buildChargeCard(
            'Storage Charge',
            _formatCurrency(_chargesData!['storage_charge'] ?? 0),
            '${_chargesData!['storage_charge_percent'] ?? 0}% of principal',
          ),
          _buildChargeCard(
            'Penalty Charge',
            _formatCurrency(_chargesData!['penalty'] ?? 0),
            '${_chargesData!['penalty_percent'] ?? 0}% penalty',
            color: (_chargesData!['penalty'] ?? 0) > 0
                ? RealTimeColors.error
                : RealTimeColors.success,
          ),

          const SizedBox(height: 20),

          // Loan Status Card
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
                  ),
                ),
                const SizedBox(height: 12),
                _buildStatusRow(
                  'Current Balance',
                  _formatCurrency(_chargesData!['current_balance'] ?? 0),
                ),
                _buildStatusRow(
                  'Total Loan Days',
                  '${_chargesData!['total_loan_days'] ?? 0} days',
                ),
                _buildStatusRow(
                  'Due Date',
                  _formatDate(_chargesData!['due_date'] ?? ''),
                ),
                _buildStatusRow(
                  'Overdue Status',
                  (_chargesData!['is_overdue'] ?? false)
                      ? '${_chargesData!['overdue_days'] ?? 0} days overdue'
                      : 'Not overdue',
                  color: (_chargesData!['is_overdue'] ?? false)
                      ? RealTimeColors.error
                      : RealTimeColors.success,
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // Calculation Card
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.surfaceColor.withOpacity(0.5),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.borderColor.withOpacity(0.5)),
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
                      style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                _buildCalcRow(
                  'Principal',
                  _formatCurrency(_chargesData!['principal'] ?? 0),
                ),
                _buildCalcRow(
                  'Interest (${_chargesData!['interest_rate'] ?? 0}%)',
                  _formatCurrency(_chargesData!['interest_accrued'] ?? 0),
                ),
                _buildCalcRow(
                  'Storage (${_chargesData!['storage_charge_percent'] ?? 0}%)',
                  _formatCurrency(_chargesData!['storage_charge'] ?? 0),
                ),
                _buildCalcRow(
                  'Penalty (${_chargesData!['penalty_percent'] ?? 0}%)',
                  _formatCurrency(_chargesData!['penalty'] ?? 0),
                ),
                const Divider(height: 24),
                _buildCalcRow(
                  'Total Amount Due',
                  _formatCurrency(_chargesData!['total_due'] ?? 0),
                  isTotal: true,
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Payment Button
          if ((_chargesData!['total_due'] ?? 0) > 0)
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Get.toNamed(
                    RoutesHelper.CreatePaymentScreen,
                    arguments: {
                      'loanId': widget.loanId,
                      'amount': (_chargesData!['total_due'] as num).toDouble(),
                    },
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  'Make Payment - ${_formatCurrency(_chargesData!['total_due'] ?? 0)}',
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
  }

  Widget _buildSummaryItem(
    String label,
    String value, {
    bool large = false,
    Color? color,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 12,
            color: AppColors.subtextColor,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: GoogleFonts.poppins(
            fontSize: large ? 20 : 16,
            fontWeight: FontWeight.bold,
            color: color ?? AppColors.textColor,
          ),
        ),
      ],
    );
  }

  Widget _buildChargeCard(
    String label,
    String value,
    String description, {
    Color? color,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surfaceColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.borderColor),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 4),
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
            value,
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.bold,
              color: color ?? AppColors.textColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusRow(String label, String value, {Color? color}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: GoogleFonts.poppins(color: AppColors.subtextColor),
          ),
          Text(
            value,
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.w500,
              color: color ?? AppColors.textColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCalcRow(String label, String value, {bool isTotal = false}) {
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
}
