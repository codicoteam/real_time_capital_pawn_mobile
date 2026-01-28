import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:real_time_pawn/core/utils/logs.dart';
import 'package:real_time_pawn/models/user_bid_models.dart';
import '../../../../config/api_config/api_keys.dart';
import '../../../../core/utils/api_response.dart';
import '../../../../core/utils/shared_pref_methods.dart';

class DisputeService {
  /// RAISE A DISPUTE ON A BID
  /// POST /api/v1/bids/{id}/dispute
  static Future<APIResponse<BidDispute>> raiseDispute({
    required String bidId,
    required String reason,
  }) async {
    final token = await CacheUtils.checkToken();

    if (token == null || token.isEmpty) {
      return APIResponse<BidDispute>(
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

    final body = json.encode({'reason': reason});

    final uri = Uri.parse('${ApiKeys.baseUrl}/bids/$bidId/dispute');

    DevLogs.logInfo('Raising dispute on bid $bidId');
    DevLogs.logInfo('Request body: $body');

    try {
      final response = await http.post(uri, headers: headers, body: body);
      final responseBody = response.body;
      final responseData = json.decode(responseBody);

      DevLogs.logInfo('Raise dispute response status: ${response.statusCode}');
      DevLogs.logInfo('Raise dispute response body: $responseBody');

      if (response.statusCode >= 200 && response.statusCode < 300) {
        if (responseData['success'] == true) {
          final disputeData = responseData['data'];
          final dispute = BidDispute.fromJson(disputeData);

          DevLogs.logSuccess('Dispute raised successfully');

          return APIResponse<BidDispute>(
            success: true,
            data: dispute,
            message: responseData['message'] ?? 'Dispute raised successfully',
          );
        } else {
          final errorMessage =
              responseData['message'] ?? 'Failed to raise dispute';
          DevLogs.logError('Dispute raise failed: $errorMessage');

          return APIResponse<BidDispute>(
            success: false,
            message: errorMessage,
            data: null,
          );
        }
      } else if (response.statusCode == 400) {
        final errorMessage =
            responseData['message'] ??
            'Invalid dispute data or dispute already exists';

        if (errorMessage.contains('already exists')) {
          return APIResponse<BidDispute>(
            success: false,
            message: 'A dispute already exists for this bid',
            data: null,
          );
        }

        return APIResponse<BidDispute>(
          success: false,
          message: errorMessage,
          data: null,
        );
      } else if (response.statusCode == 401) {
        return APIResponse<BidDispute>(
          success: false,
          message: 'Unauthorized - Please login again',
          data: null,
        );
      } else if (response.statusCode == 403) {
        return APIResponse<BidDispute>(
          success: false,
          message: 'Only the bidder can raise a dispute',
          data: null,
        );
      } else if (response.statusCode == 404) {
        return APIResponse<BidDispute>(
          success: false,
          message: 'Bid not found',
          data: null,
        );
      } else {
        final errorMessage =
            responseData['message'] ?? 'HTTP Error: ${response.statusCode}';
        DevLogs.logError('Dispute raise HTTP error: $errorMessage');

        return APIResponse<BidDispute>(
          success: false,
          message: errorMessage,
          data: null,
        );
      }
    } catch (e) {
      DevLogs.logError('Error raising dispute: $e');
      return APIResponse<BidDispute>(
        success: false,
        message: 'An error occurred while raising dispute: ${e.toString()}',
        data: null,
      );
    }
  }

  /// CANCEL A DISPUTE
  /// DELETE /api/v1/bids/{bidId}/dispute/{disputeId}
  static Future<APIResponse<bool>> cancelDispute({
    required String bidId,
    required String disputeId,
  }) async {
    final token = await CacheUtils.checkToken();

    if (token == null || token.isEmpty) {
      return APIResponse<bool>(
        success: false,
        message: 'Authentication required',
        data: null,
      );
    }

    var headers = {
      'accept': 'application/json',
      'Authorization': 'Bearer $token',
    };

    final uri = Uri.parse('${ApiKeys.baseUrl}/bids/$bidId/dispute/$disputeId');

    DevLogs.logInfo('Cancelling dispute: $uri');

    try {
      final response = await http.delete(uri, headers: headers);
      final responseBody = response.body;
      final responseData = json.decode(responseBody);

      DevLogs.logInfo('Cancel dispute response status: ${response.statusCode}');

      if (response.statusCode >= 200 && response.statusCode < 300) {
        if (responseData['success'] == true) {
          DevLogs.logSuccess('Dispute cancelled successfully');

          return APIResponse<bool>(
            success: true,
            data: true,
            message:
                responseData['message'] ?? 'Dispute cancelled successfully',
          );
        } else {
          final errorMessage =
              responseData['message'] ?? 'Failed to cancel dispute';
          DevLogs.logError('Dispute cancel failed: $errorMessage');

          return APIResponse<bool>(
            success: false,
            message: errorMessage,
            data: null,
          );
        }
      } else if (response.statusCode == 401) {
        return APIResponse<bool>(
          success: false,
          message: 'Unauthorized - Please login again',
          data: null,
        );
      } else if (response.statusCode == 403) {
        return APIResponse<bool>(
          success: false,
          message: 'Only the bidder can cancel a dispute',
          data: null,
        );
      } else if (response.statusCode == 404) {
        return APIResponse<bool>(
          success: false,
          message: 'Dispute not found',
          data: null,
        );
      } else {
        final errorMessage =
            responseData['message'] ?? 'HTTP Error: ${response.statusCode}';
        DevLogs.logError('Dispute cancel HTTP error: $errorMessage');

        return APIResponse<bool>(
          success: false,
          message: errorMessage,
          data: null,
        );
      }
    } catch (e) {
      DevLogs.logError('Error cancelling dispute: $e');
      return APIResponse<bool>(
        success: false,
        message: 'An error occurred while cancelling dispute: ${e.toString()}',
        data: null,
      );
    }
  }

  /// GET DISPUTE DETAILS
  /// GET /api/v1/bids/{bidId}/dispute/{disputeId}
  static Future<APIResponse<BidDispute>> getDisputeDetails({
    required String bidId,
    required String disputeId,
  }) async {
    final token = await CacheUtils.checkToken();

    if (token == null || token.isEmpty) {
      return APIResponse<BidDispute>(
        success: false,
        message: 'Authentication required',
        data: null,
      );
    }

    var headers = {
      'accept': 'application/json',
      'Authorization': 'Bearer $token',
    };

    final uri = Uri.parse('${ApiKeys.baseUrl}/bids/$bidId/dispute/$disputeId');

    DevLogs.logInfo('Fetching dispute details: $uri');

    try {
      final response = await http.get(uri, headers: headers);
      final responseBody = response.body;
      final responseData = json.decode(responseBody);

      DevLogs.logInfo(
        'Dispute details response status: ${response.statusCode}',
      );

      if (response.statusCode >= 200 && response.statusCode < 300) {
        if (responseData['success'] == true) {
          final disputeData = responseData['data'];
          final dispute = BidDispute.fromJson(disputeData);

          DevLogs.logSuccess('Fetched dispute details successfully');

          return APIResponse<BidDispute>(
            success: true,
            data: dispute,
            message:
                responseData['message'] ??
                'Dispute details retrieved successfully',
          );
        } else {
          final errorMessage =
              responseData['message'] ?? 'Failed to fetch dispute details';
          DevLogs.logError('Dispute details fetch failed: $errorMessage');

          return APIResponse<BidDispute>(
            success: false,
            message: errorMessage,
            data: null,
          );
        }
      } else if (response.statusCode == 401) {
        return APIResponse<BidDispute>(
          success: false,
          message: 'Unauthorized - Please login again',
          data: null,
        );
      } else if (response.statusCode == 403) {
        return APIResponse<BidDispute>(
          success: false,
          message: 'Access denied to this dispute',
          data: null,
        );
      } else if (response.statusCode == 404) {
        return APIResponse<BidDispute>(
          success: false,
          message: 'Dispute not found',
          data: null,
        );
      } else {
        final errorMessage =
            responseData['message'] ?? 'HTTP Error: ${response.statusCode}';
        DevLogs.logError('Dispute details HTTP error: $errorMessage');

        return APIResponse<BidDispute>(
          success: false,
          message: errorMessage,
          data: null,
        );
      }
    } catch (e) {
      DevLogs.logError('Error fetching dispute details: $e');
      return APIResponse<BidDispute>(
        success: false,
        message:
            'An error occurred while fetching dispute details: ${e.toString()}',
        data: null,
      );
    }
  }
}
