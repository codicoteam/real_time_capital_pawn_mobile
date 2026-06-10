import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:real_time_pawn/config/routers/router.dart';
import 'package:real_time_pawn/core/utils/pallete.dart';
import 'package:real_time_pawn/features/loan_mngmt/controllers/loan_mngmt_controller.dart';
import 'package:real_time_pawn/models/loan_mngmt_model.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:shimmer/shimmer.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';
import '../../attached_files_mngmt/controllers/attached_files_mngmt_controller.dart'
    show AttachmentController;
import '../../loan_terms_mngmt/controllers/loan_terms_mngmt_controller.dart'
    show LoanTermsController;

class LoanDetailsScreen extends StatefulWidget {
  final LoanModel loan;

  const LoanDetailsScreen({super.key, required this.loan});

  @override
  State<LoanDetailsScreen> createState() => _LoanDetailsScreenState();
}

class _LoanDetailsScreenState extends State<LoanDetailsScreen>
    with SingleTickerProviderStateMixin {
  late final LoanController _loanController;
  late final AttachmentController _attachmentController;
  late final LoanTermsController _loanTermsController;

  late LoanModel _loan;
  bool _isRefreshing = false;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;


  @override
  void initState() {
    super.initState();
    _loanController = Get.put(LoanController());
    _attachmentController = Get.put(AttachmentController());
    _loanTermsController = Get.put(LoanTermsController());
    _loan = widget.loan;

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );
    _animationController.forward();

    _loadAttachments();
    _loadLoanTerms();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _loadAttachments() async {
    final customerId = _loan.customerUser?.id;
    final applicationId = _loan.application?.id;
    if (customerId != null && applicationId != null) {
      await _attachmentController.fetchAttachmentsByUserAndEntity(
        userId: customerId,
        entityType: 'LoanApplication',
        entityId: applicationId,
      );
    }
  }

  Future<void> _loadLoanTerms() async {
    if (_loan.id != null) {
      await _loanTermsController.fetchLoanTerms(_loan.id!, refresh: true);
    }
  }

  Future<void> _refreshLoan() async {
    if (!mounted) return;
    setState(() => _isRefreshing = true);
    try {
      final updated = await _loanController.getLoanDetails(_loan.id!);
      if (updated != null && mounted) {
        setState(() => _loan = updated);
      }
    } finally {
      if (mounted) setState(() => _isRefreshing = false);
    }
  }

  bool get _isPaymentEnabled {
    final status = (_loan.status ?? '').toLowerCase();
    return status == 'active' || status == 'in_grace';
  }

  Future<void> _loadChargesAndNavigate() async {
    if (_loan.id == null) return;
    Get.dialog(
      const Center(
        child: CircularProgressIndicator(color: AppColors.primaryColor),
      ),
      barrierDismissible: false,
    );
    try {
      final charges = await _loanController.calculateLoanCharges(_loan.id!);
      if (Get.isDialogOpen == true) Get.back();
      final totalDue = (charges?['total_due'] as num?)?.toDouble() ??
          (charges?['principal'] as num?)?.toDouble() ??
          0.0;
      Get.toNamed(
        RoutesHelper.CreatePaymentScreen,
        arguments: {
          'loanId': _loan.id,
          'loanNo': _loan.loanNo,
          'amount': totalDue,    // use 'amount' key the router reads
          'charges': charges,    // use 'charges' key the router reads
        },
      );
    } catch (e) {
      if (Get.isDialogOpen == true) Get.back();
      Get.snackbar('Error', 'Failed to load loan charges',
          backgroundColor: RealTimeColors.error, colorText: Colors.white);
    }
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'active':
        return const Color(0xFF22C55E);
      case 'overdue':
        return const Color(0xFFEF4444);
      case 'redeemed':
        return const Color(0xFF22C55E);
      case 'pending_approval':
      case 'draft':
      case 'approved':
        return const Color(0xFFF59E0B);
      case 'defaulted':
      case 'written_off':
      case 'cancelled':
        return const Color(0xFFEF4444);
      case 'in_grace':
        return const Color(0xFFF97316);
      case 'partially_paid':
        return const Color(0xFF3B82F6);
      default:
        return AppColors.subtextColor;
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status.toLowerCase()) {
      case 'active':
        return Icons.check_circle_rounded;
      case 'overdue':
        return Icons.warning_rounded;
      case 'redeemed':
        return Icons.verified_rounded;
      case 'pending_approval':
      case 'draft':
      case 'approved':
        return Icons.hourglass_top_rounded;
      case 'defaulted':
      case 'written_off':
      case 'cancelled':
        return Icons.cancel_rounded;
      case 'in_grace':
        return Icons.timer_rounded;
      case 'partially_paid':
        return Icons.pie_chart_rounded;
      default:
        return Icons.help_outline_rounded;
    }
  }

  String _formatDateFull(DateTime? date) {
    if (date == null) return 'N/A';
    const monthNames = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    return '${date.day} ${monthNames[date.month - 1]} ${date.year}';
  }

  String _formatDateTime(DateTime? date) {
    if (date == null) return 'N/A';
    return '${_formatDateFull(date)} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }

  String _formatCurrency(num? amount) {
    if (amount == null) return 'N/A';
    final currency = _loan.currency ?? 'USD';
    final formatted = amount.abs().toStringAsFixed(2).replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]},',
    );
    return '$currency $formatted';
  }

  String _getCustomerName() {
    final first = _loan.customerUser?.firstName ?? '';
    final last = _loan.customerUser?.lastName ?? '';
    if (first.isNotEmpty || last.isNotEmpty) return '$first $last'.trim();
    return 'N/A';
  }

  String _getStatusLabel(String? status) {
    switch ((status ?? '').toLowerCase()) {
      case 'draft': return 'Draft';
      case 'pending_approval': return 'Pending Approval';
      case 'approved': return 'Approved';
      case 'active': return 'Active';
      case 'overdue': return 'Overdue';
      case 'in_grace': return 'In Grace Period';
      case 'partially_paid': return 'Partially Paid';
      case 'redeemed': return 'Redeemed';
      case 'defaulted': return 'Defaulted';
      case 'written_off': return 'Written Off';
      case 'cancelled': return 'Cancelled';
      default: return (status ?? 'Unknown').toUpperCase();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _refreshLoan,
          color: AppColors.primaryColor,
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              _buildAppBar(),
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    FadeTransition(
                      opacity: _fadeAnimation,
                      child: _isRefreshing
                          ? const Padding(
                              padding: EdgeInsets.symmetric(vertical: 60),
                              child: Center(child: CircularProgressIndicator()),
                            )
                          : Column(
                              children: [
                                const SizedBox(height: 16),
                                _buildQuickStats(),
                                const SizedBox(height: 12),
                                _buildPenaltyBanner(),
                                const SizedBox(height: 20),
                                _buildQuickActions(),
                                const SizedBox(height: 20),
                                _buildLoanInfo(),
                                const SizedBox(height: 16),
                                _buildRepaymentInfo(),
                                const SizedBox(height: 16),
                                _buildCollateralInfo(),
                                const SizedBox(height: 16),
                                _buildCustomerInfo(),
                                const SizedBox(height: 16),
                                _buildPaymentsHistory(),
                                const SizedBox(height: 16),
                                _buildSuperAdminApprovals(),
                                const SizedBox(height: 16),
                                _buildAdditionalDetails(),
                                const SizedBox(height: 16),
                                _buildAttachmentsSection(),
                                const SizedBox(height: 16),
                            
                              ],
                            ),
                    ),
                  ]),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAppBar() {
    final statusColor = _getStatusColor(_loan.status ?? 'unknown');
    return SliverAppBar(
      pinned: true,
      floating: true,
      expandedHeight: 110,
      backgroundColor: AppColors.surfaceColor,
      elevation: 0,
      surfaceTintColor: Colors.transparent,
      leading: IconButton(
        icon: Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: AppColors.backgroundColor,
            borderRadius: BorderRadius.circular(10),
          ),
          child: const Icon(Icons.arrow_back_ios_new_rounded,
              color: AppColors.textColor, size: 16),
        ),
        onPressed: () => Get.back(),
      ),
      flexibleSpace: FlexibleSpaceBar(
        titlePadding: const EdgeInsets.only(left: 56, bottom: 14),
        title: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Loan Details',
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: AppColors.textColor,
              ),
            ),
            Text(
              _loan.loanNo ?? 'N/A',
              style: GoogleFonts.poppins(
                fontSize: 11,
                color: AppColors.subtextColor,
              ),
            ),
          ],
        ),
      ),
      actions: [
        Container(
          margin: const EdgeInsets.only(right: 16, top: 8, bottom: 8),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: statusColor.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: statusColor.withValues(alpha: 0.4)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(_getStatusIcon(_loan.status ?? 'unknown'),
                  size: 13, color: statusColor),
              const SizedBox(width: 5),
              Text(
                _getStatusLabel(_loan.status),
                style: GoogleFonts.poppins(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: statusColor,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPenaltyBanner() {
    final status         = (_loan.status ?? '').toLowerCase();
    final bd             = _loan.repaymentBreakdown;
    final penaltyApplied = bd != null && bd['penalty_applied'] == true;
    final graceDays      = _loan.graceDays ?? 7;
    final penaltyPct     = (bd?['penalty_percent'] as num?)?.toDouble()
        ?? _loan.penaltyPercent?.toDouble()
        ?? 10.0;

    // Resolve state → accent colour, icon, title, notice text
    final Color accent;
    final IconData headerIcon;
    final String headerTitle;
    final String noticeText;

    if (status == 'auction') {
      accent      = RealTimeColors.error;
      headerIcon  = Icons.gavel_rounded;
      headerTitle = 'Asset Listed for Auction';
      noticeText  = 'Your collateral has been listed for public auction because the '
          '$graceDays-day grace period expired without full repayment. '
          'Contact us immediately to discuss redemption options.';
    } else if (status == 'in_grace' || penaltyApplied) {
      accent      = RealTimeColors.error;
      headerIcon  = Icons.warning_amber_rounded;
      headerTitle = 'Grace Period Active — Act Now';
      final penaltyAmount = (bd?['penalty_amount'] as num?)?.toDouble() ?? 0.0;
      int daysRemaining = graceDays;
      final due = _loan.dueDate;
      if (due != null) {
        daysRemaining = due
            .add(Duration(days: graceDays))
            .difference(DateTime.now())
            .inDays
            .clamp(0, graceDays);
      }
      noticeText = 'A ${penaltyPct.toStringAsFixed(0)}% late penalty of '
          '${_formatCurrency(penaltyAmount)} has been added to your balance. '
          'You have $daysRemaining day${daysRemaining == 1 ? '' : 's'} remaining '
          'in the $graceDays-day grace period. After that, your asset is automatically auctioned.';
    } else if (status == 'active' || status == 'overdue') {
      accent      = RealTimeColors.warning;
      headerIcon  = Icons.info_outline_rounded;
      headerTitle = 'Grace Period & Penalty Policy';
      noticeText  = 'If not repaid by the due date, a $graceDays-day grace period begins and '
          'a ${penaltyPct.toStringAsFixed(0)}% penalty is immediately added to your outstanding balance. '
          'If not cleared within those $graceDays days, your collateral is automatically listed for auction.';
    } else {
      return const SizedBox.shrink();
    }

    // Extra rows for in-grace state
    final bool showGraceRows = (status == 'in_grace' || penaltyApplied);
    final penaltyAmount  = (bd?['penalty_amount'] as num?)?.toDouble() ?? 0.0;
    final balanceBefore  = (bd?['balance_before_penalty'] as num?)?.toDouble()
        ?? (_loan.currentBalance ?? 0.0) - penaltyAmount;
    final totalNow       = _loan.currentBalance ?? 0.0;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surfaceColor,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: accent.withValues(alpha: 0.35)),
        boxShadow: [
          BoxShadow(
            color: accent.withValues(alpha: 0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header row
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: accent.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(headerIcon, size: 19, color: accent),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  headerTitle,
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: accent,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),

          // Notice box
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: accent.withValues(alpha: 0.07),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: accent.withValues(alpha: 0.2)),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.info_rounded, size: 15, color: accent),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    noticeText,
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: AppColors.textColor,
                      height: 1.55,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Stat rows — always shown
          _penaltyStat(Icons.hourglass_bottom_rounded, 'Grace Period',
              '$graceDays days after due date', accent),
          _penaltyStat(Icons.percent_rounded, 'Penalty Rate',
              '${penaltyPct.toStringAsFixed(0)}% of outstanding balance', accent),

          if (showGraceRows) ...[
            _penaltyStat(Icons.monetization_on_rounded, 'Balance Before Penalty',
                _formatCurrency(balanceBefore), AppColors.subtextColor),
            _penaltyStat(Icons.add_circle_outline_rounded, 'Penalty Added',
                '+ ${_formatCurrency(penaltyAmount)}', RealTimeColors.error, bold: true),
            _penaltyStat(Icons.account_balance_wallet_rounded, 'Total to Pay Now',
                _formatCurrency(totalNow), accent, bold: true),
          ],

          _penaltyStat(
            Icons.check_circle_outline_rounded,
            'Penalty Status',
            penaltyApplied
                ? 'Applied to balance'
                : (status == 'overdue')
                    ? 'Due — not yet processed'
                    : 'Not yet applied',
            penaltyApplied
                ? RealTimeColors.error
                : (status == 'overdue')
                    ? RealTimeColors.warning
                    : RealTimeColors.success,
          ),
        ],
      ),
    );
  }

  Widget _penaltyStat(IconData icon, String label, String value, Color color,
      {bool bold = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: 17, color: color),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(label,
                style: GoogleFonts.poppins(
                    fontSize: 13, color: AppColors.subtextColor)),
          ),
          Text(
            value,
            style: GoogleFonts.poppins(
              fontSize: 13,
              fontWeight: bold ? FontWeight.w700 : FontWeight.w600,
              color: bold ? color : AppColors.textColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickStats() {
    final paidAmount =
        (_loan.principalAmount ?? 0) - (_loan.currentBalance ?? 0);
    final progress = _loan.principalAmount != null && _loan.principalAmount! > 0
        ? (paidAmount / _loan.principalAmount!).clamp(0.0, 1.0)
        : 0.0;
    final statusColor = _getStatusColor(_loan.status ?? 'unknown');

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.surfaceColor,
            AppColors.surfaceColor.withValues(alpha: 0.95),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.borderColor),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  label: 'Loan Amount',
                  value: _formatCurrency(_loan.principalAmount),
                  color: AppColors.primaryColor,
                  icon: Icons.monetization_on_outlined,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  label: 'Amount Paid',
                  value: _formatCurrency(paidAmount),
                  color: const Color(0xFF22C55E),
                  icon: Icons.check_circle_outline_rounded,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _buildStatCard(
            label: 'Outstanding Balance',
            value: _formatCurrency(_loan.currentBalance),
            color: const Color(0xFFF59E0B),
            icon: Icons.account_balance_wallet_outlined,
            isWide: true,
          ),
          const SizedBox(height: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Repayment Progress',
                    style: GoogleFonts.poppins(
                      fontSize: 11,
                      color: AppColors.subtextColor,
                    ),
                  ),
                  Text(
                    '${(progress * 100).toStringAsFixed(1)}%',
                    style: GoogleFonts.poppins(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: statusColor,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: LinearProgressIndicator(
                  value: progress,
                  backgroundColor: AppColors.borderColor,
                  valueColor: AlwaysStoppedAnimation<Color>(statusColor),
                  minHeight: 8,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard({
    required String label,
    required String value,
    required Color color,
    required IconData icon,
    bool isWide = false,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: 18, color: color),
          ),
          const SizedBox(width: 10),
          Expanded(
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
                const SizedBox(height: 2),
                Text(
                  value,
                  style: GoogleFonts.poppins(
                    fontSize: isWide ? 18 : 14,
                    fontWeight: FontWeight.w700,
                    color: color,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions() {
    final paymentEnabled = _isPaymentEnabled;
    final disabledReason = paymentEnabled
        ? null
        : 'Payment not available for ${_getStatusLabel(_loan.status)} loans';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Quick Actions',
          style: GoogleFonts.poppins(
            fontSize: 15,
            fontWeight: FontWeight.w700,
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
                onTap: paymentEnabled ? _loadChargesAndNavigate : null,
                color: const Color(0xFF22C55E),
                isDisabled: !paymentEnabled,
                disabledReason: disabledReason,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildActionButton(
                icon: Icons.receipt_long_outlined,
                label: 'View Charges',
                onTap: () => Get.toNamed(
                  RoutesHelper.LoanChargesScreen,
                  arguments: {'loanId': _loan.id},
                ),
                color: const Color(0xFF3B82F6),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required VoidCallback? onTap,
    required Color color,
    bool isDisabled = false,
    String? disabledReason,
  }) {
    final effectiveColor = isDisabled ? AppColors.subtextColor : color;

    return Tooltip(
      message: isDisabled ? (disabledReason ?? '') : '',
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isDisabled
                ? AppColors.surfaceColor.withValues(alpha: 0.5)
                : effectiveColor.withValues(alpha: 0.07),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: isDisabled
                  ? AppColors.borderColor
                  : effectiveColor.withValues(alpha: 0.3),
            ),
          ),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: isDisabled
                      ? AppColors.borderColor.withValues(alpha: 0.5)
                      : effectiveColor.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  isDisabled ? Icons.block_rounded : icon,
                  color: effectiveColor,
                  size: 22,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                label,
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: isDisabled ? AppColors.subtextColor : AppColors.textColor,
                ),
                textAlign: TextAlign.center,
              ),
              if (isDisabled && disabledReason != null) ...[
                const SizedBox(height: 4),
                Text(
                  'Not Available',
                  style: GoogleFonts.poppins(
                    fontSize: 9,
                    color: AppColors.subtextColor,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLoanInfo() {
    return _buildSectionCard(
      title: 'Loan Information',
      icon: Icons.info_outline_rounded,
      children: [
        _buildInfoRow('Loan Number', _loan.loanNo ?? 'N/A'),
        _buildInfoRow('Loan Date', _formatDateFull(_loan.startDate)),
        _buildInfoRow('Due Date', _formatDateFull(_loan.dueDate)),
        _buildInfoRow(
          'Interest Rate',
          '${_loan.interestRatePercent ?? 0}% / month',
        ),
        _buildInfoRow('Interest Period', '${_loan.interestPeriodDays ?? 0} days'),
        _buildInfoRow('Grace Period', '${_loan.graceDays ?? 7} days'),
        _buildInfoRow('Repayment Type', _loan.repaymentType ?? 'N/A'),
        _buildInfoRow('Currency', _loan.currency ?? 'USD'),
        _buildInfoRow('Approval Status', _loan.approvalStatus ?? 'N/A'),
        if (_loan.requiresSuperAdminApproval == true)
          _buildInfoRow('Super Admin Required', 'Yes', highlight: true),
      ],
    );
  }

  Widget _buildRepaymentInfo() {
    final totalPaid = _loan.totalPaid ?? 0;
    final bd = _loan.repaymentBreakdown;
    final penaltyApplied = bd != null && bd['penalty_applied'] == true;
    final penaltyAmount =
        (bd?['penalty_amount'] as num?)?.toDouble() ?? 0.0;
    final penaltyPercent = (bd?['penalty_percent'] as num?)?.toDouble()
        ?? _loan.penaltyPercent
        ?? 10.0;
    final balanceBefore =
        (bd?['balance_before_penalty'] as num?)?.toDouble()
        ?? (_loan.currentBalance ?? 0) - penaltyAmount;
    final expectedTotal = penaltyApplied
        ? _loan.currentBalance ?? 0
        : _loan.expectedTotalRepayable ?? _loan.principalAmount ?? 0;

    return _buildSectionCard(
      title: 'Repayment Summary',
      icon: Icons.account_balance_outlined,
      children: [
        _buildInfoRow('Principal', _formatCurrency(_loan.principalAmount)),
        if (_loan.interestAmount != null)
          _buildInfoRow('Interest (${_loan.interestRatePercent?.toStringAsFixed(0) ?? 0}%)',
              _formatCurrency(_loan.interestAmount)),
        if (_loan.storageChargeAmount != null)
          _buildInfoRow('Storage (${_loan.storageChargePercent?.toStringAsFixed(0) ?? 0}%)',
              _formatCurrency(_loan.storageChargeAmount)),
        if (penaltyApplied) ...[
          _buildInfoRow('Balance Before Penalty', _formatCurrency(balanceBefore)),
          _buildInfoRow(
            'Penalty (${penaltyPercent.toStringAsFixed(0)}%)',
            '+ ${_formatCurrency(penaltyAmount)}',
            valueColor: const Color(0xFFEF4444),
          ),
        ],
        _buildInfoRow(
          penaltyApplied ? 'Total (incl. penalty)' : 'Total to Repay',
          _formatCurrency(expectedTotal),
          valueColor: penaltyApplied
              ? const Color(0xFFF87171)
              : const Color(0xFF22C55E),
          bold: true,
        ),
        _buildInfoRow('Total Paid', _formatCurrency(totalPaid),
            valueColor: const Color(0xFF22C55E)),
        _buildInfoRow(
          'Outstanding Balance',
          _formatCurrency(_loan.currentBalance),
          valueColor: const Color(0xFFF59E0B),
          bold: true,
        ),
        if (_loan.payments != null && _loan.payments!.isNotEmpty) ...[
          _buildInfoRow('Payments Count', '${_loan.payments!.length}'),
          const SizedBox(height: 8),
          _buildSubTitle('Latest Payment'),
          const SizedBox(height: 4),
          _buildInfoRow('Amount', _formatCurrency(_loan.payments!.last.amount)),
          _buildInfoRow('Date', _formatDateTime(_loan.payments!.last.paymentDate)),
          _buildInfoRow('Method', _loan.payments!.last.paymentMethod ?? 'N/A'),
        ],
      ],
    );
  }

  Widget _buildCollateralInfo() {
    final List<Widget> children = [
      _buildInfoRow('Category', _loan.collateralCategory ?? 'N/A'),
    ];

    if (_loan.asset != null) {
      final asset = _loan.asset!;
      children.add(_buildInfoRow('Asset Number', asset.assetNo ?? 'N/A'));
      children.add(_buildInfoRow('Asset Title', asset.title ?? 'N/A'));
      children.add(_buildInfoRow('Asset Category', asset.category ?? 'N/A'));
      children.add(_buildInfoRow('Asset Status', asset.status ?? 'N/A'));
      if (asset.evaluatedValue != null) {
        children.add(_buildInfoRow(
          'Evaluated Value',
          _formatCurrency(asset.evaluatedValue),
        ));
      }

      if (asset.assetImages != null && asset.assetImages!.isNotEmpty) {
        children.add(const SizedBox(height: 14));
        children.add(_buildSubTitle('Asset Images'));
        children.add(const SizedBox(height: 10));
        children.add(_buildImageGrid(asset.assetImages!));
      }
    }

    final app = _loan.application;
    if (app != null) {
      if (app.declaredAssetValue != null) {
        children.add(_buildInfoRow(
          'Declared Value',
          _formatCurrency(app.declaredAssetValue),
        ));
      }
      if (app.collateralDescription != null &&
          app.collateralDescription!.isNotEmpty) {
        children.add(_buildInfoRow('Description', app.collateralDescription!));
      }
    }

    return _buildSectionCard(
      title: 'Collateral Information',
      icon: Icons.inventory_2_outlined,
      children: children,
    );
  }

  Widget _buildCustomerInfo() {
    final app = _loan.application;
    return _buildSectionCard(
      title: 'Customer Information',
      icon: Icons.person_outline_rounded,
      children: [
        _buildInfoRow('Name', _getCustomerName()),
        if (_loan.customerUser != null) ...[
          _buildInfoRow('Email', _loan.customerUser!.email ?? 'N/A'),
          _buildInfoRow('Phone', _loan.customerUser!.phone ?? 'N/A'),
          _buildInfoRow('National ID', _loan.customerUser!.nationalIdNumber ?? 'N/A'),
        ],
        if (app != null) ...[
          const Divider(height: 24),
          _buildInfoRow('Application No', app.applicationNo ?? 'N/A'),
          _buildInfoRow(
            'Requested Amount',
            _formatCurrency(app.requestedLoanAmount),
          ),
          _buildInfoRow('Application Status', app.status ?? 'N/A'),
        ],
      ],
    );
  }

  Widget _buildPaymentsHistory() {
    if (_loan.payments == null || _loan.payments!.isEmpty) {
      return const SizedBox.shrink();
    }

    final displayCount =
        _loan.payments!.length > 5 ? 5 : _loan.payments!.length;

    return _buildSectionCard(
      title: 'Payment History',
      icon: Icons.history_rounded,
      children: [
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: displayCount,
          separatorBuilder: (_, i) => Divider(
            height: 1,
            color: AppColors.borderColor,
          ),
          itemBuilder: (context, index) {
            final payment = _loan.payments![index];
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: const Color(0xFF22C55E).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.payment_rounded,
                      color: Color(0xFF22C55E),
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _formatCurrency(payment.amount),
                          style: GoogleFonts.poppins(
                            fontWeight: FontWeight.w700,
                            fontSize: 14,
                            color: const Color(0xFF22C55E),
                          ),
                        ),
                        Text(
                          payment.paymentMethod ?? 'Unknown method',
                          style: GoogleFonts.poppins(
                            fontSize: 11,
                            color: AppColors.subtextColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    _formatDateFull(payment.paymentDate),
                    style: GoogleFonts.poppins(
                      fontSize: 11,
                      color: AppColors.subtextColor,
                    ),
                  ),
                ],
              ),
            );
          },
        ),
        if (_loan.payments!.length > 5)
          Padding(
            padding: const EdgeInsets.only(top: 10),
            child: Center(
              child: TextButton.icon(
                onPressed: () => Get.toNamed(
                  RoutesHelper.PaymentListScreen,
                  arguments: {'loanId': _loan.id, 'isLoanPayments': true},
                ),
                icon: const Icon(Icons.visibility_outlined, size: 16),
                label: Text(
                  'View All ${_loan.payments!.length} Payments',
                  style: GoogleFonts.poppins(fontSize: 13),
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildSuperAdminApprovals() {
    final hasRequests = _loan.requestedSuperAdmins?.isNotEmpty ?? false;
    final hasApprovals = _loan.superAdminApprovals?.isNotEmpty ?? false;

    if (!hasRequests && !hasApprovals) return const SizedBox.shrink();

    return _buildSectionCard(
      title: 'Super Admin Approvals',
      icon: Icons.verified_outlined,
      children: [
        if (hasRequests) ...[
          _buildSubTitle('Requests'),
          const SizedBox(height: 8),
          ..._loan.requestedSuperAdmins!.map(
            (req) => _buildInfoRow(
              'Request Status',
              req.status ?? 'Pending',
            ),
          ),
        ],
        if (hasApprovals) ...[
          const SizedBox(height: 12),
          _buildSubTitle('Approvals'),
          const SizedBox(height: 8),
          ..._loan.superAdminApprovals!.map(
            (approval) => _buildInfoRow(
              'Approved On',
              _formatDateTime(approval.approvedAt),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildAdditionalDetails() {
    return _buildSectionCard(
      title: 'Additional Details',
      icon: Icons.tune_rounded,
      children: [
        _buildInfoRow('Storage Charge', '${_loan.storageChargePercent ?? 0}%'),
        _buildInfoRow('Penalty Rate', '${_loan.penaltyPercent ?? 10}%'),
        _buildInfoRow('Created By', _loan.createdBy ?? 'N/A'),
        _buildInfoRow('Created Date', _formatDateTime(_loan.createdAt)),
        _buildInfoRow('Last Updated', _formatDateTime(_loan.updatedAt)),
      ],
    );
  }

  Widget _buildAttachmentsSection() {
    return Obx(() {
      if (_attachmentController.isLoading.value) {
        return _buildSectionCard(
          title: 'Attachments',
          icon: Icons.attach_file_rounded,
          children: [
            const Center(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: CircularProgressIndicator(),
              ),
            ),
          ],
        );
      }

      final attachments = _attachmentController.attachments;
      if (attachments.isEmpty) return const SizedBox.shrink();

      final imageUrls = attachments
          .map((att) => att.url ?? '')
          .where((url) => url.isNotEmpty)
          .toList();

      if (imageUrls.isEmpty) return const SizedBox.shrink();

      return _buildSectionCard(
        title: 'Attachments (${attachments.length})',
        icon: Icons.attach_file_rounded,
        children: [_buildImageGrid(imageUrls)],
      );
    });
  }

  /// Builds a 3-per-row image grid that wraps
  Widget _buildImageGrid(List<String> imageUrls, {List<String>? titles}) {
    if (imageUrls.isEmpty) return const SizedBox.shrink();

    // Build rows of 3
    final rows = <Widget>[];
    for (int i = 0; i < imageUrls.length; i += 3) {
      final rowItems = <Widget>[];
      for (int j = i; j < i + 3 && j < imageUrls.length; j++) {
        rowItems.add(
          Expanded(
            child: _buildImageTile(imageUrls, j, titles: titles),
          ),
        );
      }
      // Fill remaining slots if last row is incomplete
      while (rowItems.length < 3) {
        rowItems.add(const Expanded(child: SizedBox()));
      }

      rows.add(Row(
        children: [
          for (int k = 0; k < rowItems.length; k++) ...[
            rowItems[k],
            if (k < rowItems.length - 1) const SizedBox(width: 8),
          ],
        ],
      ));
      if (i + 3 < imageUrls.length) rows.add(const SizedBox(height: 8));
    }

    return Column(children: rows);
  }

  Widget _buildImageTile(
    List<String> allUrls,
    int index, {
    List<String>? titles,
  }) {
    final url = allUrls[index];
    return GestureDetector(
      onTap: () => _showFullScreenGallery(allUrls, initialIndex: index),
      child: AspectRatio(
        aspectRatio: 1,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.1),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Stack(
              fit: StackFit.expand,
              children: [
                Hero(
                  tag: 'img_$url',
                  child: CachedNetworkImage(
                    imageUrl: url,
                    fit: BoxFit.cover,
                    placeholder: (_, url) => Shimmer.fromColors(
                      baseColor: Colors.grey[300]!,
                      highlightColor: Colors.grey[100]!,
                      child: Container(color: Colors.white),
                    ),
                    errorWidget: (_, url, err) => Container(
                      color: AppColors.borderColor,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.broken_image_rounded,
                              color: AppColors.subtextColor, size: 24),
                          const SizedBox(height: 4),
                          Text(
                            'No image',
                            style: GoogleFonts.poppins(
                              fontSize: 10,
                              color: AppColors.subtextColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                // Tap overlay hint
                Positioned(
                  top: 4,
                  right: 4,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.4),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Icon(Icons.zoom_in_rounded,
                        color: Colors.white, size: 12),
                  ),
                ),
                if (titles != null && titles.length > index)
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 4),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.transparent,
                            Colors.black.withValues(alpha: 0.7),
                          ],
                        ),
                      ),
                      child: Text(
                        titles[index],
                        style: GoogleFonts.poppins(
                          fontSize: 9,
                          color: Colors.white,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showFullScreenGallery(
    List<String> imageUrls, {
    required int initialIndex,
  }) {
    final pageController = PageController(initialPage: initialIndex);
    final currentIndex = initialIndex.obs;

    Get.to(
      () => Scaffold(
        backgroundColor: Colors.black,
        body: SafeArea(
          child: Stack(
            children: [
              PhotoViewGallery.builder(
                itemCount: imageUrls.length,
                pageController: pageController,
                onPageChanged: (index) => currentIndex.value = index,
                builder: (context, index) {
                  return PhotoViewGalleryPageOptions(
                    imageProvider:
                        CachedNetworkImageProvider(imageUrls[index]),
                    minScale: PhotoViewComputedScale.contained * 0.8,
                    maxScale: PhotoViewComputedScale.covered * 2.5,
                    heroAttributes: PhotoViewHeroAttributes(
                      tag: 'img_${imageUrls[index]}',
                    ),
                  );
                },
                scrollPhysics: const BouncingScrollPhysics(),
                backgroundDecoration:
                    const BoxDecoration(color: Colors.black),
              ),
              // Close button
              Positioned(
                top: 12,
                right: 12,
                child: GestureDetector(
                  onTap: () => Get.back(),
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.6),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.close_rounded,
                        color: Colors.white, size: 22),
                  ),
                ),
              ),
              // Page indicator
              Positioned(
                bottom: 20,
                left: 0,
                right: 0,
                child: Center(
                  child: Obx(
                    () => Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 7),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.6),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        '${currentIndex.value + 1} / ${imageUrls.length}',
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              // Navigation arrows for multiple images
              if (imageUrls.length > 1) ...[
                Positioned(
                  left: 8,
                  top: 0,
                  bottom: 0,
                  child: Center(
                    child: Obx(() => currentIndex.value > 0
                        ? GestureDetector(
                            onTap: () => pageController.previousPage(
                              duration: const Duration(milliseconds: 300),
                              curve: Curves.easeInOut,
                            ),
                            child: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.black.withValues(alpha: 0.5),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.chevron_left_rounded,
                                color: Colors.white,
                                size: 28,
                              ),
                            ),
                          )
                        : const SizedBox.shrink()),
                  ),
                ),
                Positioned(
                  right: 8,
                  top: 0,
                  bottom: 0,
                  child: Center(
                    child: Obx(() =>
                        currentIndex.value < imageUrls.length - 1
                            ? GestureDetector(
                                onTap: () => pageController.nextPage(
                                  duration: const Duration(milliseconds: 300),
                                  curve: Curves.easeInOut,
                                ),
                                child: Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: Colors.black.withValues(alpha: 0.5),
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.chevron_right_rounded,
                                    color: Colors.white,
                                    size: 28,
                                  ),
                                ),
                              )
                            : const SizedBox.shrink()),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
      fullscreenDialog: true,
    );
  }


  Widget _buildSectionCard({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.surfaceColor,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.borderColor),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(7),
                decoration: BoxDecoration(
                  color: AppColors.primaryColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(9),
                ),
                child: Icon(icon, size: 16, color: AppColors.primaryColor),
              ),
              const SizedBox(width: 10),
              Text(
                title,
                style: GoogleFonts.poppins(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Divider(color: AppColors.borderColor, height: 1),
          const SizedBox(height: 12),
          ...children,
        ],
      ),
    );
  }

  Widget _buildSubTitle(String text) {
    return Text(
      text,
      style: GoogleFonts.poppins(
        fontSize: 12,
        fontWeight: FontWeight.w700,
        color: AppColors.subtextColor,
        letterSpacing: 0.5,
      ),
    );
  }

  Widget _buildInfoRow(
    String label,
    String value, {
    bool highlight = false,
    Color? valueColor,
    bool bold = false,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 5,
            child: Text(
              label,
              style: GoogleFonts.poppins(
                fontSize: 12,
                color: AppColors.subtextColor,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            flex: 5,
            child: Text(
              value,
              style: GoogleFonts.poppins(
                fontSize: 12,
                fontWeight:
                    (highlight || bold) ? FontWeight.w700 : FontWeight.w600,
                color: valueColor ??
                    (highlight
                        ? const Color(0xFFF59E0B)
                        : AppColors.textColor),
              ),
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }
}