// features/payments_mngmt/controllers/payments_mngmt_controller.dart - COMPLETE MERGED VERSION

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

  // Grouped by loan (for customer-wide view)
  final RxMap<String, List<PaymentModel>> paymentsByLoan =
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

  // Get unique loans from payments (for customer-wide view)
  List<Map<String, dynamic>> get uniqueLoans {
    final Map<String, Map<String, dynamic>> loanMap = {};

    for (var payment in payments) {
      if (payment.loanId.isNotEmpty) {
        if (!loanMap.containsKey(payment.loanId)) {
          loanMap[payment.loanId] = {
            'id': payment.loanId,
            'number': payment.loanNumber,
            'principal': payment.loanPrincipal,
            'customerName': payment.customerName,
          };
        }
      }
    }

    return loanMap.values.toList();
  }

  // ============================================
  // METHOD 1: Fetch payments for a specific loan
  // ============================================
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

      print(
        '📄 Fetching payments for loan: $loanId, page: ${currentPage.value}',
      );

      final response = await PaymentService.getPaymentsByLoan(
        loanId: loanId,
        page: currentPage.value,
        limit: 10,
      );

      if (response.success && response.data != null) {
        print(
          '✅ Successfully fetched ${response.data!.payments.length} payments',
        );

        final List<PaymentModel> fetchedPayments = response.data!.payments;

        if (loanPayments.containsKey(loanId)) {
          loanPayments[loanId]!.addAll(fetchedPayments);
        } else {
          loanPayments[loanId] = fetchedPayments;
        }

        // ✅ Update the main payments list
        payments.value = fetchedPayments;

        // ✅ Update pagination values
        totalPayments.value = response.data!.pagination.total;
        totalPages.value = response.data!.pagination.totalPages;
        hasNextPage.value = response.data!.pagination.hasNextPage;
        hasPrevPage.value = response.data!.pagination.hasPrevPage;

        print(
          '📊 Pagination - Page: ${currentPage.value}, HasNext: $hasNextPage, Total: $totalPayments',
        );
      } else {
        errorMessage.value = response.message ?? 'Failed to load payments';
        print('❌ Error: $errorMessage');
      }
    } catch (e) {
      errorMessage.value = 'Failed to load payments: ${e.toString()}';
      print('❌ Exception: $e');
    } finally {
      isLoading.value = false;
    }
  }

  // ============================================
  // METHOD 2: Fetch all payments for a customer
  // ============================================
  Future<void> fetchPaymentsByCustomer({bool refresh = false}) async {
    try {
      if (refresh) {
        currentPage.value = 1;
        payments.clear();
        paymentsByLoan.clear();
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
        '📄 Fetching payments for customer: $customerId, page: ${currentPage.value}',
      );

      final response = await PaymentService.getPaymentsByCustomer(
        customerId: customerId,
        page: currentPage.value,
        limit: 10,
      );

      if (response.success && response.data != null) {
        print(
          '✅ Successfully fetched ${response.data!.payments.length} payments',
        );

        final fetchedPayments = response.data!.payments;

        // Update main payments list
        if (refresh) {
          payments.value = fetchedPayments;
        } else {
          payments.addAll(fetchedPayments);
        }

        // Group payments by loan
        _groupPaymentsByLoan(fetchedPayments);

        // Update pagination
        totalPayments.value = response.data!.pagination.total;
        totalPages.value = response.data!.pagination.totalPages;
        hasNextPage.value = response.data!.pagination.hasNextPage;
        hasPrevPage.value = response.data!.pagination.hasPrevPage;

        print(
          '📊 Pagination - Page: ${currentPage.value}, Total: $totalPayments, HasNext: $hasNextPage',
        );
      } else {
        errorMessage.value = response.message ?? 'Failed to load payments';
        print('❌ Error: $errorMessage');
        Get.snackbar('Error', errorMessage.value);
      }
    } catch (e) {
      errorMessage.value = 'Failed to load payments: ${e.toString()}';
      print('❌ Exception: $e');
      Get.snackbar('Error', errorMessage.value);
    } finally {
      isLoading.value = false;
    }
  }

  // Helper to group payments by loan
  void _groupPaymentsByLoan(List<PaymentModel> newPayments) {
    for (var payment in newPayments) {
      final loanId = payment.loanId;
      if (loanId.isNotEmpty) {
        if (!paymentsByLoan.containsKey(loanId)) {
          paymentsByLoan[loanId] = [];
        }
        // Avoid duplicates
        if (!paymentsByLoan[loanId]!.any((p) => p.id == payment.id)) {
          paymentsByLoan[loanId]!.add(payment);
        }
      }
    }
    paymentsByLoan.refresh();
  }

  // ============================================
  // METHOD 3: Load more payments (pagination)
  // ============================================
  Future<void> loadMorePayments({
    required bool isCustomerPayments,
    String? loanId,
  }) async {
    if (isLoadingMore.value || !hasNextPage.value) return;

    try {
      isLoadingMore.value = true;
      currentPage.value++;

      if (isCustomerPayments) {
        // Load more customer payments
        final customerId = await CacheUtils.getUserId();
        if (customerId == null || customerId.isEmpty) {
          isLoadingMore.value = false;
          currentPage.value--;
          return;
        }

        final response = await PaymentService.getPaymentsByCustomer(
          customerId: customerId,
          page: currentPage.value,
          limit: 10,
        );

        if (response.success && response.data != null) {
          payments.addAll(response.data!.payments);
          _groupPaymentsByLoan(response.data!.payments);
          hasNextPage.value = response.data!.pagination.hasNextPage;
          totalPages.value = response.data!.pagination.totalPages;
          print('✅ Loaded ${response.data!.payments.length} more payments');
        } else {
          currentPage.value--;
        }
      } else {
        // Load more loan payments
        if (loanId == null) {
          print('❌ Cannot load more loan payments: loanId is null');
          currentPage.value--;
          isLoadingMore.value = false;
          return;
        }

        print(
          '📄 Loading more payments for loan: $loanId, page: ${currentPage.value}',
        );

        final response = await PaymentService.getPaymentsByLoan(
          loanId: loanId,
          page: currentPage.value,
          limit: 10,
        );

        if (response.success && response.data != null) {
          payments.addAll(response.data!.payments);
          hasNextPage.value = response.data!.pagination.hasNextPage;
          totalPages.value = response.data!.pagination.totalPages;
          print('✅ Loaded ${response.data!.payments.length} more payments');
        } else {
          print('❌ Failed to load more payments: ${response.message}');
          currentPage.value--;
        }
      }
    } catch (e) {
      print('❌ Error loading more payments: $e');
      currentPage.value--;
    } finally {
      isLoadingMore.value = false;
    }
  }

  // ============================================
  // METHOD 4: Create payment
  // ============================================
  Future<Map<String, dynamic>?> createPayment({
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
    try {
      isProcessingPayment.value = true;
      paymentError.value = '';
      paymentSuccess.value = '';

      print(
        'DEBUG: Payment Controller - Creating payment for loan: $loanId, amount: $amount',
      );

      final response = await PaymentService.createPayment(
        loanId: loanId,
        loanTermId: loanTermId,
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

  // ============================================
  // METHOD 5: Get payment details by ID
  // ============================================
  Future<PaymentModel?> getPaymentDetails(String paymentId) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      print('🔍 Getting payment details for ID: $paymentId');

      final response = await PaymentService.getPaymentById(paymentId);

      if (response.success && response.data != null) {
        print('✅ Payment details loaded successfully');
        selectedPayment.value = response.data;
        return response.data;
      } else {
        errorMessage.value =
            response.message ?? 'Failed to load payment details';
        print('❌ Payment details failed: ${errorMessage.value}');
        return null;
      }
    } catch (e) {
      errorMessage.value = 'Failed to load payment details';
      print('❌ Exception in getPaymentDetails: $e');
      return null;
    } finally {
      isLoading.value = false;
    }
  }

  // ============================================
  // METHOD 6: Check payment status
  // ============================================
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

          // Update payments by loan
          for (final loanId in paymentsByLoan.keys) {
            final loanPaymentIndex = paymentsByLoan[loanId]!.indexWhere(
              (p) => p.id == paymentId,
            );
            if (loanPaymentIndex != -1) {
              paymentsByLoan[loanId]![loanPaymentIndex] = updatedPayment;
              paymentsByLoan.refresh();
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

  // ============================================
  // METHOD 7: Start payment status polling
  // ============================================
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

  // ============================================
  // HELPER METHODS
  // ============================================

  // Get payments for specific loan (from loanPayments map)
  List<PaymentModel> getPaymentsForLoan(String loanId) {
    return loanPayments[loanId] ?? [];
  }

  // Get payments for specific loan (from paymentsByLoan map - customer view)
  List<PaymentModel> getPaymentsForLoanInCustomerView(String loanId) {
    return paymentsByLoan[loanId] ?? [];
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
    paymentsByLoan.clear();
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
