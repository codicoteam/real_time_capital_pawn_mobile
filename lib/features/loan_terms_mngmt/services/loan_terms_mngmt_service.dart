// loan_terms_mngmt_service.dart
// lib/features/loan_terms_mngmt/services/loan_terms_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:real_time_pawn/core/utils/logs.dart';
import 'package:real_time_pawn/config/api_config/api_keys.dart';
import 'package:real_time_pawn/core/utils/api_response.dart';
import 'package:real_time_pawn/core/utils/shared_pref_methods.dart';
import 'package:real_time_pawn/models/loan_terms_model.dart';

class LoanTermsService {
  /// GET /api/v1/loan-terms/loan/{loanId} - Get all loan terms for a loan
  static Future<APIResponse<List<LoanTerm>>> getLoanTermsByLoanId(
    String loanId, {
    int page = 1,
    int limit = 10,
    String? status,
    String? termType,
  }) async {
    final token = await CacheUtils.checkToken();
    if (token == null) {
      return APIResponse(
        success: false,
        message: 'Authentication required',
        data: null,
      );
    }

    try {
      // Build query parameters
      final Map<String, String> queryParams = {
        'page': page.toString(),
        'limit': limit.toString(),
      };
      if (status != null && status.isNotEmpty && status != 'All') {
        queryParams['status'] = status;
      }
      if (termType != null && termType.isNotEmpty && termType != 'All') {
        queryParams['term_type'] = termType;
      }

      final queryString = Uri(queryParameters: queryParams).query;
      final url = '${ApiKeys.baseUrl}/loan-terms/loan/$loanId?$queryString';

      DevLogs.logInfo('Fetching loan terms for loan: $loanId');
      DevLogs.logInfo('URL: $url');

      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      DevLogs.logInfo('Response status: ${response.statusCode}');
      DevLogs.logInfo('Response body: ${response.body}');

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final responseData = json.decode(response.body);

        if (responseData['success'] == true) {
          final data = responseData['data'];
          if (data is Map && data['terms'] != null) {
            final terms = List<LoanTerm>.from(
              data['terms'].map((x) => LoanTerm.fromMap(x)),
            );
            return APIResponse<List<LoanTerm>>(
              success: true,
              message:
                  responseData['message'] ?? 'Loan terms fetched successfully',
              data: terms,
            );
          }
        }

        return APIResponse<List<LoanTerm>>(
          success: false,
          message: responseData['message'] ?? 'No loan terms found',
          data: [],
        );
      } else {
        final errorData = json.decode(response.body);
        return APIResponse<List<LoanTerm>>(
          success: false,
          message: errorData['message'] ?? 'Failed to fetch loan terms',
          data: null,
        );
      }
    } catch (e) {
      DevLogs.logError('Error fetching loan terms: $e');
      return APIResponse<List<LoanTerm>>(
        success: false,
        message: 'An error occurred: ${e.toString()}',
        data: null,
      );
    }
  }

  /// GET /api/v1/loan-terms/loan/{loanId}/current - Get current active term
  static Future<APIResponse<LoanTerm>> getCurrentTerm(String loanId) async {
    final token = await CacheUtils.checkToken();
    if (token == null) {
      return APIResponse(
        success: false,
        message: 'Authentication required',
        data: null,
      );
    }

    try {
      final url = '${ApiKeys.baseUrl}/loan-terms/loan/$loanId/current';

      DevLogs.logInfo('Fetching current term for loan: $loanId');
      DevLogs.logInfo('URL: $url');

      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      DevLogs.logInfo('Response status: ${response.statusCode}');
      DevLogs.logInfo('Response body: ${response.body}');

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final responseData = json.decode(response.body);

        if (responseData['success'] == true && responseData['data'] != null) {
          final term = LoanTerm.fromMap(responseData['data']);
          return APIResponse<LoanTerm>(
            success: true,
            message:
                responseData['message'] ?? 'Current term fetched successfully',
            data: term,
          );
        }

        return APIResponse<LoanTerm>(
          success: false,
          message: responseData['message'] ?? 'No active term found',
          data: null,
        );
      } else {
        final errorData = json.decode(response.body);
        return APIResponse<LoanTerm>(
          success: false,
          message: errorData['message'] ?? 'Failed to fetch current term',
          data: null,
        );
      }
    } catch (e) {
      DevLogs.logError('Error fetching current term: $e');
      return APIResponse<LoanTerm>(
        success: false,
        message: 'An error occurred: ${e.toString()}',
        data: null,
      );
    }
  }

  /// GET /api/v1/loan-terms/loan/{loanId}/timeline - Get loan term timeline
  static Future<APIResponse<LoanTermTimeline>> getTermTimeline(
    String loanId,
  ) async {
    final token = await CacheUtils.checkToken();
    if (token == null) {
      return APIResponse(
        success: false,
        message: 'Authentication required',
        data: null,
      );
    }

    try {
      final url = '${ApiKeys.baseUrl}/loan-terms/loan/$loanId/timeline';

      DevLogs.logInfo('Fetching timeline for loan: $loanId');
      DevLogs.logInfo('URL: $url');

      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      DevLogs.logInfo('Response status: ${response.statusCode}');
      DevLogs.logInfo('Response body: ${response.body}');

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final responseData = json.decode(response.body);

        if (responseData['success'] == true && responseData['data'] != null) {
          final timeline = LoanTermTimeline.fromMap(responseData['data']);
          return APIResponse<LoanTermTimeline>(
            success: true,
            message: responseData['message'] ?? 'Timeline fetched successfully',
            data: timeline,
          );
        }

        return APIResponse<LoanTermTimeline>(
          success: false,
          message: responseData['message'] ?? 'No timeline data found',
          data: null,
        );
      } else {
        final errorData = json.decode(response.body);
        return APIResponse<LoanTermTimeline>(
          success: false,
          message: errorData['message'] ?? 'Failed to fetch timeline',
          data: null,
        );
      }
    } catch (e) {
      DevLogs.logError('Error fetching timeline: $e');
      return APIResponse<LoanTermTimeline>(
        success: false,
        message: 'An error occurred: ${e.toString()}',
        data: null,
      );
    }
  }

  /// GET /api/v1/loan-terms/{id} - Get term by ID
  static Future<APIResponse<LoanTerm>> getTermById(String termId) async {
    final token = await CacheUtils.checkToken();
    if (token == null) {
      return APIResponse(
        success: false,
        message: 'Authentication required',
        data: null,
      );
    }

    try {
      final url = '${ApiKeys.baseUrl}/loan-terms/$termId';

      DevLogs.logInfo('Fetching term details: $termId');
      DevLogs.logInfo('URL: $url');

      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      DevLogs.logInfo('Response status: ${response.statusCode}');
      DevLogs.logInfo('Response body: ${response.body}');

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final responseData = json.decode(response.body);

        if (responseData['success'] == true && responseData['data'] != null) {
          final term = LoanTerm.fromMap(responseData['data']);
          return APIResponse<LoanTerm>(
            success: true,
            message:
                responseData['message'] ?? 'Term details fetched successfully',
            data: term,
          );
        }

        return APIResponse<LoanTerm>(
          success: false,
          message: responseData['message'] ?? 'Term not found',
          data: null,
        );
      } else {
        final errorData = json.decode(response.body);
        return APIResponse<LoanTerm>(
          success: false,
          message: errorData['message'] ?? 'Failed to fetch term details',
          data: null,
        );
      }
    } catch (e) {
      DevLogs.logError('Error fetching term details: $e');
      return APIResponse<LoanTerm>(
        success: false,
        message: 'An error occurred: ${e.toString()}',
        data: null,
      );
    }
  }

  /// POST /api/v1/loan-terms/loan/{loanId}/renew - Request loan renewal
  static Future<APIResponse<LoanTerm>> requestLoanRenewal(
    RenewalRequest request,
  ) async {
    final token = await CacheUtils.checkToken();
    if (token == null) {
      return APIResponse(
        success: false,
        message: 'Authentication required',
        data: null,
      );
    }

    try {
      final url = '${ApiKeys.baseUrl}/loan-terms/loan/${request.loanId}/renew';

      DevLogs.logInfo('Requesting loan renewal for loan: ${request.loanId}');
      DevLogs.logInfo('URL: $url');
      DevLogs.logInfo('Request payload: ${request.toMap()}');

      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode(request.toMap()),
      );

      DevLogs.logInfo('Response status: ${response.statusCode}');
      DevLogs.logInfo('Response body: ${response.body}');

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final responseData = json.decode(response.body);

        if (responseData['success'] == true && responseData['data'] != null) {
          final term = LoanTerm.fromMap(responseData['data']);
          return APIResponse<LoanTerm>(
            success: true,
            message:
                responseData['message'] ??
                'Renewal request submitted successfully',
            data: term,
          );
        }

        return APIResponse<LoanTerm>(
          success: false,
          message:
              responseData['message'] ?? 'Failed to submit renewal request',
          data: null,
        );
      } else {
        final errorData = json.decode(response.body);
        return APIResponse<LoanTerm>(
          success: false,
          message: errorData['message'] ?? 'Failed to submit renewal request',
          data: null,
        );
      }
    } catch (e) {
      DevLogs.logError('Error submitting renewal request: $e');
      return APIResponse<LoanTerm>(
        success: false,
        message: 'An error occurred: ${e.toString()}',
        data: null,
      );
    }
  }

  /// GET /api/v1/loan-terms/stats - Get loan term statistics
  static Future<APIResponse<LoanTermStats>> getTermStats({
    String? loanId,
  }) async {
    final token = await CacheUtils.checkToken();
    if (token == null) {
      return APIResponse(
        success: false,
        message: 'Authentication required',
        data: null,
      );
    }

    try {
      final url = loanId != null
          ? '${ApiKeys.baseUrl}/loan-terms/stats?loan_id=$loanId'
          : '${ApiKeys.baseUrl}/loan-terms/stats';

      DevLogs.logInfo('Fetching loan term statistics');
      DevLogs.logInfo('URL: $url');

      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      DevLogs.logInfo('Response status: ${response.statusCode}');
      DevLogs.logInfo('Response body: ${response.body}');

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final responseData = json.decode(response.body);

        if (responseData['success'] == true && responseData['data'] != null) {
          final stats = LoanTermStats.fromMap(responseData['data']);
          return APIResponse<LoanTermStats>(
            success: true,
            message:
                responseData['message'] ?? 'Statistics fetched successfully',
            data: stats,
          );
        }

        return APIResponse<LoanTermStats>(
          success: false,
          message: responseData['message'] ?? 'No statistics available',
          data: null,
        );
      } else {
        final errorData = json.decode(response.body);
        return APIResponse<LoanTermStats>(
          success: false,
          message: errorData['message'] ?? 'Failed to fetch statistics',
          data: null,
        );
      }
    } catch (e) {
      DevLogs.logError('Error fetching statistics: $e');
      return APIResponse<LoanTermStats>(
        success: false,
        message: 'An error occurred: ${e.toString()}',
        data: null,
      );
    }
  }

  /// GET /api/v1/loan-terms/loan/{loanId}/next-term - Get next term number
  static Future<APIResponse<Map<String, dynamic>>> getNextTermNumber(
    String loanId,
  ) async {
    final token = await CacheUtils.checkToken();
    if (token == null) {
      return APIResponse(
        success: false,
        message: 'Authentication required',
        data: null,
      );
    }

    try {
      final url = '${ApiKeys.baseUrl}/loan-terms/loan/$loanId/next-term';

      DevLogs.logInfo('Fetching next term number for loan: $loanId');
      DevLogs.logInfo('URL: $url');

      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      DevLogs.logInfo('Response status: ${response.statusCode}');
      DevLogs.logInfo('Response body: ${response.body}');

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final responseData = json.decode(response.body);
        return APIResponse<Map<String, dynamic>>(
          success: true,
          message: responseData['message'] ?? 'Next term number fetched',
          data: responseData['data'],
        );
      } else {
        final errorData = json.decode(response.body);
        return APIResponse<Map<String, dynamic>>(
          success: false,
          message: errorData['message'] ?? 'Failed to fetch next term number',
          data: null,
        );
      }
    } catch (e) {
      DevLogs.logError('Error fetching next term number: $e');
      return APIResponse<Map<String, dynamic>>(
        success: false,
        message: 'An error occurred: ${e.toString()}',
        data: null,
      );
    }
  }
}
