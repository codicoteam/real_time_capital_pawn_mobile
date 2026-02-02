// loan_terms_mngmt_screen.dart
// lib/features/loan_terms_mngmt/screens/loan_terms_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:real_time_pawn/config/routers/router.dart';
import 'package:real_time_pawn/core/utils/pallete.dart';
import 'package:real_time_pawn/features/loan_terms_mngmt/controllers/loan_terms_mngmt_controller.dart';
import 'package:real_time_pawn/models/loan_terms_model.dart';

class LoanTermsScreen extends StatefulWidget {
  final String loanId;
  final String loanNo;

  const LoanTermsScreen({
    super.key,
    required this.loanId,
    required this.loanNo,
  });

  @override
  State<LoanTermsScreen> createState() => _LoanTermsScreenState();
}

class _LoanTermsScreenState extends State<LoanTermsScreen> {
  final LoanTermsController _controller = Get.put(LoanTermsController());
  final ScrollController _scrollController = ScrollController();
  bool _isInitialLoad = true;

  @override
  void initState() {
    super.initState();
    _loadInitialData();
    _scrollController.addListener(_scrollListener);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadInitialData() async {
    await _controller.fetchLoanTerms(widget.loanId, refresh: true);
    await _controller.fetchTermStats(loanId: widget.loanId);
    setState(() {
      _isInitialLoad = false;
    });
  }

  void _scrollListener() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      if (!_controller.isLoadingMore.value && _controller.hasNextPage.value) {
        _controller.loadMoreTerms(widget.loanId);
      }
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
    return '${date.day}/${date.month}/${date.year}';
  }

  String _getTermTypeDisplay(String type) {
    switch (type.toLowerCase()) {
      case 'initial':
        return 'Initial Term';
      case 'renewal':
        return 'Renewal';
      case 'extension':
        return 'Extension';
      case 'partial_renewal':
        return 'Partial Renewal';
      case 'settlement':
        return 'Settlement';
      default:
        return type;
    }
  }

  Widget _buildTermCard(LoanTerm term) {
    return GestureDetector(
      onTap: () {
        Get.toNamed(
          RoutesHelper.loanTermDetailsScreen,
          arguments: {'termId': term.id, 'loanId': widget.loanId},
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surfaceColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.borderColor),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              spreadRadius: 0,
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Term ${term.termNo}',
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textColor,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _getTermTypeDisplay(term.termType),
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: _getTypeColor(term.termType),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: _getStatusColor(term.status).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    term.status.toUpperCase(),
                    style: GoogleFonts.poppins(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: _getStatusColor(term.status),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Principal',
                        style: GoogleFonts.poppins(
                          fontSize: 10,
                          color: AppColors.subtextColor,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        term.formattedPrincipalAmount,
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textColor,
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Current Balance',
                        style: GoogleFonts.poppins(
                          fontSize: 10,
                          color: AppColors.subtextColor,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        term.formattedCurrentBalance,
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: term.isActive
                              ? RealTimeColors.warning
                              : AppColors.textColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Interest Rate',
                        style: GoogleFonts.poppins(
                          fontSize: 10,
                          color: AppColors.subtextColor,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        term.formattedInterestRate,
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: AppColors.textColor,
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Duration',
                        style: GoogleFonts.poppins(
                          fontSize: 10,
                          color: AppColors.subtextColor,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        term.formattedTermDuration,
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: AppColors.textColor,
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Period',
                        style: GoogleFonts.poppins(
                          fontSize: 10,
                          color: AppColors.subtextColor,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${_formatDate(term.startDate)} - ${_formatDate(term.endDate)}',
                        style: GoogleFonts.poppins(
                          fontSize: 10,
                          fontWeight: FontWeight.w500,
                          color: AppColors.textColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            if (term.notes != null && term.notes!.isNotEmpty) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.backgroundColor,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: AppColors.borderColor.withOpacity(0.3),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.note_outlined,
                      size: 12,
                      color: AppColors.subtextColor,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        term.notes!,
                        style: GoogleFonts.poppins(
                          fontSize: 10,
                          color: AppColors.subtextColor,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildStatisticsCard() {
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
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Loan Terms Overview',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textColor,
                ),
              ),
              Icon(
                Icons.analytics_outlined,
                color: AppColors.primaryColor,
                size: 20,
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildStatItem(
                  label: 'Total Terms',
                  value: _controller.totalTerms.value.toString(),
                  icon: Icons.list_alt_outlined,
                  color: RealTimeColors.primaryGreen,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatItem(
                  label: 'Active',
                  value: _controller.activeTermsCount.toString(),
                  icon: Icons.play_circle_outline,
                  color: RealTimeColors.success,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatItem(
                  label: 'Pending',
                  value: _controller.pendingTermsCount.toString(),
                  icon: Icons.pending_outlined,
                  color: RealTimeColors.warning,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _controller.stats.value != null
              ? Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.backgroundColor,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.account_balance_wallet_outlined,
                        size: 16,
                        color: AppColors.subtextColor,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Total Outstanding: ZWL ${_controller.totalOutstandingBalance.toStringAsFixed(2)}',
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: RealTimeColors.warning,
                          ),
                        ),
                      ),
                    ],
                  ),
                )
              : const SizedBox(),
        ],
      ),
    );
  }

  Widget _buildStatItem({
    required String label,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.backgroundColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.borderColor.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 14, color: color),
              const SizedBox(width: 4),
              Text(
                value,
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: color,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 10,
              color: AppColors.subtextColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChips() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          _buildFilterChip('All', _controller.selectedFilter.value == 'All'),
          const SizedBox(width: 8),
          _buildFilterChip(
            'Active',
            _controller.selectedFilter.value == 'Active',
          ),
          const SizedBox(width: 8),
          _buildFilterChip(
            'Pending',
            _controller.selectedFilter.value == 'Pending',
          ),
          const SizedBox(width: 8),
          _buildFilterChip(
            'Completed',
            _controller.selectedFilter.value == 'Completed',
          ),
          const SizedBox(width: 8),
          _buildFilterChip(
            'Approved',
            _controller.selectedFilter.value == 'Approved',
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, bool isSelected) {
    return GestureDetector(
      onTap: () {
        _controller.setFilter(label);
        _controller.fetchLoanTerms(widget.loanId, refresh: true);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primaryColor : AppColors.surfaceColor,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? AppColors.primaryColor : AppColors.borderColor,
          ),
        ),
        child: Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 12,
            color: isSelected ? Colors.white : AppColors.textColor,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
          ),
        ),
      ),
    );
  }

  Widget _buildTypeFilterChips() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          _buildTypeFilterChip(
            'All',
            _controller.selectedTypeFilter.value == 'All',
          ),
          const SizedBox(width: 8),
          _buildTypeFilterChip(
            'Initial',
            _controller.selectedTypeFilter.value == 'Initial',
          ),
          const SizedBox(width: 8),
          _buildTypeFilterChip(
            'Renewal',
            _controller.selectedTypeFilter.value == 'Renewal',
          ),
          const SizedBox(width: 8),
          _buildTypeFilterChip(
            'Extension',
            _controller.selectedTypeFilter.value == 'Extension',
          ),
          const SizedBox(width: 8),
          _buildTypeFilterChip(
            'Settlement',
            _controller.selectedTypeFilter.value == 'Settlement',
          ),
        ],
      ),
    );
  }

  Widget _buildTypeFilterChip(String label, bool isSelected) {
    return GestureDetector(
      onTap: () {
        _controller.setTypeFilter(label);
        _controller.fetchLoanTerms(widget.loanId, refresh: true);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected
              ? RealTimeColors.primaryGreen
              : AppColors.surfaceColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected
                ? RealTimeColors.primaryGreen
                : AppColors.borderColor,
          ),
        ),
        child: Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 10,
            color: isSelected ? Colors.white : AppColors.textColor,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
          ),
        ),
      ),
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
                    onPressed: () async {
                      await _loadInitialData();
                    },
                    icon: const Icon(Icons.refresh),
                    color: AppColors.primaryColor,
                  ),
                ],
              ),
            ),

            // Main Content
            Expanded(
              child: _isInitialLoad
                  ? Center(
                      child: CircularProgressIndicator(
                        color: AppColors.primaryColor,
                      ),
                    )
                  : Obx(() {
                      return SingleChildScrollView(
                        controller: _scrollController,
                        physics: const BouncingScrollPhysics(),
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            // Quick Actions
                            Row(
                                  children: [
                                    Expanded(
                                      child: _buildActionButton(
                                        icon: Icons.timeline_outlined,
                                        label: 'View Timeline',
                                        onTap: () {
                                          Get.toNamed(
                                            RoutesHelper.loanTermTimelineScreen,
                                            arguments: {
                                              'loanId': widget.loanId,
                                            },
                                          );
                                        },
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: _buildActionButton(
                                        icon: Icons.autorenew_outlined,
                                        label: 'Renew Loan',
                                        onTap: () {
                                          if (_controller.currentTerm.value !=
                                              null) {
                                            Get.toNamed(
                                              RoutesHelper.renewLoanTermScreen,
                                              arguments: {
                                                'loanId': widget.loanId,
                                                'currentTerm': _controller
                                                    .currentTerm
                                                    .value,
                                              },
                                            );
                                          } else {
                                            Get.snackbar(
                                              'Info',
                                              'No active term to renew',
                                              snackPosition: SnackPosition.TOP,
                                            );
                                          }
                                        },
                                      ),
                                    ),
                                  ],
                                )
                                .animate()
                                .fadeIn(duration: 600.ms)
                                .slideY(begin: 0.3),

                            const SizedBox(height: 20),

                            // Statistics Card
                            _buildStatisticsCard()
                                .animate()
                                .fadeIn(duration: 800.ms, delay: 200.ms)
                                .slideY(begin: 0.3),

                            const SizedBox(height: 20),

                            // Filters
                            Text(
                              'Filter by Status',
                              style: GoogleFonts.poppins(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textColor,
                              ),
                            ).animate().fadeIn(duration: 600.ms, delay: 400.ms),
                            const SizedBox(height: 12),
                            _buildFilterChips().animate().fadeIn(
                              duration: 600.ms,
                              delay: 500.ms,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Filter by Type',
                              style: GoogleFonts.poppins(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textColor,
                              ),
                            ).animate().fadeIn(duration: 600.ms, delay: 600.ms),
                            const SizedBox(height: 12),
                            _buildTypeFilterChips().animate().fadeIn(
                              duration: 600.ms,
                              delay: 700.ms,
                            ),

                            const SizedBox(height: 24),

                            // Current Term Section
                            if (_controller.currentTerm.value != null) ...[
                              Text(
                                'Current Term',
                                style: GoogleFonts.poppins(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.textColor,
                                ),
                              ).animate().fadeIn(
                                duration: 600.ms,
                                delay: 800.ms,
                              ),
                              const SizedBox(height: 12),
                              _buildTermCard(_controller.currentTerm.value!)
                                  .animate()
                                  .fadeIn(duration: 800.ms, delay: 900.ms)
                                  .slideY(begin: 0.3),
                              const SizedBox(height: 24),
                            ],

                            // All Terms Section
                            Text(
                              'All Terms (${_controller.filteredTerms.length})',
                              style: GoogleFonts.poppins(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textColor,
                              ),
                            ).animate().fadeIn(
                              duration: 600.ms,
                              delay: 1000.ms,
                            ),
                            const SizedBox(height: 12),

                            // Terms List
                            if (_controller.isLoading.value &&
                                _controller.loanTerms.isEmpty)
                              Center(
                                child: Padding(
                                  padding: const EdgeInsets.all(32.0),
                                  child: CircularProgressIndicator(
                                    color: AppColors.primaryColor,
                                  ),
                                ),
                              )
                            else if (_controller.filteredTerms.isEmpty)
                              _buildEmptyState()
                            else
                              ..._controller.filteredTerms
                                  .map((term) => _buildTermCard(term))
                                  .toList()
                                  .animate(interval: 100.ms)
                                  .fadeIn(duration: 600.ms, delay: 1100.ms)
                                  .slideY(begin: 0.3),

                            // Loading More Indicator
                            if (_controller.isLoadingMore.value)
                              Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Center(
                                  child: CircularProgressIndicator(
                                    color: AppColors.primaryColor,
                                  ),
                                ),
                              ),

                            const SizedBox(height: 32),
                          ],
                        ),
                      );
                    }),
            ),
          ],
        ),
      ),
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
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              spreadRadius: 0,
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
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
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 32),
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: AppColors.surfaceColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderColor),
      ),
      child: Column(
        children: [
          Icon(
            Icons.assignment_outlined,
            size: 64,
            color: RealTimeColors.grey400,
          ),
          const SizedBox(height: 16),
          Text(
            'No Loan Terms Found',
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppColors.textColor,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _controller.selectedFilter.value != 'All'
                ? 'No ${_controller.selectedFilter.value.toLowerCase()} terms available'
                : 'No loan terms have been created yet',
            style: GoogleFonts.poppins(
              fontSize: 14,
              color: AppColors.subtextColor,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          if (_controller.selectedFilter.value != 'All')
            ElevatedButton(
              onPressed: () {
                _controller.setFilter('All');
                _controller.fetchLoanTerms(widget.loanId, refresh: true);
              },
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.white,
                backgroundColor: AppColors.primaryColor,
              ),
              child: const Text('Clear Filter'),
            ),
        ],
      ),
    );
  }
}
