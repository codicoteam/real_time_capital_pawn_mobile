// features/payments_mngmt/controllers/payments_mngmt_controller.dart

import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:real_time_pawn/core/utils/pallete.dart';
import 'package:real_time_pawn/core/utils/shared_pref_methods.dart';
import 'package:real_time_pawn/features/payments_mngmt/services/payments_mngmt_service.dart';
import 'package:real_time_pawn/models/payment_mngmt_model.dart';
import 'dart:async';

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

  // Auto-refresh timer for pending payments
  Timer? _autoRefreshTimer;

  @override
  void onInit() {
    super.onInit();
    _startAutoRefresh();
  }

  @override
  void onClose() {
    _autoRefreshTimer?.cancel();
    clearAll();
    super.onClose();
  }

  // Start auto-refresh for pending payments (every 10 seconds)
  void _startAutoRefresh() {
    _autoRefreshTimer?.cancel();
    _autoRefreshTimer = Timer.periodic(const Duration(seconds: 10), (timer) {
      _refreshPendingPayments();
    });
  }

  // Auto-refresh only pending payments
  Future<void> _refreshPendingPayments() async {
    // Get all pending payments from current lists
    final allPendingPayments = <PaymentModel>[];

    // Check main payments list
    allPendingPayments.addAll(
      payments.where((p) => p.isPending || p.isProcessing).toList(),
    );

    // Check selected payment if pending
    if (selectedPayment.value != null &&
        (selectedPayment.value!.isPending ||
            selectedPayment.value!.isProcessing)) {
      if (!allPendingPayments.any((p) => p.id == selectedPayment.value!.id)) {
        allPendingPayments.add(selectedPayment.value!);
      }
    }

    // Check loan payments
    for (final loanId in loanPayments.keys) {
      allPendingPayments.addAll(
        loanPayments[loanId]!
            .where((p) => p.isPending || p.isProcessing)
            .toList(),
      );
    }

    // Check payments by loan
    for (final loanId in paymentsByLoan.keys) {
      allPendingPayments.addAll(
        paymentsByLoan[loanId]!
            .where((p) => p.isPending || p.isProcessing)
            .toList(),
      );
    }

    // Remove duplicates
    final uniquePendingIds = <String>{};
    final uniquePendingPayments = <PaymentModel>[];

    for (var payment in allPendingPayments) {
      if (uniquePendingIds.add(payment.id)) {
        uniquePendingPayments.add(payment);
      }
    }

    if (uniquePendingPayments.isNotEmpty) {
      print(
        '🔄 Auto-refreshing ${uniquePendingPayments.length} pending payments',
      );

      for (var payment in uniquePendingPayments) {
        await checkPaymentStatus(payment.id, showNotification: true);
        await Future.delayed(
          const Duration(milliseconds: 500),
        ); // Small delay to avoid rate limiting
      }
    }
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

        // Update the main payments list
        payments.value = fetchedPayments;

        // Update pagination values
        totalPayments.value = response.data!.pagination.total;
        totalPages.value = response.data!.pagination.totalPages;
        hasNextPage.value = response.data!.pagination.hasNextPage;
        hasPrevPage.value = response.data!.pagination.hasPrevPage;

        print(
          '📊 Pagination - Page: ${currentPage.value}, HasNext: $hasNextPage, Total: $totalPayments',
        );

        // Check status of any pending payments in this list
        _checkPendingPaymentsInList(fetchedPayments);
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

        // Check status of any pending payments in this list
        _checkPendingPaymentsInList(fetchedPayments);
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

  // Check pending payments in a list and queue them for status check
  void _checkPendingPaymentsInList(List<PaymentModel> paymentList) {
    final pendingPayments = paymentList
        .where((p) => p.isPending || p.isProcessing)
        .toList();

    if (pendingPayments.isNotEmpty) {
      print(
        '🔍 Found ${pendingPayments.length} pending payments, will check status',
      );

      // Check each pending payment after a short delay
      for (var i = 0; i < pendingPayments.length; i++) {
        Future.delayed(Duration(seconds: 2 + i), () {
          checkPaymentStatus(pendingPayments[i].id, showNotification: false);
        });
      }
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

          // Check pending payments in new batch
          _checkPendingPaymentsInList(response.data!.payments);
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

          // Check pending payments in new batch
          _checkPendingPaymentsInList(response.data!.payments);
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

        // Start automatic polling for status
        final paymentId =
            response.data!['_id'] ?? response.data!['payment']?['_id'];
        if (paymentId != null) {
          startPaymentStatusPolling(paymentId);
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

        // If payment is pending, start auto-refresh
        if (response.data!.isPending || response.data!.isProcessing) {
          startPaymentStatusPolling(paymentId);
        }

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
  // METHOD 6: Check payment status (FIXED with proper error handling)
  // ============================================
  Future<Map<String, dynamic>?> checkPaymentStatus(
    String paymentId, {
    bool showNotification = true,
  }) async {
    try {
      isPollingStatus[paymentId] = true;

      print('🔍 Checking payment status for: $paymentId');

      final response = await PaymentService.checkPaymentStatus(paymentId);

      if (response.success && response.data != null) {
        final gatewayStatus = response.data!['gateway_status']?.toString();
        final paymentData = response.data!['payment'];

        print('✅ Payment status check successful');
        print('📊 Gateway status: $gatewayStatus');

        if (paymentData != null) {
          // Create updated payment model
          final updatedPayment = PaymentModel.fromMap(paymentData);

          // Track if notification should be shown
          bool shouldShowNotification = false;

          // Update in main payments list
          final index = payments.indexWhere((p) => p.id == paymentId);
          if (index != -1) {
            final oldStatus = payments[index].paymentStatus;
            payments[index] = updatedPayment;
            payments.refresh();
            print(
              '✅ Updated payment in main list: $oldStatus → ${updatedPayment.paymentStatus}',
            );

            // Check if status changed and not pending
            if (showNotification && oldStatus != updatedPayment.paymentStatus) {
              if (!updatedPayment.isPending && !updatedPayment.isProcessing) {
                shouldShowNotification = true;
              }
            }
          }

          // Update selected payment if it's the same
          if (selectedPayment.value != null &&
              selectedPayment.value!.id == paymentId) {
            final oldStatus = selectedPayment.value!.paymentStatus;
            selectedPayment.value = updatedPayment;
            print(
              '✅ Updated selected payment: $oldStatus → ${updatedPayment.paymentStatus}',
            );

            // Check if status changed and not pending
            if (showNotification && oldStatus != updatedPayment.paymentStatus) {
              if (!updatedPayment.isPending && !updatedPayment.isProcessing) {
                shouldShowNotification = true;
              }
            }
          }

          // Update loan payments
          for (final loanId in loanPayments.keys.toList()) {
            final loanPaymentIndex = loanPayments[loanId]!.indexWhere(
              (p) => p.id == paymentId,
            );
            if (loanPaymentIndex != -1) {
              loanPayments[loanId]![loanPaymentIndex] = updatedPayment;
              loanPayments.refresh();
            }
          }

          // Update payments by loan
          for (final loanId in paymentsByLoan.keys.toList()) {
            final loanPaymentIndex = paymentsByLoan[loanId]!.indexWhere(
              (p) => p.id == paymentId,
            );
            if (loanPaymentIndex != -1) {
              paymentsByLoan[loanId]![loanPaymentIndex] = updatedPayment;
              paymentsByLoan.refresh();
            }
          }

          // Show notification if needed
          if (shouldShowNotification) {
            _showStatusNotification(updatedPayment);
          }
        }

        return response.data;
      } else {
        // Handle the validation error gracefully
        if (response.message?.contains('validation failed') == true ||
            response.message?.contains('not a valid enum value') == true) {
          print('⚠️ Backend validation error: ${response.message}');

          // Check if this is the "sent" status issue
          if (response.message?.contains('sent') == true) {
            print(
              '📌 Payment is in "sent" state - this is a temporary state, continuing to poll',
            );

            // Don't treat as failure - the payment is still processing
            // Just return null and continue polling
            return null;
          }
        } else {
          print('❌ Payment status check failed: ${response.message}');
        }
        return null;
      }
    } catch (e) {
      print('❌ Error checking payment status: $e');
      return null;
    } finally {
      isPollingStatus[paymentId] = false;
      isPollingStatus.refresh();
    }
  }

  // Show notification to user about payment status change
  void _showStatusNotification(PaymentModel payment) {
    String message;
    Color color;

    switch (payment.paymentStatus.toLowerCase()) {
      case 'paid':
      case 'completed':
      case 'successful':
        message = '✅ Payment successful! Reference: ${payment.reference}';
        color = RealTimeColors.success;
        break;
      case 'cancelled':
        message = '❌ Payment was cancelled. Please try again.';
        color = RealTimeColors.warning;
        break;
      case 'failed':
        message = '❌ Payment failed. Insufficient funds or transaction error.';
        color = RealTimeColors.error;
        break;
      default:
        return; // Don't show notification for other statuses
    }

    Get.snackbar(
      'Payment Update',
      message,
      backgroundColor: color,
      colorText: Colors.white,
      snackPosition: SnackPosition.TOP,
      duration: const Duration(seconds: 4),
    );
  }

  // ============================================
  // METHOD 7: Start automatic payment status polling
  // ============================================
  void startPaymentStatusPolling(String paymentId) {
    if (isPollingStatus[paymentId] == true) return;

    print('🔄 Starting automatic payment status polling for: $paymentId');

    int pollCount = 0;
    const maxPolls = 24; // 24 * 5 seconds = 2 minutes

    Future.doWhile(() async {
      if (pollCount >= maxPolls) {
        print('⏱️ Polling stopped after $maxPolls attempts');
        return false;
      }

      await Future.delayed(const Duration(seconds: 5));

      final statusResult = await checkPaymentStatus(
        paymentId,
        showNotification: true,
      );

      if (statusResult != null) {
        final paymentData = statusResult['payment'];
        final paymentStatus = paymentData?['payment_status']
            ?.toString()
            .toLowerCase();

        print('📊 Poll #${pollCount + 1}: Status = $paymentStatus');

        // Stop polling if payment is no longer pending/processing
        if (paymentStatus != 'pending' && paymentStatus != 'processing') {
          print('✅ Payment reached final state: $paymentStatus');
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
