import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/utils/api_response.dart';
import '../../../core/utils/pallete.dart';
import '../../../widgets/loading_widgets/circular_loader.dart';
import '../controllers/attached_files_mngmt_controller.dart';
import '../../../models/attachment_model.dart';

class AttachmentHelper {
  static final AttachmentController _attachmentController =
      Get.find<AttachmentController>();

  static final ImagePicker _picker = ImagePicker();
  static final SupabaseClient _supabase = Supabase.instance.client;

  // =========================================================
  // IMAGE PICKER (Camera / Gallery)
  // =========================================================
  static Future<void> showImagePickerDialog({
    required Function(List<String>) onUploadComplete,
    required String bucketName,
    String folder = 'attachments',
  }) async {
    bool isLoading = false;
    final uploadedUrls = <String>[];

    Get.dialog(
      StatefulBuilder(
        builder: (context, setState) => Dialog(
          alignment: Alignment.bottomCenter,
          insetPadding: EdgeInsets.zero,
          backgroundColor: Colors.transparent,
          child: Container(
            height: isLoading ? 150 : 200,
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: isLoading
                ? const Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircularProgressIndicator(),
                      SizedBox(height: 12),
                      Text('Uploading images...'),
                    ],
                  )
                : Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Choose an option',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Row(
                        children: [
                          Expanded(
                            child: GestureDetector(
                              onTap: () async {
                                final XFile? image = await _picker.pickImage(
                                  source: ImageSource.camera,
                                );
                                if (image != null) {
                                  setState(() => isLoading = true);
                                  final urls = await _uploadImagesToSupabase(
                                    [image],
                                    bucketName,
                                    folder,
                                  );
                                  uploadedUrls.addAll(urls);
                                  onUploadComplete(uploadedUrls);
                                  setState(() => isLoading = false);
                                  Get.back();
                                }
                              },
                              child: _pickerOption(
                                'Open Camera',
                                Icons.camera_alt,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: GestureDetector(
                              onTap: () async {
                                final images = await _picker.pickMultiImage();
                                if (images.isNotEmpty) {
                                  setState(() => isLoading = true);
                                  final urls = await _uploadImagesToSupabase(
                                    images,
                                    bucketName,
                                    folder,
                                  );
                                  uploadedUrls.addAll(urls);
                                  onUploadComplete(uploadedUrls);
                                  setState(() => isLoading = false);
                                  Get.back();
                                }
                              },
                              child: _pickerOption(
                                'Choose Photos',
                                Icons.photo,
                              ),
                            ),
                          ),
                        ],
                      ),
                      TextButton(
                        onPressed: () => Get.back(),
                        child: const Text('Cancel'),
                      ),
                    ],
                  ),
          ),
        ),
      ),
      barrierDismissible: false,
    );
  }

  // =========================================================
  // SUPABASE UPLOAD
  // =========================================================
  static Future<List<String>> _uploadImagesToSupabase(
    List<XFile> images,
    String bucket,
    String folder,
  ) async {
    final List<String> uploadedUrls = [];

    try {
      for (final image in images) {
        final filePath =
            '$folder/${DateTime.now().millisecondsSinceEpoch}_${image.name}';

        await _supabase.storage
            .from(bucket)
            .upload(
              filePath,
              File(image.path),
              fileOptions: const FileOptions(upsert: false),
            );

        final publicUrl = _supabase.storage.from(bucket).getPublicUrl(filePath);

        uploadedUrls.add(publicUrl);
      }
    } catch (e) {
      _showErrorDialog('Failed to upload images: ${e.toString()}');
    }

    return uploadedUrls;
  }

  // =========================================================
  // BACKEND ATTACHMENT REGISTRATION (Updated to return AttachmentModel)
  // =========================================================
  static Future<AttachmentModel?> uploadAttachment({
    required String entityType,
    required String entityId,
    required String category,
    required String filename,
    required String mimeType,
    required String url,
    required String meta,
  }) async {
    _attachmentController.clearUploadState();

    try {
      Get.dialog(
        const CustomLoader(message: 'Saving attachment...'),
        barrierDismissible: false,
      );

      final APIResponse<AttachmentModel> response = await _attachmentController
          .uploadAttachment(
            entityType: entityType,
            entityId: entityId,
            category: "other",
            filename: filename,
            mimeType: mimeType,
            storage: 'url',
            url: url,
            signed: false,
            meta: meta,
            file: null,
          );

      if (Get.isDialogOpen ?? false) Get.back();

      if (response.success && response.data != null) {
        _showSuccessSnackbar(response.message ?? 'Attachment saved');
        return response.data;
      } else {
        _showErrorDialog(response.message ?? 'Failed to save attachment');
        return null;
      }
    } catch (e) {
      if (Get.isDialogOpen ?? false) Get.back();
      _showErrorDialog('Unexpected error occurred: ${e.toString()}');
      return null;
    }
  }

  // =========================================================
  // UI HELPERS
  // =========================================================
  static Widget _pickerOption(String title, IconData icon) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 40, color: AppColors.primaryColor),
        const SizedBox(height: 8),
        Text(
          title,
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 14),
        ),
      ],
    );
  }

  static void _showSuccessSnackbar(String message) {
    Get.snackbar(
      'Success',
      message,
      backgroundColor: AppColors.successColor.withOpacity(0.1),
      colorText: AppColors.successColor,
      snackPosition: SnackPosition.TOP,
      margin: const EdgeInsets.all(16),
      borderRadius: 12,
      icon: Icon(Icons.check_circle, color: AppColors.successColor),
    );
  }

  static void _showErrorDialog(String message) {
    Get.defaultDialog(
      title: 'Error',
      middleText: message,
      confirm: ElevatedButton(
        onPressed: () => Get.back(),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryColor,
        ),
        child: const Text('OK'),
      ),
    );
  }
}
