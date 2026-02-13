// payments_mngmt_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:real_time_pawn/core/utils/logs.dart';
import 'package:real_time_pawn/config/api_config/api_keys.dart';
import 'package:real_time_pawn/core/utils/api_response.dart';
import 'package:real_time_pawn/core/utils/shared_pref_methods.dart';
import 'package:real_time_pawn/models/payment_mngmt_model.dart';

class PaymentService {
  /// CREATE NEW PAYMENT - CORRECTED VERSION
  static Future<APIResponse<Map<String, dynamic>>> createPayment({
    required String loanId,
    required String loanTermId,
    required double amount,
    required String provider,
    required String method,
    String currency = 'USD',
    double? interestComponent,
    double? principalComponent,
    double? storageComponent,
    double? penaltyComponent,
    String? notes,
    String? phoneNumber,
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

    // Build the body according to backend API documentation
    final Map<String, dynamic> requestBody = {
      'loan': loanId,
      'loan_term': loanTermId,
      'amount': amount,
      'currency': currency,
      'provider': provider,
      'method': method,
      'payment_status': 'pending',
      if (interestComponent != null) 'interest_component': interestComponent,
      if (principalComponent != null) 'principal_component': principalComponent,
      if (storageComponent != null) 'storage_component': storageComponent,
      if (penaltyComponent != null) 'penalty_component': penaltyComponent,
      if (notes != null && notes.isNotEmpty) 'notes': notes,
    };

    // Only add phoneNumber for mobile money providers
    if (provider == 'ecocash' ||
        provider == 'onemoney' ||
        provider == 'telecash') {
      if (phoneNumber != null && phoneNumber.isNotEmpty) {
        // Try camelCase first since it's more common in APIs
        requestBody['phoneNumber'] = phoneNumber;
        // Also add snake_case as backup
        requestBody['phone_number'] = phoneNumber;
      }
    }

    final body = json.encode(requestBody);
    final uri = Uri.parse('${ApiKeys.baseUrl}/payments');

    DevLogs.logInfo('Creating payment: $uri');
    DevLogs.logInfo('Payment request body: $body');

    try {
      final response = await http.post(uri, headers: headers, body: body);
      final responseBody = response.body;
      final responseData = json.decode(responseBody);

      DevLogs.logInfo('Create payment response status: ${response.statusCode}');
      DevLogs.logInfo('Create payment response body: $responseBody');

      if (response.statusCode == 201) {
        if (responseData['success'] == true) {
          final data = responseData['data'];
          DevLogs.logSuccess('Payment created successfully');

          return APIResponse<Map<String, dynamic>>(
            success: true,
            data: data,
            message: responseData['message'] ?? 'Payment created successfully',
          );
        } else {
          final errorMessage =
              responseData['message'] ?? 'Failed to create payment';
          DevLogs.logError('Payment creation failed: $errorMessage');

          return APIResponse<Map<String, dynamic>>(
            success: false,
            message: errorMessage,
            data: null,
          );
        }
      } else if (response.statusCode == 400) {
        final errorMessage = responseData['message'] ?? 'Invalid payment data';
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
          message: 'You are not authorized to create this payment',
          data: null,
        );
      } else {
        final errorMessage =
            responseData['message'] ?? 'HTTP Error: ${response.statusCode}';
        DevLogs.logError('Create payment HTTP error: $errorMessage');

        return APIResponse<Map<String, dynamic>>(
          success: false,
          message: errorMessage,
          data: null,
        );
      }
    } catch (e) {
      DevLogs.logError('Error creating payment: $e');
      return APIResponse<Map<String, dynamic>>(
        success: false,
        message: 'An error occurred while creating payment: ${e.toString()}',
        data: null,
      );
    }
  }

  /// GET PAYMENTS BY LOAN ID
  static Future<APIResponse<PaymentListResponse>> getPaymentsByLoan({
    required String loanId,
    int page = 1,
    int limit = 10,
  }) async {
    final token = await CacheUtils.checkToken();

    if (token == null || token.isEmpty) {
      return APIResponse<PaymentListResponse>(
        success: false,
        message: 'Authentication required',
        data: null,
      );
    }

    var headers = {
      'accept': 'application/json',
      'Authorization': 'Bearer $token',
    };

    final uri = Uri.parse('${ApiKeys.baseUrl}/payments/loan/$loanId').replace(
      queryParameters: {'page': page.toString(), 'limit': limit.toString()},
    );

    DevLogs.logInfo('Fetching payments by loan: $uri');

    try {
      final response = await http.get(uri, headers: headers);
      final responseBody = response.body;
      final responseData = json.decode(responseBody);

      DevLogs.logInfo(
        'Payments by loan response status: ${response.statusCode}',
      );

      if (response.statusCode == 200) {
        if (responseData['success'] == true) {
          final data = responseData['data'];

          try {
            final paymentsResponse = PaymentListResponse.fromMap(data);
            DevLogs.logSuccess(
              'Fetched ${paymentsResponse.payments.length} payments successfully',
            );

            return APIResponse<PaymentListResponse>(
              success: true,
              data: paymentsResponse,
              message:
                  responseData['message'] ?? 'Payments retrieved successfully',
            );
          } catch (e) {
            DevLogs.logError('Error parsing payments response: $e');
            return APIResponse<PaymentListResponse>(
              success: false,
              message: 'Error parsing payment data: ${e.toString()}',
              data: null,
            );
          }
        } else {
          final errorMessage =
              responseData['message'] ?? 'Failed to fetch payments';
          DevLogs.logError('Payments fetch failed: $errorMessage');

          return APIResponse<PaymentListResponse>(
            success: false,
            message: errorMessage,
            data: null,
          );
        }
      } else if (response.statusCode == 401) {
        return APIResponse<PaymentListResponse>(
          success: false,
          message: 'Authentication failed. Please login again.',
          data: null,
        );
      } else if (response.statusCode == 403) {
        return APIResponse<PaymentListResponse>(
          success: false,
          message: 'You are not authorized to view these payments',
          data: null,
        );
      } else if (response.statusCode == 404) {
        return APIResponse<PaymentListResponse>(
          success: false,
          message: 'Loan not found',
          data: null,
        );
      } else {
        final errorMessage =
            responseData['message'] ?? 'HTTP Error: ${response.statusCode}';
        DevLogs.logError('Payments HTTP error: $errorMessage');

        return APIResponse<PaymentListResponse>(
          success: false,
          message: errorMessage,
          data: null,
        );
      }
    } catch (e) {
      DevLogs.logError('Error fetching payments by loan: $e');
      return APIResponse<PaymentListResponse>(
        success: false,
        message: 'An error occurred while fetching payments: ${e.toString()}',
        data: null,
      );
    }
  }

  /// GET PAYMENTS BY CUSTOMER
  static Future<APIResponse<PaymentListResponse>> getPaymentsByCustomer({
    required String customerId,
    int page = 1,
    int limit = 10,
  }) async {
    final token = await CacheUtils.checkToken();

    if (token == null || token.isEmpty) {
      return APIResponse<PaymentListResponse>(
        success: false,
        message: 'Authentication required',
        data: null,
      );
    }

    var headers = {
      'accept': 'application/json',
      'Authorization': 'Bearer $token',
    };

    // Remove any spaces from customerId (issue from API example)
    final cleanCustomerId = customerId.trim();

    final uri =
        Uri.parse(
          '${ApiKeys.baseUrl}/payments/customer/$cleanCustomerId',
        ).replace(
          queryParameters: {'page': page.toString(), 'limit': limit.toString()},
        );

    DevLogs.logInfo('Fetching payments by customer: $uri');

    try {
      final response = await http.get(uri, headers: headers);
      final responseBody = response.body;
      final responseData = json.decode(responseBody);

      DevLogs.logInfo(
        'Payments by customer response status: ${response.statusCode}',
      );

      if (response.statusCode == 200) {
        if (responseData['success'] == true) {
          final data = responseData['data'];

          try {
            final paymentsResponse = PaymentListResponse.fromMap(data);
            DevLogs.logSuccess(
              'Fetched ${paymentsResponse.payments.length} payments successfully',
            );

            return APIResponse<PaymentListResponse>(
              success: true,
              data: paymentsResponse,
              message:
                  responseData['message'] ?? 'Payments retrieved successfully',
            );
          } catch (e) {
            DevLogs.logError('Error parsing payments response: $e');
            return APIResponse<PaymentListResponse>(
              success: false,
              message: 'Error parsing payment data: ${e.toString()}',
              data: null,
            );
          }
        } else {
          final errorMessage =
              responseData['message'] ?? 'Failed to fetch payments';
          DevLogs.logError('Payments fetch failed: $errorMessage');

          return APIResponse<PaymentListResponse>(
            success: false,
            message: errorMessage,
            data: null,
          );
        }
      } else if (response.statusCode == 401) {
        return APIResponse<PaymentListResponse>(
          success: false,
          message: 'Authentication failed. Please login again.',
          data: null,
        );
      } else if (response.statusCode == 403) {
        return APIResponse<PaymentListResponse>(
          success: false,
          message: 'You are not authorized to view these payments',
          data: null,
        );
      } else if (response.statusCode == 404) {
        return APIResponse<PaymentListResponse>(
          success: false,
          message: 'Customer not found',
          data: null,
        );
      } else {
        final errorMessage =
            responseData['message'] ?? 'HTTP Error: ${response.statusCode}';
        DevLogs.logError('Payments HTTP error: $errorMessage');

        return APIResponse<PaymentListResponse>(
          success: false,
          message: errorMessage,
          data: null,
        );
      }
    } catch (e) {
      DevLogs.logError('Error fetching payments by customer: $e');
      return APIResponse<PaymentListResponse>(
        success: false,
        message: 'An error occurred while fetching payments: ${e.toString()}',
        data: null,
      );
    }
  }

  /// GET PAYMENT BY ID - REPLACE YOUR EXISTING METHOD WITH THIS EXACT VERSION
  static Future<APIResponse<PaymentModel>> getPaymentById(
    String paymentId,
  ) async {
    final token = await CacheUtils.checkToken();

    if (token == null || token.isEmpty) {
      return APIResponse<PaymentModel>(
        success: false,
        message: 'Authentication required',
        data: null,
      );
    }

    var headers = {
      'accept': 'application/json',
      'Authorization': 'Bearer $token',
    };

    final uri = Uri.parse('${ApiKeys.baseUrl}/payments/$paymentId');

    DevLogs.logInfo('Fetching payment by ID: $uri');

    try {
      final response = await http.get(uri, headers: headers);
      final responseBody = response.body;
      final responseData = json.decode(responseBody);

      DevLogs.logInfo('Payment by ID response status: ${response.statusCode}');

      if (response.statusCode == 200) {
        // ✅ SIMPLE: Always try to parse, let the model handle the structure
        try {
          final payment = PaymentModel.fromMap(responseData);
          DevLogs.logSuccess('✅ Fetched payment details successfully');

          return APIResponse<PaymentModel>(
            success: true,
            data: payment,
            message: 'Payment details retrieved successfully',
          );
        } catch (e, stackTrace) {
          DevLogs.logError('❌ Error parsing payment data: $e\n$stackTrace');
          return APIResponse<PaymentModel>(
            success: false,
            message: 'Error parsing payment data',
            data: null,
          );
        }
      } else if (response.statusCode == 401) {
        return APIResponse<PaymentModel>(
          success: false,
          message: 'Authentication failed. Please login again.',
          data: null,
        );
      } else if (response.statusCode == 403) {
        return APIResponse<PaymentModel>(
          success: false,
          message: 'You are not authorized to view this payment',
          data: null,
        );
      } else if (response.statusCode == 404) {
        return APIResponse<PaymentModel>(
          success: false,
          message: 'Payment not found',
          data: null,
        );
      } else {
        final errorMessage =
            responseData['message'] ?? 'HTTP Error: ${response.statusCode}';
        DevLogs.logError('Payment HTTP error: $errorMessage');
        return APIResponse<PaymentModel>(
          success: false,
          message: errorMessage,
          data: null,
        );
      }
    } catch (e) {
      DevLogs.logError('Error fetching payment by ID: $e');
      return APIResponse<PaymentModel>(
        success: false,
        message: 'An error occurred while fetching payment',
        data: null,
      );
    }
  }

  /// CHECK PAYNOW PAYMENT STATUS
  static Future<APIResponse<Map<String, dynamic>>> checkPaymentStatus(
    String paymentId,
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

    final uri = Uri.parse(
      '${ApiKeys.baseUrl}/payments/$paymentId/check-status',
    );

    DevLogs.logInfo('Checking payment status: $uri');

    try {
      final response = await http.get(uri, headers: headers);
      final responseBody = response.body;
      final responseData = json.decode(responseBody);

      DevLogs.logInfo('Payment status response status: ${response.statusCode}');

      if (response.statusCode == 200) {
        if (responseData['success'] == true) {
          final data = responseData['data'];

          DevLogs.logSuccess('Payment status checked successfully');

          return APIResponse<Map<String, dynamic>>(
            success: true,
            data: data,
            message:
                responseData['message'] ??
                'Payment status checked successfully',
          );
        } else {
          final errorMessage =
              responseData['message'] ?? 'Failed to check payment status';
          DevLogs.logError('Payment status check failed: $errorMessage');

          return APIResponse<Map<String, dynamic>>(
            success: false,
            message: errorMessage,
            data: null,
          );
        }
      } else if (response.statusCode == 400) {
        return APIResponse<Map<String, dynamic>>(
          success: false,
          message: 'Not a PayNow payment or no poll URL available',
          data: null,
        );
      } else if (response.statusCode == 401) {
        return APIResponse<Map<String, dynamic>>(
          success: false,
          message: 'Unauthorized - Please login again',
          data: null,
        );
      } else if (response.statusCode == 404) {
        return APIResponse<Map<String, dynamic>>(
          success: false,
          message: 'Payment not found',
          data: null,
        );
      } else {
        final errorMessage =
            responseData['message'] ?? 'HTTP Error: ${response.statusCode}';
        DevLogs.logError('Payment status HTTP error: $errorMessage');

        return APIResponse<Map<String, dynamic>>(
          success: false,
          message: errorMessage,
          data: null,
        );
      }
    } catch (e) {
      DevLogs.logError('Error checking payment status: $e');
      return APIResponse<Map<String, dynamic>>(
        success: false,
        message:
            'An error occurred while checking payment status: ${e.toString()}',
        data: null,
      );
    }
  }
}
