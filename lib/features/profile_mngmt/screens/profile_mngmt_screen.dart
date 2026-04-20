// lib/features/profile_mngmt/screens/view_profile_screen.dart
import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:photo_view/photo_view.dart';
import 'package:real_time_pawn/config/routers/router.dart';
import 'package:real_time_pawn/core/utils/pallete.dart';
import 'package:real_time_pawn/core/utils/shared_pref_methods.dart';
import 'package:real_time_pawn/features/loan_mngmt/controllers/loan_mngmt_controller.dart';
import 'package:real_time_pawn/features/profile_mngmt/controllers/profile_mngmt_controller.dart';
import 'package:real_time_pawn/features/profile_mngmt/helpers/profile_mngmt_helper.dart';
import 'package:real_time_pawn/features/profile_mngmt/screens/edit_profile_screen.dart';
import 'package:real_time_pawn/features/test/curved_edges_widget.dart';
import 'package:real_time_pawn/models/profile_mngmt_model.dart';
import 'package:real_time_pawn/widgets/custom_button/general_button.dart';
import 'package:url_launcher/url_launcher.dart';

import 'kyc_modal.dart';
import 'next_of_kin_modal.dart';
import 'profile_picture_modal.dart' show ProfilePictureModal;
import 'update_password_modal.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final ProfileController _profileController = Get.find<ProfileController>();
  final ScrollController _scrollController = ScrollController();
  final ImagePicker _imagePicker = ImagePicker();

  bool isLoading = false;
  bool hasError = false;
  String errorMessage = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkAuthAndLoadProfile();
    });
  }

  Future<void> _checkAuthAndLoadProfile() async {
    setState(() {
      isLoading = true;
      hasError = false;
      errorMessage = '';
    });

    try {
      final token = await CacheUtils.checkToken();
      if (token == null || token.isEmpty) {
        Get.offAllNamed('/login');
        return;
      }

      await _loadProfile();
    } catch (e) {
      setState(() {
        hasError = true;
        errorMessage = 'Authentication error: $e';
      });
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _loadProfile() async {
    try {
      final success = await ProfileMngmtHelper.fetchUserProfile();

      if (success && _profileController.userProfile.value != null) {
        if (Get.isRegistered<LoanController>()) {
          final loanController = Get.find<LoanController>();
          await loanController.fetchCustomerLoans();
        }
      } else {
        setState(() {
          hasError = true;
          errorMessage = _profileController.errorMessage.value.isNotEmpty
              ? _profileController.errorMessage.value
              : 'Failed to load profile';
        });
      }
    } catch (e) {
      setState(() {
        hasError = true;
        errorMessage = 'An error occurred: $e';
      });
    }
  }

  bool get isKycVerified {
    final user = _profileController.userProfile.value;
    return user?.kycVerificationStatus?.toLowerCase() == 'verified';
  }

  Future<void> _showProfilePictureModal() async {
    if (isKycVerified) {
      ProfileMngmtHelper.showError('KYC verified profiles cannot be edited');
      return;
    }

    await Get.bottomSheet(
      ProfilePictureModal(
        onImageUpdated: (newImageUrl) {
          if (newImageUrl != null &&
              _profileController.userProfile.value != null) {
            final currentUser = _profileController.userProfile.value!;
            final updatedUser = UserProfile(
              nextOfKin: currentUser.nextOfKin,
              id: currentUser.id,
              email: currentUser.email,
              phone: currentUser.phone,
              roles: currentUser.roles,
              firstName: currentUser.firstName,
              lastName: currentUser.lastName,
              status: currentUser.status,
              dateOfBirth: currentUser.dateOfBirth,
              address: currentUser.address,
              location: currentUser.location,
              gender: currentUser.gender,
              maritalStatus: currentUser.maritalStatus,
              passportImageUrl: currentUser.passportImageUrl,
              proofOfAddressUrl: currentUser.proofOfAddressUrl,
              passportExpiryDate: currentUser.passportExpiryDate,
              isEmployed: currentUser.isEmployed,
              employmentDetails: currentUser.employmentDetails,
              documents: currentUser.documents,
              kycVerificationStatus: currentUser.kycVerificationStatus,
              termsAcceptedAt: currentUser.termsAcceptedAt,
              emailVerified: currentUser.emailVerified,
              addedBy: currentUser.addedBy,
              fullName: currentUser.fullName,
              emailVerificationOtp: currentUser.emailVerificationOtp,
              emailVerificationExpiresAt:
                  currentUser.emailVerificationExpiresAt,
              createdAt: currentUser.createdAt,
              updatedAt: currentUser.updatedAt,
              v: currentUser.v,
              nationalIdNumber: currentUser.nationalIdNumber,
              alternativePhone: currentUser.alternativePhone,
              profilePicUrl: newImageUrl,
              drivingLicenseExpiryDate: currentUser.drivingLicenseExpiryDate,
              nationalIdExpiryDate: currentUser.nationalIdExpiryDate,
              nationalIdImageUrl: currentUser.nationalIdImageUrl,
            );
            _profileController.userProfile.value = updatedUser;
            _profileController.userProfile.refresh();
          }
        },
      ),
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      enableDrag: true,
    );
  }

  Future<void> _showUpdatePasswordModal() async {
    await Get.bottomSheet(
      const UpdatePasswordModal(),
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      enableDrag: true,
    );
  }

  Future<void> _showNextOfKinModal() async {
    if (isKycVerified) {
      ProfileMngmtHelper.showError('KYC verified profiles cannot be edited');
      return;
    }

    final user = _profileController.userProfile.value;
    if (user == null) return;

    await Get.bottomSheet(
      NextOfKinModal(
        initialData: user.nextOfKin,
        onUpdated: (updatedData) {
          if (_profileController.userProfile.value != null) {
            final currentUser = _profileController.userProfile.value!;
            final updatedNextOfKin = NextOfKin(
              fullName: updatedData['full_name'],
              relationship: updatedData['relationship'],
              phoneNumber: updatedData['phone_number'],
              email: updatedData['email'],
              address: updatedData['address'],
            );
            final updatedUser = UserProfile(
              nextOfKin: updatedNextOfKin,
              id: currentUser.id,
              email: currentUser.email,
              phone: currentUser.phone,
              roles: currentUser.roles,
              firstName: currentUser.firstName,
              lastName: currentUser.lastName,
              status: currentUser.status,
              dateOfBirth: currentUser.dateOfBirth,
              address: currentUser.address,
              location: currentUser.location,
              gender: currentUser.gender,
              maritalStatus: currentUser.maritalStatus,
              passportImageUrl: currentUser.passportImageUrl,
              proofOfAddressUrl: currentUser.proofOfAddressUrl,
              passportExpiryDate: currentUser.passportExpiryDate,
              isEmployed: currentUser.isEmployed,
              employmentDetails: currentUser.employmentDetails,
              documents: currentUser.documents,
              kycVerificationStatus: currentUser.kycVerificationStatus,
              termsAcceptedAt: currentUser.termsAcceptedAt,
              emailVerified: currentUser.emailVerified,
              addedBy: currentUser.addedBy,
              fullName: currentUser.fullName,
              emailVerificationOtp: currentUser.emailVerificationOtp,
              emailVerificationExpiresAt:
                  currentUser.emailVerificationExpiresAt,
              createdAt: currentUser.createdAt,
              updatedAt: currentUser.updatedAt,
              v: currentUser.v,
              nationalIdNumber: currentUser.nationalIdNumber,
              alternativePhone: currentUser.alternativePhone,
              profilePicUrl: currentUser.profilePicUrl,
              drivingLicenseExpiryDate: currentUser.drivingLicenseExpiryDate,
              nationalIdExpiryDate: currentUser.nationalIdExpiryDate,
              nationalIdImageUrl: currentUser.nationalIdImageUrl,
            );
            _profileController.userProfile.value = updatedUser;
            _profileController.userProfile.refresh();
          }
        },
      ),
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      enableDrag: true,
    );
  }

  Future<void> _showKYCModal() async {
    final user = _profileController.userProfile.value;
    if (user == null) return;

    await Get.bottomSheet(
      KYCModal(
        userProfile: user,
        onKYCUpdated: (updatedProfile) {
          _profileController.userProfile.value = updatedProfile;
          _profileController.userProfile.refresh();
        },
      ),
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      enableDrag: true,
    );
  }

  Future<void> logout() async {
    final confirmed = await Get.dialog<bool>(
      AlertDialog(
        title: Text(
          'Logout',
          style: GoogleFonts.nunito(fontWeight: FontWeight.bold),
        ),
        content: Text(
          'Are you sure you want to logout?',
          style: GoogleFonts.nunito(),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: Text(
              'Cancel',
              style: GoogleFonts.nunito(color: AppColors.textColor),
            ),
          ),
          TextButton(
            onPressed: () => Get.back(result: true),
            child: Text(
              'Logout',
              style: GoogleFonts.nunito(
                color: AppColors.primaryColor,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      setState(() => isLoading = true);
      try {
        await CacheUtils.clearAllUserData();
        Get.offAllNamed('/login');
      } catch (e) {
        ProfileMngmtHelper.showError('Logout failed: $e');
      } finally {
        setState(() => isLoading = false);
      }
    }
  }

  Future<void> _requestAccountDeletion() async {
    final user = _profileController.userProfile.value;
    if (user == null) return;

    final confirmed = await Get.dialog<bool>(
      AlertDialog(
        title: Text(
          'Delete Account',
          style: GoogleFonts.nunito(fontWeight: FontWeight.bold),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'This action will permanently delete your account. All data will be lost.',
              style: GoogleFonts.nunito(),
            ),
            const SizedBox(height: 10),
            Text(
              'Enter your email to confirm:',
              style: GoogleFonts.nunito(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 5),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(user.email ?? '', style: GoogleFonts.nunito()),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: Text(
              'Cancel',
              style: GoogleFonts.nunito(color: AppColors.textColor),
            ),
          ),
          TextButton(
            onPressed: () => Get.back(result: true),
            child: Text(
              'Request Deletion',
              style: GoogleFonts.nunito(
                color: Colors.red,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      setState(() => isLoading = true);
      try {
        final success = await ProfileMngmtHelper.requestAccountDeletion(
          email: user.email ?? '',
        );
        if (success) {
          await _showOTPVerificationDialog(user.email ?? '');
        }
      } catch (e) {
        ProfileMngmtHelper.showError('Failed to request deletion: $e');
      } finally {
        setState(() => isLoading = false);
      }
    }
  }

  final TextEditingController otpController = TextEditingController();

  Future<void> _showOTPVerificationDialog(String email) async {
    otpController.clear();

    await Get.dialog(
      AlertDialog(
        title: Text(
          'Verify Deletion',
          style: GoogleFonts.nunito(fontWeight: FontWeight.bold),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Enter the 6-digit OTP sent to your email',
              style: GoogleFonts.nunito(),
            ),
            const SizedBox(height: 15),
            TextField(
              controller: otpController,
              keyboardType: TextInputType.number,
              maxLength: 6,
              decoration: InputDecoration(
                labelText: 'OTP Code',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                prefixIcon: const Icon(Icons.lock_outline),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text(
              'Cancel',
              style: GoogleFonts.nunito(color: AppColors.textColor),
            ),
          ),
          TextButton(
            onPressed: () async {
              if (otpController.text.length != 6) {
                ProfileMngmtHelper.showError(
                  'Please enter a valid 6-digit OTP',
                );
                return;
              }

              Get.back();
              setState(() => isLoading = true);

              try {
                final success = await ProfileMngmtHelper.confirmAccountDeletion(
                  email: email,
                  otp: otpController.text,
                );

                if (success) {
                  await CacheUtils.clearAllUserData();
                  Get.offAllNamed('/login');
                }
              } catch (e) {
                ProfileMngmtHelper.showError('Failed to delete account: $e');
              } finally {
                setState(() => isLoading = false);
              }
            },
            child: Text(
              'Confirm Delete',
              style: GoogleFonts.nunito(
                color: Colors.red,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _navigateToEditProfile() {
    if (isKycVerified) {
      ProfileMngmtHelper.showError('KYC verified profiles cannot be edited');
      return;
    }

    final user = _profileController.userProfile.value;
    if (user != null) {
      Get.to(() => EditProfileScreen(userProfile: user));
    }
  }

  void _showImageFullScreen(String imageUrl) {
    Get.to(
      () => Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.close, color: Colors.white),
            onPressed: () => Get.back(),
          ),
        ),
        body: Center(
          child: PhotoView(
            imageProvider: CachedNetworkImageProvider(imageUrl),
            backgroundDecoration: const BoxDecoration(color: Colors.black),
            minScale: PhotoViewComputedScale.contained,
            maxScale: PhotoViewComputedScale.covered * 2,
          ),
        ),
      ),
    );
  }

  Widget _buildLoadingScreen() {
    return const Center(
      child: CircularProgressIndicator(color: AppColors.primaryColor),
    );
  }

  Widget _buildErrorScreen() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 60, color: AppColors.errorColor),
            const SizedBox(height: 20),
            Text(
              'Unable to load profile',
              style: GoogleFonts.nunito(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              errorMessage,
              textAlign: TextAlign.center,
              style: GoogleFonts.nunito(
                fontSize: 14,
                color: AppColors.subtextColor,
              ),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                GeneralButton(
                  btnColor: Colors.grey,
                  borderRadius: 8,
                  width: 120,
                  onTap: () => Get.back(),
                  child: Text(
                    'Go Back',
                    style: GoogleFonts.nunito(color: Colors.white),
                  ),
                ),
                const SizedBox(width: 12),
                GeneralButton(
                  btnColor: AppColors.primaryColor,
                  borderRadius: 8,
                  width: 120,
                  onTap: _checkAuthAndLoadProfile,
                  child: Text(
                    'Try Again',
                    style: GoogleFonts.nunito(color: Colors.white),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildKycStatusCard(UserProfile user) {
    String status = user.kycVerificationStatus ?? 'Not Started';
    Color statusColor;
    IconData statusIcon;

    switch (status.toLowerCase()) {
      case 'verified':
        statusColor = Colors.green;
        statusIcon = Icons.verified_user;
        break;
      case 'pending':
        statusColor = Colors.orange;
        statusIcon = Icons.pending;
        break;
      case 'rejected':
        statusColor = Colors.red;
        statusIcon = Icons.cancel;
        break;
      default:
        statusColor = Colors.grey;
        statusIcon = Icons.info_outline;
    }

    return GestureDetector(
      onTap: isKycVerified ? null : _showKYCModal,
      child: Container(
        margin: const EdgeInsets.only(top: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: statusColor.withOpacity(0.3)),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(statusIcon, color: statusColor, size: 24),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'KYC Verification Status',
                      style: GoogleFonts.nunito(
                        fontSize: 13,
                        color: Colors.grey[600],
                      ),
                    ),
                    Text(
                      status,
                      style: GoogleFonts.nunito(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: statusColor,
                      ),
                    ),
                  ],
                ),
              ),
              if (status.toLowerCase() != 'verified')
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primaryColor,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    isKycVerified ? 'Verified' : 'Complete KYC',
                    style: GoogleFonts.nunito(
                      fontSize: 12,
                      color: Colors.white,
                    ),
                  ),
                )
              else
                Icon(Icons.verified, color: Colors.green, size: 24),
            ],
          ),
        ),
      ),
    ).animate().fadeIn(delay: 500.ms).slideX(begin: -0.1, end: 0);
  }

  Widget _buildDocumentsSection(UserProfile user) {
    if (user.documents == null || user.documents!.isEmpty) {
      return Container(
        margin: const EdgeInsets.only(top: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Documents',
                style: GoogleFonts.nunito(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey[200]!),
                ),
                child: Center(
                  child: Column(
                    children: [
                      Icon(
                        Icons.cloud_upload_outlined,
                        size: 48,
                        color: Colors.grey[400],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'No documents uploaded yet',
                        style: GoogleFonts.nunito(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Container(
      margin: const EdgeInsets.only(top: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Documents',
              style: GoogleFonts.nunito(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            ...user.documents!.map(
              (doc) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: GestureDetector(
                  onTap: () {
                    if (doc.url != null) {
                      _showImageFullScreen(doc.url!);
                    }
                  },
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.grey[50],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: AppColors.primaryColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(
                            Icons.description,
                            color: AppColors.primaryColor,
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                doc.type?.toUpperCase() ?? 'Document',
                                style: GoogleFonts.nunito(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              if (doc.fileName != null)
                                Text(
                                  doc.fileName!,
                                  style: GoogleFonts.nunito(
                                    fontSize: 12,
                                    color: Colors.grey[600],
                                  ),
                                ),
                            ],
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.open_in_new, size: 20),
                          onPressed: () async {
                            if (doc.url != null &&
                                await canLaunchUrl(Uri.parse(doc.url!))) {
                              await launchUrl(Uri.parse(doc.url!));
                            }
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileContent() {
    final user = _profileController.userProfile.value;
    if (user == null) return const SizedBox();

    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      body: Stack(
        children: [
          SingleChildScrollView(
            controller: _scrollController,
            physics: const BouncingScrollPhysics(),
            child: Column(
              children: [
                TCurvedEdgeWidget(
                  child: Container(
                    height: 180,
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [Color(0xFF2F855A), Color(0xFF38A169)],
                      ),
                    ),
                    child: SafeArea(
                      bottom: false,
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.2),
                                shape: BoxShape.circle,
                              ),
                              child: IconButton(
                                icon: const Icon(
                                  Icons.arrow_back_ios_new_rounded,
                                  color: Colors.white,
                                  size: 18,
                                ),
                                onPressed: () {
                                  Get.offAllNamed(RoutesHelper.main_home_page);
                                },
                              ),
                            ),
                            const Spacer(),
                            // Edit profile button moved to top right
                            if (!isKycVerified)
                              Container(
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.2),
                                  shape: BoxShape.circle,
                                ),
                                child: IconButton(
                                  icon: const Icon(
                                    Icons.edit_outlined,
                                    color: Colors.white,
                                    size: 18,
                                  ),
                                  onPressed: _navigateToEditProfile,
                                ),
                              )
                            else
                              Container(
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(
                                  color: Colors.green.withOpacity(0.2),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.verified,
                                  color: Colors.white,
                                  size: 18,
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),

                Transform.translate(
                  offset: const Offset(0, -50),
                  child: Column(
                    children: [
                      Stack(
                            children: [
                              GestureDetector(
                                onTap: isKycVerified
                                    ? null
                                    : _showProfilePictureModal,
                                child: Container(
                                  width: 100,
                                  height: 100,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: Colors.white,
                                      width: 4,
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.1),
                                        blurRadius: 10,
                                      ),
                                    ],
                                  ),
                                  child: CircleAvatar(
                                    radius: 50,
                                    backgroundColor: AppColors.primaryColor
                                        .withOpacity(0.1),
                                    backgroundImage:
                                        user.profilePicUrl != null &&
                                            user.profilePicUrl!.isNotEmpty
                                        ? CachedNetworkImageProvider(
                                            user.profilePicUrl!,
                                          )
                                        : null,
                                    child:
                                        user.profilePicUrl == null ||
                                            user.profilePicUrl!.isEmpty
                                        ? Icon(
                                            Icons.person,
                                            size: 50,
                                            color: AppColors.primaryColor,
                                          )
                                        : null,
                                  ),
                                ),
                              ),
                              if (!isKycVerified)
                                Positioned(
                                  bottom: 0,
                                  right: 0,
                                  child: Container(
                                    padding: const EdgeInsets.all(4),
                                    decoration: BoxDecoration(
                                      color: AppColors.primaryColor,
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: Colors.white,
                                        width: 2,
                                      ),
                                    ),
                                    child: const Icon(
                                      Icons.camera_alt,
                                      size: 16,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                            ],
                          )
                          .animate()
                          .fadeIn(duration: 400.ms)
                          .scale(
                            delay: 200.ms,
                            duration: 400.ms,
                            begin: const Offset(0.8, 0.8),
                          ),

                      const SizedBox(height: 12),

                      Column(
                            children: [
                              Text(
                                user.firstName != null && user.lastName != null
                                    ? '${user.firstName} ${user.lastName}'
                                    : 'User',
                                style: GoogleFonts.nunito(
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                user.email ?? '',
                                style: GoogleFonts.nunito(
                                  fontSize: 14,
                                  color: Colors.grey[600],
                                ),
                              ),
                              if (user.phone != null)
                                Text(
                                  user.phone!,
                                  style: GoogleFonts.nunito(
                                    fontSize: 14,
                                    color: Colors.grey[600],
                                  ),
                                ),
                            ],
                          )
                          .animate()
                          .fadeIn(delay: 300.ms)
                          .slideY(begin: 0.2, end: 0, delay: 300.ms),
                    ],
                  ),
                ),

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    children: [
                      _buildKycStatusCard(user),
                      const SizedBox(height: 12),
                      _buildInfoSection(user).animate().fadeIn(delay: 600.ms),
                      _buildEmploymentSection(
                        user,
                      ).animate().fadeIn(delay: 700.ms),
                      _buildNextOfKinSection(
                        user,
                      ).animate().fadeIn(delay: 750.ms),
                      _buildDocumentsSection(
                        user,
                      ).animate().fadeIn(delay: 800.ms),
                      const SizedBox(height: 12),
                      _buildAccountActions().animate().fadeIn(delay: 900.ms),
                      const SizedBox(height: 20),
                      // Change Password button moved to bottom
                      if (!isKycVerified)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 20),
                          child: SizedBox(
                            width: double.infinity,
                            child: OutlinedButton.icon(
                              onPressed: _showUpdatePasswordModal,
                              icon: const Icon(Icons.lock_outline, size: 18),
                              label: Text(
                                'Change Password',
                                style: GoogleFonts.nunito(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: AppColors.primaryColor,
                                side: BorderSide(color: AppColors.primaryColor),
                                padding: const EdgeInsets.symmetric(
                                  vertical: 12,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoSection(UserProfile user) {
    return Container(
      margin: const EdgeInsets.only(top: 8),
      decoration: BoxDecoration(
        color: isKycVerified ? Colors.grey[50] : Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Personal Information',
                  style: GoogleFonts.nunito(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (!isKycVerified)
                  TextButton.icon(
                    onPressed: _navigateToEditProfile,
                    icon: Icon(
                      Icons.edit,
                      size: 18,
                      color: AppColors.primaryColor,
                    ),
                    label: Text(
                      'Edit',
                      style: GoogleFonts.nunito(color: AppColors.primaryColor),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 16),
            _buildInfoRow('First Name:', user.firstName ?? 'Not provided'),
            _buildInfoRow('Last Name:', user.lastName ?? 'Not provided'),
            _buildInfoRow('Email:', user.email ?? 'Not provided'),
            _buildInfoRow('Phone:', user.phone ?? 'Not provided'),
            if (user.dateOfBirth != null)
              _buildInfoRow(
                'Date of Birth:',
                DateFormat('yyyy-MM-dd').format(user.dateOfBirth!),
              ),
            if (user.address != null && user.address!.isNotEmpty)
              _buildInfoRow('Address:', user.address!),
            if (user.location != null && user.location!.isNotEmpty)
              _buildInfoRow('Location:', user.location!),
            if (user.gender != null) _buildInfoRow('Gender:', user.gender!),
            if (user.maritalStatus != null)
              _buildInfoRow('Marital Status:', user.maritalStatus!),
            if (user.nationalIdNumber != null)
              _buildInfoRow('National ID:', user.nationalIdNumber!),
            if (user.alternativePhone != null &&
                user.alternativePhone!.isNotEmpty)
              _buildInfoRow('Alternative Phone:', user.alternativePhone!),
          ],
        ),
      ),
    );
  }

  Widget _buildEmploymentSection(UserProfile user) {
    if (user.isEmployed != true || user.employmentDetails == null) {
      return const SizedBox();
    }

    return Container(
      margin: const EdgeInsets.only(top: 12),
      decoration: BoxDecoration(
        color: isKycVerified ? Colors.grey[50] : Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Employment Details',
              style: GoogleFonts.nunito(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            if (user.employmentDetails!.employerName != null &&
                user.employmentDetails!.employerName!.isNotEmpty)
              _buildInfoRow('Employer:', user.employmentDetails!.employerName!),
            if (user.employmentDetails!.jobTitle != null &&
                user.employmentDetails!.jobTitle!.isNotEmpty)
              _buildInfoRow('Job Title:', user.employmentDetails!.jobTitle!),
            if (user.employmentDetails!.duration != null &&
                user.employmentDetails!.duration!.isNotEmpty)
              _buildInfoRow('Duration:', user.employmentDetails!.duration!),
            if (user.employmentDetails!.location != null &&
                user.employmentDetails!.location!.isNotEmpty)
              _buildInfoRow(
                'Work Location:',
                user.employmentDetails!.location!,
              ),
            if (user.employmentDetails!.contacts != null &&
                user.employmentDetails!.contacts!.isNotEmpty)
              _buildInfoRow(
                'Work Contacts:',
                user.employmentDetails!.contacts!,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildNextOfKinSection(UserProfile user) {
    return Container(
      margin: const EdgeInsets.only(top: 12),
      decoration: BoxDecoration(
        color: isKycVerified ? Colors.grey[50] : Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Next of Kin',
                  style: GoogleFonts.nunito(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (!isKycVerified)
                  TextButton.icon(
                    onPressed: _showNextOfKinModal,
                    icon: Icon(
                      Icons.edit,
                      size: 18,
                      color: AppColors.primaryColor,
                    ),
                    label: Text(
                      'Edit',
                      style: GoogleFonts.nunito(color: AppColors.primaryColor),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 16),
            if (user.nextOfKin == null ||
                (user.nextOfKin!.fullName == null &&
                    user.nextOfKin!.relationship == null &&
                    user.nextOfKin!.phoneNumber == null))
              Center(
                child: Column(
                  children: [
                    Icon(
                      Icons.people_outline,
                      size: 48,
                      color: Colors.grey[400],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'No next of kin added',
                      style: GoogleFonts.nunito(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                    if (!isKycVerified) const SizedBox(height: 8),
                    if (!isKycVerified)
                      TextButton(
                        onPressed: _showNextOfKinModal,
                        child: Text(
                          'Add Now',
                          style: GoogleFonts.nunito(
                            color: AppColors.primaryColor,
                          ),
                        ),
                      ),
                  ],
                ),
              )
            else ...[
              if (user.nextOfKin!.fullName != null &&
                  user.nextOfKin!.fullName!.isNotEmpty)
                _buildInfoRow('Full Name:', user.nextOfKin!.fullName!),
              if (user.nextOfKin!.relationship != null &&
                  user.nextOfKin!.relationship!.isNotEmpty)
                _buildInfoRow('Relationship:', user.nextOfKin!.relationship!),
              if (user.nextOfKin!.phoneNumber != null &&
                  user.nextOfKin!.phoneNumber!.isNotEmpty)
                _buildInfoRow('Phone:', user.nextOfKin!.phoneNumber!),
              if (user.nextOfKin!.email != null &&
                  user.nextOfKin!.email!.isNotEmpty)
                _buildInfoRow('Email:', user.nextOfKin!.email!),
              if (user.nextOfKin!.address != null &&
                  user.nextOfKin!.address!.isNotEmpty)
                _buildInfoRow('Address:', user.nextOfKin!.address!),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 110,
            child: Text(
              label,
              style: GoogleFonts.nunito(fontSize: 14, color: Colors.grey[600]),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: GoogleFonts.nunito(
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAccountActions() {
    return Container(
      margin: const EdgeInsets.only(top: 12, bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Account Actions',
              style: GoogleFonts.nunito(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.logout_outlined,
                  color: Colors.grey,
                  size: 20,
                ),
              ),
              title: Text(
                'Log Out',
                style: GoogleFonts.nunito(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                ),
              ),
              trailing: const Icon(Icons.chevron_right, color: Colors.grey),
              onTap: logout,
            ),
            const Divider(height: 16),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.delete_outline,
                  color: Colors.red,
                  size: 20,
                ),
              ),
              title: Text(
                'Delete Account',
                style: GoogleFonts.nunito(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  color: Colors.red,
                ),
              ),
              trailing: const Icon(Icons.chevron_right, color: Colors.grey),
              onTap: _requestAccountDeletion,
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    otpController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      body: Obx(() {
        final user = _profileController.userProfile.value;
        final isLoadingController = _profileController.isLoading.value;

        if (isLoadingController && user == null) {
          return _buildLoadingScreen();
        } else if (hasError) {
          return _buildErrorScreen();
        } else if (user != null) {
          return _buildProfileContent();
        } else {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'No profile data available',
                  style: GoogleFonts.nunito(fontSize: 16),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: _checkAuthAndLoadProfile,
                  child: const Text('Retry'),
                ),
              ],
            ),
          );
        }
      }),
    );
  }
}
