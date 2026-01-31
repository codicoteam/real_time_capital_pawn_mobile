import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:real_time_pawn/config/routers/router.dart';
import 'package:real_time_pawn/core/utils/pallete.dart';

class LoanDetailsScreen extends StatefulWidget {
  final String loanId;

  const LoanDetailsScreen({super.key, required this.loanId});

  @override
  State<LoanDetailsScreen> createState() => _LoanDetailsScreenState();
}

class _LoanDetailsScreenState extends State<LoanDetailsScreen> {
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header with loan ID and status
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
                          'Loan Details',
                          style: GoogleFonts.poppins(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textColor,
                          ),
                        ),
                        Text(
                          widget.loanId, // From API: loanNumber
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            color: AppColors.subtextColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: RealTimeColors.success.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      'Active', // From API: status
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: RealTimeColors.success,
                      ),
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
                    // Quick Stats Card
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
                              _buildAmountCard(
                                label: 'Loan Amount',
                                amount:
                                    'K10,000.00', // From API: principalAmount
                                color: AppColors.textColor,
                              ),
                              _buildAmountCard(
                                label: 'Paid',
                                amount: 'K2,500.00', // From API: totalPaid
                                color: RealTimeColors.success,
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          _buildAmountCard(
                            label: 'Outstanding Balance',
                            amount: 'K7,500.00', // From API: outstandingBalance
                            color: RealTimeColors.warning,
                            isLarge: true,
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Quick Actions
                    Text(
                      'Quick Actions',
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
                          child: _buildActionButton(
                            icon: Icons.payments_outlined,
                            label: 'Make Payment',
                            onTap: () {
                              Get.toNamed(
                                RoutesHelper.LoanPaymentScreen,
                                arguments: {'loanId': widget.loanId},
                              );
                            },
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildActionButton(
                            icon: Icons.receipt_long_outlined,
                            label: 'View Charges',
                            onTap: () {
                              Get.toNamed(
                                RoutesHelper.LoanChargesScreen,
                                arguments: {'loanId': widget.loanId},
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: _buildActionButton(
                            icon: Icons.history_outlined,
                            label: 'Status Timeline',
                            onTap: () {
                              Get.toNamed(
                                RoutesHelper.LoanStatusScreen,
                                arguments: {'loanId': widget.loanId},
                              );
                            },
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildActionButton(
                            icon: Icons.document_scanner_outlined,
                            label: 'View Contract',
                            onTap: () {
                              // View loan contract/document
                            },
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 24),

                    // Loan Information
                    _buildSectionCard(
                      title: 'Loan Information',
                      children: [
                        _buildInfoRow(
                          label: 'Loan Date',
                          value: '02 Jan 2024', // From API: loanDate
                        ),
                        _buildInfoRow(
                          label: 'Due Date',
                          value: '15 Jan 2024', // From API: dueDate
                        ),
                        _buildInfoRow(
                          label: 'Interest Rate',
                          value: '15% per month', // From API: interestRate
                        ),
                        _buildInfoRow(
                          label: 'Loan Term',
                          value: '30 days', // From API: loanTerm
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),

                    // Collateral Information
                    _buildSectionCard(
                      title: 'Collateral Information',
                      children: [
                        _buildInfoRow(
                          label: 'Item',
                          value:
                              'Gold Necklace with Diamond', // From API: collateralName
                        ),
                        _buildInfoRow(
                          label: 'Category',
                          value: 'Jewelry', // From API: collateralCategory
                        ),
                        _buildInfoRow(
                          label: 'Estimated Value',
                          value: 'K15,000.00', // From API: collateralValue
                        ),
                        _buildInfoRow(
                          label: 'Storage Location',
                          value:
                              'Main Vault - Section A', // From API: storageLocation
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),

                    // Customer Information
                    _buildSectionCard(
                      title: 'Customer Information',
                      children: [
                        _buildInfoRow(
                          label: 'Name',
                          value: 'John Banda', // From API: customerName
                        ),
                        _buildInfoRow(
                          label: 'ID Number',
                          value: '63-1234567C01', // From API: customerIdNumber
                        ),
                        _buildInfoRow(
                          label: 'Phone',
                          value: '+260 97 123 4567', // From API: customerPhone
                        ),
                      ],
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

  Widget _buildAmountCard({
    required String label,
    required String amount,
    required Color color,
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
              fontSize: isLarge ? 20 : 16,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surfaceColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.borderColor),
        ),
        child: Column(
          children: [
            Icon(icon, color: AppColors.primaryColor, size: 24),
            const SizedBox(height: 8),
            Text(
              label,
              style: GoogleFonts.poppins(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: AppColors.textColor,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionCard({
    required String title,
    required List<Widget> children,
  }) {
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
            title,
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.textColor,
            ),
          ),
          const SizedBox(height: 12),
          ...children,
        ],
      ),
    );
  }

  Widget _buildInfoRow({required String label, required String value}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
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
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: AppColors.textColor,
            ),
          ),
        ],
      ),
    );
  }
}
