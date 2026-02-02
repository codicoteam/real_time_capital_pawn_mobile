// lib/features/loan_terms_mngmt/screens/loan_term_timeline_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:real_time_pawn/core/utils/pallete.dart';
import 'package:real_time_pawn/features/loan_terms_mngmt/controllers/loan_terms_mngmt_controller.dart';
import 'package:real_time_pawn/models/loan_terms_model.dart';

class LoanTermTimelineScreen extends StatefulWidget {
  final String loanId;

  const LoanTermTimelineScreen({super.key, required this.loanId});

  @override
  State<LoanTermTimelineScreen> createState() => _LoanTermTimelineScreenState();
}

class _LoanTermTimelineScreenState extends State<LoanTermTimelineScreen> {
  final LoanTermsController _controller = Get.find<LoanTermsController>();
  bool _isInitialLoad = true;

  @override
  void initState() {
    super.initState();
    _loadTimeline();
  }

  Future<void> _loadTimeline() async {
    await _controller.fetchTermTimeline(widget.loanId);
    setState(() {
      _isInitialLoad = false;
    });
  }

  Color _getEventColor(String eventType) {
    switch (eventType.toLowerCase()) {
      case 'term_start':
        return RealTimeColors.primaryGreen;
      case 'renewal':
        return RealTimeColors.success;
      case 'extension':
        return RealTimeColors.warning;
      case 'payment':
        return RealTimeColors.primaryGreen;
      case 'approval':
        return RealTimeColors.success.withOpacity(0.8);
      case 'due_date':
        return RealTimeColors.error;
      default:
        return AppColors.subtextColor;
    }
  }

  IconData _getEventIcon(String eventType) {
    switch (eventType.toLowerCase()) {
      case 'term_start':
        return Icons.play_circle_outline;
      case 'renewal':
        return Icons.autorenew_outlined;
      case 'extension':
        return Icons.extension_outlined;
      case 'payment':
        return Icons.payments_outlined;
      case 'approval':
        return Icons.verified_outlined;
      case 'due_date':
        return Icons.calendar_today_outlined;
      default:
        return Icons.event_outlined;
    }
  }

  String _formatDateTime(DateTime date) {
    final format = DateFormat('dd MMM yyyy, HH:mm');
    return format.format(date);
  }

  String _formatAmount(double? amount) {
    if (amount == null) return '';
    return 'ZWL ${amount.toStringAsFixed(2)}';
  }

  Widget _buildTimelineItem(TimelineEvent event, int index, bool isLast) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Timeline line and dot
        Column(
          children: [
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color: _getEventColor(event.eventType),
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 3),
              ),
              child: Icon(
                _getEventIcon(event.eventType),
                size: 12,
                color: Colors.white,
              ),
            ),
            if (!isLast)
              Container(
                width: 2,
                height: 60,
                color: AppColors.borderColor,
                margin: const EdgeInsets.only(top: 4, bottom: 4),
              ),
          ],
        ),
        const SizedBox(width: 16),

        // Event content
        Expanded(
          child: Container(
            margin: const EdgeInsets.only(bottom: 20),
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
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        event.description,
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textColor,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: _getEventColor(event.eventType).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        event.eventType.replaceAll('_', ' ').toUpperCase(),
                        style: GoogleFonts.poppins(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: _getEventColor(event.eventType),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  _formatDateTime(event.date),
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: AppColors.subtextColor,
                  ),
                ),
                if (event.termNo != null && event.termNo!.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.backgroundColor,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.numbers_outlined,
                          size: 14,
                          color: AppColors.subtextColor,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Term ${event.termNo}',
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: AppColors.textColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
                if (event.amount != null && event.amount! > 0) ...[
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.backgroundColor,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.account_balance_wallet_outlined,
                          size: 14,
                          color: AppColors.subtextColor,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          _formatAmount(event.amount),
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: event.eventType == 'payment'
                                ? RealTimeColors.success
                                : AppColors.textColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
                if (event.status != null && event.status!.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.backgroundColor,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.extension_outlined,
                          size: 14,
                          color: AppColors.subtextColor,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Status: ${event.status!.toUpperCase()}',
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: AppColors.textColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStatisticsCard() {
    if (_controller.timeline.value == null) return const SizedBox();

    final timeline = _controller.timeline.value!;

    return Container(
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
          Text(
            'Loan Timeline Summary',
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.textColor,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _buildTimelineStat(
                label: 'Total Terms',
                value: timeline.totalTerms.toString(),
                icon: Icons.list_alt_outlined,
                color: RealTimeColors.primaryGreen,
              ),
              const SizedBox(width: 12),
              _buildTimelineStat(
                label: 'Events',
                value: timeline.events.length.toString(),
                icon: Icons.timeline_outlined,
                color: RealTimeColors.primaryGreen,
              ),
              const SizedBox(width: 12),
              _buildTimelineStat(
                label: 'Total Principal',
                value: _formatAmount(timeline.totalPrincipal),
                icon: Icons.account_balance_wallet_outlined,
                color: AppColors.textColor,
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _buildTimelineStat(
                label: 'Total Interest',
                value: _formatAmount(timeline.totalInterest),
                icon: Icons.percent_outlined,
                color: RealTimeColors.warning,
              ),
              const SizedBox(width: 12),
              _buildTimelineStat(
                label: 'Total Paid',
                value: _formatAmount(timeline.totalPaid),
                icon: Icons.payments_outlined,
                color: RealTimeColors.success,
              ),
              const SizedBox(width: 12),
              _buildTimelineStat(
                label: 'Outstanding',
                value: _formatAmount(timeline.outstandingBalance),
                icon: Icons.balance_outlined,
                color: RealTimeColors.error,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTimelineStat({
    required String label,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.backgroundColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.borderColor.withOpacity(0.3)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, size: 12, color: color),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    value,
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: color,
                    ),
                    overflow: TextOverflow.ellipsis,
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
            Icons.timeline_outlined,
            size: 64,
            color: RealTimeColors.grey400,
          ),
          const SizedBox(height: 16),
          Text(
            'No Timeline Events',
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppColors.textColor,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'There are no timeline events available for this loan yet.',
            style: GoogleFonts.poppins(
              fontSize: 14,
              color: AppColors.subtextColor,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _loadTimeline,
            style: ElevatedButton.styleFrom(
              foregroundColor: Colors.white,
              backgroundColor: AppColors.primaryColor,
            ),
            child: const Text('Refresh'),
          ),
        ],
      ),
    );
  }

  Widget _buildEventTypeFilter() {
    final eventTypes =
        _controller.timeline.value?.events
            .map((e) => e.eventType)
            .toSet()
            .toList() ??
        [];

    if (eventTypes.isEmpty) return const SizedBox();

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Filter by Event Type',
            style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.textColor,
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _buildEventTypeChip('All', true),
              ...eventTypes.map((type) => _buildEventTypeChip(type, false)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEventTypeChip(String type, bool isAll) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: isAll ? AppColors.primaryColor : AppColors.surfaceColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isAll ? AppColors.primaryColor : AppColors.borderColor,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            _getEventIcon(type),
            size: 12,
            color: isAll ? Colors.white : _getEventColor(type),
          ),
          const SizedBox(width: 4),
          Text(
            isAll ? 'All' : type.replaceAll('_', ' '),
            style: GoogleFonts.poppins(
              fontSize: 10,
              color: isAll ? Colors.white : AppColors.textColor,
              fontWeight: isAll ? FontWeight.w600 : FontWeight.w400,
            ),
          ),
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
                          'Loan Timeline',
                          style: GoogleFonts.poppins(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textColor,
                          ),
                        ),
                        Text(
                          'Visual history of all loan terms',
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            color: AppColors.subtextColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: _loadTimeline,
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
                      if (_controller.isLoadingTimeline.value) {
                        return Center(
                          child: CircularProgressIndicator(
                            color: AppColors.primaryColor,
                          ),
                        );
                      }

                      if (_controller.timeline.value == null ||
                          _controller.timeline.value!.events.isEmpty) {
                        return SingleChildScrollView(
                          padding: const EdgeInsets.all(16),
                          child: _buildEmptyState(),
                        );
                      }

                      final timeline = _controller.timeline.value!;

                      return SingleChildScrollView(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            // Statistics Card
                            _buildStatisticsCard()
                                .animate()
                                .fadeIn(duration: 600.ms)
                                .slideY(begin: 0.3),

                            const SizedBox(height: 20),

                            // Event Type Filter
                            _buildEventTypeFilter().animate().fadeIn(
                              duration: 600.ms,
                              delay: 200.ms,
                            ),

                            // Timeline
                            Text(
                              'Timeline Events (${timeline.events.length})',
                              style: GoogleFonts.poppins(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textColor,
                              ),
                            ).animate().fadeIn(duration: 600.ms, delay: 400.ms),
                            const SizedBox(height: 16),

                            // Timeline Items
                            ...timeline.events
                                .asMap()
                                .entries
                                .map(
                                  (entry) => _buildTimelineItem(
                                    entry.value,
                                    entry.key,
                                    entry.key == timeline.events.length - 1,
                                  ),
                                )
                                .toList()
                                .animate(interval: 100.ms)
                                .fadeIn(duration: 600.ms, delay: 600.ms)
                                .slideY(begin: 0.3),

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
}
