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
    String? dateOfBirth,
    String? address,
    String? location,
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
      final success = await _profileController.updateProfile(
        firstName: firstName.trim(),
        lastName: lastName.trim(),
        phone: phone?.trim(),
        dateOfBirth: dateOfBirth?.trim(),
        address: address?.trim(),
        location: location?.trim(),
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
}
