// features/payments_mngmt/screens/payment_list_screen.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:real_time_pawn/config/routers/router.dart';
import 'package:real_time_pawn/core/utils/pallete.dart';
import 'package:real_time_pawn/features/payments_mngmt/controllers/payments_mngmt_controller.dart';
import 'package:real_time_pawn/models/payment_mngmt_model.dart';

class PaymentListScreen extends StatefulWidget {
  final String? loanId;
  final bool isLoanPayments;

  const PaymentListScreen({
    super.key,
    this.loanId,
    this.isLoanPayments = false,
  });

  @override
  State<PaymentListScreen> createState() => _PaymentListScreenState();
}

class _PaymentListScreenState extends State<PaymentListScreen> {
  final PaymentController _controller = Get.put(PaymentController());
  final ScrollController _scrollController = ScrollController();
  bool _isRefreshing = false;

  @override
  void initState() {
    super.initState();
    _loadPayments();
    _scrollController.addListener(_scrollListener);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadPayments() async {
    if (widget.isLoanPayments && widget.loanId != null) {
      await _controller.fetchPaymentsByLoan(
        loanId: widget.loanId!,
        refresh: true,
      );
    } else {
      await _controller.fetchPaymentsByCustomer(refresh: true);
    }
  }

  void _scrollListener() {
    if (_scrollController.position.pixels ==
        _scrollController.position.maxScrollExtent) {
      if (!_controller.isLoadingMore.value && _controller.hasNextPage.value) {
        _controller.loadMorePayments(
          isCustomerPayments: !widget.isLoanPayments,
          loanId: widget.loanId,
        );
      }
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

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'paid':
      case 'completed':
      case 'successful':
        return RealTimeColors.success;
      case 'pending':
      case 'processing':
        return RealTimeColors.warning;
      case 'failed':
      case 'cancelled':
      case 'declined':
        return RealTimeColors.error;
      default:
        return AppColors.subtextColor;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // SIMPLE HEADER
            _buildHeader(),

            // CONTENT AREA
            Expanded(
              child: Obx(() {
                // LOADING STATE
                if (_controller.isLoading.value &&
                    _controller.payments.isEmpty) {
                  return const Center(child: CircularProgressIndicator());
                }

                // ERROR STATE
                if (_controller.errorMessage.value.isNotEmpty) {
                  return _buildErrorState();
                }

                // EMPTY STATE
                if (_controller.payments.isEmpty) {
                  return _buildEmptyState();
                }

                // PAYMENTS LIST
                return _buildPaymentsList();
              }),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    final isSmall = MediaQuery.of(context).size.width < 360;

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isSmall ? 12 : 16,
        vertical: isSmall ? 8 : 12,
      ),
      decoration: BoxDecoration(
        color: AppColors.surfaceColor,
        border: Border(bottom: BorderSide(color: AppColors.borderColor)),
      ),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Get.back(),
            icon: const Icon(Icons.arrow_back),
            color: AppColors.textColor,
            iconSize: isSmall ? 20 : 24,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  widget.isLoanPayments ? 'Loan Payments' : 'My Payments',
                  style: GoogleFonts.poppins(
                    fontSize: isSmall ? 16 : 18,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textColor,
                  ),
                ),
                if (widget.isLoanPayments && widget.loanId != null)
                  Text(
                    'ID: ${widget.loanId!.substring(0, 6)}...',
                    style: GoogleFonts.poppins(
                      fontSize: isSmall ? 10 : 12,
                      color: AppColors.subtextColor,
                    ),
                  ),
              ],
            ),
          ),

          // Show pending count with auto-refresh indicator
          Obx(() {
            if (_controller.pendingPaymentsCount == 0) return const SizedBox();

            return Container(
              margin: const EdgeInsets.only(right: 8),
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: RealTimeColors.warning.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(
                    width: 12,
                    height: 12,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        RealTimeColors.warning,
                      ),
                    ),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '${_controller.pendingPaymentsCount} pending',
                    style: GoogleFonts.poppins(
                      fontSize: 10,
                      color: RealTimeColors.warning,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            );
          }),

          // Simple refresh button (optional, not needed but kept for manual trigger)
          IconButton(
            onPressed: () async {
              setState(() => _isRefreshing = true);
              await _loadPayments();
              setState(() => _isRefreshing = false);
            },
            icon: _isRefreshing
                ? SizedBox(
                    height: isSmall ? 18 : 20,
                    width: isSmall ? 18 : 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: AppColors.primaryColor,
                    ),
                  )
                : const Icon(Icons.refresh_outlined),
            color: AppColors.textColor,
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error_outline, size: 48, color: RealTimeColors.error),
            const SizedBox(height: 16),
            Text(
              _controller.errorMessage.value,
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: AppColors.textColor,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadPayments,
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.white,
                backgroundColor: AppColors.primaryColor,
                minimumSize: const Size(120, 40),
              ),
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.payments_outlined,
              size: 64,
              color: RealTimeColors.grey400,
            ),
            const SizedBox(height: 16),
            Text(
              'No payments found',
              style: GoogleFonts.poppins(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: AppColors.subtextColor,
              ),
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Text(
                widget.isLoanPayments
                    ? 'No payments have been made for this loan yet'
                    : 'You haven\'t made any payments yet',
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  color: AppColors.subtextColor,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 24),
            if (!widget.isLoanPayments)
              ElevatedButton(
                onPressed: () => Get.back(),
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.white,
                  backgroundColor: AppColors.primaryColor,
                  minimumSize: const Size(160, 44),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text('Make a Payment'),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentsList() {
    return Column(
      children: [
        // STATS BAR
        if (!_controller.isLoading.value && _controller.payments.isNotEmpty)
          _buildStatsBar(),

        // LIST VIEW
        Expanded(
          child: RefreshIndicator(
            onRefresh: _loadPayments,
            color: AppColors.primaryColor,
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(16),
              itemCount:
                  _controller.payments.length +
                  (_controller.isLoadingMore.value ? 1 : 0),
              itemBuilder: (context, index) {
                if (index >= _controller.payments.length) {
                  return const Padding(
                    padding: EdgeInsets.all(16),
                    child: Center(child: CircularProgressIndicator()),
                  );
                }
                return _buildPaymentCard(_controller.payments[index]);
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStatsBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.surfaceColor,
        border: Border(bottom: BorderSide(color: AppColors.borderColor)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatItem(
            'Total Paid',
            '\$${_controller.totalPaidAmount.toStringAsFixed(2)}',
            RealTimeColors.success,
          ),
          Container(height: 30, width: 1, color: AppColors.borderColor),
          _buildStatItem(
            'Pending',
            '\$${_controller.totalPendingAmount.toStringAsFixed(2)}',
            RealTimeColors.warning,
          ),
          Container(height: 30, width: 1, color: AppColors.borderColor),
          _buildStatItem(
            'Transactions',
            _controller.payments.length.toString(),
            AppColors.primaryColor,
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value, Color color) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          value,
          style: GoogleFonts.poppins(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: color,
          ),
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
    );
  }

  Widget _buildPaymentCard(PaymentModel payment) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: AppColors.borderColor),
      ),
      color: AppColors.surfaceColor,
      child: InkWell(
        onTap: () {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            Get.toNamed(
              RoutesHelper.PaymentDetailsScreen,
              arguments: {'paymentId': payment.id},
            );
          });
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          payment.reference,
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textColor,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _formatDate(payment.createdAt),
                          style: GoogleFonts.poppins(
                            fontSize: 10,
                            color: AppColors.subtextColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Row(
                    children: [
                      // Show loading indicator for pending payments
                      if (payment.isPending || payment.isProcessing)
                        Container(
                          margin: const EdgeInsets.only(right: 8),
                          child: const SizedBox(
                            width: 12,
                            height: 12,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                        ),

                      // Status chip
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: _getStatusColor(
                            payment.paymentStatus,
                          ).withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          payment.paymentStatus.toUpperCase(),
                          style: GoogleFonts.poppins(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: _getStatusColor(payment.paymentStatus),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 12),
              const Divider(height: 1),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Amount',
                        style: GoogleFonts.poppins(
                          fontSize: 10,
                          color: AppColors.subtextColor,
                        ),
                      ),
                      Text(
                        payment.formattedAmount,
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textColor,
                        ),
                      ),
                    ],
                  ),
                  if (payment.method != null)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Method',
                          style: GoogleFonts.poppins(
                            fontSize: 10,
                            color: AppColors.subtextColor,
                          ),
                        ),
                        Text(
                          payment.method!.toUpperCase(),
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textColor,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                ],
              ),
              if (payment.notes != null && payment.notes!.isNotEmpty) ...[
                const SizedBox(height: 8),
                Text(
                  'Notes: ${payment.notes!}',
                  style: GoogleFonts.poppins(
                    fontSize: 11,
                    color: AppColors.subtextColor,
                    fontStyle: FontStyle.italic,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
