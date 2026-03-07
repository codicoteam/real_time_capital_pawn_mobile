import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:real_time_pawn/core/utils/logs.dart';
import '../../../config/api_config/api_keys.dart';
import '../../../core/utils/api_response.dart';
import '../../../core/utils/shared_pref_methods.dart';

class HomeService {
  /// GET HOME DATA FOR AUTHENTICATED USER
  static Future<APIResponse<Map<String, dynamic>>> getHomeData() async {
    final token = await CacheUtils.checkToken();

    if (token == null || token.isEmpty) {
      DevLogs.logError('No authentication token found');
      return APIResponse(
        success: false,
        message: 'Authentication required',
        data: null,
      );
    }

    var headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };

    var request = http.Request('GET', Uri.parse('${ApiKeys.baseUrl}/home'));

    request.headers.addAll(headers);

    try {
      final response = await request.send();
      final responseBody = await response.stream.bytesToString();

      DevLogs.logInfo('Home data response status: ${response.statusCode}');
      DevLogs.logInfo('Home data response body: $responseBody');

      final responseData = json.decode(responseBody);

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final success = responseData['success'] ?? false;
        final message =
            responseData['message'] ?? 'Home data retrieved successfully';
        final data = responseData['data'] as Map<String, dynamic>? ?? {};

        DevLogs.logSuccess('Home data retrieved: $message');

        return APIResponse(success: success, message: message, data: data);
      } else {
        final errorMessage =
            responseData['message'] ?? 'Failed to load home data';
        DevLogs.logError('Home data error: $errorMessage');

        return APIResponse(success: false, message: errorMessage, data: null);
      }
    } catch (e) {
      DevLogs.logError('Error fetching home data: $e');
      return APIResponse(
        success: false,
        message: 'An error occurred: $e',
        data: null,
      );
    }
  }

  /// GET CUSTOMER DASHBOARD FOR STAFF (if needed)
  static Future<APIResponse<Map<String, dynamic>>> getCustomerDashboard({
    required String userId,
  }) async {
    final token = await CacheUtils.checkToken();

    if (token == null || token.isEmpty) {
      DevLogs.logError('No authentication token found');
      return APIResponse(
        success: false,
        message: 'Authentication required',
        data: null,
      );
    }

    var headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };

    var request = http.Request(
      'GET',
      Uri.parse('${ApiKeys.baseUrl}/customer/dashboard/$userId'),
    );

    request.headers.addAll(headers);

    try {
      final response = await request.send();
      final responseBody = await response.stream.bytesToString();

      DevLogs.logInfo(
        'Customer dashboard response status: ${response.statusCode}',
      );
      DevLogs.logInfo('Customer dashboard response body: $responseBody');

      final responseData = json.decode(responseBody);

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final success = responseData['success'] ?? false;
        final message =
            responseData['message'] ?? 'Dashboard data retrieved successfully';
        final data = responseData['data'] as Map<String, dynamic>? ?? {};

        return APIResponse(success: success, message: message, data: data);
      } else {
        final errorMessage =
            responseData['message'] ?? 'Failed to load dashboard data';
        DevLogs.logError('Customer dashboard error: $errorMessage');

        return APIResponse(success: false, message: errorMessage, data: null);
      }
    } catch (e) {
      DevLogs.logError('Error fetching customer dashboard: $e');
      return APIResponse(
        success: false,
        message: 'An error occurred: $e',
        data: null,
      );
    }
  }
}
