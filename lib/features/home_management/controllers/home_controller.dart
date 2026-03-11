import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:real_time_pawn/features/home_management/service/home_service.dart';
import 'package:real_time_pawn/global/user_controller.dart';
import 'package:real_time_pawn/models/loan_application_model.dart';
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

  // Add userId for tracking winning auctions
  var userId = ''.obs;

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
          // Extract user ID from profile if available
          // You might need to adjust this based on where user ID is stored
          userId.value = profile.value['user_id'] ?? '';
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
        if (data['latest_bid'] != null && data['latest_bid'] is Map) {
          latestBid.value = Map<String, dynamic>.from(data['latest_bid']);
        } else {
          latestBid.value = {};
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

  // Method to place a bid
  Future<void> placeBid(String auctionId, double bidAmount) async {
    try {
      // Show loading indicator
      Get.dialog(
        const Center(child: CircularProgressIndicator()),
        barrierDismissible: false,
      );

      // Call your bid service here
      // final response = await BidService.placeBid(auctionId, bidAmount);

      // For now, just simulate a successful bid
      await Future.delayed(const Duration(seconds: 1));

      Get.back(); // Close loading dialog

      // Show success message
      Get.snackbar(
        'Success',
        'Bid placed successfully!',
        backgroundColor: Colors.green,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );

      // Refresh home data to show updated bid
      fetchHomeData();
    } catch (e) {
      Get.back(); // Close loading dialog
      Get.snackbar(
        'Error',
        'Failed to place bid: ${e.toString()}',
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
      DevLogs.logError('Error placing bid: ${e.toString()}');
    }
  }

  LoanApplicationModel mapToLoanApplication(Map<String, dynamic> json) {
    return LoanApplicationModel(
      id: json['_id'],
      applicationNo: json['_application_no'] ?? json['application_no'],
      fullName: json['full_name'],
      nationalIdNumber: json['national_id_number'],
      gender: json['gender'],
      dateOfBirth: json['date_of_birth'] != null
          ? DateTime.parse(json['date_of_birth'])
          : null,
      maritalStatus: json['marital_status'],
      contactDetails: json['contact_details'],
      alternativeNumber: json['alternative_number'],
      emailAddress: json['email_address'],
      homeAddress: json['home_address'],
      nationalIdUrl: json['national_id_url'],
      passportUrl: json['passport_url'],
      proofOfResidentUrl: json['proof_of_resident_url'],
      proofOfEmploymentUrl: json['proof_of_employment_url'],
      requestedLoanAmount: json['requested_loan_amount'],
      collateralCategory: json['collateral_category'],
      collateralDescription: json['collateral_description'],
      suretyDescription: json['surety_description'],
      declaredAssetValue: json['declared_asset_value'],
      status: json['status'],
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : null,

      // ✅ FIX: Properly parse customerUser
      customerUser: json['customer_user'] != null
          ? CustomerUser(
              id: json['customer_user']['_id'],
              email: json['customer_user']['email'],
              phone: json['customer_user']['phone'],
              firstName: json['customer_user']['first_name'],
              lastName: json['customer_user']['last_name'],
            )
          : null,

      // Next of kin
      nextOfKin: json['next_of_kin'] != null
          ? NextOfKin(
              fullName: json['next_of_kin']['full_name'],
              relationship: json['next_of_kin']['relationship'],
              phoneNumber: json['next_of_kin']['phone_number'],
              email: json['next_of_kin']['email'],
              address: json['next_of_kin']['address'],
            )
          : null,

      // Employment
      employment: json['employment'] != null
          ? Employment(
              employmentType: json['employment']['employment_type'],
              title: json['employment']['title'],
              duration: json['employment']['duration'],
              location: json['employment']['location'],
              contacts: json['employment']['contacts'],
            )
          : null,

      // Small loan details
      smallLoanDetails: json['small_loan_details'] != null
          ? SmallLoanDetails(
              type: json['small_loan_details']['type'],
              model: json['small_loan_details']['model'],
              serialNo: json['small_loan_details']['serial_no'],
            )
          : null,
    );
  }

  // Check if user is winning a specific auction
  bool isUserWinningAuction(Map<String, dynamic> auction) {
    final winnerUserId = auction['winner_user'];
    return winnerUserId == userId.value &&
        auction['winning_bid_amount'] != null;
  }

  // Get current bid amount for an auction
  double getCurrentBidAmount(Map<String, dynamic> auction) {
    return (auction['winning_bid_amount'] as num?)?.toDouble() ??
        (auction['starting_bid_amount'] as num?)?.toDouble() ??
        0;
  }

  // Check if user has any active bids
  bool get hasActiveBids {
    return latestBid.value.isNotEmpty;
  }

  // Get count of live auctions
  int get liveAuctionsCount {
    return activeAuctions
        .where((auction) => auction['status'] == 'live')
        .length;
  }

  // Get count of pending loan applications
  int get pendingApplicationsCount {
    return latestLoanApplications
        .where(
          (app) => app['status'] == 'processing' || app['status'] == 'pending',
        )
        .length;
  }

  // Get total outstanding loan balance
  double get totalOutstandingBalance {
    return latestLoans.fold(
      0.0,
      (sum, loan) => sum + (loan['current_balance'] as num? ?? 0).toDouble(),
    );
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

  Future<void> refreshData() async {
    await fetchHomeData();
  }

  String getUserId() {
    try {
      final userController = Get.find<UserController>();
      return userController.user?.userId ?? '';
    } catch (e) {
      return '';
    }
  }

  void clearMessages() {
    errorMessage.value = '';
  }
}
