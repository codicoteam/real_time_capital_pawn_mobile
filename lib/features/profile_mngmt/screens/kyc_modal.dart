// lib/features/profile_mngmt/widgets/kyc_modal.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart' show GoogleFonts;
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:real_time_pawn/core/utils/logs.dart';
import 'package:real_time_pawn/core/utils/pallete.dart';
import 'package:real_time_pawn/core/utils/shared_pref_methods.dart';
import 'package:real_time_pawn/features/profile_mngmt/controllers/profile_mngmt_controller.dart';
import 'package:real_time_pawn/models/profile_mngmt_model.dart';

class KYCModal extends StatefulWidget {
  final UserProfile? userProfile;
  final Function(UserProfile updatedProfile) onKYCUpdated;

  const KYCModal({super.key, this.userProfile, required this.onKYCUpdated});

  @override
  State<KYCModal> createState() => _KYCModalState();
}

class _KYCModalState extends State<KYCModal> {
  final _formKey = GlobalKey<FormState>();
  final ProfileController _profileController = Get.find<ProfileController>();
  final ImagePicker _imagePicker = ImagePicker();

  bool _isUploading = false;
  bool _isSubmitting = false;

  // Controllers
  final _nationalIdController = TextEditingController();
  final _passportNumberController =
      TextEditingController(); // Added for passport number
  final _dateOfBirthController = TextEditingController();
  final _addressController = TextEditingController();
  final _locationController = TextEditingController();
  final _genderController = TextEditingController();
  final _maritalStatusController = TextEditingController();
  final _alternativePhoneController = TextEditingController();

  // Employment controllers
  final _isEmployed = false.obs;
  final _employerNameController = TextEditingController();
  final _jobTitleController = TextEditingController();
  final _durationController = TextEditingController();
  final _workLocationController = TextEditingController();
  final _workContactsController = TextEditingController();

  // Document URLs
  String? _nationalIdImageUrl;
  String? _passportImageUrl;
  String? _proofOfAddressUrl;

  // Document selection tracking
  final RxBool _hasNationalId = false.obs;
  final RxBool _hasPassport = false.obs;

  DateTime? _selectedDateOfBirth;
  DateTime? _passportExpiryDate;
  DateTime? _drivingLicenseExpiryDate;
  DateTime? _nationalIdExpiryDate;

  final List<String> _genders = [
    'Male',
    'Female',
    'Other',
    'Prefer not to say',
  ];
  final List<String> _maritalStatuses = [
    'Single',
    'Married',
    'Divorced',
    'Widowed',
    'Separated',
  ];

  @override
  void initState() {
    super.initState();
    _loadExistingData();
  }

  void _loadExistingData() {
    final user = widget.userProfile;
    if (user != null) {
      _nationalIdController.text = user.nationalIdNumber ?? '';
      _addressController.text = user.address ?? '';
      _locationController.text = user.location ?? '';
      _genderController.text = user.gender ?? '';
      _maritalStatusController.text = user.maritalStatus ?? '';
      _alternativePhoneController.text = user.alternativePhone ?? '';

      // Check if user has existing documents
      _hasNationalId.value =
          (user.nationalIdNumber != null &&
              user.nationalIdNumber!.isNotEmpty) ||
          (user.nationalIdImageUrl != null &&
              user.nationalIdImageUrl!.isNotEmpty);
      _hasPassport.value =
          (user.passportImageUrl != null && user.passportImageUrl!.isNotEmpty);

      if (user.dateOfBirth != null) {
        _selectedDateOfBirth = user.dateOfBirth;
        _dateOfBirthController.text = DateFormat(
          'yyyy-MM-dd',
        ).format(user.dateOfBirth!);
      }

      _nationalIdImageUrl = user.nationalIdImageUrl;
      _passportImageUrl = user.passportImageUrl;
      _proofOfAddressUrl = user.proofOfAddressUrl;

      _passportExpiryDate = user.passportExpiryDate;
      _drivingLicenseExpiryDate = user.drivingLicenseExpiryDate;
      _nationalIdExpiryDate = user.nationalIdExpiryDate;

      _isEmployed.value = user.isEmployed ?? false;
      if (user.employmentDetails != null) {
        _employerNameController.text =
            user.employmentDetails!.employerName ?? '';
        _jobTitleController.text = user.employmentDetails!.jobTitle ?? '';
        _durationController.text = user.employmentDetails!.duration ?? '';
        _workLocationController.text = user.employmentDetails!.location ?? '';
        _workContactsController.text = user.employmentDetails!.contacts ?? '';
      }
    }
  }

  String? _validateDocumentSelection() {
    if (!_hasNationalId.value && !_hasPassport.value) {
      return 'Please provide either National ID or Passport details';
    }
    return null;
  }

  Future<void> _selectDate(
    BuildContext context,
    TextEditingController controller,
    Function(DateTime) onDateSelected,
  ) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.primaryColor,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      onDateSelected(picked);
      controller.text = DateFormat('yyyy-MM-dd').format(picked);
    }
  }

  Future<void> _selectExpiryDate(
    BuildContext context,
    TextEditingController controller,
    Function(DateTime) onDateSelected,
  ) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365 * 20)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.primaryColor,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      onDateSelected(picked);
      controller.text = DateFormat('yyyy-MM-dd').format(picked);
    }
  }

  Future<String?> _uploadDocument(File imageFile, String documentType) async {
    try {
      final userId = await CacheUtils.getUserId();
      if (userId == null || userId.isEmpty) {
        throw Exception('User not logged in');
      }

      final fileExtension = imageFile.path.split('.').last;
      final fileName =
          '${DateTime.now().millisecondsSinceEpoch}_$documentType.$fileExtension';
      final filePath = '$userId/kyc_documents/$fileName';

      await Supabase.instance.client.storage
          .from('topics')
          .upload(filePath, imageFile);

      return Supabase.instance.client.storage
          .from('topics')
          .getPublicUrl(filePath);
    } catch (e) {
      DevLogs.logError('Failed to upload $documentType: $e');
      return null;
    }
  }

  Future<void> _pickDocumentImage(
    String documentType,
    Function(String?) onUrlSet,
  ) async {
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
                leading: const Icon(
                  Icons.camera_alt,
                  color: AppColors.primaryColor,
                ),
                title: const Text('Take Photo'),
                onTap: () => Get.back(result: 'camera'),
              ),
              ListTile(
                leading: const Icon(
                  Icons.photo_library,
                  color: AppColors.primaryColor,
                ),
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

    setState(() => _isUploading = true);

    try {
      final XFile? pickedFile = await _imagePicker.pickImage(
        source: result == 'camera' ? ImageSource.camera : ImageSource.gallery,
        imageQuality: 85,
      );

      if (pickedFile != null) {
        final url = await _uploadDocument(File(pickedFile.path), documentType);
        if (url != null) {
          onUrlSet(url);

          // Update the document selection status
          if (documentType == 'national_id') {
            _hasNationalId.value = true;
          } else if (documentType == 'passport') {
            _hasPassport.value = true;
          }

          Get.snackbar(
            'Success',
            '$documentType uploaded successfully',
            backgroundColor: Colors.green,
            colorText: Colors.white,
            snackPosition: SnackPosition.BOTTOM,
          );
        }
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to upload: $e',
        backgroundColor: AppColors.errorColor,
        colorText: Colors.white,
      );
    } finally {
      setState(() => _isUploading = false);
    }
  }

  Future<void> _submitKYC() async {
    // First validate the form
    if (!_formKey.currentState!.validate()) return;

    // Then validate document selection (at least one of National ID or Passport)
    final documentValidationError = _validateDocumentSelection();
    if (documentValidationError != null) {
      Get.snackbar(
        'Validation Error',
        documentValidationError,
        backgroundColor: AppColors.errorColor,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final response = await _profileController.updateKycDetails(
        nationalIdNumber: _hasNationalId.value
            ? _nationalIdController.text.trim()
            : null,
        dateOfBirth: _selectedDateOfBirth,
        address: _addressController.text.trim(),
        location: _locationController.text.trim(),
        gender: _genderController.text.trim(),
        maritalStatus: _maritalStatusController.text.trim(),
        alternativePhone: _alternativePhoneController.text.trim(),
        nationalIdImageUrl: _hasNationalId.value ? _nationalIdImageUrl : null,
        passportImageUrl: _hasPassport.value ? _passportImageUrl : null,
        proofOfAddressUrl: _proofOfAddressUrl,
        passportExpiryDate: _hasPassport.value ? _passportExpiryDate : null,
        drivingLicenseExpiryDate: _drivingLicenseExpiryDate,
        nationalIdExpiryDate: _hasNationalId.value
            ? _nationalIdExpiryDate
            : null,
        isEmployed: _isEmployed.value,
        employmentDetails: _isEmployed.value
            ? {
                'employer_name': _employerNameController.text.trim(),
                'job_title': _jobTitleController.text.trim(),
                'duration': _durationController.text.trim(),
                'location': _workLocationController.text.trim(),
                'contacts': _workContactsController.text.trim(),
              }
            : null,
      );

      if (response.success && response.data != null) {
        widget.onKYCUpdated(response.data!);
        Get.back();
        Get.snackbar(
          'Success',
          'KYC details updated successfully',
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
      } else {
        Get.snackbar(
          'Error',
          response.message ?? 'Failed to update KYC',
          backgroundColor: AppColors.errorColor,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to update KYC: $e',
        backgroundColor: AppColors.errorColor,
        colorText: Colors.white,
      );
    } finally {
      setState(() => _isSubmitting = false);
    }
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
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'KYC Verification',
                    style: GoogleFonts.nunito(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  TextButton(
                    onPressed: () => Get.back(),
                    child: Text(
                      'Cancel',
                      style: GoogleFonts.nunito(color: Colors.grey[600]),
                    ),
                  ),
                ],
              ),
            ),
            const Divider(height: 24),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      // Document Selection Info Card
                      Container(
                        padding: const EdgeInsets.all(12),
                        margin: const EdgeInsets.only(bottom: 16),
                        decoration: BoxDecoration(
                          color: Colors.blue[50],
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.blue[200]!),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.info_outline,
                              color: Colors.blue[700],
                              size: 20,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                'Please provide either National ID OR Passport details. Both are not mandatory.',
                                style: GoogleFonts.nunito(
                                  fontSize: 12,
                                  color: Colors.blue[700],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      // National ID Section with Checkbox
                      Card(
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: BorderSide(
                            color: _hasNationalId.value
                                ? AppColors.primaryColor
                                : Colors.grey[300]!,
                          ),
                        ),
                        child: Column(
                          children: [
                            Obx(
                              () => CheckboxListTile(
                                title: Text(
                                  'Use National ID',
                                  style: GoogleFonts.nunito(
                                    fontWeight: FontWeight.bold,
                                    color: _hasNationalId.value
                                        ? AppColors.primaryColor
                                        : Colors.black87,
                                  ),
                                ),
                                value: _hasNationalId.value,
                                activeColor: AppColors.primaryColor,
                                onChanged: (val) {
                                  setState(() {
                                    _hasNationalId.value = val ?? false;
                                    if (!_hasNationalId.value) {
                                      _nationalIdController.clear();
                                      _nationalIdImageUrl = null;
                                      _nationalIdExpiryDate = null;
                                    }
                                  });
                                },
                              ),
                            ),
                            if (_hasNationalId.value) ...[
                              const Divider(height: 1),
                              Padding(
                                padding: const EdgeInsets.all(16),
                                child: Column(
                                  children: [
                                    _buildTextField(
                                      controller: _nationalIdController,
                                      label: 'National ID Number',
                                      icon: Icons.credit_card,
                                      validator: (v) =>
                                          _hasNationalId.value &&
                                              (v == null || v.isEmpty)
                                          ? 'National ID number is required'
                                          : null,
                                    ),
                                    const SizedBox(height: 12),
                                    _buildDocumentUploadCard(
                                      title: 'National ID Image',
                                      imageUrl: _nationalIdImageUrl,
                                      onUpload: () => _pickDocumentImage(
                                        'national_id',
                                        (url) => _nationalIdImageUrl = url,
                                      ),
                                    ),
                                    const SizedBox(height: 12),
                                    _buildDateField(
                                      controller: TextEditingController(
                                        text: _nationalIdExpiryDate != null
                                            ? DateFormat(
                                                'yyyy-MM-dd',
                                              ).format(_nationalIdExpiryDate!)
                                            : null,
                                      ),
                                      label: 'National ID Expiry Date',
                                      icon: Icons.event,
                                      onTap: () => _selectExpiryDate(
                                        context,
                                        TextEditingController(),
                                        (date) => _nationalIdExpiryDate = date,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),

                      const SizedBox(height: 16),

                      // Passport Section with Checkbox
                      Card(
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: BorderSide(
                            color: _hasPassport.value
                                ? AppColors.primaryColor
                                : Colors.grey[300]!,
                          ),
                        ),
                        child: Column(
                          children: [
                            Obx(
                              () => CheckboxListTile(
                                title: Text(
                                  'Use Passport',
                                  style: GoogleFonts.nunito(
                                    fontWeight: FontWeight.bold,
                                    color: _hasPassport.value
                                        ? AppColors.primaryColor
                                        : Colors.black87,
                                  ),
                                ),
                                value: _hasPassport.value,
                                activeColor: AppColors.primaryColor,
                                onChanged: (val) {
                                  setState(() {
                                    _hasPassport.value = val ?? false;
                                    if (!_hasPassport.value) {
                                      _passportImageUrl = null;
                                      _passportExpiryDate = null;
                                    }
                                  });
                                },
                              ),
                            ),
                            if (_hasPassport.value) ...[
                              const Divider(height: 1),
                              Padding(
                                padding: const EdgeInsets.all(16),
                                child: Column(
                                  children: [
                                    _buildDocumentUploadCard(
                                      title: 'Passport Image',
                                      imageUrl: _passportImageUrl,
                                      onUpload: () => _pickDocumentImage(
                                        'passport',
                                        (url) => _passportImageUrl = url,
                                      ),
                                    ),
                                    const SizedBox(height: 12),
                                    _buildDateField(
                                      controller: TextEditingController(
                                        text: _passportExpiryDate != null
                                            ? DateFormat(
                                                'yyyy-MM-dd',
                                              ).format(_passportExpiryDate!)
                                            : null,
                                      ),
                                      label: 'Passport Expiry Date',
                                      icon: Icons.event,
                                      onTap: () => _selectExpiryDate(
                                        context,
                                        TextEditingController(),
                                        (date) => _passportExpiryDate = date,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),

                      const SizedBox(height: 24),
                      _buildSectionTitle(
                        'Personal Information',
                        Icons.person_outline,
                      ),
                      const SizedBox(height: 12),
                      _buildDateField(
                        controller: _dateOfBirthController,
                        label: 'Date of Birth',
                        icon: Icons.cake,
                        onTap: () => _selectDate(
                          context,
                          _dateOfBirthController,
                          (date) => _selectedDateOfBirth = date,
                        ),
                        validator: (v) => v == null || v.isEmpty
                            ? 'Date of birth is required'
                            : null,
                      ),
                      const SizedBox(height: 12),
                      _buildTextField(
                        controller: _addressController,
                        label: 'Address',
                        icon: Icons.home,
                        maxLines: 2,
                        validator: (v) => v == null || v.isEmpty
                            ? 'Address is required'
                            : null,
                      ),
                      const SizedBox(height: 12),
                      _buildTextField(
                        controller: _locationController,
                        label: 'City/Location',
                        icon: Icons.location_city,
                        validator: (v) => v == null || v.isEmpty
                            ? 'Location is required'
                            : null,
                      ),
                      const SizedBox(height: 12),
                      _buildDropdownField(
                        controller: _genderController,
                        label: 'Gender',
                        icon: Icons.wc,
                        items: _genders,
                        validator: (v) => v == null || v.isEmpty
                            ? 'Gender is required'
                            : null,
                      ),
                      const SizedBox(height: 12),
                      _buildDropdownField(
                        controller: _maritalStatusController,
                        label: 'Marital Status',
                        icon: Icons.favorite,
                        items: _maritalStatuses,
                        validator: (v) => v == null || v.isEmpty
                            ? 'Marital status is required'
                            : null,
                      ),
                      const SizedBox(height: 12),
                      _buildTextField(
                        controller: _alternativePhoneController,
                        label: 'Alternative Phone Number',
                        icon: Icons.phone_android,
                        keyboardType: TextInputType.phone,
                      ),

                      const SizedBox(height: 24),
                      _buildSectionTitle('Proof of Address', Icons.home_work),
                      const SizedBox(height: 12),
                      _buildDocumentUploadCard(
                        title: 'Proof of Address Document',
                        imageUrl: _proofOfAddressUrl,
                        onUpload: () => _pickDocumentImage(
                          'proof_of_address',
                          (url) => _proofOfAddressUrl = url,
                        ),
                      ),

                      const SizedBox(height: 24),
                      _buildSectionTitle(
                        'Driver\'s License (Optional)',
                        Icons.drive_eta,
                      ),
                      const SizedBox(height: 12),
                      _buildDateField(
                        controller: TextEditingController(
                          text: _drivingLicenseExpiryDate != null
                              ? DateFormat(
                                  'yyyy-MM-dd',
                                ).format(_drivingLicenseExpiryDate!)
                              : null,
                        ),
                        label: "Driver's License Expiry Date",
                        icon: Icons.drive_eta,
                        onTap: () => _selectExpiryDate(
                          context,
                          TextEditingController(),
                          (date) => _drivingLicenseExpiryDate = date,
                        ),
                      ),

                      const SizedBox(height: 24),
                      _buildSectionTitle(
                        'Employment Information',
                        Icons.work_outline,
                      ),
                      const SizedBox(height: 12),
                      Obx(
                        () => SwitchListTile(
                          title: Text(
                            'Are you employed?',
                            style: GoogleFonts.nunito(
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          value: _isEmployed.value,
                          activeColor: AppColors.primaryColor,
                          onChanged: (val) => _isEmployed.value = val,
                        ),
                      ),
                      if (_isEmployed.value) ...[
                        const SizedBox(height: 12),
                        _buildTextField(
                          controller: _employerNameController,
                          label: 'Employer Name',
                          icon: Icons.business,
                          validator: (v) => v == null || v.isEmpty
                              ? 'Employer name is required'
                              : null,
                        ),
                        const SizedBox(height: 12),
                        _buildTextField(
                          controller: _jobTitleController,
                          label: 'Job Title',
                          icon: Icons.work,
                          validator: (v) => v == null || v.isEmpty
                              ? 'Job title is required'
                              : null,
                        ),
                        const SizedBox(height: 12),
                        _buildTextField(
                          controller: _durationController,
                          label: 'Duration (e.g., 3 years)',
                          icon: Icons.timer,
                          validator: (v) => v == null || v.isEmpty
                              ? 'Duration is required'
                              : null,
                        ),
                        const SizedBox(height: 12),
                        _buildTextField(
                          controller: _workLocationController,
                          label: 'Work Location',
                          icon: Icons.location_on,
                          validator: (v) => v == null || v.isEmpty
                              ? 'Work location is required'
                              : null,
                        ),
                        const SizedBox(height: 12),
                        _buildTextField(
                          controller: _workContactsController,
                          label: 'Work Contacts',
                          icon: Icons.phone,
                          validator: (v) => v == null || v.isEmpty
                              ? 'Work contacts are required'
                              : null,
                        ),
                      ],

                      const SizedBox(height: 32),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _isSubmitting || _isUploading
                              ? null
                              : _submitKYC,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primaryColor,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: _isSubmitting
                              ? const SizedBox(
                                  width: 24,
                                  height: 24,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : Text(
                                  'Submit KYC',
                                  style: GoogleFonts.nunito(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                        ),
                      ),
                      const SizedBox(height: 32),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 20, color: AppColors.primaryColor),
        const SizedBox(width: 8),
        Text(
          title,
          style: GoogleFonts.nunito(fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        maxLines: maxLines,
        style: GoogleFonts.nunito(fontSize: 15),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: GoogleFonts.nunito(color: Colors.grey[600]),
          prefixIcon: Icon(icon, color: AppColors.primaryColor),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 14,
          ),
        ),
        validator: validator,
      ),
    );
  }

  Widget _buildDateField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required VoidCallback onTap,
    String? Function(String?)? validator,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.grey[50],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey[200]!),
        ),
        child: TextFormField(
          controller: controller,
          enabled: false,
          style: GoogleFonts.nunito(fontSize: 15),
          decoration: InputDecoration(
            labelText: label,
            labelStyle: GoogleFonts.nunito(color: Colors.grey[600]),
            prefixIcon: Icon(icon, color: AppColors.primaryColor),
            suffixIcon: const Icon(
              Icons.calendar_today,
              size: 18,
              color: Colors.grey,
            ),
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),
          ),
          validator: validator,
        ),
      ),
    );
  }

  Widget _buildDropdownField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required List<String> items,
    String? Function(String?)? validator,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: DropdownButtonFormField<String>(
        value: controller.text.isNotEmpty ? controller.text : null,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: GoogleFonts.nunito(color: Colors.grey[600]),
          prefixIcon: Icon(icon, color: AppColors.primaryColor),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 14,
          ),
        ),
        items: items
            .map((item) => DropdownMenuItem(value: item, child: Text(item)))
            .toList(),
        onChanged: (value) => controller.text = value ?? '',
        validator: validator,
      ),
    );
  }

  Widget _buildDocumentUploadCard({
    required String title,
    required String? imageUrl,
    required VoidCallback onUpload,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: imageUrl != null
                ? () => _showImageFullScreen(imageUrl)
                : null,
            child: Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey[300]!),
              ),
              child: imageUrl != null
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(
                        imageUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) =>
                            Icon(Icons.error, color: Colors.red[300]),
                      ),
                    )
                  : Icon(Icons.upload_file, size: 30, color: Colors.grey[400]),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.nunito(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  imageUrl != null ? 'Uploaded' : 'Not uploaded',
                  style: GoogleFonts.nunito(
                    fontSize: 12,
                    color: imageUrl != null ? Colors.green : Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          TextButton.icon(
            onPressed: onUpload,
            icon: Icon(
              Icons.cloud_upload,
              size: 18,
              color: AppColors.primaryColor,
            ),
            label: Text(
              imageUrl != null ? 'Change' : 'Upload',
              style: GoogleFonts.nunito(color: AppColors.primaryColor),
            ),
          ),
        ],
      ),
    );
  }

  void _showImageFullScreen(String imageUrl) {
    Get.to(
      () => Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.close, color: Colors.white),
            onPressed: () => Get.back(),
          ),
        ),
        body: Center(
          child: InteractiveViewer(
            minScale: 0.5,
            maxScale: 4.0,
            child: Image.network(
              imageUrl,
              fit: BoxFit.contain,
              errorBuilder: (_, __, ___) =>
                  const Icon(Icons.error, color: Colors.red, size: 50),
            ),
          ),
        ),
      ),
    );
  }
}
