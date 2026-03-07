import 'package:get/get.dart';
import 'package:real_time_pawn/features/home_management/service/home_service.dart';
import '../../../core/utils/logs.dart';

class HomeController extends GetxController {
  var isLoading = true.obs;
  var errorMessage = ''.obs;

  // Home data from API
  var profile = Rx<Map<String, dynamic>>({});
  var activeAuctions = <Map<String, dynamic>>[].obs;
  var latestBid = Rx<Map<String, dynamic>>({});
  var latestLoanApplications = <Map<String, dynamic>>[].obs;
  var latestLoans = <Map<String, dynamic>>[].obs;

  // Derived data for UI
  var activeLoansCount = 0.obs;
  var totalDueAmount = 0.0.obs;

  @override
  void onInit() {
    super.onInit();
    fetchHomeData();
  }

  Future<void> fetchHomeData() async {
    try {
      isLoading(true);
      errorMessage.value = '';

      final response = await HomeService.getHomeData();

      if (response.success && response.data != null) {
        final data = response.data!;

        // Update profile
        if (data['profile'] != null) {
          profile.value = Map<String, dynamic>.from(data['profile']);
        }

        // Update active auctions
        if (data['active_auctions'] != null) {
          activeAuctions.value = List<Map<String, dynamic>>.from(
            data['active_auctions'].map(
              (item) => Map<String, dynamic>.from(item),
            ),
          );
        }

        // Update latest bid
        if (data['latest_bid'] != null) {
          latestBid.value = Map<String, dynamic>.from(data['latest_bid']);
        }

        // Update latest loan applications
        if (data['latest_loan_applications'] != null) {
          latestLoanApplications.value = List<Map<String, dynamic>>.from(
            data['latest_loan_applications'].map(
              (item) => Map<String, dynamic>.from(item),
            ),
          );
        }

        // Update latest loans
        if (data['latest_loans'] != null) {
          latestLoans.value = List<Map<String, dynamic>>.from(
            data['latest_loans'].map((item) => Map<String, dynamic>.from(item)),
          );
        }

        // Calculate derived data
        activeLoansCount.value = latestLoans.length;

        // Calculate total due amount from loans (you can adjust this logic)
        totalDueAmount.value = latestLoans.fold(
          0.0,
          (sum, loan) =>
              sum + (loan['current_balance'] as num? ?? 0).toDouble(),
        );

        DevLogs.logSuccess('Home data loaded successfully');
      } else {
        errorMessage.value = response.message ?? 'Failed to load home data';
        DevLogs.logError(errorMessage.value);
      }
    } catch (e) {
      errorMessage.value = 'An error occurred: ${e.toString()}';
      DevLogs.logError('Error in fetchHomeData: ${e.toString()}');
    } finally {
      isLoading(false);
    }
  }

  // Helper methods for UI
  String get getUserName {
    final firstName = profile.value['first_name'] ?? '';
    final lastName = profile.value['last_name'] ?? '';

    if (firstName.isNotEmpty && lastName.isNotEmpty) {
      return '$firstName $lastName';
    } else if (firstName.isNotEmpty) {
      return firstName;
    } else if (lastName.isNotEmpty) {
      return lastName;
    } else {
      return 'Guest';
    }
  }

  String getUserInitials() {
    final firstName = profile.value['first_name'] ?? '';
    final lastName = profile.value['last_name'] ?? '';

    if (firstName.isNotEmpty && lastName.isNotEmpty) {
      return '${firstName[0]}${lastName[0]}'.toUpperCase();
    } else if (firstName.isNotEmpty) {
      return firstName[0].toUpperCase();
    } else if (lastName.isNotEmpty) {
      return lastName[0].toUpperCase();
    } else {
      return 'G';
    }
  }

  String getUserEmail() {
    return profile.value['email'] ?? 'guest@example.com';
  }

  String getUserPhone() {
    return profile.value['phone'] ?? '';
  }

  String? getProfilePicUrl() {
    return profile.value['profile_pic_url'];
  }

  void refreshData() {
    fetchHomeData();
  }

  void clearMessages() {
    errorMessage.value = '';
  }
}
