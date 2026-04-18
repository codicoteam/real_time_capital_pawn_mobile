import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:real_time_pawn/core/utils/pallete.dart';
import 'package:real_time_pawn/models/loan_application_model.dart';

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
        return 'Electronics';
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
        return Icons.devices_rounded;
      case 'motor_vehicle':
        return Icons.directions_car_rounded;
      case 'jewellery':
        return Icons.diamond_rounded;
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

  Color _getStatusColor(String? status) {
    if (status == null) return RealTimeColors.grey600;

    switch (status.toLowerCase()) {
      case 'processing':
        return const Color(0xFFF57C00);
      case 'submitted':
        return const Color(0xFF1976D2);
      case 'approved':
        return const Color(0xFF388E3C);
      case 'rejected':
        return const Color(0xFFD32F2F);
      case 'cancelled':
        return const Color(0xFFC2185B);
      default:
        return RealTimeColors.grey600;
    }
  }

  Color _getStatusBackgroundColor(String? status) {
    if (status == null) return RealTimeColors.grey100;

    switch (status.toLowerCase()) {
      case 'processing':
        return const Color(0xFFFFF3E0);
      case 'submitted':
        return const Color(0xFFE3F2FD);
      case 'approved':
        return const Color(0xFFE8F5E9);
      case 'rejected':
        return const Color(0xFFFFEBEE);
      case 'cancelled':
        return const Color(0xFFFCE4EC);
      default:
        return RealTimeColors.grey100;
    }
  }

  String _getRepaymentTypeText(String? type) {
    if (type == null) return 'N/A';
    switch (type.toLowerCase()) {
      case 'once_off':
        return 'Once Off';
      case 'installment':
        return 'Installment';
      default:
        return type;
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
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.08),
                  blurRadius: 20,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(24),
              child: Stack(
                children: [
                  // Animated gradient background on hover (optional)
                  Positioned.fill(
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            _getCategoryColor(
                              application.collateralCategory,
                            ).withOpacity(0.05),
                            Colors.transparent,
                          ],
                        ),
                      ),
                    ),
                  ),

                  // Main content
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Header Row - Application Number and Status
                        Row(
                          children: [
                            // Application Number with icon
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    AppColors.primaryColor.withOpacity(0.15),
                                    AppColors.primaryColor.withOpacity(0.05),
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Icon(
                                Icons.receipt_long_rounded,
                                color: AppColors.primaryColor,
                                size: 20,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Application Number',
                                    style: GoogleFonts.poppins(
                                      color: AppColors.subtextColor,
                                      fontSize: 11,
                                      fontWeight: FontWeight.w500,
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    application.applicationNo ?? 'N/A',
                                    style: GoogleFonts.poppins(
                                      color: AppColors.textColor,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w700,
                                      letterSpacing: -0.3,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                            // Status Chip
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 8,
                              ),
                              decoration: BoxDecoration(
                                color: _getStatusBackgroundColor(
                                  application.status,
                                ),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: _getStatusColor(
                                    application.status,
                                  ).withOpacity(0.3),
                                  width: 1,
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    _getStatusIcon(application.status),
                                    size: 14,
                                    color: _getStatusColor(application.status),
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    _formatStatus(
                                      application.status ?? 'draft',
                                    ),
                                    style: GoogleFonts.poppins(
                                      color: _getStatusColor(
                                        application.status,
                                      ),
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 20),

                        // Divider with animation
                        Container(
                          height: 1,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                Colors.transparent,
                                AppColors.borderColor,
                                Colors.transparent,
                              ],
                            ),
                          ),
                        ),

                        const SizedBox(height: 20),

                        // Key Field 1: Loan Amount (Primary)
                        _buildInfoRow(
                          icon: Icons.account_balance_wallet_rounded,
                          label: 'Loan Amount',
                          value: _formatCurrency(
                            application.requestedLoanAmount,
                          ),
                          isPrimary: true,
                        ),

                        const SizedBox(height: 16),

                        // Key Field 2: Collateral Category
                        Row(
                          children: [
                            Expanded(
                              child: _buildInfoRow(
                                icon: _getCategoryIcon(
                                  application.collateralCategory,
                                ),
                                label: 'Collateral',
                                value: _formatCollateralCategory(
                                  application.collateralCategory,
                                ),
                                iconColor: _getCategoryColor(
                                  application.collateralCategory,
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _buildInfoRow(
                                icon: Icons.payment_rounded,
                                label: 'Repayment',
                                value: _getRepaymentTypeText(
                                  application.repaymentType,
                                ),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 16),

                        // Key Field 3: Application Date
                        _buildInfoRow(
                          icon: Icons.calendar_today_rounded,
                          label: 'Applied On',
                          value: _formatDate(application.createdAt),
                        ),

                        const SizedBox(height: 16),

                        // Optional: Quick details for the specific collateral
                        if (application.collateralCategory != null)
                          Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: _buildCollateralQuickInfo(),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        )
        .animate(onPlay: (controller) => controller.repeat(reverse: false))
        .fadeIn(
          delay: (index * 100).ms,
          duration: 500.ms,
          curve: Curves.easeOutCubic,
        )
        .slideX(
          begin: 0.3,
          end: 0,
          delay: (index * 100).ms,
          duration: 600.ms,
          curve: Curves.easeOutCubic,
        )
        .scale(
          begin: const Offset(0.95, 0.95),
          end: const Offset(1, 1),
          delay: (index * 100).ms,
          duration: 400.ms,
          curve: Curves.easeOutCubic,
        )
        .then()
        .shimmer(
          delay: (index * 150 + 500).ms,
          duration: 1500.ms,
          color: Colors.white.withOpacity(0.4),
        );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String label,
    required String value,
    bool isPrimary = false,
    Color? iconColor,
  }) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: (iconColor ?? AppColors.primaryColor).withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(
            icon,
            size: isPrimary ? 20 : 18,
            color: iconColor ?? AppColors.primaryColor,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: GoogleFonts.poppins(
                  color: AppColors.subtextColor,
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: GoogleFonts.poppins(
                  color: isPrimary
                      ? AppColors.primaryColor
                      : AppColors.textColor,
                  fontSize: isPrimary ? 20 : 14,
                  fontWeight: isPrimary ? FontWeight.w800 : FontWeight.w600,
                  letterSpacing: isPrimary ? -0.5 : 0,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCollateralQuickInfo() {
    final category = application.collateralCategory?.toLowerCase();

    if (category == 'small_loans' && application.smallLoanDetails != null) {
      return Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: _getCategoryColor(category).withOpacity(0.08),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: _getCategoryColor(category).withOpacity(0.2),
            width: 1,
          ),
        ),
        child: Row(
          children: [
            Icon(
              Icons.devices_rounded,
              size: 16,
              color: _getCategoryColor(category),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                '${application.smallLoanDetails?.type ?? ''} ${application.smallLoanDetails?.model ?? ''}',
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: _getCategoryColor(category),
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ).animate().fadeIn(duration: 300.ms).slideX(begin: 0.1);
    }

    if (category == 'motor_vehicle' &&
        application.motorVehicleDetails != null) {
      return Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: _getCategoryColor(category).withOpacity(0.08),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: _getCategoryColor(category).withOpacity(0.2),
            width: 1,
          ),
        ),
        child: Row(
          children: [
            Icon(
              Icons.directions_car_rounded,
              size: 16,
              color: _getCategoryColor(category),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                '${application.motorVehicleDetails?.make ?? ''} ${application.motorVehicleDetails?.model ?? ''}',
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: _getCategoryColor(category),
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ).animate().fadeIn(duration: 300.ms).slideX(begin: 0.1);
    }

    if (category == 'jewellery' && application.jewelleryDetails != null) {
      return Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: _getCategoryColor(category).withOpacity(0.08),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: _getCategoryColor(category).withOpacity(0.2),
            width: 1,
          ),
        ),
        child: Row(
          children: [
            Icon(
              Icons.diamond_rounded,
              size: 16,
              color: _getCategoryColor(category),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                '${application.jewelleryDetails?.type ?? ''} • ${application.jewelleryDetails?.purity ?? ''}',
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: _getCategoryColor(category),
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ).animate().fadeIn(duration: 300.ms).slideX(begin: 0.1);
    }

    return const SizedBox.shrink();
  }

  IconData _getStatusIcon(String? status) {
    if (status == null) return Icons.help_outline_rounded;

    switch (status.toLowerCase()) {
      case 'processing':
        return Icons.hourglass_empty_rounded;
      case 'submitted':
        return Icons.send_rounded;
      case 'approved':
        return Icons.check_circle_outline_rounded;
      case 'rejected':
        return Icons.cancel_outlined;
      case 'cancelled':
        return Icons.block_rounded;
      default:
        return Icons.edit_note_rounded;
    }
  }

  String _formatStatus(String status) {
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
