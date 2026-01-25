// bid_mngmt_service.dart
// lib/features/user_bids/services/user_bids_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:real_time_pawn/core/utils/logs.dart';
import 'package:real_time_pawn/config/api_config/api_keys.dart';
import 'package:real_time_pawn/core/utils/api_response.dart';
import 'package:real_time_pawn/core/utils/shared_pref_methods.dart';
import 'package:real_time_pawn/models/user_bid_models.dart';

import '../../auctions_mngmt/services/auctions_mngmt_service.dart';

class UserBidsService {
  /// GET USER'S BIDDING HISTORY
  static Future<APIResponse<UserBidsResponse>> getUserBiddingHistory({
    required String userId,
    String? status,
    int page = 1,
    int limit = 10,
  }) async {
    final token = await CacheUtils.checkToken();

    if (token == null || token.isEmpty) {
      return APIResponse<UserBidsResponse>(
        success: false,
        message: 'Authentication required',
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
    };

    if (status != null && status.isNotEmpty && status != 'All') {
      params['status'] = status.toLowerCase();
    }

    final uri = Uri.parse(
      '${ApiKeys.baseUrl}/auctions/users/$userId/bids',
    ).replace(queryParameters: params);

    DevLogs.logInfo('Fetching user bidding history: $uri');

    try {
      final response = await http.get(uri, headers: headers);
      final responseBody = response.body;
      final responseData = json.decode(responseBody);

      DevLogs.logInfo('User bids response status: ${response.statusCode}');
      DevLogs.logInfo('User bids response body: $responseBody');

      if (response.statusCode == 403) {
        return APIResponse<UserBidsResponse>(
          success: false,
          message:
              responseData['message'] ??
              'You can only view your own bidding history',
          data: null,
        );
      }

      if (response.statusCode == 401) {
        return APIResponse<UserBidsResponse>(
          success: false,
          message: 'Authentication failed. Please login again.',
          data: null,
        );
      }

      if (response.statusCode >= 200 && response.statusCode < 300) {
        if (responseData['success'] == true) {
          final data = responseData['data'];
          final bids = List<Map<String, dynamic>>.from(
            data['bids'] ?? [],
          ).map((bidJson) => UserBid.fromJson(bidJson)).toList();

          final pagination = Pagination.fromJson(data['pagination'] ?? {});

          final responseObj = UserBidsResponse(
            bids: bids,
            pagination: pagination,
          );

          DevLogs.logSuccess('Fetched ${bids.length} user bids successfully');

          return APIResponse<UserBidsResponse>(
            success: true,
            data: responseObj,
            message:
                responseData['message'] ??
                'Bidding history retrieved successfully',
          );
        } else {
          final errorMessage =
              responseData['message'] ?? 'Failed to fetch bidding history';
          DevLogs.logError('User bids fetch failed: $errorMessage');

          return APIResponse<UserBidsResponse>(
            success: false,
            message: errorMessage,
            data: null,
          );
        }
      } else {
        final errorMessage =
            responseData['message'] ?? 'HTTP Error: ${response.statusCode}';
        DevLogs.logError('User bids HTTP error: $errorMessage');

        return APIResponse<UserBidsResponse>(
          success: false,
          message: errorMessage,
          data: null,
        );
      }
    } catch (e) {
      DevLogs.logError('Error fetching user bidding history: $e');
      return APIResponse<UserBidsResponse>(
        success: false,
        message:
            'An error occurred while fetching bidding history: ${e.toString()}',
        data: null,
      );
    }
  }

  /// GET CURRENT USER'S BIDDING HISTORY
  /// This is the main method to use - it gets the current logged-in user's history
  static Future<APIResponse<UserBidsResponse>> getCurrentUserBiddingHistory({
    String? status,
    int page = 1,
    int limit = 10,
  }) async {
    // First, get the current user's ID from cache/token
    final userId = await CacheUtils.getUserId();

    if (userId == null || userId.isEmpty) {
      return APIResponse<UserBidsResponse>(
        success: false,
        message: 'User not logged in',
        data: null,
      );
    }

    return getUserBiddingHistory(
      userId: userId,
      status: status,
      page: page,
      limit: limit,
    );
  }
}
