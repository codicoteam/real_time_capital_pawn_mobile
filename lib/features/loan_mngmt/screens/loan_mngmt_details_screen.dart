import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:real_time_pawn/config/routers/router.dart';
import 'package:real_time_pawn/core/utils/logs.dart';
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
  // Controllers
  late final LoanController _loanController;
  late final AttachmentController _attachmentController;
  late final LoanTermsController _loanTermsController;

  // Local state
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
    await _loanTermsController.fetchLoanTerms(_loan.id!, refresh: true);
  }

  Future<void> _refreshLoan() async {
    setState(() => _isRefreshing = true);
    try {
      final updated = await _loanController.getLoanDetails(_loan.id!);
      if (updated != null) {
        setState(() => _loan = updated);
      }
    } finally {
      setState(() => _isRefreshing = false);
    }
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'active':
        return RealTimeColors.success;
      case 'overdue':
        return RealTimeColors.error;
      case 'settled':
      case 'redeemed':
      case 'closed':
        return RealTimeColors.success;
      case 'pending_approval':
      case 'draft':
        return RealTimeColors.warning;
      case 'defaulted':
      case 'written_off':
      case 'cancelled':
        return RealTimeColors.error;
      case 'in_grace':
        return Colors.orange;
      case 'auction':
      case 'sold':
        return Colors.purple;
      default:
        return AppColors.subtextColor;
    }
  }

  String _formatDateFull(DateTime? date) {
    if (date == null) return 'N/A';
    const monthNames = [
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

  String _formatDateTime(DateTime? date) {
    if (date == null) return 'N/A';
    return '${_formatDateFull(date)} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }

  String _formatCurrency(int? amount) {
    if (amount == null) return 'N/A';
    final currency = _loan.currency ?? 'USD';
    return '$currency ${amount.toStringAsFixed(2)}';
  }

  String _getCustomerName() {
    final first = _loan.customerUser?.firstName ?? '';
    final last = _loan.customerUser?.lastName ?? '';
    if (first.isNotEmpty || last.isNotEmpty) return '$first $last'.trim();
    return 'N/A';
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
            slivers: [
              _buildAnimatedAppBar(),
              SliverPadding(
                padding: const EdgeInsets.all(16),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    FadeTransition(
                      opacity: _fadeAnimation,
                      child: _isRefreshing
                          ? const Center(child: CircularProgressIndicator())
                          : Column(
                              children: [
                                _buildQuickStats(),
                                const SizedBox(height: 20),
                                _buildQuickActions(),
                                const SizedBox(height: 24),
                                _buildLoanInfo(),
                                const SizedBox(height: 16),
                                _buildRepaymentInfo(),
                                const SizedBox(height: 16),
                                _buildCollateralInfo(),
                                const SizedBox(height: 16),
                                _buildCustomerInfo(),
                                const SizedBox(height: 16),
                                _buildCustomerDocuments(),
                                const SizedBox(height: 16),
                                _buildPaymentsHistory(),
                                const SizedBox(height: 16),
                                _buildSuperAdminApprovals(),
                                const SizedBox(height: 16),
                                _buildAdditionalDetails(),
                                const SizedBox(height: 16),
                                _buildAttachmentsSection(),
                                const SizedBox(height: 16),
                                if (_loan.status?.toLowerCase() == 'active' ||
                                    _loan.status?.toLowerCase() == 'overdue')
                                  _buildStatusManagement(),
                                const SizedBox(height: 24),
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

  Widget _buildAnimatedAppBar() {
    return SliverAppBar(
      pinned: true,
      floating: true,
      expandedHeight: 120,
      backgroundColor: AppColors.surfaceColor,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: AppColors.textColor),
        onPressed: () => Get.back(),
      ),
      flexibleSpace: FlexibleSpaceBar(
        title: Column(
          mainAxisAlignment: MainAxisAlignment.end,
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
              _loan.loanNo ?? 'N/A',
              style: GoogleFonts.poppins(
                fontSize: 12,
                color: AppColors.subtextColor,
              ),
            ),
          ],
        ),
        titlePadding: const EdgeInsets.only(left: 16, bottom: 16),
      ),
      actions: [
        Container(
          margin: const EdgeInsets.only(right: 16),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: _getStatusColor(_loan.status ?? 'unknown').withOpacity(0.1),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            (_loan.status ?? 'UNKNOWN').toUpperCase(),
            style: GoogleFonts.poppins(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: _getStatusColor(_loan.status ?? 'unknown'),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildQuickStats() {
    final paidAmount =
        (_loan.principalAmount ?? 0) - (_loan.currentBalance ?? 0);
    final progress = _loan.principalAmount != null && _loan.principalAmount! > 0
        ? (paidAmount / _loan.principalAmount!).clamp(0.0, 1.0)
        : 0.0;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.surfaceColor,
            AppColors.surfaceColor.withOpacity(0.8),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.borderColor),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _buildAnimatedAmountCard(
                  label: 'Loan Amount',
                  amount: _formatCurrency(_loan.principalAmount),
                  color: AppColors.textColor,
                  icon: Icons.attach_money,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildAnimatedAmountCard(
                  label: 'Paid',
                  amount: _formatCurrency(paidAmount),
                  color: RealTimeColors.success,
                  icon: Icons.check_circle_outline,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _buildAnimatedAmountCard(
            label: 'Outstanding Balance',
            amount: _formatCurrency(_loan.currentBalance),
            color: RealTimeColors.warning,
            icon: Icons.account_balance_wallet_outlined,
            isLarge: true,
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: progress,
              backgroundColor: Colors.grey[300],
              valueColor: const AlwaysStoppedAnimation<Color>(
                RealTimeColors.success,
              ),
              minHeight: 8,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '${(progress * 100).toStringAsFixed(1)}% Repaid',
            style: GoogleFonts.poppins(
              fontSize: 12,
              color: AppColors.subtextColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnimatedAmountCard({
    required String label,
    required String amount,
    required Color color,
    required IconData icon,
    bool isLarge = false,
  }) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: const Duration(milliseconds: 800),
      builder: (context, value, child) {
        return Opacity(opacity: value, child: child);
      },
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.backgroundColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.borderColor),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, size: 16, color: AppColors.subtextColor),
                const SizedBox(width: 4),
                Text(
                  label,
                  style: GoogleFonts.poppins(
                    fontSize: 10,
                    color: AppColors.subtextColor,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
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
      ),
    );
  }

  Widget _buildQuickActions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
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
              child: _buildAnimatedActionButton(
                icon: Icons.payments_outlined,
                label: 'Make Payment',
                onTap: () => Get.toNamed(
                  RoutesHelper.CreatePaymentScreen,
                  arguments: {'loanId': _loan.id},
                ),
                color: RealTimeColors.success,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildAnimatedActionButton(
                icon: Icons.receipt_long_outlined,
                label: 'View Charges',
                onTap: () {
                  Get.toNamed(
                    RoutesHelper.LoanChargesScreen,
                    arguments: {'loanId': _loan.id},
                  );
                },
                color: Colors.blue,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildAnimatedActionButton(
                icon: Icons.list_alt_outlined,
                label: 'Loan Terms',
                onTap: () => Get.toNamed(
                  RoutesHelper.loanTermsDisplayScreen,
                  arguments: {'loanId': _loan.id, 'loanNo': _loan.loanNo},
                ),
                color: Colors.purple,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildAnimatedActionButton(
                icon: Icons.payment_outlined,
                label: 'View Payments',
                onTap: () => Get.toNamed(
                  RoutesHelper.PaymentListScreen,
                  arguments: {'loanId': _loan.id, 'isLoanPayments': true},
                ),
                color: Colors.orange,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildAnimatedActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    required Color color,
  }) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: const Duration(milliseconds: 500),
      builder: (context, value, child) {
        return Transform.scale(scale: value, child: child);
      },
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [AppColors.surfaceColor, color.withOpacity(0.05)],
            ),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: color.withOpacity(0.3)),
          ),
          child: Column(
            children: [
              Icon(icon, color: color, size: 24),
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
      ),
    );
  }

  Widget _buildLoanInfo() {
    return _buildAnimatedSectionCard(
      title: 'Loan Information',
      icon: Icons.info_outline,
      children: [
        _buildInfoRow('Loan Number', _loan.loanNo ?? 'N/A'),
        _buildInfoRow('Loan Date', _formatDateFull(_loan.startDate)),
        _buildInfoRow('Due Date', _formatDateFull(_loan.dueDate)),
        _buildInfoRow(
          'Interest Rate',
          '${_loan.interestRatePercent ?? 0}% per month',
        ),
        _buildInfoRow(
          'Interest Period',
          '${_loan.interestPeriodDays ?? 0} days',
        ),
        _buildInfoRow('Grace Period', '${_loan.graceDays ?? 0} days'),
        _buildInfoRow('Repayment Type', _loan.repaymentType ?? 'N/A'),
        _buildInfoRow('Currency', _loan.currency ?? 'USD'),
        _buildInfoRow('Approval Status', _loan.approvalStatus ?? 'N/A'),
        if (_loan.requiresSuperAdminApproval == true)
          _buildInfoRow('Super Admin Required', 'Yes', highlight: true),
      ],
    );
  }

  Widget _buildRepaymentInfo() {
    if (_loan.payments == null || _loan.payments!.isEmpty)
      return const SizedBox.shrink();

    final totalPaid = _loan.totalPaid ?? 0;
    final expectedTotal = _loan.principalAmount ?? 0;

    return _buildAnimatedSectionCard(
      title: 'Repayment Summary',
      icon: Icons.account_balance_outlined,
      children: [
        _buildInfoRow('Total Paid', _formatCurrency(totalPaid)),
        _buildInfoRow('Expected Total', _formatCurrency(expectedTotal)),
        _buildInfoRow('Payments Count', '${_loan.payments!.length}'),
        if (_loan.payments!.isNotEmpty) ...[
          const SizedBox(height: 8),
          Text(
            'Latest Payment',
            style: GoogleFonts.poppins(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppColors.textColor,
            ),
          ),
          const SizedBox(height: 4),
          _buildInfoRow('Amount', _formatCurrency(_loan.payments!.last.amount)),
          _buildInfoRow(
            'Date',
            _formatDateTime(_loan.payments!.last.paymentDate),
          ),
          _buildInfoRow('Method', _loan.payments!.last.paymentMethod ?? 'N/A'),
        ],
      ],
    );
  }

  Widget _buildCollateralInfo() {
    List<Widget> children = [
      _buildInfoRow('Category', _loan.collateralCategory ?? 'N/A'),
    ];

    if (_loan.asset != null) {
      children.add(_buildInfoRow('Asset No', _loan.asset!.assetNo ?? 'N/A'));
      children.add(_buildInfoRow('Asset Title', _loan.asset!.title ?? 'N/A'));
      children.add(
        _buildInfoRow('Asset Category', _loan.asset!.category ?? 'N/A'),
      );
      children.add(_buildInfoRow('Asset Status', _loan.asset!.status ?? 'N/A'));
      if (_loan.asset!.evaluatedValue != null) {
        children.add(
          _buildInfoRow(
            'Evaluated Value',
            _formatCurrency(_loan.asset!.evaluatedValue),
          ),
        );
      }

      // Asset Images Gallery
      if (_loan.asset!.assetImages != null &&
          _loan.asset!.assetImages!.isNotEmpty) {
        children.add(const SizedBox(height: 12));
        children.add(
          Text(
            'Asset Images',
            style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.textColor,
            ),
          ),
        );
        children.add(const SizedBox(height: 8));
        children.add(_buildImageGallery(_loan.asset!.assetImages!));
      }
    }

    final app = _loan.application;
    if (app != null) {
      if (app.declaredAssetValue != null) {
        children.add(
          _buildInfoRow(
            'Declared Value',
            _formatCurrency(app.declaredAssetValue),
          ),
        );
      }
      if (app.collateralDescription != null &&
          app.collateralDescription!.isNotEmpty) {
        children.add(_buildInfoRow('Description', app.collateralDescription!));
      }
    }

    return _buildAnimatedSectionCard(
      title: 'Collateral Information',
      icon: Icons.inventory_2_outlined,
      children: children,
    );
  }

  Widget _buildCustomerInfo() {
    final app = _loan.application;
    return _buildAnimatedSectionCard(
      title: 'Customer Information',
      icon: Icons.person_outline,
      children: [
        _buildInfoRow('Name', _getCustomerName()),
        if (_loan.customerUser != null) ...[
          _buildInfoRow('Email', _loan.customerUser!.email ?? 'N/A'),
          _buildInfoRow('Phone', _loan.customerUser!.phone ?? 'N/A'),
          _buildInfoRow(
            'National ID',
            _loan.customerUser!.nationalIdNumber ?? 'N/A',
          ),
        ],
        if (app != null && app.id != null) ...[
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

  Widget _buildCustomerDocuments() {
    final app = _loan.application;
    if (app == null) return const SizedBox.shrink();

    final documents = <String, String>{};
    // Note: These fields would need to be added to your Application model
    // For now, we'll show a message or skip

    if (documents.isEmpty) return const SizedBox.shrink();

    return _buildAnimatedSectionCard(
      title: 'Customer Documents (${documents.length})',
      icon: Icons.description_outlined,
      children: [
        _buildImageGallery(
          documents.values.toList(),
          titles: documents.keys.toList(),
        ),
      ],
    );
  }

  Widget _buildPaymentsHistory() {
    if (_loan.payments == null || _loan.payments!.isEmpty) {
      return const SizedBox.shrink();
    }

    return _buildAnimatedSectionCard(
      title: 'Payment History',
      icon: Icons.history_outlined,
      children: [
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: _loan.payments!.length > 5 ? 5 : _loan.payments!.length,
          separatorBuilder: (_, __) => const Divider(),
          itemBuilder: (context, index) {
            final payment = _loan.payments![index];
            return ListTile(
              contentPadding: EdgeInsets.zero,
              leading: CircleAvatar(
                backgroundColor: RealTimeColors.success.withOpacity(0.1),
                child: Icon(
                  Icons.payment,
                  color: RealTimeColors.success,
                  size: 20,
                ),
              ),
              title: Text(
                _formatCurrency(payment.amount),
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w600,
                  color: RealTimeColors.success,
                ),
              ),
              subtitle: Text(
                payment.paymentMethod ?? 'Unknown method',
                style: GoogleFonts.poppins(fontSize: 11),
              ),
              trailing: Text(
                _formatDateFull(payment.paymentDate),
                style: GoogleFonts.poppins(
                  fontSize: 11,
                  color: AppColors.subtextColor,
                ),
              ),
            );
          },
        ),
        if (_loan.payments!.length > 5)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Center(
              child: TextButton(
                onPressed: () => Get.toNamed(
                  RoutesHelper.PaymentListScreen,
                  arguments: {'loanId': _loan.id, 'isLoanPayments': true},
                ),
                child: Text('View All ${_loan.payments!.length} Payments'),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildSuperAdminApprovals() {
    if ((_loan.requestedSuperAdmins == null ||
            _loan.requestedSuperAdmins!.isEmpty) &&
        (_loan.superAdminApprovals == null ||
            _loan.superAdminApprovals!.isEmpty)) {
      return const SizedBox.shrink();
    }

    return _buildAnimatedSectionCard(
      title: 'Super Admin Approvals',
      icon: Icons.verified_outlined,
      children: [
        if (_loan.requestedSuperAdmins != null &&
            _loan.requestedSuperAdmins!.isNotEmpty) ...[
          Text(
            'Requests',
            style: GoogleFonts.poppins(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppColors.textColor,
            ),
          ),
          const SizedBox(height: 8),
          ..._loan.requestedSuperAdmins!.map(
            (req) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: _buildInfoRow(
                'Super Admin',
                'Status: ${req.status ?? 'pending'}',
              ),
            ),
          ),
        ],
        if (_loan.superAdminApprovals != null &&
            _loan.superAdminApprovals!.isNotEmpty) ...[
          const SizedBox(height: 12),
          Text(
            'Approvals',
            style: GoogleFonts.poppins(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppColors.textColor,
            ),
          ),
          const SizedBox(height: 8),
          ..._loan.superAdminApprovals!.map(
            (approval) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: _buildInfoRow(
                'Approved By',
                _formatDateTime(approval.approvedAt),
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildAdditionalDetails() {
    return _buildAnimatedSectionCard(
      title: 'Additional Details',
      icon: Icons.more_horiz_outlined,
      children: [
        _buildInfoRow('Storage Charge', '${_loan.storageChargePercent ?? 0}%'),
        _buildInfoRow('Penalty Rate', '${_loan.penaltyPercent ?? 0}%'),
        _buildInfoRow('Created By', _loan.createdBy ?? 'N/A'),
        _buildInfoRow('Created Date', _formatDateTime(_loan.createdAt)),
        _buildInfoRow('Last Updated', _formatDateTime(_loan.updatedAt)),
        if (_loan.v != null) _buildInfoRow('Version', _loan.v.toString()),
      ],
    );
  }

  Widget _buildAttachmentsSection() {
    return Obx(() {
      final attachments = _attachmentController.attachments;
      if (_attachmentController.isLoading.value) {
        return const Center(child: CircularProgressIndicator());
      }
      if (attachments.isEmpty) {
        return const SizedBox.shrink();
      }
      return _buildAnimatedSectionCard(
        title: 'Attachments (${attachments.length})',
        icon: Icons.attach_file_outlined,
        children: [
          _buildImageGallery(
            attachments
                .map((att) => att.url ?? '')
                .where((url) => url.isNotEmpty)
                .toList(),
          ),
        ],
      );
    });
  }

  Widget _buildImageGallery(List<String> imageUrls, {List<String>? titles}) {
    if (imageUrls.isEmpty) return const SizedBox.shrink();

    return SizedBox(
      height: 120,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: imageUrls.length,
        itemBuilder: (context, index) {
          return GestureDetector(
            onTap: () => _showFullScreenGallery(imageUrls, initialIndex: index),
            child: Container(
              width: 100,
              margin: const EdgeInsets.only(right: 8),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 4,
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
                      tag: 'image_${imageUrls[index]}',
                      child: CachedNetworkImage(
                        imageUrl: imageUrls[index],
                        fit: BoxFit.cover,
                        placeholder: (_, __) => Shimmer.fromColors(
                          baseColor: Colors.grey[300]!,
                          highlightColor: Colors.grey[100]!,
                          child: Container(color: Colors.white),
                        ),
                        errorWidget: (_, __, ___) => Container(
                          color: Colors.grey[300],
                          child: const Icon(
                            Icons.broken_image,
                            color: Colors.grey,
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: 0,
                      left: 0,
                      right: 0,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 4,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.transparent,
                              Colors.black.withOpacity(0.7),
                            ],
                          ),
                        ),
                        child: Text(
                          titles != null && titles.length > index
                              ? titles[index]
                              : '',
                          style: GoogleFonts.poppins(
                            fontSize: 10,
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
          );
        },
      ),
    );
  }

  void _showFullScreenGallery(
    List<String> imageUrls, {
    required int initialIndex,
  }) {
    Get.to(
      () => Scaffold(
        backgroundColor: Colors.black,
        body: Stack(
          children: [
            PhotoViewGallery.builder(
              itemCount: imageUrls.length,
              builder: (context, index) {
                return PhotoViewGalleryPageOptions(
                  imageProvider: CachedNetworkImageProvider(imageUrls[index]),
                  minScale: PhotoViewComputedScale.contained * 0.8,
                  maxScale: PhotoViewComputedScale.covered * 2,
                  heroAttributes: PhotoViewHeroAttributes(
                    tag: 'image_${imageUrls[index]}',
                  ),
                );
              },
              scrollPhysics: const BouncingScrollPhysics(),
              backgroundDecoration: const BoxDecoration(color: Colors.black),
              pageController: PageController(initialPage: initialIndex),
            ),
            Positioned(
              top: 40,
              right: 16,
              child: IconButton(
                icon: const Icon(Icons.close, color: Colors.white, size: 30),
                onPressed: () => Get.back(),
              ),
            ),
            Positioned(
              bottom: 20,
              left: 0,
              right: 0,
              child: Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.6),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Obx(
                    () => Text(
                      '${(initialIndex + 1).toString().padLeft(2, '0')} / ${imageUrls.length.toString().padLeft(2, '0')}',
                      style: const TextStyle(color: Colors.white, fontSize: 14),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      fullscreenDialog: true,
    );
  }

  void _showImageDialog(String? url) {
    if (url == null) return;
    _showFullScreenGallery([url], initialIndex: 0);
  }

  Widget _buildStatusManagement() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            RealTimeColors.warning.withOpacity(0.1),
            AppColors.surfaceColor,
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: RealTimeColors.warning.withOpacity(0.3)),
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
                child: ElevatedButton.icon(
                  onPressed: () async {
                    final confirmed = await Get.dialog<bool>(
                      AlertDialog(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        title: const Text('Mark as Settled'),
                        content: const Text(
                          'Are you sure you want to mark this loan as settled?\n\nThis action will mark the loan as fully repaid.',
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Get.back(result: false),
                            child: const Text('Cancel'),
                          ),
                          ElevatedButton(
                            onPressed: () => Get.back(result: true),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: RealTimeColors.success,
                            ),
                            child: const Text('Yes, Settle'),
                          ),
                        ],
                      ),
                    );
                    if (confirmed == true) {
                      final success = await _loanController.updateLoanStatus(
                        loanId: _loan.id!,
                        status: 'redeemed',
                        notes: 'Loan settled from mobile app',
                      );
                      if (success) {
                        _refreshLoan();
                        Get.snackbar(
                          'Success',
                          'Loan marked as settled',
                          backgroundColor: RealTimeColors.success,
                          colorText: Colors.white,
                          snackPosition: SnackPosition.BOTTOM,
                        );
                      }
                    }
                  },
                  icon: const Icon(Icons.check_circle_outline),
                  label: const Text('Mark as Settled'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: RealTimeColors.success,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAnimatedSectionCard({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: const Duration(milliseconds: 600),
      builder: (context, value, child) {
        return Transform.translate(
          offset: Offset(0, 50 * (1 - value)),
          child: Opacity(opacity: value, child: child),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surfaceColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.borderColor),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, size: 20, color: AppColors.primaryColor),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textColor,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, {bool highlight = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: GoogleFonts.poppins(
                fontSize: 12,
                color: AppColors.subtextColor,
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              value,
              style: GoogleFonts.poppins(
                fontSize: 13,
                fontWeight: highlight ? FontWeight.w600 : FontWeight.w500,
                color: highlight ? RealTimeColors.warning : AppColors.textColor,
              ),
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }
}
