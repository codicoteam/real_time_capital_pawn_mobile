import 'package:get/get.dart';
import 'package:real_time_pawn/core/utils/shared_pref_methods.dart';
import 'package:real_time_pawn/features/payments_mngmt/services/payments_mngmt_service.dart';
import 'package:real_time_pawn/models/payment_mngmt_model.dart';

class PaymentController extends GetxController {
  // State
  final RxList<PaymentModel> payments = <PaymentModel>[].obs;
  final Rx<PaymentModel?> selectedPayment = Rx<PaymentModel?>(null);
  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;

  // Loan-specific payments
  final RxMap<String, List<PaymentModel>> loanPayments =
      <String, List<PaymentModel>>{}.obs;

  // Pagination
  final RxInt currentPage = 1.obs;
  final RxInt totalPages = 1.obs;
  final RxBool hasNextPage = false.obs;
  final RxBool hasPrevPage = false.obs;
  final RxInt totalPayments = 0.obs;
  final RxBool isLoadingMore = false.obs;

  // Payment processing
  final RxBool isProcessingPayment = false.obs;
  final RxString paymentError = ''.obs;
  final RxString paymentSuccess = ''.obs;

  // Payment status polling
  final RxMap<String, bool> isPollingStatus = <String, bool>{}.obs;

  // Singleton instance getter
  static PaymentController get instance {
    return Get.find<PaymentController>();
  }

  @override
  void onInit() {
    super.onInit();
    // Initialize any required setup
  }

  @override
  void onClose() {
    clearAll();
    super.onClose();
  }

  // Statistics
  double get totalPaidAmount {
    return payments.fold(
      0,
      (sum, payment) => payment.isPaid ? sum + payment.amount : sum,
    );
  }

  double get totalPendingAmount {
    return payments.fold(
      0,
      (sum, payment) => payment.isPending || payment.isProcessing
          ? sum + payment.amount
          : sum,
    );
  }

  int get successfulPaymentsCount {
    return payments.where((payment) => payment.isPaid).length;
  }

  int get failedPaymentsCount {
    return payments.where((payment) => payment.isFailed).length;
  }

  int get pendingPaymentsCount {
    return payments
        .where((payment) => payment.isPending || payment.isProcessing)
        .length;
  }

  // Fetch payments by loan
  Future<void> fetchPaymentsByLoan({
    required String loanId,
    bool refresh = false,
  }) async {
    try {
      if (refresh) {
        currentPage.value = 1;
        if (loanPayments.containsKey(loanId)) {
          loanPayments[loanId]!.clear();
        }
      }

      isLoading.value = true;
      errorMessage.value = '';

      print('DEBUG: Payment Controller - Fetching payments for loan: $loanId');

      final response = await PaymentService.getPaymentsByLoan(
        loanId: loanId,
        page: currentPage.value,
        limit: 10,
      );

      if (response.success && response.data != null) {
        print(
          'DEBUG: Payment Controller - Successfully fetched ${response.data!.payments.length} payments',
        );

        final List<PaymentModel> fetchedPayments = response.data!.payments;

        if (loanPayments.containsKey(loanId)) {
          loanPayments[loanId]!.addAll(fetchedPayments);
        } else {
          loanPayments[loanId] = fetchedPayments;
        }

        // Also update main payments list
        payments.value = fetchedPayments;

        totalPayments.value = response.data!.pagination.total;
        totalPages.value = response.data!.pagination.totalPages;
        hasNextPage.value = response.data!.pagination.hasNextPage;
        hasPrevPage.value = response.data!.pagination.hasPrevPage;
      } else {
        errorMessage.value = response.message ?? 'Failed to load payments';
        print('DEBUG: Payment Controller - Error: $errorMessage');
        Get.snackbar('Error', errorMessage.value);
      }
    } catch (e) {
      errorMessage.value = 'Failed to load payments: ${e.toString()}';
      print('DEBUG: Payment Controller - Exception: $errorMessage');
      Get.snackbar('Error', errorMessage.value);
    } finally {
      isLoading.value = false;
      print('DEBUG: Payment Controller - Loading completed');
    }
  }

  // Fetch payments by customer
  Future<void> fetchPaymentsByCustomer({bool refresh = false}) async {
    try {
      if (refresh) {
        currentPage.value = 1;
        payments.clear();
      }

      isLoading.value = true;
      errorMessage.value = '';

      // Get customer ID from cache
      final customerId = await CacheUtils.getUserId();

      if (customerId == null || customerId.isEmpty) {
        errorMessage.value = 'Customer ID not found';
        isLoading.value = false;
        return;
      }

      print(
        'DEBUG: Payment Controller - Fetching payments for customer: $customerId',
      );

      final response = await PaymentService.getPaymentsByCustomer(
        customerId: customerId,
        page: currentPage.value,
        limit: 10,
      );

      if (response.success && response.data != null) {
        print(
          'DEBUG: Payment Controller - Successfully fetched ${response.data!.payments.length} payments',
        );

        payments.value = response.data!.payments;

        totalPayments.value = response.data!.pagination.total;
        totalPages.value = response.data!.pagination.totalPages;
        hasNextPage.value = response.data!.pagination.hasNextPage;
        hasPrevPage.value = response.data!.pagination.hasPrevPage;
      } else {
        errorMessage.value = response.message ?? 'Failed to load payments';
        print('DEBUG: Payment Controller - Error: $errorMessage');
        Get.snackbar('Error', errorMessage.value);
      }
    } catch (e) {
      errorMessage.value = 'Failed to load payments: ${e.toString()}';
      print('DEBUG: Payment Controller - Exception: $errorMessage');
      Get.snackbar('Error', errorMessage.value);
    } finally {
      isLoading.value = false;
      print('DEBUG: Payment Controller - Loading completed');
    }
  }

  // Load more payments
  Future<void> loadMorePayments({bool isCustomerPayments = true}) async {
    if (isLoadingMore.value || !hasNextPage.value) return;

    try {
      isLoadingMore.value = true;
      currentPage.value++;

      if (isCustomerPayments) {
        final customerId = await CacheUtils.getUserId();

        if (customerId == null || customerId.isEmpty) {
          isLoadingMore.value = false;
          return;
        }

        final response = await PaymentService.getPaymentsByCustomer(
          customerId: customerId,
          page: currentPage.value,
          limit: 10,
        );

        if (response.success && response.data != null) {
          payments.addAll(response.data!.payments);
          hasNextPage.value = response.data!.pagination.hasNextPage;
          hasPrevPage.value = response.data!.pagination.hasPrevPage;
        } else {
          currentPage.value--;
          Get.snackbar('Error', 'Failed to load more payments');
        }
      } else {
        // For loan payments, we need the loan ID
        // This would need to be implemented differently based on your needs
        Get.snackbar('Info', 'Load more for loan payments not implemented');
      }
    } catch (e) {
      currentPage.value--;
      Get.snackbar('Error', 'Failed to load more payments');
    } finally {
      isLoadingMore.value = false;
    }
  }

  Future<Map<String, dynamic>?> createPayment({
    required String loanId,
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
    try {
      isProcessingPayment.value = true;
      paymentError.value = '';
      paymentSuccess.value = '';

      print(
        'DEBUG: Payment Controller - Creating payment for loan: $loanId, amount: $amount',
      );

      final response = await PaymentService.createPayment(
        loanId: loanId,
        amount: amount,
        provider: provider,
        method: method,
        currency: currency,
        interestComponent: interestComponent,
        principalComponent: principalComponent,
        storageComponent: storageComponent,
        penaltyComponent: penaltyComponent,
        notes: notes,
        phoneNumber: phoneNumber,
      );

      if (response.success && response.data != null) {
        paymentSuccess.value =
            'Payment created successfully! Reference: ${response.data!['reference']}';

        // Refresh payments list
        await fetchPaymentsByLoan(loanId: loanId, refresh: true);

        // If payment has pollUrl, start polling for status
        if (response.data!.containsKey('pollUrl') &&
            response.data!['pollUrl'] != null) {
          final paymentId = response.data!['_id'];
          if (paymentId != null) {
            startPaymentStatusPolling(paymentId);
          }
        }

        return response.data;
      } else {
        paymentError.value = response.message ?? 'Payment creation failed';
        Get.snackbar('Payment Error', paymentError.value);
        return null;
      }
    } catch (e) {
      paymentError.value = 'Payment creation failed: ${e.toString()}';
      Get.snackbar('Payment Error', paymentError.value);
      return null;
    } finally {
      isProcessingPayment.value = false;
    }
  }

  // Get payment details
  Future<PaymentModel?> getPaymentDetails(String paymentId) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      final response = await PaymentService.getPaymentById(paymentId);

      if (response.success && response.data != null) {
        selectedPayment.value = response.data;
        return response.data;
      } else {
        errorMessage.value =
            response.message ?? 'Failed to load payment details';
        Get.snackbar('Error', errorMessage.value);
        return null;
      }
    } catch (e) {
      errorMessage.value = 'Failed to load payment details: ${e.toString()}';
      Get.snackbar('Error', errorMessage.value);
      return null;
    } finally {
      isLoading.value = false;
    }
  }

  // Check payment status
  Future<Map<String, dynamic>?> checkPaymentStatus(String paymentId) async {
    try {
      isPollingStatus[paymentId] = true;

      final response = await PaymentService.checkPaymentStatus(paymentId);

      if (response.success && response.data != null) {
        // Update payment in list if found
        final index = payments.indexWhere((p) => p.id == paymentId);
        if (index != -1) {
          // Create updated payment
          final updatedPayment = PaymentModel.fromMap(response.data!);
          payments[index] = updatedPayment;

          // Update selected payment if it's the same
          if (selectedPayment.value != null &&
              selectedPayment.value!.id == paymentId) {
            selectedPayment.value = updatedPayment;
          }

          // Update loan payments
          for (final loanId in loanPayments.keys) {
            final loanPaymentIndex = loanPayments[loanId]!.indexWhere(
              (p) => p.id == paymentId,
            );
            if (loanPaymentIndex != -1) {
              loanPayments[loanId]![loanPaymentIndex] = updatedPayment;
              loanPayments.refresh();
            }
          }
        }

        return response.data;
      } else {
        print('DEBUG: Payment status check failed: ${response.message}');
        return null;
      }
    } catch (e) {
      print('DEBUG: Error checking payment status: $e');
      return null;
    } finally {
      isPollingStatus[paymentId] = false;
      isPollingStatus.refresh();
    }
  }

  // Start payment status polling (for PayNow payments)
  void startPaymentStatusPolling(String paymentId) {
    if (isPollingStatus[paymentId] == true) return;

    // Poll every 5 seconds for up to 2 minutes
    int pollCount = 0;
    const maxPolls = 24; // 24 * 5 seconds = 2 minutes

    Future.doWhile(() async {
      if (pollCount >= maxPolls) return false;

      await Future.delayed(const Duration(seconds: 5));

      final statusResult = await checkPaymentStatus(paymentId);

      if (statusResult != null) {
        final status = statusResult['payment_status'];
        // Stop polling if payment is no longer pending/processing
        if (status != 'pending' && status != 'processing') {
          Get.snackbar('Payment Status', 'Payment is now $status');
          return false;
        }
      }

      pollCount++;
      return true;
    });
  }

  // Get payments for specific loan
  List<PaymentModel> getPaymentsForLoan(String loanId) {
    return loanPayments[loanId] ?? [];
  }

  // Clear selected payment
  void clearSelectedPayment() {
    selectedPayment.value = null;
  }

  // Clear all state
  void clearAll() {
    payments.clear();
    selectedPayment.value = null;
    loanPayments.clear();
    isLoading.value = false;
    errorMessage.value = '';
    paymentError.value = '';
    paymentSuccess.value = '';
    currentPage.value = 1;
    totalPages.value = 1;
    hasNextPage.value = false;
    hasPrevPage.value = false;
    totalPayments.value = 0;
    isProcessingPayment.value = false;
    isPollingStatus.clear();
  }
}
