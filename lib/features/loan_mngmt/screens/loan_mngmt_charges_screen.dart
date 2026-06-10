import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:real_time_pawn/config/routers/router.dart';
import 'package:real_time_pawn/core/utils/pallete.dart';
import 'package:real_time_pawn/features/loan_mngmt/controllers/loan_mngmt_controller.dart';

class LoanChargesScreen extends StatefulWidget {
  final String loanId;
  const LoanChargesScreen({super.key, required this.loanId});

  @override
  State<LoanChargesScreen> createState() => _LoanChargesScreenState();
}

class _LoanChargesScreenState extends State<LoanChargesScreen> {
  final LoanController _controller = Get.find<LoanController>();
  Map<String, dynamic>? _data;
  bool _isLoading = true;
  String _error = '';

  // Safe double extractor — handles int/double/null from JSON
  double _d(String key, [double fallback = 0.0]) =>
      (_data?[key] as num?)?.toDouble() ?? fallback;

  int _i(String key, [int fallback = 0]) =>
      (_data?[key] as num?)?.toInt() ?? fallback;

  bool _b(String key, [bool fallback = false]) =>
      (_data?[key] as bool?) ?? fallback;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  Future<void> _load() async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
      _error = '';
    });
    try {
      final charges = await _controller.calculateLoanCharges(widget.loanId);
      if (!mounted) return;
      setState(() {
        _data = charges;
        _isLoading = false;
        if (charges == null) _error = 'No charges data available';
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = 'Failed to load charges';
        _isLoading = false;
      });
    }
  }

  String _fmt(double v) => 'USD \$${v.toStringAsFixed(2)}';

  String _fmtDate(String? raw) {
    if (raw == null || raw.isEmpty) return '—';
    try {
      final d = DateTime.parse(raw);
      const m = ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'];
      return '${d.day} ${m[d.month - 1]} ${d.year}';
    } catch (_) {
      return raw;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            Expanded(child: _buildBody()),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.surfaceColor,
        border: Border(bottom: BorderSide(color: AppColors.borderColor)),
      ),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Get.back(),
            icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
            color: AppColors.textColor,
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Charges Breakdown',
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textColor,
                  ),
                ),
                Text(
                  'Loan #${widget.loanId.length > 8 ? widget.loanId.substring(widget.loanId.length - 8) : widget.loanId}',
                  style: GoogleFonts.poppins(fontSize: 12, color: AppColors.subtextColor),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: _load,
            icon: const Icon(Icons.refresh_rounded, size: 22),
            color: AppColors.primaryColor,
            tooltip: 'Refresh',
          ),
        ],
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) return _buildLoader();
    if (_error.isNotEmpty) return _buildError();
    if (_data == null) return _buildError();
    return _buildContent();
  }

  Widget _buildLoader() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(color: AppColors.primaryColor, strokeWidth: 2.5),
          const SizedBox(height: 20),
          Text(
            'Calculating charges…',
            style: GoogleFonts.poppins(fontSize: 14, color: AppColors.subtextColor),
          ),
        ],
      ),
    );
  }

  Widget _buildError() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: RealTimeColors.error.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.error_outline_rounded, size: 44, color: RealTimeColors.error),
            ),
            const SizedBox(height: 20),
            Text(
              _error.isNotEmpty ? _error : 'No data available',
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(fontSize: 15, color: AppColors.textColor),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _load,
              icon: const Icon(Icons.refresh_rounded, size: 18),
              label: Text('Retry', style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 28),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent() {
    final totalDue = _d('total_due');
    final principal = _d('principal');
    final interest = _d('interest_accrued');
    final storage = _d('storage_charge');
    final penalty = _d('penalty');
    final isOverdue = _b('is_overdue');
    final inGrace = _b('in_grace');
    final penaltyApplied = _b('penalty_applied');
    final overdueDays = _i('overdue_days');
    final graceDays = _i('grace_days', 7);

    Color statusColor = RealTimeColors.success;
    String statusLabel = 'Active';
    IconData statusIcon = Icons.check_circle_rounded;
    if (isOverdue && inGrace) {
      statusColor = RealTimeColors.warning;
      statusLabel = 'Grace Period';
      statusIcon = Icons.access_time_rounded;
    } else if (isOverdue) {
      statusColor = RealTimeColors.error;
      statusLabel = 'Overdue';
      statusIcon = Icons.warning_amber_rounded;
    }

    return Stack(
      children: [
        SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // ── Hero total due card ──────────────────────────────────────
              _buildHeroCard(totalDue, statusColor, statusLabel, statusIcon,
                      isOverdue, inGrace, overdueDays, graceDays)
                  .animate()
                  .fadeIn(duration: 350.ms)
                  .slideY(begin: 0.05, end: 0),

              const SizedBox(height: 20),

              // ── Breakdown bars ───────────────────────────────────────────
              _buildBreakdownCard(principal, interest, storage, penalty, totalDue)
                  .animate()
                  .fadeIn(delay: 80.ms, duration: 350.ms)
                  .slideY(begin: 0.05, end: 0),

              const SizedBox(height: 20),

              // ── Charge detail rows ───────────────────────────────────────
              _buildDetailCard(
                title: 'Loan Details',
                icon: Icons.account_balance_rounded,
                iconColor: AppColors.primaryColor,
                rows: [
                  _detailRow(Icons.payments_rounded, 'Principal',
                      _fmt(principal), AppColors.primaryColor),
                  _detailRow(Icons.percent_rounded, 'Interest Rate',
                      '${_d('interest_rate').toStringAsFixed(1)}% p.a.', AppColors.primaryColor),
                  _detailRow(Icons.trending_up_rounded, 'Interest Accrued',
                      _fmt(interest), RealTimeColors.warning),
                  _detailRow(Icons.inventory_2_rounded, 'Storage Charge',
                      _fmt(storage),
                      AppColors.primaryColor.withValues(alpha: 0.8),
                      sub: '${_d('storage_charge_percent').toStringAsFixed(1)}% of principal'),
                ],
              ).animate().fadeIn(delay: 140.ms, duration: 350.ms).slideY(begin: 0.05, end: 0),

              const SizedBox(height: 16),

              _buildGracePenaltyCard(
                graceDays: graceDays,
                penaltyPercent: _i('penalty_percent', 10),
                penaltyAmount: penalty,
                penaltyApplied: penaltyApplied,
                isOverdue: isOverdue,
                inGrace: inGrace,
                overdueDays: overdueDays,
              )
                  .animate()
                  .fadeIn(delay: 200.ms, duration: 350.ms)
                  .slideY(begin: 0.05, end: 0),

              const SizedBox(height: 16),

              _buildDetailCard(
                title: 'Loan Timeline',
                icon: Icons.calendar_month_rounded,
                iconColor: AppColors.primaryColor,
                rows: [
                  _detailRow(Icons.play_circle_rounded, 'Days Elapsed',
                      '${_i('days_elapsed')} days', AppColors.primaryColor),
                  _detailRow(Icons.timer_rounded, 'Total Loan Days',
                      '${_i('total_loan_days')} days', AppColors.subtextColor),
                  _detailRow(Icons.event_rounded, 'Due Date',
                      _fmtDate(_data!['due_date']?.toString()),
                      isOverdue ? RealTimeColors.error : AppColors.textColor),
                  if (isOverdue)
                    _detailRow(Icons.schedule_rounded, 'Days Overdue',
                        '$overdueDays days', RealTimeColors.error),
                ],
              )
                  .animate()
                  .fadeIn(delay: 260.ms, duration: 350.ms)
                  .slideY(begin: 0.05, end: 0),

              const SizedBox(height: 16),

              // ── Calculation summary ──────────────────────────────────────
              _buildCalcSummary(principal, interest, storage, penalty, totalDue)
                  .animate()
                  .fadeIn(delay: 320.ms, duration: 350.ms)
                  .slideY(begin: 0.05, end: 0),
            ],
          ),
        ),

        // ── Bottom Pay button ────────────────────────────────────────────
        if (totalDue > 0)
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
              decoration: BoxDecoration(
                color: AppColors.surfaceColor,
                border: Border(top: BorderSide(color: AppColors.borderColor)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.07),
                    blurRadius: 12,
                    offset: const Offset(0, -4),
                  ),
                ],
              ),
              child: ElevatedButton.icon(
                onPressed: () => Get.toNamed(
                  RoutesHelper.CreatePaymentScreen,
                  arguments: {
                    'loanId': widget.loanId,
                    'amount': totalDue,
                    'charges': _data,
                  },
                ),
                icon: const Icon(Icons.payment_rounded, size: 20),
                label: Text(
                  'Make Payment · ${_fmt(totalDue)}',
                  style: GoogleFonts.poppins(fontSize: 15, fontWeight: FontWeight.w700),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  elevation: 2,
                ),
              ),
            ),
          ),
      ],
    );
  }

  // ── Hero card ──────────────────────────────────────────────────────────────
  Widget _buildHeroCard(
    double totalDue,
    Color statusColor,
    String statusLabel,
    IconData statusIcon,
    bool isOverdue,
    bool inGrace,
    int overdueDays,
    int graceDays,
  ) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.primaryColor, AppColors.primaryColor.withValues(alpha: 0.75)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryColor.withValues(alpha: 0.35),
            blurRadius: 24,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Total Amount Due',
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  color: Colors.white.withValues(alpha: 0.85),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: statusColor.withValues(alpha: 0.5)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(statusIcon, size: 12, color: Colors.white),
                    const SizedBox(width: 4),
                    Text(
                      statusLabel,
                      style: GoogleFonts.poppins(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            _fmt(totalDue),
            style: GoogleFonts.poppins(
              fontSize: 40,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          )
              .animate()
              .fadeIn(duration: 400.ms)
              .scaleXY(begin: 0.85, end: 1.0, duration: 400.ms),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.shield_rounded, size: 13, color: Colors.white.withValues(alpha: 0.75)),
              const SizedBox(width: 5),
              Text(
                isOverdue && inGrace
                    ? '$overdueDays days overdue · $graceDays-day grace period active'
                    : isOverdue
                        ? '$overdueDays days overdue'
                        : 'Loan is current · no penalty',
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  color: Colors.white.withValues(alpha: 0.8),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ── Stacked bar breakdown ──────────────────────────────────────────────────
  Widget _buildBreakdownCard(
    double principal,
    double interest,
    double storage,
    double penalty,
    double total,
  ) {
    final items = [
      ('Principal', principal, AppColors.primaryColor),
      ('Interest', interest, RealTimeColors.warning),
      ('Storage', storage, AppColors.primaryColor.withValues(alpha: 0.55)),
      ('Penalty', penalty, RealTimeColors.error),
    ].where((e) => e.$2 > 0).toList();

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surfaceColor,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.borderColor),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.pie_chart_rounded, size: 18, color: AppColors.primaryColor),
              const SizedBox(width: 8),
              Text(
                'Composition',
                style: GoogleFonts.poppins(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Stacked bar
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: SizedBox(
              height: 14,
              child: Row(
                children: items.map((item) {
                  final pct = total > 0 ? item.$2 / total : 0.0;
                  return Flexible(
                    flex: (pct * 1000).toInt(),
                    child: Container(color: item.$3),
                  );
                }).toList(),
              ),
            ),
          ),
          const SizedBox(height: 16),
          // Legend
          Wrap(
            spacing: 16,
            runSpacing: 8,
            children: items.map((item) {
              final pct = total > 0 ? (item.$2 / total * 100) : 0.0;
              return Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(color: item.$3, shape: BoxShape.circle),
                  ),
                  const SizedBox(width: 5),
                  Text(
                    '${item.$1} ${pct.toStringAsFixed(0)}%',
                    style: GoogleFonts.poppins(fontSize: 12, color: AppColors.subtextColor),
                  ),
                ],
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  // ── Detail card ────────────────────────────────────────────────────────────
  Widget _buildDetailCard({
    required String title,
    required IconData icon,
    required Color iconColor,
    required List<Widget> rows,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surfaceColor,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.borderColor),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
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
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: iconColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, size: 18, color: iconColor),
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
          const SizedBox(height: 16),
          ...rows,
        ],
      ),
    );
  }

  // ── Grace period & penalty card ────────────────────────────────────────────
  Widget _buildGracePenaltyCard({
    required int graceDays,
    required int penaltyPercent,
    required double penaltyAmount,
    required bool penaltyApplied,
    required bool isOverdue,
    required bool inGrace,
    required int overdueDays,
  }) {
    // Pick tone based on state
    final Color accent;
    final IconData headerIcon;
    final String headerTitle;
    final String noticeText;

    if (penaltyApplied || inGrace) {
      accent      = RealTimeColors.error;
      headerIcon  = Icons.gavel_rounded;
      headerTitle = inGrace ? 'Grace Period Active — Act Now' : 'Penalty Applied';
      final remaining = (graceDays - overdueDays).clamp(0, graceDays);
      noticeText  = 'A $penaltyPercent% late penalty has been added to your balance. '
          'You have $remaining day${remaining == 1 ? '' : 's'} remaining in the $graceDays-day grace period. '
          'If not paid in full, your asset will be automatically listed for auction.';
    } else if (isOverdue) {
      accent      = RealTimeColors.error;
      headerIcon  = Icons.warning_amber_rounded;
      headerTitle = 'Overdue — Penalty Due';
      noticeText  = 'This loan is overdue and past the $graceDays-day grace period. '
          'A $penaltyPercent% penalty applies to the outstanding balance.';
    } else {
      accent      = RealTimeColors.warning;
      headerIcon  = Icons.info_outline_rounded;
      headerTitle = 'Grace Period & Penalty Policy';
      noticeText  = 'If not repaid by the due date, a $graceDays-day grace period begins and '
          'a $penaltyPercent% penalty is immediately added to the outstanding balance. '
          'After those $graceDays days the collateral asset is automatically listed for auction.';
    }

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
          // Header
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

          // Stat rows
          _graceStat(Icons.hourglass_bottom_rounded, 'Grace Period',
              '$graceDays days after due date', accent),
          _graceStat(Icons.percent_rounded, 'Penalty Rate',
              '$penaltyPercent% of outstanding balance', accent),
          if (penaltyApplied || penaltyAmount > 0)
            _graceStat(
              Icons.monetization_on_rounded,
              'Penalty Amount',
              _fmt(penaltyAmount),
              penaltyAmount > 0 ? RealTimeColors.error : AppColors.subtextColor,
              bold: true,
            ),
          _graceStat(
            Icons.check_circle_outline_rounded,
            'Penalty Status',
            penaltyApplied
                ? 'Applied to balance'
                : (isOverdue && !inGrace)
                    ? 'Due — not yet processed'
                    : 'Not yet applied',
            penaltyApplied
                ? RealTimeColors.error
                : (isOverdue && !inGrace)
                    ? RealTimeColors.warning
                    : RealTimeColors.success,
          ),
        ],
      ),
    );
  }

  Widget _graceStat(IconData icon, String label, String value, Color color,
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

  Widget _detailRow(
    IconData icon,
    String label,
    String value,
    Color color, {
    String? sub,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: 18, color: color),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: GoogleFonts.poppins(fontSize: 13, color: AppColors.subtextColor),
                ),
                if (sub != null)
                  Text(
                    sub,
                    style: GoogleFonts.poppins(fontSize: 11, color: AppColors.subtextColor),
                  ),
              ],
            ),
          ),
          Text(
            value,
            style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  // ── Calc summary ───────────────────────────────────────────────────────────
  Widget _buildCalcSummary(
    double principal,
    double interest,
    double storage,
    double penalty,
    double totalDue,
  ) {
    final rows = [
      ('Principal', principal),
      ('Interest Accrued', interest),
      ('Storage Charge', storage),
      if (penalty > 0) ('Penalty', penalty),
    ];

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.primaryColor.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.primaryColor.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.calculate_rounded, size: 18, color: AppColors.primaryColor),
              const SizedBox(width: 8),
              Text(
                'Summary',
                style: GoogleFonts.poppins(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          ...rows.map(
            (r) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(r.$1, style: GoogleFonts.poppins(fontSize: 13, color: AppColors.subtextColor)),
                  Text(_fmt(r.$2),
                      style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textColor)),
                ],
              ),
            ),
          ),
          const Divider(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Total Due',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textColor,
                ),
              ),
              Text(
                _fmt(totalDue),
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primaryColor,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
