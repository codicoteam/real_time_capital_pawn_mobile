import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:real_time_pawn/core/utils/pallete.dart';
import 'package:real_time_pawn/models/loan_application.model.dart';

class LoanApplicationCard extends StatelessWidget {
  final LoanApplicationModel application;
  final int index;
  final VoidCallback? onTap;

  const LoanApplicationCard({
    super.key,
    required this.application,
    required this.index,
    this.onTap,
  });

  String _formatCurrency(int? amount) {
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
        // Convert snake_case to Title Case
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
                color: AppColors.primaryColor.withOpacity(0.3),
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primaryColor.withOpacity(0.08),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
                BoxShadow(
                  color: Colors.black.withOpacity(0.03),
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
                            AppColors.primaryColor.withOpacity(0.05),
                            AppColors.primaryColor.withOpacity(0.0),
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
                        // Application Number and Status
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: AppColors.primaryColor.withOpacity(
                                        0.1,
                                      ),
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
                                      application.applicationNo ?? 'N/A',
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
                            _buildStatusChip(application.status ?? 'draft'),
                          ],
                        ),
                        const SizedBox(height: 16),

                        // Divider
                        Container(
                          height: 1,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                AppColors.borderColor.withOpacity(0.1),
                                AppColors.borderColor,
                                AppColors.borderColor.withOpacity(0.1),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Applicant Name
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: AppColors.primaryColor.withOpacity(0.08),
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
                                    'Applicant',
                                    style: GoogleFonts.poppins(
                                      color: AppColors.subtextColor,
                                      fontSize: 11,
                                      fontWeight: FontWeight.w500,
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    application.fullName ?? 'N/A',
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

                        // Collateral Category and Date
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
                                  color: _getCategoryColor(
                                    application.collateralCategory,
                                  ).withOpacity(0.08),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: _getCategoryColor(
                                      application.collateralCategory,
                                    ).withOpacity(0.2),
                                    width: 1,
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    Icon(
                                      _getCategoryIcon(
                                        application.collateralCategory,
                                      ),
                                      color: _getCategoryColor(
                                        application.collateralCategory,
                                      ),
                                      size: 18,
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        _formatCollateralCategory(
                                          application.collateralCategory,
                                        ),
                                        style: GoogleFonts.poppins(
                                          color: _getCategoryColor(
                                            application.collateralCategory,
                                          ),
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

                            // Date
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
                                    _formatDate(application.createdAt),
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

                        // Amount with accent background
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                AppColors.primaryColor.withOpacity(0.12),
                                AppColors.primaryColor.withOpacity(0.05),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: AppColors.primaryColor.withOpacity(0.25),
                              width: 1.5,
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.account_balance_wallet_outlined,
                                        size: 14,
                                        color: AppColors.primaryColor,
                                      ),
                                      const SizedBox(width: 6),
                                      Text(
                                        'Requested Amount',
                                        style: GoogleFonts.poppins(
                                          color: AppColors.primaryColor,
                                          fontSize: 11,
                                          fontWeight: FontWeight.w600,
                                          letterSpacing: 0.5,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    _formatCurrency(
                                      application.requestedLoanAmount,
                                    ),
                                    style: GoogleFonts.poppins(
                                      color: AppColors.primaryColor,
                                      fontSize: 24,
                                      fontWeight: FontWeight.w800,
                                      letterSpacing: -0.5,
                                      height: 1,
                                    ),
                                  ),
                                ],
                              ),
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: AppColors.primaryColor.withOpacity(
                                    0.15,
                                  ),
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
          color: Colors.white.withOpacity(0.3),
        );
  }

  Widget _buildStatusChip(String status) {
    Color backgroundColor;
    Color textColor;
    IconData icon;

    switch (status.toLowerCase()) {
      case 'processing':
      case 'under_review':
        backgroundColor = const Color(0xFFFFF3E0);
        textColor = const Color(0xFFF57C00);
        icon = Icons.hourglass_empty_rounded;
        break;
      case 'submitted':
        backgroundColor = const Color(0xFFE3F2FD);
        textColor = const Color(0xFF1976D2);
        icon = Icons.send_rounded;
        break;
      case 'approved':
        backgroundColor = const Color(0xFFE8F5E9);
        textColor = const Color(0xFF388E3C);
        icon = Icons.check_circle_outline_rounded;
        break;
      case 'rejected':
      case 'declined':
        backgroundColor = const Color(0xFFFFEBEE);
        textColor = const Color(0xFFD32F2F);
        icon = Icons.cancel_outlined;
        break;
      case 'cancelled':
        backgroundColor = const Color(0xFFFCE4EC);
        textColor = const Color(0xFFC2185B);
        icon = Icons.block_rounded;
        break;
      case 'draft':
        backgroundColor = const Color(0xFFF5F5F5);
        textColor = const Color(0xFF616161);
        icon = Icons.edit_note_rounded;
        break;
      default:
        backgroundColor = RealTimeColors.grey200;
        textColor = RealTimeColors.grey700;
        icon = Icons.help_outline_rounded;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: textColor.withOpacity(0.3), width: 1),
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
