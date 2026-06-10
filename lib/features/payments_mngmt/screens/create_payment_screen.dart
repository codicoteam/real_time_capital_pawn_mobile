import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:real_time_pawn/config/routers/router.dart';
import 'package:real_time_pawn/core/utils/pallete.dart';
import 'package:real_time_pawn/features/loan_mngmt/controllers/loan_mngmt_controller.dart';
import 'package:real_time_pawn/features/payments_mngmt/controllers/payments_mngmt_controller.dart';
import 'package:url_launcher/url_launcher.dart';

enum _PaymentState { loadingCharges, selecting, polling, success, failed }

class CreatePaymentScreen extends StatefulWidget {
  final String loanId;
  final double? initialAmount;
  final Map<String, dynamic>? chargesData;

  const CreatePaymentScreen({
    super.key,
    required this.loanId,
    this.initialAmount,
    this.chargesData,
  });

  @override
  State<CreatePaymentScreen> createState() => _CreatePaymentScreenState();
}

class _CreatePaymentScreenState extends State<CreatePaymentScreen> {
  final PaymentController _controller = Get.put(PaymentController());
  final LoanController _loanController = Get.find<LoanController>();
  final TextEditingController _phoneController = TextEditingController();

  String _selectedProvider = 'ecocash';
  _PaymentState _state = _PaymentState.selecting;

  // Loaded charges
  double _totalDue = 0.0;
  Map<String, dynamic>? _chargesData;

  // Polling
  Timer? _pollTimer;
  int _pollsRemaining = 12; // 12 × 5 s = 60 s
  String _pollStatus = 'Checking payment status…';
  String? _createdPaymentId;
  String? _redirectUrl;

  double _charge(String key) =>
      (_chargesData?[key] as num?)?.toDouble() ?? 0.0;

  bool _isValidZimbabwePhone(String phone) {
    final cleaned = phone.replaceAll(RegExp(r'[^\d]'), '');
    if (cleaned.length != 9 || !cleaned.startsWith('7')) return false;
    final prefix = cleaned.substring(0, 2);
    return ['77', '78', '79', '71', '73'].contains(prefix);
  }

  // ── Lifecycle ────────────────────────────────────────────────────────────────
  @override
  void initState() {
    super.initState();
    _initAmountAndCharges();
  }

  @override
  void dispose() {
    _pollTimer?.cancel();
    _phoneController.dispose();
    super.dispose();
  }

  /// Resolve the amount to pay. If it was passed in already, use it.
  /// Otherwise fetch from the charges API so the screen always shows a valid
  /// amount and the Pay button is never permanently disabled.
  Future<void> _initAmountAndCharges() async {
    // Prefer constructor values
    if (widget.initialAmount != null && widget.initialAmount! > 0) {
      setState(() {
        _totalDue = widget.initialAmount!;
        _chargesData = widget.chargesData;
      });
      return;
    }

    // Check chargesData passed in
    final cdTotal = (widget.chargesData?['total_due'] as num?)?.toDouble();
    if (cdTotal != null && cdTotal > 0) {
      setState(() {
        _totalDue = cdTotal;
        _chargesData = widget.chargesData;
      });
      return;
    }

    // Nothing passed — fetch from API
    setState(() => _state = _PaymentState.loadingCharges);
    try {
      final charges = await _loanController.calculateLoanCharges(widget.loanId);
      final due = (charges?['total_due'] as num?)?.toDouble() ??
          (charges?['principal'] as num?)?.toDouble() ??
          0.0;
      if (mounted) {
        setState(() {
          _totalDue = due;
          _chargesData = charges;
          _state = _PaymentState.selecting;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _state = _PaymentState.selecting);
    }
  }

  // ── Submit ───────────────────────────────────────────────────────────────────
  Future<void> _submit() async {
    if (_totalDue <= 0) {
      Get.snackbar('Error', 'No amount to pay',
          backgroundColor: RealTimeColors.error, colorText: Colors.white);
      return;
    }

    String? formattedPhone;
    if (_selectedProvider == 'ecocash') {
      final cleaned = _phoneController.text.replaceAll(RegExp(r'[^\d]'), '');
      if (!_isValidZimbabwePhone(cleaned)) {
        Get.snackbar(
          'Invalid Number',
          'Enter a valid 9-digit Zimbabwe number starting with 7',
          backgroundColor: RealTimeColors.error,
          colorText: Colors.white,
        );
        return;
      }
      formattedPhone = '263$cleaned';
    }

    final principal = _charge('principal');
    final interest = _charge('interest_accrued');
    final storage = _charge('storage_charge');
    final penalty = _charge('penalty');

    // If no breakdown, allocate proportionally
    final totalBreakdown = principal + interest + storage + penalty;
    final double effectivePrincipal =
        totalBreakdown > 0 ? principal : _totalDue * 0.70;
    final double effectiveInterest =
        totalBreakdown > 0 ? interest : _totalDue * 0.20;
    final double effectiveStorage =
        totalBreakdown > 0 ? storage : _totalDue * 0.05;
    final double effectivePenalty =
        totalBreakdown > 0 ? penalty : _totalDue * 0.05;

    final result = await _controller.createPayment(
      loanId: widget.loanId,
      loanTermId: widget.loanId,
      amount: _totalDue,
      provider: _selectedProvider,
      method: _selectedProvider, // 'ecocash' or 'paynow' — matches API enum
      interestComponent: effectiveInterest,
      principalComponent: effectivePrincipal,
      storageComponent: effectiveStorage,
      penaltyComponent: effectivePenalty,
      phoneNumber: formattedPhone,
    );

    if (result == null) return; // controller showed snackbar

    // Extract payment ID and redirect URL from various response shapes
    final paymentData = result['payment'] ?? result;
    _createdPaymentId = paymentData['_id']?.toString() ?? result['_id']?.toString();
    _redirectUrl = result['redirect_url'] as String? ??
        result['redirectUrl'] as String? ??
        (paymentData['meta'] as Map?)?['redirect_url'] as String?;

    setState(() => _state = _PaymentState.polling);
    _startPolling();

    // Open PayNow in-app browser immediately
    if (_selectedProvider == 'paynow' &&
        _redirectUrl != null &&
        _redirectUrl!.isNotEmpty) {
      _openInAppBrowser(_redirectUrl!);
    }
  }

  // ── Polling ──────────────────────────────────────────────────────────────────
  void _startPolling() {
    _pollsRemaining = 12;
    _pollTimer?.cancel();
    _pollTimer = Timer.periodic(const Duration(seconds: 5), (_) async {
      if (_createdPaymentId == null) return;

      final statusResult =
          await _controller.checkPaymentStatus(_createdPaymentId!);

      if (!mounted) return;
      _pollsRemaining--;

      final paymentStatus = (statusResult?['payment']?['payment_status'] ??
              statusResult?['payment_status'])
          ?.toString()
          .toLowerCase();

      if (paymentStatus == 'paid' ||
          paymentStatus == 'completed' ||
          paymentStatus == 'successful' ||
          paymentStatus == 'success') {
        _pollTimer?.cancel();
        setState(() {
          _state = _PaymentState.success;
          _pollStatus = 'Payment confirmed!';
        });
        return;
      }

      if (paymentStatus == 'failed' ||
          paymentStatus == 'cancelled' ||
          paymentStatus == 'declined') {
        _pollTimer?.cancel();
        setState(() {
          _state = _PaymentState.failed;
          _pollStatus = 'Payment $paymentStatus';
        });
        return;
      }

      if (_pollsRemaining <= 0) {
        _pollTimer?.cancel();
        setState(() => _pollStatus = 'Still pending — check payment history');
        return;
      }

      setState(
          () => _pollStatus = 'Checking… (${_pollsRemaining * 5}s remaining)');
    });
  }

  Future<void> _openInAppBrowser(String url) async {
    final uri = Uri.parse(url);
    try {
      final launched = await launchUrl(uri, mode: LaunchMode.inAppBrowserView);
      if (!launched) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      }
    } catch (_) {
      try {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } catch (e) {
        Get.snackbar('Error', 'Could not open payment page',
            backgroundColor: RealTimeColors.error, colorText: Colors.white);
      }
    }
  }

  // ── Build ────────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    final args = Get.arguments as Map? ?? {};
    final loanNo = args['loanNo']?.toString();

    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildHeader(loanNo != null ? 'Loan $loanNo' : null),
            Expanded(child: _buildBody()),
            if (_state == _PaymentState.selecting) _buildPayButton(),
          ],
        ),
      ),
    );
  }

  // ── Header ───────────────────────────────────────────────────────────────────
  Widget _buildHeader(String? subtitle) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
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
                  'Make Payment',
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textColor,
                  ),
                ),
                if (subtitle != null)
                  Text(
                    subtitle,
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: AppColors.subtextColor,
                    ),
                  ),
              ],
            ),
          ),
          // Secure badge
          Container(
            margin: const EdgeInsets.only(right: 8),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: RealTimeColors.success.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: RealTimeColors.success.withValues(alpha: 0.3)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.lock_rounded, size: 12, color: RealTimeColors.success),
                const SizedBox(width: 4),
                Text(
                  'Secure',
                  style: GoogleFonts.poppins(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: RealTimeColors.success,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Body router ──────────────────────────────────────────────────────────────
  Widget _buildBody() {
    switch (_state) {
      case _PaymentState.loadingCharges:
        return _buildLoadingChargesView();
      case _PaymentState.selecting:
        return _buildSelectingView();
      case _PaymentState.polling:
        return _buildPollingView();
      case _PaymentState.success:
        return _buildResultView(success: true);
      case _PaymentState.failed:
        return _buildResultView(success: false);
    }
  }

  // ── Loading charges ──────────────────────────────────────────────────────────
  Widget _buildLoadingChargesView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(color: AppColors.primaryColor),
          const SizedBox(height: 20),
          Text(
            'Calculating your balance…',
            style: GoogleFonts.poppins(
              fontSize: 15,
              color: AppColors.subtextColor,
            ),
          ),
        ],
      ),
    );
  }

  // ── Selecting view ───────────────────────────────────────────────────────────
  Widget _buildSelectingView() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildAmountCard(),
          const SizedBox(height: 20),

          if (_chargesData != null) ...[
            _buildChargesBreakdown(),
            const SizedBox(height: 20),
          ],

          _sectionLabel('Payment Method'),
          const SizedBox(height: 10),
          _buildMethodSelector(),
          const SizedBox(height: 20),

          if (_selectedProvider == 'ecocash') ...[
            _sectionLabel('Mobile Number (EcoCash)'),
            const SizedBox(height: 10),
            _buildPhoneInput(),
            const SizedBox(height: 20),
          ],

          const SizedBox(height: 8),
        ],
      ),
    );
  }

  Widget _buildAmountCard() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primaryColor,
            AppColors.primaryColor.withValues(alpha: 0.78),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryColor.withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.account_balance_wallet_rounded,
                color: Colors.white, size: 28),
          ),
          const SizedBox(height: 14),
          Text(
            'Total Amount Due',
            style: GoogleFonts.poppins(
              fontSize: 13,
              color: Colors.white.withValues(alpha: 0.85),
            ),
          ),
          const SizedBox(height: 6),
          _totalDue > 0
              ? Text(
                  'USD \$${_totalDue.toStringAsFixed(2)}',
                  style: GoogleFonts.poppins(
                    fontSize: 36,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                )
              : Text(
                  'Loading…',
                  style: GoogleFonts.poppins(
                    fontSize: 28,
                    fontWeight: FontWeight.w600,
                    color: Colors.white.withValues(alpha: 0.7),
                  ),
                ),
        ],
      ),
    );
  }

  Widget _buildChargesBreakdown() {
    final rows = [
      ('Principal', _charge('principal'), AppColors.primaryColor),
      ('Interest', _charge('interest_accrued'), RealTimeColors.warning),
      ('Storage', _charge('storage_charge'),
          AppColors.primaryColor.withValues(alpha: 0.7)),
      ('Penalty', _charge('penalty'), RealTimeColors.error),
    ];

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderColor),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.receipt_long_rounded,
                  size: 16, color: AppColors.primaryColor),
              const SizedBox(width: 8),
              Text(
                'Breakdown',
                style: GoogleFonts.poppins(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          ...rows.where((r) => r.$2 > 0).map(
                (r) => Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Row(
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        margin: const EdgeInsets.only(right: 10),
                        decoration: BoxDecoration(
                          color: r.$3,
                          shape: BoxShape.circle,
                        ),
                      ),
                      Expanded(
                        child: Text(
                          r.$1,
                          style: GoogleFonts.poppins(
                            fontSize: 13,
                            color: AppColors.textColor,
                          ),
                        ),
                      ),
                      Text(
                        'USD \$${r.$2.toStringAsFixed(2)}',
                        style: GoogleFonts.poppins(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: r.$3,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          const Divider(height: 16),
          Row(
            children: [
              const Expanded(
                child: Text(
                  'Total',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              Text(
                'USD \$${_totalDue.toStringAsFixed(2)}',
                style: GoogleFonts.poppins(
                  fontSize: 15,
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

  Widget _buildMethodSelector() {
    return Row(
      children: [
        _methodCard('ecocash', 'EcoCash', Icons.phone_android_rounded,
            'Mobile money push'),
        const SizedBox(width: 12),
        _methodCard('paynow', 'PayNow', Icons.open_in_browser_rounded,
            'Opens in browser'),
      ],
    );
  }

  Widget _methodCard(
      String id, String label, IconData icon, String subtitle) {
    final selected = _selectedProvider == id;
    final color = id == 'ecocash' ? RealTimeColors.success : AppColors.primaryColor;

    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() {
          _selectedProvider = id;
          _phoneController.clear();
        }),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 12),
          decoration: BoxDecoration(
            color: selected ? color.withValues(alpha: 0.08) : AppColors.surfaceColor,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: selected ? color : AppColors.borderColor,
              width: selected ? 2.0 : 1.0,
            ),
            boxShadow: selected
                ? [BoxShadow(color: color.withValues(alpha: 0.15), blurRadius: 10)]
                : null,
          ),
          child: Column(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: selected ? color.withValues(alpha: 0.15) : AppColors.backgroundColor,
                  shape: BoxShape.circle,
                ),
                child: Icon(icon,
                    color: selected ? color : AppColors.subtextColor, size: 24),
              ),
              const SizedBox(height: 8),
              Text(
                label,
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: selected ? color : AppColors.textColor,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  fontSize: 10,
                  color: AppColors.subtextColor,
                ),
              ),
              if (selected) ...[
                const SizedBox(height: 6),
                Container(
                  width: 18,
                  height: 18,
                  decoration: BoxDecoration(color: color, shape: BoxShape.circle),
                  child: const Icon(Icons.check_rounded, color: Colors.white, size: 12),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPhoneInput() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceColor,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.borderColor),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextField(
            controller: _phoneController,
            keyboardType: TextInputType.number,
            maxLength: 9,
            buildCounter: (_, {required currentLength, required isFocused, maxLength}) =>
                null,
            onChanged: (_) => setState(() {}),
            decoration: InputDecoration(
              labelText: 'Mobile Number',
              hintText: '780197542',
              prefixText: '+263 ',
              prefixStyle: GoogleFonts.poppins(
                fontWeight: FontWeight.w700,
                color: AppColors.textColor,
              ),
              prefixIcon: Icon(Icons.phone_rounded,
                  color: RealTimeColors.success),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: AppColors.borderColor),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: RealTimeColors.success, width: 2),
              ),
              suffixIcon: _phoneController.text.isNotEmpty
                  ? Icon(
                      _isValidZimbabwePhone(_phoneController.text)
                          ? Icons.check_circle_rounded
                          : Icons.error_rounded,
                      color: _isValidZimbabwePhone(_phoneController.text)
                          ? RealTimeColors.success
                          : RealTimeColors.error,
                    )
                  : null,
            ),
            style: GoogleFonts.poppins(fontSize: 16, color: AppColors.textColor),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(Icons.info_outline_rounded,
                  size: 13, color: AppColors.subtextColor),
              const SizedBox(width: 5),
              Text(
                '9-digit number starting with 7 (e.g. 780197542)',
                style: GoogleFonts.poppins(
                    fontSize: 11, color: AppColors.subtextColor),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _sectionLabel(String label) {
    return Text(
      label,
      style: GoogleFonts.poppins(
        fontSize: 15,
        fontWeight: FontWeight.w700,
        color: AppColors.textColor,
      ),
    );
  }

  // ── Pay button ────────────────────────────────────────────────────────────────
  Widget _buildPayButton() {
    final phoneOk = _selectedProvider != 'ecocash' ||
        _isValidZimbabwePhone(_phoneController.text);
    final canPay = _totalDue > 0 && phoneOk;

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
      decoration: BoxDecoration(
        color: AppColors.surfaceColor,
        border: Border(top: BorderSide(color: AppColors.borderColor)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 10,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Obx(() {
        final loading = _controller.isProcessingPayment.value;
        final enabled = canPay && !loading;

        return ElevatedButton(
          onPressed: enabled ? _submit : null,
          style: ElevatedButton.styleFrom(
            foregroundColor: Colors.white,
            backgroundColor: AppColors.primaryColor,
            disabledBackgroundColor: AppColors.primaryColor.withValues(alpha: 0.45),
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            elevation: enabled ? 2 : 0,
          ),
          child: loading
              ? const SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(
                      color: Colors.white, strokeWidth: 2.5),
                )
              : Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      _selectedProvider == 'ecocash'
                          ? Icons.phone_android_rounded
                          : Icons.open_in_browser_rounded,
                      size: 20,
                    ),
                    const SizedBox(width: 10),
                    Text(
                      _totalDue > 0
                          ? 'Pay USD \$${_totalDue.toStringAsFixed(2)} via '
                              '${_selectedProvider == 'ecocash' ? 'EcoCash' : 'PayNow'}'
                          : 'Loading…',
                      style: GoogleFonts.poppins(
                          fontSize: 15, fontWeight: FontWeight.w700),
                    ),
                  ],
                ),
        );
      }),
    );
  }

  // ── Polling view ──────────────────────────────────────────────────────────────
  Widget _buildPollingView() {
    final isEcoCash = _selectedProvider == 'ecocash';

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildAmountCard(),
          const SizedBox(height: 24),

          if (!isEcoCash && _redirectUrl != null && _redirectUrl!.isNotEmpty)
            _buildPayNowBrowserCard()
          else if (isEcoCash)
            _buildEcoCashInstructions(),

          const SizedBox(height: 20),
          _buildPollingCard(),
          const SizedBox(height: 16),

          OutlinedButton(
            onPressed: () => Get.toNamed(
              RoutesHelper.CustomerPaymentsScreen,
              arguments: {'loanId': widget.loanId, 'isLoanPayments': true},
            ),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
            child: Text(
              'View Payment History',
              style: GoogleFonts.poppins(fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPayNowBrowserCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.primaryColor.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.primaryColor, width: 2),
      ),
      child: Column(
        children: [
          const Icon(Icons.open_in_browser_rounded,
              size: 56, color: AppColors.primaryColor),
          const SizedBox(height: 12),
          Text(
            'Complete Your Payment',
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: AppColors.textColor,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'The PayNow payment page has been opened in the browser. Complete the payment there, then return to check status.',
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
                fontSize: 13, color: AppColors.subtextColor),
          ),
          const SizedBox(height: 20),
          ElevatedButton.icon(
            onPressed: () => _openInAppBrowser(_redirectUrl!),
            icon: const Icon(Icons.launch_rounded, size: 18),
            label: Text(
              'Open PayNow Page',
              style: GoogleFonts.poppins(
                  fontSize: 14, fontWeight: FontWeight.w700),
            ),
            style: ElevatedButton.styleFrom(
              foregroundColor: Colors.white,
              backgroundColor: AppColors.primaryColor,
              padding:
                  const EdgeInsets.symmetric(vertical: 14, horizontal: 28),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEcoCashInstructions() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: RealTimeColors.success.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: RealTimeColors.success, width: 2),
      ),
      child: Column(
        children: [
          const Icon(Icons.phone_android_rounded,
              size: 52, color: RealTimeColors.success),
          const SizedBox(height: 12),
          Text(
            'Check Your Phone',
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: AppColors.textColor,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'An EcoCash payment request has been sent to:\n+263${_phoneController.text}\n\nApprove it on your phone to complete the payment.',
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
                fontSize: 13, color: AppColors.subtextColor),
          ),
        ],
      ),
    );
  }

  Widget _buildPollingCard() {
    final secondsLeft = _pollsRemaining * 5;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceColor,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.borderColor),
      ),
      child: Row(
        children: [
          const SizedBox(
            width: 22,
            height: 22,
            child: CircularProgressIndicator(
                strokeWidth: 2, color: AppColors.primaryColor),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _pollStatus,
                  style: GoogleFonts.poppins(
                      fontSize: 13, color: AppColors.textColor),
                ),
                if (secondsLeft > 0)
                  Text(
                    'Auto-checking every 5s · ${secondsLeft}s remaining',
                    style: GoogleFonts.poppins(
                        fontSize: 11, color: AppColors.subtextColor),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Result view ───────────────────────────────────────────────────────────────
  Widget _buildResultView({required bool success}) {
    final color = success ? RealTimeColors.success : RealTimeColors.error;
    final icon = success ? Icons.check_circle_rounded : Icons.cancel_rounded;
    final title = success ? 'Payment Successful!' : 'Payment Failed';
    final message = success
        ? 'Your loan payment of USD \$${_totalDue.toStringAsFixed(2)} has been confirmed.'
        : 'The payment could not be completed. Please try again or contact support.';

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 88, color: color),
            const SizedBox(height: 20),
            Text(
              title,
              style: GoogleFonts.poppins(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: AppColors.textColor,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              message,
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                  fontSize: 14, color: AppColors.subtextColor),
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  if (success) {
                    Get.back();
                  } else {
                    setState(() {
                      _state = _PaymentState.selecting;
                      _createdPaymentId = null;
                      _redirectUrl = null;
                    });
                  }
                },
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.white,
                  backgroundColor: color,
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                child: Text(
                  success ? 'Done' : 'Try Again',
                  style: GoogleFonts.poppins(
                      fontSize: 15, fontWeight: FontWeight.w700),
                ),
              ),
            ),
            if (success) ...[
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () => Get.toNamed(
                    RoutesHelper.CustomerPaymentsScreen,
                    arguments: {
                      'loanId': widget.loanId,
                      'isLoanPayments': true,
                    },
                  ),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  child: Text(
                    'View Payment History',
                    style: GoogleFonts.poppins(fontSize: 14),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
