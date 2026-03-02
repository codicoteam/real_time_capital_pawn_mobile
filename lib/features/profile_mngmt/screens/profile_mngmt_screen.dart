// lib/features/profile_mngmt/screens/profile_screen.dart
import 'dart:convert';
import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:photo_view/photo_view.dart';
import 'package:real_time_pawn/core/utils/pallete.dart';
import 'package:real_time_pawn/core/utils/shared_pref_methods.dart';
import 'package:real_time_pawn/features/attached_files_mngmt/helpers/attached_files_mngmt_helper.dart';
import 'package:real_time_pawn/features/attached_files_mngmt/services/attached_files_mngmt_service.dart';
import 'package:real_time_pawn/models/profile_mngmt_model.dart';
import 'package:real_time_pawn/widgets/custom_button/general_button.dart';
import 'package:real_time_pawn/widgets/text_fields/custom_text_field.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../widgets/profile_widgets/profile_widgets.dart';
import '../controllers/profile_mngmt_controller.dart';
import '../helpers/profile_mngmt_helper.dart';

// ✅ ADD THE ENUM HERE
enum DocumentType { national_id, passport, proof_of_address }

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final ProfileController _profileController = Get.put(ProfileController());

  bool isEditing = false;
  bool isLoading = false;
  bool hasError = false;
  String errorMessage = '';
  final ImagePicker _imagePicker = ImagePicker();

  // ✅ UPDATED: Only controllers for fields that exist
  late TextEditingController firstNameCtrl;
  late TextEditingController lastNameCtrl;
  late TextEditingController phoneCtrl;

  // For account deletion
  final TextEditingController otpController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _initializeControllers();
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
      // Check if token exists
      final token = await CacheUtils.checkToken();

      if (token == null || token.isEmpty) {
        // No token - redirect to login
        Get.offAllNamed('/login');
        return;
      }

      // Token exists - load profile
      await _loadProfile();
    } catch (e) {
      setState(() {
        hasError = true;
        errorMessage = 'Authentication error: $e';
      });
    } finally {
      setState(() => isLoading = false);
    }
  }

  Future<void> _loadProfile() async {
    try {
      // 1. Fetch user profile
      final success = await ProfileMngmtHelper.fetchUserProfile();

      if (success && _profileController.userProfile.value != null) {
        _updateControllers();

        // 2. ALSO FETCH ATTACHMENTS FROM ATTACHMENTS API
        await _profileController.fetchUserAttachments();
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

  void _initializeControllers() {
    firstNameCtrl = TextEditingController();
    lastNameCtrl = TextEditingController();
    phoneCtrl = TextEditingController();
  }

  void _updateControllers() {
    if (_profileController.userProfile.value != null) {
      final user = _profileController.userProfile.value!;
      setState(() {
        firstNameCtrl.text = user.firstName;
        lastNameCtrl.text = user.lastName;
        phoneCtrl.text = user.phone ?? '';
      });
    }
  }

  @override
  void dispose() {
    firstNameCtrl.dispose();
    lastNameCtrl.dispose();
    phoneCtrl.dispose();
    otpController.dispose();
    super.dispose();
  }

  Future<void> _pickProfileImage() async {
    final result = await Get.bottomSheet(
      Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: const Text('Take Photo'),
                onTap: () => Get.back(result: 'camera'),
              ),
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Choose from Gallery'),
                onTap: () => Get.back(result: 'gallery'),
              ),
              ListTile(
                leading: const Icon(Icons.cancel, color: Colors.red),
                title: const Text('Cancel'),
                onTap: () => Get.back(),
              ),
            ],
          ),
        ),
      ),
    );

    if (result == null) return;

    setState(() => isLoading = true);

    try {
      final XFile? pickedFile = await _imagePicker.pickImage(
        source: result == 'camera' ? ImageSource.camera : ImageSource.gallery,
        imageQuality: 85,
      );

      if (pickedFile != null) {
        final confirmed = await _showImagePreview(pickedFile);
        if (confirmed == true) {
          await _uploadProfileImage(File(pickedFile.path));
        }
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to pick image: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      setState(() => isLoading = false);
    }
  }

  Future<bool?> _showImagePreview(XFile file) async {
    return await Get.dialog<bool>(
      Dialog(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              height: 300,
              child: PhotoView(imageProvider: FileImage(File(file.path))),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  TextButton(
                    onPressed: () => Get.back(result: false),
                    child: const Text('Cancel'),
                  ),
                  const SizedBox(width: 20),
                  ElevatedButton(
                    onPressed: () => Get.back(result: true),
                    child: const Text('Use This Photo'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _uploadProfileImage(File imageFile) async {
    try {
      // TODO: IMPLEMENT ACTUAL IMAGE UPLOAD TO YOUR STORAGE SERVICE
      Get.snackbar(
        'Info',
        'Image upload feature requires storage integration',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.blue,
        colorText: Colors.white,
      );
    } catch (e) {
      Get.snackbar(
        'Upload Failed',
        'Error: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  void toggleEdit() {
    setState(() {
      if (isEditing) {
        _updateControllers();
      }
      isEditing = !isEditing;
    });
  }

  Future<void> saveProfile() async {
    // Check form validation
    if (firstNameCtrl.text.trim().isEmpty) {
      Get.snackbar(
        'Validation Error',
        'First name is required',
        backgroundColor: Colors.red[50],
        colorText: Colors.red[700],
      );
      return;
    }

    if (lastNameCtrl.text.trim().isEmpty) {
      Get.snackbar(
        'Validation Error',
        'Last name is required',
        backgroundColor: Colors.red[50],
        colorText: Colors.red[700],
      );
      return;
    }

    setState(() => isLoading = true);

    try {
      final success = await ProfileMngmtHelper.updateProfile(
        firstName: firstNameCtrl.text.trim(),
        lastName: lastNameCtrl.text.trim(),
        phone: phoneCtrl.text.trim().isNotEmpty ? phoneCtrl.text.trim() : null,
      );

      if (success) {
        setState(() => isEditing = false);
        Get.snackbar(
          'Success',
          'Profile updated successfully',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: AppColors.successColor,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to update profile: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      setState(() => isLoading = false);
    }
  }

  Future<void> uploadDocument() async {
    // Show document type selection
    final documentType = await Get.dialog<DocumentType>(
      AlertDialog(
        title: const Text('Select Document Type'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: const Text('National ID'),
              onTap: () => Get.back(result: DocumentType.national_id),
            ),
            ListTile(
              title: const Text('Passport'),
              onTap: () => Get.back(result: DocumentType.passport),
            ),
            ListTile(
              title: const Text('Proof of Address'),
              onTap: () => Get.back(result: DocumentType.proof_of_address),
            ),
          ],
        ),
      ),
    );

    if (documentType == null) return;

    // Pick file
    final XFile? pickedFile = await ImagePicker().pickImage(
      source: ImageSource.gallery,
    );

    if (pickedFile == null) return;

    setState(() => isLoading = true);

    try {
      final user = _profileController.userProfile.value;
      if (user == null) {
        Get.snackbar('Error', 'User profile not loaded');
        return;
      }

      final fileName =
          '${DateTime.now().millisecondsSinceEpoch}_${pickedFile.name}';

      String publicUrl;

      if (kIsWeb) {
        // WEB: Use dummy URL for testing
        publicUrl = 'https://dummyimage.com/600x400/000/fff.jpg&text=$fileName';
        print('WEB MODE: Testing with dummy URL: $publicUrl');
      } else {
        // ANDROID: Real Supabase upload
        final supabase = Supabase.instance.client;
        final filePath = 'profile_documents/$fileName';

        await supabase.storage
            .from('attachments')
            .upload(
              filePath,
              File(pickedFile.path),
              fileOptions: FileOptions(
                contentType: 'image/jpeg',
                upsert: false,
              ),
            );

        publicUrl = supabase.storage.from('attachments').getPublicUrl(filePath);
      }

      // Map DocumentType to API category
      String apiCategory;
      switch (documentType) {
        case DocumentType.national_id:
          apiCategory = 'national_id';
          break;
        case DocumentType.passport:
          apiCategory = 'other';
          break;
        case DocumentType.proof_of_address:
          apiCategory = 'proof_of_residence';
          break;
      }

      // Create proper JSON metadata
      final metaData = json.encode({
        'document_type': documentType.toString().split('.').last,
        'uploaded_at': DateTime.now().toIso8601String(),
        'file_name': pickedFile.name,
        'original_document_type': documentType.toString().split('.').last,
        'user_id': user.id,
        'purpose': 'profile_verification',
      });

      final attachmentModel = await AttachmentHelper.uploadAttachment(
        entityType: 'User',
        entityId: user.id,
        category: apiCategory,
        filename: fileName,
        mimeType: 'image/jpeg',
        storage: 'url',
        url: publicUrl,
        meta: metaData,
      );

      if (attachmentModel != null) {
        // Refresh user profile to show new document
        await _loadProfile();

        Get.snackbar(
          'Success',
          'Document uploaded successfully',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: AppColors.successColor,
          colorText: Colors.white,
        );
      } else {
        Get.snackbar(
          'Error',
          'Failed to save attachment to database',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Upload failed: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      setState(() => isLoading = false);
    }
  }

  Future<void> deleteDocument(Document document) async {
    final confirmed = await Get.dialog<bool>(
      AlertDialog(
        title: Text(
          'Delete Document',
          style: GoogleFonts.nunito(fontWeight: FontWeight.bold),
        ),
        content: Text(
          'Are you sure you want to delete this document?',
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
              'Delete',
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
        final response = await AttachmentService.deleteAttachment(document.id);

        if (response.success) {
          await _loadProfile();
          Get.snackbar(
            'Success',
            'Document deleted successfully',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: AppColors.successColor,
            colorText: Colors.white,
          );
        } else {
          Get.snackbar(
            'Error',
            'Failed to delete document: ${response.message}',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.red,
            colorText: Colors.white,
          );
        }
      } catch (e) {
        Get.snackbar(
          'Error',
          'Failed to delete document: $e',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      } finally {
        setState(() => isLoading = false);
      }
    }
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
        // Clear all user data from cache
        await CacheUtils.clearAllUserData();

        // Navigate to login
        Get.offAllNamed('/login');
      } catch (e) {
        Get.snackbar(
          'Error',
          'Logout failed: $e',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
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
              child: Text(user.email, style: GoogleFonts.nunito()),
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
          email: user.email,
        );

        if (success) {
          await _showOTPVerificationDialog(user.email);
        }
      } catch (e) {
        Get.snackbar(
          'Error',
          'Failed to request deletion: $e',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      } finally {
        setState(() => isLoading = false);
      }
    }
  }

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
                Get.snackbar(
                  'Validation Error',
                  'Please enter a valid 6-digit OTP',
                  snackPosition: SnackPosition.BOTTOM,
                  backgroundColor: Colors.orange,
                  colorText: Colors.white,
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
                  // Clear all user data and navigate to login
                  await CacheUtils.clearAllUserData();
                  Get.offAllNamed('/login');
                }
              } catch (e) {
                Get.snackbar(
                  'Error',
                  'Failed to delete account: $e',
                  snackPosition: SnackPosition.BOTTOM,
                  backgroundColor: Colors.red,
                  colorText: Colors.white,
                );
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

  Widget _buildLoadingScreen() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(color: AppColors.primaryColor),
          const SizedBox(height: 20),
          Text(
            'Loading your profile...',
            style: GoogleFonts.nunito(fontSize: 16, color: AppColors.textColor),
          ),
        ],
      ),
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
                color: AppColors.textColor,
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
                    style: GoogleFonts.nunito(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
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
                    style: GoogleFonts.nunito(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _openDocument(Document document) async {
    // Check if URL is valid
    if (document.url.isEmpty || document.url == 'string') {
      Get.snackbar(
        'Error',
        'Document URL not available',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    try {
      final uri = Uri.parse(document.url);

      // For images, open in PhotoView
      if (document.mimeType.startsWith('image/')) {
        Get.to(
          () => Scaffold(
            appBar: AppBar(title: Text(document.fileName)),
            body: Center(
              child: CachedNetworkImage(
                imageUrl: document.url,
                placeholder: (context, url) => const CircularProgressIndicator(
                  color: AppColors.primaryColor,
                ),
                errorWidget: (context, url, error) =>
                    const Icon(Icons.error_outline, color: Colors.red),
                fit: BoxFit.contain,
              ),
            ),
          ),
        );
      } else {
        // For other files, try to open in browser
        if (await canLaunchUrl(uri)) {
          await launchUrl(uri, mode: LaunchMode.externalApplication);
        } else {
          Get.snackbar(
            'Warning',
            'Cannot open this file type',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.orange,
            colorText: Colors.white,
          );
        }
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to open document: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  Widget _buildInfoSection() {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: AppColors.borderColor, width: 1),
      ),
      margin: const EdgeInsets.only(top: 16),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Personal Information',
              style: GoogleFonts.nunito(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppColors.textColor,
              ),
            ),
            const SizedBox(height: 16),

            CustomTextField(
              controller: firstNameCtrl,
              labelText: 'First Name',
              enabled: isEditing,
              focusedBorderColor: AppColors.primaryColor,
              fillColor: isEditing ? Colors.white : Colors.grey.shade50,
            ),
            const SizedBox(height: 12),

            CustomTextField(
              controller: lastNameCtrl,
              labelText: 'Last Name',
              enabled: isEditing,
              focusedBorderColor: AppColors.primaryColor,
              fillColor: isEditing ? Colors.white : Colors.grey.shade50,
            ),
            const SizedBox(height: 12),

            CustomTextField(
              controller: phoneCtrl,
              labelText: 'Phone Number (Optional)',
              enabled: isEditing,
              keyboardType: TextInputType.phone,
              focusedBorderColor: AppColors.primaryColor,
              fillColor: isEditing ? Colors.white : Colors.grey.shade50,
            ),
            const SizedBox(height: 20),

            Row(
              children: [
                Expanded(
                  child: GeneralButton(
                    btnColor: isEditing ? Colors.grey : AppColors.primaryColor,
                    borderRadius: 8,
                    onTap: toggleEdit,
                    child: Text(
                      isEditing ? 'Cancel' : 'Edit Profile',
                      style: GoogleFonts.nunito(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                if (isEditing) ...[
                  const SizedBox(width: 12),
                  Expanded(
                    child: GeneralButton(
                      btnColor: AppColors.primaryColor,
                      borderRadius: 8,
                      onTap: saveProfile,
                      child: Text(
                        'Save Changes',
                        style: GoogleFonts.nunito(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDocumentsSection() {
    final user = _profileController.userProfile.value;
    if (user == null) return const SizedBox();

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: AppColors.borderColor, width: 1),
      ),
      margin: const EdgeInsets.only(top: 16),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Uploaded Documents',
                  style: GoogleFonts.nunito(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textColor,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${user.documents.length}',
                    style: GoogleFonts.nunito(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primaryColor,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            GeneralButton(
              btnColor: AppColors.surfaceColor,
              borderRadius: 8,
              boxBorder: Border.all(color: AppColors.primaryColor, width: 1.5),
              onTap: uploadDocument,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.upload_outlined,
                    size: 18,
                    color: AppColors.primaryColor,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Upload Document',
                    style: GoogleFonts.nunito(
                      color: AppColors.primaryColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            if (user.documents.isEmpty)
              Column(
                children: [
                  Icon(
                    Icons.folder_open_outlined,
                    size: 60,
                    color: AppColors.borderColor,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'No documents uploaded yet',
                    style: GoogleFonts.nunito(
                      fontSize: 14,
                      color: AppColors.subtextColor,
                    ),
                  ),
                ],
              )
            else
              Column(
                children: user.documents.map((document) {
                  return DocumentItem(
                    document: document,
                    onTap: () => _openDocument(document),
                  );
                }).toList(),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildAccountActions() {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: AppColors.borderColor, width: 1),
      ),
      margin: const EdgeInsets.only(top: 16, bottom: 40),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Account Actions',
              style: GoogleFonts.nunito(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppColors.textColor,
              ),
            ),
            const SizedBox(height: 16),

            // Log Out
            GeneralButton(
              btnColor: AppColors.surfaceColor,
              borderRadius: 8,
              boxBorder: Border.all(color: AppColors.borderColor, width: 1.5),
              onTap: logout,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.logout_outlined,
                    size: 18,
                    color: AppColors.textColor,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Log Out',
                    style: GoogleFonts.nunito(
                      color: AppColors.textColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),

            // Delete Account
            GeneralButton(
              btnColor: Colors.white,
              borderRadius: 8,
              boxBorder: Border.all(color: AppColors.errorColor, width: 1.5),
              onTap: _requestAccountDeletion,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.delete_outline,
                    size: 18,
                    color: AppColors.errorColor,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Delete Account',
                    style: GoogleFonts.nunito(
                      color: AppColors.errorColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
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

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          ProfileHeader(
            user: user,
            onTap: _pickProfileImage,
          ).animate().fadeIn(duration: 300.ms),
          _buildInfoSection().animate().fadeIn(duration: 400.ms, delay: 100.ms),
          _buildDocumentsSection().animate().fadeIn(
            duration: 500.ms,
            delay: 200.ms,
          ),
          _buildAccountActions().animate().fadeIn(
            duration: 600.ms,
            delay: 300.ms,
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: AppBar(
        backgroundColor: AppColors.surfaceColor,
        elevation: 0,
        title: Text(
          'Profile',
          style: GoogleFonts.nunito(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppColors.textColor,
          ),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: AppColors.textColor),
          onPressed: () => Get.back(),
        ),
        actions: [
          if (isLoading)
            Container(
              padding: const EdgeInsets.only(right: 16),
              child: const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: AppColors.primaryColor,
                ),
              ),
            ),
        ],
      ),
      body: Stack(
        children: [
          if (isLoading && _profileController.userProfile.value == null)
            _buildLoadingScreen()
          else if (hasError)
            _buildErrorScreen()
          else
            _buildProfileContent(),

          // Global loading overlay for actions
          if (isLoading && _profileController.userProfile.value != null)
            Container(
              color: Colors.black.withOpacity(0.3),
              child: const Center(
                child: CircularProgressIndicator(color: AppColors.primaryColor),
              ),
            ),
        ],
      ),
    );
  }
}
