import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:real_time_pawn/core/utils/pallete.dart';
import 'package:real_time_pawn/core/utils/logs.dart';
import 'package:real_time_pawn/models/loan_application_model.dart';
import '../../../config/routers/router.dart';

class LoanApplicationDetailsScreen extends StatefulWidget {
  final LoanApplicationModel application;

  const LoanApplicationDetailsScreen({super.key, required this.application});

  @override
  State<LoanApplicationDetailsScreen> createState() =>
      _LoanApplicationDetailsScreenState();
}

class _LoanApplicationDetailsScreenState
    extends State<LoanApplicationDetailsScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  final ScrollController _scrollController = ScrollController();
  bool _showFab = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _animationController.forward();

    _scrollController.addListener(() {
      if (_scrollController.offset > 200 && !_showFab) {
        setState(() => _showFab = true);
      } else if (_scrollController.offset <= 200 && _showFab) {
        setState(() => _showFab = false);
      }
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  // ✅ Fixed: accepts double? so it works for both int and double amounts
  String _formatCurrency(double? amount) {
    if (amount == null) return '\$0.00';
    final formatter = NumberFormat.currency(symbol: '\$', decimalDigits: 2);
    return formatter.format(amount);
  }

  String _formatDate(DateTime? date) {
    if (date == null) return 'N/A';
    return DateFormat('MMMM dd, yyyy • hh:mm a').format(date);
  }

  String _formatDateShort(DateTime? date) {
    if (date == null) return 'N/A';
    return DateFormat('MMM dd, yyyy').format(date);
  }

  String _formatTimeAgo(DateTime? date) {
    if (date == null) return '';
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays > 7) {
      return _formatDateShort(date);
    } else if (difference.inDays > 0) {
      return '${difference.inDays} day${difference.inDays > 1 ? 's' : ''} ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} hour${difference.inHours > 1 ? 's' : ''} ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} minute${difference.inMinutes > 1 ? 's' : ''} ago';
    } else {
      return 'Just now';
    }
  }

  String _formatCollateralCategory(String? category) {
    if (category == null || category.isEmpty) return 'N/A';
    switch (category.toLowerCase()) {
      case 'small_loans':
        return '📱 Electronics';
      case 'motor_vehicle':
        return '🚗 Motor Vehicle';
      case 'jewellery':
        return '💎 Jewellery';
      default:
        return category;
    }
  }

  String _formatStatus(String? status) {
    if (status == null || status.isEmpty) return 'Submitted';
    return status
        .split('_')
        .map(
          (word) => word.isEmpty
              ? ''
              : word[0].toUpperCase() + word.substring(1).toLowerCase(),
        )
        .join(' ');
  }

  Color _getStatusColor(String? status) {
    switch (status?.toLowerCase()) {
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
        return const Color(0xFF1976D2);
    }
  }

  IconData _getStatusIcon(String? status) {
    switch (status?.toLowerCase()) {
      case 'processing':
        return Icons.hourglass_empty_rounded;
      case 'submitted':
        return Icons.send_rounded;
      case 'approved':
        return Icons.check_circle_rounded;
      case 'rejected':
        return Icons.cancel_rounded;
      case 'cancelled':
        return Icons.block_rounded;
      default:
        return Icons.pending_rounded;
    }
  }

  bool get _isEditable {
    final status = widget.application.status?.toLowerCase();
    return status != 'approved' &&
        status != 'rejected' &&
        status != 'cancelled';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      body: CustomScrollView(
        controller: _scrollController,
        physics: const BouncingScrollPhysics(),
        slivers: [
          _buildSliverAppBar(),
          SliverToBoxAdapter(
            child: Column(
              children: [
                const SizedBox(height: 16),
                _buildStatusCard().animate().fadeIn(
                  delay: 200.ms,
                  duration: 500.ms,
                  curve: Curves.easeOut,
                ),
                const SizedBox(height: 20),
                _buildAmountCard().animate().fadeIn(
                  delay: 300.ms,
                  duration: 500.ms,
                  curve: Curves.easeOut,
                ),
                const SizedBox(height: 20),
                _buildCustomerInfoCard().animate().fadeIn(
                  delay: 350.ms,
                  duration: 500.ms,
                  curve: Curves.easeOut,
                ),
                const SizedBox(height: 20),
                _buildCollateralCard().animate().fadeIn(
                  delay: 400.ms,
                  duration: 500.ms,
                  curve: Curves.easeOut,
                ),
                const SizedBox(height: 20),
                _buildRepaymentCard().animate().fadeIn(
                  delay: 500.ms,
                  duration: 500.ms,
                  curve: Curves.easeOut,
                ),
                const SizedBox(height: 20),
                _buildDebtorCheckCard().animate().fadeIn(
                  delay: 550.ms,
                  duration: 500.ms,
                  curve: Curves.easeOut,
                ),
                const SizedBox(height: 20),
                _buildDeclarationCard().animate().fadeIn(
                  delay: 600.ms,
                  duration: 500.ms,
                  curve: Curves.easeOut,
                ),
                const SizedBox(height: 20),
                if (widget.application.adminNotes != null &&
                    widget.application.adminNotes!.isNotEmpty)
                  _buildAdminNotesCard().animate().fadeIn(
                    delay: 650.ms,
                    duration: 500.ms,
                    curve: Curves.easeOut,
                  ),
                const SizedBox(height: 20),
                if (widget.application.collateralImages != null &&
                    widget.application.collateralImages!.isNotEmpty)
                  _buildCollateralImagesCard().animate().fadeIn(
                    delay: 700.ms,
                    duration: 500.ms,
                    curve: Curves.easeOut,
                  ),
                const SizedBox(height: 20),
                _buildMetadataCard().animate().fadeIn(
                  delay: 750.ms,
                  duration: 500.ms,
                  curve: Curves.easeOut,
                ),
                const SizedBox(height: 100),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: _isEditable
          ? AnimatedOpacity(
              opacity: _showFab ? 1.0 : 0.0,
              duration: const Duration(milliseconds: 300),
              child:
                  FloatingActionButton.extended(
                        onPressed: _navigateToUpdateScreen,
                        backgroundColor: AppColors.primaryColor,
                        elevation: 8,
                        icon: const Icon(Icons.edit_outlined, size: 20),
                        label: Text(
                          'Edit Application',
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      )
                      .animate(
                        onPlay: (controller) =>
                            controller.repeat(reverse: true),
                      )
                      .shimmer(
                        delay: 2000.ms,
                        duration: 1500.ms,
                        color: Colors.white.withValues(alpha: 0.3),
                      ),
            )
          : null,
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }

  void _navigateToUpdateScreen() {
    Get.toNamed(
      RoutesHelper.updateLoanApplication,
      arguments: widget.application,
    )?.then((result) {
      if (result == true && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Application updated successfully'),
            backgroundColor: AppColors.successColor,
            duration: Duration(seconds: 2),
          ),
        );
      }
    });
  }

  Widget _buildSliverAppBar() {
    return SliverAppBar(
      expandedHeight: 200,
      floating: false,
      pinned: true,
      elevation: 0,
      backgroundColor: AppColors.primaryColor,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
        onPressed: () => Navigator.pop(context),
      ),
      flexibleSpace: FlexibleSpaceBar(
        title: Text(
          'Loan Application Details',
          style: GoogleFonts.poppins(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
        background: Stack(
          fit: StackFit.expand,
          children: [
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    AppColors.primaryColor,
                    AppColors.primaryColor.withValues(alpha: 0.7),
                  ],
                ),
              ),
            ),
            Positioned(
              top: 80,
              right: -20,
              child: Container(
                width: 150,
                height: 150,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
              ),
            ),
            Positioned(
              bottom: -30,
              left: -30,
              child: Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.08),
                  shape: BoxShape.circle,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusCard() {
    final status = widget.application.status ?? 'submitted';
    final statusColor = _getStatusColor(status);
    final statusIcon = _getStatusIcon(status);
    final statusText = _formatStatus(status);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: statusColor.withValues(alpha: 0.15),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
        border: Border.all(color: statusColor.withValues(alpha: 0.2), width: 1),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: statusColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(statusIcon, color: statusColor, size: 28),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Current Status',
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    color: AppColors.subtextColor,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  statusText,
                  style: GoogleFonts.poppins(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: statusColor,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Application #${widget.application.applicationNo ?? 'N/A'}',
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
    );
  }

  Widget _buildAmountCard() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.primaryColor,
            AppColors.primaryColor.withValues(alpha: 0.85),
          ],
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryColor.withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.attach_money_rounded,
                  color: Colors.white,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'Requested Amount',
                style: GoogleFonts.poppins(
                  color: Colors.white.withValues(alpha: 0.9),
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            // ✅ Cast int? to double? for the unified _formatCurrency
            _formatCurrency(widget.application.requestedLoanAmount?.toDouble()),
            style: GoogleFonts.poppins(
              color: Colors.white,
              fontSize: 44,
              fontWeight: FontWeight.bold,
              letterSpacing: -1,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCustomerInfoCard() {
    final customer = widget.application.customerUser;
    if (customer == null) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 15,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.primaryColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.person_outline_rounded,
                  color: AppColors.primaryColor,
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'Customer Information',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          _buildDetailRow(
            'Full Name',
            '${customer.firstName ?? ''} ${customer.lastName ?? ''}'.trim(),
            Icons.badge_outlined,
          ),
          const SizedBox(height: 16),
          // ✅ Fixed: customer.email is now String? — no more enum mismatch
          _buildDetailRow(
            'Email',
            customer.email ?? 'N/A',
            Icons.email_outlined,
          ),
          const SizedBox(height: 16),
          _buildDetailRow(
            'Phone',
            customer.phone ?? 'N/A',
            Icons.phone_outlined,
          ),
          if (customer.nationalIdNumber != null) ...[
            const SizedBox(height: 16),
            _buildDetailRow(
              'National ID',
              customer.nationalIdNumber!,
              Icons.credit_card_outlined,
            ),
          ],
          if (customer.dateOfBirth != null) ...[
            const SizedBox(height: 16),
            _buildDetailRow(
              'Date of Birth',
              _formatDateShort(customer.dateOfBirth),
              Icons.cake_outlined,
            ),
          ],
          if (customer.address != null) ...[
            const SizedBox(height: 16),
            _buildDetailRow(
              'Address',
              customer.address!,
              Icons.location_on_outlined,
              isLongText: true,
            ),
          ],
          if (customer.gender != null) ...[
            const SizedBox(height: 16),
            _buildDetailRow('Gender', customer.gender!, Icons.wc_outlined),
          ],
          if (customer.maritalStatus != null) ...[
            const SizedBox(height: 16),
            _buildDetailRow(
              'Marital Status',
              customer.maritalStatus!,
              Icons.favorite_outlined,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildCollateralCard() {
    final category = widget.application.collateralCategory ?? '';
    final categoryDisplay = _formatCollateralCategory(category);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 15,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.primaryColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.security_rounded,
                  color: AppColors.primaryColor,
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'Collateral Information',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          _buildDetailRow('Category', categoryDisplay, Icons.category_outlined),

          if (category.toLowerCase() == 'jewellery' &&
              widget.application.jewelleryDetails != null) ...[
            const SizedBox(height: 16),
            _buildSubsectionHeader('Jewellery Details', Icons.diamond_outlined),
            const SizedBox(height: 12),
            if (widget.application.jewelleryDetails!.type != null)
              _buildDetailRow(
                'Type',
                widget.application.jewelleryDetails!.type!,
                Icons.label_outline,
                indent: true,
              ),
            if (widget.application.jewelleryDetails!.weight != null)
              _buildDetailRow(
                'Weight',
                '${widget.application.jewelleryDetails!.weight}g',
                Icons.fitness_center,
                indent: true,
              ),
            if (widget.application.jewelleryDetails!.purity != null)
              _buildDetailRow(
                'Purity',
                widget.application.jewelleryDetails!.purity!,
                Icons.star_outline,
                indent: true,
              ),
            if (widget.application.jewelleryDetails!.estimatedValue != null)
              _buildDetailRow(
                'Estimated Value',
                // ✅ Cast int? to double?
                _formatCurrency(
                  widget.application.jewelleryDetails!.estimatedValue
                      ?.toDouble(),
                ),
                Icons.monetization_on_outlined,
                indent: true,
              ),
            if (widget.application.jewelleryDetails!.description != null)
              _buildDetailRow(
                'Description',
                widget.application.jewelleryDetails!.description!,
                Icons.description_outlined,
                indent: true,
                isLongText: true,
              ),
          ],

          if (category.toLowerCase() == 'motor_vehicle' &&
              widget.application.motorVehicleDetails != null) ...[
            const SizedBox(height: 16),
            _buildSubsectionHeader(
              'Vehicle Details',
              Icons.directions_car_outlined,
            ),
            const SizedBox(height: 12),
            if (widget.application.motorVehicleDetails!.make != null)
              _buildDetailRow(
                'Make',
                widget.application.motorVehicleDetails!.make!,
                Icons.branding_watermark,
                indent: true,
              ),
            if (widget.application.motorVehicleDetails!.model != null)
              _buildDetailRow(
                'Model',
                widget.application.motorVehicleDetails!.model!,
                Icons.label_outline,
                indent: true,
              ),
            if (widget.application.motorVehicleDetails!.registrationNo != null)
              _buildDetailRow(
                'Registration No',
                widget.application.motorVehicleDetails!.registrationNo!,
                Icons.confirmation_number_outlined,
                indent: true,
              ),
            if (widget.application.motorVehicleDetails!.year != null)
              _buildDetailRow(
                'Year',
                widget.application.motorVehicleDetails!.year.toString(),
                Icons.calendar_today_outlined,
                indent: true,
              ),
            if (widget.application.motorVehicleDetails!.ccSerialNo != null)
              _buildDetailRow(
                'CC/Serial No',
                widget.application.motorVehicleDetails!.ccSerialNo!,
                Icons.qr_code,
                indent: true,
              ),
            if (widget.application.motorVehicleDetails!.engineNo != null)
              _buildDetailRow(
                'Engine No',
                widget.application.motorVehicleDetails!.engineNo!,
                Icons.engineering_outlined,
                indent: true,
              ),
            if (widget.application.motorVehicleDetails!.chassisNo != null)
              _buildDetailRow(
                'Chassis No',
                widget.application.motorVehicleDetails!.chassisNo!,
                Icons.view_quilt_outlined,
                indent: true,
              ),
          ],

          if (category.toLowerCase() == 'small_loans' &&
              widget.application.smallLoanDetails != null) ...[
            const SizedBox(height: 16),
            _buildSubsectionHeader(
              'Electronics Details',
              Icons.devices_outlined,
            ),
            const SizedBox(height: 12),
            if (widget.application.smallLoanDetails!.type != null)
              _buildDetailRow(
                'Type',
                widget.application.smallLoanDetails!.type!,
                Icons.device_hub,
                indent: true,
              ),
            if (widget.application.smallLoanDetails!.model != null)
              _buildDetailRow(
                'Model',
                widget.application.smallLoanDetails!.model!,
                Icons.label_outline,
                indent: true,
              ),
            if (widget.application.smallLoanDetails!.serialNo != null)
              _buildDetailRow(
                'Serial No',
                widget.application.smallLoanDetails!.serialNo!,
                Icons.qr_code,
                indent: true,
              ),
          ],

          if (widget.application.declaredAssetValue != null) ...[
            const SizedBox(height: 16),
            _buildDetailRow(
              'Declared Value',
              // ✅ Cast int? to double?
              _formatCurrency(
                widget.application.declaredAssetValue?.toDouble(),
              ),
              Icons.monetization_on_outlined,
            ),
          ],
          if (widget.application.collateralDescription != null &&
              widget.application.collateralDescription!.isNotEmpty) ...[
            const SizedBox(height: 16),
            _buildDetailRow(
              'Description',
              widget.application.collateralDescription!,
              Icons.description_outlined,
              isLongText: true,
            ),
          ],
          if (widget.application.suretyDescription != null &&
              widget.application.suretyDescription!.isNotEmpty) ...[
            const SizedBox(height: 16),
            _buildDetailRow(
              'Surety Details',
              widget.application.suretyDescription!,
              Icons.people_outline,
              isLongText: true,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildRepaymentCard() {
    final loanPeriodType = widget.application.loanPeriodType;
    final repaymentDays = widget.application.repaymentDays;
    final interestRate = widget.application.interestRate;
    final interestAmount = widget.application.interestAmount;
    final totalRepayable = widget.application.totalRepayableAmount;

    // Use backend values if present, otherwise derive from loan period
    double? storageRate = widget.application.storageRate;
    double? storageAmount = widget.application.storageAmount;
    if (storageRate == null && loanPeriodType != null) {
      storageRate = loanPeriodType == 'two_weeks' ? 18.0 : 21.0;
    }
    if (storageAmount == null &&
        storageRate != null &&
        widget.application.requestedLoanAmount != null) {
      storageAmount =
          widget.application.requestedLoanAmount! * storageRate / 100;
    }

    String periodLabel = 'N/A';
    if (loanPeriodType == 'two_weeks') {
      periodLabel = '2 Weeks';
    } else if (loanPeriodType == 'one_month') {
      periodLabel = '1 Month';
    } else if (loanPeriodType != null) {
      periodLabel = loanPeriodType;
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 15,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.primaryColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.payment_rounded,
                  color: AppColors.primaryColor,
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'Repayment Plan',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          _buildDetailRow(
            'Repayment Type',
            'Once Off Payment',
            Icons.schedule_rounded,
          ),
          const SizedBox(height: 16),
          _buildDetailRow(
            'Loan Period',
            periodLabel,
            Icons.calendar_view_week_outlined,
          ),
          if (repaymentDays != null) ...[
            const SizedBox(height: 16),
            _buildDetailRow(
              'Repayment Days',
              '$repaymentDays days',
              Icons.timer_rounded,
            ),
          ],
          if (interestRate != null) ...[
            const SizedBox(height: 16),
            _buildDetailRow(
              'Interest Rate',
              '${interestRate.toStringAsFixed(1)}%',
              Icons.percent_rounded,
            ),
          ],
          if (interestAmount != null) ...[
            const SizedBox(height: 16),
            _buildDetailRow(
              'Interest Amount',
              _formatCurrency(interestAmount),
              Icons.attach_money_rounded,
            ),
          ],
          if (storageRate != null) ...[
            const SizedBox(height: 16),
            _buildDetailRow(
              'Storage Rate',
              '${storageRate.toStringAsFixed(1)}%',
              Icons.warehouse_outlined,
            ),
          ],
          if (storageAmount != null) ...[
            const SizedBox(height: 16),
            _buildDetailRow(
              'Storage Fee',
              _formatCurrency(storageAmount),
              Icons.store_mall_directory_outlined,
            ),
          ],
          if (totalRepayable != null) ...[
            const SizedBox(height: 16),
            _buildDetailRow(
              'Total Repayable',
              _formatCurrency(totalRepayable),
              Icons.summarize_rounded,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildDebtorCheckCard() {
    final debtorCheck = widget.application.debtorCheck;
    if (debtorCheck == null || debtorCheck.checked != true) {
      return const SizedBox.shrink();
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: debtorCheck.matched == true
            ? AppColors.errorColor.withValues(alpha: 0.05)
            : AppColors.successColor.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: debtorCheck.matched == true
              ? AppColors.errorColor.withValues(alpha: 0.3)
              : AppColors.successColor.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: debtorCheck.matched == true
                  ? AppColors.errorColor.withValues(alpha: 0.1)
                  : AppColors.successColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(
              debtorCheck.matched == true
                  ? Icons.warning_amber_rounded
                  : Icons.verified_rounded,
              color: debtorCheck.matched == true
                  ? AppColors.errorColor
                  : AppColors.successColor,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Debtor Register Check',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textColor,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  debtorCheck.matched == true
                      ? 'Warning: Matched with debtor records'
                      : 'Clear: No debtor records found',
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    color: debtorCheck.matched == true
                        ? AppColors.errorColor
                        : AppColors.successColor,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                if (debtorCheck.matchedDebtorRecords != null &&
                    debtorCheck.matchedDebtorRecords!.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Text(
                    '${debtorCheck.matchedDebtorRecords!.length} record(s) found',
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: AppColors.subtextColor,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDeclarationCard() {
    final hasDeclaration =
        widget.application.declarationText != null ||
        widget.application.declarationSignedAt != null;

    if (!hasDeclaration) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 15,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.primaryColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.description_rounded,
                  color: AppColors.primaryColor,
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'Declaration',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textColor,
                ),
              ),
            ],
          ),
          if (widget.application.declarationText != null) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.backgroundColor,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                widget.application.declarationText!,
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  color: AppColors.textColor,
                  height: 1.5,
                ),
              ),
            ),
          ],
          if (widget.application.declarationSignatureName != null) ...[
            const SizedBox(height: 12),
            _buildDetailRow(
              'Signed by',
              widget.application.declarationSignatureName!,
              Icons.edit_note_rounded,
            ),
          ],
          if (widget.application.declarationSignedAt != null) ...[
            const SizedBox(height: 12),
            _buildDetailRow(
              'Signed on',
              _formatDate(widget.application.declarationSignedAt),
              Icons.schedule_rounded,
            ),
          ],
          if (widget.application.customTermsAndConditions != null &&
              widget.application.customTermsAndConditions!.isNotEmpty) ...[
            const SizedBox(height: 16),
            _buildDetailRow(
              'Custom Terms',
              widget.application.customTermsAndConditions!,
              Icons.privacy_tip_rounded,
              isLongText: true,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildAdminNotesCard() {
    final notes = widget.application.adminNotes ?? [];

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 15,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.orange.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.admin_panel_settings_rounded,
                  color: Colors.orange,
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'Admin Notes (${notes.length})',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: notes.length,
            separatorBuilder: (context, index) => const Divider(height: 16),
            itemBuilder: (context, index) {
              final note = notes[index];
              return Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.orange.shade50,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: Colors.orange.shade100,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(
                            Icons.comment_rounded,
                            size: 16,
                            color: Colors.orange.shade700,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            note.note ?? 'No content',
                            style: GoogleFonts.poppins(
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                              color: AppColors.textColor,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(
                          Icons.person_outline,
                          size: 12,
                          color: AppColors.subtextColor,
                        ),
                        const SizedBox(width: 4),
                        // ✅ Fixed: createdBy.firstName is now String?
                        Text(
                          note.createdBy?.firstName ?? 'Admin',
                          style: GoogleFonts.poppins(
                            fontSize: 11,
                            color: AppColors.subtextColor,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Icon(
                          Icons.access_time,
                          size: 12,
                          color: AppColors.subtextColor,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          _formatTimeAgo(note.createdAt),
                          style: GoogleFonts.poppins(
                            fontSize: 11,
                            color: AppColors.subtextColor,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildCollateralImagesCard() {
    final images = widget.application.collateralImages ?? [];
    if (images.isEmpty) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 15,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.primaryColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.photo_library_rounded,
                  color: AppColors.primaryColor,
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'Collateral Photos (${images.length})',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 120,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: images.length,
              itemBuilder: (context, index) {
                return GestureDetector(
                  onTap: () => _showImageModal(images[index]),
                  child: Container(
                    width: 120,
                    height: 120,
                    margin: const EdgeInsets.only(right: 12),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.borderColor),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.network(
                        images[index],
                        fit: BoxFit.cover,
                        loadingBuilder: (context, child, loadingProgress) {
                          if (loadingProgress == null) return child;
                          return Container(
                            color: RealTimeColors.grey200,
                            child: const Center(
                              child: CircularProgressIndicator(),
                            ),
                          );
                        },
                        errorBuilder: (context, error, stackTrace) => Container(
                          color: RealTimeColors.grey200,
                          child: const Icon(
                            Icons.broken_image,
                            color: AppColors.subtextColor,
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetadataCard() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: RealTimeColors.grey100,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Additional Information',
            style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.subtextColor,
            ),
          ),
          const SizedBox(height: 12),
          _buildMetaRow(
            'Application Source',
            widget.application.applicationSource ?? 'N/A',
          ),
          _buildMetaRow(
            'Created At',
            _formatDate(widget.application.createdAt),
          ),
          if (widget.application.updatedAt != null)
            _buildMetaRow(
              'Last Updated',
              _formatDate(widget.application.updatedAt),
            ),
        ],
      ),
    );
  }

  Widget _buildMetaRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: GoogleFonts.poppins(
                fontSize: 12,
                color: AppColors.subtextColor,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: GoogleFonts.poppins(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: AppColors.textColor,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSubsectionHeader(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 16, color: AppColors.primaryColor),
        const SizedBox(width: 8),
        Text(
          title,
          style: GoogleFonts.poppins(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: AppColors.primaryColor,
          ),
        ),
      ],
    );
  }

  Widget _buildDetailRow(
    String label,
    String value,
    IconData icon, {
    bool isLongText = false,
    bool indent = false,
  }) {
    return Padding(
      padding: EdgeInsets.only(left: indent ? 16 : 0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: RealTimeColors.grey100,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, size: 16, color: AppColors.subtextColor),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: AppColors.subtextColor,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: GoogleFonts.poppins(
                    fontSize: isLongText ? 13 : 14,
                    fontWeight: isLongText
                        ? FontWeight.normal
                        : FontWeight.w500,
                    color: AppColors.textColor,
                    height: 1.4,
                  ),
                  maxLines: isLongText ? 3 : null,
                  overflow: isLongText ? TextOverflow.ellipsis : null,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showImageModal(String imageUrl) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.all(16),
        child: Stack(
          alignment: Alignment.topRight,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: InteractiveViewer(
                child: Image.network(
                  imageUrl,
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) => Container(
                    color: Colors.black54,
                    height: 300,
                    width: double.infinity,
                    child: const Center(
                      child: Icon(
                        Icons.broken_image,
                        size: 60,
                        color: Colors.white54,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            Positioned(
              top: 8,
              right: 8,
              child: IconButton(
                icon: const Icon(Icons.close, color: Colors.white),
                onPressed: () => Navigator.pop(context),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
