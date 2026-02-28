import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:real_time_pawn/config/routers/router.dart';
import 'package:real_time_pawn/core/utils/logs.dart';
import 'package:real_time_pawn/core/utils/pallete.dart';
import 'package:real_time_pawn/features/loan_mngmt/controllers/loan_mngmt_controller.dart';
import 'package:real_time_pawn/models/loan_mngmt_model.dart';
import 'package:cached_network_image/cached_network_image.dart';
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

class _LoanDetailsScreenState extends State<LoanDetailsScreen> {
  // Controllers
  final LoanController _loanController = Get.find<LoanController>();
  final AttachmentController _attachmentController =
      Get.find<AttachmentController>();
  final LoanTermsController _loanTermsController =
      Get.find<LoanTermsController>();

  // Local state for loan (allows refresh)
  late LoanModel _loan;
  bool _isRefreshing = false;

  @override
  void initState() {
    super.initState();
    _loan = widget.loan;
    _loadAttachments();
    _loadLoanTerms();
  }

  /// Load attachments for this loan's application
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

  /// Load loan terms for this loan
  Future<void> _loadLoanTerms() async {
    await _loanTermsController.fetchLoanTerms(_loan.id!, refresh: true);
  }

  /// Refresh loan details from server
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
        return RealTimeColors.success;
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

  String _formatCurrency(int? amount) {
    if (amount == null) return 'N/A';
    final currency = _loan.currency ?? 'ZWL';
    return '$currency ${amount.toStringAsFixed(2)}';
  }

  String _getCustomerName() {
    if (_loan.application?.fullName != null &&
        _loan.application!.fullName!.isNotEmpty) {
      return _loan.application!.fullName!;
    }
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
              // Header Sliver
              SliverAppBar(
                pinned: true,
                floating: true,
                backgroundColor: AppColors.surfaceColor,
                leading: IconButton(
                  icon: const Icon(
                    Icons.arrow_back,
                    color: AppColors.textColor,
                  ),
                  onPressed: () => Get.back(),
                ),
                title: Column(
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
                actions: [
                  Container(
                    margin: const EdgeInsets.only(right: 16),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: _getStatusColor(
                        _loan.status ?? 'unknown',
                      ).withOpacity(0.1),
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
              ),

              // Main content
              SliverPadding(
                padding: const EdgeInsets.all(16),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    if (_isRefreshing)
                      const Center(child: CircularProgressIndicator())
                    else ...[
                      // Quick Stats
                      _buildQuickStats(),
                      const SizedBox(height: 20),

                      // Quick Actions
                      _buildQuickActions(),
                      const SizedBox(height: 24),

                      // Loan Information
                      _buildLoanInfo(),
                      const SizedBox(height: 16),

                      // Collateral Information
                      _buildCollateralInfo(),
                      const SizedBox(height: 16),

                      // Customer Information
                      _buildCustomerInfo(),
                      const SizedBox(height: 16),

                      // Customer Documents (new section)
                      _buildCustomerDocuments(),
                      const SizedBox(height: 16),

                      // Additional Details
                      _buildAdditionalDetails(),
                      const SizedBox(height: 16),

                      // Attachments
                      _buildAttachmentsSection(),
                      const SizedBox(height: 16),

                      // Loan Terms
                      _buildLoanTermsSection(),
                      const SizedBox(height: 16),

                      // Status Management (if applicable)
                      if (_loan.status?.toLowerCase() == 'active' ||
                          _loan.status?.toLowerCase() == 'overdue')
                        _buildStatusManagement(),
                      const SizedBox(height: 24),
                    ],
                  ]),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQuickStats() {
    final paidAmount =
        (_loan.principalAmount ?? 0) - (_loan.currentBalance ?? 0);
    return Container(
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
                child: _buildAmountCard(
                  label: 'Loan Amount',
                  amount: _formatCurrency(_loan.principalAmount),
                  color: AppColors.textColor,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildAmountCard(
                  label: 'Paid',
                  amount: _formatCurrency(paidAmount),
                  color: RealTimeColors.success,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          _buildAmountCard(
            label: 'Outstanding Balance',
            amount: _formatCurrency(_loan.currentBalance),
            color: RealTimeColors.warning,
            isLarge: true,
          ),
        ],
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
              child: _buildActionButton(
                icon: Icons.payments_outlined,
                label: 'Make Payment',
                onTap: () => Get.toNamed(
                  RoutesHelper.CreatePaymentScreen,
                  arguments: {'loanId': _loan.id},
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildActionButton(
                icon: Icons.receipt_long_outlined,
                label: 'View Charges',
                onTap: () async {
                  final charges = await _loanController.calculateLoanCharges(
                    _loan.id!,
                  );
                  if (charges != null) {
                    Get.toNamed(
                      RoutesHelper.LoanChargesScreen,
                      arguments: {'loanId': _loan.id, 'charges': charges},
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
                icon: Icons.list_alt_outlined,
                label: 'Loan Terms',
                onTap: () => Get.toNamed(
                  RoutesHelper.loanTermsDisplayScreen,
                  arguments: {'loanId': _loan.id, 'loanNo': _loan.loanNo},
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildActionButton(
                icon: Icons.payment_outlined,
                label: 'View Payments',
                onTap: () => Get.toNamed(
                  RoutesHelper.PaymentListScreen,
                  arguments: {'loanId': _loan.id, 'isLoanPayments': true},
                ),
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

  Widget _buildLoanInfo() {
    return _buildSectionCard(
      title: 'Loan Information',
      children: [
        _buildInfoRow('Loan Date', _formatDateFull(_loan.startDate)),
        _buildInfoRow('Due Date', _formatDateFull(_loan.dueDate)),
        _buildInfoRow(
          'Interest Rate',
          '${_loan.interestRatePercent ?? 0}% per month',
        ),
        _buildInfoRow('Loan Term', '${_loan.interestPeriodDays ?? 0} days'),
        _buildInfoRow('Grace Period', '${_loan.graceDays ?? 0} days'),
      ],
    );
  }

  Widget _buildCollateralInfo() {
    List<Widget> children = [
      _buildInfoRow('Category', _loan.collateralCategory ?? 'N/A'),
    ];

    // Add asset details if available
    if (_loan.asset != null) {
      children.add(_buildInfoRow('Asset No', _loan.asset!.assetNo ?? 'N/A'));
      children.add(_buildInfoRow('Asset Title', _loan.asset!.title ?? 'N/A'));
      children.add(
        _buildInfoRow('Asset Type', _loan.asset!.assetType ?? 'N/A'),
      );
    }

    // Add application collateral details
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

      // Jewellery details
      if (app.jewelleryDetails != null) {
        final j = app.jewelleryDetails!;
        children.add(_buildInfoRow('Jewellery Type', j.type ?? 'N/A'));
        children.add(
          _buildInfoRow('Weight', j.weight != null ? '${j.weight}g' : 'N/A'),
        );
        children.add(_buildInfoRow('Purity', j.purity ?? 'N/A'));
        if (j.estimatedValue != null) {
          children.add(
            _buildInfoRow('Est. Value', _formatCurrency(j.estimatedValue)),
          );
        }
      }

      // Motor vehicle details
      if (app.motorVehicleDetails != null) {
        final mv = app.motorVehicleDetails!;
        children.add(_buildInfoRow('Make', mv.make ?? 'N/A'));
        children.add(_buildInfoRow('Model', mv.model ?? 'N/A'));
        children.add(_buildInfoRow('Registration', mv.registrationNo ?? 'N/A'));
        children.add(_buildInfoRow('Engine No', mv.engineNo ?? 'N/A'));
        children.add(_buildInfoRow('Chassis No', mv.chassisNo ?? 'N/A'));
      }
    }

    return _buildSectionCard(
      title: 'Collateral Information',
      children: children,
    );
  }

  Widget _buildCustomerInfo() {
    final app = _loan.application;
    return _buildSectionCard(
      title: 'Customer Information',
      children: [
        _buildInfoRow('Name', _getCustomerName()),
        if (app != null) ...[
          _buildInfoRow('National ID', app.nationalIdNumber ?? 'N/A'),
          _buildInfoRow('Gender', app.gender ?? 'N/A'),
          _buildInfoRow('Marital Status', app.maritalStatus ?? 'N/A'),
          _buildInfoRow('Date of Birth', _formatDateFull(app.dateOfBirth)),
          _buildInfoRow(
            'Phone',
            app.contactDetails ?? _loan.customerUser?.phone ?? 'N/A',
          ),
          _buildInfoRow(
            'Email',
            app.emailAddress ?? _loan.customerUser?.email ?? 'N/A',
          ),
          _buildInfoRow('Address', app.homeAddress ?? 'N/A'),
        ],
        // Next of kin
        if (app?.nextOfKin != null) ...[
          const Divider(height: 24),
          Text(
            'Next of Kin',
            style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          _buildInfoRow('Name', app!.nextOfKin!.fullName ?? 'N/A'),
          _buildInfoRow('Relationship', app.nextOfKin!.relationship ?? 'N/A'),
          _buildInfoRow('Phone', app.nextOfKin!.phoneNumber ?? 'N/A'),
          _buildInfoRow('Email', app.nextOfKin!.email ?? 'N/A'),
        ],
        // Employment
        if (app?.employment != null) ...[
          const Divider(height: 24),
          Text(
            'Employment',
            style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          _buildInfoRow('Type', app!.employment!.employmentType ?? 'N/A'),
          _buildInfoRow('Title', app.employment!.title ?? 'N/A'),
          _buildInfoRow('Duration', app.employment!.duration ?? 'N/A'),
          _buildInfoRow('Location', app.employment!.location ?? 'N/A'),
        ],
      ],
    );
  }

  /// New section: display customer documents (ID, passport, proof of residence, proof of employment)
  Widget _buildCustomerDocuments() {
    final app = _loan.application;
    if (app == null) return const SizedBox.shrink();

    // Collect non‑null document URLs
    final documents = <String, String>{};
    if (app.nationalIdUrl != null && app.nationalIdUrl!.isNotEmpty) {
      documents['National ID'] = app.nationalIdUrl!;
    }
    if (app.passportUrl != null && app.passportUrl!.isNotEmpty) {
      documents['Passport'] = app.passportUrl!;
    }
    if (app.proofOfResidentUrl != null && app.proofOfResidentUrl!.isNotEmpty) {
      documents['Proof of Residence'] = app.proofOfResidentUrl!;
    }
    if (app.proofOfEmploymentUrl != null &&
        app.proofOfEmploymentUrl!.isNotEmpty) {
      documents['Proof of Employment'] = app.proofOfEmploymentUrl!;
    }

    if (documents.isEmpty) return const SizedBox.shrink();

    return _buildSectionCard(
      title: 'Customer Documents (${documents.length})',
      children: [
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          crossAxisSpacing: 8,
          mainAxisSpacing: 8,
          childAspectRatio: 1.2,
          children: documents.entries.map((entry) {
            return GestureDetector(
              onTap: () => _showImageDialog(entry.value),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: CachedNetworkImage(
                        imageUrl: entry.value,
                        fit: BoxFit.cover,
                        width: double.infinity,
                        placeholder: (_, __) => Container(
                          color: Colors.grey[300],
                          child: const Center(
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
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
                  ),
                  const SizedBox(height: 4),
                  Text(
                    entry.key,
                    style: GoogleFonts.poppins(
                      fontSize: 10,
                      color: AppColors.subtextColor,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildAdditionalDetails() {
    return _buildSectionCard(
      title: 'Additional Details',
      children: [
        _buildInfoRow('Storage Charge', '${_loan.storageChargePercent ?? 0}%'),
        _buildInfoRow('Penalty Rate', '${_loan.penaltyPercent ?? 0}%'),
        _buildInfoRow('Created By', _loan.createdBy ?? 'N/A'),
        _buildInfoRow('Created Date', _formatDateFull(_loan.createdAt)),
        _buildInfoRow('Last Updated', _formatDateFull(_loan.updatedAt)),
        if (_loan.approvedBy != null)
          _buildInfoRow('Approved By', _loan.approvedBy!),
        if (_loan.disbursedAt != null)
          _buildInfoRow('Disbursed At', _formatDateFull(_loan.disbursedAt)),
        if (_loan.processedBy != null)
          _buildInfoRow('Processed By', _loan.processedBy!),
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
      return _buildSectionCard(
        title: 'Attachments (${attachments.length})',
        children: [
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
              childAspectRatio: 1,
            ),
            itemCount: attachments.length,
            itemBuilder: (context, index) {
              final att = attachments[index];
              return GestureDetector(
                onTap: () => _showImageDialog(att.url),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: CachedNetworkImage(
                    imageUrl: att.url ?? '',
                    fit: BoxFit.cover,
                    placeholder: (_, __) => Container(color: Colors.grey[300]),
                    errorWidget: (_, __, ___) => Container(
                      color: Colors.grey[300],
                      child: const Icon(Icons.broken_image, color: Colors.grey),
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      );
    });
  }

  void _showImageDialog(String? url) {
    DevLogs.logInfo('Showing image dialog for URL: $url');
    if (url == null) return;
    Get.dialog(
      Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.all(20),
        child: InteractiveViewer(
          child: CachedNetworkImage(
            imageUrl: url,
            fit: BoxFit.contain,
            placeholder: (_, __) =>
                const Center(child: CircularProgressIndicator()),
            errorWidget: (_, __, ___) =>
                const Icon(Icons.error, color: Colors.white, size: 50),
          ),
        ),
      ),
    );
  }

  Widget _buildLoanTermsSection() {
    return Obx(() {
      final terms = _loanTermsController.loanTerms;
      if (_loanTermsController.isLoading.value && terms.isEmpty) {
        return const Center(child: CircularProgressIndicator());
      }
      if (terms.isEmpty) {
        return const SizedBox.shrink();
      }
      return _buildSectionCard(
        title: 'Loan Terms (${terms.length})',
        children: [
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: terms.length > 3 ? 3 : terms.length,
            separatorBuilder: (_, __) => const Divider(height: 16),
            itemBuilder: (context, index) {
              final term = terms[index];
              return ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: _getStatusColor(term.status).withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      term.termNo.substring(term.termNo.length - 2),
                      style: TextStyle(
                        color: _getStatusColor(term.status),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                title: Text(
                  'Term ${term.termNo} - ${term.termType}',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                subtitle: Text(
                  '${term.formattedPrincipalAmount} • ${_formatDateFull(term.startDate)} - ${_formatDateFull(term.endDate)}',
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: AppColors.subtextColor,
                  ),
                ),
                trailing: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: _getStatusColor(term.status).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    term.status.toUpperCase(),
                    style: TextStyle(
                      fontSize: 10,
                      color: _getStatusColor(term.status),
                    ),
                  ),
                ),
                onTap: () => Get.toNamed(
                  RoutesHelper.loanTermsDisplayScreen, // CHANGED THIS
                  arguments: {'loanId': _loan.id, 'loanNo': _loan.loanNo},
                ),
              );
            },
          ),
          if (terms.length > 3)
            TextButton(
              onPressed: () => Get.toNamed(
                RoutesHelper.loanTermsDisplayScreen, // CHANGED THIS
                arguments: {'loanId': _loan.id, 'loanNo': _loan.loanNo},
              ),
              child: const Text('View All Terms'),
            ),
        ],
      );
    });
  }

  Widget _buildStatusManagement() {
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
            'Loan Status Management',
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.textColor,
            ),
          ),
          const SizedBox(height: 12),
          ElevatedButton(
            onPressed: () async {
              final confirmed = await Get.dialog<bool>(
                AlertDialog(
                  title: const Text('Settle Loan'),
                  content: const Text(
                    'Are you sure you want to mark this loan as settled?',
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Get.back(result: false),
                      child: const Text('Cancel'),
                    ),
                    ElevatedButton(
                      onPressed: () => Get.back(result: true),
                      child: const Text('Settle'),
                    ),
                  ],
                ),
              );
              if (confirmed == true) {
                final success = await _loanController.updateLoanStatus(
                  loanId: _loan.id!,
                  status: 'settled',
                  notes: 'Loan settled from mobile app',
                );
                if (success) {
                  _refreshLoan();
                  Get.snackbar('Success', 'Loan marked as settled');
                }
              }
            },
            style: ElevatedButton.styleFrom(
              foregroundColor: Colors.white,
              backgroundColor: RealTimeColors.success,
              minimumSize: const Size(double.infinity, 45),
            ),
            child: const Text('Mark as Settled'),
          ),
        ],
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

  Widget _buildInfoRow(String label, String value) {
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
