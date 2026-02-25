// lib/features/profile_mngmt/helpers/profile_mngmt_helper.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:real_time_pawn/features/profile_mngmt/controllers/profile_mngmt_controller.dart';
import 'package:real_time_pawn/models/profile_mngmt_model.dart';

class ProfileMngmtHelper {
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

  /// Update profile with validation
  static Future<bool> updateProfile({
    required String firstName,
    required String lastName,
    String? phone,
    // ❌ REMOVED: These fields don't exist in your backend
    // String? dateOfBirth,
    // String? address,
    // String? location,
    String? profilePicUrl,
  }) async {
    // Validation
    if (firstName.isEmpty) {
      showError('First name is required');
      return false;
    }
    if (lastName.isEmpty) {
      showError('Last name is required');
      return false;
    }

    try {
      // ✅ UPDATED: Only pass fields that exist
      final success = await _profileController.updateProfile(
        firstName: firstName.trim(),
        lastName: lastName.trim(),
        phone: phone?.trim(),
        // ❌ REMOVED: dateOfBirth, address, location
        profilePicUrl: profilePicUrl,
      );

      if (success) {
        showSuccess('Profile updated successfully');
        return true;
      } else {
        showError(_profileController.currentErrorMessage);
        return false;
      }
    } catch (e) {
      showError('An error occurred: ${e.toString()}');
      return false;
    }
  }

  /// Upload document
  static Future<bool> uploadDocument({
    required String type,
    required String url,
    required String fileName,
    required String mimeType,
    String? notes,
  }) async {
    try {
      final success = await _profileController.uploadDocument(
        type: type,
        url: url,
        fileName: fileName,
        mimeType: mimeType,
        notes: notes,
      );

      if (success) {
        showSuccess('Document uploaded successfully');
        return true;
      } else {
        showError(_profileController.currentErrorMessage);
        return false;
      }
    } catch (e) {
      showError('An error occurred: ${e.toString()}');
      return false;
    }
  }

  /// Delete document
  static Future<bool> deleteDocument(String documentId) async {
    final confirmed = await Get.dialog<bool>(
      AlertDialog(
        title: const Text('Delete Document'),
        content: const Text('Are you sure you want to delete this document?'),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Get.back(result: true),
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmed != true) return false;

    try {
      final success = await _profileController.deleteDocument(documentId);

      if (success) {
        showSuccess('Document deleted successfully');
        return true;
      } else {
        showError(_profileController.currentErrorMessage);
        return false;
      }
    } catch (e) {
      showError('An error occurred: ${e.toString()}');
      return false;
    }
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

  /// Get document ID for deletion (handles mock data)
  static String? getDocumentIdForDeletion(Document document) {
    // If the document ID is "string" (mock data), we can't delete it
    if (document.id == 'string') {
      showError(
        'Cannot delete mock document. Please upload a real document first.',
      );
      return null;
    }
    return document.id;
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

      // If profile not loaded, fetch it first
      if (controller.userProfile.value == null) {
        await fetchUserProfile();
      }

      final user = controller.userProfile.value;
      if (user == null) return null;

      // ✅ ONLY USE FIELDS FROM YOUR BACKEND
      return {
        // ✅ Available from profile response
        'fullName': '${user.firstName} ${user.lastName}',
        'firstName': user.firstName,
        'lastName': user.lastName,
        'email': user.email,
        'phone': user.phone ?? '',

        // ✅ Document info if available
        'hasDocuments': user.documents.isNotEmpty,
        'documentCount': user.documents.length,

        // ✅ Status information
        'isEmailVerified': user.isEmailVerified,
        'status': user.status.toString(),

        // ✅ Calculate profile completeness based on ACTUAL fields
        'hasBasicInfo': _hasBasicInfo(user),
        'hasCompleteProfile': _hasCompleteProfile(user),
        'missingFields': _getMissingFields(user),
      };
    } catch (e) {
      showError('Error fetching user data: ${e.toString()}');
      return null;
    }
  }

  /// ✅ Update: Check if we have minimum required for auto-fill
  static bool _hasBasicInfo(UserProfile user) {
    return user.firstName.isNotEmpty &&
        user.lastName.isNotEmpty &&
        user.email.isNotEmpty &&
        user.isEmailVerified;
  }

  /// ✅ Update: Check if profile is complete based on ACTUAL requirements
  static bool _hasCompleteProfile(UserProfile user) {
    return _hasBasicInfo(user) &&
        user.phone != null &&
        user.phone!.isNotEmpty &&
        user.documents.isNotEmpty;
  }

  /// ✅ Update: Get list of missing fields based on ACTUAL fields
  static List<String> _getMissingFields(UserProfile user) {
    List<String> missing = [];

    if (user.phone == null || user.phone!.isEmpty) {
      missing.add('Phone Number');
    }

    if (!user.isEmailVerified) {
      missing.add('Email Verification');
    }

    if (user.documents.isEmpty) {
      missing.add('Documents (ID, Proof of Address)');
    }

    return missing;
  }
}
