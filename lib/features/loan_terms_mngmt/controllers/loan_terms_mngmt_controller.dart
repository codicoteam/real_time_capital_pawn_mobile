// loan_terms_mngmt_controller.dart
// lib/features/loan_terms_mngmt/controllers/loan_terms_controller.dart
import 'package:get/get.dart';
import 'package:real_time_pawn/features/loan_terms_mngmt/services/loan_terms_mngmt_service.dart';
import 'package:real_time_pawn/models/loan_terms_model.dart';

class LoanTermsController extends GetxController {
  // State
  final RxList<LoanTerm> loanTerms = <LoanTerm>[].obs;
  final Rx<LoanTerm?> currentTerm = Rx<LoanTerm?>(null);
  final Rx<LoanTermTimeline?> timeline = Rx<LoanTermTimeline?>(null);
  final Rx<LoanTermStats?> stats = Rx<LoanTermStats?>(null);
  final Rx<LoanTerm?> selectedTerm = Rx<LoanTerm?>(null);
  final RxBool isLoading = false.obs;
  final RxBool isLoadingTimeline = false.obs;
  final RxBool isLoadingStats = false.obs;
  final RxString errorMessage = ''.obs;
  final RxString selectedFilter = 'All'.obs;
  final RxString selectedTypeFilter = 'All'.obs;
  final RxString searchQuery = ''.obs;

  // Pagination
  final RxInt currentPage = 1.obs;
  final RxInt totalPages = 1.obs;
  final RxBool hasNextPage = false.obs;
  final RxBool hasPrevPage = false.obs;
  final RxInt totalTerms = 0.obs;
  final RxBool isLoadingMore = false.obs;

  // Filtered terms
  List<LoanTerm> get filteredTerms {
    if (searchQuery.value.isNotEmpty) {
      final query = searchQuery.value.toLowerCase();
      return loanTerms.where((term) {
        return term.termNo.toLowerCase().contains(query) ||
            term.loanNo.toLowerCase().contains(query) ||
            term.status.toLowerCase().contains(query);
      }).toList();
    }

    List<LoanTerm> filtered = loanTerms;

    // Filter by status
    if (selectedFilter.value != 'All') {
      filtered = filtered.where((term) {
        return term.status.toLowerCase() == selectedFilter.value.toLowerCase();
      }).toList();
    }

    // Filter by term type
    if (selectedTypeFilter.value != 'All') {
      filtered = filtered.where((term) {
        return term.termType.toLowerCase() ==
            selectedTypeFilter.value.toLowerCase();
      }).toList();
    }

    return filtered;
  }

  // Statistics
  double get totalOutstandingBalance {
    return loanTerms.fold(0, (sum, term) => sum + term.currentBalance);
  }

  int get activeTermsCount {
    return loanTerms.where((term) => term.isActive).length;
  }

  int get pendingTermsCount {
    return loanTerms.where((term) => term.isPending).length;
  }

  int get completedTermsCount {
    return loanTerms.where((term) => term.isCompleted).length;
  }

  // Fetch loan terms for a specific loan
  Future<void> fetchLoanTerms(String loanId, {bool refresh = false}) async {
    try {
      if (refresh) {
        currentPage.value = 1;
        loanTerms.clear();
      }

      isLoading.value = true;
      errorMessage.value = '';

      print('DEBUG: Fetching loan terms for loan: $loanId');
      print(
        'DEBUG: Filter: ${selectedFilter.value}, Type: ${selectedTypeFilter.value}',
      );

      final response = await LoanTermsService.getLoanTermsByLoanId(
        loanId,
        page: currentPage.value,
        limit: 100000000,
        status: selectedFilter.value != 'All' ? selectedFilter.value : null,
        termType: selectedTypeFilter.value != 'All'
            ? selectedTypeFilter.value
            : null,
      );

      if (response.success && response.data != null) {
        print('DEBUG: Successfully fetched ${response.data!.length} terms');

        if (refresh) {
          loanTerms.value = response.data!;
        } else {
          loanTerms.addAll(response.data!);
        }

        // Update pagination info (you might need to adjust based on API response)
        totalTerms.value = response.data!.length;
        hasNextPage.value = response.data!.length >= 10;
        hasPrevPage.value = currentPage.value > 1;

        print('DEBUG: Total terms in list: ${loanTerms.length}');

        // Also fetch current term
        await fetchCurrentTerm(loanId);
      } else {
        errorMessage.value = response.message ?? 'Failed to load loan terms';
        print('DEBUG: Error fetching terms: $errorMessage');
        Get.snackbar('Error', errorMessage.value);
      }
    } catch (e) {
      errorMessage.value = 'Failed to load loan terms: ${e.toString()}';
      print('DEBUG: Exception fetching terms: $errorMessage');
      Get.snackbar('Error', errorMessage.value);
    } finally {
      isLoading.value = false;
      print('DEBUG: Loading completed');
    }
  }

  // Fetch current active term
  Future<void> fetchCurrentTerm(String loanId) async {
    try {
      final response = await LoanTermsService.getCurrentTerm(loanId);

      if (response.success && response.data != null) {
        currentTerm.value = response.data;
        print('DEBUG: Current term found: ${currentTerm.value?.termNo}');
      } else {
        currentTerm.value = null;
        print('DEBUG: No current term found');
      }
    } catch (e) {
      print('DEBUG: Error fetching current term: $e');
      currentTerm.value = null;
    }
  }

  // Fetch term timeline
  Future<void> fetchTermTimeline(String loanId) async {
    try {
      isLoadingTimeline.value = true;
      errorMessage.value = '';

      print('DEBUG: Fetching timeline for loan: $loanId');

      final response = await LoanTermsService.getTermTimeline(loanId);

      if (response.success && response.data != null) {
        timeline.value = response.data;
        print(
          'DEBUG: Timeline fetched with ${timeline.value?.events.length} events',
        );
      } else {
        errorMessage.value = response.message ?? 'Failed to load timeline';
        Get.snackbar('Error', errorMessage.value);
      }
    } catch (e) {
      errorMessage.value = 'Failed to load timeline: ${e.toString()}';
      Get.snackbar('Error', errorMessage.value);
    } finally {
      isLoadingTimeline.value = false;
    }
  }

  // Fetch term statistics
  Future<void> fetchTermStats({String? loanId}) async {
    try {
      isLoadingStats.value = true;

      print('DEBUG: Fetching term statistics');

      final response = await LoanTermsService.getTermStats(loanId: loanId);

      if (response.success && response.data != null) {
        stats.value = response.data;
        print('DEBUG: Statistics fetched');
      } else {
        print('DEBUG: No statistics available');
      }
    } catch (e) {
      print('DEBUG: Error fetching statistics: $e');
    } finally {
      isLoadingStats.value = false;
    }
  }

  // Get term details by ID
  Future<LoanTerm?> getTermDetails(String termId) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      print('DEBUG: Fetching term details: $termId');

      final response = await LoanTermsService.getTermById(termId);

      if (response.success && response.data != null) {
        selectedTerm.value = response.data;
        print('DEBUG: Term details fetched: ${selectedTerm.value?.termNo}');
        return response.data;
      } else {
        errorMessage.value = response.message ?? 'Failed to load term details';
        Get.snackbar('Error', errorMessage.value);
        return null;
      }
    } catch (e) {
      errorMessage.value = 'Failed to load term details: ${e.toString()}';
      Get.snackbar('Error', errorMessage.value);
      return null;
    } finally {
      isLoading.value = false;
    }
  }

  // Request loan renewal
  Future<bool> requestLoanRenewal(RenewalRequest request) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      print('DEBUG: Submitting renewal request for loan: ${request.loanId}');

      final response = await LoanTermsService.requestLoanRenewal(request);

      if (response.success && response.data != null) {
        print('DEBUG: Renewal request submitted successfully');

        // Show success message
        Get.snackbar(
          'Success',
          'Renewal request submitted successfully',
          snackPosition: SnackPosition.TOP,
        );

        // Refresh terms list
        await fetchLoanTerms(request.loanId, refresh: true);

        return true;
      } else {
        errorMessage.value =
            response.message ?? 'Failed to submit renewal request';
        Get.snackbar('Error', errorMessage.value);
        return false;
      }
    } catch (e) {
      errorMessage.value = 'Failed to submit renewal request: ${e.toString()}';
      Get.snackbar('Error', errorMessage.value);
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  // Load more terms
  Future<void> loadMoreTerms(String loanId) async {
    if (isLoadingMore.value || !hasNextPage.value) return;

    try {
      isLoadingMore.value = true;
      currentPage.value++;

      final response = await LoanTermsService.getLoanTermsByLoanId(
        loanId,
        page: currentPage.value,
        limit: 10,
        status: selectedFilter.value != 'All' ? selectedFilter.value : null,
        termType: selectedTypeFilter.value != 'All'
            ? selectedTypeFilter.value
            : null,
      );

      if (response.success && response.data != null) {
        loanTerms.addAll(response.data!);
        hasNextPage.value = response.data!.length >= 10;
      } else {
        currentPage.value--;
        Get.snackbar('Error', 'Failed to load more terms');
      }
    } catch (e) {
      currentPage.value--;
      Get.snackbar('Error', 'Failed to load more terms');
    } finally {
      isLoadingMore.value = false;
    }
  }

  // Set filter
  void setFilter(String filter) {
    selectedFilter.value = filter;
    // Don't fetch here - let the screen trigger fetch with new filter
  }

  // Set type filter
  void setTypeFilter(String type) {
    selectedTypeFilter.value = type;
    // Don't fetch here - let the screen trigger fetch with new filter
  }

  // Set search query
  void setSearchQuery(String query) {
    searchQuery.value = query;
  }

  // Clear search
  void clearSearch() {
    searchQuery.value = '';
  }

  // Select term
  void selectTerm(LoanTerm term) {
    selectedTerm.value = term;
  }

  // Clear selected term
  void clearSelectedTerm() {
    selectedTerm.value = null;
  }

  // Get next term number
  Future<String?> getNextTermNumber(String loanId) async {
    try {
      final response = await LoanTermsService.getNextTermNumber(loanId);

      if (response.success && response.data != null) {
        return response.data?['next_term_no']?.toString() ?? '1';
      }
      return '1';
    } catch (e) {
      return '1';
    }
  }

  // Reset controller
  void reset() {
    loanTerms.clear();
    currentTerm.value = null;
    timeline.value = null;
    stats.value = null;
    selectedTerm.value = null;
    isLoading.value = false;
    isLoadingTimeline.value = false;
    isLoadingStats.value = false;
    errorMessage.value = '';
    selectedFilter.value = 'All';
    selectedTypeFilter.value = 'All';
    searchQuery.value = '';
    currentPage.value = 1;
    totalPages.value = 1;
    hasNextPage.value = false;
    hasPrevPage.value = false;
    totalTerms.value = 0;
    isLoadingMore.value = false;
  }
}
