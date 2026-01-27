import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:real_time_pawn/core/utils/pallete.dart';

import 'package:real_time_pawn/features/auctions_mngmt/controllers/auctions_mngmt_controller.dart';
import 'package:real_time_pawn/features/auctions_mngmt/screens/bid_placement_dialog.dart';
import 'package:real_time_pawn/features/auctions_mngmt/helpers/user_bid_history_helper.dart';

import 'package:real_time_pawn/models/auction_models.dart';

class BidPlacementHelper {
  static Future<void> placeBid({
    required BuildContext context,
    required String auctionId,
    required double amount,
    required String auctionTitle,
  }) async {
    // Show loading
    Get.dialog(
      const CustomLoader(message: 'Placing your bid...'),
      barrierDismissible: false,
    );

    try {
      final auctionsController = Get.find<AuctionsController>();
      final success = await auctionsController.placeBidRequest(
        auctionId: auctionId,
        amount: amount,
      );

      Get.back(); // Close loading

      if (success) {
        // Show success
        Get.snackbar(
          'Bid Placed!',
          'Your bid of \$${amount.toStringAsFixed(2)} on "$auctionTitle" has been placed successfully',
          snackPosition: SnackPosition.TOP,
          backgroundColor: RealTimeColors.success,
          colorText: Colors.white,
          duration: const Duration(seconds: 3),
        );

        // Trigger refresh if needed
        auctionsController.refreshAuctions();
      } else {
        Get.snackbar(
          'Bid Failed',
          auctionsController.errorMessage.value,
          snackPosition: SnackPosition.TOP,
          backgroundColor: RealTimeColors.error,
          colorText: Colors.white,
          duration: const Duration(seconds: 3),
        );
      }
    } catch (e) {
      Get.back(); // Close loading
      Get.snackbar(
        'Error',
        'Failed to place bid: ${e.toString()}',
        snackPosition: SnackPosition.TOP,
        backgroundColor: RealTimeColors.error,
        colorText: Colors.white,
        duration: const Duration(seconds: 3),
      );
    }
  }

  /// OPEN BID PLACEMENT DIALOG
  static void openBidDialog({
    required BuildContext context,
    required Auction auction,
  }) {
    final currentBidAmount = auction.winningBidAmount ?? auction.startingBid;

    Get.dialog(
      BidPlacementDialog(
        auctionTitle: auction.asset.title,
        currentBid: currentBidAmount,
        reservePrice: auction.reservePrice,
        startingBid: auction.startingBid,
        onPlaceBid: (newAmount) {
          placeBid(
            context: context,
            auctionId: auction.id,
            amount: newAmount,
            auctionTitle: auction.asset.title,
          );
        },
      ),
      barrierDismissible: true,
    );
  }
}
