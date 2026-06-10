import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:real_time_pawn/core/utils/pallete.dart';
import '../../../models/notifications_model.dart';

class NotificationCard extends StatelessWidget {
  final NotificationsModel notification;
  final int index;
  final VoidCallback onTap;
  final VoidCallback? onMarkRead;
  final VoidCallback? onActionTap;

  const NotificationCard({
    super.key,
    required this.notification,
    required this.index,
    required this.onTap,
    this.onMarkRead,
    this.onActionTap,
  });

  String _formatDate(DateTime? date) {
    if (date == null) return 'Just now';
    
    final now = DateTime.now();
    final difference = now.difference(date);
    
    if (difference.inDays > 7) {
      return DateFormat('MMM dd, yyyy').format(date);
    } else if (difference.inDays > 0) {
      return '${difference.inDays} day${difference.inDays > 1 ? 's' : ''} ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} hour${difference.inHours > 1 ? 's' : ''} ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} min${difference.inMinutes > 1 ? 's' : ''} ago';
    } else {
      return 'Just now';
    }
  }

  String _formatTime(DateTime? date) {
    if (date == null) return '';
    return DateFormat('h:mm a').format(date);
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
      case 'others':
        return Icons.notifications_rounded;
      
      default:
        return Icons.notifications_rounded;
    }
  }

  Color _getNotificationColor(String? type) {
    switch (type?.toLowerCase()) {
      // Loan lifecycle
      case 'loan_application':
        return AppColors.successColor;
      case 'loan_approved':
        return AppColors.successColor;
      case 'loan_rejected':
        return AppColors.errorColor;
      case 'loan_disbursed':
        return AppColors.successColor;
      case 'repayment_due':
        return AppColors.warningColor;
      case 'repayment_overdue':
        return AppColors.errorColor;
      case 'repayment_received':
        return AppColors.successColor;
      case 'loan_closed':
        return AppColors.successColor;
      
      // Collateral lifecycle
      case 'collateral_received':
        return AppColors.successColor;
      case 'collateral_verified':
        return AppColors.successColor;
      case 'collateral_at_risk':
        return AppColors.warningColor;
      case 'collateral_auctioned':
        return Colors.deepOrange;
      case 'collateral_released':
        return AppColors.successColor;
      
      // Auctions & bidding
      case 'auction_created':
        return AppColors.successColor;
      case 'auction_started':
        return AppColors.successColor;
      case 'auction_ending_soon':
        return AppColors.warningColor;
      case 'auction_closed':
        return AppColors.errorColor;
      case 'auction_won':
        return AppColors.successColor;
      case 'auction_lost':
        return AppColors.errorColor;
      case 'bid_placed':
        return AppColors.successColor;
      case 'bid_outbid':
        return AppColors.warningColor;
      case 'bid_winning':
        return AppColors.successColor;
      case 'bid_won':
        return AppColors.successColor;
      case 'bid_payment_due':
        return AppColors.warningColor;
      case 'bid_payment_received':
        return AppColors.successColor;
      
      // Account / compliance
      case 'account_kyc':
        return AppColors.successColor;
      case 'account_status':
        return AppColors.successColor;
      case 'system_notice':
        return AppColors.successColor;
      case 'security_alert':
        return AppColors.errorColor;
      case 'others':
        return AppColors.primaryColor;
      
      default:
        return AppColors.primaryColor;
    }
  }

  String _getNotificationTypeLabel(String? type) {
    switch (type?.toLowerCase()) {
      // Loan lifecycle
      case 'loan_application': return 'Loan Application';
      case 'loan_approved': return 'Loan Approved';
      case 'loan_rejected': return 'Loan Rejected';
      case 'loan_disbursed': return 'Loan Disbursed';
      case 'repayment_due': return 'Repayment Due';
      case 'repayment_overdue': return 'Repayment Overdue';
      case 'repayment_received': return 'Repayment Received';
      case 'loan_closed': return 'Loan Closed';
      
      // Collateral lifecycle
      case 'collateral_received': return 'Collateral Received';
      case 'collateral_verified': return 'Collateral Verified';
      case 'collateral_at_risk': return 'Collateral at Risk';
      case 'collateral_auctioned': return 'Collateral Auctioned';
      case 'collateral_released': return 'Collateral Released';
      
      // Auctions & bidding
      case 'auction_created': return 'Auction Created';
      case 'auction_started': return 'Auction Started';
      case 'auction_ending_soon': return 'Auction Ending Soon';
      case 'auction_closed': return 'Auction Closed';
      case 'auction_won': return 'Auction Won';
      case 'auction_lost': return 'Auction Lost';
      case 'bid_placed': return 'Bid Placed';
      case 'bid_outbid': return 'Outbid';
      case 'bid_winning': return 'Winning Bid';
      case 'bid_won': return 'Bid Won';
      case 'bid_payment_due': return 'Bid Payment Due';
      case 'bid_payment_received': return 'Bid Payment Received';
      
      // Account / compliance
      case 'account_kyc': return 'KYC Verification';
      case 'account_status': return 'Account Status';
      case 'system_notice': return 'System Notice';
      case 'security_alert': return 'Security Alert';
      case 'others': return 'Notification';
      
      default: return 'Notification';
    }
  }

  @override
  Widget build(BuildContext context) {
    final isUnread = notification.isRead == false;
    final notificationColor = _getNotificationColor(notification.type);
    final hasAction = notification.actionText != null && notification.actionUrl != null;
    final typeLabel = _getNotificationTypeLabel(notification.type);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Stack(
          children: [
            // Unread indicator bar
            if (isUnread)
              Positioned(
                left: 0,
                top: 0,
                bottom: 0,
                child: Container(
                  width: 4,
                  decoration: BoxDecoration(
                    color: notificationColor,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(20),
                      bottomLeft: Radius.circular(20),
                    ),
                  ),
                ),
              ),
            
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Icon Container
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: notificationColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Icon(
                      _getNotificationIcon(notification.type),
                      color: notificationColor,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  
                  // Content
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                notification.title ?? 'Notification',
                                style: GoogleFonts.poppins(
                                  color: AppColors.textColor,
                                  fontSize: 15,
                                  fontWeight: isUnread ? FontWeight.w700 : FontWeight.w600,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            if (isUnread)
                              Container(
                                width: 8,
                                height: 8,
                                decoration: BoxDecoration(
                                  color: notificationColor,
                                  shape: BoxShape.circle,
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        
                        // Type chip
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: notificationColor.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            typeLabel,
                            style: GoogleFonts.poppins(
                              color: notificationColor,
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        
                        const SizedBox(height: 8),
                        
                        Text(
                          notification.message ?? '',
                          style: GoogleFonts.poppins(
                            color: AppColors.subtextColor,
                            fontSize: 13,
                            fontWeight: FontWeight.w400,
                            height: 1.4,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 8),
                        
                        Row(
                          children: [
                            Icon(
                              Icons.access_time_rounded,
                              size: 12,
                              color: AppColors.subtextColor.withValues(alpha: 0.7),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              _formatDate(notification.createdAt),
                              style: GoogleFonts.poppins(
                                color: AppColors.subtextColor.withValues(alpha: 0.7),
                                fontSize: 11,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              '•',
                              style: GoogleFonts.poppins(
                                color: AppColors.subtextColor.withValues(alpha: 0.7),
                                fontSize: 11,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              _formatTime(notification.createdAt),
                              style: GoogleFonts.poppins(
                                color: AppColors.subtextColor.withValues(alpha: 0.7),
                                fontSize: 11,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                          ],
                        ),
                        
                        // Action Button
                        if (hasAction)
                          Padding(
                            padding: const EdgeInsets.only(top: 12),
                            child: GestureDetector(
                              onTap: onActionTap,
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 8,
                                ),
                                decoration: BoxDecoration(
                                  color: notificationColor.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.arrow_forward_rounded,
                                      size: 14,
                                      color: notificationColor,
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      notification.actionText ?? 'View',
                                      style: GoogleFonts.poppins(
                                        color: notificationColor,
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                  
                  // Mark as read button (for unread notifications)
                  if (isUnread && onMarkRead != null)
                    Padding(
                      padding: const EdgeInsets.only(left: 8),
                      child: GestureDetector(
                        onTap: onMarkRead,
                        child: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: AppColors.primaryColor.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Icon(
                            Icons.done_rounded,
                            size: 16,
                            color: AppColors.primaryColor,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    ).animate().fadeIn(
      delay: Duration(milliseconds: 100 + (index * 50)),
      duration: 400.ms,
    ).slideY(
      begin: 0.2,
      end: 0,
      duration: 500.ms,
      curve: Curves.easeOutCubic,
    );
  }
}