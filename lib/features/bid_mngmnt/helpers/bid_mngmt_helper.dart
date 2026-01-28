import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:real_time_pawn/core/utils/pallete.dart';
import 'package:real_time_pawn/features/auctions_mngmt/helpers/auctions_mngmt_helper.dart';
import 'package:real_time_pawn/features/bid_mngmnt/controllers/bid_mngmt_controller.dart';
import 'package:real_time_pawn/widgets/loading_widgets/circular_loader.dart';

class BidManagementHelper {
  static final BidManagementController _bidController =
      Get.find<BidManagementController>();

  /// LOAD USER BIDS
  static Future<bool> loadUserBids({
    int page = 1,
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
      final success = await _bidController.getUserBidsRequest(
        page: page,
        status: status,
        showLoader: false,
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
        showError(_bidController.errorMessage.value);
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

  /// LOAD BID DETAILS
  static Future<bool> loadBidDetails({required String bidId}) async {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (Get.isDialogOpen != true) {
        Get.dialog(
          const CustomLoader(message: 'Loading bid details...'),
          barrierDismissible: false,
        );
      }
    });

    try {
      final success = await _bidController.getBidDetailsRequest(bidId: bidId);

      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (Get.isDialogOpen == true) {
          Get.back();
        }
      });

      if (success) {
        return true;
      } else {
        showError(_bidController.errorMessage.value);
        return false;
      }
    } catch (e) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (Get.isDialogOpen == true) {
          Get.back();
        }
      });
      showError('Failed to load bid details: ${e.toString()}');
      return false;
    }
  }

  /// GET BID STATUS TEXT (based on UserBid data)
  static String getBidStatusText(dynamic bid) {
    // Handle both UserBidAuction and Auction types
    final auction = bid.auction;
    final amount = bid.amount;
    final bidderId = bid.bidder?.id;

    // Get status from auction
    final auctionStatus = auction.status?.toString().toLowerCase() ?? 'draft';

    if (auctionStatus == 'live') {
      // Check if this is winning bid
      if (auction.winningBidAmount == amount) {
        return 'WINNING';
      } else {
        return 'ACTIVE';
      }
    } else if (auctionStatus == 'closed') {
      // Check if this bid won
      if (auction.winnerUser != null && auction.winnerUser?.id == bidderId) {
        return 'WON';
      } else {
        return 'OUTBID';
      }
    }
    return 'PENDING';
  }

  /// GET BID STATUS COLOR
  static Color getBidStatusColorFromText(String statusText) {
    switch (statusText) {
      case 'ACTIVE':
        return RealTimeColors.warning;
      case 'WINNING':
        return RealTimeColors.success;
      case 'WON':
        return RealTimeColors.success;
      case 'OUTBID':
        return RealTimeColors.error;
      case 'PENDING':
        return RealTimeColors.grey500;
      default:
        return RealTimeColors.grey400;
    }
  }

  /// GET DISPUTE STATUS COLOR
  static Color getDisputeStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'none':
        return Colors.transparent;
      case 'raised':
        return RealTimeColors.warning;
      case 'under_review':
        return RealTimeColors.warning;
      case 'resolved':
        return RealTimeColors.success;
      case 'dismissed':
        return RealTimeColors.error;
      case 'rejected':
        return RealTimeColors.error;
      case 'cancelled':
        return RealTimeColors.grey500;
      default:
        return RealTimeColors.grey400;
    }
  }

  /// GET DISPUTE STATUS TEXT
  static String getDisputeStatusText(String status) {
    switch (status.toLowerCase()) {
      case 'none':
        return 'No Dispute';
      case 'raised':
        return 'Dispute Raised';
      case 'under_review':
        return 'Under Review';
      case 'resolved':
        return 'Resolved';
      case 'dismissed':
        return 'Dismissed';
      case 'rejected':
        return 'Rejected';
      case 'cancelled':
        return 'Cancelled';
      default:
        return 'Unknown';
    }
  }

  /// GET PAYMENT STATUS COLOR
  static Color getPaymentStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'paid':
        return RealTimeColors.success;
      case 'partially_paid':
        return RealTimeColors.warning;
      case 'pending':
        return RealTimeColors.warning;
      case 'unpaid':
        return RealTimeColors.error;
      case 'failed':
        return RealTimeColors.error;
      case 'refunded':
        return RealTimeColors.grey500;
      case 'disputed':
        return RealTimeColors.warning;
      default:
        return RealTimeColors.grey400;
    }
  }

  /// GET PAYMENT STATUS TEXT
  static String getPaymentStatusText(String status) {
    switch (status.toLowerCase()) {
      case 'paid':
        return 'Paid';
      case 'partially_paid':
        return 'Partially Paid';
      case 'pending':
        return 'Pending';
      case 'unpaid':
        return 'Unpaid';
      case 'failed':
        return 'Failed';
      case 'refunded':
        return 'Refunded';
      case 'disputed':
        return 'Disputed';
      default:
        return 'Unknown';
    }
  }

  /// FORMAT CURRENCY
  static String formatCurrency(double amount, [String currency = 'USD']) {
    if (amount >= 1000) {
      return '\$${(amount / 1000).toStringAsFixed(1)}k';
    }
    return '\$${amount.toStringAsFixed(2)}';
  }

  /// GET TIME AGO STRING
  static String getTimeAgo(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays > 365) {
      final years = (difference.inDays / 365).floor();
      return '$years year${years > 1 ? 's' : ''} ago';
    } else if (difference.inDays > 30) {
      final months = (difference.inDays / 30).floor();
      return '$months month${months > 1 ? 's' : ''} ago';
    } else if (difference.inDays > 0) {
      return '${difference.inDays} day${difference.inDays > 1 ? 's' : ''} ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} hour${difference.inHours > 1 ? 's' : ''} ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} minute${difference.inMinutes > 1 ? 's' : ''} ago';
    } else {
      return 'Just now';
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
    AuctionsHelper.navigateToAuctionDetails(
      auctionId: auctionId,
      context: context,
    );
  }

  /// GET BID SUMMARY STATISTICS
  static Map<String, int> getBidSummary(List<dynamic> bids) {
    int total = bids.length;
    int active = 0;
    int winning = 0;
    int won = 0;
    int lost = 0;
    int withDispute = 0;

    for (var bid in bids) {
      // Check dispute
      final disputeStatus =
          bid.dispute?.status?.toString().toLowerCase() ?? 'none';
      if (disputeStatus != 'none') {
        withDispute++;
      }

      // Get auction and bidder info
      final auction = bid.auction;
      final auctionStatus = auction.status?.toString().toLowerCase() ?? 'draft';
      final bidderId = bid.bidder?.id;

      if (auctionStatus == 'live') {
        if (auction.winningBidAmount == bid.amount) {
          winning++;
          active++;
        } else {
          active++;
        }
      } else if (auctionStatus == 'closed') {
        if (auction.winnerUser != null && auction.winnerUser?.id == bidderId) {
          won++;
        } else {
          lost++;
        }
      }
    }

    return {
      'total': total,
      'active': active,
      'winning': winning,
      'won': won,
      'lost': lost,
      'withDispute': withDispute,
    };
  }

  /// CHECK IF BID CAN HAVE DISPUTE
  static bool canRaiseDispute(dynamic bid) {
    // Can raise dispute if:
    // 1. Auction is closed
    // 2. No existing dispute
    final auctionStatus =
        bid.auction.status?.toString().toLowerCase() ?? 'draft';
    final disputeStatus =
        bid.dispute?.status?.toString().toLowerCase() ?? 'none';

    return auctionStatus == 'closed' && disputeStatus == 'none';
  }

  /// GET BID IS ACTIVE
  static bool isBidActive(dynamic bid) {
    final auctionStatus =
        bid.auction.status?.toString().toLowerCase() ?? 'draft';
    return auctionStatus == 'live';
  }

  /// GET BID IS WINNING
  static bool isBidWinning(dynamic bid) {
    final auctionStatus =
        bid.auction.status?.toString().toLowerCase() ?? 'draft';
    if (auctionStatus == 'live') {
      return bid.auction.winningBidAmount == bid.amount;
    }
    return false;
  }

  /// GET BID HAS DISPUTE
  static bool hasBidDispute(dynamic bid) {
    final disputeStatus =
        bid.dispute?.status?.toString().toLowerCase() ?? 'none';
    return disputeStatus != 'none';
  }

  /// GET BID IS PAID
  static bool isBidPaid(dynamic bid) {
    final paymentStatus =
        bid.paymentStatus?.toString().toLowerCase() ?? 'unpaid';
    return paymentStatus == 'paid' || paymentStatus == 'partially_paid';
  }

  /// GET BID IS WON
  static bool isBidWon(dynamic bid) {
    final auctionStatus =
        bid.auction.status?.toString().toLowerCase() ?? 'draft';
    if (auctionStatus == 'closed') {
      final bidderId = bid.bidder?.id;
      return bid.auction.winnerUser != null &&
          bid.auction.winnerUser?.id == bidderId;
    }
    return false;
  }
}
