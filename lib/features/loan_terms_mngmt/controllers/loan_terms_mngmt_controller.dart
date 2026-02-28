// lib/features/loan_terms_mngmt/controllers/loan_terms_mngmt_controller.dart
import 'package:get/get.dart';
import 'package:real_time_pawn/core/utils/logs.dart';
import 'package:real_time_pawn/features/loan_terms_mngmt/services/loan_terms_mngmt_service.dart';
import 'package:real_time_pawn/models/loan_terms_model.dart';

class LoanTermsController extends GetxController {
  // =====================
  // Observable states
  // =====================
  final isLoading = false.obs;
  final errorMessage = ''.obs;

  // =====================
  // Loan terms data
  // =====================
  final loanTerms = <LoanTerm>[].obs;
  final selectedTerm = Rx<LoanTerm?>(null);

  // Simple stats from loaded data
  int get totalTerms => loanTerms.length;
  double get totalOutstandingBalance {
    return loanTerms.fold(0.0, (sum, term) => sum + term.currentBalance);
  }

  // =====================
  // Fetch loan terms by loan ID
  // =====================
  Future<void> fetchLoanTerms(String loanId, {bool refresh = false}) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      DevLogs.logInfo('Fetching loan terms for loan: $loanId');

      final response = await LoanTermsService.getLoanTermsByLoanId(
        loanId,
        page: 1,
        limit: 100,
      );

      if (response.success && response.data != null) {
        loanTerms.assignAll(response.data!);
        DevLogs.logSuccess('Fetched ${response.data!.length} loan terms');
      } else {
        errorMessage.value = response.message ?? 'Failed to load loan terms';
        DevLogs.logError(errorMessage.value);
      }
    } catch (e) {
      errorMessage.value = 'Failed to load loan terms: $e';
      DevLogs.logError(errorMessage.value);
    } finally {
      isLoading.value = false;
    }
  }

  // =====================
  // Get term details by ID
  // =====================
  Future<LoanTerm?> getTermDetails(String termId) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      DevLogs.logInfo('Fetching term details: $termId');

      final response = await LoanTermsService.getTermById(termId);

      if (response.success && response.data != null) {
        selectedTerm.value = response.data;
        DevLogs.logSuccess('Term details fetched successfully');
        return response.data;
      } else {
        errorMessage.value = response.message ?? 'Failed to load term details';
        DevLogs.logError(errorMessage.value);
        return null;
      }
    } catch (e) {
      errorMessage.value = 'Failed to load term details: $e';
      DevLogs.logError(errorMessage.value);
      return null;
    } finally {
      isLoading.value = false;
    }
  }

  // =====================
  // Reset controller
  // =====================
  void reset() {
    loanTerms.clear();
    selectedTerm.value = null;
    isLoading.value = false;
    errorMessage.value = '';
  }
}
