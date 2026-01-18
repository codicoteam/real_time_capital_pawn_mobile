import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:photo_view/photo_view.dart';
import 'package:real_time_pawn/core/utils/pallete.dart';
import 'package:real_time_pawn/widgets/custom_button/general_button.dart';
import 'package:real_time_pawn/widgets/dialogs/conformation_dialog.dart';
import 'package:real_time_pawn/widgets/text_fields/custom_text_field.dart';

import '../../../models/profile_models.dart';
import '../../../widgets/profile_widgets.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  /// MOCK USER
  UserProfile user = UserProfile(
    id: '1',
    email: 'ipahchirume@gmail.com',
    phone: '+263780197542',
    roles: [UserRole.customer],
    firstName: 'Ipanoshi',
    lastName: 'Chirume',
    fullName: 'Ipanoshi Chirume',
    status: UserStatus.active,
    nationalIdNumber: '123456789X',
    dateOfBirth: DateTime(1990, 5, 15),
    address: '123 Main Street, Harare',
    location: 'Harare, Zimbabwe',
    termsAcceptedAt: DateTime.now(),
    nationalIdImageUrl: null,
    profilePicUrl: null,
    isEmailVerified: true,
    createdAt: DateTime.parse('2026-01-14T13:03:04.724Z'),
    documents: [
      Document(
        id: '1',
        type: DocumentType.national_id,
        url: 'https://example.com/national_id.pdf',
        fileName: 'National_ID.pdf',
        mimeType: 'application/pdf',
        uploadedAt: DateTime.now().subtract(const Duration(days: 30)),
      ),
      Document(
        id: '2',
        type: DocumentType.passport,
        url: 'https://example.com/passport.pdf',
        fileName: 'Passport.pdf',
        mimeType: 'application/pdf',
        uploadedAt: DateTime.now().subtract(const Duration(days: 15)),
      ),
    ],
  );

  bool isLoading = false;
  bool isEditing = false;
  final _formKey = GlobalKey<FormState>();
  final ImagePicker _imagePicker = ImagePicker(); // Moved here

  // Controllers
  late TextEditingController firstNameCtrl;
  late TextEditingController lastNameCtrl;
  late TextEditingController phoneCtrl;
  late TextEditingController nationalIdCtrl;
  late TextEditingController dateOfBirthCtrl;
  late TextEditingController addressCtrl;
  late TextEditingController locationCtrl;

  @override
  void initState() {
    super.initState();
    _initializeControllers();
  }

  void _initializeControllers() {
    firstNameCtrl = TextEditingController(text: user.firstName);
    lastNameCtrl = TextEditingController(text: user.lastName);
    phoneCtrl = TextEditingController(text: user.phone ?? '');
    nationalIdCtrl = TextEditingController(text: user.nationalIdNumber ?? '');
    dateOfBirthCtrl = TextEditingController(
      text: user.dateOfBirth != null
          ? DateFormat('dd-MM-yyyy').format(user.dateOfBirth!)
          : '',
    );
    addressCtrl = TextEditingController(text: user.address ?? '');
    locationCtrl = TextEditingController(text: user.location ?? '');
  }

  @override
  void dispose() {
    firstNameCtrl.dispose();
    lastNameCtrl.dispose();
    phoneCtrl.dispose();
    nationalIdCtrl.dispose();
    dateOfBirthCtrl.dispose();
    addressCtrl.dispose();
    locationCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickProfileImage() async {
    // Show options: Camera or Gallery
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
                onTap: () {
                  Get.back(result: 'camera');
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Choose from Gallery'),
                onTap: () {
                  Get.back(result: 'gallery');
                },
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
        maxWidth: 800,
        maxHeight: 800,
      );

      if (pickedFile != null) {
        // Show preview and confirm
        final confirmed = await _showImagePreview(pickedFile);

        if (confirmed == true) {
          // Upload to server
          await _uploadImageToServer(File(pickedFile.path));
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
              child: PhotoView(
                imageProvider: FileImage(File(file.path)),
                minScale: PhotoViewComputedScale.contained * 0.8,
                maxScale: PhotoViewComputedScale.covered * 2,
              ),
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

  Future<void> _uploadImageToServer(File imageFile) async {
    try {
      // TODO: Implement actual upload to your backend
      // Example using Supabase (you already have supabase_flutter)
      // If you're using another backend, adjust this part

      // 1. Upload to storage
      // final storageResponse = await supabase.storage
      //     .from('profile-pictures')
      //     .upload('${user.id}/${DateTime.now().millisecondsSinceEpoch}.jpg', imageFile);

      // 2. Get public URL
      // final publicUrl = supabase.storage
      //     .from('profile-pictures')
      //     .getPublicUrl(storageResponse.path);

      // 3. Update user profile with new URL
      // await supabase
      //     .from('users')
      //     .update({'profile_pic_url': publicUrl})
      //     .eq('id', user.id);

      // 4. Update local state (for demo, use a mock URL)
      setState(() {
        user.profilePicUrl =
            'https://example.com/profile.jpg'; // Replace with actual URL
      });

      Get.snackbar(
        'Success',
        'Profile picture updated',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColors.successColor,
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

  /// =======================
  /// ACTIONS
  /// =======================

  void toggleEdit() {
    setState(() {
      if (isEditing) {
        _resetControllers();
      }
      isEditing = !isEditing;
    });
  }

  void _resetControllers() {
    firstNameCtrl.text = user.firstName;
    lastNameCtrl.text = user.lastName;
    phoneCtrl.text = user.phone ?? '';
    nationalIdCtrl.text = user.nationalIdNumber ?? '';
    dateOfBirthCtrl.text = user.dateOfBirth != null
        ? DateFormat('dd-MM-yyyy').format(user.dateOfBirth!)
        : '';
    addressCtrl.text = user.address ?? '';
    locationCtrl.text = user.location ?? '';
  }

  Future<void> saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => isLoading = true);
    await Future.delayed(const Duration(seconds: 1));

    setState(() {
      user.firstName = firstNameCtrl.text.trim();
      user.lastName = lastNameCtrl.text.trim();
      user.phone = phoneCtrl.text.trim().isNotEmpty
          ? phoneCtrl.text.trim()
          : null;
      user.nationalIdNumber = nationalIdCtrl.text.trim().isNotEmpty
          ? nationalIdCtrl.text.trim()
          : null;

      if (dateOfBirthCtrl.text.isNotEmpty) {
        try {
          user.dateOfBirth = DateFormat(
            'dd-MM-yyyy',
          ).parse(dateOfBirthCtrl.text);
        } catch (e) {
          user.dateOfBirth = null;
        }
      } else {
        user.dateOfBirth = null;
      }

      user.address = addressCtrl.text.trim().isNotEmpty
          ? addressCtrl.text.trim()
          : null;
      user.location = locationCtrl.text.trim().isNotEmpty
          ? locationCtrl.text.trim()
          : null;

      isEditing = false;
      isLoading = false;
    });

    Get.snackbar(
      'Success',
      'Profile updated successfully',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: AppColors.successColor,
      colorText: Colors.white,
      duration: const Duration(seconds: 3),
    );
  }

  Future<void> uploadDocument() async {
    setState(() => isLoading = true);
    await Future.delayed(const Duration(seconds: 1));

    setState(() {
      user.documents.add(
        Document(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          type: DocumentType.proof_of_address,
          url: 'https://example.com/utility_bill.pdf',
          fileName: 'Utility_Bill.pdf',
          mimeType: 'application/pdf',
          uploadedAt: DateTime.now(),
          notes: 'Electricity bill for address verification',
        ),
      );
      isLoading = false;
    });

    Get.snackbar(
      'Success',
      'Document uploaded successfully',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: AppColors.successColor,
      colorText: Colors.white,
    );
  }

  Future<void> deleteDocument(String id) async {
    final confirmed = await Get.dialog<bool>(
      ConformationDialog(
        itemName: 'this document',
        icon: Icons.delete_outline,
        onConfirm: () => Get.back(result: true),
      ),
    );

    if (confirmed == true) {
      setState(() {
        user.documents.removeWhere((d) => d.id == id);
      });

      Get.snackbar(
        'Deleted',
        'Document removed successfully',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColors.primaryColor,
        colorText: Colors.white,
      );
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
      await Future.delayed(const Duration(seconds: 1));
      setState(() => isLoading = false);
      Get.offAllNamed('/login');
    }
  }

  Future<void> selectDateOfBirth(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate:
          user.dateOfBirth ??
          DateTime.now().subtract(const Duration(days: 365 * 25)),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: AppColors.primaryColor,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        dateOfBirthCtrl.text = DateFormat('dd-MM-yyyy').format(picked);
      });
    }
  }

  /// =======================
  /// UI BUILDERS
  /// =======================

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
        child: Form(
          key: _formKey,
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
              const SizedBox(height: 12),

              Text(
                'KYC Information (Optional)',
                style: GoogleFonts.nunito(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textColor,
                ),
              ),
              const SizedBox(height: 12),

              CustomTextField(
                controller: nationalIdCtrl,
                labelText: 'National ID Number',
                enabled: isEditing,
                focusedBorderColor: AppColors.primaryColor,
                fillColor: isEditing ? Colors.white : Colors.grey.shade50,
              ),
              const SizedBox(height: 12),

              GestureDetector(
                onTap: isEditing ? () => selectDateOfBirth(context) : null,
                child: AbsorbPointer(
                  child: CustomTextField(
                    controller: dateOfBirthCtrl,
                    labelText: 'Date of Birth',
                    enabled: isEditing,
                    focusedBorderColor: AppColors.primaryColor,
                    fillColor: isEditing ? Colors.white : Colors.grey.shade50,
                    prefixIcon: const Icon(Icons.calendar_today_outlined),
                  ),
                ),
              ),
              const SizedBox(height: 12),

              CustomTextField(
                controller: addressCtrl,
                labelText: 'Address',
                enabled: isEditing,
                focusedBorderColor: AppColors.primaryColor,
                fillColor: isEditing ? Colors.white : Colors.grey.shade50,
              ),
              const SizedBox(height: 12),

              CustomTextField(
                controller: locationCtrl,
                labelText: 'Location/City',
                enabled: isEditing,
                focusedBorderColor: AppColors.primaryColor,
                fillColor: isEditing ? Colors.white : Colors.grey.shade50,
              ),
              const SizedBox(height: 20),

              Row(
                children: [
                  Expanded(
                    child: GeneralButton(
                      btnColor: isEditing
                          ? Colors.grey
                          : AppColors.primaryColor,
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
      ),
    );
  }

  Widget _buildDocumentsSection() {
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
            const SizedBox(height: 12),

            if (!user.hasCompletedBasicKyc)
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.warningColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: AppColors.warningColor.withOpacity(0.2),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.info_outline,
                      size: 20,
                      color: AppColors.warningColor,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Complete your KYC by adding National ID and Date of Birth for faster loan processing.',
                        style: GoogleFonts.nunito(
                          fontSize: 12,
                          color: AppColors.textColor,
                        ),
                      ),
                    ),
                  ],
                ),
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
                    onDelete: () => deleteDocument(document.id),
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
          ],
        ),
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
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: AppColors.textColor,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Profile',
          style: GoogleFonts.nunito(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppColors.textColor,
          ),
        ),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                ProfileHeader(
                  user: user,
                  onTap: _pickProfileImage, // Added onTap callback
                ).animate().fadeIn(duration: 300.ms),
                _buildInfoSection().animate().fadeIn(
                  duration: 400.ms,
                  delay: 100.ms,
                ),
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
          ),
          if (isLoading)
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
