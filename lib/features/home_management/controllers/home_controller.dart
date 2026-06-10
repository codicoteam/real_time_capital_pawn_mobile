import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:real_time_pawn/features/home_management/service/home_service.dart';
import 'package:real_time_pawn/global/user_controller.dart';
import 'package:real_time_pawn/models/loan_application_model.dart';
import '../../../config/routers/router.dart';
import '../../../core/utils/logs.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/utils/pallete.dart';

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

  // KYC verification status
  var kycVerificationStatus = 'unverified'.obs;

  // Check if KYC is verified - computed property
  bool get isKycVerified => kycVerificationStatus.value == 'verified';

  // Get KYC status message for UI
  String get kycStatusMessage {
    switch (kycVerificationStatus.value) {
      case 'unverified':
        return 'Complete KYC verification to apply for loans';
      case 'pending':
        return 'KYC verification in progress. Please wait for approval.';
      case 'rejected':
        return 'KYC verification rejected. Please contact support.';
      case 'verified':
        return '';
      default:
        return 'Please complete KYC verification';
    }
  }

  // Get KYC status color
  Color get kycStatusColor {
    switch (kycVerificationStatus.value) {
      case 'unverified':
        return Colors.orange;
      case 'pending':
        return Colors.orange;
      case 'rejected':
        return Colors.red;
      case 'verified':
        return Colors.green;
      default:
        return Colors.orange;
    }
  }

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
          userId.value = profile.value['user_id'] ?? '';
          // Extract KYC verification status
          if (profile.value['kyc_verification_status'] != null) {
            kycVerificationStatus.value =
                profile.value['kyc_verification_status'];
          }
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

        DevLogs.logSuccess(
          'Home data loaded successfully, KYC Status: ${kycVerificationStatus.value}',
        );
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

  // Method to check if user can apply for loan
  bool canApplyForLoan() {
    return isKycVerified;
  }

  // Show KYC required dialog
  void showKycRequiredDialog() {
    String title = '';
    String message = '';
    IconData icon = Icons.verified_user_outlined;
    Color iconColor = Colors.orange;
    List<Map<String, dynamic>> actionButtons = [];

    switch (kycVerificationStatus.value) {
      case 'unverified':
        title = 'KYC Verification Required';
        message =
            'You need to complete your KYC verification before you can apply for loans. '
            'Please update your profile with the required KYC documents to get started. '
            'If you have already updated your profile, you can still attempt to make a loan application. '
            'Our staff team will receive your request and reach out to you for verification.';
        icon = Icons.verified_user_outlined;
        iconColor = Colors.orange;
        actionButtons = [
          {
            'text': 'Update Profile',
            'action': () {
              Get.back();
              Get.toNamed(RoutesHelper.profileScreen);
            },
            'isPrimary': true,
            'icon': Icons.edit,
          },
          {
            'text': 'Try Loan Application',
            'action': () {
              Get.back();
              Get.toNamed('/create-loan-application');
            },
            'isPrimary': false,
            'icon': Icons.request_quote,
          },
          {
            'text': 'Contact Support',
            'action': () {
              Get.back();
              Get.toNamed(RoutesHelper.ticketListScreen);
            },
            'isPrimary': false,
            'icon': Icons.support_agent,
          },
        ];
        break;
      case 'pending':
        title = 'KYC Verification Pending';
        message =
            'Your KYC verification is currently being processed. '
            'You will be able to apply for loans once your verification is approved. '
            'In the meantime, you can:'
            '\n\n• Check your profile for verification status updates'
            '\n• Try submitting a loan application - our team will be notified'
            '\n• Contact support for any questions about your verification';
        icon = Icons.pending_actions;
        iconColor = Colors.orange;
        actionButtons = [
          {
            'text': 'View Profile',
            'action': () {
              Get.back();
              Get.toNamed(RoutesHelper.profileScreen);
            },
            'isPrimary': true,
            'icon': Icons.visibility,
          },
          {
            'text': 'Try Loan Application',
            'action': () {
              Get.back();
              Get.toNamed('/create-loan-application');
            },
            'isPrimary': false,
            'icon': Icons.request_quote,
          },
          {
            'text': 'Contact Support',
            'action': () {
              Get.back();
              Get.toNamed(RoutesHelper.ticketListScreen);
            },
            'isPrimary': false,
            'icon': Icons.support_agent,
          },
        ];
        break;
      case 'rejected':
        title = 'KYC Verification Rejected';
        message =
            'Your KYC verification has been rejected. '
            'Please update your profile with correct documents or contact support. '
            'You can still try to make a loan application - our staff will review your request '
            'and help you with the verification process.';
        icon = Icons.cancel_outlined;
        iconColor = Colors.red;
        actionButtons = [
          {
            'text': 'Update Profile',
            'action': () {
              Get.back();
              Get.toNamed(RoutesHelper.profileScreen);
            },
            'isPrimary': true,
            'icon': Icons.edit,
          },
          {
            'text': 'Try Loan Application',
            'action': () {
              Get.back();
              Get.toNamed('/create-loan-application');
            },
            'isPrimary': false,
            'icon': Icons.request_quote,
          },
          {
            'text': 'Create Support Ticket',
            'action': () {
              Get.back();
              Get.toNamed(RoutesHelper.ticketListScreen);
            },
            'isPrimary': false,
            'icon': Icons.confirmation_number,
          },
        ];
        break;
      default:
        title = 'Verification Required';
        message =
            'Please complete your verification to access loan services. '
            'Update your profile with the required information or contact our support team for assistance.';
        icon = Icons.warning_amber_outlined;
        iconColor = Colors.orange;
        actionButtons = [
          {
            'text': 'Go to Profile',
            'action': () {
              Get.back();
              Get.toNamed(RoutesHelper.profileScreen);
            },
            'isPrimary': true,
            'icon': Icons.person,
          },
          {
            'text': 'Contact Support',
            'action': () {
              Get.back();
              Get.toNamed(RoutesHelper.ticketListScreen);
            },
            'isPrimary': false,
            'icon': Icons.support_agent,
          },
        ];
    }

    // Show bottom sheet instead of dialog
    Get.bottomSheet(
      Container(
        decoration: BoxDecoration(
          color: AppColors.surfaceColor,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Drag handle
            Container(
              margin: const EdgeInsets.only(top: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.borderColor,
                borderRadius: BorderRadius.circular(2),
              ),
            ),

            // Scrollable content
            Flexible(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 16,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header with icon and title
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: iconColor.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Icon(icon, color: iconColor, size: 28),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Text(
                            title,
                            style: GoogleFonts.nunito(
                              fontSize: 20,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textColor,
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 20),

                    // Message
                    Text(
                      message,
                      style: GoogleFonts.nunito(
                        fontSize: 14,
                        color: AppColors.subtextColor,
                        height: 1.5,
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Contact Information Card
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.primaryColor.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: AppColors.primaryColor.withValues(alpha: 0.2),
                          width: 1,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.support_agent,
                                color: AppColors.primaryColor,
                                size: 20,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Need help? Contact us:',
                                style: GoogleFonts.nunito(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.primaryColor,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),

                          // Email
                          GestureDetector(
                            onTap: () {
                              Get.back();
                              Get.snackbar(
                                'Contact Support',
                                'Email: support@rtcapital.co.zw',
                                backgroundColor: AppColors.primaryColor,
                                colorText: Colors.white,
                                snackPosition: SnackPosition.BOTTOM,
                                duration: const Duration(seconds: 4),
                                icon: const Icon(
                                  Icons.email,
                                  color: Colors.white,
                                ),
                              );
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.email_outlined,
                                    color: AppColors.primaryColor,
                                    size: 18,
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Text(
                                      'support@rtcapital.co.zw',
                                      style: GoogleFonts.nunito(
                                        fontSize: 13,
                                        color: AppColors.textColor,
                                      ),
                                    ),
                                  ),
                                  Icon(
                                    Icons.copy,
                                    color: AppColors.primaryColor,
                                    size: 16,
                                  ),
                                ],
                              ),
                            ),
                          ),

                          const Divider(height: 1),

                          // Phone
                          GestureDetector(
                            onTap: () {
                              Get.back();
                              Get.snackbar(
                                'Contact Support',
                                'Call us: +263785480423',
                                backgroundColor: AppColors.primaryColor,
                                colorText: Colors.white,
                                snackPosition: SnackPosition.BOTTOM,
                                duration: const Duration(seconds: 4),
                                icon: const Icon(
                                  Icons.phone,
                                  color: Colors.white,
                                ),
                              );
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.phone_outlined,
                                    color: AppColors.primaryColor,
                                    size: 18,
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Text(
                                      '+263785480423',
                                      style: GoogleFonts.nunito(
                                        fontSize: 13,
                                        color: AppColors.textColor,
                                      ),
                                    ),
                                  ),
                                  Icon(
                                    Icons.call,
                                    color: AppColors.primaryColor,
                                    size: 16,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Staff notification info
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.orange.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: Colors.orange.withValues(alpha: 0.3),
                          width: 1,
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.info_outline,
                            color: Colors.orange.shade700,
                            size: 20,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'When you try to make a loan application, our staff team will receive your request and assist you with the verification process.',
                              style: GoogleFonts.nunito(
                                fontSize: 12,
                                color: Colors.orange.shade800,
                                height: 1.4,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Required documents for unverified users
                    if (kycVerificationStatus.value == 'unverified') ...[
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppColors.surfaceColor,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: AppColors.borderColor),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.05),
                              blurRadius: 10,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Required Documents:',
                              style: GoogleFonts.nunito(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                color: AppColors.textColor,
                              ),
                            ),
                            const SizedBox(height: 12),
                            _buildRequirementItem(
                              'Valid Government ID',
                              'Passport, Driver\'s License, or National ID',
                              Icons.credit_card,
                            ),
                            const SizedBox(height: 8),
                            _buildRequirementItem(
                              'Proof of Address',
                              'Utility bill, Bank statement, or Lease agreement',
                              Icons.home,
                            ),
                            const SizedBox(height: 8),
                            _buildRequirementItem(
                              'Recent Photo',
                              'Clear profile picture for identification',
                              Icons.camera_alt,
                            ),
                          ],
                        ),
                      ),
                    ],

                    const SizedBox(height: 24),

                    // Action Buttons
                    Column(
                      children: actionButtons.map((button) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: SizedBox(
                            width: double.infinity,
                            child: ElevatedButton.icon(
                              onPressed: button['action'] as VoidCallback,
                              icon: Icon(button['icon'] as IconData, size: 20),
                              label: Text(
                                button['text'] as String,
                                style: GoogleFonts.nunito(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: button['isPrimary'] as bool
                                    ? AppColors.primaryColor
                                    : Colors.transparent,
                                foregroundColor: button['isPrimary'] as bool
                                    ? Colors.white
                                    : AppColors.primaryColor,
                                elevation: button['isPrimary'] as bool ? 2 : 0,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 14,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  side: button['isPrimary'] as bool
                                      ? BorderSide.none
                                      : BorderSide(
                                          color: AppColors.primaryColor,
                                        ),
                                ),
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),

                    // Cancel button
                    const SizedBox(height: 8),
                    SizedBox(
                      width: double.infinity,
                      child: TextButton(
                        onPressed: () => Get.back(),
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(
                          'Close',
                          style: GoogleFonts.nunito(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: AppColors.subtextColor,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      enableDrag: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
    );
  }

  // Helper method to build requirement items
  Widget _buildRequirementItem(String title, String subtitle, IconData icon) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: Colors.green.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, size: 16, color: Colors.green),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: GoogleFonts.nunito(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textColor,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: GoogleFonts.nunito(
                  fontSize: 11,
                  color: AppColors.subtextColor,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  } // Method to place a bid

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

// Add this if GoogleFonts is not imported in this file
