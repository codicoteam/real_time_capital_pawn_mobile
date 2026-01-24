// loan_application_mngmt_controller.dart
import 'package:get/get.dart';
import '../../../core/utils/api_response.dart';
import '../../../core/utils/logs.dart';
import '../../../models/loan_application.model.dart';
import '../services/loan_application_mngmt_service.dart'
    show LoanApplicationService;

class LoanApplicationController extends GetxController {
  // =====================
  // Observable states
  // =====================
  var isLoading = false.obs;
  var successMessage = ''.obs;
  var errorMessage = ''.obs;

  // =====================
  // Loan applications list
  // =====================
  var loanApplications = <LoanApplicationModel>[].obs;

  // =====================
  // Search & filter
  // =====================
  final RxString searchQuery = ''.obs;
  final RxString searchType = 'applicationNumber'.obs;
  // example types: applicationNumber, status, amount

  // =====================
  // Create loan application
  // =====================
  Future<APIResponse<LoanApplicationModel>> createLoanApplication(
    Map<String, dynamic> payload,
  ) async {
    try {
      isLoading(true);

      final response = await LoanApplicationService.createLoanApplication(
        payload: payload,
      );

      if (response.success) {
        successMessage.value = response.message!;
        // Optionally add new loan to list
        if (response.data != null) {
          loanApplications.insert(0, response.data!);
        }
        return response;
      } else {
        errorMessage.value = response.message!;
        DevLogs.logError(errorMessage.value);
        return response;
      }
    } catch (e) {
      DevLogs.logError('Create loan application error: $e');
      errorMessage.value = 'An error occurred while creating loan application';
      return APIResponse<LoanApplicationModel>(
        success: false,
        message: errorMessage.value,
      );
    } finally {
      isLoading(false);
    }
  }

  // =====================
  // Fetch loan applications by customer
  // =====================
  Future<void> fetchLoanApplicationsByCustomer(
    String customerUserId, {
    String sortBy = 'created_at',
    String sortOrder = 'desc',
  }) async {
    try {
      isLoading(true);

      final response =
          await LoanApplicationService.getLoanApplicationsByCustomer(
            customerUserId: customerUserId,
            sortBy: sortBy,
            sortOrder: sortOrder,
          );

      if (response.success) {
        loanApplications.value = response.data ?? [];
        successMessage.value =
            response.message ?? 'Loan applications loaded successfully';
      } else {
        errorMessage.value = response.message!;
      }
    } catch (e) {
      DevLogs.logError('Fetch loan applications error: $e');
      errorMessage.value = 'An error occurred while fetching loan applications';
    } finally {
      isLoading(false);
    }
  }

  // =====================
  // Update loan application
  // =====================
  Future<APIResponse<LoanApplicationModel>> updateLoanApplication({
    required String loanApplicationId,
    required Map<String, dynamic> payload,
  }) async {
    try {
      isLoading(true);

      final response = await LoanApplicationService.updateLoanApplication(
        loanApplicationId: loanApplicationId,
        payload: payload,
      );

      if (response.success && response.data != null) {
        successMessage.value = response.message!;

        // Update item in list
        final index = loanApplications.indexWhere(
          (e) => e.id == loanApplicationId,
        );
        if (index != -1) {
          loanApplications[index] = response.data!;
        }

        return response;
      } else {
        errorMessage.value = response.message!;
        return response;
      }
    } catch (e) {
      DevLogs.logError('Update loan application error: $e');
      errorMessage.value = 'An error occurred while updating loan application';
      return APIResponse<LoanApplicationModel>(
        success: false,
        message: errorMessage.value,
      );
    } finally {
      isLoading(false);
    }
  }

  // =====================
  // Refresh
  // =====================
  Future<void> refreshLoans(String customerUserId) async {
    await fetchLoanApplicationsByCustomer(customerUserId);
  }

  // =====================
  // Search logic
  // =====================
  List<LoanApplicationModel> get filteredLoanApplications {
    if (searchQuery.value.isEmpty) {
      return loanApplications;
    }

    final query = searchQuery.value.toLowerCase();

    return loanApplications.where((loan) {
      switch (searchType.value) {
        case 'applicationNo':
          return loan.applicationNo?.toLowerCase().contains(query) ?? false;

        case 'fullName':
          return loan.fullName?.toLowerCase().contains(query) ?? false;

        case 'nationalId':
          return loan.nationalIdNumber?.toLowerCase().contains(query) ?? false;

        case 'status':
          return loan.status?.toLowerCase().contains(query) ?? false;

        case 'amount':
          return loan.requestedLoanAmount?.toString().contains(query) ?? false;

        case 'customerName':
          final firstName = loan.customerUser?.firstName?.toLowerCase() ?? '';
          final lastName = loan.customerUser?.lastName?.toLowerCase() ?? '';
          return ('$firstName $lastName').contains(query);

        default:
          return false;
      }
    }).toList();
  }

  // =====================
  // Search helpers
  // =====================
  void updateSearchQuery(String query) {
    searchQuery.value = query;
  }

  void updateSearchType(String type) {
    searchType.value = type;
  }

  void clearSearch() {
    searchQuery.value = '';
  }
}
