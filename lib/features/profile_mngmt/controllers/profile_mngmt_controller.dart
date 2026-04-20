// lib/features/profile_mngmt/controllers/profile_mngmt_controller.dart
import 'dart:convert';

import 'package:get/get.dart';
import 'package:real_time_pawn/core/utils/api_response.dart';
import 'package:real_time_pawn/features/attached_files_mngmt/services/attached_files_mngmt_service.dart';
import 'package:real_time_pawn/features/profile_mngmt/services/profile_mngmt_services.dart';
import 'package:real_time_pawn/models/profile_mngmt_model.dart';
import 'package:real_time_pawn/models/register_body_model.dart' hide NextOfKin;

class ProfileController extends GetxController {
  // State variables
  final Rx<UserProfile?> userProfile = Rx<UserProfile?>(null);
  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;
  final RxString successMessage = ''.obs;

  // Clear messages

  void clearMessages() {
    errorMessage.value = '';
    successMessage.value = '';
  }

  /// Fetch user profile from backend
  Future<bool> fetchUserProfile() async {
    try {
      isLoading.value = true;
      clearMessages();

      final APIResponse<UserProfile> response =
          await ProfileMngmtServices.getUserProfile();

      if (response.success) {
        userProfile.value = response.data;
        successMessage.value =
            response.message ?? 'Profile loaded successfully';
        return true;
      } else {
        errorMessage.value = response.message ?? 'Failed to load profile';
        return false;
      }
    } catch (e) {
      errorMessage.value = 'An error occurred: $e';
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  /// Update user profile using RegisterBodyModel
  Future<bool> updateProfile({required RegisterBodyModel profileData}) async {
    try {
      isLoading.value = true;
      clearMessages();

      final APIResponse<UserProfile> response =
          await ProfileMngmtServices.updateUserProfile(
            profileData: profileData,
          );

      if (response.success) {
        userProfile.value = response.data;
        successMessage.value =
            response.message ?? 'Profile updated successfully';
        return true;
      } else {
        errorMessage.value = response.message ?? 'Failed to update profile';
        return false;
      }
    } catch (e) {
      errorMessage.value = 'An error occurred: $e';
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  /// Update profile picture (standalone)
  Future<APIResponse<String>> updateProfilePicture({
    required String profilePicUrl,
  }) async {
    try {
      isLoading.value = true;
      clearMessages();

      final response = await ProfileMngmtServices.updateProfilePicture(
        profilePicUrl: profilePicUrl,
      );

      if (response.success) {
        successMessage.value =
            response.message ?? 'Profile picture updated successfully';
        // Update the profile picture in the local userProfile if it exists

      } else {
        errorMessage.value =
            response.message ?? 'Failed to update profile picture';
      }

      return response;
    } catch (e) {
      errorMessage.value = 'An error occurred: $e';
      return APIResponse<String>(
        success: false,
        message: 'An error occurred: $e',
      );
    } finally {
      isLoading.value = false;
    }
  }

  /// Update next of kin details (standalone)
  Future<APIResponse<Map<String, dynamic>>> updateNextOfKin({
    required String fullName,
    required String relationship,
    required String phoneNumber,
    required String email,
    required String address,
  }) async {
    try {
      isLoading.value = true;
      clearMessages();

      final response = await ProfileMngmtServices.updateNextOfKin(
        fullName: fullName,
        relationship: relationship,
        phoneNumber: phoneNumber,
        email: email,
        address: address,
      );

      if (response.success) {
        successMessage.value =
            response.message ?? 'Next of kin details updated successfully';
   
      } else {
        errorMessage.value =
            response.message ?? 'Failed to update next of kin details';
      }

      return response;
    } catch (e) {
      errorMessage.value = 'An error occurred: $e';
      return APIResponse<Map<String, dynamic>>(
        success: false,
        message: 'An error occurred: $e',
      );
    } finally {
      isLoading.value = false;
    }
  }

  /// Update KYC documents and details (standalone)
  Future<APIResponse<UserProfile>> updateKycDetails({
    String? nationalIdNumber,
    DateTime? dateOfBirth,
    String? address,
    String? location,
    String? gender,
    String? maritalStatus,
    String? alternativePhone,
    String? nationalIdImageUrl,
    String? passportImageUrl,
    String? proofOfAddressUrl,
    DateTime? passportExpiryDate,
    DateTime? drivingLicenseExpiryDate,
    DateTime? nationalIdExpiryDate,
    bool? isEmployed,
    Map<String, dynamic>? employmentDetails,
  }) async {
    try {
      isLoading.value = true;
      clearMessages();

      final response = await ProfileMngmtServices.updateKycDetails(
        nationalIdNumber: nationalIdNumber,
        dateOfBirth: dateOfBirth,
        address: address,
        location: location,
        gender: gender,
        maritalStatus: maritalStatus,
        alternativePhone: alternativePhone,
        nationalIdImageUrl: nationalIdImageUrl,
        passportImageUrl: passportImageUrl,
        proofOfAddressUrl: proofOfAddressUrl,
        passportExpiryDate: passportExpiryDate,
        drivingLicenseExpiryDate: drivingLicenseExpiryDate,
        nationalIdExpiryDate: nationalIdExpiryDate,
        isEmployed: isEmployed,
        employmentDetails: employmentDetails,
      );

      if (response.success) {
        successMessage.value =
            response.message ?? 'KYC details updated successfully';
        // Update the local userProfile with the new data
        if (response.data != null) {
          userProfile.value = response.data;
          userProfile.refresh();
        }
      } else {
        errorMessage.value = response.message ?? 'Failed to update KYC details';
      }

      return response;
    } catch (e) {
      errorMessage.value = 'An error occurred: $e';
      return APIResponse<UserProfile>(
        success: false,
        message: 'An error occurred: $e',
      );
    } finally {
      isLoading.value = false;
    }
  }

  /// Update password for logged-in user (standalone)
  Future<APIResponse<String>> updatePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    try {
      isLoading.value = true;
      clearMessages();

      final response = await ProfileMngmtServices.updatePassword(
        currentPassword: currentPassword,
        newPassword: newPassword,
      );

      if (response.success) {
        successMessage.value =
            response.message ?? 'Password updated successfully';
      } else {
        errorMessage.value = response.message ?? 'Failed to update password';
      }

      return response;
    } catch (e) {
      errorMessage.value = 'An error occurred: $e';
      return APIResponse<String>(
        success: false,
        message: 'An error occurred: $e',
      );
    } finally {
      isLoading.value = false;
    }
  }

  /// Update personal details (standalone)
  Future<APIResponse<UserProfile>> updatePersonalDetails({
    String? firstName,
    String? lastName,
    String? phone,
    DateTime? dateOfBirth,
    String? address,
    String? location,
    String? gender,
    String? maritalStatus,
    String? alternativePhone,
  }) async {
    try {
      isLoading.value = true;
      clearMessages();

      final response = await ProfileMngmtServices.updatePersonalDetails(
        firstName: firstName,
        lastName: lastName,
        phone: phone,
        dateOfBirth: dateOfBirth,
        address: address,
        location: location,
        gender: gender,
        maritalStatus: maritalStatus,
        alternativePhone: alternativePhone,
      );

      if (response.success) {
        successMessage.value =
            response.message ?? 'Personal details updated successfully';
        // Update the local userProfile with the new data
        if (response.data != null) {
          userProfile.value = response.data;
          userProfile.refresh();
        }
      } else {
        errorMessage.value =
            response.message ?? 'Failed to update personal details';
      }

      return response;
    } catch (e) {
      errorMessage.value = 'An error occurred: $e';
      return APIResponse<UserProfile>(
        success: false,
        message: 'An error occurred: $e',
      );
    } finally {
      isLoading.value = false;
    }
  }

  /// Request account deletion
  Future<APIResponse<String>> requestAccountDeletion({
    required String email,
  }) async {
    try {
      isLoading.value = true;
      clearMessages();

      final response = await ProfileMngmtServices.requestAccountDeletion(
        email: email,
      );

      if (response.success) {
        successMessage.value = response.message ?? 'Deletion OTP sent to email';
      } else {
        errorMessage.value = response.message ?? 'Failed to request deletion';
      }

      return response;
    } catch (e) {
      errorMessage.value = 'An error occurred: $e';
      return APIResponse<String>(
        success: false,
        message: 'An error occurred: $e',
      );
    } finally {
      isLoading.value = false;
    }
  }

  /// Confirm account deletion with OTP
  Future<APIResponse<bool>> confirmAccountDeletion({
    required String email,
    required String otp,
  }) async {
    try {
      isLoading.value = true;
      clearMessages();

      final response = await ProfileMngmtServices.confirmAccountDeletion(
        email: email,
        otp: otp,
      );

      if (response.success) {
        successMessage.value =
            response.message ?? 'Account deleted successfully';
        // Clear local data
        userProfile.value = null;
      } else {
        errorMessage.value = response.message ?? 'Failed to delete account';
      }

      return response;
    } catch (e) {
      errorMessage.value = 'An error occurred: $e';
      return APIResponse<bool>(
        success: false,
        message: 'An error occurred: $e',
      );
    } finally {
      isLoading.value = false;
    }
  }
}
