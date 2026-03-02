// lib/features/loan_terms_mngmt/services/loan_terms_mngmt_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:real_time_pawn/config/api_config/api_keys.dart';
import 'package:real_time_pawn/core/utils/api_response.dart';
import 'package:real_time_pawn/core/utils/logs.dart';
import 'package:real_time_pawn/core/utils/shared_pref_methods.dart';
import 'package:real_time_pawn/models/loan_terms_model.dart';

class LoanTermsService {
  /// GET loan terms by loan ID (only API we use)
  static Future<APIResponse<List<LoanTerm>>> getLoanTermsByLoanId(
    String loanId, {
    int page = 1,
    int limit = 100,
  }) async {
    final token = await CacheUtils.checkToken();

    if (token == null || token.isEmpty) {
      return APIResponse<List<LoanTerm>>(
        success: false,
        message: 'Authentication required',
        data: null,
      );
    }

    var headers = {
      'accept': 'application/json',
      'Authorization': 'Bearer $token',
    };

    final uri = Uri.parse('${ApiKeys.baseUrl}/loan-terms/loan/$loanId').replace(
      queryParameters: {'page': page.toString(), 'limit': limit.toString()},
    );

    DevLogs.logInfo('Fetching loan terms: $uri');

    try {
      final response = await http.get(uri, headers: headers);
      final responseBody = response.body;
      final responseData = json.decode(responseBody);

      DevLogs.logInfo('Response status: ${response.statusCode}');

      DevLogs.logInfo('Response body: $responseBody');
      if (response.statusCode == 401) {
        return APIResponse<List<LoanTerm>>(
          success: false,
          message: 'Authentication failed. Please login again.',
          data: null,
        );
      }

      if (response.statusCode == 403) {
        return APIResponse<List<LoanTerm>>(
          success: false,
          message: 'You are not authorized to view these terms',
          data: null,
        );
      }

      if (response.statusCode == 404) {
        return APIResponse<List<LoanTerm>>(
          success: false,
          message: 'Loan not found',
          data: null,
        );
      }

      if (response.statusCode >= 200 && response.statusCode < 300) {
        if (responseData['success'] == true) {
          final data = responseData['data'];
          final loanTermsJson = data['loanTerms'] as List?;

          if (loanTermsJson == null) {
            return APIResponse<List<LoanTerm>>(
              success: false,
              message: 'Invalid response format',
              data: null,
            );
          }

          try {
            final terms = loanTermsJson
                .map((item) => LoanTerm.fromMap(item as Map<String, dynamic>))
                .toList();

            DevLogs.logSuccess('Fetched ${terms.length} terms');

            return APIResponse<List<LoanTerm>>(
              success: true,
              data: terms,
              message:
                  responseData['message'] ?? 'Terms retrieved successfully',
            );
          } catch (e) {
            DevLogs.logError('Error parsing terms: $e');
            return APIResponse<List<LoanTerm>>(
              success: false,
              message: 'Error parsing term data',
              data: null,
            );
          }
        } else {
          return APIResponse<List<LoanTerm>>(
            success: false,
            message: responseData['message'] ?? 'Failed to fetch terms',
            data: null,
          );
        }
      } else {
        return APIResponse<List<LoanTerm>>(
          success: false,
          message: 'HTTP Error: ${response.statusCode}',
          data: null,
        );
      }
    } catch (e) {
      DevLogs.logError('Error fetching terms: $e');
      return APIResponse<List<LoanTerm>>(
        success: false,
        message: 'An error occurred: ${e.toString()}',
        data: null,
      );
    }
  }

  /// GET loan term by ID (only API we use)
  static Future<APIResponse<LoanTerm>> getTermById(String termId) async {
    final token = await CacheUtils.checkToken();

    if (token == null || token.isEmpty) {
      return APIResponse<LoanTerm>(
        success: false,
        message: 'Authentication required',
        data: null,
      );
    }

    var headers = {
      'accept': 'application/json',
      'Authorization': 'Bearer $token',
    };

    final uri = Uri.parse('${ApiKeys.baseUrl}/loan-terms/$termId');

    DevLogs.logInfo('Fetching term details: $uri');

    try {
      final response = await http.get(uri, headers: headers);
      final responseBody = response.body;
      final responseData = json.decode(responseBody);

      DevLogs.logInfo('Response status: ${response.statusCode}');

      if (response.statusCode == 401) {
        return APIResponse<LoanTerm>(
          success: false,
          message: 'Authentication failed. Please login again.',
          data: null,
        );
      }

      if (response.statusCode == 403) {
        return APIResponse<LoanTerm>(
          success: false,
          message: 'You are not authorized to view this term',
          data: null,
        );
      }

      if (response.statusCode == 404) {
        return APIResponse<LoanTerm>(
          success: false,
          message: 'Loan term not found',
          data: null,
        );
      }

      if (response.statusCode >= 200 && response.statusCode < 300) {
        if (responseData['success'] == true) {
          final data = responseData['data'];
          final term = LoanTerm.fromMap(data);

          DevLogs.logSuccess('Term details fetched successfully');

          return APIResponse<LoanTerm>(
            success: true,
            data: term,
            message: responseData['message'] ?? 'Term retrieved successfully',
          );
        } else {
          return APIResponse<LoanTerm>(
            success: false,
            message: responseData['message'] ?? 'Failed to fetch term',
            data: null,
          );
        }
      } else {
        return APIResponse<LoanTerm>(
          success: false,
          message: 'HTTP Error: ${response.statusCode}',
          data: null,
        );
      }
    } catch (e) {
      DevLogs.logError('Error fetching term: $e');
      return APIResponse<LoanTerm>(
        success: false,
        message: 'An error occurred: ${e.toString()}',
        data: null,
      );
    }
  }
}
