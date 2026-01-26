// lib/features/auctions_mngmt/services/bid_placement_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:real_time_pawn/core/utils/logs.dart';
import 'package:real_time_pawn/models/auction_models.dart';
import '../../../../config/api_config/api_keys.dart';
import '../../../../core/utils/api_response.dart';
import '../../../../core/utils/shared_pref_methods.dart';

class BidPlacementService {
  /// PLACE A BID ON AN AUCTION
  static Future<APIResponse<Bid>> placeBid({
    required String auctionId,
    required double amount,
  }) async {
    final token = await CacheUtils.checkToken();

    if (token == null || token.isEmpty) {
      return APIResponse<Bid>(
        success: false,
        message: 'Authentication required',
        data: null,
      );
    }

    var headers = {
      'accept': 'application/json',
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
    };

    final body = json.encode({'amount': amount});

    final uri = Uri.parse('${ApiKeys.baseUrl}/auctions/$auctionId/bids');

    DevLogs.logInfo('Placing bid on auction $auctionId: $amount');
    DevLogs.logInfo('Request body: $body');

    try {
      final response = await http.post(uri, headers: headers, body: body);
      final responseBody = response.body;
      final responseData = json.decode(responseBody);

      DevLogs.logInfo('Place bid response status: ${response.statusCode}');
      DevLogs.logInfo('Place bid response body: $responseBody');

      if (response.statusCode == 201) {
        if (responseData['success'] == true) {
          final bidData = responseData['data'];
          final bid = Bid.fromJson(bidData);

          DevLogs.logSuccess('Bid placed successfully: \$${bid.amount}');

          return APIResponse<Bid>(
            success: true,
            data: bid,
            message: responseData['message'] ?? 'Bid placed successfully',
          );
        } else {
          final errorMessage = responseData['message'] ?? 'Failed to place bid';
          DevLogs.logError('Bid placement failed: $errorMessage');

          return APIResponse<Bid>(
            success: false,
            message: errorMessage,
            data: null,
          );
        }
      } else if (response.statusCode == 400) {
        // Handle specific 400 errors
        final errorMessage =
            responseData['message'] ??
            'Invalid bid amount or auction not eligible';

        // Check for specific error messages
        if (errorMessage.contains('not live')) {
          return APIResponse<Bid>(
            success: false,
            message: 'This auction is not live',
            data: null,
          );
        } else if (errorMessage.contains('lower than current')) {
          return APIResponse<Bid>(
            success: false,
            message: 'Bid amount must be higher than current bid',
            data: null,
          );
        } else if (errorMessage.contains('own asset')) {
          return APIResponse<Bid>(
            success: false,
            message: 'You cannot bid on your own auction',
            data: null,
          );
        } else if (errorMessage.contains('dispute')) {
          return APIResponse<Bid>(
            success: false,
            message: 'You have a pending dispute on this auction',
            data: null,
          );
        }

        return APIResponse<Bid>(
          success: false,
          message: errorMessage,
          data: null,
        );
      } else if (response.statusCode == 401) {
        return APIResponse<Bid>(
          success: false,
          message: 'Unauthorized - Please login again',
          data: null,
        );
      } else if (response.statusCode == 403) {
        return APIResponse<Bid>(
          success: false,
          message: responseData['message'] ?? 'You cannot bid on this auction',
          data: null,
        );
      } else if (response.statusCode == 404) {
        return APIResponse<Bid>(
          success: false,
          message: 'Auction not found',
          data: null,
        );
      } else {
        final errorMessage =
            responseData['message'] ?? 'HTTP Error: ${response.statusCode}';
        DevLogs.logError('Bid placement HTTP error: $errorMessage');

        return APIResponse<Bid>(
          success: false,
          message: errorMessage,
          data: null,
        );
      }
    } catch (e) {
      DevLogs.logError('Error placing bid: $e');
      return APIResponse<Bid>(
        success: false,
        message: 'An error occurred while placing bid: ${e.toString()}',
        data: null,
      );
    }
  }

  /// VALIDATE BID AMOUNT
  static String? validateBidAmount({
    required double currentBidAmount,
    required double newBidAmount,
    double? reservePrice,
    double startingBid = 0,
  }) {
    // Check if bid is higher than current bid
    if (newBidAmount <= currentBidAmount) {
      return 'Bid must be higher than current bid (\$${currentBidAmount.toStringAsFixed(2)})';
    }

    // Check if bid is at least starting bid
    if (newBidAmount < startingBid) {
      return 'Bid must be at least the starting bid (\$${startingBid.toStringAsFixed(2)})';
    }

    // Check if meets reserve price (if set)
    if (reservePrice != null &&
        reservePrice > 0 &&
        newBidAmount < reservePrice) {
      return 'Bid must meet or exceed reserve price (\$${reservePrice.toStringAsFixed(2)})';
    }

    // Check for reasonable increment (optional)
    final minIncrement = (currentBidAmount * 0.05).clamp(
      1,
      100,
    ); // 5% minimum increment
    if (newBidAmount - currentBidAmount < minIncrement) {
      return 'Minimum bid increment is \$${minIncrement.toStringAsFixed(2)}';
    }

    return null;
  }

  /// FORMAT CURRENCY FOR DISPLAY
  static String formatCurrency(double amount) {
    if (amount >= 1000) {
      return '\$${(amount / 1000).toStringAsFixed(1)}k';
    }
    return '\$${amount.toStringAsFixed(2)}';
  }
}
