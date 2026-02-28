// features/payments_mngmt/screens/customer_payments_screen.dart - CORRECTED VERSION

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:real_time_pawn/config/routers/router.dart';
import 'package:real_time_pawn/core/utils/pallete.dart';
import 'package:real_time_pawn/features/payments_mngmt/controllers/payments_mngmt_controller.dart';
import 'package:real_time_pawn/models/payment_mngmt_model.dart';

class CustomerPaymentsScreen extends StatefulWidget {
  const CustomerPaymentsScreen({super.key});

  @override
  State<CustomerPaymentsScreen> createState() => _CustomerPaymentsScreenState();
}

class _CustomerPaymentsScreenState extends State<CustomerPaymentsScreen> {
  final PaymentController _controller = Get.put(PaymentController());
  final ScrollController _scrollController = ScrollController();
  bool _isRefreshing = false;

  // View mode: 'list' or 'grouped'
  final RxString _viewMode = 'list'.obs;

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
    // ✅ FIX: Use fetchPaymentsByCustomer instead of fetchCustomerPayments
    await _controller.fetchPaymentsByCustomer(refresh: true);
  }

  void _scrollListener() {
    if (_scrollController.position.pixels ==
        _scrollController.position.maxScrollExtent) {
      if (!_controller.isLoadingMore.value && _controller.hasNextPage.value) {
        // ✅ FIX: Add required parameters for loadMorePayments
        _controller.loadMorePayments(
          isCustomerPayments: true, // This is for customer-wide payments
          loanId: null, // No loanId needed for customer-wide
        );
      }
    }
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
    final isSmall = MediaQuery.of(context).size.width < 360;

    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: isSmall ? 12 : 16,
                vertical: isSmall ? 8 : 12,
              ),
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
                    iconSize: isSmall ? 20 : 24,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'My Loan Payments',
                      style: GoogleFonts.poppins(
                        fontSize: isSmall ? 16 : 18,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textColor,
                      ),
                    ),
                  ),
                  // View toggle
                  Container(
                    decoration: BoxDecoration(
                      color: AppColors.backgroundColor,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: AppColors.borderColor),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _buildViewToggleButton('list', Icons.list),
                        _buildViewToggleButton('grouped', Icons.folder),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
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
            ),

            // Stats Bar
            Obx(() {
              if (_controller.payments.isEmpty) return const SizedBox();
              return _buildStatsBar();
            }),

            // Content Area
            Expanded(
              child: Obx(() {
                // Loading state
                if (_controller.isLoading.value &&
                    _controller.payments.isEmpty) {
                  return const Center(child: CircularProgressIndicator());
                }

                // Error state
                if (_controller.errorMessage.value.isNotEmpty) {
                  return _buildErrorState();
                }

                // Empty state
                if (_controller.payments.isEmpty) {
                  return _buildEmptyState();
                }

                // Content based on view mode
                return Obx(() {
                  if (_viewMode.value == 'grouped') {
                    return _buildGroupedView();
                  }
                  return _buildListView();
                });
              }),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildViewToggleButton(String mode, IconData icon) {
    return Obx(
      () => InkWell(
        onTap: () => _viewMode.value = mode,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: _viewMode.value == mode
                ? AppColors.primaryColor
                : Colors.transparent,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Icon(
            icon,
            size: 18,
            color: _viewMode.value == mode
                ? Colors.white
                : AppColors.subtextColor,
          ),
        ),
      ),
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
                'You haven\'t made any loan payments yet',
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  color: AppColors.subtextColor,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildListView() {
    return RefreshIndicator(
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
    );
  }

  Widget _buildGroupedView() {
    final loans = _controller.uniqueLoans;

    if (loans.isEmpty) {
      return _buildEmptyState();
    }

    return RefreshIndicator(
      onRefresh: _loadPayments,
      color: AppColors.primaryColor,
      child: ListView.builder(
        controller: _scrollController,
        padding: const EdgeInsets.all(16),
        itemCount: loans.length + (_controller.isLoadingMore.value ? 1 : 0),
        itemBuilder: (context, index) {
          if (index >= loans.length) {
            return const Padding(
              padding: EdgeInsets.all(16),
              child: Center(child: CircularProgressIndicator()),
            );
          }
          final loan = loans[index];
          // ✅ FIX: Use getPaymentsForLoanInCustomerView instead of getPaymentsForLoan
          final loanPayments = _controller.getPaymentsForLoanInCustomerView(
            loan['id'],
          );

          return _buildLoanGroupCard(loan, loanPayments);
        },
      ),
    );
  }

  Widget _buildLoanGroupCard(
    Map<String, dynamic> loan,
    List<PaymentModel> payments,
  ) {
    // Calculate totals for this loan
    final totalPaid = payments
        .where((p) => p.isPaid)
        .fold(0.0, (sum, p) => sum + p.amount);
    final totalPending = payments
        .where((p) => p.isPending)
        .fold(0.0, (sum, p) => sum + p.amount);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: AppColors.surfaceColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Loan header
          InkWell(
            onTap: () {
              // Navigate to loan details
              Get.toNamed(
                RoutesHelper.LoanDetailsScreen,
                arguments: loan['id'],
              );
            },
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(12),
              topRight: Radius.circular(12),
            ),
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.primaryColor.withOpacity(0.05),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(12),
                  topRight: Radius.circular(12),
                ),
                border: Border(
                  bottom: BorderSide(color: AppColors.borderColor),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.primaryColor.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.account_balance_wallet_outlined,
                      size: 16,
                      color: AppColors.primaryColor,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          loan['number'] ?? 'Loan',
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textColor,
                          ),
                        ),
                        if (loan['customerName']?.isNotEmpty == true)
                          Text(
                            loan['customerName'],
                            style: GoogleFonts.poppins(
                              fontSize: 11,
                              color: AppColors.subtextColor,
                            ),
                          ),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        'Principal: \$${loan['principal']?.toStringAsFixed(2) ?? '0.00'}',
                        style: GoogleFonts.poppins(
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                          color: AppColors.subtextColor,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          if (totalPaid > 0)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: RealTimeColors.success.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                'Paid: \$${totalPaid.toStringAsFixed(2)}',
                                style: GoogleFonts.poppins(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600,
                                  color: RealTimeColors.success,
                                ),
                              ),
                            ),
                          const SizedBox(width: 4),
                          if (totalPending > 0)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: RealTimeColors.warning.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                'Pending: \$${totalPending.toStringAsFixed(2)}',
                                style: GoogleFonts.poppins(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600,
                                  color: RealTimeColors.warning,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // Payments list
          ...payments
              .take(3)
              .map((payment) => _buildCompactPaymentTile(payment))
              .toList(),

          if (payments.length > 3)
            Padding(
              padding: const EdgeInsets.all(8),
              child: Center(
                child: TextButton(
                  onPressed: () {
                    // Navigate to loan payments screen
                    Get.toNamed(
                      RoutesHelper.PaymentListScreen,
                      arguments: {'loanId': loan['id'], 'isLoanPayments': true},
                    );
                  },
                  child: Text(
                    '+ ${payments.length - 3} more payments',
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: AppColors.primaryColor,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildCompactPaymentTile(PaymentModel payment) {
    return InkWell(
      onTap: () {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          Get.toNamed(
            RoutesHelper.PaymentDetailsScreen,
            arguments: {'paymentId': payment.id},
          );
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(color: AppColors.borderColor.withOpacity(0.3)),
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 4,
              height: 24,
              decoration: BoxDecoration(
                color: _getStatusColor(payment.paymentStatus),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    payment.reference,
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textColor,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    payment.formattedDate,
                    style: GoogleFonts.poppins(
                      fontSize: 10,
                      color: AppColors.subtextColor,
                    ),
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  payment.formattedAmount,
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textColor,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 4,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: _getStatusColor(
                      payment.paymentStatus,
                    ).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    payment.paymentStatus.toUpperCase(),
                    style: GoogleFonts.poppins(
                      fontSize: 8,
                      fontWeight: FontWeight.w600,
                      color: _getStatusColor(payment.paymentStatus),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
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
                        if (payment.loanNumber.isNotEmpty)
                          Text(
                            'Loan: ${payment.loanNumber}',
                            style: GoogleFonts.poppins(
                              fontSize: 11,
                              color: AppColors.primaryColor,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        Text(
                          payment.formattedDate,
                          style: GoogleFonts.poppins(
                            fontSize: 10,
                            color: AppColors.subtextColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: _getStatusColor(
                        payment.paymentStatus,
                      ).withOpacity(0.1),
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
                        Row(
                          children: [
                            Icon(
                              payment.provider == 'ecocash'
                                  ? Icons.phone_android
                                  : Icons.credit_card,
                              size: 12,
                              color: AppColors.primaryColor,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              payment.provider?.toUpperCase() ?? 'N/A',
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
