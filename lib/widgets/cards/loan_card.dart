import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:real_time_pawn/core/utils/pallete.dart';

import '../../models/loan_mngmt_model.dart';

class LoanCard extends StatelessWidget {
  final LoanModel loan;
  final int index;
  final VoidCallback? onTap;

  const LoanCard({
    super.key,
    required this.loan,
    required this.index,
    this.onTap,
  });

  String _formatCurrency(num? amount) {
    if (amount == null) return '\$0.00';
    final formatter = NumberFormat.currency(symbol: '\$', decimalDigits: 2);
    return formatter.format(amount);
  }

  String _formatDate(DateTime? date) {
    if (date == null) return 'N/A';
    return DateFormat('MMM dd, yyyy').format(date);
  }

  String _formatCollateralCategory(String? category) {
    if (category == null || category.isEmpty) return 'N/A';
    switch (category.toLowerCase()) {
      case 'small_loans':
        return 'Small Loans';
      case 'motor_vehicle':
        return 'Motor Vehicle';
      case 'jewellery':
        return 'Jewellery';
      default:
        return category
            .split('_')
            .map(
              (word) => word.isEmpty
                  ? ''
                  : word[0].toUpperCase() + word.substring(1).toLowerCase(),
            )
            .join(' ');
    }
  }

  IconData _getCategoryIcon(String? category) {
    if (category == null || category.isEmpty) return Icons.category_outlined;
    switch (category.toLowerCase()) {
      case 'small_loans':
        return Icons.attach_money_rounded;
      case 'motor_vehicle':
        return Icons.directions_car_outlined;
      case 'jewellery':
        return Icons.diamond_outlined;
      default:
        return Icons.category_outlined;
    }
  }

  Color _getCategoryColor(String? category) {
    if (category == null || category.isEmpty) return AppColors.subtextColor;
    switch (category.toLowerCase()) {
      case 'small_loans':
        return const Color(0xFF2196F3); // Blue
      case 'motor_vehicle':
        return const Color(0xFFFF9800); // Orange
      case 'jewellery':
        return const Color(0xFF9C27B0); // Purple
      default:
        return AppColors.subtextColor;
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: AppColors.primaryColor.withValues(alpha: 0.3),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.primaryColor.withValues(alpha: 0.08),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Stack(
            children: [
              // Subtle gradient overlay
              Positioned(
                top: 0,
                right: 0,
                child: Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    gradient: RadialGradient(
                      colors: [
                        AppColors.primaryColor.withValues(alpha: 0.05),
                        AppColors.primaryColor.withValues(alpha: 0.0),
                      ],
                    ),
                  ),
                ),
              ),

              // Content
              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Loan Number and Status
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: AppColors.primaryColor.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Icon(
                                  Icons.receipt_long_rounded,
                                  color: AppColors.primaryColor,
                                  size: 18,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  loan.loanNo ?? 'N/A',
                                  style: GoogleFonts.poppins(
                                    color: AppColors.textColor,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                    letterSpacing: -0.3,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),
                        _buildStatusChip(loan.status ?? 'draft'),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Divider
                    Container(
                      height: 1,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            AppColors.borderColor.withValues(alpha: 0.1),
                            AppColors.borderColor,
                            AppColors.borderColor.withValues(alpha: 0.1),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Customer Name
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: AppColors.primaryColor.withValues(alpha: 0.08),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(
                            Icons.person_outline_rounded,
                            color: AppColors.primaryColor,
                            size: 16,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Borrower',
                                style: GoogleFonts.poppins(
                                  color: AppColors.subtextColor,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w500,
                                  letterSpacing: 0.5,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                loan.customerUser != null
                                    ? '${loan.customerUser!.firstName} ${loan.customerUser!.lastName}'
                                    : 'N/A',
                                style: GoogleFonts.poppins(
                                  color: AppColors.textColor,
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Collateral Category and Due Date
                    Row(
                      children: [
                        // Collateral Category
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 10,
                            ),
                            decoration: BoxDecoration(
                              color: _getCategoryColor(loan.collateralCategory)
                                  .withValues(alpha: 0.08),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: _getCategoryColor(loan.collateralCategory)
                                    .withValues(alpha: 0.2),
                                width: 1,
                              ),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  _getCategoryIcon(loan.collateralCategory),
                                  color: _getCategoryColor(loan.collateralCategory),
                                  size: 18,
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    _formatCollateralCategory(loan.collateralCategory),
                                    style: GoogleFonts.poppins(
                                      color: _getCategoryColor(loan.collateralCategory),
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),

                        // Due Date
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 10,
                          ),
                          decoration: BoxDecoration(
                            color: RealTimeColors.grey100,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: AppColors.borderColor,
                              width: 1,
                            ),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.calendar_today_outlined,
                                color: AppColors.subtextColor,
                                size: 14,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                'Due: ${_formatDate(loan.dueDate)}',
                                style: GoogleFonts.poppins(
                                  color: AppColors.subtextColor,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Amounts with accent background
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            AppColors.primaryColor.withValues(alpha: 0.12),
                            AppColors.primaryColor.withValues(alpha: 0.05),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: AppColors.primaryColor.withValues(alpha: 0.25),
                          width: 1.5,
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          // Principal and Balance
                          Expanded(
                            child: Row(
                              children: [
                                // Principal
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Icon(
                                            Icons.account_balance_wallet_outlined,
                                            size: 12,
                                            color: AppColors.primaryColor,
                                          ),
                                          const SizedBox(width: 4),
                                          Text(
                                            'Principal',
                                            style: GoogleFonts.poppins(
                                              color: AppColors.primaryColor,
                                              fontSize: 10,
                                              fontWeight: FontWeight.w600,
                                              letterSpacing: 0.3,
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        _formatCurrency(loan.principalAmount),
                                        style: GoogleFonts.poppins(
                                          color: AppColors.primaryColor,
                                          fontSize: 16,
                                          fontWeight: FontWeight.w800,
                                          letterSpacing: -0.3,
                                          height: 1,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 12),
                                // Current Balance
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Icon(
                                            Icons.trending_up_rounded,
                                            size: 12,
                                            color: RealTimeColors.warning,
                                          ),
                                          const SizedBox(width: 4),
                                          Text(
                                            'Balance',
                                            style: GoogleFonts.poppins(
                                              color: RealTimeColors.warning,
                                              fontSize: 10,
                                              fontWeight: FontWeight.w600,
                                              letterSpacing: 0.3,
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        _formatCurrency(loan.currentBalance),
                                        style: GoogleFonts.poppins(
                                          color: RealTimeColors.warning,
                                          fontSize: 16,
                                          fontWeight: FontWeight.w800,
                                          letterSpacing: -0.3,
                                          height: 1,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 12),
                          // Arrow icon
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: AppColors.primaryColor.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(
                              Icons.arrow_forward_rounded,
                              color: AppColors.primaryColor,
                              size: 20,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    )
        .animate()
        .fadeIn(delay: (index * 80).ms, duration: 400.ms)
        .slideX(
          begin: 0.2,
          end: 0,
          delay: (index * 80).ms,
          duration: 400.ms,
          curve: Curves.easeOutCubic,
        )
        .shimmer(
          delay: (index * 100 + 1000).ms,
          duration: 1800.ms,
          color: Colors.white.withValues(alpha: 0.3),
        );
  }

  Widget _buildStatusChip(String status) {
    Color backgroundColor;
    Color textColor;
    IconData icon;

    switch (status.toLowerCase()) {
      case 'active':
        backgroundColor = const Color(0xFFE8F5E9);
        textColor = const Color(0xFF388E3C);
        icon = Icons.check_circle_outline_rounded;
        break;
      case 'overdue':
        backgroundColor = const Color(0xFFFFEBEE);
        textColor = const Color(0xFFD32F2F);
        icon = Icons.warning_amber_rounded;
        break;
      case 'in_grace':
        backgroundColor = const Color(0xFFFFF3E0);
        textColor = const Color(0xFFF57C00);
        icon = Icons.hourglass_empty_rounded;
        break;
      case 'auction':
        backgroundColor = const Color(0xFFFCE4EC);
        textColor = const Color(0xFFC2185B);
        icon = Icons.gavel_rounded;
        break;
      case 'sold':
        backgroundColor = const Color(0xFFE0F2F1);
        textColor = const Color(0xFF00796B);
        icon = Icons.shopping_cart_outlined;
        break;
      case 'redeemed':
        backgroundColor = const Color(0xFFE8F5E9);
        textColor = const Color(0xFF2E7D32);
        icon = Icons.swap_horiz_rounded;
        break;
      case 'closed':
        backgroundColor = const Color(0xFFF5F5F5);
        textColor = const Color(0xFF616161);
        icon = Icons.lock_outline_rounded;
        break;
      case 'cancelled':
        backgroundColor = const Color(0xFFFCE4EC);
        textColor = const Color(0xFFC2185B);
        icon = Icons.block_rounded;
        break;
      case 'draft':
      default:
        backgroundColor = const Color(0xFFF5F5F5);
        textColor = const Color(0xFF616161);
        icon = Icons.edit_note_rounded;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: textColor.withValues(alpha: 0.3), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: textColor),
          const SizedBox(width: 6),
          Text(
            _formatStatus(status),
            style: GoogleFonts.poppins(
              color: textColor,
              fontSize: 12,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.3,
            ),
          ),
        ],
      ),
    );
  }

  String _formatStatus(String status) {
    // Convert to title case
    return status
        .split('_')
        .map(
          (word) => word.isEmpty
              ? ''
              : word[0].toUpperCase() + word.substring(1).toLowerCase(),
        )
        .join(' ');
  }
}