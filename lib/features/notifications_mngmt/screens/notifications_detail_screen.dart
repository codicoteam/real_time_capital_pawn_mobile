import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:real_time_pawn/config/routers/router.dart';
import 'package:real_time_pawn/core/utils/logs.dart';
import 'package:real_time_pawn/core/utils/pallete.dart';
import '../../../global/user_controller.dart';
import '../controllers/notifications_mngmt_controller.dart';
import '../../../models/notifications_model.dart';

class NotificationDetailScreen extends StatefulWidget {
  final String notificationId;

  const NotificationDetailScreen({super.key, required this.notificationId});

  @override
  State<NotificationDetailScreen> createState() =>
      _NotificationDetailScreenState();
}

class _NotificationDetailScreenState extends State<NotificationDetailScreen>
    with TickerProviderStateMixin {
  final NotificationController _controller = Get.find<NotificationController>();
  final UserController _userController = Get.find<UserController>();
  late AnimationController _animationController;

  NotificationsModel? _notification;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _animationController.forward();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadNotification();
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _loadNotification() async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final notification = await _controller.getNotificationDetails(
        widget.notificationId,
      );

      if (!mounted) return;

      if (notification != null) {
        setState(() {
          _notification = notification;
          _isLoading = false;
        });

        // Mark as read if not already
        if (notification.isRead == false) {
          await _controller.markAsRead(notification.id!);
          if (!mounted) return;
          setState(() {
            _notification?.isRead = true;
            _notification?.readAt = DateTime.now();
          });
        }
      } else {
        setState(() {
          _error = 'Failed to load notification';
          _isLoading = false;
        });
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = 'An error occurred: $e';
        _isLoading = false;
      });
    }
  }

  Future<void> _handleAction() async {
    if (_notification == null) return;

    // Record the action
    await _controller.markAsReadAndAct(
      notificationId: _notification!.id!,
      action: _notification!.actionText ?? 'view',
    );

    // Navigate based on entity type
    final entityType = _notification?.entityType?.toLowerCase();

    switch (entityType) {
      case 'loan':
        Get.toNamed(RoutesHelper.LoansScreen);
        break;

      case 'loan_application':
        // Get the current user ID from UserController

        Get.toNamed(RoutesHelper.main_home_page);

      case 'auction':
        Get.toNamed(RoutesHelper.auctionsListScreen);
        break;

      default:
        // Fallback to action URL if available
        if (_notification?.actionUrl != null &&
            _notification!.actionUrl!.isNotEmpty) {
          Get.toNamed(RoutesHelper.main_home_page);
        } else {
          // Go to home screen as fallback
          Get.toNamed(RoutesHelper.main_home_page);
        }
        break;
    }
  }

  void _handleEntityTap() {
    if (_notification == null) return;

    final entityType = _notification?.entityType?.toLowerCase();

    switch (entityType) {
      case 'loan':
        Get.toNamed(RoutesHelper.LoansScreen);
        break;

      case 'loan_application':
        final userId = _userController.user?.userId;

        if (userId != null && userId.isNotEmpty) {
          Get.toNamed(
            RoutesHelper.loanApplicationsScreen,
            arguments: {'customerUserId': userId},
          );
        } else {
          Get.snackbar(
            'Error',
            'Unable to load loan applications. User ID not found.',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: AppColors.errorColor,
            colorText: Colors.white,
          );
        }
        break;

      case 'auction':
        Get.toNamed(RoutesHelper.auctionsListScreen);
        break;

      default:
        if (_notification?.actionUrl != null &&
            _notification!.actionUrl!.isNotEmpty) {
          Get.toNamed(_notification!.actionUrl!);
        }
        break;
    }
  }

  String _formatDateTime(DateTime? date) {
    if (date == null) return 'Unknown';
    return DateFormat('EEEE, MMMM dd, yyyy • h:mm a').format(date);
  }

  IconData _getNotificationIcon(String? type) {
    switch (type?.toLowerCase()) {
      // Loan lifecycle
      case 'loan_application':
        return Icons.description_rounded;
      case 'loan_approved':
        return Icons.thumb_up_rounded;
      case 'loan_rejected':
        return Icons.cancel_rounded;
      case 'loan_disbursed':
        return Icons.account_balance_wallet_rounded;
      case 'repayment_due':
        return Icons.payment_rounded;
      case 'repayment_overdue':
        return Icons.warning_amber_rounded;
      case 'repayment_received':
        return Icons.check_circle_rounded;
      case 'loan_closed':
        return Icons.check_circle_outline_rounded;
      // Collateral lifecycle
      case 'collateral_received':
        return Icons.inventory_2_rounded;
      case 'collateral_verified':
        return Icons.verified_rounded;
      case 'collateral_at_risk':
        return Icons.warning_rounded;
      case 'collateral_auctioned':
        return Icons.gavel_rounded;
      case 'collateral_released':
        return Icons.logout_rounded;
      // Auctions & bidding
      case 'auction_created':
        return Icons.add_circle_rounded;
      case 'auction_started':
        return Icons.play_circle_rounded;
      case 'auction_ending_soon':
        return Icons.timer_rounded;
      case 'auction_closed':
        return Icons.stop_circle_rounded;
      case 'auction_won':
        return Icons.celebration_rounded;
      case 'auction_lost':
        return Icons.sentiment_dissatisfied_rounded;
      case 'bid_placed':
        return Icons.attach_money_rounded;
      case 'bid_outbid':
        return Icons.trending_up_rounded;
      case 'bid_winning':
        return Icons.leaderboard_rounded;
      case 'bid_won':
        return Icons.emoji_events_rounded;
      case 'bid_payment_due':
        return Icons.receipt_rounded;
      case 'bid_payment_received':
        return Icons.payment_rounded;
      // Account / compliance
      case 'account_kyc':
        return Icons.verified_user_rounded;
      case 'account_status':
        return Icons.account_circle_rounded;
      case 'system_notice':
        return Icons.announcement_rounded;
      case 'security_alert':
        return Icons.security_rounded;
      default:
        return Icons.notifications_rounded;
    }
  }

  Color _getNotificationColor(String? type) {
    switch (type?.toLowerCase()) {
      case 'loan_approved':
      case 'loan_disbursed':
      case 'repayment_received':
      case 'loan_closed':
      case 'collateral_verified':
      case 'collateral_released':
      case 'auction_won':
      case 'bid_won':
      case 'bid_payment_received':
        return AppColors.successColor;
      case 'loan_rejected':
      case 'repayment_overdue':
      case 'collateral_auctioned':
      case 'auction_lost':
      case 'security_alert':
        return AppColors.errorColor;
      case 'repayment_due':
      case 'collateral_at_risk':
      case 'auction_ending_soon':
      case 'bid_outbid':
      case 'bid_payment_due':
        return AppColors.warningColor;
      default:
        return AppColors.primaryColor;
    }
  }

  String _getEntityLabel(String? entityType) {
    switch (entityType?.toLowerCase()) {
      case 'loan':
        return 'Loan';
      case 'loan_application':
        return 'Loan Application';
      case 'auction':
        return 'Auction';
      default:
        return 'Notification';
    }
  }

  String _getActionButtonText() {
    final entityType = _notification?.entityType?.toLowerCase();

    // Custom button text based on entity type
    switch (entityType) {
      case 'loan':
        return 'View My Loans';
      case 'loan_application':
        return 'View Loan Applications';
      case 'auction':
        return 'View Auctions';
      default:
        return _notification?.actionText ?? 'Take Action';
    }
  }

  Widget _buildEntityInfo() {
    if (_notification?.entityType == null || _notification?.entityId == null) {
      return const SizedBox.shrink();
    }

    final entityLabel = _getEntityLabel(_notification?.entityType);
    final entityId = _notification?.entityId ?? '';
    final entityType = _notification?.entityType?.toLowerCase();

    // Check if entity is tappable
    final bool isTappable =
        entityType == 'loan' ||
        entityType == 'loan_application' ||
        entityType == 'auction';

    return GestureDetector(
      onTap: isTappable ? _handleEntityTap : null,
      child: Container(
        margin: const EdgeInsets.only(top: 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.primaryColor.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: AppColors.primaryColor.withValues(alpha: 0.1),
            width: 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.primaryColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                Icons.link_rounded,
                size: 20,
                color: AppColors.primaryColor,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Related $entityLabel',
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: AppColors.subtextColor,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'ID: $entityId',
                    style: GoogleFonts.poppins(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textColor,
                    ),
                  ),
                ],
              ),
            ),
            if (isTappable)
              const Icon(
                Icons.arrow_forward_ios_rounded,
                size: 14,
                color: AppColors.subtextColor,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoanDataSection() {
    final data = _notification?.data;
    if (data == null) return const SizedBox.shrink();

    final List<MapEntry<String, dynamic>> entries = [];

    if (data.dueDate != null) {
      entries.add(
        MapEntry('Due Date', DateFormat('MMM dd, yyyy').format(data.dueDate!)),
      );
    }
    if (data.amountDue != null) {
      entries.add(
        MapEntry('Amount Due', '\$${data.amountDue!.toStringAsFixed(2)}'),
      );
    }
    if (data.remainingBalance != null) {
      entries.add(
        MapEntry(
          'Remaining Balance',
          '\$${data.remainingBalance!.toStringAsFixed(2)}',
        ),
      );
    }
    if (data.lateFeeIfMissed != null) {
      entries.add(MapEntry('Late Fee', '\$${data.lateFeeIfMissed}'));
    }
    if (data.loanAmount != null) {
      entries.add(MapEntry('Loan Amount', '\$${data.loanAmount}'));
    }
    if (data.interestRate != null) {
      entries.add(MapEntry('Interest Rate', '${data.interestRate}%'));
    }
    if (data.loanTermMonths != null) {
      entries.add(MapEntry('Term', '${data.loanTermMonths} months'));
    }
    if (data.monthlyPayment != null) {
      entries.add(
        MapEntry(
          'Monthly Payment',
          '\$${data.monthlyPayment!.toStringAsFixed(2)}',
        ),
      );
    }
    if (data.pendingCount != null) {
      entries.add(
        MapEntry('Pending Applications', data.pendingCount.toString()),
      );
    }
    if (data.totalAmount != null) {
      entries.add(MapEntry('Total Amount', '\$${data.totalAmount}'));
    }

    if (entries.isEmpty) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.only(top: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderColor, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Details',
            style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.textColor,
            ),
          ),
          const SizedBox(height: 12),
          ...entries.map(
            (entry) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    entry.key,
                    style: GoogleFonts.poppins(
                      fontSize: 13,
                      fontWeight: FontWeight.w400,
                      color: AppColors.subtextColor,
                    ),
                  ),
                  Text(
                    entry.value,
                    style: GoogleFonts.poppins(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textColor,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildApplicationsSection() {
    final applications = _notification?.data?.applications;
    if (applications == null || applications.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      margin: const EdgeInsets.only(top: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderColor, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Applications',
            style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.textColor,
            ),
          ),
          const SizedBox(height: 12),
          ...applications.map(
            (app) => Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.backgroundColor,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        app.customer ?? 'Unknown',
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
                          color: AppColors.primaryColor.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          '\$${app.amount}',
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: AppColors.primaryColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'ID: ${app.id}',
                    style: GoogleFonts.poppins(
                      fontSize: 11,
                      fontWeight: FontWeight.w400,
                      color: AppColors.subtextColor,
                    ),
                  ),
                  if (app.submittedAt != null)
                    Text(
                      'Submitted: ${DateFormat('MMM dd, yyyy').format(app.submittedAt!)}',
                      style: GoogleFonts.poppins(
                        fontSize: 11,
                        fontWeight: FontWeight.w400,
                        color: AppColors.subtextColor,
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAcknowledgementSection() {
    final acknowledgements = _notification?.acknowledgements;
    if (acknowledgements == null || acknowledgements.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      margin: const EdgeInsets.only(top: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderColor, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Activity',
            style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.textColor,
            ),
          ),
          const SizedBox(height: 12),
          ...acknowledgements.map(
            (ack) => Row(
              children: [
                Icon(
                  ack.action == 'view'
                      ? Icons.visibility_rounded
                      : Icons.touch_app_rounded,
                  size: 16,
                  color: AppColors.primaryColor,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        ack.action == 'view'
                            ? 'Viewed'
                            : 'Action taken: ${ack.action}',
                        style: GoogleFonts.poppins(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: AppColors.textColor,
                        ),
                      ),
                      if (ack.actedAt != null)
                        Text(
                          DateFormat(
                            'MMM dd, yyyy • h:mm a',
                          ).format(ack.actedAt!),
                          style: GoogleFonts.poppins(
                            fontSize: 11,
                            fontWeight: FontWeight.w400,
                            color: AppColors.subtextColor,
                          ),
                        ),
                    ],
                  ),
                ),
              ],
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
        child: _isLoading
            ? _buildLoadingState()
            : _error != null
            ? _buildErrorState()
            : _buildContent(),
      ),
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: 50,
            height: 50,
            child: CircularProgressIndicator(
              strokeWidth: 3,
              valueColor: AlwaysStoppedAnimation<Color>(AppColors.primaryColor),
            ),
          ).animate().rotate(duration: 1500.ms),
          const SizedBox(height: 24),
          Text(
            'Loading notification...',
            style: GoogleFonts.poppins(
              color: AppColors.subtextColor,
              fontSize: 14,
            ),
          ).animate().fadeIn(duration: 500.ms),
        ],
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.errorColor.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.error_outline_rounded,
              size: 60,
              color: AppColors.errorColor,
            ),
          ).animate().scale(delay: 100.ms),
          const SizedBox(height: 24),
          Text(
            'Something went wrong',
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: AppColors.textColor,
            ),
          ).animate().fadeIn(delay: 200.ms),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Text(
              _error ?? 'Failed to load notification',
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: AppColors.subtextColor,
              ),
              textAlign: TextAlign.center,
            ),
          ).animate().fadeIn(delay: 300.ms),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: _loadNotification,
            icon: const Icon(Icons.refresh_rounded),
            label: Text(
              'Try Again',
              style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryColor,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ).animate().fadeIn(delay: 400.ms),
        ],
      ),
    );
  }

  Widget _buildContent() {
    final notificationColor = _getNotificationColor(_notification?.type);
    final hasAction =
        _notification?.actionText != null || _notification?.entityType != null;
    final actionButtonText = _getActionButtonText();

    return CustomScrollView(
      physics: const BouncingScrollPhysics(),
      slivers: [
        // Header with gradient
        SliverAppBar(
          expandedHeight: 280,
          floating: false,
          pinned: true,
          backgroundColor: AppColors.backgroundColor,
          flexibleSpace: FlexibleSpaceBar(
            background: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    AppColors.primaryColor,
                    AppColors.primaryColor.withValues(alpha: 0.85),
                  ],
                ),
              ),
              child: SafeArea(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Spacer(),
                    // Icon Circle
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.1),
                            blurRadius: 20,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      child: Icon(
                        _getNotificationIcon(_notification?.type),
                        size: 40,
                        color: notificationColor,
                      ),
                    ).animate().scale(delay: 100.ms, duration: 500.ms),
                    const SizedBox(height: 16),
                    // Title
                    Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 24),
                          child: Text(
                            _notification?.title ?? 'Notification',
                            style: GoogleFonts.poppins(
                              fontSize: 22,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        )
                        .animate()
                        .fadeIn(delay: 200.ms)
                        .slideY(begin: 0.2, end: 0),
                    const SizedBox(height: 8),
                    // Date
                    Text(
                      _formatDateTime(_notification?.createdAt),
                      style: GoogleFonts.poppins(
                        fontSize: 13,
                        fontWeight: FontWeight.w400,
                        color: Colors.white.withValues(alpha: 0.8),
                      ),
                    ).animate().fadeIn(delay: 300.ms),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ),
          leading: IconButton(
            icon: const Icon(
              Icons.arrow_back_ios_new_rounded,
              color: Colors.white,
            ),
            onPressed: () => Navigator.pop(context),
          ).animate().fadeIn(delay: 100.ms).slideX(begin: -0.3, end: 0),
        ),

        // Content
        SliverToBoxAdapter(
          child: Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(32),
                topRight: Radius.circular(32),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 24),

                // Message
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Text(
                    _notification?.message ?? '',
                    style: GoogleFonts.poppins(
                      fontSize: 15,
                      fontWeight: FontWeight.w400,
                      height: 1.5,
                      color: AppColors.textColor,
                    ),
                  ),
                ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.1, end: 0),

                // Status Badge
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 16,
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: notificationColor.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              _notification?.isRead == true
                                  ? Icons.done_all_rounded
                                  : Icons.circle_rounded,
                              size: 12,
                              color: notificationColor,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              _notification?.isRead == true ? 'Read' : 'Unread',
                              style: GoogleFonts.poppins(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: notificationColor,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.primaryColor.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          (_notification?.type?.toUpperCase().replaceAll(
                                '_',
                                ' ',
                              )) ??
                              'NOTIFICATION',
                          style: GoogleFonts.poppins(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: AppColors.primaryColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                ).animate().fadeIn(delay: 500.ms),

                const Divider(height: 1, color: AppColors.borderColor),

                const SizedBox(height: 16),

                // Entity Info
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: _buildEntityInfo(),
                ),

                // Loan Data Section
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: _buildLoanDataSection(),
                ),

                // Applications Section
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: _buildApplicationsSection(),
                ),

                // Acknowledgement Section
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: _buildAcknowledgementSection(),
                ),

                // Action Button
                if (hasAction)
                  Padding(
                    padding: const EdgeInsets.all(24),
                    child:
                        ElevatedButton(
                              onPressed: _handleAction,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: notificationColor,
                                foregroundColor: Colors.white,
                                minimumSize: const Size(double.infinity, 52),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                elevation: 0,
                              ),
                              child: Text(
                                actionButtonText,
                                style: GoogleFonts.poppins(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            )
                            .animate()
                            .fadeIn(delay: 600.ms)
                            .slideY(begin: 0.1, end: 0),
                  ),

                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
