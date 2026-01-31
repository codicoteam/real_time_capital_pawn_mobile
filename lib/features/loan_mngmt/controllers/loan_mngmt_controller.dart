import 'package:get/get.dart';
import 'package:real_time_pawn/features/loan_mngmt/services/loan_mngmt_service.dart';
import 'package:real_time_pawn/models/loan_mngmt_model.dart';

class LoanController extends GetxController {
  // State
  final RxList<LoanModel> loans = <LoanModel>[].obs;
  final Rx<LoanModel?> selectedLoan = Rx<LoanModel?>(null);
  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;
  final RxString selectedFilter = 'All'.obs;
  final RxString searchQuery = ''.obs;

  // Pagination
  final RxInt currentPage = 1.obs;
  final RxInt totalPages = 1.obs;
  final RxBool hasNextPage = false.obs;
  final RxBool hasPrevPage = false.obs;
  final RxInt totalLoans = 0.obs;
  final RxBool isLoadingMore = false.obs;

  // Statistics
  double get totalOutstandingBalance {
    return loans.fold(0, (sum, loan) => sum + loan.currentBalance);
  }

  int get activeLoansCount {
    return loans.where((loan) => loan.isActive).length;
  }

  int get overdueLoansCount {
    return loans.where((loan) => loan.isOverdue).length;
  }

  int get settledLoansCount {
    return loans.where((loan) => loan.isSettled).length;
  }

  // Filtered loans
  List<LoanModel> get filteredLoans {
    if (searchQuery.value.isNotEmpty) {
      final query = searchQuery.value.toLowerCase();
      return loans.where((loan) {
        return loan.loanNo.toLowerCase().contains(query) ||
            loan.customerName.toLowerCase().contains(query);
      }).toList();
    }

    switch (selectedFilter.value) {
      case 'Active':
        return loans.where((loan) => loan.isActive).toList();
      case 'Overdue':
        return loans.where((loan) => loan.isOverdue).toList();
      case 'Settled':
        return loans.where((loan) => loan.isSettled).toList();
      default:
        return loans;
    }
  }

  // Fetch customer loans
  // Fetch customer loans
  Future<void> fetchCustomerLoans({bool refresh = false}) async {
    try {
      if (refresh) {
        currentPage.value = 1;
        loans.clear();
      }

      isLoading.value = true;
      errorMessage.value = '';

      print('DEBUG: Controller - Starting fetchCustomerLoans');
      print('DEBUG: Selected filter: ${selectedFilter.value}');

      final response = await LoanService.getCustomerLoans(
        page: currentPage.value,
        limit: 10,
        status: selectedFilter.value != 'All' ? selectedFilter.value : null,
      );

      if (response.success && response.data != null) {
        // Access loans and pagination from LoanListData
        print(
          'DEBUG: Controller - Response success, loans count: ${response.data!.loans.length}',
        );
        print(
          'DEBUG: Controller - First loan: ${response.data!.loans.isNotEmpty ? response.data!.loans.first.loanNo : "No loans"}',
        );

        loans.value = response.data!.loans;
        totalLoans.value = response.data!.pagination.total;
        totalPages.value = response.data!.pagination.totalPages;
        hasNextPage.value = response.data!.pagination.hasNextPage;
        hasPrevPage.value = response.data!.pagination.hasPrevPage;

        print('DEBUG: Controller - Updated loans list: ${loans.length} loans');
        print('DEBUG: Controller - Total loans: ${totalLoans.value}');
      } else {
        errorMessage.value = response.message ?? 'Failed to load loans';
        print('DEBUG: Controller - Error: $errorMessage');
        Get.snackbar('Error', errorMessage.value);
      }
    } catch (e) {
      errorMessage.value = 'Failed to load loans: ${e.toString()}';
      print('DEBUG: Controller - Exception: $errorMessage');
      Get.snackbar('Error', errorMessage.value);
    } finally {
      isLoading.value = false;
      print('DEBUG: Controller - Loading completed');
    }
  }

  // Load more loans
  Future<void> loadMoreLoans() async {
    if (isLoadingMore.value || !hasNextPage.value) return;

    try {
      isLoadingMore.value = true;
      currentPage.value++;

      final response = await LoanService.getCustomerLoans(
        page: currentPage.value,
        limit: 10,
        status: selectedFilter.value != 'All' ? selectedFilter.value : null,
      );

      if (response.success && response.data != null) {
        loans.addAll(response.data!.loans);
        hasNextPage.value = response.data!.pagination.hasNextPage;
        hasPrevPage.value = response.data!.pagination.hasPrevPage;
      } else {
        currentPage.value--;
        Get.snackbar('Error', 'Failed to load more loans');
      }
    } catch (e) {
      currentPage.value--;
      Get.snackbar('Error', 'Failed to load more loans');
    } finally {
      isLoadingMore.value = false;
    }
  }

  // Get loan details by ID
  Future<LoanModel?> getLoanDetails(String loanId) async {
    try {
      final response = await LoanService.getLoanById(loanId);

      if (response.success && response.data != null) {
        // FIX: response.data is already LoanModel, not LoanData
        selectedLoan.value = response.data; // Not response.data!.loan
        return response.data; // Not response.data!.loan
      } else {
        errorMessage.value = response.message ?? 'Failed to load loan details';
        Get.snackbar('Error', errorMessage.value);
        return null;
      }
    } catch (e) {
      errorMessage.value = 'Failed to load loan details: ${e.toString()}';
      Get.snackbar('Error', errorMessage.value);
      return null;
    }
  }

  // Calculate loan charges
  Future<Map<String, dynamic>?> calculateLoanCharges(String loanId) async {
    try {
      final response = await LoanService.calculateLoanCharges(loanId);

      if (response.success && response.data != null) {
        return response.data;
      } else {
        errorMessage.value = response.message ?? 'Failed to calculate charges';
        Get.snackbar('Error', errorMessage.value);
        return null;
      }
    } catch (e) {
      errorMessage.value = 'Failed to calculate charges: ${e.toString()}';
      Get.snackbar('Error', errorMessage.value);
      return null;
    }
  }

  // Process loan payment
  Future<Map<String, dynamic>?> processLoanPayment({
    required String loanId,
    required double amount,
    required String paymentMethod,
    String? provider,
    String? phoneNumber,
    String? accountNumber,
  }) async {
    try {
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
        await fetchCustomerLoans(refresh: true);
        if (selectedLoan.value != null && selectedLoan.value!.id == loanId) {
          await getLoanDetails(loanId);
        }

        return response.data;
      } else {
        errorMessage.value = response.message ?? 'Payment failed';
        Get.snackbar('Payment Error', errorMessage.value);
        return null;
      }
    } catch (e) {
      errorMessage.value = 'Payment failed: ${e.toString()}';
      Get.snackbar('Payment Error', errorMessage.value);
      return null;
    }
  }

  // Update loan status
  Future<bool> updateLoanStatus({
    required String loanId,
    required String status,
    String? notes,
  }) async {
    try {
      final response = await LoanService.updateLoanStatus(
        loanId: loanId,
        status: status,
        notes: notes,
      );

      if (response.success && response.data == true) {
        // Refresh loan data
        await fetchCustomerLoans(refresh: true);
        if (selectedLoan.value != null && selectedLoan.value!.id == loanId) {
          await getLoanDetails(loanId);
        }

        Get.snackbar('Success', 'Loan status updated successfully');
        return true;
      } else {
        errorMessage.value = response.message ?? 'Failed to update status';
        Get.snackbar('Error', errorMessage.value);
        return false;
      }
    } catch (e) {
      errorMessage.value = 'Failed to update status: ${e.toString()}';
      Get.snackbar('Error', errorMessage.value);
      return false;
    }
  }

  // Set filter
  void setFilter(String filter) {
    selectedFilter.value = filter;
    fetchCustomerLoans(refresh: true);
  }

  // Set search query
  void setSearchQuery(String query) {
    searchQuery.value = query;
  }

  // Clear search
  void clearSearch() {
    searchQuery.value = '';
  }

  // Select loan
  void selectLoan(LoanModel loan) {
    selectedLoan.value = loan;
  }

  // Clear selected loan
  void clearSelectedLoan() {
    selectedLoan.value = null;
  }
}
