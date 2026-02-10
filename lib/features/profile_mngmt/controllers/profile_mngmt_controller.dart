// lib/features/profile_mngmt/controllers/profile_mngmt_controller.dart
import 'dart:convert';

import 'package:get/get.dart';
import 'package:real_time_pawn/core/utils/api_response.dart';
import 'package:real_time_pawn/features/attached_files_mngmt/services/attached_files_mngmt_service.dart';
import 'package:real_time_pawn/features/profile_mngmt/services/profile_mngmt_services.dart';
import 'package:real_time_pawn/models/profile_mngmt_model.dart';

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

  /// Update user profile
  Future<bool> updateProfile({
    required String firstName,
    required String lastName,
    String? phone,
    String? dateOfBirth,
    String? address,
    String? location,
    String? profilePicUrl,
  }) async {
    try {
      isLoading.value = true;
      clearMessages();

      final APIResponse<UserProfile> response =
          await ProfileMngmtServices.updateUserProfile(
            firstName: firstName,
            lastName: lastName,
            phone: phone,
            dateOfBirth: dateOfBirth,
            address: address,
            location: location,
            profilePicUrl: profilePicUrl,
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

  /// Upload document
  Future<bool> uploadDocument({
    required String type,
    required String url,
    required String fileName,
    required String mimeType,
    String? notes,
  }) async {
    try {
      isLoading.value = true;
      clearMessages();

      final APIResponse<Document> response =
          await ProfileMngmtServices.uploadDocument(
            type: type,
            url: url,
            fileName: fileName,
            mimeType: mimeType,
            notes: notes,
          );

      if (response.success && userProfile.value != null) {
        // Add to local profile
        final newProfile = UserProfile(
          id: userProfile.value!.id,
          email: userProfile.value!.email,
          phone: userProfile.value!.phone,
          roles: userProfile.value!.roles,
          firstName: userProfile.value!.firstName,
          lastName: userProfile.value!.lastName,
          fullName: userProfile.value!.fullName,
          status: userProfile.value!.status,
          nationalIdNumber: userProfile.value!.nationalIdNumber,
          dateOfBirth: userProfile.value!.dateOfBirth,
          address: userProfile.value!.address,
          location: userProfile.value!.location,
          termsAcceptedAt: userProfile.value!.termsAcceptedAt,
          nationalIdImageUrl: userProfile.value!.nationalIdImageUrl,
          profilePicUrl: userProfile.value!.profilePicUrl,
          documents: [...userProfile.value!.documents, response.data!],
          isEmailVerified: userProfile.value!.isEmailVerified,
          createdAt: userProfile.value!.createdAt,
          updatedAt: DateTime.now(),
        );

        userProfile.value = newProfile;
        successMessage.value =
            response.message ?? 'Document uploaded successfully';
        return true;
      } else {
        errorMessage.value = response.message ?? 'Failed to upload document';
        return false;
      }
    } catch (e) {
      errorMessage.value = 'An error occurred: $e';
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  /// Delete document
  Future<bool> deleteDocument(String documentId) async {
    try {
      isLoading.value = true;
      clearMessages();

      final APIResponse<bool> response =
          await ProfileMngmtServices.deleteDocument(documentId);

      if (response.success && userProfile.value != null) {
        // Remove from local profile
        final updatedDocuments = userProfile.value!.documents
            .where((doc) => doc.id != documentId)
            .toList();

        final newProfile = UserProfile(
          id: userProfile.value!.id,
          email: userProfile.value!.email,
          phone: userProfile.value!.phone,
          roles: userProfile.value!.roles,
          firstName: userProfile.value!.firstName,
          lastName: userProfile.value!.lastName,
          fullName: userProfile.value!.fullName,
          status: userProfile.value!.status,
          nationalIdNumber: userProfile.value!.nationalIdNumber,
          dateOfBirth: userProfile.value!.dateOfBirth,
          address: userProfile.value!.address,
          location: userProfile.value!.location,
          termsAcceptedAt: userProfile.value!.termsAcceptedAt,
          nationalIdImageUrl: userProfile.value!.nationalIdImageUrl,
          profilePicUrl: userProfile.value!.profilePicUrl,
          documents: updatedDocuments,
          isEmailVerified: userProfile.value!.isEmailVerified,
          createdAt: userProfile.value!.createdAt,
          updatedAt: DateTime.now(),
        );

        userProfile.value = newProfile;
        successMessage.value =
            response.message ?? 'Document deleted successfully';
        return true;
      } else {
        errorMessage.value = response.message ?? 'Failed to delete document';
        return false;
      }
    } catch (e) {
      errorMessage.value = 'An error occurred: $e';
      return false;
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

  // Add these getters for the helper file
  bool get isProfileLoading => isLoading.value;
  String get currentErrorMessage => errorMessage.value;
  String get currentSuccessMessage => successMessage.value;

  /// Fetch user attachments from Attachments API
  Future<void> fetchUserAttachments() async {
    try {
      final user = userProfile.value;
      if (user == null) return;

      final response = await AttachmentService.getAttachmentsByUserAndEntity(
        userId: user.id,
        entityType: 'User',
        entityId: user.id,
      );

      if (response.success && response.data != null) {
        // Convert attachments to Document objects
        final attachmentsAsDocuments = response.data!.map((attachment) {
          final meta = json.decode(attachment.meta ?? '{}');
          return Document(
            id: attachment.id!, // Use attachment ID
            type: _parseDocumentTypeFromString(
              meta['document_type'] ?? 'other',
            ),
            url: attachment.url ?? '',
            fileName: attachment.filename ?? '',
            mimeType: attachment.mimeType ?? 'image/jpeg',
            uploadedAt: attachment.createdAt ?? DateTime.now(),
            notes: meta['notes'] ?? '',
          );
        }).toList();

        // Combine with existing documents
        final allDocuments = [
          ...user.documents, // Old documents (empty)
          ...attachmentsAsDocuments, // New attachments
        ];

        userProfile.value = user.copyWith(documents: allDocuments);
      }
    } catch (e) {
      print('Error fetching attachments: $e');
    }
  }

  /// Helper method to parse document type from string
  DocumentType _parseDocumentTypeFromString(String typeString) {
    switch (typeString) {
      case 'national_id':
        return DocumentType.national_id;
      case 'passport':
        return DocumentType.passport;
      case 'proof_of_address':
      case 'proof_of_residence':
        return DocumentType.proof_of_address;
      default:
        return DocumentType.other;
    }
  }
}
