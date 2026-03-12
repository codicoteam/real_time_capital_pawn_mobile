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
import 'package:intl/intl.dart';
import 'package:photo_view/photo_view.dart';
import 'package:real_time_pawn/core/utils/pallete.dart';
import 'package:real_time_pawn/core/utils/shared_pref_methods.dart';
import 'package:real_time_pawn/features/attached_files_mngmt/helpers/attached_files_mngmt_helper.dart';
import 'package:real_time_pawn/features/attached_files_mngmt/services/attached_files_mngmt_service.dart';
import 'package:real_time_pawn/features/loan_mngmt/controllers/loan_mngmt_controller.dart';
import 'package:real_time_pawn/features/test/curved_edges_widget.dart';
import 'package:real_time_pawn/models/profile_mngmt_model.dart';
import 'package:real_time_pawn/widgets/custom_button/general_button.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
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
  final ScrollController _scrollController = ScrollController();

  bool isEditing = false;
  bool isLoading = false;
  bool hasError = false;
  String errorMessage = '';
  final ImagePicker _imagePicker = ImagePicker();

  // Add this to track when profile is loaded

  // Controllers for fields
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
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _loadProfile() async {
    try {
      // 1. Fetch user profile
      final success = await ProfileMngmtHelper.fetchUserProfile();

      if (success && _profileController.userProfile.value != null) {
        _updateControllers();

        // 2. Fetch loans if controller exists
        if (Get.isRegistered<LoanController>()) {
          final loanController = Get.find<LoanController>();
          await loanController.fetchCustomerLoans();
        }

        // 3. ALSO FETCH ATTACHMENTS FROM ATTACHMENTS API
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
    _scrollController.dispose();
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
        publicUrl = 'https://dummyimage.com/600x400/000/fff.jpg&text=$fileName';
      } else {
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
        await CacheUtils.clearAllUserData();
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

  double _calculateCompletion(UserProfile user) {
    int totalFields = 0;
    int completedFields = 0;

    totalFields++;
    if (user.phone != null && user.phone!.isNotEmpty) completedFields++;

    totalFields++;
    if (user.isEmailVerified) completedFields++;

    totalFields++;
    if (user.documents.isNotEmpty) completedFields++;

    return completedFields / totalFields;
  }

  int _getDocumentsCount(UserProfile user) {
    return user.documents.length;
  }

  String _getMemberSince(UserProfile user) {
    return 'Since ${DateFormat('yyyy').format(user.createdAt)}';
  }

  List<String> _getMissingFieldsList(UserProfile user) {
    List<String> missing = [];

    if (user.phone == null || user.phone!.isEmpty) {
      missing.add('Phone Number');
    }

    if (!user.isEmailVerified) {
      missing.add('Email Verification');
    }

    if (user.documents.isEmpty) {
      missing.add('Documents');
    }

    return missing;
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

  Widget _buildDocumentItem(Document document) {
    IconData icon;
    Color iconColor;
    String fileTypeLabel;

    if (document.mimeType.startsWith('image/')) {
      icon = Icons.image_outlined;
      iconColor = Colors.blue;
      fileTypeLabel = 'IMG';
    } else if (document.mimeType == 'application/pdf') {
      icon = Icons.picture_as_pdf_outlined;
      iconColor = Colors.red;
      fileTypeLabel = 'PDF';
    } else {
      icon = Icons.insert_drive_file_outlined;
      iconColor = AppColors.primaryColor;
      fileTypeLabel = 'DOC';
    }

    return GestureDetector(
      onTap: () => _openDocument(document),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFE5E7EB), width: 1),
        ),
        child: Row(
          children: [
            Icon(icon, size: 24, color: iconColor),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    document.typeString,
                    style: GoogleFonts.nunito(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF1F2933),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    document.fileName,
                    style: GoogleFonts.nunito(
                      fontSize: 13,
                      color: const Color(0xFF6B7280),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: iconColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                fileTypeLabel,
                style: GoogleFonts.nunito(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: iconColor,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsRow(UserProfile user) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 16),
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(color: const Color(0xFFE5E7EB), width: 1),
          bottom: BorderSide(color: const Color(0xFFE5E7EB), width: 1),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatItem('${_getDocumentsCount(user)}', 'Documents'),
          _buildStatItem(_getMemberSince(user), ''),
        ],
      ),
    );
  }

  Widget _buildStatItem(String value, String label) {
    return Column(
      children: [
        Text(
          value,
          style: GoogleFonts.nunito(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: const Color(0xFF1F2933),
          ),
        ),
        if (label.isNotEmpty) ...[
          const SizedBox(height: 2),
          Text(
            label,
            style: GoogleFonts.nunito(
              fontSize: 12,
              color: const Color(0xFF6B7280),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildProfileCompletionSection(UserProfile user) {
    double completionPercentage = _calculateCompletion(user) * 100;
    List<String> missingFields = _getMissingFieldsList(user);

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Profile Completion',
                style: GoogleFonts.nunito(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF1F2933),
                ),
              ),
              Text(
                '${completionPercentage.toInt()}% Complete',
                style: GoogleFonts.nunito(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: RealTimeColors.primaryGreen,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: _calculateCompletion(user),
              backgroundColor: const Color(0xFFC6F6D5),
              valueColor: const AlwaysStoppedAnimation<Color>(
                RealTimeColors.primaryGreen,
              ),
              minHeight: 6,
            ),
          ),
          const SizedBox(height: 8),
          if (missingFields.isNotEmpty)
            Text(
              'Complete missing information for faster applications',
              style: GoogleFonts.nunito(
                fontSize: 13,
                color: const Color(0xFF6B7280),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildInfoSection() {
    final user = _profileController.userProfile.value;
    if (user == null) return const SizedBox();

    if (isEditing) {
      return Container(
        margin: const EdgeInsets.only(top: 8),
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
                'Personal Information',
                style: GoogleFonts.nunito(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF1F2933),
                ),
              ),
              const SizedBox(height: 20),
              Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'First Name',
                              style: GoogleFonts.nunito(
                                fontSize: 13,
                                color: const Color(0xFF6B7280),
                              ),
                            ),
                            const SizedBox(height: 4),
                            TextField(
                              controller: firstNameCtrl,
                              decoration: InputDecoration(
                                hintText: 'Enter first name',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide: BorderSide(
                                    color: const Color(0xFFE5E7EB),
                                  ),
                                ),
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 12,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Last Name',
                              style: GoogleFonts.nunito(
                                fontSize: 13,
                                color: const Color(0xFF6B7280),
                              ),
                            ),
                            const SizedBox(height: 4),
                            TextField(
                              controller: lastNameCtrl,
                              decoration: InputDecoration(
                                hintText: 'Enter last name',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide: BorderSide(
                                    color: const Color(0xFFE5E7EB),
                                  ),
                                ),
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 12,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Phone',
                        style: GoogleFonts.nunito(
                          fontSize: 13,
                          color: const Color(0xFF6B7280),
                        ),
                      ),
                      const SizedBox(height: 4),
                      TextField(
                        controller: phoneCtrl,
                        keyboardType: TextInputType.phone,
                        decoration: InputDecoration(
                          hintText: 'Enter phone number',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(
                              color: const Color(0xFFE5E7EB),
                            ),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: toggleEdit,
                      style: TextButton.styleFrom(
                        foregroundColor: const Color(0xFF6B7280),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                          side: BorderSide(color: const Color(0xFFE5E7EB)),
                        ),
                      ),
                      child: Text(
                        'Cancel',
                        style: GoogleFonts.nunito(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: saveProfile,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: RealTimeColors.primaryGreen,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: Text(
                        'Save Changes',
                        style: GoogleFonts.nunito(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
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

    return Container(
      margin: const EdgeInsets.only(top: 8),
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
              'Personal Information',
              style: GoogleFonts.nunito(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF1F2933),
              ),
            ),
            const SizedBox(height: 16),
            _buildInfoRow('First Name:', user.firstName),
            _buildInfoRow('Last Name:', user.lastName),
            _buildInfoRow('Phone:', user.phone ?? 'Not provided'),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: toggleEdit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: RealTimeColors.primaryGreen,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                    side: BorderSide(color: RealTimeColors.primaryGreen),
                  ),
                ),
                child: Text(
                  'Edit Profile',
                  style: GoogleFonts.nunito(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
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
            width: 90,
            child: Text(
              label,
              style: GoogleFonts.nunito(
                fontSize: 14,
                color: const Color(0xFF6B7280),
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: GoogleFonts.nunito(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: const Color(0xFF1F2933),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDocumentsSection() {
    final user = _profileController.userProfile.value;
    if (user == null) return const SizedBox();

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
              'Uploaded Documents',
              style: GoogleFonts.nunito(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF1F2933),
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: uploadDocument,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: RealTimeColors.primaryGreen,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                    side: BorderSide(color: RealTimeColors.primaryGreen),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.upload_outlined,
                      size: 18,
                      color: RealTimeColors.primaryGreen,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Upload Document',
                      style: GoogleFonts.nunito(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: RealTimeColors.primaryGreen,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            if (user.documents.isEmpty)
              const Center(
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 24),
                  child: Text(
                    'No documents uploaded yet',
                    style: TextStyle(fontSize: 14, color: Color(0xFF6B7280)),
                  ),
                ),
              )
            else
              Column(
                children: user.documents.map((document) {
                  return _buildDocumentItem(document);
                }).toList(),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildAccountActions() {
    return Container(
      margin: const EdgeInsets.only(top: 12, bottom: 24),
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
                color: const Color(0xFF1F2933),
              ),
            ),
            const SizedBox(height: 16),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: const Color(0xFFF3F4F6),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.logout_outlined,
                  color: Color(0xFF6B7280),
                  size: 20,
                ),
              ),
              title: Text(
                'Log Out',
                style: GoogleFonts.nunito(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  color: const Color(0xFF1F2933),
                ),
              ),
              trailing: const Icon(
                Icons.chevron_right,
                color: Color(0xFF9CA3AF),
              ),
              onTap: logout,
            ),
            const Divider(height: 16),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: const Color(0xFFF3F4F6),
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
              trailing: const Icon(
                Icons.chevron_right,
                color: Color(0xFF9CA3AF),
              ),
              onTap: _requestAccountDeletion,
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
                // Header - No animation needed
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
                                onPressed: () => Get.back(),
                              ),
                            ),
                            const Spacer(),
                            Container(width: 40, height: 40),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),

                // Profile picture with fade and scale animation
                Transform.translate(
                  offset: const Offset(0, -50),
                  child: Column(
                    children: [
                      GestureDetector(
                            onTap: _pickProfileImage,
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
                                    spreadRadius: 0,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: CircleAvatar(
                                radius: 50,
                                backgroundColor: AppColors.primaryColor
                                    .withOpacity(0.1),
                                backgroundImage: user.profilePicUrl != null
                                    ? CachedNetworkImageProvider(
                                        user.profilePicUrl!,
                                      )
                                    : null,
                                child: user.profilePicUrl == null
                                    ? Icon(
                                        Icons.person,
                                        size: 50,
                                        color: AppColors.primaryColor,
                                      )
                                    : null,
                              ),
                            ),
                          )
                          .animate()
                          .fadeIn(duration: 400.ms)
                          .scale(
                            delay: 200.ms,
                            duration: 400.ms,
                            begin: const Offset(0.8, 0.8),
                            end: const Offset(1, 1),
                          ),

                      const SizedBox(height: 12),

                      // Name and email with slide animation
                      Column(
                            children: [
                              Text(
                                user.fullNameDisplay,
                                style: GoogleFonts.nunito(
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                  color: const Color(0xFF1F2933),
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                user.email,
                                style: GoogleFonts.nunito(
                                  fontSize: 14,
                                  color: const Color(0xFF6B7280),
                                ),
                              ),
                            ],
                          )
                          .animate()
                          .fadeIn(delay: 300.ms)
                          .slideY(
                            begin: 0.2,
                            end: 0,
                            delay: 300.ms,
                            duration: 500.ms,
                          ),
                    ],
                  ),
                ),

                // Content sections with staggered animations
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    children: [
                      // Stats row
                      _buildStatsRow(user)
                          .animate()
                          .fadeIn(delay: 400.ms, duration: 500.ms)
                          .slideX(
                            begin: -0.1,
                            end: 0,
                            delay: 400.ms,
                            duration: 500.ms,
                          ),

                      // Profile completion
                      _buildProfileCompletionSection(user)
                          .animate()
                          .fadeIn(delay: 500.ms, duration: 500.ms)
                          .slideX(
                            begin: 0.1,
                            end: 0,
                            delay: 500.ms,
                            duration: 500.ms,
                          ),

                      // Personal Information
                      _buildInfoSection()
                          .animate()
                          .fadeIn(delay: 600.ms, duration: 500.ms)
                          .slideY(
                            begin: 0.2,
                            end: 0,
                            delay: 600.ms,
                            duration: 500.ms,
                          ),

                      const SizedBox(height: 12),

                      // Uploaded Documents
                      _buildDocumentsSection()
                          .animate()
                          .fadeIn(delay: 700.ms, duration: 500.ms)
                          .slideY(
                            begin: 0.2,
                            end: 0,
                            delay: 700.ms,
                            duration: 500.ms,
                          ),

                      const SizedBox(height: 12),

                      // Account Actions
                      _buildAccountActions()
                          .animate()
                          .fadeIn(delay: 800.ms, duration: 500.ms)
                          .slideY(
                            begin: 0.2,
                            end: 0,
                            delay: 800.ms,
                            duration: 500.ms,
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      body: Obx(() {
        final user = _profileController.userProfile.value;
        final isLoading = _profileController.isLoading.value;

        if (isLoading && user == null) {
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
