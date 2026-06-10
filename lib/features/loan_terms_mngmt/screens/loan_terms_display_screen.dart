import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:real_time_pawn/core/utils/pallete.dart';
import 'package:real_time_pawn/features/loan_terms_mngmt/controllers/loan_terms_mngmt_controller.dart';
import 'package:real_time_pawn/models/loan_terms_model.dart';

class LoanTermsDisplayScreen extends StatefulWidget {
  final String loanId;
  final String loanNo;

  const LoanTermsDisplayScreen({
    super.key,
    required this.loanId,
    required this.loanNo,
  });

  @override
  State<LoanTermsDisplayScreen> createState() => _LoanTermsDisplayScreenState();
}

class _LoanTermsDisplayScreenState extends State<LoanTermsDisplayScreen> {
  final LoanTermsController _controller = Get.find<LoanTermsController>();
  LoanTerm? _term;
  bool _isLoading = true;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _loadTerms();
  }

  Future<void> _loadTerms() async {
    if (!mounted) return;

    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      await _controller.fetchLoanTerms(widget.loanId, refresh: true);
      if (mounted) {
        // Get the first term from the list
        if (_controller.loanTerms.isNotEmpty) {
          setState(() {
            _term = _controller.loanTerms.first;
          });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Failed to load loan terms';
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
                          'Loan Terms',
                          style: GoogleFonts.poppins(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textColor,
                          ),
                        ),
                        Text(
                          'Loan: ${widget.loanNo}',
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            color: AppColors.subtextColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: _loadTerms,
                    icon: const Icon(Icons.refresh_outlined),
                    color: AppColors.primaryColor,
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
                            onPressed: _loadTerms,
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
                            'No Terms Found',
                            style: GoogleFonts.poppins(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textColor,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'No loan terms have been created for this loan yet.',
                            style: GoogleFonts.poppins(
                              fontSize: 14,
                              color: AppColors.subtextColor,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
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
                                  'ZWL ${_term!.currentBalance.toStringAsFixed(2)}',
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
                                'ZWL ${_term!.principalAmount.toStringAsFixed(2)}',
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
