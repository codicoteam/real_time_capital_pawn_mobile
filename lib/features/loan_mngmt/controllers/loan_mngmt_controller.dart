import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/utils/logs.dart';
import '../../../models/loan_mngmt_model.dart';
import '../services/loan_mngmt_service.dart';

class LoanController extends GetxController {
  // =====================
  // Observable states
  // =====================
  final isLoading = false.obs;
  final successMessage = ''.obs;
  final errorMessage = ''.obs;

  // =====================
  // Loans list
  // =====================
  final loans = <LoanModel>[].obs;
  final selectedLoan = Rx<LoanModel?>(null);

  // =====================
  // Search & filter
  // =====================
  final searchQuery = ''.obs;
  final selectedFilter = 'All'.obs;

  // =====================
  // Statistics (computed)
  // =====================

  // =====================
  // Filtered loans (based on search & filter)

  // =====================
  // Fetch customer loans
  // =====================
  Future<void> fetchCustomerLoans({bool refresh = false}) async {
    if (refresh) {
      loans.clear();
    }

    try {
      isLoading.value = true;
      errorMessage.value = '';

      DevLogs.logInfo(
        'Fetching customer loans with filter: ${selectedFilter.value}',
      );

      final response = await LoanService.getCustomerLoans(
        status: selectedFilter.value != 'All' ? selectedFilter.value : null,
      );

      if (response.success && response.data != null) {
        loans.value = response.data!;
        successMessage.value = response.message ?? 'Loans loaded successfully';
        DevLogs.logSuccess('Loaded ${loans.length} loans');
      } else {
        errorMessage.value = response.message ?? 'Failed to load loans';
        DevLogs.logError(errorMessage.value);
        Get.snackbar(
          'Error',
          errorMessage.value,
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    } catch (e) {
      errorMessage.value = 'An error occurred while fetching loans: $e';
      DevLogs.logError(errorMessage.value);
      Get.snackbar(
        'Error',
        errorMessage.value,
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  // =====================
  // Refresh loans
  // =====================
  Future<void> refreshLoans() async {
    await fetchCustomerLoans(refresh: true);
  }

  // =====================
  // Get loan details by ID
  // =====================
  Future<LoanModel?> getLoanDetails(String loanId) async {
    try {
      isLoading.value = true;

      final response = await LoanService.getLoanById(loanId);

      if (response.success && response.data != null) {
        selectedLoan.value = response.data;
        return response.data;
      } else {
        errorMessage.value = response.message ?? 'Failed to load loan details';
        Get.snackbar(
          'Error',
          errorMessage.value,
          snackPosition: SnackPosition.BOTTOM,
        );
        return null;
      }
    } catch (e) {
      errorMessage.value = 'Failed to load loan details: $e';
      Get.snackbar(
        'Error',
        errorMessage.value,
        snackPosition: SnackPosition.BOTTOM,
      );
      return null;
    } finally {
      isLoading.value = false;
    }
  }

  // =====================
  // Calculate loan charges
  // =====================
  // In loan_mngmt_controller.dart - update the calculateLoanCharges method

  Future<Map<String, dynamic>?> calculateLoanCharges(String loanId) async {
    try {
      isLoading.value = true;

      final response = await LoanService.calculateLoanCharges(loanId);

      if (response.success && response.data != null) {
        return response.data;
      } else {
        errorMessage.value = response.message ?? 'Failed to calculate charges';
        // REMOVE THIS SNACKBAR
        // Get.snackbar('Error', errorMessage.value);
        return null;
      }
    } catch (e) {
      errorMessage.value = 'Failed to calculate charges: $e';
      // REMOVE THIS SNACKBAR
      // Get.snackbar('Error', errorMessage.value);
      return null;
    } finally {
      isLoading.value = false;
    }
  }

  // =====================
  // Process loan payment
  // =====================
  Future<Map<String, dynamic>?> processLoanPayment({
    required String loanId,
    required double amount,
    required String paymentMethod,
    String? provider,
    String? phoneNumber,
    String? accountNumber,
  }) async {
    try {
      isLoading.value = true;

      final response = await LoanService.processLoanPayment(
        loanId: loanId,
        amount: amount,
        paymentMethod: paymentMethod,
        provider: provider,
        phoneNumber: phoneNumber,
        accountNumber: accountNumber,
      );

      if (response.success && response.data != null) {
        // Refresh loan data after successful payment
        await refreshLoans();
        if (selectedLoan.value != null && selectedLoan.value!.id == loanId) {
          await getLoanDetails(loanId);
        }

        Get.snackbar(
          'Success',
          'Payment processed successfully',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Get.theme.primaryColor,
          colorText: Colors.white,
        );

        return response.data;
      } else {
        errorMessage.value = response.message ?? 'Payment failed';
        Get.snackbar(
          'Payment Error',
          errorMessage.value,
          snackPosition: SnackPosition.BOTTOM,
        );
        return null;
      }
    } catch (e) {
      errorMessage.value = 'Payment failed: $e';
      Get.snackbar(
        'Payment Error',
        errorMessage.value,
        snackPosition: SnackPosition.BOTTOM,
      );
      return null;
    } finally {
      isLoading.value = false;
    }
  }

  // =====================
  // Update loan status
  // =====================
  Future<bool> updateLoanStatus({
    required String loanId,
    required String status,
    String? notes,
  }) async {
    try {
      isLoading.value = true;

      final response = await LoanService.updateLoanStatus(
        loanId: loanId,
        status: status,
        notes: notes,
      );

      if (response.success && response.data == true) {
        // Refresh loan data
        await refreshLoans();
        if (selectedLoan.value != null && selectedLoan.value!.id == loanId) {
          await getLoanDetails(loanId);
        }

        Get.snackbar(
          'Success',
          'Loan status updated successfully',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Get.theme.primaryColor,
          colorText: Colors.white,
        );
        return true;
      } else {
        errorMessage.value = response.message ?? 'Failed to update status';
        Get.snackbar(
          'Error',
          errorMessage.value,
          snackPosition: SnackPosition.BOTTOM,
        );
        return false;
      }
    } catch (e) {
      errorMessage.value = 'Failed to update status: $e';
      Get.snackbar(
        'Error',
        errorMessage.value,
        snackPosition: SnackPosition.BOTTOM,
      );
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  // =====================
  // Set filter
  // =====================
  void setFilter(String filter) {
    selectedFilter.value = filter;
    fetchCustomerLoans(refresh: true);
  }

  // =====================
  // Set search query
  // =====================
  void setSearchQuery(String query) {
    searchQuery.value = query;
  }

  // =====================
  // Clear search
  // =====================
  void clearSearch() {
    searchQuery.value = '';
  }

  // =====================
  // Clear all filters (reset to default)
  // =====================
  void clearFilters() {
    selectedFilter.value = 'All';
    searchQuery.value = '';
    fetchCustomerLoans(refresh: true);
  }

  // =====================
  // Select loan
  // =====================
  void selectLoan(LoanModel loan) {
    selectedLoan.value = loan;
  }

  // =====================
  // Clear selected loan
  // =====================
  void clearSelectedLoan() {
    selectedLoan.value = null;
  }
}
