import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:real_time_pawn/core/utils/pallete.dart';

class LoanChargesScreen extends StatefulWidget {
  final String loanId;

  const LoanChargesScreen({super.key, required this.loanId});

  @override
  State<LoanChargesScreen> createState() => _LoanChargesScreenState();
}

class _LoanChargesScreenState extends State<LoanChargesScreen> {
  bool _isLoading = false;

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
                ],
              ),
            ),

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
                              _buildChargeSummaryItem(
                                label: 'Total Charges',
                                amount: 'K2,250.00', // From API: totalCharges
                              ),
                              _buildChargeSummaryItem(
                                label: 'Paid',
                                amount: 'K250.00', // From API: totalPaid
                                color: RealTimeColors.success,
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Divider(color: AppColors.borderColor),
                          const SizedBox(height: 12),
                          _buildChargeSummaryItem(
                            label: 'Outstanding Charges',
                            amount: 'K2,000.00', // From API: outstandingCharges
                            color: RealTimeColors.warning,
                            isLarge: true,
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Charges Breakdown by Type
                    Text(
                      'Charges by Type',
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textColor,
                      ),
                    ),
                    const SizedBox(height: 12),
                    _buildChargeTypeCard(
                      type: 'Principal',
                      amount: 'K10,000.00', // From API charge breakdown
                      description: 'Original loan amount',
                      isPaid: false,
                    ),
                    const SizedBox(height: 8),
                    _buildChargeTypeCard(
                      type: 'Interest',
                      amount: 'K1,500.00', // From API charge breakdown
                      description: 'Monthly interest @ 15%',
                      isPaid: false,
                    ),
                    const SizedBox(height: 8),
                    _buildChargeTypeCard(
                      type: 'Storage Fee',
                      amount: 'K500.00', // From API charge breakdown
                      description: 'Monthly storage fee',
                      isPaid: false,
                    ),
                    const SizedBox(height: 8),
                    _buildChargeTypeCard(
                      type: 'Insurance',
                      amount: 'K250.00', // From API charge breakdown
                      description: 'Monthly insurance premium',
                      isPaid: true, // Already paid
                    ),

                    const SizedBox(height: 24),

                    // Detailed Charges List
                    Text(
                      'Detailed Charges',
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textColor,
                      ),
                    ),
                    const SizedBox(height: 12),
                    _buildDetailedChargeItem(
                      date: '02 Jan 2024',
                      description: 'Principal Disbursement',
                      type: 'Principal',
                      amount: 'K10,000.00',
                      isPaid: false,
                    ),
                    _buildDetailedChargeItem(
                      date: '02 Jan 2024',
                      description: 'Interest Charge',
                      type: 'Interest',
                      amount: 'K1,500.00',
                      isPaid: false,
                    ),
                    _buildDetailedChargeItem(
                      date: '02 Jan 2024',
                      description: 'Storage Fee',
                      type: 'Storage',
                      amount: 'K500.00',
                      isPaid: false,
                    ),
                    _buildDetailedChargeItem(
                      date: '02 Jan 2024',
                      description: 'Insurance Premium',
                      type: 'Insurance',
                      amount: 'K250.00',
                      isPaid: true,
                    ),

                    const SizedBox(height: 24),

                    // Calculation Notes
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
                                Icons.info_outline,
                                size: 16,
                                color: AppColors.subtextColor,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Calculation Notes',
                                style: GoogleFonts.poppins(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.textColor,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '• Interest: 15% per month on principal\n'
                            '• Storage: K500 monthly flat fee\n'
                            '• Insurance: 2.5% of collateral value\n'
                            '• All charges accrue daily',
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
          ),
        ],
      ),
    );
  }

  Widget _buildChargeTypeCard({
    required String type,
    required String amount,
    required String description,
    required bool isPaid,
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
                Row(
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
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: _getChargeTypeColor(type),
                        ),
                      ),
                    ),
                    if (isPaid) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: RealTimeColors.success.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          'PAID',
                          style: GoogleFonts.poppins(
                            fontSize: 8,
                            fontWeight: FontWeight.bold,
                            color: RealTimeColors.success,
                          ),
                        ),
                      ),
                    ],
                  ],
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
              color: AppColors.textColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailedChargeItem({
    required String date,
    required String description,
    required String type,
    required String amount,
    required bool isPaid,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surfaceColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                date,
                style: GoogleFonts.poppins(
                  fontSize: 10,
                  color: AppColors.subtextColor,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                description,
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textColor,
                ),
              ),
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: _getChargeTypeColor(type).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  type,
                  style: GoogleFonts.poppins(
                    fontSize: 8,
                    fontWeight: FontWeight.w600,
                    color: _getChargeTypeColor(type),
                  ),
                ),
              ),
            ],
          ),
          const Spacer(),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                amount,
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textColor,
                ),
              ),
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: isPaid
                      ? RealTimeColors.success.withOpacity(0.1)
                      : RealTimeColors.warning.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  isPaid ? 'PAID' : 'DUE',
                  style: GoogleFonts.poppins(
                    fontSize: 8,
                    fontWeight: FontWeight.bold,
                    color: isPaid
                        ? RealTimeColors.success
                        : RealTimeColors.warning,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Color _getChargeTypeColor(String type) {
    switch (type.toLowerCase()) {
      case 'principal':
        return AppColors.primaryColor;
      case 'interest':
        return RealTimeColors.warning;
      case 'storage':
        return RealTimeColors.warning;
      case 'insurance':
        return RealTimeColors.success;
      default:
        return AppColors.textColor;
    }
  }
}
