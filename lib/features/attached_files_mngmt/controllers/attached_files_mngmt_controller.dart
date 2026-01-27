import 'dart:io';

import 'package:get/get.dart';
import '../../../core/utils/api_response.dart';
import '../../../core/utils/logs.dart';
import '../../../models/attachment_model.dart';
import '../services/attached_files_mngmt_service.dart' show AttachmentService;

class AttachmentController extends GetxController {
  // =====================
  // General states
  // =====================
  var isLoading = false.obs;
  var successMessage = ''.obs;
  var errorMessage = ''.obs;

  var attachments = <AttachmentModel>[].obs;
  var isUploading = false.obs;
  var uploadSuccessMessage = ''.obs;
  var uploadErrorMessage = ''.obs;

  // =====================
  // Search functionality
  // =====================
  final RxString searchQuery = ''.obs;
  final RxString searchType = 'category'.obs;
  // searchType values:
  // 'category', 'filename', 'mimeType', 'owner'

  // =====================
  // Fetch attachments
  // =====================
  Future<void> fetchAttachmentsByUserAndEntity({
    required String userId,
    required String entityType,
  }) async {
    try {
      isLoading(true);

      final response = await AttachmentService.getAttachmentsByUserAndEntity(
        userId: userId,
        entityType: entityType,
      );

      if (response.success) {
        attachments.value = response.data ?? [];
        successMessage.value =
            response.message ?? 'Attachments loaded successfully';
      } else {
        errorMessage.value = response.message!;
      }
    } catch (e) {
      DevLogs.logError('Error fetching attachments: $e');
      errorMessage.value = 'An error occurred while fetching attachments';
    } finally {
      isLoading(false);
    }
  }

  // =====================
  // Upload attachment
  // =====================
  Future<APIResponse<AttachmentModel>> uploadAttachment({
    required String entityType,
    required String entityId,
    required String category,
    required String filename,
    required String mimeType,
    required String storage,
    required String url,
    required bool signed,
    required String meta,
    File? file,
  }) async {
    try {
      isUploading(true);
      uploadSuccessMessage.value = '';
      uploadErrorMessage.value = '';

      final response = await AttachmentService.uploadAttachment(
        entityType: entityType,
        entityId: entityId,
        category: category,
        filename: filename,
        mimeType: mimeType,
        storage: storage,
        url: url,
        signed: signed,
        meta: meta,
        file: file,
      );

      if (response.success) {
        uploadSuccessMessage.value = response.message!;
        if (response.data != null) {
          // Insert at top for instant UI feedback
          attachments.insert(0, response.data!);
        }
        return response;
      } else {
        uploadErrorMessage.value = response.message!;
        DevLogs.logError(uploadErrorMessage.value);
        return response;
      }
    } catch (e) {
      DevLogs.logError('Error uploading attachment: $e');
      uploadErrorMessage.value = 'An error occurred while uploading attachment';
      return APIResponse<AttachmentModel>(
        success: false,
        message: uploadErrorMessage.value,
      );
    } finally {
      isUploading(false);
    }
  }

  // =====================
  // Refresh helper
  // =====================
  Future<void> refreshAttachments({
    required String userId,
    required String entityType,
  }) async {
    await fetchAttachmentsByUserAndEntity(
      userId: userId,
      entityType: entityType,
    );
  }

  // =====================
  // Filtered attachments
  // =====================
  List<AttachmentModel> get filteredAttachments {
    if (searchQuery.value.isEmpty) {
      return attachments;
    }

    final query = searchQuery.value.toLowerCase();

    return attachments.where((attachment) {
      switch (searchType.value) {
        case 'category':
          return attachment.category?.toLowerCase().contains(query) ?? false;

        case 'filename':
          return attachment.filename?.toLowerCase().contains(query) ?? false;

        case 'mimeType':
          return attachment.mimeType?.toLowerCase().contains(query) ?? false;

        case 'owner':
          final firstName =
              attachment.ownerUser?.firstName?.toLowerCase() ?? '';
          final lastName = attachment.ownerUser?.lastName?.toLowerCase() ?? '';
          return ('$firstName $lastName').contains(query);

        default:
          return false;
      }
    }).toList();
  }

  // =====================
  // Search helpers
  // =====================
  void updateSearchQuery(String query) {
    searchQuery.value = query;
  }

  void updateSearchType(String type) {
    searchType.value = type;
  }

  void clearSearch() {
    searchQuery.value = '';
  }

  // =====================
  // Clear upload state
  // =====================
  void clearUploadState() {
    uploadSuccessMessage.value = '';
    uploadErrorMessage.value = '';
  }

  // =====================
  // Utility helpers
  // =====================
  void reverseAttachments() {
    attachments.value = attachments.reversed.toList();
  }

  void shuffleAttachments() {
    final shuffled = attachments.toList();
    shuffled.shuffle();
    attachments.value = shuffled;
  }
}
