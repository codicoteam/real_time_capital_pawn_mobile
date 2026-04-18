import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:image_picker/image_picker.dart';
import 'package:real_time_pawn/core/utils/logs.dart';
import 'package:real_time_pawn/core/utils/pallete.dart';
import 'package:real_time_pawn/widgets/custom_password_textfield.dart';
import 'package:real_time_pawn/widgets/dialogs/error_dialog.dart';
import 'package:real_time_pawn/widgets/text_fields/custom_text_field.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../terms_and_private_policy_mgmnt/privacy_policy_screen.dart';
import '../../terms_and_private_policy_mgmnt/terms_and_private_screen.dart';
import '../helpers/register_helper.dart';

class SignUp extends StatefulWidget {
  const SignUp({super.key});

  @override
  State<SignUp> createState() => _SignUpState();
}

class _SignUpState extends State<SignUp> {
  // Text Controllers
  final TextEditingController firstNameController = TextEditingController();
  final TextEditingController lastNameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController alternativePhoneController =
      TextEditingController();
  final TextEditingController nationalIdController = TextEditingController();
  final TextEditingController passportNumberController =
      TextEditingController();
  final TextEditingController dateOfBirthController = TextEditingController();
  final TextEditingController addressController = TextEditingController();
  final TextEditingController locationController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();

  // Additional KYC Controllers
  final TextEditingController genderController = TextEditingController();
  final TextEditingController maritalStatusController = TextEditingController();
  final TextEditingController passportExpiryDateController =
      TextEditingController();
  final TextEditingController drivingLicenseExpiryDateController =
      TextEditingController();
  final TextEditingController nationalIdExpiryDateController =
      TextEditingController();

  // Employment Controllers
  final TextEditingController employerNameController = TextEditingController();
  final TextEditingController jobTitleController = TextEditingController();
  final TextEditingController employmentDurationController =
      TextEditingController();
  final TextEditingController employmentLocationController =
      TextEditingController();
  final TextEditingController employmentContactsController =
      TextEditingController();

  // Next of Kin Controllers
  final TextEditingController nextOfKinNameController = TextEditingController();
  final TextEditingController nextOfKinRelationshipController =
      TextEditingController();
  final TextEditingController nextOfKinPhoneController =
      TextEditingController();
  final TextEditingController nextOfKinEmailController =
      TextEditingController();
  final TextEditingController nextOfKinAddressController =
      TextEditingController();

  // State Variables
  bool _isLoading = false;
  bool _acceptTerms = false;
  String _identificationType = 'national_id'; // 'national_id' or 'passport'
  String? _selectedGender;
  String? _selectedMaritalStatus;
  bool _isEmployed = false;
  bool _showEmploymentFields = false;
  bool _showNextOfKinFields = false;
  bool _showAdditionalKyc = false;

  // Document URLs from Supabase
  String? _nationalIdImageUrl;
  String? _passportImageUrl;
  String? _profilePicUrl;
  String? _proofOfAddressUrl;

  // Document objects for documents array
  List<Map<String, dynamic>> _uploadedDocuments = [];

  // File picking states
  bool _isUploadingNationalId = false;
  bool _isUploadingPassport = false;
  bool _isUploadingProfile = false;
  bool _isUploadingProofOfAddress = false;
  bool _isUploadingDrivingLicense = false;
  bool _isUploadingOtherDocument = false;

  final _scrollController = ScrollController();
  final _supabase = Supabase.instance.client;

  // Gender options
  final List<String> _genderOptions = [
    'Male',
    'Female',
    'Other',
    'Prefer not to say',
  ];

  // Marital status options
  final List<String> _maritalStatusOptions = [
    'Single',
    'Married',
    'Divorced',
    'Widowed',
    'Separated',
    'Prefer not to say',
  ];

  @override
  void dispose() {
    firstNameController.dispose();
    lastNameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    alternativePhoneController.dispose();
    nationalIdController.dispose();
    passportNumberController.dispose();
    dateOfBirthController.dispose();
    addressController.dispose();
    locationController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    genderController.dispose();
    maritalStatusController.dispose();
    passportExpiryDateController.dispose();
    drivingLicenseExpiryDateController.dispose();
    nationalIdExpiryDateController.dispose();
    employerNameController.dispose();
    jobTitleController.dispose();
    employmentDurationController.dispose();
    employmentLocationController.dispose();
    employmentContactsController.dispose();
    nextOfKinNameController.dispose();
    nextOfKinRelationshipController.dispose();
    nextOfKinPhoneController.dispose();
    nextOfKinEmailController.dispose();
    nextOfKinAddressController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(TextEditingController controller) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now().add(const Duration(days: 365 * 10)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: AppColors.primaryColor,
              onPrimary: Colors.white,
              surface: AppColors.surfaceColor,
              onSurface: AppColors.textColor,
            ),
            dialogTheme: DialogThemeData(
              backgroundColor: AppColors.surfaceColor,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        controller.text = DateFormat('yyyy-MM-dd').format(picked);
      });
    }
  }

  Future<void> _selectDateOfBirth() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().subtract(const Duration(days: 365 * 18)),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: AppColors.primaryColor,
              onPrimary: Colors.white,
              surface: AppColors.surfaceColor,
              onSurface: AppColors.textColor,
            ),
            dialogTheme: DialogThemeData(
              backgroundColor: AppColors.surfaceColor,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        dateOfBirthController.text = DateFormat('yyyy-MM-dd').format(picked);
      });
    }
  }

  // Upload document to Supabase Storage
  Future<String?> _uploadDocumentToSupabase({
    required File imageFile,
    required String userId,
    required String documentType,
  }) async {
    try {
      final fileName =
          '${DateTime.now().millisecondsSinceEpoch}_${userId}_${documentType}.jpg';
      final filePath = 'users/$userId/$documentType/$fileName';

      DevLogs.logInfo('📤 Uploading $documentType to storage: $filePath');

      await _supabase.storage
          .from('topics')
          .upload(
            filePath,
            imageFile,
            fileOptions: const FileOptions(
              upsert: false,
              contentType: 'image/jpeg',
            ),
          );

      final publicUrl = _supabase.storage.from('topics').getPublicUrl(filePath);
      DevLogs.logInfo('🔗 Public URL for $documentType: $publicUrl');

      return publicUrl;
    } on StorageException catch (e) {
      DevLogs.logError(
        '❌ Storage Exception for $documentType: ${e.toString()}',
      );
      return null;
    } catch (e) {
      DevLogs.logError('❌ Error uploading $documentType: ${e.toString()}');
      return null;
    }
  }

  // Pick and upload National ID
  Future<void> _pickAndUploadNationalId() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
    );

    if (image != null) {
      setState(() {
        _isUploadingNationalId = true;
      });

      final file = File(image.path);
      final tempId = 'temp_${DateTime.now().millisecondsSinceEpoch}';
      final url = await _uploadDocumentToSupabase(
        imageFile: file,
        userId: tempId,
        documentType: 'national_id',
      );

      if (url != null && mounted) {
        setState(() {
          _nationalIdImageUrl = url;
          _uploadedDocuments.add({
            'type': 'national_id',
            'url': url,
            'file_name': image.name,
            'mime_type': 'image/jpeg',
            'notes': 'National ID uploaded during registration',
          });
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('National ID uploaded successfully'),
            backgroundColor: AppColors.successColor,
            duration: const Duration(seconds: 2),
          ),
        );
      }

      setState(() {
        _isUploadingNationalId = false;
      });
    }
  }

  // Pick and upload Passport
  Future<void> _pickAndUploadPassport() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
    );

    if (image != null) {
      setState(() {
        _isUploadingPassport = true;
      });

      final file = File(image.path);
      final tempId = 'temp_${DateTime.now().millisecondsSinceEpoch}';
      final url = await _uploadDocumentToSupabase(
        imageFile: file,
        userId: tempId,
        documentType: 'passport',
      );

      if (url != null && mounted) {
        setState(() {
          _passportImageUrl = url;
          _uploadedDocuments.add({
            'type': 'passport',
            'url': url,
            'file_name': image.name,
            'mime_type': 'image/jpeg',
            'notes': 'Passport uploaded during registration',
          });
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Passport uploaded successfully'),
            backgroundColor: AppColors.successColor,
            duration: const Duration(seconds: 2),
          ),
        );
      }

      setState(() {
        _isUploadingPassport = false;
      });
    }
  }

  // Pick and upload Profile Picture
  Future<void> _pickAndUploadProfilePic() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
    );

    if (image != null) {
      setState(() {
        _isUploadingProfile = true;
      });

      final file = File(image.path);
      final tempId = 'temp_${DateTime.now().millisecondsSinceEpoch}';
      final url = await _uploadDocumentToSupabase(
        imageFile: file,
        userId: tempId,
        documentType: 'profile',
      );

      if (url != null && mounted) {
        setState(() {
          _profilePicUrl = url;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Profile picture uploaded successfully'),
            backgroundColor: AppColors.successColor,
            duration: const Duration(seconds: 2),
          ),
        );
      }

      setState(() {
        _isUploadingProfile = false;
      });
    }
  }

  // Pick and upload Proof of Address
  Future<void> _pickAndUploadProofOfAddress() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
    );

    if (image != null) {
      setState(() {
        _isUploadingProofOfAddress = true;
      });

      final file = File(image.path);
      final tempId = 'temp_${DateTime.now().millisecondsSinceEpoch}';
      final url = await _uploadDocumentToSupabase(
        imageFile: file,
        userId: tempId,
        documentType: 'proof_of_address',
      );

      if (url != null && mounted) {
        setState(() {
          _proofOfAddressUrl = url;
          _uploadedDocuments.add({
            'type': 'proof_of_address',
            'url': url,
            'file_name': image.name,
            'mime_type': 'image/jpeg',
            'notes': 'Proof of address uploaded during registration',
          });
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Proof of address uploaded successfully'),
            backgroundColor: AppColors.successColor,
            duration: const Duration(seconds: 2),
          ),
        );
      }

      setState(() {
        _isUploadingProofOfAddress = false;
      });
    }
  }

  // Pick and upload Driving License
  Future<void> _pickAndUploadDrivingLicense() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
    );

    if (image != null) {
      setState(() {
        _isUploadingDrivingLicense = true;
      });

      final file = File(image.path);
      final tempId = 'temp_${DateTime.now().millisecondsSinceEpoch}';
      final url = await _uploadDocumentToSupabase(
        imageFile: file,
        userId: tempId,
        documentType: 'driving_license',
      );

      if (url != null && mounted) {
        setState(() {
          _uploadedDocuments.add({
            'type': 'other',
            'url': url,
            'file_name': image.name,
            'mime_type': 'image/jpeg',
            'notes': 'Driving license uploaded during registration',
          });
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Driving license uploaded successfully'),
            backgroundColor: AppColors.successColor,
            duration: const Duration(seconds: 2),
          ),
        );
      }

      setState(() {
        _isUploadingDrivingLicense = false;
      });
    }
  }

  Future<void> _submitForm() async {
    if (!_acceptTerms) {
      showErrorDialog('Please accept the terms and conditions');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Parse dates
      DateTime? parsedPassportExpiryDate;
      if (passportExpiryDateController.text.isNotEmpty) {
        parsedPassportExpiryDate = DateTime.tryParse(
          passportExpiryDateController.text,
        );
      }

      DateTime? parsedDrivingLicenseExpiryDate;
      if (drivingLicenseExpiryDateController.text.isNotEmpty) {
        parsedDrivingLicenseExpiryDate = DateTime.tryParse(
          drivingLicenseExpiryDateController.text,
        );
      }

      DateTime? parsedNationalIdExpiryDate;
      if (nationalIdExpiryDateController.text.isNotEmpty) {
        parsedNationalIdExpiryDate = DateTime.tryParse(
          nationalIdExpiryDateController.text,
        );
      }

      final success = await RegisterHelper.validateRegisterForm(
        firstName: firstNameController.text.trim(),
        lastName: lastNameController.text.trim(),
        email: emailController.text.trim(),
        password: passwordController.text,
        confirmPassword: confirmPasswordController.text,
        phone: phoneController.text.trim().isNotEmpty
            ? phoneController.text.trim()
            : null,
        alternativePhone: alternativePhoneController.text.trim().isNotEmpty
            ? alternativePhoneController.text.trim()
            : null,
        identificationType: _identificationType,
        nationalIdNumber: _identificationType == 'national_id'
            ? nationalIdController.text.trim()
            : null,
        passportNumber: _identificationType == 'passport'
            ? passportNumberController.text.trim()
            : null,
        nationalIdImageUrl: _nationalIdImageUrl,
        passportImageUrl: _passportImageUrl,
        profilePicUrl: _profilePicUrl,
        proofOfAddressUrl: _proofOfAddressUrl,
        dateOfBirth: dateOfBirthController.text.trim().isNotEmpty
            ? dateOfBirthController.text.trim()
            : null,
        address: addressController.text.trim().isNotEmpty
            ? addressController.text.trim()
            : null,
        location: locationController.text.trim().isNotEmpty
            ? locationController.text.trim()
            : null,
        gender: _selectedGender,
        maritalStatus: _selectedMaritalStatus,
        passportExpiryDate: parsedPassportExpiryDate,
        drivingLicenseExpiryDate: parsedDrivingLicenseExpiryDate,
        nationalIdExpiryDate: parsedNationalIdExpiryDate,
        isEmployed: _isEmployed,
        employerName:
            _isEmployed && employerNameController.text.trim().isNotEmpty
            ? employerNameController.text.trim()
            : null,
        jobTitle: _isEmployed && jobTitleController.text.trim().isNotEmpty
            ? jobTitleController.text.trim()
            : null,
        employmentDuration:
            _isEmployed && employmentDurationController.text.trim().isNotEmpty
            ? employmentDurationController.text.trim()
            : null,
        employmentLocation:
            _isEmployed && employmentLocationController.text.trim().isNotEmpty
            ? employmentLocationController.text.trim()
            : null,
        employmentContacts:
            _isEmployed && employmentContactsController.text.trim().isNotEmpty
            ? employmentContactsController.text.trim()
            : null,
        nextOfKinFullName: nextOfKinNameController.text.trim().isNotEmpty
            ? nextOfKinNameController.text.trim()
            : null,
        nextOfKinRelationship:
            nextOfKinRelationshipController.text.trim().isNotEmpty
            ? nextOfKinRelationshipController.text.trim()
            : null,
        nextOfKinPhone: nextOfKinPhoneController.text.trim().isNotEmpty
            ? nextOfKinPhoneController.text.trim()
            : null,
        nextOfKinEmail: nextOfKinEmailController.text.trim().isNotEmpty
            ? nextOfKinEmailController.text.trim()
            : null,
        nextOfKinAddress: nextOfKinAddressController.text.trim().isNotEmpty
            ? nextOfKinAddressController.text.trim()
            : null,
        documents: _uploadedDocuments.isNotEmpty ? _uploadedDocuments : null,
        acceptTerms: _acceptTerms,
      );

      if (success) {
        // Success - navigation will be handled in RegisterHelper
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void showErrorDialog(String errorMessage) {
    showDialog(
      context: context,
      builder: (context) => ErrorDialog(errorMessage: errorMessage),
    );
  }

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.sizeOf(context).height;

    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          controller: _scrollController,
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: screenHeight * 0.04),

              // Welcome Header
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Create Account',
                    style: GoogleFonts.poppins(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textColor,
                    ),
                  ).animate().fadeIn(duration: 600.ms).slideX(begin: -0.3),
                  const SizedBox(height: 8),
                  Text(
                        'Complete your profile to get started',
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          color: AppColors.subtextColor,
                          fontWeight: FontWeight.w400,
                        ),
                      )
                      .animate()
                      .fadeIn(duration: 800.ms, delay: 200.ms)
                      .slideX(begin: -0.3),
                ],
              ),

              SizedBox(height: screenHeight * 0.03),

              // Personal Information Section
              Text(
                'Personal Information',
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textColor,
                ),
              ).animate().fadeIn(duration: 600.ms, delay: 400.ms),

              const SizedBox(height: 12),

              // Register Form Container
              Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(28),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceColor,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          spreadRadius: 0,
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // First Name Field
                        CustomTextField(
                              controller: firstNameController,
                              labelText: 'First Name',
                              focusedBorderColor: AppColors.primaryColor,
                              prefixIcon: Icon(
                                Icons.person_outline,
                                color: AppColors.subtextColor,
                              ),
                            )
                            .animate()
                            .fadeIn(duration: 600.ms, delay: 400.ms)
                            .slideY(begin: 0.3),

                        const SizedBox(height: 16),

                        // Last Name Field
                        CustomTextField(
                              controller: lastNameController,
                              labelText: 'Last Name',
                              focusedBorderColor: AppColors.primaryColor,
                              prefixIcon: Icon(
                                Icons.person_outline,
                                color: AppColors.subtextColor,
                              ),
                            )
                            .animate()
                            .fadeIn(duration: 600.ms, delay: 500.ms)
                            .slideY(begin: 0.3),

                        const SizedBox(height: 16),

                        // Email Field
                        CustomTextField(
                              controller: emailController,
                              labelText: 'Email Address',
                              focusedBorderColor: AppColors.primaryColor,
                              prefixIcon: Icon(
                                Icons.email_outlined,
                                color: AppColors.subtextColor,
                              ),
                              keyboardType: TextInputType.emailAddress,
                            )
                            .animate()
                            .fadeIn(duration: 600.ms, delay: 600.ms)
                            .slideY(begin: 0.3),

                        const SizedBox(height: 16),

                        // Phone Field
                        CustomTextField(
                              controller: phoneController,
                              labelText: 'Phone Number',
                              focusedBorderColor: AppColors.primaryColor,
                              prefixIcon: Icon(
                                Icons.phone_outlined,
                                color: AppColors.subtextColor,
                              ),
                              keyboardType: TextInputType.phone,
                            )
                            .animate()
                            .fadeIn(duration: 600.ms, delay: 700.ms)
                            .slideY(begin: 0.3),

                        const SizedBox(height: 16),

                        // Alternative Phone Field
                        CustomTextField(
                              controller: alternativePhoneController,
                              labelText: 'Alternative Phone Number (Optional)',
                              focusedBorderColor: AppColors.primaryColor,
                              prefixIcon: Icon(
                                Icons.phone_android_outlined,
                                color: AppColors.subtextColor,
                              ),
                              keyboardType: TextInputType.phone,
                            )
                            .animate()
                            .fadeIn(duration: 600.ms, delay: 750.ms)
                            .slideY(begin: 0.3),

                        const SizedBox(height: 24),

                        // Gender Dropdown
                        Container(
                              decoration: BoxDecoration(
                                border: Border.all(
                                  color: AppColors.borderColor,
                                ),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                              ),
                              child: DropdownButtonFormField<String>(
                                value: _selectedGender,
                                hint: Text(
                                  'Select Gender',
                                  style: GoogleFonts.poppins(
                                    color: AppColors.subtextColor,
                                  ),
                                ),
                                decoration: const InputDecoration(
                                  border: InputBorder.none,
                                  prefixIcon: Icon(Icons.transgender_outlined),
                                ),
                                items: _genderOptions.map((String gender) {
                                  return DropdownMenuItem<String>(
                                    value: gender,
                                    child: Text(
                                      gender,
                                      style: GoogleFonts.poppins(),
                                    ),
                                  );
                                }).toList(),
                                onChanged: (String? newValue) {
                                  setState(() {
                                    _selectedGender = newValue;
                                  });
                                },
                              ),
                            )
                            .animate()
                            .fadeIn(duration: 600.ms, delay: 800.ms)
                            .slideY(begin: 0.3),

                        const SizedBox(height: 16),

                        // Marital Status Dropdown
                        Container(
                              decoration: BoxDecoration(
                                border: Border.all(
                                  color: AppColors.borderColor,
                                ),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                              ),
                              child: DropdownButtonFormField<String>(
                                value: _selectedMaritalStatus,
                                hint: Text(
                                  'Marital Status',
                                  style: GoogleFonts.poppins(
                                    color: AppColors.subtextColor,
                                  ),
                                ),
                                decoration: const InputDecoration(
                                  border: InputBorder.none,
                                  prefixIcon: Icon(Icons.favorite_outlined),
                                ),
                                items: _maritalStatusOptions.map((
                                  String status,
                                ) {
                                  return DropdownMenuItem<String>(
                                    value: status,
                                    child: Text(
                                      status,
                                      style: GoogleFonts.poppins(),
                                    ),
                                  );
                                }).toList(),
                                onChanged: (String? newValue) {
                                  setState(() {
                                    _selectedMaritalStatus = newValue;
                                  });
                                },
                              ),
                            )
                            .animate()
                            .fadeIn(duration: 600.ms, delay: 850.ms)
                            .slideY(begin: 0.3),

                        const SizedBox(height: 24),

                        // Identification Type Selection
                        Text(
                          'Identification Type',
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textColor,
                          ),
                        ).animate().fadeIn(duration: 600.ms, delay: 900.ms),

                        const SizedBox(height: 8),

                        Row(
                          children: [
                            Expanded(
                              child: RadioListTile<String>(
                                title: Text(
                                  'National ID',
                                  style: GoogleFonts.poppins(fontSize: 14),
                                ),
                                value: 'national_id',
                                groupValue: _identificationType,
                                activeColor: AppColors.primaryColor,
                                contentPadding: EdgeInsets.zero,
                                onChanged: (value) {
                                  setState(() {
                                    _identificationType = value!;
                                  });
                                },
                              ),
                            ),
                            Expanded(
                              child: RadioListTile<String>(
                                title: Text(
                                  'Passport',
                                  style: GoogleFonts.poppins(fontSize: 14),
                                ),
                                value: 'passport',
                                groupValue: _identificationType,
                                activeColor: AppColors.primaryColor,
                                contentPadding: EdgeInsets.zero,
                                onChanged: (value) {
                                  setState(() {
                                    _identificationType = value!;
                                  });
                                },
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 8),

                        // Conditional Field: National ID or Passport
                        if (_identificationType == 'national_id')
                          CustomTextField(
                                controller: nationalIdController,
                                labelText: 'National ID (e.g., 63-1234567A12)',
                                focusedBorderColor: AppColors.primaryColor,
                                prefixIcon: Icon(
                                  Icons.badge_outlined,
                                  color: AppColors.subtextColor,
                                ),
                              )
                              .animate()
                              .fadeIn(duration: 600.ms, delay: 950.ms)
                              .slideY(begin: 0.3)
                        else
                          CustomTextField(
                                controller: passportNumberController,
                                labelText: 'Passport Number',
                                focusedBorderColor: AppColors.primaryColor,
                                prefixIcon: Icon(
                                  Icons.airplane_ticket_outlined,
                                  color: AppColors.subtextColor,
                                ),
                              )
                              .animate()
                              .fadeIn(duration: 600.ms, delay: 950.ms)
                              .slideY(begin: 0.3),

                        const SizedBox(height: 16),

                        // National ID Expiry Date (if National ID selected)
                        if (_identificationType == 'national_id')
                          GestureDetector(
                                onTap: () =>
                                    _selectDate(nationalIdExpiryDateController),
                                child: AbsorbPointer(
                                  child: CustomTextField(
                                    controller: nationalIdExpiryDateController,
                                    labelText:
                                        'National ID Expiry Date (Optional)',
                                    focusedBorderColor: AppColors.primaryColor,
                                    prefixIcon: Icon(
                                      Icons.calendar_today_outlined,
                                      color: AppColors.subtextColor,
                                    ),
                                  ),
                                ),
                              )
                              .animate()
                              .fadeIn(duration: 600.ms, delay: 1000.ms)
                              .slideY(begin: 0.3),

                        const SizedBox(height: 16),

                        // Upload Document Button (National ID or Passport)
                        if (_identificationType == 'national_id')
                          Column(
                            children: [
                              _buildUploadButton(
                                label: 'Upload National ID Image',
                                isUploading: _isUploadingNationalId,
                                onTap: _pickAndUploadNationalId,
                                hasFile: _nationalIdImageUrl != null,
                              ),
                              if (_nationalIdImageUrl != null)
                                Padding(
                                  padding: const EdgeInsets.only(top: 8),
                                  child: Text(
                                    '✓ National ID uploaded',
                                    style: GoogleFonts.poppins(
                                      fontSize: 12,
                                      color: AppColors.successColor,
                                    ),
                                  ),
                                ),
                            ],
                          )
                        else
                          Column(
                            children: [
                              _buildUploadButton(
                                label: 'Upload Passport Image',
                                isUploading: _isUploadingPassport,
                                onTap: _pickAndUploadPassport,
                                hasFile: _passportImageUrl != null,
                              ),
                              if (_passportImageUrl != null)
                                Padding(
                                  padding: const EdgeInsets.only(top: 8),
                                  child: Text(
                                    '✓ Passport uploaded',
                                    style: GoogleFonts.poppins(
                                      fontSize: 12,
                                      color: AppColors.successColor,
                                    ),
                                  ),
                                ),
                            ],
                          ),

                        const SizedBox(height: 16),

                        // Passport Expiry Date
                        GestureDetector(
                              onTap: () =>
                                  _selectDate(passportExpiryDateController),
                              child: AbsorbPointer(
                                child: CustomTextField(
                                  controller: passportExpiryDateController,
                                  labelText: 'Passport Expiry Date (Optional)',
                                  focusedBorderColor: AppColors.primaryColor,
                                  prefixIcon: Icon(
                                    Icons.calendar_today_outlined,
                                    color: AppColors.subtextColor,
                                  ),
                                ),
                              ),
                            )
                            .animate()
                            .fadeIn(duration: 600.ms, delay: 1050.ms)
                            .slideY(begin: 0.3),

                        const SizedBox(height: 16),

                        // Profile Picture Upload
                        _buildUploadButton(
                          label: 'Upload Profile Picture (Optional)',
                          isUploading: _isUploadingProfile,
                          onTap: _pickAndUploadProfilePic,
                          hasFile: _profilePicUrl != null,
                        ),

                        const SizedBox(height: 16),

                        // Proof of Address Upload
                        _buildUploadButton(
                          label: 'Upload Proof of Address (Optional)',
                          isUploading: _isUploadingProofOfAddress,
                          onTap: _pickAndUploadProofOfAddress,
                          hasFile: _proofOfAddressUrl != null,
                        ),

                        const SizedBox(height: 16),

                        // Driving License Upload
                        _buildUploadButton(
                          label: 'Upload Driving License (Optional)',
                          isUploading: _isUploadingDrivingLicense,
                          onTap: _pickAndUploadDrivingLicense,
                          hasFile: false,
                        ),

                        const SizedBox(height: 16),

                        // Driving License Expiry Date
                        GestureDetector(
                              onTap: () => _selectDate(
                                drivingLicenseExpiryDateController,
                              ),
                              child: AbsorbPointer(
                                child: CustomTextField(
                                  controller:
                                      drivingLicenseExpiryDateController,
                                  labelText:
                                      'Driving License Expiry Date (Optional)',
                                  focusedBorderColor: AppColors.primaryColor,
                                  prefixIcon: Icon(
                                    Icons.calendar_today_outlined,
                                    color: AppColors.subtextColor,
                                  ),
                                ),
                              ),
                            )
                            .animate()
                            .fadeIn(duration: 600.ms, delay: 1100.ms)
                            .slideY(begin: 0.3),

                        const SizedBox(height: 16),

                        // Date of Birth Field
                        GestureDetector(
                              onTap: _selectDateOfBirth,
                              child: AbsorbPointer(
                                child: CustomTextField(
                                  controller: dateOfBirthController,
                                  labelText: 'Date of Birth (YYYY-MM-DD)',
                                  focusedBorderColor: AppColors.primaryColor,
                                  prefixIcon: Icon(
                                    Icons.calendar_today_outlined,
                                    color: AppColors.subtextColor,
                                  ),
                                ),
                              ),
                            )
                            .animate()
                            .fadeIn(duration: 600.ms, delay: 1150.ms)
                            .slideY(begin: 0.3),

                        const SizedBox(height: 16),

                        // Address Field
                        CustomTextField(
                              controller: addressController,
                              labelText: 'Address',
                              focusedBorderColor: AppColors.primaryColor,
                              prefixIcon: Icon(
                                Icons.location_on_outlined,
                                color: AppColors.subtextColor,
                              ),
                            )
                            .animate()
                            .fadeIn(duration: 600.ms, delay: 1200.ms)
                            .slideY(begin: 0.3),

                        const SizedBox(height: 16),

                        // Location/City Field
                        CustomTextField(
                              controller: locationController,
                              labelText: 'Location/City',
                              focusedBorderColor: AppColors.primaryColor,
                              prefixIcon: Icon(
                                Icons.place_outlined,
                                color: AppColors.subtextColor,
                              ),
                            )
                            .animate()
                            .fadeIn(duration: 600.ms, delay: 1250.ms)
                            .slideY(begin: 0.3),

                        const SizedBox(height: 24),

                        // Employment Section
                        Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                border: Border.all(
                                  color: AppColors.borderColor,
                                ),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Column(
                                children: [
                                  Row(
                                    children: [
                                      Checkbox(
                                        value: _isEmployed,
                                        onChanged: (value) {
                                          setState(() {
                                            _isEmployed = value ?? false;
                                            _showEmploymentFields = _isEmployed;
                                          });
                                        },
                                        activeColor: AppColors.primaryColor,
                                      ),
                                      Text(
                                        'I am currently employed',
                                        style: GoogleFonts.poppins(
                                          fontSize: 14,
                                          color: AppColors.textColor,
                                        ),
                                      ),
                                    ],
                                  ),
                                  if (_showEmploymentFields) ...[
                                    const SizedBox(height: 12),
                                    CustomTextField(
                                      controller: employerNameController,
                                      labelText: 'Employer Name',
                                      focusedBorderColor:
                                          AppColors.primaryColor,
                                      prefixIcon: Icon(
                                        Icons.business_outlined,
                                        color: AppColors.subtextColor,
                                      ),
                                    ),
                                    const SizedBox(height: 12),
                                    CustomTextField(
                                      controller: jobTitleController,
                                      labelText: 'Job Title',
                                      focusedBorderColor:
                                          AppColors.primaryColor,
                                      prefixIcon: Icon(
                                        Icons.work_outline,
                                        color: AppColors.subtextColor,
                                      ),
                                    ),
                                    const SizedBox(height: 12),
                                    CustomTextField(
                                      controller: employmentDurationController,
                                      labelText: 'Duration (e.g., 2 years)',
                                      focusedBorderColor:
                                          AppColors.primaryColor,
                                      prefixIcon: Icon(
                                        Icons.timer_outlined,
                                        color: AppColors.subtextColor,
                                      ),
                                    ),
                                    const SizedBox(height: 12),
                                    CustomTextField(
                                      controller: employmentLocationController,
                                      labelText: 'Work Location (Optional)',
                                      focusedBorderColor:
                                          AppColors.primaryColor,
                                      prefixIcon: Icon(
                                        Icons.location_city_outlined,
                                        color: AppColors.subtextColor,
                                      ),
                                    ),
                                    const SizedBox(height: 12),
                                    CustomTextField(
                                      controller: employmentContactsController,
                                      labelText: 'Work Contacts (Optional)',
                                      focusedBorderColor:
                                          AppColors.primaryColor,
                                      prefixIcon: Icon(
                                        Icons.contact_phone_outlined,
                                        color: AppColors.subtextColor,
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            )
                            .animate()
                            .fadeIn(duration: 600.ms, delay: 1300.ms)
                            .slideY(begin: 0.3),

                        const SizedBox(height: 16),

                        // Next of Kin Section (Optional)
                        Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                border: Border.all(
                                  color: AppColors.borderColor,
                                ),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Column(
                                children: [
                                  Row(
                                    children: [
                                      Checkbox(
                                        value: _showNextOfKinFields,
                                        onChanged: (value) {
                                          setState(() {
                                            _showNextOfKinFields =
                                                value ?? false;
                                          });
                                        },
                                        activeColor: AppColors.primaryColor,
                                      ),
                                      Text(
                                        'Add Next of Kin (Optional)',
                                        style: GoogleFonts.poppins(
                                          fontSize: 14,
                                          color: AppColors.textColor,
                                        ),
                                      ),
                                    ],
                                  ),
                                  if (_showNextOfKinFields) ...[
                                    const SizedBox(height: 12),
                                    CustomTextField(
                                      controller: nextOfKinNameController,
                                      labelText: 'Full Name',
                                      focusedBorderColor:
                                          AppColors.primaryColor,
                                      prefixIcon: Icon(
                                        Icons.person_outline,
                                        color: AppColors.subtextColor,
                                      ),
                                    ),
                                    const SizedBox(height: 12),
                                    CustomTextField(
                                      controller:
                                          nextOfKinRelationshipController,
                                      labelText: 'Relationship',
                                      focusedBorderColor:
                                          AppColors.primaryColor,
                                      prefixIcon: Icon(
                                        Icons.family_restroom_outlined,
                                        color: AppColors.subtextColor,
                                      ),
                                    ),
                                    const SizedBox(height: 12),
                                    CustomTextField(
                                      controller: nextOfKinPhoneController,
                                      labelText: 'Phone Number',
                                      focusedBorderColor:
                                          AppColors.primaryColor,
                                      prefixIcon: Icon(
                                        Icons.phone_outlined,
                                        color: AppColors.subtextColor,
                                      ),
                                      keyboardType: TextInputType.phone,
                                    ),
                                    const SizedBox(height: 12),
                                    CustomTextField(
                                      controller: nextOfKinEmailController,
                                      labelText: 'Email',
                                      focusedBorderColor:
                                          AppColors.primaryColor,
                                      prefixIcon: Icon(
                                        Icons.email_outlined,
                                        color: AppColors.subtextColor,
                                      ),
                                      keyboardType: TextInputType.emailAddress,
                                    ),
                                    const SizedBox(height: 12),
                                    CustomTextField(
                                      controller: nextOfKinAddressController,
                                      labelText: 'Address',
                                      focusedBorderColor:
                                          AppColors.primaryColor,
                                      prefixIcon: Icon(
                                        Icons.location_on_outlined,
                                        color: AppColors.subtextColor,
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            )
                            .animate()
                            .fadeIn(duration: 600.ms, delay: 1350.ms)
                            .slideY(begin: 0.3),

                        const SizedBox(height: 24),

                        // Password Section
                        Text(
                          'Security Information',
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textColor,
                          ),
                        ).animate().fadeIn(duration: 600.ms, delay: 1400.ms),

                        const SizedBox(height: 12),

                        // Password Field
                        CustomPasswordTextfield(
                              controller: passwordController,
                              obscureText: true,
                              labelText: 'Password',
                              prefixIcon: Icon(
                                Icons.lock_outline,
                                color: AppColors.subtextColor,
                              ),
                            )
                            .animate()
                            .fadeIn(duration: 600.ms, delay: 1450.ms)
                            .slideY(begin: 0.3),

                        const SizedBox(height: 16),

                        // Confirm Password Field
                        CustomPasswordTextfield(
                              controller: confirmPasswordController,
                              obscureText: true,
                              labelText: 'Confirm Password',
                              prefixIcon: Icon(
                                Icons.lock_outline,
                                color: AppColors.subtextColor,
                              ),
                            )
                            .animate()
                            .fadeIn(duration: 600.ms, delay: 1500.ms)
                            .slideY(begin: 0.3),

                        const SizedBox(height: 24),

                        // Terms and Conditions Checkbox
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(
                              width: 24,
                              height: 24,
                              child: Checkbox(
                                value: _acceptTerms,
                                onChanged: (value) {
                                  setState(() {
                                    _acceptTerms = value ?? false;
                                  });
                                },
                                activeColor: AppColors.primaryColor,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(4),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Flexible(
                              child: Wrap(
                                children: [
                                  Text(
                                    'I agree to the ',
                                    style: GoogleFonts.poppins(
                                      color: AppColors.subtextColor,
                                      fontSize: 13,
                                    ),
                                  ),
                                  GestureDetector(
                                    onTap: () => Get.to(
                                      () => const TermsOfServiceScreen(),
                                    ),
                                    child: Text(
                                      'Terms of Service',
                                      style: GoogleFonts.poppins(
                                        color: AppColors.primaryColor,
                                        fontWeight: FontWeight.w600,
                                        fontSize: 13,
                                        decoration: TextDecoration.underline,
                                      ),
                                    ),
                                  ),
                                  Text(
                                    ' and ',
                                    style: GoogleFonts.poppins(
                                      color: AppColors.subtextColor,
                                      fontSize: 13,
                                    ),
                                  ),
                                  GestureDetector(
                                    onTap: () => Get.to(
                                      () => const PrivacyPolicyScreen(),
                                    ),
                                    child: Text(
                                      'Privacy Policy',
                                      style: GoogleFonts.poppins(
                                        color: AppColors.primaryColor,
                                        fontWeight: FontWeight.w600,
                                        fontSize: 13,
                                        decoration: TextDecoration.underline,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 32),

                        // Register Button
                        Container(
                              width: double.infinity,
                              decoration: BoxDecoration(
                                color: AppColors.primaryColor,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: AppColors.borderColor,
                                  width: 1.5,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.03),
                                    spreadRadius: 0,
                                    blurRadius: 10,
                                    offset: const Offset(0, 5),
                                  ),
                                ],
                              ),
                              child: Material(
                                color: Colors.transparent,
                                child: InkWell(
                                  borderRadius: BorderRadius.circular(12),
                                  onTap: _isLoading ? null : _submitForm,
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 16,
                                    ),
                                    child: Center(
                                      child: _isLoading
                                          ? const SizedBox(
                                              height: 20,
                                              width: 20,
                                              child: CircularProgressIndicator(
                                                color: Colors.white,
                                                strokeWidth: 2,
                                              ),
                                            )
                                          : Text(
                                              'Create Account',
                                              style: GoogleFonts.poppins(
                                                color: Colors.white,
                                                fontSize: 16,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                    ),
                                  ),
                                ),
                              ),
                            )
                            .animate()
                            .fadeIn(duration: 600.ms, delay: 1700.ms)
                            .scale(begin: const Offset(0.95, 0.95)),
                      ],
                    ),
                  )
                  .animate()
                  .fadeIn(duration: 800.ms, delay: 300.ms)
                  .scale(begin: const Offset(0.95, 0.95)),

              const SizedBox(height: 24),

              // Sign In Link
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Already have an account? ",
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      color: AppColors.subtextColor,
                    ),
                  ),
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Text(
                      'Sign In',
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        color: AppColors.primaryColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ).animate().fadeIn(duration: 600.ms, delay: 1800.ms),

              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildUploadButton({
    required String label,
    required bool isUploading,
    required VoidCallback onTap,
    required bool hasFile,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: double.infinity,
          decoration: BoxDecoration(
            border: Border.all(color: AppColors.borderColor),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: isUploading ? null : onTap,
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: 12,
                  horizontal: 16,
                ),
                child: Row(
                  children: [
                    Icon(
                      hasFile
                          ? Icons.check_circle
                          : Icons.cloud_upload_outlined,
                      color: hasFile
                          ? AppColors.successColor
                          : AppColors.primaryColor,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        isUploading ? 'Uploading...' : label,
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          color: isUploading
                              ? AppColors.subtextColor
                              : AppColors.textColor,
                        ),
                      ),
                    ),
                    if (isUploading)
                      const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
