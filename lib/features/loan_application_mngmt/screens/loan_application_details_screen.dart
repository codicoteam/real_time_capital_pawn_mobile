import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:real_time_pawn/core/utils/pallete.dart';
import 'package:real_time_pawn/models/loan_application.model.dart';

class LoanApplicationDetailsScreen extends StatefulWidget {
  final LoanApplicationModel application;

  const LoanApplicationDetailsScreen({
    super.key,
    required this.application,
  });

  @override
  State<LoanApplicationDetailsScreen> createState() =>
      _LoanApplicationDetailsScreenState();
}

class _LoanApplicationDetailsScreenState
    extends State<LoanApplicationDetailsScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _fabController;
  final ScrollController _scrollController = ScrollController();
  bool _showFab = false;

  @override
  void initState() {
    super.initState();
    _fabController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    _scrollController.addListener(() {
      if (_scrollController.offset > 200 && !_showFab) {
        setState(() => _showFab = true);
        _fabController.forward();
      } else if (_scrollController.offset <= 200 && _showFab) {
        setState(() => _showFab = false);
        _fabController.reverse();
      }
    });
  }

  @override
  void dispose() {
    _fabController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  String _formatCurrency(int? amount) {
    if (amount == null) return '\$0.00';
    final formatter = NumberFormat.currency(symbol: '\$', decimalDigits: 2);
    return formatter.format(amount);
  }

  String _formatDate(DateTime? date) {
    if (date == null) return 'N/A';
    return DateFormat('MMMM dd, yyyy').format(date);
  }

  String _formatDateShort(DateTime? date) {
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
            .map((word) => word.isEmpty
                ? ''
                : word[0].toUpperCase() + word.substring(1).toLowerCase())
            .join(' ');
    }
  }

  String _formatStatus(String? status) {
    if (status == null || status.isEmpty) return 'Unknown';
    return status
        .split('_')
        .map((word) => word.isEmpty
            ? ''
            : word[0].toUpperCase() + word.substring(1).toLowerCase())
        .join(' ');
  }

  Color _getStatusColor(String? status) {
    switch (status?.toLowerCase()) {
      case 'processing':
      case 'under_review':
        return const Color(0xFFF57C00);
      case 'submitted':
      case 'pending':
        return const Color(0xFF1976D2);
      case 'approved':
        return const Color(0xFF388E3C);
      case 'rejected':
      case 'declined':
        return const Color(0xFFD32F2F);
      case 'cancelled':
        return const Color(0xFFC2185B);
      case 'draft':
        return const Color(0xFF616161);
      default:
        return RealTimeColors.grey700;
    }
  }

  Color _getStatusBackgroundColor(String? status) {
    switch (status?.toLowerCase()) {
      case 'processing':
      case 'under_review':
        return const Color(0xFFFFF3E0);
      case 'submitted':
      case 'pending':
        return const Color(0xFFE3F2FD);
      case 'approved':
        return const Color(0xFFE8F5E9);
      case 'rejected':
      case 'declined':
        return const Color(0xFFFFEBEE);
      case 'cancelled':
        return const Color(0xFFFCE4EC);
      case 'draft':
        return const Color(0xFFF5F5F5);
      default:
        return RealTimeColors.grey200;
    }
  }

  IconData _getStatusIcon(String? status) {
    switch (status?.toLowerCase()) {
      case 'processing':
      case 'under_review':
        return Icons.hourglass_empty_rounded;
      case 'submitted':
      case 'pending':
        return Icons.send_rounded;
      case 'approved':
        return Icons.check_circle_outline_rounded;
      case 'rejected':
      case 'declined':
        return Icons.cancel_outlined;
      case 'cancelled':
        return Icons.block_rounded;
      case 'draft':
        return Icons.edit_note_rounded;
      default:
        return Icons.help_outline_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      body: Stack(
        children: [
          // Main Content
          CustomScrollView(
            controller: _scrollController,
            physics: const BouncingScrollPhysics(),
            slivers: [
              // Custom App Bar
              _buildSliverAppBar(),

              // Content
              SliverToBoxAdapter(
                child: Column(
                  children: [
                    const SizedBox(height: 24),
                    
                    // Status Header Card
                    _buildStatusHeaderCard()
                        .animate()
                        .fadeIn(duration: 400.ms)
                        .slideY(begin: 0.2, end: 0, duration: 500.ms),

                    const SizedBox(height: 24),

                    // Amount Highlight Card
                    _buildAmountCard()
                        .animate()
                        .fadeIn(delay: 100.ms, duration: 400.ms)
                        .slideY(
                          begin: 0.2,
                          end: 0,
                          delay: 100.ms,
                          duration: 500.ms,
                        ),

                    const SizedBox(height: 24),

                    // Personal Information
                    _buildSection(
                      title: 'Personal Information',
                      icon: Icons.person_outline_rounded,
                      children: [
                        _buildInfoRow(
                          'Full Name',
                          widget.application.fullName ?? 'N/A',
                          Icons.badge_outlined,
                        ),
                        _buildInfoRow(
                          'National ID',
                          widget.application.nationalIdNumber ?? 'N/A',
                          Icons.credit_card_outlined,
                        ),
                        _buildInfoRow(
                          'Gender',
                          widget.application.gender ?? 'N/A',
                          Icons.wc_outlined,
                        ),
                        _buildInfoRow(
                          'Date of Birth',
                          _formatDateShort(widget.application.dateOfBirth),
                          Icons.cake_outlined,
                        ),
                        _buildInfoRow(
                          'Marital Status',
                          widget.application.maritalStatus ?? 'N/A',
                          Icons.favorite_outline_rounded,
                        ),
                      ],
                    ).animate()
                        .fadeIn(delay: 200.ms, duration: 400.ms)
                        .slideY(begin: 0.2, end: 0, delay: 200.ms),

                    const SizedBox(height: 24),

                    // Contact Information
                    _buildSection(
                      title: 'Contact Information',
                      icon: Icons.contact_phone_outlined,
                      children: [
                        _buildInfoRow(
                          'Phone Number',
                          widget.application.contactDetails ?? 'N/A',
                          Icons.phone_outlined,
                        ),
                        _buildInfoRow(
                          'Alternative Number',
                          widget.application.alternativeNumber ?? 'N/A',
                          Icons.phone_android_outlined,
                        ),
                        _buildInfoRow(
                          'Email Address',
                          widget.application.emailAddress ?? 'N/A',
                          Icons.email_outlined,
                        ),
                        _buildInfoRow(
                          'Home Address',
                          widget.application.homeAddress ?? 'N/A',
                          Icons.home_outlined,
                          maxLines: 2,
                        ),
                      ],
                    ).animate()
                        .fadeIn(delay: 300.ms, duration: 400.ms)
                        .slideY(begin: 0.2, end: 0, delay: 300.ms),

                    const SizedBox(height: 24),

                    // Employment Information
                    if (widget.application.employment != null)
                      _buildSection(
                        title: 'Employment Information',
                        icon: Icons.work_outline_rounded,
                        children: [
                          _buildInfoRow(
                            'Employment Type',
                            widget.application.employment?.employmentType ??
                                'N/A',
                            Icons.business_center_outlined,
                          ),
                          _buildInfoRow(
                            'Job Title',
                            widget.application.employment?.title ?? 'N/A',
                            Icons.assignment_ind_outlined,
                          ),
                          _buildInfoRow(
                            'Duration',
                            widget.application.employment?.duration ?? 'N/A',
                            Icons.schedule_outlined,
                          ),
                          _buildInfoRow(
                            'Location',
                            widget.application.employment?.location ?? 'N/A',
                            Icons.location_on_outlined,
                          ),
                          _buildInfoRow(
                            'Contacts',
                            widget.application.employment?.contacts ?? 'N/A',
                            Icons.contacts_outlined,
                          ),
                        ],
                      ).animate()
                          .fadeIn(delay: 400.ms, duration: 400.ms)
                          .slideY(begin: 0.2, end: 0, delay: 400.ms),

                    if (widget.application.employment != null)
                      const SizedBox(height: 24),

                    // Loan Details
                    _buildSection(
                      title: 'Loan Details',
                      icon: Icons.account_balance_wallet_outlined,
                      children: [
                        _buildInfoRow(
                          'Application Number',
                          widget.application.applicationNo ?? 'N/A',
                          Icons.confirmation_number_outlined,
                        ),
                        _buildInfoRow(
                          'Requested Amount',
                          _formatCurrency(
                            widget.application.requestedLoanAmount,
                          ),
                          Icons.attach_money_rounded,
                          valueColor: AppColors.primaryColor,
                        ),
                        _buildInfoRow(
                          'Application Date',
                          _formatDateShort(widget.application.createdAt),
                          Icons.calendar_today_outlined,
                        ),
                      ],
                    ).animate()
                        .fadeIn(delay: 500.ms, duration: 400.ms)
                        .slideY(begin: 0.2, end: 0, delay: 500.ms),

                    const SizedBox(height: 24),

                    // Collateral Information
                    _buildSection(
                      title: 'Collateral Information',
                      icon: Icons.security_outlined,
                      children: [
                        _buildInfoRow(
                          'Category',
                          _formatCollateralCategory(
                            widget.application.collateralCategory,
                          ),
                          Icons.category_outlined,
                        ),
                        if (widget.application.collateralDescription != null)
                          _buildInfoRow(
                            'Description',
                            widget.application.collateralDescription!,
                            Icons.description_outlined,
                            maxLines: 3,
                          ),
                        if (widget.application.declaredAssetValue != null)
                          _buildInfoRow(
                            'Declared Value',
                            _formatCurrency(
                              widget.application.declaredAssetValue,
                            ),
                            Icons.monetization_on_outlined,
                            valueColor: AppColors.successColor,
                          ),
                        if (widget.application.suretyDescription != null)
                          _buildInfoRow(
                            'Surety',
                            widget.application.suretyDescription!,
                            Icons.person_add_outlined,
                            maxLines: 2,
                          ),
                      ],
                    ).animate()
                        .fadeIn(delay: 600.ms, duration: 400.ms)
                        .slideY(begin: 0.2, end: 0, delay: 600.ms),

                    const SizedBox(height: 24),

                    // Declaration
                    if (widget.application.declarationSignatureName != null)
                      _buildSection(
                        title: 'Declaration',
                        icon: Icons.verified_outlined,
                        children: [
                          if (widget.application.declarationText != null)
                            _buildInfoRow(
                              'Agreement',
                              widget.application.declarationText!,
                              Icons.gavel_outlined,
                              maxLines: 5,
                            ),
                          _buildInfoRow(
                            'Signed By',
                            widget.application.declarationSignatureName!,
                            Icons.draw_outlined,
                          ),
                          if (widget.application.declarationSignedAt != null)
                            _buildInfoRow(
                              'Signed Date',
                              _formatDate(
                                widget.application.declarationSignedAt,
                              ),
                              Icons.event_available_outlined,
                            ),
                        ],
                      ).animate()
                          .fadeIn(delay: 700.ms, duration: 400.ms)
                          .slideY(begin: 0.2, end: 0, delay: 700.ms),

                    if (widget.application.declarationSignatureName != null)
                      const SizedBox(height: 24),

                    // Debtor Check (if available)
                    if (widget.application.debtorCheck?.checked == true)
                      _buildSection(
                        title: 'Debtor Check',
                        icon: Icons.fact_check_outlined,
                        children: [
                          _buildInfoRow(
                            'Status',
                            widget.application.debtorCheck!.matched == true
                                ? 'Matched'
                                : 'Clear',
                            widget.application.debtorCheck!.matched == true
                                ? Icons.warning_amber_rounded
                                : Icons.check_circle_outline_rounded,
                            valueColor:
                                widget.application.debtorCheck!.matched == true
                                    ? AppColors.warningColor
                                    : AppColors.successColor,
                          ),
                          if (widget.application.debtorCheck!.matched == true)
                            _buildInfoRow(
                              'Matched Records',
                              '${widget.application.debtorCheck!.matchedDebtorRecords?.length ?? 0} record(s)',
                              Icons.assignment_late_outlined,
                              valueColor: AppColors.errorColor,
                            ),
                        ],
                      ).animate()
                          .fadeIn(delay: 800.ms, duration: 400.ms)
                          .slideY(begin: 0.2, end: 0, delay: 800.ms),

                    if (widget.application.debtorCheck?.checked == true)
                      const SizedBox(height: 24),

                    // Attachments
                    if (widget.application.attachments != null &&
                        widget.application.attachments!.isNotEmpty)
                      _buildAttachmentsSection()
                          .animate()
                          .fadeIn(delay: 900.ms, duration: 400.ms)
                          .slideY(begin: 0.2, end: 0, delay: 900.ms),

                    if (widget.application.attachments != null &&
                        widget.application.attachments!.isNotEmpty)
                      const SizedBox(height: 24),

                    // Internal Notes (if available)
                    if (widget.application.internalNotes != null &&
                        widget.application.internalNotes!.isNotEmpty)
                      _buildSection(
                        title: 'Internal Notes',
                        icon: Icons.note_outlined,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: RealTimeColors.grey100,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: AppColors.borderColor,
                                width: 1,
                              ),
                            ),
                            child: Text(
                              widget.application.internalNotes!,
                              style: GoogleFonts.poppins(
                                color: AppColors.textColor,
                                fontSize: 14,
                                height: 1.6,
                              ),
                            ),
                          ),
                        ],
                      ).animate()
                          .fadeIn(delay: 1000.ms, duration: 400.ms)
                          .slideY(begin: 0.2, end: 0, delay: 1000.ms),

                    const SizedBox(height: 100),
                  ],
                ),
              ),
            ],
          ),

          // Floating Edit Button
          _buildFloatingEditButton(),
        ],
      ),
    );
  }

  Widget _buildSliverAppBar() {
    return SliverAppBar(
      expandedHeight: 120,
      floating: false,
      pinned: true,
      elevation: 0,
      backgroundColor: AppColors.primaryColor,
      leading: IconButton(
        icon: const Icon(
          Icons.arrow_back_ios_new_rounded,
          size: 20,
          color: Colors.white,
        ),
        onPressed: () => Navigator.pop(context),
      ).animate().fadeIn(delay: 100.ms).slideX(begin: -0.3, end: 0),
      flexibleSpace: FlexibleSpaceBar(
        title: Text(
          'Application Details',
          style: GoogleFonts.poppins(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: Colors.white,
            letterSpacing: -0.3,
          ),
        ).animate().fadeIn(delay: 200.ms),
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                AppColors.primaryColor,
                AppColors.primaryColor.withOpacity(0.8),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatusHeaderCard() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryColor.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: _getStatusBackgroundColor(widget.application.status),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(
              _getStatusIcon(widget.application.status),
              color: _getStatusColor(widget.application.status),
              size: 32,
            ),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Application Status',
                  style: GoogleFonts.poppins(
                    color: AppColors.subtextColor,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _formatStatus(widget.application.status),
                  style: GoogleFonts.poppins(
                    color: _getStatusColor(widget.application.status),
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    )
        .animate()
        .shimmer(
          delay: 800.ms,
          duration: 1500.ms,
          color: Colors.white.withOpacity(0.3),
        );
  }

  Widget _buildAmountCard() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.primaryColor,
            AppColors.primaryColor.withOpacity(0.8),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryColor.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.account_balance_wallet_outlined,
                color: Colors.white.withOpacity(0.9),
                size: 24,
              ),
              const SizedBox(width: 12),
              Text(
                'Requested Loan Amount',
                style: GoogleFonts.poppins(
                  color: Colors.white.withOpacity(0.9),
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  letterSpacing: 0.3,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            _formatCurrency(widget.application.requestedLoanAmount),
            style: GoogleFonts.poppins(
              color: Colors.white,
              fontSize: 40,
              fontWeight: FontWeight.w800,
              letterSpacing: -1.5,
              height: 1,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Application #${widget.application.applicationNo ?? 'N/A'}',
            style: GoogleFonts.poppins(
              color: Colors.white.withOpacity(0.8),
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    )
        .animate()
        .shimmer(
          delay: 1000.ms,
          duration: 1800.ms,
          color: Colors.white.withOpacity(0.2),
        );
  }

  Widget _buildSection({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppColors.borderColor,
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
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
                  color: AppColors.primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  color: AppColors.primaryColor,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                title,
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textColor,
                  letterSpacing: -0.3,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          ...children,
        ],
      ),
    );
  }

  Widget _buildInfoRow(
    String label,
    String value,
    IconData icon, {
    int maxLines = 1,
    Color? valueColor,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: RealTimeColors.grey100,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              icon,
              size: 18,
              color: AppColors.subtextColor,
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
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    letterSpacing: 0.3,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: GoogleFonts.poppins(
                    color: valueColor ?? AppColors.textColor,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    height: 1.4,
                  ),
                  maxLines: maxLines,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAttachmentsSection() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppColors.borderColor,
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
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
                  color: AppColors.primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.attach_file_rounded,
                  color: AppColors.primaryColor,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'Attachments',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textColor,
                  letterSpacing: -0.3,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: AppColors.primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${widget.application.attachments!.length}',
                  style: GoogleFonts.poppins(
                    color: AppColors.primaryColor,
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...widget.application.attachments!.map((attachment) {
            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: RealTimeColors.grey400,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppColors.borderColor,
                  width: 1,
                ),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppColors.primaryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      Icons.insert_drive_file_outlined,
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
                          attachment.filename ?? 'Unknown File',
                          style: GoogleFonts.poppins(
                            color: AppColors.textColor,
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          attachment.category ?? 'Uncategorized',
                          style: GoogleFonts.poppins(
                            color: AppColors.subtextColor,
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    Icons.arrow_forward_ios_rounded,
                    color: AppColors.subtextColor,
                    size: 16,
                  ),
                ],
              ),
            );
          }).toList(),
        ],
      ),
    );
  }

  Widget _buildFloatingEditButton() {
    return Positioned(
      bottom: 24,
      right: 24,
      child: ScaleTransition(
        scale: _fabController,
        child: FloatingActionButton.extended(
          onPressed: () {
            // TODO: Implement edit functionality
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  'Edit functionality coming soon!',
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                backgroundColor: AppColors.primaryColor,
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            );
          },
          backgroundColor: AppColors.primaryColor,
          elevation: 8,
          icon: const Icon(Icons.edit_outlined, size: 20),
          label: Text(
            'Edit Details',
            style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        )
            .animate(onPlay: (controller) => controller.repeat())
            .shimmer(
              delay: 2000.ms,
              duration: 1500.ms,
              color: Colors.white.withOpacity(0.3),
            ),
      ),
    );
  }
}