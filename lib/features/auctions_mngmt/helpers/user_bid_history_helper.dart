// bid_mngmt_helper.dart
// lib/features/user_bids/helpers/user_bids_helper.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:real_time_pawn/config/routers/router.dart';
import 'package:real_time_pawn/core/utils/pallete.dart';
import 'package:real_time_pawn/features/auctions_mngmt/controllers/user_bid_history_controller.dart';
import 'package:real_time_pawn/models/user_bid_models.dart';

class UserBidsHelper {
  static final UserBidsController _controller = Get.find<UserBidsController>();

  /// STATUS COLOR HELPER
  static Color getAuctionStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'live':
        return RealTimeColors.success;
      case 'upcoming':
        return RealTimeColors.warning;
      case 'closed':
      case 'past':
        return RealTimeColors.error;
      case 'draft':
      default:
        return RealTimeColors.grey500;
    }
  }

  /// STATUS TEXT HELPER
  static String getAuctionStatusText(String status) {
    switch (status.toLowerCase()) {
      case 'live':
        return 'LIVE';
      case 'upcoming':
        return 'UPCOMING';
      case 'closed':
        return 'CLOSED';
      case 'past':
        return 'ENDED';
      case 'draft':
        return 'DRAFT';
      default:
        return status.toUpperCase();
    }
  }

  /// PAYMENT STATUS COLOR HELPER
  static Color getPaymentStatusColor(BidPaymentStatus status) {
    switch (status) {
      case BidPaymentStatus.paid:
        return RealTimeColors.success;
      case BidPaymentStatus.partially_paid:
        return RealTimeColors.warning;
      case BidPaymentStatus.unpaid:
        return RealTimeColors.error;
      case BidPaymentStatus.refunded:
        return RealTimeColors.grey600;
      case BidPaymentStatus.failed:
        return RealTimeColors.grey500;
    }
  }

  /// PAYMENT STATUS TEXT HELPER
  static String getPaymentStatusText(BidPaymentStatus status) {
    switch (status) {
      case BidPaymentStatus.paid:
        return 'Paid';
      case BidPaymentStatus.partially_paid:
        return 'Partial';
      case BidPaymentStatus.unpaid:
        return 'Unpaid';
      case BidPaymentStatus.refunded:
        return 'Refunded';
      case BidPaymentStatus.failed:
        return 'Failed';
    }
  }

  /// DISPUTE STATUS COLOR HELPER
  static Color getDisputeStatusColor(BidDisputeStatus status) {
    switch (status) {
      case BidDisputeStatus.raised:
        return RealTimeColors.warning;
      case BidDisputeStatus.under_review:
        return RealTimeColors.grey600;
      case BidDisputeStatus.resolved:
        return RealTimeColors.success;
      case BidDisputeStatus.dismissed:
        return RealTimeColors.error;
      case BidDisputeStatus.none:
        return RealTimeColors.grey500;
    }
  }

  /// DISPUTE STATUS TEXT HELPER
  static String getDisputeStatusText(BidDisputeStatus status) {
    switch (status) {
      case BidDisputeStatus.raised:
        return 'Disputed';
      case BidDisputeStatus.under_review:
        return 'Under Review';
      case BidDisputeStatus.resolved:
        return 'Resolved';
      case BidDisputeStatus.dismissed:
        return 'Dismissed';
      case BidDisputeStatus.none:
        return 'No Dispute';
    }
  }

  /// FORMAT DATE TIME
  static String formatDateTime(DateTime date) {
    final dateFormat = DateFormat('MMM dd, yyyy');
    final timeFormat = DateFormat('h:mm a');
    return '${dateFormat.format(date)} at ${timeFormat.format(date)}';
  }

  /// FORMAT CURRENCY
  static String formatCurrency(double amount, String currency) {
    final format = NumberFormat.currency(
      symbol: currency == 'USD' ? '\$' : currency,
      decimalDigits: 2,
    );
    return format.format(amount);
  }

  /// LOAD USER BIDS
  static Future<bool> loadUserBids({
    String? status,
    bool showLoader = true,
  }) async {
    if (showLoader) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (Get.isDialogOpen != true) {
          Get.dialog(
            const CustomLoader(message: 'Loading your bids...'),
            barrierDismissible: false,
          );
        }
      });
    }

    try {
      final success = await _controller.getUserBiddingHistoryRequest(
        status: status,
      );

      if (showLoader) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (Get.isDialogOpen == true) {
            Get.back();
          }
        });
      }

      if (success) {
        return true;
      } else {
        showError(_controller.errorMessage.value);
        return false;
      }
    } catch (e) {
      if (showLoader) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (Get.isDialogOpen == true) {
            Get.back();
          }
        });
      }
      showError('Failed to load bids: ${e.toString()}');
      return false;
    }
  }

  /// SHOW ERROR
  static void showError(String message) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Get.snackbar(
        'Error',
        message,
        snackPosition: SnackPosition.TOP,
        backgroundColor: AppColors.errorColor,
        colorText: Colors.white,
        borderRadius: 12,
        margin: const EdgeInsets.all(16),
        duration: 3.seconds,
      );
    });
  }

  /// SHOW SUCCESS
  static void showSuccess(String message) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Get.snackbar(
        'Success',
        message,
        snackPosition: SnackPosition.TOP,
        backgroundColor: AppColors.successColor,
        colorText: Colors.white,
        borderRadius: 12,
        margin: const EdgeInsets.all(16),
        duration: 2.seconds,
      );
    });
  }

  /// NAVIGATE TO AUCTION DETAILS
  static void navigateToAuctionDetails({
    required String auctionId,
    required BuildContext context,
  }) {
    // You can reuse the existing auction details screen
    // or create a simplified version if needed
    Get.toNamed(
      RoutesHelper.auctionDetailsScreen.replaceFirst(':id', auctionId),
    );
  }

  /// CHECK IF BID IS WINNING
  static bool isWinningBid(UserBid bid) {
    return bid.auction.winnerUser != null &&
        bid.auction.winnerUser?.id == bid.bidder.id &&
        bid.auction.winningBidAmount != null &&
        (bid.auction.winningBidAmount! - bid.amount).abs() < 0.01;
  }

  /// GET BID STATUS SUMMARY
  static Map<String, dynamic> getBidSummary(List<UserBid> bids) {
    final total = bids.length;
    final won = bids.where((bid) => isWinningBid(bid)).length;
    final active = bids.where((bid) => bid.auction.status == 'live').length;
    final pendingPayment = bids
        .where(
          (bid) =>
              bid.paymentStatus == BidPaymentStatus.unpaid ||
              bid.paymentStatus == BidPaymentStatus.partially_paid,
        )
        .length;

    return {
      'total': total,
      'won': won,
      'active': active,
      'pendingPayment': pendingPayment,
    };
  }
}

// Add this to your existing CustomLoader if not exists
class CustomLoader extends StatelessWidget {
  final String message;

  const CustomLoader({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(color: AppColors.primaryColor),
            const SizedBox(height: 16),
            Text(message, style: const TextStyle(fontSize: 14)),
          ],
        ),
      ),
    );
  }
}
