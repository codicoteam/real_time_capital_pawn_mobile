import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:real_time_pawn/core/utils/logs.dart';
import 'package:real_time_pawn/models/bid_payment_model.dart';
import '../../../../config/api_config/api_keys.dart';
import '../../../../core/utils/api_response.dart';
import '../../../../core/utils/shared_pref_methods.dart';

class BidPaymentService {
  /// 1. GET PAYMENT METHODS
  /// GET /api/v1/bid-payments/methods
  static Future<APIResponse<List<PaymentMethod>>> getPaymentMethods() async {
    final token = await CacheUtils.checkToken();

    if (token == null || token.isEmpty) {
      return APIResponse<List<PaymentMethod>>(
        success: false,
        message: 'Authentication required',
        data: null,
      );
    }

    var headers = {
      'accept': 'application/json',
      'Authorization': 'Bearer $token',
    };

    final uri = Uri.parse('${ApiKeys.baseUrl}/bid-payments/methods');

    DevLogs.logInfo('Fetching payment methods: $uri');

    try {
      final response = await http.get(uri, headers: headers);
      final responseBody = response.body;
      final responseData = json.decode(responseBody);

      DevLogs.logInfo(
        'Payment methods response status: ${response.statusCode}',
      );

      if (response.statusCode >= 200 && response.statusCode < 300) {
        if (responseData['success'] == true) {
          final data = responseData['data'];
          List<PaymentMethod> methods = [];

          if (data is List) {
            methods = List<Map<String, dynamic>>.from(
              data,
            ).map((methodJson) => PaymentMethod.fromJson(methodJson)).toList();
          }

          DevLogs.logSuccess('Fetched ${methods.length} payment methods');

          return APIResponse<List<PaymentMethod>>(
            success: true,
            data: methods,
            message: responseData['message'] ?? 'Payment methods retrieved',
          );
        } else {
          final errorMessage =
              responseData['message'] ?? 'Failed to fetch payment methods';
          DevLogs.logError('Payment methods fetch failed: $errorMessage');

          return APIResponse<List<PaymentMethod>>(
            success: false,
            message: errorMessage,
            data: null,
          );
        }
      } else if (response.statusCode == 401) {
        return APIResponse<List<PaymentMethod>>(
          success: false,
          message: 'Unauthorized - Please login again',
          data: null,
        );
      } else {
        final errorMessage =
            responseData['message'] ?? 'HTTP Error: ${response.statusCode}';
        DevLogs.logError('Payment methods HTTP error: $errorMessage');

        return APIResponse<List<PaymentMethod>>(
          success: false,
          message: errorMessage,
          data: null,
        );
      }
    } catch (e) {
      DevLogs.logError('Error fetching payment methods: $e');
      return APIResponse<List<PaymentMethod>>(
        success: false,
        message:
            'An error occurred while fetching payment methods: ${e.toString()}',
        data: null,
      );
    }
  }

  /// 2. CREATE PAYMENT
  /// POST /api/v1/bid-payments
  static Future<APIResponse<BidPayment>> createPayment({
    required String bidId,
    required double amount,
    required String method,
    required String provider,
    required String payerPhone,
    String? redirectUrl,
    String? notes,
  }) async {
    final token = await CacheUtils.checkToken();

    if (token == null || token.isEmpty) {
      return APIResponse<BidPayment>(
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
      'bid_id': bidId,
      'amount': amount,
      'method': method,
      'provider': provider,
      'payer_phone': payerPhone,
      'redirect_url': redirectUrl ?? '',
      'notes': notes ?? '',
    });

    final uri = Uri.parse('${ApiKeys.baseUrl}/bid-payments');

    DevLogs.logInfo('Creating payment for bid: $bidId');
    DevLogs.logInfo('Request body: $body');

    try {
      final response = await http.post(uri, headers: headers, body: body);
      final responseBody = response.body;
      final responseData = json.decode(responseBody);

      DevLogs.logInfo('Create payment response status: ${response.statusCode}');
      DevLogs.logInfo('Create payment response body: $responseBody');

      if (response.statusCode >= 200 && response.statusCode < 300) {
        if (responseData['success'] == true) {
          final paymentData = responseData['data'];
          final payment = BidPayment.fromJson(paymentData);

          DevLogs.logSuccess('Payment created successfully');

          return APIResponse<BidPayment>(
            success: true,
            data: payment,
            message: responseData['message'] ?? 'Payment created successfully',
          );
        } else {
          final errorMessage =
              responseData['message'] ?? 'Failed to create payment';
          DevLogs.logError('Payment creation failed: $errorMessage');

          return APIResponse<BidPayment>(
            success: false,
            message: errorMessage,
            data: null,
          );
        }
      } else if (response.statusCode == 400) {
        return APIResponse<BidPayment>(
          success: false,
          message: responseData['message'] ?? 'Invalid payment data',
          data: null,
        );
      } else if (response.statusCode == 401) {
        return APIResponse<BidPayment>(
          success: false,
          message: 'Unauthorized - Please login again',
          data: null,
        );
      } else if (response.statusCode == 404) {
        return APIResponse<BidPayment>(
          success: false,
          message: 'Bid not found',
          data: null,
        );
      } else {
        final errorMessage =
            responseData['message'] ?? 'HTTP Error: ${response.statusCode}';
        DevLogs.logError('Create payment HTTP error: $errorMessage');

        return APIResponse<BidPayment>(
          success: false,
          message: errorMessage,
          data: null,
        );
      }
    } catch (e) {
      DevLogs.logError('Error creating payment: $e');
      return APIResponse<BidPayment>(
        success: false,
        message: 'An error occurred while creating payment: ${e.toString()}',
        data: null,
      );
    }
  }

  /// 3. GET PAYER'S PAYMENTS
  /// GET /api/v1/bid-payments/payer/{payerId}
  static Future<APIResponse<List<BidPayment>>> getPayerPayments({
    String? payerId,
    int page = 1,
    int limit = 10,
  }) async {
    final token = await CacheUtils.checkToken();

    if (token == null || token.isEmpty) {
      return APIResponse<List<BidPayment>>(
        success: false,
        message: 'Authentication required',
        data: null,
      );
    }

    // Get current user ID if not provided
    final currentUserId = payerId ?? await _getCurrentUserIdFromToken();
    if (currentUserId.isEmpty) {
      return APIResponse<List<BidPayment>>(
        success: false,
        message: 'User ID not found',
        data: null,
      );
    }

    var headers = {
      'accept': 'application/json',
      'Authorization': 'Bearer $token',
    };

    final params = <String, String>{
      'page': page.toString(),
      'limit': limit.toString(),
    };

    final uri = Uri.parse(
      '${ApiKeys.baseUrl}/bid-payments/payer/$currentUserId',
    ).replace(queryParameters: params);

    DevLogs.logInfo('Fetching payer payments: $uri');

    try {
      final response = await http.get(uri, headers: headers);
      final responseBody = response.body;
      final responseData = json.decode(responseBody);

      DevLogs.logInfo('Payer payments response status: ${response.statusCode}');

      if (response.statusCode >= 200 && response.statusCode < 300) {
        if (responseData['success'] == true) {
          final data = responseData['data'];
          List<BidPayment> payments = [];

          if (data is List) {
            payments = List<Map<String, dynamic>>.from(
              data,
            ).map((paymentJson) => BidPayment.fromJson(paymentJson)).toList();
          }

          DevLogs.logSuccess('Fetched ${payments.length} payer payments');

          return APIResponse<List<BidPayment>>(
            success: true,
            data: payments,
            message: responseData['message'] ?? 'Payments retrieved',
          );
        } else {
          final errorMessage =
              responseData['message'] ?? 'Failed to fetch payments';
          DevLogs.logError('Payer payments fetch failed: $errorMessage');

          return APIResponse<List<BidPayment>>(
            success: false,
            message: errorMessage,
            data: null,
          );
        }
      } else if (response.statusCode == 401) {
        return APIResponse<List<BidPayment>>(
          success: false,
          message: 'Unauthorized - Please login again',
          data: null,
        );
      } else if (response.statusCode == 403) {
        return APIResponse<List<BidPayment>>(
          success: false,
          message: 'Cannot view other users payments',
          data: null,
        );
      } else {
        final errorMessage =
            responseData['message'] ?? 'HTTP Error: ${response.statusCode}';
        DevLogs.logError('Payer payments HTTP error: $errorMessage');

        return APIResponse<List<BidPayment>>(
          success: false,
          message: errorMessage,
          data: null,
        );
      }
    } catch (e) {
      DevLogs.logError('Error fetching payer payments: $e');
      return APIResponse<List<BidPayment>>(
        success: false,
        message: 'An error occurred while fetching payments: ${e.toString()}',
        data: null,
      );
    }
  }

  /// 4. GET PAYMENT DETAILS
  /// GET /api/v1/bid-payments/{id}
  static Future<APIResponse<BidPayment>> getPaymentDetails({
    required String paymentId,
  }) async {
    final token = await CacheUtils.checkToken();

    if (token == null || token.isEmpty) {
      return APIResponse<BidPayment>(
        success: false,
        message: 'Authentication required',
        data: null,
      );
    }

    var headers = {
      'accept': 'application/json',
      'Authorization': 'Bearer $token',
    };

    final uri = Uri.parse('${ApiKeys.baseUrl}/bid-payments/$paymentId');

    DevLogs.logInfo('Fetching payment details: $uri');

    try {
      final response = await http.get(uri, headers: headers);
      final responseBody = response.body;
      final responseData = json.decode(responseBody);

      DevLogs.logInfo(
        'Payment details response status: ${response.statusCode}',
      );

      if (response.statusCode >= 200 && response.statusCode < 300) {
        if (responseData['success'] == true) {
          final paymentData = responseData['data'];
          final payment = BidPayment.fromJson(paymentData);

          DevLogs.logSuccess('Fetched payment details successfully');

          return APIResponse<BidPayment>(
            success: true,
            data: payment,
            message: responseData['message'] ?? 'Payment details retrieved',
          );
        } else {
          final errorMessage =
              responseData['message'] ?? 'Failed to fetch payment details';
          DevLogs.logError('Payment details fetch failed: $errorMessage');

          return APIResponse<BidPayment>(
            success: false,
            message: errorMessage,
            data: null,
          );
        }
      } else if (response.statusCode == 401) {
        return APIResponse<BidPayment>(
          success: false,
          message: 'Unauthorized - Please login again',
          data: null,
        );
      } else if (response.statusCode == 403) {
        return APIResponse<BidPayment>(
          success: false,
          message: 'Access denied to this payment',
          data: null,
        );
      } else if (response.statusCode == 404) {
        return APIResponse<BidPayment>(
          success: false,
          message: 'Payment not found',
          data: null,
        );
      } else {
        final errorMessage =
            responseData['message'] ?? 'HTTP Error: ${response.statusCode}';
        DevLogs.logError('Payment details HTTP error: $errorMessage');

        return APIResponse<BidPayment>(
          success: false,
          message: errorMessage,
          data: null,
        );
      }
    } catch (e) {
      DevLogs.logError('Error fetching payment details: $e');
      return APIResponse<BidPayment>(
        success: false,
        message:
            'An error occurred while fetching payment details: ${e.toString()}',
        data: null,
      );
    }
  }

  /// 5. CHECK PAYMENT STATUS
  /// GET /api/v1/bid-payments/{id}/check-status
  static Future<APIResponse<Map<String, dynamic>>> checkPaymentStatus({
    required String paymentId,
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
    };

    final uri = Uri.parse(
      '${ApiKeys.baseUrl}/bid-payments/$paymentId/check-status',
    );

    DevLogs.logInfo('Checking payment status: $uri');

    try {
      final response = await http.get(uri, headers: headers);
      final responseBody = response.body;
      final responseData = json.decode(responseBody);

      DevLogs.logInfo(
        'Payment status check response status: ${response.statusCode}',
      );

      if (response.statusCode >= 200 && response.statusCode < 300) {
        if (responseData['success'] == true) {
          final data = responseData['data'];

          DevLogs.logSuccess('Payment status checked successfully');

          return APIResponse<Map<String, dynamic>>(
            success: true,
            data: data is Map ? Map<String, dynamic>.from(data) : null,
            message: responseData['message'] ?? 'Payment status checked',
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
          message: 'Not a supported payment method or no poll URL',
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
        DevLogs.logError('Payment status check HTTP error: $errorMessage');

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

  /// 6. PROCESS PAYNOW WEBHOOK
  /// POST /api/v1/bid-payments/webhook/paynow
  static Future<APIResponse<Map<String, dynamic>>> processPayNowWebhook({
    required String reference,
    required String status,
    String? pollUrl,
    String? method,
    double? amount,
  }) async {
    // Note: This endpoint might not require authentication based on webhook nature
    // Check if authentication is needed
    final token = await CacheUtils.checkToken();

    var headers = {
      'accept': 'application/json',
      'Content-Type': 'application/json',
    };

    // Add authorization if token exists
    if (token != null && token.isNotEmpty) {
      headers['Authorization'] = 'Bearer $token';
    }

    final body = json.encode({
      'reference': reference,
      'status': status,
      if (pollUrl != null) 'pollUrl': pollUrl,
      if (method != null) 'method': method,
      if (amount != null) 'amount': amount,
    });

    final uri = Uri.parse('${ApiKeys.baseUrl}/bid-payments/webhook/paynow');

    DevLogs.logInfo('Processing PayNow webhook for reference: $reference');
    DevLogs.logInfo('Request body: $body');

    try {
      final response = await http.post(uri, headers: headers, body: body);
      final responseBody = response.body;
      final responseData = json.decode(responseBody);

      DevLogs.logInfo('PayNow webhook response status: ${response.statusCode}');

      if (response.statusCode >= 200 && response.statusCode < 300) {
        if (responseData['success'] == true) {
          final data = responseData['data'];

          DevLogs.logSuccess('PayNow webhook processed successfully');

          return APIResponse<Map<String, dynamic>>(
            success: true,
            data: data is Map ? Map<String, dynamic>.from(data) : null,
            message: responseData['message'] ?? 'Webhook processed',
          );
        } else {
          final errorMessage =
              responseData['message'] ?? 'Failed to process webhook';
          DevLogs.logError('PayNow webhook processing failed: $errorMessage');

          return APIResponse<Map<String, dynamic>>(
            success: false,
            message: errorMessage,
            data: null,
          );
        }
      } else if (response.statusCode == 400) {
        return APIResponse<Map<String, dynamic>>(
          success: false,
          message: 'Invalid webhook data',
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
        DevLogs.logError('PayNow webhook HTTP error: $errorMessage');

        return APIResponse<Map<String, dynamic>>(
          success: false,
          message: errorMessage,
          data: null,
        );
      }
    } catch (e) {
      DevLogs.logError('Error processing PayNow webhook: $e');
      return APIResponse<Map<String, dynamic>>(
        success: false,
        message:
            'An error occurred while processing PayNow webhook: ${e.toString()}',
        data: null,
      );
    }
  }

  /// 7. SEARCH BID PAYMENTS
  /// GET /api/v1/bid-payments/search
  static Future<APIResponse<List<BidPayment>>> searchPayments({
    required String query,
    String? auctionId,
    String? payerUserId,
    String? status,
    String? method,
    int page = 1,
    int limit = 10,
  }) async {
    final token = await CacheUtils.checkToken();

    if (token == null || token.isEmpty) {
      return APIResponse<List<BidPayment>>(
        success: false,
        message: 'Authentication required',
        data: null,
      );
    }

    // Validate search query length
    if (query.length < 2) {
      return APIResponse<List<BidPayment>>(
        success: false,
        message: 'Search term must be at least 2 characters',
        data: null,
      );
    }

    var headers = {
      'accept': 'application/json',
      'Authorization': 'Bearer $token',
    };

    final params = <String, String>{
      'q': query,
      'page': page.toString(),
      'limit': limit.toString(),
      if (auctionId != null && auctionId.isNotEmpty) 'auction_id': auctionId,
      if (payerUserId != null && payerUserId.isNotEmpty)
        'payer_user': payerUserId,
      if (status != null && status.isNotEmpty) 'status': status,
      if (method != null && method.isNotEmpty) 'method': method,
    };

    final uri = Uri.parse(
      '${ApiKeys.baseUrl}/bid-payments/search',
    ).replace(queryParameters: params);

    DevLogs.logInfo('Searching payments: $uri');

    try {
      final response = await http.get(uri, headers: headers);
      final responseBody = response.body;
      final responseData = json.decode(responseBody);

      DevLogs.logInfo(
        'Search payments response status: ${response.statusCode}',
      );

      if (response.statusCode >= 200 && response.statusCode < 300) {
        if (responseData['success'] == true) {
          final data = responseData['data'];
          List<BidPayment> payments = [];

          if (data is List) {
            payments = List<Map<String, dynamic>>.from(
              data,
            ).map((paymentJson) => BidPayment.fromJson(paymentJson)).toList();
          }

          DevLogs.logSuccess('Found ${payments.length} payments in search');

          return APIResponse<List<BidPayment>>(
            success: true,
            data: payments,
            message: responseData['message'] ?? 'Payments retrieved',
          );
        } else {
          final errorMessage =
              responseData['message'] ?? 'Failed to search payments';
          DevLogs.logError('Payments search failed: $errorMessage');

          return APIResponse<List<BidPayment>>(
            success: false,
            message: errorMessage,
            data: null,
          );
        }
      } else if (response.statusCode == 400) {
        return APIResponse<List<BidPayment>>(
          success: false,
          message: 'Search term too short',
          data: null,
        );
      } else if (response.statusCode == 401) {
        return APIResponse<List<BidPayment>>(
          success: false,
          message: 'Unauthorized - Please login again',
          data: null,
        );
      } else {
        final errorMessage =
            responseData['message'] ?? 'HTTP Error: ${response.statusCode}';
        DevLogs.logError('Payments search HTTP error: $errorMessage');

        return APIResponse<List<BidPayment>>(
          success: false,
          message: errorMessage,
          data: null,
        );
      }
    } catch (e) {
      DevLogs.logError('Error searching payments: $e');
      return APIResponse<List<BidPayment>>(
        success: false,
        message: 'An error occurred while searching payments: ${e.toString()}',
        data: null,
      );
    }
  }

  /// Helper method to poll payment status continuously
  /// Useful for PayNow and mobile payments that require polling
  static Future<Map<String, dynamic>?> pollPaymentStatus({
    required String paymentId,
    int maxAttempts = 30, // 30 attempts
    int intervalSeconds = 2, // 2 seconds between attempts
  }) async {
    int attempts = 0;

    while (attempts < maxAttempts) {
      attempts++;

      DevLogs.logInfo(
        'Polling payment status attempt $attempts/$maxAttempts for payment: $paymentId',
      );

      final result = await checkPaymentStatus(paymentId: paymentId);

      if (result.success && result.data != null) {
        final statusData = result.data!;
        final gatewayStatus = statusData['gateway_status']
            ?.toString()
            .toLowerCase();
        final paymentStatus = statusData['status']?.toString().toLowerCase();
        final paid = statusData['paid'] == true;

        DevLogs.logInfo(
          'Payment status: gateway=$gatewayStatus, status=$paymentStatus, paid=$paid',
        );

        // Check if payment is completed
        if (paid ||
            gatewayStatus == 'paid' ||
            gatewayStatus == 'success' ||
            paymentStatus == 'success' ||
            paymentStatus == 'completed') {
          DevLogs.logSuccess('Payment completed successfully');
          return statusData;
        }

        // Check if payment failed
        if (gatewayStatus == 'failed' ||
            gatewayStatus == 'cancelled' ||
            paymentStatus == 'failed' ||
            paymentStatus == 'cancelled') {
          DevLogs.logError('Payment failed or cancelled');
          return statusData;
        }

        // Payment still pending, continue polling
        if (attempts < maxAttempts) {
          await Future.delayed(Duration(seconds: intervalSeconds));
        }
      } else {
        DevLogs.logError('Failed to check payment status: ${result.message}');
        break;
      }
    }

    DevLogs.logWarning(
      'Payment status polling timed out after $maxAttempts attempts',
    );
    return null;
  }

  /// Helper: Get current user ID from token
  static Future<String> _getCurrentUserIdFromToken() async {
    try {
      final cachedUserId = await CacheUtils.getUserId();
      if (cachedUserId != null && cachedUserId.isNotEmpty) {
        return cachedUserId;
      }
      return '';
    } catch (e) {
      DevLogs.logError('Error getting user ID: $e');
      return '';
    }
  }

  /// Format currency
  static String formatCurrency(double amount, [String currency = 'USD']) {
    return '\$${amount.toStringAsFixed(2)}';
  }

  /// Get payment method icon
  static String getPaymentMethodIcon(String method) {
    switch (method.toLowerCase()) {
      case 'ecocash':
        return 'assets/icons/ecocash.png';
      case 'onemoney':
        return 'assets/icons/onemoney.png';
      case 'telecash':
        return 'assets/icons/telecash.png';
      case 'cash':
        return 'assets/icons/cash.png';
      case 'bank_transfer':
        return 'assets/icons/bank.png';
      default:
        return 'assets/icons/payment.png';
    }
  }
}
