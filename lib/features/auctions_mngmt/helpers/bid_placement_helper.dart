// Add to AuctionsHelper class or create a new BidPlacementHelper

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:real_time_pawn/core/utils/pallete.dart';
import 'package:real_time_pawn/features/auctions_mngmt/controllers/auctions_mngmt_controller.dart';
import 'package:real_time_pawn/features/auctions_mngmt/services/bid_placement_service.dart';
import 'package:real_time_pawn/features/bid_mngmt/helpers/bid_mngmt_helper.dart';
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
      final response = await BidPlacementService.placeBid(
        auctionId: auctionId,
        amount: amount,
      );

      Get.back(); // Close loading

      if (response.success && response.data != null) {
        // Show success
        Get.snackbar(
          'Bid Placed!',
          'Your bid of \$${amount.toStringAsFixed(2)} on "$auctionTitle" has been placed successfully',
          snackPosition: SnackPosition.TOP,
          backgroundColor: RealTimeColors.success,
          colorText: Colors.white,
          duration: 3.seconds,
        );

        // Trigger refresh if needed
        Get.find<AuctionsController>().refreshAuctions();
      } else {
        Get.snackbar(
          'Bid Failed',
          response.message ?? 'Failed to place bid',
          snackPosition: SnackPosition.TOP,
          backgroundColor: RealTimeColors.error,
          colorText: Colors.white,
          duration: 3.seconds,
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
        duration: 3.seconds,
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
        auction: auction,
        currentBidAmount: currentBidAmount,
        onBidPlaced: (newAmount) {
          // Could trigger refresh of auction list
          Get.find<AuctionsController>().refreshAuctions();
        },
      ),
      barrierDismissible: true,
    );
  }
}
