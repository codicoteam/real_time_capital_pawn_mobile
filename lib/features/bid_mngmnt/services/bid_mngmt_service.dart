import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:real_time_pawn/core/utils/logs.dart';
import 'package:real_time_pawn/models/user_bid_models.dart';
import '../../../../config/api_config/api_keys.dart';
import '../../../../core/utils/api_response.dart';
import '../../../../core/utils/shared_pref_methods.dart';

class BidManagementService {
  /// GET USER'S BIDS
  /// GET /api/v1/bids/user/{userId}
  static Future<APIResponse<List<UserBid>>> getUserBids({
    String? userId,
    int page = 1,
    int limit = 10,
    String? status,
    String? sortBy = 'placed_at',
    String? sortOrder = 'desc',
  }) async {
    final token = await CacheUtils.checkToken();

    if (token == null || token.isEmpty) {
      return APIResponse<List<UserBid>>(
        success: false,
        message: 'Authentication required',
        data: null,
      );
    }

    // Get current user ID from token if not provided
    final currentUserId = userId ?? await _getCurrentUserIdFromToken();
    if (currentUserId.isEmpty) {
      return APIResponse<List<UserBid>>(
        success: false,
        message: 'User ID not found',
        data: null,
      );
    }

    var headers = {
      'accept': 'application/json',
      'Authorization': 'Bearer $token',
    };

    // Build query parameters
    final params = <String, String>{
      'page': page.toString(),
      'limit': limit.toString(),
      'sort_by': sortBy!,
      'sort_order': sortOrder!,
    };

    if (status != null && status.isNotEmpty && status != 'All') {
      params['status'] = status.toLowerCase();
    }

    final uri = Uri.parse(
      '${ApiKeys.baseUrl}/bids/user/$currentUserId',
    ).replace(queryParameters: params);

    DevLogs.logInfo('Fetching user bids: $uri');

    try {
      final response = await http.get(uri, headers: headers);
      final responseBody = response.body;
      final responseData = json.decode(responseBody);

      DevLogs.logInfo('User bids response status: ${response.statusCode}');
      DevLogs.logInfo('User bids response body: $responseBody');

      if (response.statusCode == 403) {
        return APIResponse<List<UserBid>>(
          success: false,
          message: 'You can only view your own bids',
          data: null,
        );
      }

      if (response.statusCode >= 200 && response.statusCode < 300) {
        if (responseData['success'] == true) {
          // Handle both response formats
          final data = responseData['data'];
          List<UserBid> bids = [];

          if (data is List) {
            // Direct array response
            bids = List<Map<String, dynamic>>.from(
              data,
            ).map((bidJson) => UserBid.fromJson(bidJson)).toList();
          } else if (data is Map) {
            // Paginated response
            final bidsList = List<Map<String, dynamic>>.from(
              data['bids'] ?? [],
            );
            bids = bidsList
                .map((bidJson) => UserBid.fromJson(bidJson))
                .toList();
          }

          DevLogs.logSuccess('Fetched ${bids.length} user bids successfully');

          return APIResponse<List<UserBid>>(
            success: true,
            data: bids,
            message: responseData['message'] ?? 'Bids retrieved successfully',
          );
        } else {
          final errorMessage =
              responseData['message'] ?? 'Failed to fetch bids';
          DevLogs.logError('User bids fetch failed: $errorMessage');

          return APIResponse<List<UserBid>>(
            success: false,
            message: errorMessage,
            data: null,
          );
        }
      } else if (response.statusCode == 401) {
        return APIResponse<List<UserBid>>(
          success: false,
          message: 'Unauthorized - Please login again',
          data: null,
        );
      } else {
        final errorMessage =
            responseData['message'] ?? 'HTTP Error: ${response.statusCode}';
        DevLogs.logError('User bids HTTP error: $errorMessage');

        return APIResponse<List<UserBid>>(
          success: false,
          message: errorMessage,
          data: null,
        );
      }
    } catch (e) {
      DevLogs.logError('Error fetching user bids: $e');
      return APIResponse<List<UserBid>>(
        success: false,
        message: 'An error occurred while fetching bids: ${e.toString()}',
        data: null,
      );
    }
  }

  /// GET BID DETAILS
  /// GET /api/v1/bids/{id}
  static Future<APIResponse<UserBid>> getBidDetails({
    required String bidId,
  }) async {
    final token = await CacheUtils.checkToken();

    if (token == null || token.isEmpty) {
      return APIResponse<UserBid>(
        success: false,
        message: 'Authentication required',
        data: null,
      );
    }

    var headers = {
      'accept': 'application/json',
      'Authorization': 'Bearer $token',
    };

    final uri = Uri.parse('${ApiKeys.baseUrl}/bids/$bidId');

    DevLogs.logInfo('Fetching bid details: $uri');

    try {
      final response = await http.get(uri, headers: headers);
      final responseBody = response.body;
      final responseData = json.decode(responseBody);

      DevLogs.logInfo('Bid details response status: ${response.statusCode}');

      if (response.statusCode >= 200 && response.statusCode < 300) {
        if (responseData['success'] == true) {
          final bidData = responseData['data'];
          final bid = UserBid.fromJson(bidData);

          DevLogs.logSuccess('Fetched bid details successfully');

          return APIResponse<UserBid>(
            success: true,
            data: bid,
            message:
                responseData['message'] ?? 'Bid details retrieved successfully',
          );
        } else {
          final errorMessage =
              responseData['message'] ?? 'Failed to fetch bid details';
          DevLogs.logError('Bid details fetch failed: $errorMessage');

          return APIResponse<UserBid>(
            success: false,
            message: errorMessage,
            data: null,
          );
        }
      } else if (response.statusCode == 403) {
        return APIResponse<UserBid>(
          success: false,
          message: 'Access denied to this bid',
          data: null,
        );
      } else if (response.statusCode == 404) {
        return APIResponse<UserBid>(
          success: false,
          message: 'Bid not found',
          data: null,
        );
      } else if (response.statusCode == 401) {
        return APIResponse<UserBid>(
          success: false,
          message: 'Unauthorized - Please login again',
          data: null,
        );
      } else {
        final errorMessage =
            responseData['message'] ?? 'HTTP Error: ${response.statusCode}';
        DevLogs.logError('Bid details HTTP error: $errorMessage');

        return APIResponse<UserBid>(
          success: false,
          message: errorMessage,
          data: null,
        );
      }
    } catch (e) {
      DevLogs.logError('Error fetching bid details: $e');
      return APIResponse<UserBid>(
        success: false,
        message:
            'An error occurred while fetching bid details: ${e.toString()}',
        data: null,
      );
    }
  }

  /// Helper method to get current user ID from token
  /// Helper method to get current user ID from token
  static Future<String> _getCurrentUserIdFromToken() async {
    try {
      // First try to get user ID from cache
      final cachedUserId = await CacheUtils.getUserId();
      if (cachedUserId != null && cachedUserId.isNotEmpty) {
        return cachedUserId;
      }

      // If not in cache, try to decode from token
      final token = await CacheUtils.checkToken();
      if (token == null || token.isEmpty) {
        return '';
      }

      // Decode JWT token to get user ID
      // JWT format: header.payload.signature
      final parts = token.split('.');
      if (parts.length != 3) {
        return '';
      }

      // Decode the payload (middle part)
      final payload = parts[1];

      // Add padding for base64 decode
      var normalizedPayload = payload;
      while (normalizedPayload.length % 4 != 0) {
        normalizedPayload += '=';
      }

      // Decode base64
      final decodedPayload = utf8.decode(base64Url.decode(normalizedPayload));

      // Parse JSON
      final payloadMap = json.decode(decodedPayload);

      // Extract user ID - check different possible field names
      final userId =
          payloadMap['userId'] ??
          payloadMap['user_id'] ??
          payloadMap['userID'] ??
          payloadMap['sub'] ??
          payloadMap['id'] ??
          '';

      // Store in cache for future use
      if (userId.isNotEmpty) {
        await CacheUtils.storeUserId(userId: userId.toString());
      }

      return userId.toString();
    } catch (e) {
      DevLogs.logError('Error getting user ID from token: $e');
      return '';
    }
  }

  /// Format currency for display
  static String formatCurrency(double amount, [String currency = 'USD']) {
    if (amount >= 1000) {
      return '\$${(amount / 1000).toStringAsFixed(1)}k';
    }
    return '\$${amount.toStringAsFixed(2)}';
  }

  /// Get bid status text (based on UserBid data)
  static String getBidStatusText(UserBid bid) {
    final auctionStatus = bid.auction.status.toLowerCase();

    if (auctionStatus == 'live') {
      if (bid.auction.winningBidAmount == bid.amount) {
        return 'WINNING';
      } else {
        return 'ACTIVE';
      }
    } else if (auctionStatus == 'closed') {
      if (bid.auction.winnerUser != null &&
          bid.auction.winnerUser?.id == bid.bidder.id) {
        return 'WON';
      } else {
        return 'OUTBID';
      }
    }
    return 'PENDING';
  }

  /// Get dispute status text
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

  /// Get payment status text
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
}
