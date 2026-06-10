// features/payments_mngmt/screens/customer_payments_screen.dart - WITH CURVED HEADER ONLY

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:real_time_pawn/config/routers/router.dart';
import 'package:real_time_pawn/core/utils/pallete.dart';
import 'package:real_time_pawn/features/payments_mngmt/controllers/payments_mngmt_controller.dart';
import 'package:real_time_pawn/models/payment_mngmt_model.dart';

// Simple curved edges clipper (copied from MyBidsScreen)
class _CurvedEdgeClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    var path = Path();
    path.lineTo(0, size.height - 30);
    var firstControlPoint = Offset(size.width / 4, size.height);
    var firstEndPoint = Offset(size.width / 2, size.height);
    path.quadraticBezierTo(
      firstControlPoint.dx,
      firstControlPoint.dy,
      firstEndPoint.dx,
      firstEndPoint.dy,
    );
    var secondControlPoint = Offset(size.width * 3 / 4, size.height - 30);
    var secondEndPoint = Offset(size.width, size.height - 30);
    path.quadraticBezierTo(
      secondControlPoint.dx,
      secondControlPoint.dy,
      secondEndPoint.dx,
      secondEndPoint.dy,
    );
    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}

class CustomerPaymentsScreen extends StatefulWidget {
  const CustomerPaymentsScreen({super.key});

  @override
  State<CustomerPaymentsScreen> createState() => _CustomerPaymentsScreenState();
}

class _CustomerPaymentsScreenState extends State<CustomerPaymentsScreen>
    with TickerProviderStateMixin {
  final PaymentController _controller = Get.put(PaymentController());
  final ScrollController _scrollController = ScrollController();
  bool _isRefreshing = false;
  bool _isLoadingMore = false;

  late AnimationController _headerAnimationController;
  late AnimationController _contentAnimationController;

  @override
  void initState() {
    super.initState();
    _loadPayments();
    _scrollController.addListener(_scrollListener);

    _headerAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
    _contentAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    _headerAnimationController.forward();
    _contentAnimationController.forward();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _headerAnimationController.dispose();
    _contentAnimationController.dispose();
    super.dispose();
  }

  Future<void> _loadPayments() async {
    await _controller.fetchPaymentsByCustomer(refresh: true);
  }

  void _scrollListener() {
    if (_scrollController.position.pixels ==
        _scrollController.position.maxScrollExtent) {
      if (!_controller.isLoadingMore.value && _controller.hasNextPage.value) {
        _loadMorePayments();
      }
    }
  }

  Future<void> _loadMorePayments() async {
    setState(() => _isLoadingMore = true);
    await _controller.loadMorePayments(isCustomerPayments: true, loanId: null);
    setState(() => _isLoadingMore = false);
  }

  Future<void> _refreshPayments() async {
    setState(() => _isRefreshing = true);
    await _loadPayments();
    setState(() => _isRefreshing = false);
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
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => Get.back(),
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.white,
                backgroundColor: AppColors.primaryColor,
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                'Browse Loans',
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
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
                          _formatDate(payment.createdAt),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      body: Stack(
        children: [
          // Main scrollable content
          RefreshIndicator(
            onRefresh: _refreshPayments,
            color: AppColors.primaryColor,
            child: CustomScrollView(
              controller: _scrollController,
              physics: const AlwaysScrollableScrollPhysics(),
              slivers: [
                // Animated curved header
                SliverToBoxAdapter(
                  child: AnimatedBuilder(
                    animation: _headerAnimationController,
                    builder: (context, child) {
                      return Transform.translate(
                        offset: Offset(
                          0,
                          -20 * (1 - _headerAnimationController.value),
                        ),
                        child: Opacity(
                          opacity: _headerAnimationController.value,
                          child: ClipPath(
                            clipper: _CurvedEdgeClipper(),
                            child: Container(
                              height: 180,
                              padding: const EdgeInsets.fromLTRB(
                                24,
                                50,
                                24,
                                24,
                              ),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: [
                                    AppColors.primaryColor,
                                    AppColors.primaryColor.withValues(alpha: 0.7),
                                  ],
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: AppColors.primaryColor.withValues(alpha: 
                                      0.3,
                                    ),
                                    blurRadius: 20,
                                    offset: const Offset(0, 10),
                                  ),
                                ],
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.all(8),
                                        decoration: BoxDecoration(
                                          color: Colors.white.withValues(alpha: 0.2),
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                        ),
                                        child: const Icon(
                                          Icons.credit_card_rounded,
                                          color: Colors.white,
                                          size: 24,
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Text(
                                          'My Payments',
                                          style: GoogleFonts.poppins(
                                            color: Colors.white,
                                            fontSize: 28,
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),

                // Content section
                SliverPadding(
                  padding: const EdgeInsets.all(16),
                  sliver: SliverList(
                    delegate: SliverChildListDelegate([
                      // Stats Bar
                      Obx(() {
                        if (_controller.payments.isEmpty)
                          return const SizedBox();
                        return _buildStatsBar()
                            .animate(controller: _contentAnimationController)
                            .fadeIn()
                            .slideY(
                              begin: 0.2,
                              delay: 100.ms,
                              duration: 400.ms,
                              curve: Curves.easeOutQuad,
                            );
                      }),

                      const SizedBox(height: 8),

                      // Payments list or empty state
                      Obx(() {
                        // Loading state
                        if (_controller.isLoading.value &&
                            _controller.payments.isEmpty) {
                          return const Center(
                            child: CircularProgressIndicator(),
                          );
                        }

                        // Error state
                        if (_controller.errorMessage.value.isNotEmpty) {
                          return _buildErrorState();
                        }

                        // Empty state
                        if (_controller.payments.isEmpty) {
                          return SizedBox(
                            height: MediaQuery.of(context).size.height * 0.4,
                            child: _buildEmptyState(),
                          );
                        }

                        // Payments list
                        return Column(
                          children: _controller.payments
                              .map((payment) => _buildPaymentCard(payment))
                              .toList(),
                        );
                      }),

                      // Load more indicator
                      if (_isLoadingMore)
                        const Padding(
                          padding: EdgeInsets.all(16),
                          child: Center(child: CircularProgressIndicator()),
                        ),
                      const SizedBox(height: 20),
                    ]),
                  ),
                ),
              ],
            ),
          ),

          // Custom floating app bar with back and refresh
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                child: Row(
                  children: [
                    // Back button
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(30),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.3),
                          width: 1.5,
                        ),
                      ),
                      child: IconButton(
                        icon: const Icon(
                          Icons.arrow_back_ios_new_rounded,
                          color: Colors.white,
                          size: 20,
                        ),
                        onPressed: () => Get.back(),
                      ),
                    ),
                    const Spacer(),
                    // Refresh button
                    if (!_isRefreshing)
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(30),
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.3),
                            width: 1.5,
                          ),
                        ),
                        child: IconButton(
                          icon: const Icon(
                            Icons.refresh_rounded,
                            color: Colors.white,
                            size: 24,
                          ),
                          onPressed: _refreshPayments,
                        ),
                      )
                    else
                      Container(
                        width: 46,
                        height: 46,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(30),
                        ),
                        child: const Center(
                          child: SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
