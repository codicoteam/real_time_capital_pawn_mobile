// lib/features/loan_terms_mngmt/screens/loan_term_mngmt_details_screen.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
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
    if (!mounted) return;

    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      final term = await _controller.getTermDetails(widget.termId);
      if (mounted) {
        setState(() {
          _term = term;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Error loading term details';
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'active':
        return RealTimeColors.success;
      case 'approved':
        return RealTimeColors.success;
      case 'pending':
        return RealTimeColors.warning;
      case 'completed':
        return AppColors.primaryColor;
      case 'rejected':
        return RealTimeColors.error;
      default:
        return AppColors.subtextColor;
    }
  }

  String _formatDate(DateTime date) {
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

  String _formatDateTime(DateTime date) {
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
    final hour = date.hour.toString().padLeft(2, '0');
    final minute = date.minute.toString().padLeft(2, '0');
    return '${date.day} ${monthNames[date.month - 1]} ${date.year} at $hour:$minute';
  }

  Widget _buildInfoRow(String label, String value, {Color? valueColor}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 12,
              color: AppColors.subtextColor,
            ),
          ),
          Text(
            value,
            style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: valueColor ?? AppColors.textColor,
            ),
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
      margin: const EdgeInsets.only(bottom: 16),
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
          const SizedBox(height: 16),
          ...children,
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      body: SafeArea(
        child: Column(
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
                            'Term ${_term!.termNo}',
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
                        color: _getStatusColor(_term!.status).withValues(alpha: 0.1),
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

            // Body
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _errorMessage.isNotEmpty
                  ? Center(
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
                              color: AppColors.textColor,
                            ),
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: _loadTermDetails,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primaryColor,
                              foregroundColor: Colors.white,
                            ),
                            child: const Text('Retry'),
                          ),
                        ],
                      ),
                    )
                  : _term == null
                  ? Center(
                      child: Text(
                        'Term not found',
                        style: GoogleFonts.poppins(
                          color: AppColors.subtextColor,
                        ),
                      ),
                    )
                  : SingleChildScrollView(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          // Amount Card
                          Container(
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  AppColors.primaryColor,
                                  AppColors.primaryColor.withValues(alpha: 0.8),
                                ],
                              ),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Column(
                              children: [
                                Text(
                                  'Current Balance',
                                  style: GoogleFonts.poppins(
                                    color: Colors.white70,
                                    fontSize: 12,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  _term!.formattedCurrentBalance,
                                  style: GoogleFonts.poppins(
                                    color: Colors.white,
                                    fontSize: 28,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 16),

                          // Term Information
                          _buildSectionCard(
                            title: 'Term Information',
                            children: [
                              _buildInfoRow('Term Number', _term!.termNo),
                              _buildInfoRow(
                                'Term Type',
                                _term!.termType[0].toUpperCase() +
                                    _term!.termType.substring(1),
                              ),
                              _buildInfoRow(
                                'Principal',
                                _term!.formattedPrincipalAmount,
                              ),
                              _buildInfoRow(
                                'Interest Rate',
                                '${_term!.interestRatePercent}%',
                              ),
                              _buildInfoRow(
                                'Start Date',
                                _formatDate(_term!.startDate),
                              ),
                              _buildInfoRow(
                                'End Date',
                                _formatDate(_term!.endDate),
                              ),
                              _buildInfoRow(
                                'Duration',
                                '${_term!.termDays} days',
                              ),
                            ],
                          ),

                          // Additional Details
                          _buildSectionCard(
                            title: 'Additional Details',
                            children: [
                              _buildInfoRow('Created By', _term!.createdBy),
                              _buildInfoRow(
                                'Created At',
                                _formatDateTime(_term!.createdAt),
                              ),
                              _buildInfoRow(
                                'Last Updated',
                                _formatDateTime(_term!.updatedAt),
                              ),
                            ],
                          ),

                          // Notes
                          if (_term!.notes != null && _term!.notes!.isNotEmpty)
                            _buildSectionCard(
                              title: 'Notes',
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
                                    ),
                                  ),
                                ),
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
