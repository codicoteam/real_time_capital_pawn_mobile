// lib/features/profile_mngmt/widgets/profile_picture_modal.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart' show GoogleFonts;
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:real_time_pawn/core/utils/logs.dart';
import 'package:real_time_pawn/core/utils/pallete.dart';
import 'package:real_time_pawn/core/utils/shared_pref_methods.dart';
import 'package:real_time_pawn/features/profile_mngmt/controllers/profile_mngmt_controller.dart';

class ProfilePictureModal extends StatefulWidget {
  final Function(String? newImageUrl) onImageUpdated;

  const ProfilePictureModal({
    super.key,
    required this.onImageUpdated,
  });

  @override
  State<ProfilePictureModal> createState() => _ProfilePictureModalState();
}

class _ProfilePictureModalState extends State<ProfilePictureModal> {
  final ImagePicker _imagePicker = ImagePicker();
  final ProfileController _profileController = Get.find<ProfileController>();
  bool _isUploading = false;

  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? pickedFile = await _imagePicker.pickImage(
        source: source,
        imageQuality: 85,
      );

      if (pickedFile != null) {
        final confirmed = await _showImagePreview(File(pickedFile.path));
        if (confirmed == true) {
          await _uploadProfilePicture(File(pickedFile.path));
        }
      }
    } catch (e) {
      _showError('Failed to pick image: $e');
    }
  }

  Future<bool?> _showImagePreview(File imageFile) async {
    return await Get.dialog<bool>(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              height: 350,
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                image: DecorationImage(
                  image: FileImage(imageFile),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  TextButton(
                    onPressed: () => Get.back(result: false),
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    ),
                    child: Text('Cancel', style: GoogleFonts.nunito(fontSize: 16)),
                  ),
                  ElevatedButton(
                    onPressed: () => Get.back(result: true),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryColor,
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text('Use Photo', style: GoogleFonts.nunito(fontSize: 16, color: Colors.white)),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _uploadProfilePicture(File imageFile) async {
    setState(() => _isUploading = true);

    try {
      final userId = await CacheUtils.getUserId();
      if (userId == null || userId.isEmpty) {
        throw Exception('User not logged in');
      }

      final fileExtension = imageFile.path.split('.').last;
      final fileName = '${DateTime.now().millisecondsSinceEpoch}_profile.$fileExtension';
      final filePath = '$userId/profile_pictures/$fileName';

      await Supabase.instance.client.storage
          .from('topics')
          .upload(filePath, imageFile);

      final publicUrl = Supabase.instance.client.storage
          .from('topics')
          .getPublicUrl(filePath);

      final response = await _profileController.updateProfilePicture(
        profilePicUrl: publicUrl,
      );

      if (response.success) {
        widget.onImageUpdated(publicUrl);
        Get.back();
        _showSuccess('Profile picture updated successfully');
      } else {
        _showError(response.message ?? 'Failed to update profile picture');
      }
    } catch (e) {
      DevLogs.logError('Failed to upload profile picture: $e');
      _showError('Failed to upload image: $e');
    } finally {
      if (mounted) setState(() => _isUploading = false);
    }
  }

  void _showSuccess(String message) {
    Get.snackbar(
      'Success',
      message,
      backgroundColor: Colors.green,
      colorText: Colors.white,
      snackPosition: SnackPosition.BOTTOM,
      margin: const EdgeInsets.all(16),
      borderRadius: 12,
      duration: const Duration(seconds: 2),
    );
  }

  void _showError(String message) {
    Get.snackbar(
      'Error',
      message,
      backgroundColor: AppColors.errorColor,
      colorText: Colors.white,
      snackPosition: SnackPosition.BOTTOM,
      margin: const EdgeInsets.all(16),
      borderRadius: 12,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              child: Text(
                'Update Profile Picture',
                style: GoogleFonts.nunito(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const Divider(height: 24),
            if (_isUploading)
              const Padding(
                padding: EdgeInsets.all(40),
                child: Column(
                  children: [
                    CircularProgressIndicator(color: AppColors.primaryColor),
                    SizedBox(height: 16),
                    Text('Uploading...', style: TextStyle(color: AppColors.primaryColor)),
                  ],
                ),
              )
            else ...[
              _buildOption(
                icon: Icons.camera_alt,
                title: 'Take Photo',
                subtitle: 'Use your camera to take a new photo',
                color: AppColors.primaryColor,
                onTap: () => _pickImage(ImageSource.camera),
              ),
              _buildOption(
                icon: Icons.photo_library,
                title: 'Choose from Gallery',
                subtitle: 'Select an existing photo from your gallery',
                color: AppColors.primaryColor,
                onTap: () => _pickImage(ImageSource.gallery),
              ),
              const Divider(height: 32),
              _buildOption(
                icon: Icons.close,
                title: 'Cancel',
                subtitle: 'Go back to profile',
                color: Colors.red,
                isDestructive: true,
                onTap: () => Get.back(),
              ),
            ],
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildOption({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    bool isDestructive = false,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        child: Row(
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.nunito(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: isDestructive ? Colors.red : Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: GoogleFonts.nunito(
                      fontSize: 13,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right, color: Colors.grey[400]),
          ],
        ),
      ),
    ).animate().fadeIn().slideX(begin: -0.1, end: 0);
  }
}