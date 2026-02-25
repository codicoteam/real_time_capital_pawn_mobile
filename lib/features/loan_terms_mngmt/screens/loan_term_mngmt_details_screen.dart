// lib/features/loan_terms_mngmt/screens/loan_term_details_screen.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:real_time_pawn/config/routers/router.dart';
import 'package:real_time_pawn/core/utils/pallete.dart';
import 'package:real_time_pawn/features/loan_terms_mngmt/controllers/loan_terms_mngmt_controller.dart';
import 'package:real_time_pawn/models/loan_terms_model.dart';

class LoanTermDetailsScreen extends StatefulWidget {
  final String termId;
  final String loanId;

  const LoanTermDetailsScreen({
    super.key,
    required this.termId,
    required this.loanId,
  });

  @override
  State<LoanTermDetailsScreen> createState() => _LoanTermDetailsScreenState();
}

class _LoanTermDetailsScreenState extends State<LoanTermDetailsScreen> {
  final LoanTermsController _controller = Get.find<LoanTermsController>();
  LoanTerm? _term;
  bool _isLoading = true;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _loadTermDetails();
  }

  Future<void> _loadTermDetails() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      final term = await _controller.getTermDetails(widget.termId);

      if (term != null) {
        setState(() {
          _term = term;
        });
      } else {
        setState(() {
          _errorMessage = 'Failed to load term details';
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Error loading term details: ${e.toString()}';
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
      case 'approved':
        return RealTimeColors.success.withOpacity(0.8);
      case 'pending':
        return RealTimeColors.warning;
      case 'completed':
        return RealTimeColors.primaryGreen;
      case 'rejected':
        return RealTimeColors.error;
      default:
        return AppColors.subtextColor;
    }
  }

  Color _getTypeColor(String type) {
    switch (type.toLowerCase()) {
      case 'initial':
        return RealTimeColors.primaryGreen;
      case 'renewal':
        return RealTimeColors.success;
      case 'extension':
        return RealTimeColors.warning;
      case 'partial_renewal':
        return RealTimeColors.primaryGreen;
      case 'settlement':
        return RealTimeColors.error;
      default:
        return AppColors.subtextColor;
    }
  }

  String _formatDate(DateTime date) {
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

  String _formatDateTime(DateTime date) {
    final monthNames = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];
    final hours = date.hour.toString().padLeft(2, '0');
    final minutes = date.minute.toString().padLeft(2, '0');
    return '${date.day} ${monthNames[date.month - 1]} ${date.year} at $hours:$minutes';
  }

  String _getTermTypeDisplay(String type) {
    switch (type.toLowerCase()) {
      case 'initial':
        return 'Initial Term';
      case 'renewal':
        return 'Renewal Term';
      case 'extension':
        return 'Interest Extension';
      case 'partial_renewal':
        return 'Partial Principal Renewal';
      case 'settlement':
        return 'Full Settlement';
      default:
        return type;
    }
  }

  Widget _buildAmountCard({
    required String label,
    required String amount,
    required Color color,
    IconData? icon,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              if (icon != null) ...[
                Icon(icon, size: 16, color: AppColors.subtextColor),
                const SizedBox(width: 8),
              ],
              Expanded(
                child: Text(
                  label,
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: AppColors.subtextColor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            amount,
            style: GoogleFonts.poppins(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow({
    required String label,
    required String value,
    Color? valueColor,
    IconData? icon,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Flexible(
            child: Row(
              children: [
                if (icon != null) ...[
                  Icon(icon, size: 14, color: AppColors.subtextColor),
                  const SizedBox(width: 8),
                ],
                Flexible(
                  child: Text(
                    label,
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: AppColors.subtextColor,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Flexible(
            child: Text(
              value,
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: valueColor ?? AppColors.textColor,
              ),
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionCard({
    required String title,
    required List<Widget> children,
    IconData? icon,
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
          Row(
            children: [
              if (icon != null) ...[
                Icon(icon, size: 18, color: AppColors.primaryColor),
                const SizedBox(width: 8),
              ],
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
          const SizedBox(height: 16),
          ...children,
        ],
      ),
    );
  }

  Widget _buildApprovalHistory() {
    if (_term!.approvals.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surfaceColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.borderColor),
        ),
        child: Row(
          children: [
            Icon(
              Icons.history_outlined,
              size: 16,
              color: AppColors.subtextColor,
            ),
            const SizedBox(width: 8),
            Text(
              'No approval history available',
              style: GoogleFonts.poppins(
                fontSize: 12,
                color: AppColors.subtextColor,
              ),
            ),
          ],
        ),
      );
    }

    return Column(
      children: _term!.approvals.map((approval) {
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.surfaceColor,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.borderColor),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    approval.approvedBy,
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textColor,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: _getStatusColor(approval.status).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      approval.status.toUpperCase(),
                      style: GoogleFonts.poppins(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: _getStatusColor(approval.status),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                'Role: ${approval.role}',
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  color: AppColors.subtextColor,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Approved: ${_formatDateTime(approval.approvedAt)}',
                style: GoogleFonts.poppins(
                  fontSize: 10,
                  color: AppColors.subtextColor,
                ),
              ),
              if (approval.notes != null && approval.notes!.isNotEmpty) ...[
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.backgroundColor,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    approval.notes!,
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: AppColors.textColor,
                    ),
                  ),
                ),
              ],
            ],
          ),
        );
      }).toList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header
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
                          'Term Details',
                          style: GoogleFonts.poppins(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textColor,
                          ),
                        ),
                        if (_term != null)
                          Text(
                            'Term ${_term!.termNo} • ${_term!.loanNo}',
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                              color: AppColors.subtextColor,
                            ),
                          ),
                      ],
                    ),
                  ),
                  if (_term != null)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: _getStatusColor(_term!.status).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        _term!.status.toUpperCase(),
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: _getStatusColor(_term!.status),
                        ),
                      ),
                    ),
                ],
              ),
            ),

            // Main Content
            Expanded(
              child: _isLoading
                  ? Center(
                      child: CircularProgressIndicator(
                        color: AppColors.primaryColor,
                      ),
                    )
                  : _errorMessage.isNotEmpty
                  ? Center(
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
                              onPressed: _loadTermDetails,
                              style: ElevatedButton.styleFrom(
                                foregroundColor: Colors.white,
                                backgroundColor: AppColors.primaryColor,
                              ),
                              child: const Text('Retry'),
                            ),
                          ],
                        ),
                      ),
                    )
                  : _term == null
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.assignment_outlined,
                            size: 64,
                            color: RealTimeColors.grey400,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Term not found',
                            style: GoogleFonts.poppins(
                              fontSize: 20,
                              fontWeight: FontWeight.w600,
                              color: AppColors.subtextColor,
                            ),
                          ),
                        ],
                      ),
                    )
                  : SingleChildScrollView(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // Term Type Badge
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: _getTypeColor(
                                _term!.termType,
                              ).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: _getTypeColor(_term!.termType),
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  _term!.termType == 'initial'
                                      ? Icons.start_outlined
                                      : _term!.termType == 'renewal'
                                      ? Icons.autorenew_outlined
                                      : _term!.termType == 'extension'
                                      ? Icons
                                            .extension_outlined // FIXED: Changed from extensions_outlined to extension_outlined
                                      : Icons.check_circle_outline,
                                  size: 16,
                                  color: _getTypeColor(_term!.termType),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  _getTermTypeDisplay(_term!.termType),
                                  style: GoogleFonts.poppins(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: _getTypeColor(_term!.termType),
                                  ),
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 20),

                          // Amount Cards
                          Row(
                            children: [
                              Expanded(
                                child: _buildAmountCard(
                                  label: 'Principal Amount',
                                  amount: _term!.formattedPrincipalAmount,
                                  color: AppColors.textColor,
                                  icon: Icons.account_balance_wallet_outlined,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: _buildAmountCard(
                                  label: 'Current Balance',
                                  amount: _term!.formattedCurrentBalance,
                                  color: _term!.isActive
                                      ? RealTimeColors.warning
                                      : RealTimeColors.success,
                                  icon: Icons.balance_outlined,
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 12),

                          // Additional Amounts
                          if (_term!.interestAmount != null ||
                              _term!.storageChargeAmount != null ||
                              _term!.penaltyAmount != null)
                            Wrap(
                              spacing: 12,
                              runSpacing: 12,
                              children: [
                                if (_term!.interestAmount != null)
                                  Container(
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: AppColors.surfaceColor,
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                        color: AppColors.borderColor,
                                      ),
                                    ),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Interest',
                                          style: GoogleFonts.poppins(
                                            fontSize: 10,
                                            color: AppColors.subtextColor,
                                          ),
                                        ),
                                        Text(
                                          'ZWL ${_term!.interestAmount!.toStringAsFixed(2)}',
                                          style: GoogleFonts.poppins(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w600,
                                            color: AppColors.textColor,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                if (_term!.storageChargeAmount != null)
                                  Container(
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: AppColors.surfaceColor,
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                        color: AppColors.borderColor,
                                      ),
                                    ),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Storage Charge',
                                          style: GoogleFonts.poppins(
                                            fontSize: 10,
                                            color: AppColors.subtextColor,
                                          ),
                                        ),
                                        Text(
                                          'ZWL ${_term!.storageChargeAmount!.toStringAsFixed(2)}',
                                          style: GoogleFonts.poppins(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w600,
                                            color: AppColors.textColor,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                if (_term!.penaltyAmount != null)
                                  Container(
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: AppColors.surfaceColor,
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                        color: AppColors.borderColor,
                                      ),
                                    ),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Penalty',
                                          style: GoogleFonts.poppins(
                                            fontSize: 10,
                                            color: AppColors.subtextColor,
                                          ),
                                        ),
                                        Text(
                                          'ZWL ${_term!.penaltyAmount!.toStringAsFixed(2)}',
                                          style: GoogleFonts.poppins(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w600,
                                            color: RealTimeColors.error,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                              ],
                            ),

                          const SizedBox(height: 24),

                          // Term Information
                          _buildSectionCard(
                            title: 'Term Information',
                            icon: Icons.info_outline,
                            children: [
                              _buildInfoRow(
                                label: 'Term Number',
                                value: _term!.termNo,
                                icon: Icons.numbers_outlined,
                              ),
                              _buildInfoRow(
                                label: 'Start Date',
                                value: _formatDate(_term!.startDate),
                                icon: Icons.calendar_today_outlined,
                              ),
                              _buildInfoRow(
                                label: 'End Date',
                                value: _formatDate(_term!.endDate),
                                icon: Icons.date_range_outlined,
                              ),
                              _buildInfoRow(
                                label: 'Term Duration',
                                value: _term!.formattedTermDuration,
                                icon: Icons.timer_outlined,
                              ),
                              _buildInfoRow(
                                label: 'Interest Rate',
                                value: _term!.formattedInterestRate,
                                icon: Icons.percent_outlined,
                              ),
                              if (_term!.previousBalance != null)
                                _buildInfoRow(
                                  label: 'Previous Balance',
                                  value:
                                      'ZWL ${_term!.previousBalance!.toStringAsFixed(2)}',
                                  icon: Icons.history_outlined,
                                ),
                            ],
                          ),

                          const SizedBox(height: 16),

                          // Status Information
                          _buildSectionCard(
                            title: 'Status Information',
                            icon: Icons.extension_outlined,
                            children: [
                              _buildInfoRow(
                                label: 'Created By',
                                value: _term!.createdBy,
                                icon: Icons.person_outline,
                              ),
                              _buildInfoRow(
                                label: 'Created Date',
                                value: _formatDateTime(_term!.createdAt),
                                icon: Icons.add_circle_outline,
                              ),
                              if (_term!.approvedBy != null)
                                _buildInfoRow(
                                  label: 'Approved By',
                                  value: _term!.approvedBy!,
                                  icon: Icons.verified_outlined,
                                ),
                              if (_term!.approvedAt != null)
                                _buildInfoRow(
                                  label: 'Approved Date',
                                  value: _formatDateTime(_term!.approvedAt!),
                                  icon: Icons.check_circle_outline,
                                ),
                              _buildInfoRow(
                                label: 'Last Updated',
                                value: _formatDateTime(_term!.updatedAt),
                                icon: Icons.update_outlined,
                              ),
                            ],
                          ),

                          const SizedBox(height: 16),

                          // Approval History
                          _buildSectionCard(
                            title: 'Approval History',
                            icon: Icons.history_outlined,
                            children: [_buildApprovalHistory()],
                          ),

                          const SizedBox(height: 16),

                          // Notes
                          if (_term!.notes != null && _term!.notes!.isNotEmpty)
                            _buildSectionCard(
                              title: 'Notes',
                              icon: Icons.note_outlined,
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: AppColors.backgroundColor,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    _term!.notes!,
                                    style: GoogleFonts.poppins(
                                      fontSize: 14,
                                      color: AppColors.textColor,
                                      height: 1.4,
                                    ),
                                  ),
                                ),
                              ],
                            ),

                          // Renewal Reason
                          if (_term!.renewalReason != null &&
                              _term!.renewalReason!.isNotEmpty)
                            _buildSectionCard(
                              title: 'Renewal Reason',
                              icon: Icons.receipt_long_outlined,
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: AppColors.backgroundColor,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    _term!.renewalReason!,
                                    style: GoogleFonts.poppins(
                                      fontSize: 14,
                                      color: AppColors.textColor,
                                      height: 1.4,
                                    ),
                                  ),
                                ),
                              ],
                            ),

                          const SizedBox(height: 24),

                          // Action Buttons
                          if (_term!.isActive)
                            Column(
                              children: [
                                ElevatedButton(
                                  onPressed: () {
                                    Get.toNamed(
                                      RoutesHelper
                                          .renewLoanTermScreen, // FIXED: Changed from RenewLoanTermScreen to renewLoanTermScreen
                                      arguments: {
                                        'loanId': widget.loanId,
                                        'currentTerm': _term,
                                      },
                                    );
                                  },
                                  style: ElevatedButton.styleFrom(
                                    foregroundColor: Colors.white,
                                    backgroundColor: AppColors.primaryColor,
                                    minimumSize: const Size(
                                      double.infinity,
                                      48,
                                    ),
                                  ),
                                  child: const Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(Icons.autorenew_outlined),
                                      SizedBox(width: 8),
                                      Text('Renew This Term'),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 12),
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
}
