import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:real_time_pawn/config/routers/router.dart';
import 'package:real_time_pawn/core/utils/pallete.dart';
import 'package:real_time_pawn/features/loan_mngmt/controllers/loan_mngmt_controller.dart';
import 'package:real_time_pawn/models/loan_mngmt_model.dart';

class LoanDetailsScreen extends StatefulWidget {
  final String loanId;

  const LoanDetailsScreen({super.key, required this.loanId});

  @override
  State<LoanDetailsScreen> createState() => _LoanDetailsScreenState();
}

class _LoanDetailsScreenState extends State<LoanDetailsScreen> {
  final LoanController _controller = Get.find<LoanController>();
  LoanModel? _loan;
  bool _isLoading = true;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _loadLoanDetails();
  }

  Future<void> _loadLoanDetails() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      final loan = await _controller.getLoanDetails(widget.loanId);

      if (loan != null) {
        setState(() {
          _loan = loan;
        });
      } else {
        setState(() {
          _errorMessage = 'Failed to load loan details';
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Error loading loan details: ${e.toString()}';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'active':
        return RealTimeColors.success;
      case 'overdue':
        return RealTimeColors.error;
      case 'settled':
        return RealTimeColors.success;
      default:
        return AppColors.subtextColor;
    }
  }

  String _formatDateFull(DateTime date) {
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
  }

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
                        if (_loan != null)
                          Text(
                            _loan!.loanNo,
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                              color: AppColors.subtextColor,
                            ),
                          ),
                      ],
                    ),
                  ),
                  if (_loan != null)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: _getStatusColor(_loan!.status).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        _loan!.status.toUpperCase(),
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: _getStatusColor(_loan!.status),
                        ),
                      ),
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
                          onPressed: _loadLoanDetails,
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
            else if (_loan == null)
              Expanded(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.account_balance_wallet_outlined,
                        size: 64,
                        color: RealTimeColors.grey400,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Loan not found',
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
                                Expanded(
                                  // ADD Expanded here instead
                                  child: _buildAmountCard(
                                    label: 'Loan Amount',
                                    amount: _loan!.formattedPrincipalAmount,
                                    color: AppColors.textColor,
                                  ),
                                ),
                                const SizedBox(
                                  width: 12,
                                ), // Add spacing between cards
                                Expanded(
                                  // ADD Expanded here instead
                                  child: _buildAmountCard(
                                    label: 'Paid',
                                    amount:
                                        '${_loan!.currency} ${(_loan!.principalAmount - _loan!.currentBalance).toStringAsFixed(2)}',
                                    color: RealTimeColors.success,
                                  ),
                                ),
                              ],
                            ),
                            _buildAmountCard(
                              label: 'Outstanding Balance',
                              amount: _loan!.formattedCurrentBalance,
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
                              onTap: () async {
                                final charges = await _controller
                                    .calculateLoanCharges(widget.loanId);
                                if (charges != null) {
                                  Get.toNamed(
                                    RoutesHelper.LoanChargesScreen,
                                    arguments: {
                                      'loanId': widget.loanId,
                                      'charges': charges,
                                    },
                                  );
                                }
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
                              icon: Icons.list_alt_outlined,
                              label: 'Loan Terms',
                              onTap: () {
                                Get.toNamed(
                                  RoutesHelper.loanTermsScreen,
                                  arguments: {
                                    'loanId': widget.loanId,
                                    'loanNo': _loan!.loanNo,
                                  },
                                );
                              },
                            ),
                          ),

                          // In LoanDetailsScreen.dart - Add a "View Payments" button
                          _buildActionButton(
                            icon: Icons.payment_outlined,
                            label: 'View Payments',
                            onTap: () {
                              Get.toNamed(
                                RoutesHelper.PaymentListScreen,
                                arguments: {
                                  'loanId': widget.loanId,
                                  'isLoanPayments': true,
                                },
                              );
                            },
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
                            value: _formatDateFull(_loan!.startDate),
                          ),
                          _buildInfoRow(
                            label: 'Due Date',
                            value: _formatDateFull(_loan!.dueDate),
                          ),
                          _buildInfoRow(
                            label: 'Interest Rate',
                            value: '${_loan!.interestRatePercent}% per month',
                          ),
                          _buildInfoRow(
                            label: 'Loan Term',
                            value: '${_loan!.interestPeriodDays} days',
                          ),
                          _buildInfoRow(
                            label: 'Grace Period',
                            value: '${_loan!.graceDays} days',
                          ),
                        ],
                      ),

                      const SizedBox(height: 16),

                      // Collateral Information
                      _buildSectionCard(
                        title: 'Collateral Information',
                        children: [
                          _buildInfoRow(
                            label: 'Category',
                            value: _loan!.collateralCategory,
                          ),
                          if (_loan!.asset != null)
                            _buildInfoRow(label: 'Asset', value: _loan!.asset!),
                          // Note: Collateral value not available in the model
                          // You might need to extend the model or get it from another endpoint
                        ],
                      ),

                      const SizedBox(height: 16),

                      // Customer Information
                      _buildSectionCard(
                        title: 'Customer Information',
                        children: [
                          _buildInfoRow(
                            label: 'Name',
                            value: _loan!.customerName,
                          ),
                          _buildInfoRow(
                            label: 'Email',
                            value: _loan!.customerEmail,
                          ),
                          _buildInfoRow(
                            label: 'Phone',
                            value: _loan!.customerPhone,
                          ),
                        ],
                      ),

                      const SizedBox(height: 16),

                      // Additional Loan Details
                      _buildSectionCard(
                        title: 'Additional Details',
                        children: [
                          _buildInfoRow(
                            label: 'Storage Charge',
                            value: '${_loan!.storageChargePercent}%',
                          ),
                          _buildInfoRow(
                            label: 'Penalty Rate',
                            value: '${_loan!.penaltyPercent}%',
                          ),
                          _buildInfoRow(
                            label: 'Created By',
                            value: _loan!.createdBy,
                          ),
                          _buildInfoRow(
                            label: 'Created Date',
                            value: _formatDateFull(_loan!.createdAt),
                          ),
                          _buildInfoRow(
                            label: 'Last Updated',
                            value: _formatDateFull(_loan!.updatedAt),
                          ),
                        ],
                      ),

                      const SizedBox(height: 24),

                      // Status Management
                      if (_loan!.isActive || _loan!.isOverdue)
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
                                'Loan Status Management',
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
                                    child: ElevatedButton(
                                      onPressed: () async {
                                        final confirmed = await Get.dialog<bool>(
                                          AlertDialog(
                                            title: const Text('Settle Loan'),
                                            content: const Text(
                                              'Are you sure you want to mark this loan as settled? This action cannot be undone.',
                                            ),
                                            actions: [
                                              TextButton(
                                                onPressed: () =>
                                                    Get.back(result: false),
                                                child: const Text('Cancel'),
                                              ),
                                              ElevatedButton(
                                                onPressed: () =>
                                                    Get.back(result: true),
                                                child: const Text('Settle'),
                                              ),
                                            ],
                                          ),
                                        );

                                        if (confirmed == true) {
                                          final success = await _controller
                                              .updateLoanStatus(
                                                loanId: widget.loanId,
                                                status: 'settled',
                                                notes:
                                                    'Loan settled from mobile app',
                                              );

                                          if (success) {
                                            await _loadLoanDetails();
                                          }
                                        }
                                      },
                                      style: ElevatedButton.styleFrom(
                                        foregroundColor: Colors.white,
                                        backgroundColor: RealTimeColors.success,
                                      ),
                                      child: const Text('Mark as Settled'),
                                    ),
                                  ),
                                ],
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
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
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
              maxLines: 2,
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
          Flexible(
            child: Text(
              label,
              style: GoogleFonts.poppins(
                fontSize: 12,
                color: AppColors.subtextColor,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Flexible(
            child: Text(
              value,
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: AppColors.textColor,
              ),
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }
}
