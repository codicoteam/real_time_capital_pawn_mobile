// lib/features/profile_mngmt/helpers/profile_mngmt_helper.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:real_time_pawn/core/utils/logs.dart';
import 'package:real_time_pawn/core/utils/pallete.dart';
import 'package:real_time_pawn/features/profile_mngmt/controllers/profile_mngmt_controller.dart';
import 'package:real_time_pawn/models/profile_mngmt_model.dart';
import 'package:real_time_pawn/models/profile_mngmt_model.dart' as profile_mngmt_model show EmploymentDetails, NextOfKin, Document;
import 'package:real_time_pawn/models/register_body_model.dart';
import 'package:real_time_pawn/models/register_body_model.dart' as register_body_model;
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../models/profile_mngmt_model.dart' as profile_mngmt_model show EmploymentDetails, NextOfKin;

class ProfileMngmtHelper {
  static final _supabase = Supabase.instance.client;

  /// Initialize controller if not already done
  static ProfileController get _profileController {
    if (!Get.isRegistered<ProfileController>()) {
      Get.put(ProfileController());
    }
    return Get.find<ProfileController>();
  }

  /// Fetch user profile
  static Future<bool> fetchUserProfile() async {
    try {
      return await _profileController.fetchUserProfile();
    } catch (e) {
      showError('An error occurred: ${e.toString()}');
      return false;
    }
  }

  /// Upload document to Supabase
  static Future<String?> uploadDocumentToSupabase({
    required File imageFile,
    required String userId,
    required String documentType,
  }) async {
    try {
      final fileName =
          '${DateTime.now().millisecondsSinceEpoch}_${userId}_${documentType}.jpg';
      final filePath = 'users/$userId/$documentType/$fileName';

      DevLogs.logInfo('📤 Uploading $documentType to storage: $filePath');

      await _supabase.storage
          .from('topics')
          .upload(
            filePath,
            imageFile,
            fileOptions: const FileOptions(
              upsert: false,
              contentType: 'image/jpeg',
            ),
          );

      final publicUrl = _supabase.storage.from('topics').getPublicUrl(filePath);
      DevLogs.logInfo('🔗 Public URL for $documentType: $publicUrl');

      return publicUrl;
    } on StorageException catch (e) {
      DevLogs.logError(
        '❌ Storage Exception for $documentType: ${e.toString()}',
      );
      return null;
    } catch (e) {
      DevLogs.logError('❌ Error uploading $documentType: ${e.toString()}');
      return null;
    }
  }

  /// Convert UserProfile EmploymentDetails to RegisterBodyModel EmploymentDetails
  static register_body_model.EmploymentDetails? _convertEmploymentDetails(
      profile_mngmt_model.EmploymentDetails? details) {
    if (details == null) return null;
    return register_body_model.EmploymentDetails(
      employerName: details.employerName,
      jobTitle: details.jobTitle,
      duration: details.duration,
      location: details.location,
      contacts: details.contacts,
    );
  }

  /// Convert UserProfile NextOfKin to RegisterBodyModel NextOfKin
  static register_body_model.NextOfKin? _convertNextOfKin(
      profile_mngmt_model.NextOfKin? kin) {
    if (kin == null) return null;
    return register_body_model.NextOfKin(
      fullName: kin.fullName,
      relationship: kin.relationship,
      phoneNumber: kin.phoneNumber,
      email: kin.email,
      address: kin.address,
    );
  }

  /// Convert UserProfile Document to RegisterBodyModel Document
  static List<register_body_model.Document>? _convertDocuments(
      List<profile_mngmt_model.Document>? docs) {
    if (docs == null) return null;
    return docs.map((doc) => register_body_model.Document(
      type: doc.type,
      url: doc.url,
      fileName: doc.fileName,
      mimeType: doc.mimeType,
      notes: doc.notes,
    )).toList();
  }

  /// Convert UserProfile to RegisterBodyModel for update
  static RegisterBodyModel userProfileToRegisterBody(UserProfile user) {
    return RegisterBodyModel(
      email: user.email,
      firstName: user.firstName,
      lastName: user.lastName,
      phone: user.phone,
      dateOfBirth: user.dateOfBirth,
      address: user.address,
      location: user.location,
      gender: user.gender,
      maritalStatus: user.maritalStatus,
      alternativePhone: user.alternativePhone,
      nationalIdNumber: user.nationalIdNumber,
      nationalIdImageUrl: user.nationalIdImageUrl,
      profilePicUrl: user.profilePicUrl,
      passportExpiryDate: user.passportExpiryDate != null
          ? DateTime.tryParse(user.passportExpiryDate.toString())
          : null,
      isEmployed: user.isEmployed,
      employmentDetails: _convertEmploymentDetails(user.employmentDetails),
      nextOfKin: _convertNextOfKin(user.nextOfKin),
      documents: _convertDocuments(user.documents),
    );
  }

  /// Update profile with RegisterBodyModel
  static Future<bool> updateProfileWithModel({
    required RegisterBodyModel profileData,
  }) async {
    // Validation
    if (profileData.firstName?.isEmpty ?? true) {
      showError('First name is required');
      return false;
    }
    if (profileData.lastName?.isEmpty ?? true) {
      showError('Last name is required');
      return false;
    }

    try {
      final success = await _profileController.updateProfile(
        profileData: profileData,
      );

      if (success) {
        showSuccess('Profile updated successfully');
        return true;
      } else {
        showError(_profileController.errorMessage.value);
        return false;
      }
    } catch (e) {
      showError('An error occurred: ${e.toString()}');
      return false;
    }
  }

  /// Update profile with individual fields (convenience method)
  static Future<bool> updateProfile({
    required String firstName,
    required String lastName,
    String? phone,
    DateTime? dateOfBirth,
    String? address,
    String? location,
    String? gender,
    String? maritalStatus,
    String? alternativePhone,
    String? nationalIdNumber,
    String? profilePicUrl,
    bool? isEmployed,
    profile_mngmt_model.EmploymentDetails? employmentDetails,
    profile_mngmt_model.NextOfKin? nextOfKin,
  }) async {
    // Get current user data to preserve existing fields
    final currentUser = _profileController.userProfile.value;
    
    final profileData = RegisterBodyModel(
      email: currentUser?.email,
      firstName: firstName.trim(),
      lastName: lastName.trim(),
      phone: phone?.trim(),
      dateOfBirth: dateOfBirth,
      address: address,
      location: location,
      gender: gender,
      maritalStatus: maritalStatus,
      alternativePhone: alternativePhone?.trim(),
      nationalIdNumber: nationalIdNumber?.trim(),
      profilePicUrl: profilePicUrl,
      isEmployed: isEmployed ?? currentUser?.isEmployed,
      employmentDetails: _convertEmploymentDetails(employmentDetails ?? currentUser?.employmentDetails),
      nextOfKin: _convertNextOfKin(nextOfKin ?? currentUser?.nextOfKin),
      documents: _convertDocuments(currentUser?.documents),
    );

    return updateProfileWithModel(profileData: profileData);
  }

  /// Request account deletion
  static Future<bool> requestAccountDeletion({required String email}) async {
    if (email.isEmpty) {
      showError('Email is required');
      return false;
    }

    try {
      final response = await _profileController.requestAccountDeletion(
        email: email.trim(),
      );

      if (response.success) {
        showSuccess(response.message ?? 'Deletion OTP sent to your email');
        return true;
      } else {
        showError(response.message ?? 'Failed to request deletion');
        return false;
      }
    } catch (e) {
      showError('An error occurred: ${e.toString()}');
      return false;
    }
  }

  /// Confirm account deletion with OTP
  static Future<bool> confirmAccountDeletion({
    required String email,
    required String otp,
  }) async {
    if (email.isEmpty) {
      showError('Email is required');
      return false;
    }
    if (otp.isEmpty) {
      showError('OTP is required');
      return false;
    }

    try {
      final response = await _profileController.confirmAccountDeletion(
        email: email.trim(),
        otp: otp,
      );

      if (response.success) {
        showSuccess(response.message ?? 'Account deleted successfully');
        return true;
      } else {
        showError(response.message ?? 'Failed to delete account');
        return false;
      }
    } catch (e) {
      showError('An error occurred: ${e.toString()}');
      return false;
    }
  }

  /// Upload and update profile picture
  static Future<bool> uploadProfilePicture(File imageFile) async {
    try {
      final user = _profileController.userProfile.value;
      if (user == null) {
        showError('User not found');
        return false;
      }

      showLoading('Uploading profile picture...');

      final url = await uploadDocumentToSupabase(
        imageFile: imageFile,
        userId: user.id!,
        documentType: 'profile_pic',
      );

      if (url != null) {
        // Update profile with new picture URL
        final success = await updateProfile(
          firstName: user.firstName!,
          lastName: user.lastName!,
          phone: user.phone,
          profilePicUrl: url,
        );

        hideLoading();
        if (success) {
          showSuccess('Profile picture updated successfully');
          return true;
        }
      }

      hideLoading();
      showError('Failed to upload profile picture');
      return false;
    } catch (e) {
      hideLoading();
      showError('Error uploading picture: ${e.toString()}');
      return false;
    }
  }

  // Loading dialog
  static OverlayEntry? _loadingOverlay;

  static void showLoading(String message) {
    _loadingOverlay = OverlayEntry(
      builder: (context) => Material(
        color: Colors.black.withOpacity(0.5),
        child: Center(
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const CircularProgressIndicator(
                  color: AppColors.primaryColor,
                ),
                const SizedBox(height: 16),
                Text(
                  message,
                  style: GoogleFonts.nunito(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
    Overlay.of(Get.overlayContext!).insert(_loadingOverlay!);
  }

  static void hideLoading() {
    _loadingOverlay?.remove();
    _loadingOverlay = null;
  }

  // UI Feedback methods
  static void showSuccess(String message) {
    Get.snackbar(
      'Success',
      message,
      backgroundColor: Colors.green[50],
      colorText: Colors.green[700],
      icon: Icon(Icons.check_circle, color: Colors.green[700]),
      snackPosition: SnackPosition.TOP,
      duration: 2.seconds,
      margin: const EdgeInsets.all(16),
      borderRadius: 12,
    );
  }

  static void showError(String message) {
    Get.snackbar(
      'Error',
      message,
      backgroundColor: Colors.red[50],
      colorText: Colors.red[700],
      icon: Icon(Icons.error_outline, color: Colors.red[700]),
      snackPosition: SnackPosition.TOP,
      duration: 3.seconds,
      margin: const EdgeInsets.all(16),
      borderRadius: 12,
    );
  }

  static void clearMessages() {
    _profileController.clearMessages();
  }

  /// Get user data for loan application auto-fill
  static Future<Map<String, dynamic>?> getUserDataForLoanApplication() async {
    try {
      final controller = _profileController;

      if (controller.userProfile.value == null) {
        await fetchUserProfile();
      }

      final user = controller.userProfile.value;
      if (user == null) return null;

      return {
        'fullName': '${user.firstName} ${user.lastName}',
        'firstName': user.firstName,
        'lastName': user.lastName,
        'email': user.email,
        'phone': user.phone ?? '',
        'isEmailVerified': user.emailVerified ?? false,
        'status': user.status.toString(),
      };
    } catch (e) {
      showError('Error fetching user data: ${e.toString()}');
      return null;
    }
  }
}