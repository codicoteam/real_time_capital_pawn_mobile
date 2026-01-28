import 'package:get/get.dart';
import 'package:real_time_pawn/core/utils/logs.dart';
import 'package:real_time_pawn/features/bid_payment_mngmt/services/bid_payment_mngmt_service.dart';
import 'package:real_time_pawn/models/bid_payment_model.dart';

class BidPaymentController extends GetxController {
  // Loading states
  var isLoading = false.obs;
  var isLoadingMethods = false.obs;
  var isLoadingPayment = false.obs;
  var isLoadingDetails = false.obs;
  var isLoadingMore = false.obs;
  var isPollingStatus = false.obs;
  var isSearching = false.obs;

  // Data
  var paymentMethods = <PaymentMethod>[].obs;
  var bidPayments = <BidPayment>[].obs;
  var selectedPayment = Rxn<BidPayment>();
  var selectedMethod = Rxn<PaymentMethod>();

  // Pagination
  var currentPage = 1.obs;
  var hasMorePayments = true.obs;

  // Messages
  var successMessage = ''.obs;
  var errorMessage = ''.obs;

  // Payment form
  var payerPhone = ''.obs;
  var paymentNotes = ''.obs;

  // Search properties
  var searchResults = <BidPayment>[].obs;
  var searchQuery = ''.obs;
  var searchFilters = <String, dynamic>{}.obs;

  // Payment status polling
  var currentPollingPaymentId = Rxn<String>();
  var paymentStatusData = Rxn<Map<String, dynamic>>();

  /// GET PAYMENT METHODS
  Future<bool> getPaymentMethodsRequest() async {
    try {
      isLoadingMethods(true);
      successMessage.value = '';
      errorMessage.value = '';

      final response = await BidPaymentService.getPaymentMethods();

      if (response.success && response.data != null) {
        paymentMethods.value = response.data!;
        successMessage.value = response.message ?? 'Payment methods loaded';
        DevLogs.logSuccess(successMessage.value);
        return true;
      } else {
        errorMessage.value =
            response.message ?? 'Failed to load payment methods';
        DevLogs.logError(errorMessage.value);
        return false;
      }
    } catch (e) {
      DevLogs.logError('Error getting payment methods: ${e.toString()}');
      errorMessage.value = 'An error occurred: ${e.toString()}';
      return false;
    } finally {
      isLoadingMethods(false);
    }
  }

  /// GET PAYER PAYMENTS
  Future<bool> getPayerPaymentsRequest({int page = 1, int limit = 10}) async {
    try {
      isLoading(true);
      successMessage.value = '';
      errorMessage.value = '';

      final response = await BidPaymentService.getPayerPayments(
        page: page,
        limit: limit,
      );

      if (response.success && response.data != null) {
        if (page == 1) {
          bidPayments.value = response.data!;
        } else {
          bidPayments.addAll(response.data!);
        }

        currentPage.value = page;
        hasMorePayments.value = response.data!.length == limit;

        successMessage.value =
            response.message ?? 'Payments loaded successfully';
        DevLogs.logSuccess(successMessage.value);
        return true;
      } else {
        errorMessage.value = response.message ?? 'Failed to load payments';
        DevLogs.logError(errorMessage.value);
        return false;
      }
    } catch (e) {
      DevLogs.logError('Error getting payer payments: ${e.toString()}');
      errorMessage.value = 'An error occurred: ${e.toString()}';
      return false;
    } finally {
      isLoading(false);
    }
  }

  /// LOAD MORE PAYMENTS
  Future<bool> loadMorePayments() async {
    if (!hasMorePayments.value || isLoading.value) return false;

    final nextPage = currentPage.value + 1;
    return await getPayerPaymentsRequest(page: nextPage);
  }

  /// CREATE PAYMENT
  Future<bool> createPaymentRequest({
    required String bidId,
    required double amount,
    required String method,
    required String provider,
    required String payerPhone,
    String? redirectUrl,
    String? notes,
  }) async {
    try {
      isLoadingPayment(true);
      successMessage.value = '';
      errorMessage.value = '';

      final response = await BidPaymentService.createPayment(
        bidId: bidId,
        amount: amount,
        method: method,
        provider: provider,
        payerPhone: payerPhone,
        redirectUrl: redirectUrl,
        notes: notes,
      );

      if (response.success && response.data != null) {
        selectedPayment.value = response.data!;

        // Add to payments list
        bidPayments.insert(0, response.data!);

        successMessage.value =
            response.message ?? 'Payment created successfully';
        DevLogs.logSuccess(successMessage.value);
        return true;
      } else {
        errorMessage.value = response.message ?? 'Failed to create payment';
        DevLogs.logError(errorMessage.value);
        return false;
      }
    } catch (e) {
      DevLogs.logError('Error creating payment: ${e.toString()}');
      errorMessage.value = 'An error occurred: ${e.toString()}';
      return false;
    } finally {
      isLoadingPayment(false);
    }
  }

  /// GET PAYMENT DETAILS
  Future<bool> getPaymentDetailsRequest({required String paymentId}) async {
    try {
      isLoadingDetails(true);
      successMessage.value = '';
      errorMessage.value = '';

      final response = await BidPaymentService.getPaymentDetails(
        paymentId: paymentId,
      );

      if (response.success && response.data != null) {
        selectedPayment.value = response.data!;

        // Update in list if exists
        final index = bidPayments.indexWhere((p) => p.id == paymentId);
        if (index != -1) {
          bidPayments[index] = response.data!;
        }

        successMessage.value = response.message ?? 'Payment details loaded';
        DevLogs.logSuccess(successMessage.value);
        return true;
      } else {
        errorMessage.value =
            response.message ?? 'Failed to load payment details';
        DevLogs.logError(errorMessage.value);
        return false;
      }
    } catch (e) {
      DevLogs.logError('Error getting payment details: ${e.toString()}');
      errorMessage.value = 'An error occurred: ${e.toString()}';
      return false;
    } finally {
      isLoadingDetails(false);
    }
  }

  /// CHECK PAYMENT STATUS
  Future<bool> checkPaymentStatusRequest({required String paymentId}) async {
    try {
      isPollingStatus(true);
      currentPollingPaymentId.value = paymentId;
      successMessage.value = '';
      errorMessage.value = '';

      final response = await BidPaymentService.checkPaymentStatus(
        paymentId: paymentId,
      );

      if (response.success && response.data != null) {
        paymentStatusData.value = response.data!;

        // Update the payment in the list if it exists
        final index = bidPayments.indexWhere((p) => p.id == paymentId);
        if (index != -1) {
          // You might need to update the payment status here
          // based on the response data
        }

        successMessage.value = response.message ?? 'Payment status checked';
        DevLogs.logSuccess(successMessage.value);
        return true;
      } else {
        errorMessage.value =
            response.message ?? 'Failed to check payment status';
        DevLogs.logError(errorMessage.value);
        return false;
      }
    } catch (e) {
      DevLogs.logError('Error checking payment status: ${e.toString()}');
      errorMessage.value = 'An error occurred: ${e.toString()}';
      return false;
    } finally {
      isPollingStatus(false);
    }
  }

  /// POLL PAYMENT STATUS
  Future<void> pollPaymentStatusRequest({
    required String paymentId,
    int maxAttempts = 30,
    int intervalSeconds = 2,
  }) async {
    isPollingStatus(true);
    currentPollingPaymentId.value = paymentId;

    try {
      final statusData = await BidPaymentService.pollPaymentStatus(
        paymentId: paymentId,
        maxAttempts: maxAttempts,
        intervalSeconds: intervalSeconds,
      );

      paymentStatusData.value = statusData;

      if (statusData != null) {
        final paid = statusData['paid'] == true;
        if (paid) {
          successMessage.value = 'Payment completed successfully';

          // Refresh the payment details
          await getPaymentDetailsRequest(paymentId: paymentId);
        }
      }
    } catch (e) {
      errorMessage.value = 'Error polling payment status: ${e.toString()}';
      DevLogs.logError(errorMessage.value);
    } finally {
      isPollingStatus(false);
      currentPollingPaymentId.value = null;
    }
  }

  /// SEARCH PAYMENTS
  Future<bool> searchPaymentsRequest({
    required String query,
    String? auctionId,
    String? payerUserId,
    String? status,
    String? method,
    int page = 1,
    int limit = 10,
  }) async {
    try {
      isSearching(true);
      successMessage.value = '';
      errorMessage.value = '';
      searchQuery.value = query;

      // Store search filters
      searchFilters.value = {
        'auction_id': auctionId,
        'payer_user': payerUserId,
        'status': status,
        'method': method,
      };

      final response = await BidPaymentService.searchPayments(
        query: query,
        auctionId: auctionId,
        payerUserId: payerUserId,
        status: status,
        method: method,
        page: page,
        limit: limit,
      );

      if (response.success && response.data != null) {
        if (page == 1) {
          searchResults.value = response.data!;
        } else {
          searchResults.addAll(response.data!);
        }

        successMessage.value = response.message ?? 'Search completed';
        DevLogs.logSuccess('Found ${response.data!.length} payments');
        return true;
      } else {
        errorMessage.value = response.message ?? 'Failed to search payments';
        DevLogs.logError(errorMessage.value);
        return false;
      }
    } catch (e) {
      DevLogs.logError('Error searching payments: ${e.toString()}');
      errorMessage.value = 'An error occurred: ${e.toString()}';
      return false;
    } finally {
      isSearching(false);
    }
  }

  /// SELECT PAYMENT METHOD
  void selectPaymentMethod(PaymentMethod method) {
    selectedMethod.value = method;
  }

  /// UPDATE PAYER PHONE
  void updatePayerPhone(String phone) {
    payerPhone.value = phone;
  }

  /// UPDATE PAYMENT NOTES
  void updatePaymentNotes(String notes) {
    paymentNotes.value = notes;
  }

  /// CLEAR SELECTED DATA
  void clearSelectedData() {
    selectedPayment.value = null;
    selectedMethod.value = null;
    payerPhone.value = '';
    paymentNotes.value = '';
  }

  /// CLEAR MESSAGES
  void clearMessages() {
    successMessage.value = '';
    errorMessage.value = '';
  }

  /// CLEAR SEARCH
  void clearSearch() {
    searchResults.clear();
    searchQuery.value = '';
    searchFilters.value = {};
    isSearching.value = false;
  }

  /// STOP POLLING
  void stopPolling() {
    isPollingStatus.value = false;
    currentPollingPaymentId.value = null;
  }

  /// REFRESH PAYMENTS
  Future<void> refreshPayments() async {
    await getPayerPaymentsRequest(page: 1);
  }

  /// GET PAYMENT STATISTICS
  Map<String, int> getPaymentStatistics() {
    final total = bidPayments.length;
    int successful = 0;
    int pending = 0;
    int failed = 0;
    int refunded = 0;

    for (var payment in bidPayments) {
      switch (payment.status) {
        case PaymentStatus.success:
          successful++;
          break;
        case PaymentStatus.pending:
        case PaymentStatus.initiated:
        case PaymentStatus.processing:
          pending++;
          break;
        case PaymentStatus.failed:
          failed++;
          break;
        case PaymentStatus.refunded:
          refunded++;
          break;
        default:
          pending++;
      }
    }

    return {
      'total': total,
      'successful': successful,
      'pending': pending,
      'failed': failed,
      'refunded': refunded,
    };
  }

  /// GET TOTAL PAID AMOUNT
  double get totalPaidAmount {
    return bidPayments
        .where((p) => p.isSuccessful)
        .fold(0.0, (sum, payment) => sum + payment.amount);
  }

  /// GET PENDING PAYMENT AMOUNT
  double get pendingPaymentAmount {
    return bidPayments
        .where((p) => p.isPending)
        .fold(0.0, (sum, payment) => sum + payment.amount);
  }

  /// GET PAYMENT STATUS SUMMARY
  String getPaymentStatusSummary() {
    final data = paymentStatusData.value;
    if (data == null) return 'Unknown';

    final gatewayStatus = data['gateway_status']?.toString() ?? 'Unknown';
    final status = data['status']?.toString() ?? 'Unknown';
    final paid = data['paid'] == true;

    if (paid) return 'Paid';
    if (gatewayStatus.toLowerCase() == 'paid') return 'Gateway: Paid';
    return 'Gateway: $gatewayStatus, Status: $status';
  }

  /// GET PAYMENT STATUS COLOR FROM DATA
  String getPaymentStatusColorFromData(Map<String, dynamic> data) {
    final paid = data['paid'] == true;
    final gatewayStatus =
        data['gateway_status']?.toString().toLowerCase() ?? '';
    final status = data['status']?.toString().toLowerCase() ?? '';

    if (paid || gatewayStatus == 'paid' || status == 'success') {
      return '#4CAF50'; // Green
    } else if (gatewayStatus == 'pending' || status == 'pending') {
      return '#FF9800'; // Orange
    } else if (gatewayStatus == 'failed' || status == 'failed') {
      return '#F44336'; // Red
    } else {
      return '#757575'; // Grey
    }
  }

  /// GET PAYMENT STATUS COLOR
  static String getPaymentStatusColor(PaymentStatus status) {
    switch (status) {
      case PaymentStatus.success:
        return '#4CAF50'; // Green
      case PaymentStatus.pending:
      case PaymentStatus.initiated:
      case PaymentStatus.processing:
        return '#FF9800'; // Orange
      case PaymentStatus.failed:
        return '#F44336'; // Red
      case PaymentStatus.refunded:
        return '#9E9E9E'; // Grey
      case PaymentStatus.cancelled:
        return '#607D8B'; // Blue Grey
      default:
        return '#757575'; // Grey
    }
  }

  /// GET PAYMENT STATUS TEXT
  static String getPaymentStatusText(PaymentStatus status) {
    switch (status) {
      case PaymentStatus.success:
        return 'Successful';
      case PaymentStatus.failed:
        return 'Failed';
      case PaymentStatus.refunded:
        return 'Refunded';
      case PaymentStatus.initiated:
        return 'Initiated';
      case PaymentStatus.processing:
        return 'Processing';
      case PaymentStatus.cancelled:
        return 'Cancelled';
      default:
        return 'Pending';
    }
  }

  /// GET PAYMENT METHOD DISPLAY NAME
  static String getPaymentMethodDisplayName(String method) {
    switch (method.toLowerCase()) {
      case 'ecocash':
        return 'EcoCash';
      case 'onemoney':
        return 'OneMoney';
      case 'telecash':
        return 'Telecash';
      case 'cash':
        return 'Cash';
      case 'bank_transfer':
        return 'Bank Transfer';
      case 'mobile_money':
        return 'Mobile Money';
      default:
        return method;
    }
  }

  /// GET PAYMENT STATUS FROM STRING
  static PaymentStatus getPaymentStatusFromString(String status) {
    switch (status.toLowerCase()) {
      case 'success':
        return PaymentStatus.success;
      case 'failed':
        return PaymentStatus.failed;
      case 'refunded':
        return PaymentStatus.refunded;
      case 'initiated':
        return PaymentStatus.initiated;
      case 'processing':
        return PaymentStatus.processing;
      case 'cancelled':
        return PaymentStatus.cancelled;
      default:
        return PaymentStatus.pending;
    }
  }
}
