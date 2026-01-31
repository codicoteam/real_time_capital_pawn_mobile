import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:real_time_pawn/core/utils/logs.dart';
import 'package:real_time_pawn/config/api_config/api_keys.dart';
import 'package:real_time_pawn/core/utils/api_response.dart';
import 'package:real_time_pawn/core/utils/shared_pref_methods.dart';
import 'package:real_time_pawn/models/loan_mngmt_model.dart';

class LoanService {
  /// GET CUSTOMER'S LOANS
  static Future<APIResponse<LoansResponse>> getCustomerLoans({
    int page = 1,
    int limit = 10,
    String? status,
  }) async {
    final token = await CacheUtils.checkToken();

    if (token == null || token.isEmpty) {
      return APIResponse<LoansResponse>(
        success: false,
        message: 'Authentication required',
        data: null,
      );
    }

    // Get current user ID from cache
    final userId = await CacheUtils.getUserId();

    if (userId == null || userId.isEmpty) {
      return APIResponse<LoansResponse>(
        success: false,
        message: 'User not logged in',
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
      '${ApiKeys.baseUrl}/loans/customer/$userId',
    ).replace(queryParameters: params);

    DevLogs.logInfo('Fetching customer loans: $uri');

    try {
      final response = await http.get(uri, headers: headers);
      final responseBody = response.body;

      DevLogs.logInfo('Customer loans response status: ${response.statusCode}');

      // Log only first 200 chars to avoid huge logs
      if (responseBody.length > 200) {
        DevLogs.logInfo(
          'Response body (first 200 chars): ${responseBody.substring(0, 200)}...',
        );
      } else {
        DevLogs.logInfo('Response body: $responseBody');
      }

      // Check if response is HTML (error page)
      if (responseBody.contains('<!DOCTYPE') ||
          responseBody.contains('<html')) {
        DevLogs.logError('Server returned HTML instead of JSON. Check URL.');
        return APIResponse<LoansResponse>(
          success: false,
          message:
              'Server error: Invalid endpoint. Please check API configuration.',
          data: null,
        );
      }

      final responseData = json.decode(responseBody);

      // DEBUG: Add this to see structure
      DevLogs.logInfo('Response keys: ${responseData.keys.toList()}');
      if (responseData['data'] != null) {
        final data = responseData['data'] as Map<String, dynamic>;
        DevLogs.logInfo('Data keys: ${data.keys.toList()}');
        DevLogs.logInfo('Loans type: ${data['loans'].runtimeType}');
        DevLogs.logInfo('Pagination type: ${data['pagination'].runtimeType}');
      }

      if (response.statusCode == 401) {
        return APIResponse<LoansResponse>(
          success: false,
          message: 'Authentication failed. Please login again.',
          data: null,
        );
      }

      if (response.statusCode == 403) {
        return APIResponse<LoansResponse>(
          success: false,
          message: 'You can only view your own loans',
          data: null,
        );
      }

      if (response.statusCode == 404) {
        return APIResponse<LoansResponse>(
          success: false,
          message: 'Customer not found',
          data: null,
        );
      }

      if (response.statusCode >= 200 && response.statusCode < 300) {
        if (responseData['success'] == true) {
          final data = responseData['data'];

          try {
            final loansResponse = LoansResponse.fromMap(data);
            DevLogs.logSuccess(
              'Fetched ${loansResponse.loans.length} loans successfully',
            );

            return APIResponse<LoansResponse>(
              success: true,
              data: loansResponse,
              message:
                  responseData['message'] ?? 'Loans retrieved successfully',
            );
          } catch (e) {
            DevLogs.logError('Error parsing loans response: $e');
            DevLogs.logError('Error stack: ${e.toString()}');
            return APIResponse<LoansResponse>(
              success: false,
              message: 'Error parsing loan data: ${e.toString()}',
              data: null,
            );
          }
        } else {
          final errorMessage =
              responseData['message'] ?? 'Failed to fetch loans';
          DevLogs.logError('Loans fetch failed: $errorMessage');

          return APIResponse<LoansResponse>(
            success: false,
            message: errorMessage,
            data: null,
          );
        }
      } else {
        final errorMessage =
            responseData['message'] ?? 'HTTP Error: ${response.statusCode}';
        DevLogs.logError('Loans HTTP error: $errorMessage');

        return APIResponse<LoansResponse>(
          success: false,
          message: errorMessage,
          data: null,
        );
      }
    } catch (e) {
      DevLogs.logError('Error fetching customer loans: $e');
      return APIResponse<LoansResponse>(
        success: false,
        message: 'An error occurred while fetching loans: ${e.toString()}',
        data: null,
      );
    }
  }

  /// GET LOAN DETAILS BY ID
  static Future<APIResponse<LoanModel>> getLoanById(String loanId) async {
    final token = await CacheUtils.checkToken();

    if (token == null || token.isEmpty) {
      return APIResponse<LoanModel>(
        success: false,
        message: 'Authentication required',
        data: null,
      );
    }

    var headers = {
      'accept': 'application/json',
      'Authorization': 'Bearer $token',
    };

    final uri = Uri.parse('${ApiKeys.baseUrl}/loans/$loanId');

    DevLogs.logInfo('Fetching loan details: $uri');

    try {
      final response = await http.get(uri, headers: headers);
      final responseBody = response.body;
      final responseData = json.decode(responseBody);

      DevLogs.logInfo('Loan details response status: ${response.statusCode}');
      DevLogs.logInfo('Loan details response body: $responseBody');

      if (response.statusCode == 401) {
        return APIResponse<LoanModel>(
          success: false,
          message: 'Authentication failed. Please login again.',
          data: null,
        );
      }

      if (response.statusCode == 403) {
        return APIResponse<LoanModel>(
          success: false,
          message: 'You are not authorized to view this loan',
          data: null,
        );
      }

      if (response.statusCode == 404) {
        return APIResponse<LoanModel>(
          success: false,
          message: 'Loan not found',
          data: null,
        );
      }

      if (response.statusCode >= 200 && response.statusCode < 300) {
        if (responseData['success'] == true) {
          final data = responseData['data'];
          final loan = LoanModel.fromMap(data);

          DevLogs.logSuccess('Fetched loan details successfully');

          return APIResponse<LoanModel>(
            success: true,
            data: loan,
            message:
                responseData['message'] ??
                'Loan details retrieved successfully',
          );
        } else {
          final errorMessage =
              responseData['message'] ?? 'Failed to fetch loan details';
          DevLogs.logError('Loan details fetch failed: $errorMessage');

          return APIResponse<LoanModel>(
            success: false,
            message: errorMessage,
            data: null,
          );
        }
      } else {
        final errorMessage =
            responseData['message'] ?? 'HTTP Error: ${response.statusCode}';
        DevLogs.logError('Loan details HTTP error: $errorMessage');

        return APIResponse<LoanModel>(
          success: false,
          message: errorMessage,
          data: null,
        );
      }
    } catch (e) {
      DevLogs.logError('Error fetching loan details: $e');
      return APIResponse<LoanModel>(
        success: false,
        message:
            'An error occurred while fetching loan details: ${e.toString()}',
        data: null,
      );
    }
  }

  /// CALCULATE LOAN CHARGES
  static Future<APIResponse<Map<String, dynamic>>> calculateLoanCharges(
    String loanId,
  ) async {
    final token = await CacheUtils.checkToken();

    if (token == null || token.isEmpty) {
      return APIResponse<Map<String, dynamic>>(
        success: false,
        message: 'Authentication required',
        data: null,
      );
    }

    var headers = {
      'accept': 'application/json',
      'Authorization': 'Bearer $token',
    };

    final uri = Uri.parse('${ApiKeys.baseUrl}/loans/$loanId/charges');

    DevLogs.logInfo('Calculating loan charges: $uri');

    try {
      final response = await http.get(uri, headers: headers);
      final responseBody = response.body;
      final responseData = json.decode(responseBody);

      DevLogs.logInfo('Loan charges response status: ${response.statusCode}');
      DevLogs.logInfo('Loan charges response body: $responseBody');

      if (response.statusCode >= 200 && response.statusCode < 300) {
        if (responseData['success'] == true) {
          final data = responseData['data'];

          DevLogs.logSuccess('Calculated loan charges successfully');

          return APIResponse<Map<String, dynamic>>(
            success: true,
            data: data,
            message:
                responseData['message'] ??
                'Loan charges calculated successfully',
          );
        } else {
          final errorMessage =
              responseData['message'] ?? 'Failed to calculate loan charges';
          DevLogs.logError('Loan charges calculation failed: $errorMessage');

          return APIResponse<Map<String, dynamic>>(
            success: false,
            message: errorMessage,
            data: null,
          );
        }
      } else {
        final errorMessage =
            responseData['message'] ?? 'HTTP Error: ${response.statusCode}';
        DevLogs.logError('Loan charges HTTP error: $errorMessage');

        return APIResponse<Map<String, dynamic>>(
          success: false,
          message: errorMessage,
          data: null,
        );
      }
    } catch (e) {
      DevLogs.logError('Error calculating loan charges: $e');
      return APIResponse<Map<String, dynamic>>(
        success: false,
        message:
            'An error occurred while calculating loan charges: ${e.toString()}',
        data: null,
      );
    }
  }

  /// PROCESS LOAN PAYMENT
  static Future<APIResponse<Map<String, dynamic>>> processLoanPayment({
    required String loanId,
    required double amount,
    required String paymentMethod,
    String? provider,
    String? phoneNumber,
    String? accountNumber,
  }) async {
    final token = await CacheUtils.checkToken();

    if (token == null || token.isEmpty) {
      return APIResponse<Map<String, dynamic>>(
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

    final body = json.encode({
      'amount': amount,
      'paymentMethod': paymentMethod,
      if (provider != null && provider.isNotEmpty) 'provider': provider,
      if (phoneNumber != null && phoneNumber.isNotEmpty)
        'phoneNumber': phoneNumber,
      if (accountNumber != null && accountNumber.isNotEmpty)
        'accountNumber': accountNumber,
    });

    final uri = Uri.parse('${ApiKeys.baseUrl}/loans/$loanId/payment');

    DevLogs.logInfo('Processing loan payment: $uri');
    DevLogs.logInfo('Payment request body: $body');

    try {
      final response = await http.post(uri, headers: headers, body: body);
      final responseBody = response.body;
      final responseData = json.decode(responseBody);

      DevLogs.logInfo('Loan payment response status: ${response.statusCode}');
      DevLogs.logInfo('Loan payment response body: $responseBody');

      if (response.statusCode == 201) {
        if (responseData['success'] == true) {
          final data = responseData['data'];

          DevLogs.logSuccess('Loan payment processed successfully');

          return APIResponse<Map<String, dynamic>>(
            success: true,
            data: data,
            message:
                responseData['message'] ?? 'Payment processed successfully',
          );
        } else {
          final errorMessage =
              responseData['message'] ?? 'Failed to process payment';
          DevLogs.logError('Loan payment failed: $errorMessage');

          return APIResponse<Map<String, dynamic>>(
            success: false,
            message: errorMessage,
            data: null,
          );
        }
      } else if (response.statusCode == 400) {
        final errorMessage =
            responseData['message'] ?? 'Invalid payment request';
        return APIResponse<Map<String, dynamic>>(
          success: false,
          message: errorMessage,
          data: null,
        );
      } else if (response.statusCode == 401) {
        return APIResponse<Map<String, dynamic>>(
          success: false,
          message: 'Unauthorized - Please login again',
          data: null,
        );
      } else if (response.statusCode == 403) {
        return APIResponse<Map<String, dynamic>>(
          success: false,
          message: 'You are not authorized to make this payment',
          data: null,
        );
      } else if (response.statusCode == 404) {
        return APIResponse<Map<String, dynamic>>(
          success: false,
          message: 'Loan not found',
          data: null,
        );
      } else {
        final errorMessage =
            responseData['message'] ?? 'HTTP Error: ${response.statusCode}';
        DevLogs.logError('Loan payment HTTP error: $errorMessage');

        return APIResponse<Map<String, dynamic>>(
          success: false,
          message: errorMessage,
          data: null,
        );
      }
    } catch (e) {
      DevLogs.logError('Error processing loan payment: $e');
      return APIResponse<Map<String, dynamic>>(
        success: false,
        message: 'An error occurred while processing payment: ${e.toString()}',
        data: null,
      );
    }
  }

  /// UPDATE LOAN STATUS
  static Future<APIResponse<bool>> updateLoanStatus({
    required String loanId,
    required String status,
    String? notes,
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
      'Content-Type': 'application/json',
    };

    final body = json.encode({
      'status': status,
      if (notes != null && notes.isNotEmpty) 'notes': notes,
    });

    final uri = Uri.parse('${ApiKeys.baseUrl}/loans/$loanId/status');

    DevLogs.logInfo('Updating loan status: $uri');

    try {
      final response = await http.put(uri, headers: headers, body: body);
      final responseBody = response.body;
      final responseData = json.decode(responseBody);

      DevLogs.logInfo('Loan status response status: ${response.statusCode}');

      if (response.statusCode == 200) {
        if (responseData['success'] == true) {
          DevLogs.logSuccess('Loan status updated successfully');

          return APIResponse<bool>(
            success: true,
            data: true,
            message:
                responseData['message'] ?? 'Loan status updated successfully',
          );
        } else {
          final errorMessage =
              responseData['message'] ?? 'Failed to update loan status';
          DevLogs.logError('Loan status update failed: $errorMessage');

          return APIResponse<bool>(
            success: false,
            message: errorMessage,
            data: null,
          );
        }
      } else {
        final errorMessage =
            responseData['message'] ?? 'HTTP Error: ${response.statusCode}';
        DevLogs.logError('Loan status HTTP error: $errorMessage');

        return APIResponse<bool>(
          success: false,
          message: errorMessage,
          data: null,
        );
      }
    } catch (e) {
      DevLogs.logError('Error updating loan status: $e');
      return APIResponse<bool>(
        success: false,
        message:
            'An error occurred while updating loan status: ${e.toString()}',
        data: null,
      );
    }
  }
}
