import 'dart:io';
import 'package:csc_picker_plus/csc_picker_plus.dart';
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
  final TextEditingController homeAddressController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();

  // Additional KYC Controllers
  final TextEditingController genderController = TextEditingController();
  final TextEditingController maritalStatusController = TextEditingController();
  final TextEditingController passportExpiryDateController =
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

  // CSC Picker values
  String? selectedState;
  String? selectedCity;
  String countryValue = "Zimbabwe";

  // Validation error states for real-time validation
  String? _emailError;
  String? _phoneError;
  String? _alternativePhoneError;
  String? _nationalIdError;
  String? _passwordError;
  String? _confirmPasswordError;
  String? _employmentContactError;
  String? _nextOfKinPhoneError;
  String? _nextOfKinEmailError;
  String? _nextOfKinNameError;
  String? _nextOfKinRelationshipError;
  String? _homeAddressError;
  String? _profilePictureError;

  // State Variables
  bool _isLoading = false;
  bool _acceptTerms = false;
  String _identificationType = 'national_id'; // 'national_id' or 'passport'
  String? _selectedGender;
  String? _selectedMaritalStatus;
  bool _isEmployed = false;
  bool _showEmploymentFields = false;
  bool _showNextOfKinFields = true;

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

  final _scrollController = ScrollController();
  final _supabase = Supabase.instance.client;

  // Gender options - ONLY Male and Female
  final List<String> _genderOptions = ['Male', 'Female'];

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
  void initState() {
    super.initState();
    // Add listeners for real-time validation
    emailController.addListener(_validateEmail);
    phoneController.addListener(_validatePhone);
    alternativePhoneController.addListener(_validateAlternativePhone);
    nationalIdController.addListener(_validateNationalId);
    passwordController.addListener(_validatePassword);
    confirmPasswordController.addListener(_validateConfirmPassword);
    employmentContactsController.addListener(_validateEmploymentContact);
    nextOfKinPhoneController.addListener(_validateNextOfKinPhone);
    nextOfKinEmailController.addListener(_validateNextOfKinEmail);
    nextOfKinNameController.addListener(_validateNextOfKinName);
    nextOfKinRelationshipController.addListener(_validateNextOfKinRelationship);
    homeAddressController.addListener(_validateHomeAddress);
  }

  @override
  void dispose() {
    // Remove listeners
    emailController.removeListener(_validateEmail);
    phoneController.removeListener(_validatePhone);
    alternativePhoneController.removeListener(_validateAlternativePhone);
    nationalIdController.removeListener(_validateNationalId);
    passwordController.removeListener(_validatePassword);
    confirmPasswordController.removeListener(_validateConfirmPassword);
    employmentContactsController.removeListener(_validateEmploymentContact);
    nextOfKinPhoneController.removeListener(_validateNextOfKinPhone);
    nextOfKinEmailController.removeListener(_validateNextOfKinEmail);
    nextOfKinNameController.removeListener(_validateNextOfKinName);
    nextOfKinRelationshipController.removeListener(
      _validateNextOfKinRelationship,
    );
    homeAddressController.removeListener(_validateHomeAddress);

    firstNameController.dispose();
    lastNameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    alternativePhoneController.dispose();
    nationalIdController.dispose();
    passportNumberController.dispose();
    dateOfBirthController.dispose();
    homeAddressController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    genderController.dispose();
    maritalStatusController.dispose();
    passportExpiryDateController.dispose();
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

  // Real-time validation methods
  void _validateEmail() {
    setState(() {
      _emailError = RegisterHelper.getEmailError(emailController.text);
    });
  }

  void _validatePhone() {
    setState(() {
      _phoneError = RegisterHelper.getPhoneError(phoneController.text);
    });
  }

  void _validateAlternativePhone() {
    setState(() {
      if (alternativePhoneController.text.isNotEmpty) {
        _alternativePhoneError = RegisterHelper.getPhoneError(
          alternativePhoneController.text,
        );
      } else {
        _alternativePhoneError = null;
      }
    });
  }

  void _validateNationalId() {
    if (_identificationType == 'national_id') {
      setState(() {
        _nationalIdError = RegisterHelper.getNationalIdError(
          nationalIdController.text,
        );
      });
    }
  }

  void _validatePassword() {
    setState(() {
      _passwordError = RegisterHelper.getPasswordError(passwordController.text);
    });
  }

  void _validateConfirmPassword() {
    setState(() {
      _confirmPasswordError = RegisterHelper.getConfirmPasswordError(
        passwordController.text,
        confirmPasswordController.text,
      );
    });
  }

  void _validateEmploymentContact() {
    if (_isEmployed && employmentContactsController.text.isNotEmpty) {
      setState(() {
        _employmentContactError = RegisterHelper.getPhoneError(
          employmentContactsController.text,
        );
      });
    } else {
      setState(() {
        _employmentContactError = null;
      });
    }
  }

  void _validateNextOfKinPhone() {
    if (nextOfKinPhoneController.text.isNotEmpty) {
      setState(() {
        _nextOfKinPhoneError = RegisterHelper.getPhoneError(
          nextOfKinPhoneController.text,
        );
      });
    } else {
      setState(() {
        _nextOfKinPhoneError = null;
      });
    }
  }

  void _validateNextOfKinEmail() {
    if (nextOfKinEmailController.text.isNotEmpty) {
      setState(() {
        _nextOfKinEmailError = RegisterHelper.getEmailError(
          nextOfKinEmailController.text,
        );
      });
    } else {
      setState(() {
        _nextOfKinEmailError = null;
      });
    }
  }

  void _validateNextOfKinName() {
    if (nextOfKinNameController.text.trim().isEmpty) {
      setState(() {
        _nextOfKinNameError = 'Next of kin name is required';
      });
    } else if (nextOfKinNameController.text.trim().length < 2) {
      setState(() {
        _nextOfKinNameError = 'Name must be at least 2 characters';
      });
    } else {
      setState(() {
        _nextOfKinNameError = null;
      });
    }
  }

  void _validateNextOfKinRelationship() {
    if (nextOfKinRelationshipController.text.trim().isEmpty) {
      setState(() {
        _nextOfKinRelationshipError = 'Relationship is required';
      });
    } else {
      setState(() {
        _nextOfKinRelationshipError = null;
      });
    }
  }

  void _validateHomeAddress() {
    setState(() {
      if (homeAddressController.text.trim().isEmpty) {
        _homeAddressError = 'Home address is required';
      } else if (homeAddressController.text.trim().length < 5) {
        _homeAddressError = 'Please enter a valid home address';
      } else {
        _homeAddressError = null;
      }
    });
  }

  void _validateProfilePicture() {
    setState(() {
      if (_profilePicUrl == null) {
        _profilePictureError = 'Profile picture with ID is required';
      } else {
        _profilePictureError = null;
      }
    });
  }

  // Check if form is valid for submission
  bool get _isFormValid {
    // Required fields validation
    if (firstNameController.text.trim().isEmpty ||
        firstNameController.text.trim().length < 2)
      return false;
    if (lastNameController.text.trim().isEmpty ||
        lastNameController.text.trim().length < 2)
      return false;
    if (_emailError != null) return false;
    if (dateOfBirthController.text.isEmpty) return false;
    if (_passwordError != null) return false;
    if (_confirmPasswordError != null) return false;
    if (!_acceptTerms) return false;

    // Gender is required
    if (_selectedGender == null) return false;

    // Phone is required (not optional)
    if (phoneController.text.isEmpty) return false;
    if (_phoneError != null) return false;

    // Home address is required
    if (homeAddressController.text.trim().isEmpty) return false;
    if (_homeAddressError != null) return false;

    // State and City are required from CSC picker
    if (selectedState == null || selectedState!.isEmpty) return false;
    if (selectedCity == null || selectedCity!.isEmpty) return false;

    // Age validation (must be at least 21)
    if (dateOfBirthController.text.isNotEmpty) {
      try {
        final DateTime dob = DateTime.parse(dateOfBirthController.text);
        final DateTime today = DateTime.now();
        int age = today.year - dob.year;
        if (today.month < dob.month ||
            (today.month == dob.month && today.day < dob.day)) {
          age--;
        }
        if (age < 21) return false;
      } catch (e) {
        return false;
      }
    } else {
      return false;
    }

    // Profile picture is required
    if (_profilePicUrl == null) return false;

    // Identification validation
    if (_identificationType == 'national_id') {
      if (nationalIdController.text.isEmpty) return false;
      if (_nationalIdError != null) return false;
      if (_nationalIdImageUrl == null) return false;
    } else {
      if (passportNumberController.text.isEmpty) return false;
      if (passportExpiryDateController.text.isEmpty) return false;
      if (_passportImageUrl == null) return false;
    }

    // Employment validation (if employed)
    if (_isEmployed) {
      if (employerNameController.text.trim().isEmpty) return false;
      if (jobTitleController.text.trim().isEmpty) return false;
      if (employmentDurationController.text.trim().isEmpty) return false;
      if (employmentContactsController.text.isNotEmpty &&
          _employmentContactError != null)
        return false;
    }

    // Next of Kin validation (required)
    if (nextOfKinNameController.text.trim().isEmpty) return false;
    if (_nextOfKinNameError != null) return false;
    if (nextOfKinRelationshipController.text.trim().isEmpty) return false;
    if (_nextOfKinRelationshipError != null) return false;

    // Next of kin address is required (not optional)
    if (nextOfKinAddressController.text.trim().isEmpty) return false;

    if (nextOfKinPhoneController.text.isNotEmpty &&
        _nextOfKinPhoneError != null)
      return false;
    if (nextOfKinEmailController.text.isNotEmpty &&
        _nextOfKinEmailError != null)
      return false;

    return true;
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
    // Calculate minimum age (21 years ago from today)
    final DateTime minDate = DateTime.now().subtract(
      const Duration(days: 365 * 21),
    );

    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: minDate,
      firstDate: DateTime(1900),
      lastDate: minDate, // User must be at least 21 years old
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

  // Show image picker options (Gallery or Camera)
  Future<void> _showImagePickerOptions({
    required Function(File imageFile) onImagePicked,
  }) async {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 12),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            ListTile(
              leading: const Icon(Icons.photo_library, size: 28),
              title: const Text('Choose from Gallery'),
              onTap: () async {
                Navigator.pop(context);
                final ImagePicker picker = ImagePicker();
                final XFile? image = await picker.pickImage(
                  source: ImageSource.gallery,
                  imageQuality: 80,
                );
                if (image != null) {
                  onImagePicked(File(image.path));
                }
              },
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt, size: 28),
              title: const Text('Take a Picture'),
              onTap: () async {
                Navigator.pop(context);
                final ImagePicker picker = ImagePicker();
                final XFile? image = await picker.pickImage(
                  source: ImageSource.camera,
                  imageQuality: 80,
                );
                if (image != null) {
                  onImagePicked(File(image.path));
                }
              },
            ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }

  // Upload document to Supabase Storage
  Future<String?> _uploadDocumentToSupabase({
    required File file,
    required String userId,
    required String documentType,
  }) async {
    try {
      final fileName =
          '${DateTime.now().millisecondsSinceEpoch}_${userId}_${documentType}.${file.path.split('.').last}';
      final filePath = 'users/$userId/$documentType/$fileName';

      DevLogs.logInfo('📤 Uploading $documentType to storage: $filePath');

      await _supabase.storage
          .from('topics')
          .upload(
            filePath,
            file,
            fileOptions: FileOptions(
              upsert: false,
              contentType: file.path.endsWith('.pdf')
                  ? 'application/pdf'
                  : 'image/jpeg',
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
    await _showImagePickerOptions(
      onImagePicked: (File file) async {
        setState(() {
          _isUploadingNationalId = true;
        });

        final tempId = 'temp_${DateTime.now().millisecondsSinceEpoch}';
        final url = await _uploadDocumentToSupabase(
          file: file,
          userId: tempId,
          documentType: 'national_id',
        );

        if (url != null && mounted) {
          setState(() {
            _nationalIdImageUrl = url;
            _uploadedDocuments.add({
              'type': 'national_id',
              'url': url,
              'file_name': file.path.split('/').last,
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
      },
    );
  }

  // Pick and upload Passport
  Future<void> _pickAndUploadPassport() async {
    await _showImagePickerOptions(
      onImagePicked: (File file) async {
        setState(() {
          _isUploadingPassport = true;
        });

        final tempId = 'temp_${DateTime.now().millisecondsSinceEpoch}';
        final url = await _uploadDocumentToSupabase(
          file: file,
          userId: tempId,
          documentType: 'passport',
        );

        if (url != null && mounted) {
          setState(() {
            _passportImageUrl = url;
            _uploadedDocuments.add({
              'type': 'passport',
              'url': url,
              'file_name': file.path.split('/').last,
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
      },
    );
  }

  // Pick and upload Profile Picture with ID for verification
  Future<void> _pickAndUploadProfilePicWithId() async {
    await _showImagePickerOptions(
      onImagePicked: (File file) async {
        setState(() {
          _isUploadingProfile = true;
        });

        final tempId = 'temp_${DateTime.now().millisecondsSinceEpoch}';
        final url = await _uploadDocumentToSupabase(
          file: file,
          userId: tempId,
          documentType: 'profile_with_id',
        );

        if (url != null && mounted) {
          setState(() {
            _profilePicUrl = url;
            _profilePictureError = null;
            _uploadedDocuments.add({
              'type': 'profile_with_id',
              'url': url,
              'file_name': file.path.split('/').last,
              'mime_type': 'image/jpeg',
              'notes': 'Profile picture with ID uploaded during registration',
            });
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
      },
    );
  }

  // Pick and upload Proof of Address (supports images and PDFs)
  Future<void> _pickAndUploadProofOfAddress() async {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 12),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            ListTile(
              leading: const Icon(Icons.image, size: 28),
              title: const Text('Upload Image'),
              onTap: () async {
                Navigator.pop(context);
                final ImagePicker picker = ImagePicker();
                final XFile? image = await picker.pickImage(
                  source: ImageSource.gallery,
                  imageQuality: 80,
                );
                if (image != null) {
                  await _uploadProofOfAddress(File(image.path));
                }
              },
            ),
            ListTile(
              leading: const Icon(Icons.picture_as_pdf, size: 28),
              title: const Text('Upload PDF'),
              onTap: () async {
                Navigator.pop(context);
                final ImagePicker picker = ImagePicker();
                final XFile? file = await picker.pickImage(
                  source: ImageSource.gallery,
                );
                if (file != null) {
                  await _uploadProofOfAddress(File(file.path));
                }
              },
            ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }

  Future<void> _uploadProofOfAddress(File file) async {
    setState(() {
      _isUploadingProofOfAddress = true;
    });

    final tempId = 'temp_${DateTime.now().millisecondsSinceEpoch}';
    final url = await _uploadDocumentToSupabase(
      file: file,
      userId: tempId,
      documentType: 'proof_of_address',
    );

    if (url != null && mounted) {
      setState(() {
        _proofOfAddressUrl = url;
        _uploadedDocuments.add({
          'type': 'proof_of_address',
          'url': url,
          'file_name': file.path.split('/').last,
          'mime_type': file.path.endsWith('.pdf')
              ? 'application/pdf'
              : 'image/jpeg',
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

  Future<void> _submitForm() async {
    if (!_acceptTerms) {
      showErrorDialog('Please accept the terms and conditions');
      return;
    }

    // Validate profile picture
    if (_profilePicUrl == null) {
      showErrorDialog(
        'Please upload a profile picture showing your face holding your National ID/Passport',
      );
      return;
    }

    // Validate age (must be at least 21 years)
    if (dateOfBirthController.text.isNotEmpty) {
      final DateTime dob = DateTime.parse(dateOfBirthController.text);
      final DateTime today = DateTime.now();
      int age = today.year - dob.year;
      if (today.month < dob.month ||
          (today.month == dob.month && today.day < dob.day)) {
        age--;
      }

      if (age < 21) {
        showErrorDialog('You must be at least 21 years old to register');
        return;
      }
    } else {
      showErrorDialog('Please enter your date of birth');
      return;
    }

    // Validate gender
    if (_selectedGender == null) {
      showErrorDialog('Please select your gender');
      return;
    }

    // Validate phone number (required)
    if (phoneController.text.isEmpty) {
      showErrorDialog('Phone number is required');
      return;
    }

    // Validate home address
    if (homeAddressController.text.trim().isEmpty) {
      showErrorDialog('Home address is required');
      return;
    }

    // Validate state and city
    if (selectedState == null || selectedState!.isEmpty) {
      showErrorDialog('Please select your state/province');
      return;
    }
    if (selectedCity == null || selectedCity!.isEmpty) {
      showErrorDialog('Please select your city');
      return;
    }

    // Validate Next of Kin (required)
    if (nextOfKinNameController.text.trim().isEmpty) {
      showErrorDialog('Next of kin name is required');
      return;
    }
    if (nextOfKinRelationshipController.text.trim().isEmpty) {
      showErrorDialog('Next of kin relationship is required');
      return;
    }
    if (nextOfKinAddressController.text.trim().isEmpty) {
      showErrorDialog('Next of kin address is required');
      return;
    }

    // Final validation before submission
    if (!_isFormValid) {
      showErrorDialog('Please fix all validation errors before submitting');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Parse passport expiry date if provided
      DateTime? parsedPassportExpiryDate;
      if (passportExpiryDateController.text.isNotEmpty) {
        parsedPassportExpiryDate = DateTime.tryParse(
          passportExpiryDateController.text,
        );
      }

      // Build full address with state, city, and home address
      final String fullAddress =
          '${homeAddressController.text.trim()}, $selectedCity, $selectedState, Zimbabwe';

      final success = await RegisterHelper.validateRegisterForm(
        firstName: firstNameController.text.trim(),
        lastName: lastNameController.text.trim(),
        email: emailController.text.trim(),
        password: passwordController.text,
        confirmPassword: confirmPasswordController.text,
        phone: phoneController.text.trim(),
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
        dateOfBirth: dateOfBirthController.text.trim(),
        address: fullAddress,
        location: selectedCity,
        gender: _selectedGender,
        maritalStatus: _selectedMaritalStatus,
        passportExpiryDate: parsedPassportExpiryDate,
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
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'First name is required';
                            }
                            if (value.trim().length < 2) {
                              return 'First name must be at least 2 characters';
                            }
                            return null;
                          },
                          autoValidate: true,
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
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Last name is required';
                            }
                            if (value.trim().length < 2) {
                              return 'Last name must be at least 2 characters';
                            }
                            return null;
                          },
                          autoValidate: true,
                        )
                        .animate()
                        .fadeIn(duration: 600.ms, delay: 500.ms)
                        .slideY(begin: 0.3),

                    const SizedBox(height: 16),

                    // Email Field with real-time validation
                    CustomTextField(
                          controller: emailController,
                          labelText: 'Email Address',
                          focusedBorderColor: AppColors.primaryColor,
                          errorBorderColor: Colors.red.shade700,
                          prefixIcon: Icon(
                            Icons.email_outlined,
                            color: AppColors.subtextColor,
                          ),
                          keyboardType: TextInputType.emailAddress,
                          validator: (value) =>
                              RegisterHelper.getEmailError(value ?? ''),
                          autoValidate: true,
                          initialErrorText: _emailError,
                        )
                        .animate()
                        .fadeIn(duration: 600.ms, delay: 600.ms)
                        .slideY(begin: 0.3),

                    const SizedBox(height: 16),

                    // Phone Field (Required)
                    CustomTextField(
                          controller: phoneController,
                          labelText: 'Phone Number *',
                          focusedBorderColor: AppColors.primaryColor,
                          errorBorderColor: Colors.red.shade700,
                          prefixIcon: Icon(
                            Icons.phone_outlined,
                            color: AppColors.subtextColor,
                          ),
                          keyboardType: TextInputType.phone,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Phone number is required';
                            }
                            return RegisterHelper.getPhoneError(value);
                          },
                          autoValidate: true,
                          initialErrorText: _phoneError,
                        )
                        .animate()
                        .fadeIn(duration: 600.ms, delay: 700.ms)
                        .slideY(begin: 0.3),

                    const SizedBox(height: 16),

                    // Alternative Phone Field (Optional)
                    CustomTextField(
                          controller: alternativePhoneController,
                          labelText: 'Alternative Phone Number (Optional)',
                          focusedBorderColor: AppColors.primaryColor,
                          errorBorderColor: Colors.red.shade700,
                          prefixIcon: Icon(
                            Icons.phone_android_outlined,
                            color: AppColors.subtextColor,
                          ),
                          keyboardType: TextInputType.phone,
                          validator: (value) {
                            if (value != null && value.isNotEmpty) {
                              return RegisterHelper.getPhoneError(value);
                            }
                            return null;
                          },
                          autoValidate: true,
                          initialErrorText: _alternativePhoneError,
                        )
                        .animate()
                        .fadeIn(duration: 600.ms, delay: 750.ms)
                        .slideY(begin: 0.3),

                    const SizedBox(height: 24),

                    // Gender Dropdown (Male/Female only)
                    Container(
                          decoration: BoxDecoration(
                            border: Border.all(color: AppColors.borderColor),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          child: DropdownButtonFormField<String>(
                            value: _selectedGender,
                            hint: Text(
                              'Select Gender *',
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
                            validator: (value) {
                              if (value == null) {
                                return 'Gender is required';
                              }
                              return null;
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
                            border: Border.all(color: AppColors.borderColor),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: const EdgeInsets.symmetric(horizontal: 12),
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
                            items: _maritalStatusOptions.map((String status) {
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
                                _validateNationalId();
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
                            labelText: 'National ID Number *',
                            focusedBorderColor: AppColors.primaryColor,
                            errorBorderColor: Colors.red.shade700,
                            prefixIcon: Icon(
                              Icons.badge_outlined,
                              color: AppColors.subtextColor,
                            ),
                            validator: (value) =>
                                RegisterHelper.getNationalIdError(value ?? ''),
                            autoValidate: true,
                            initialErrorText: _nationalIdError,
                          )
                          .animate()
                          .fadeIn(duration: 600.ms, delay: 950.ms)
                          .slideY(begin: 0.3)
                    else
                      CustomTextField(
                            controller: passportNumberController,
                            labelText: 'Passport Number *',
                            focusedBorderColor: AppColors.primaryColor,
                            prefixIcon: Icon(
                              Icons.airplane_ticket_outlined,
                              color: AppColors.subtextColor,
                            ),
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'Passport number is required';
                              }
                              if (value.trim().length < 6) {
                                return 'Please enter a valid passport number';
                              }
                              return null;
                            },
                            autoValidate: true,
                          )
                          .animate()
                          .fadeIn(duration: 600.ms, delay: 950.ms)
                          .slideY(begin: 0.3),

                    const SizedBox(height: 16),

                    // Upload Document Button (National ID or Passport)
                    if (_identificationType == 'national_id')
                      Column(
                        children: [
                          _buildUploadButton(
                            label: 'Upload National ID Image *',
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
                            label: 'Upload Passport Image *',
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
                          const SizedBox(height: 16),
                          // Passport Expiry Date (only for passport)
                          GestureDetector(
                            onTap: () =>
                                _selectDate(passportExpiryDateController),
                            child: AbsorbPointer(
                              child: CustomTextField(
                                controller: passportExpiryDateController,
                                labelText: 'Passport Expiry Date *',
                                focusedBorderColor: AppColors.primaryColor,
                                prefixIcon: Icon(
                                  Icons.calendar_today_outlined,
                                  color: AppColors.subtextColor,
                                ),
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Passport expiry date is required';
                                  }
                                  try {
                                    final expiryDate = DateTime.parse(value);
                                    if (expiryDate.isBefore(DateTime.now())) {
                                      return 'Passport has expired';
                                    }
                                  } catch (e) {
                                    return 'Invalid date format';
                                  }
                                  return null;
                                },
                                autoValidate: true,
                              ),
                            ),
                          ),
                        ],
                      ),

                    const SizedBox(height: 16),

                    // Profile Picture Upload with verification text
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Profile Verification Photo *',
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textColor,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Please take a clear photo of yourself holding your National ID/Passport next to your face',
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            color: AppColors.subtextColor,
                          ),
                        ),
                        const SizedBox(height: 8),
                        _buildUploadButton(
                          label: 'Upload Photo with ID',
                          isUploading: _isUploadingProfile,
                          onTap: _pickAndUploadProfilePicWithId,
                          hasFile: _profilePicUrl != null,
                        ),
                        if (_profilePictureError != null)
                          Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: Text(
                              _profilePictureError!,
                              style: GoogleFonts.poppins(
                                fontSize: 12,
                                color: Colors.red.shade700,
                              ),
                            ),
                          ),
                        if (_profilePicUrl != null)
                          Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: Text(
                              '✓ Verification photo uploaded',
                              style: GoogleFonts.poppins(
                                fontSize: 12,
                                color: AppColors.successColor,
                              ),
                            ),
                          ),
                      ],
                    ),

                    const SizedBox(height: 16),

                    // Proof of Address Upload (supports documents)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Proof of Residence (Optional)',
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textColor,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Upload a utility bill, bank statement, or official letter (JPG, PNG, or PDF)',
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            color: AppColors.subtextColor,
                          ),
                        ),
                        const SizedBox(height: 8),
                        _buildUploadButton(
                          label: 'Upload Document',
                          isUploading: _isUploadingProofOfAddress,
                          onTap: _pickAndUploadProofOfAddress,
                          hasFile: _proofOfAddressUrl != null,
                        ),
                        if (_proofOfAddressUrl != null)
                          Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: Text(
                              '✓ Document uploaded',
                              style: GoogleFonts.poppins(
                                fontSize: 12,
                                color: AppColors.successColor,
                              ),
                            ),
                          ),
                      ],
                    ),

                    const SizedBox(height: 16),

                    // Date of Birth Field
                    GestureDetector(
                          onTap: _selectDateOfBirth,
                          child: AbsorbPointer(
                            child: CustomTextField(
                              controller: dateOfBirthController,
                              labelText: 'Date of Birth (Must be 21+ years) *',
                              focusedBorderColor: AppColors.primaryColor,
                              prefixIcon: Icon(
                                Icons.calendar_today_outlined,
                                color: AppColors.subtextColor,
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Date of birth is required';
                                }
                                try {
                                  final dob = DateTime.parse(value);
                                  final now = DateTime.now();
                                  int age = now.year - dob.year;
                                  if (now.month < dob.month ||
                                      (now.month == dob.month &&
                                          now.day < dob.day)) {
                                    age--;
                                  }
                                  if (age < 21) {
                                    return 'You must be at least 21 years old';
                                  }
                                  if (age > 100) {
                                    return 'Please enter a valid date of birth';
                                  }
                                } catch (e) {
                                  return 'Please enter a valid date (YYYY-MM-DD)';
                                }
                                return null;
                              },
                              autoValidate: true,
                            ),
                          ),
                        )
                        .animate()
                        .fadeIn(duration: 600.ms, delay: 1150.ms)
                        .slideY(begin: 0.3),

                    const SizedBox(height: 16),

                    // Address Section using CSC Picker
                    Text(
                      'Address Information *',
                      style: GoogleFonts.poppins(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textColor,
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Country is always Zimbabwe
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        border: Border.all(color: AppColors.borderColor),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.public, color: AppColors.subtextColor),
                          const SizedBox(width: 12),
                          Text(
                            'Country: Zimbabwe',
                            style: GoogleFonts.poppins(
                              fontSize: 14,
                              color: AppColors.textColor,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 12),

                    // CSC Picker for State and City
                    CSCPickerPlus(

                      showStates: true,
                      showCities: true,

                      dropdownDecoration: BoxDecoration(
                        border: Border.all(color: AppColors.borderColor),
                        borderRadius: BorderRadius.circular(12),
                      ),

                      disabledDropdownDecoration: BoxDecoration(
                        border: Border.all(color: AppColors.borderColor),
                        borderRadius: BorderRadius.circular(12),
                      ),

                      defaultCountry: CscCountry.Zimbabwe,
                      onStateChanged: (value) {
                        setState(() {
                          selectedState = value;
                          selectedCity = null;
                        });
                      },

                      onCityChanged: (value) {
                        setState(() {
                          selectedCity = value;
                        });
                      },

                      layout: Layout.vertical,

                      stateDropdownLabel: "State/Province *",
                      cityDropdownLabel: "City *",

                      dropdownHeadingStyle: TextStyle(
                        color: AppColors.primaryColor,
                        fontSize: 14,
                      ),
                    ),

                    const SizedBox(height: 12),

                    // Home Address Field
                    CustomTextField(
                          controller: homeAddressController,
                          labelText: 'Home Address *',
                          focusedBorderColor: AppColors.primaryColor,
                          errorBorderColor: Colors.red.shade700,
                          prefixIcon: Icon(
                            Icons.home_outlined,
                            color: AppColors.subtextColor,
                          ),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Home address is required';
                            }
                            if (value.trim().length < 5) {
                              return 'Please enter a valid home address';
                            }
                            return null;
                          },
                          autoValidate: true,
                          initialErrorText: _homeAddressError,
                        )
                        .animate()
                        .fadeIn(duration: 600.ms, delay: 1250.ms)
                        .slideY(begin: 0.3),

                    const SizedBox(height: 24),

                    // Employment Section
                    Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            border: Border.all(color: AppColors.borderColor),
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
                                  labelText: 'Employer Name *',
                                  focusedBorderColor: AppColors.primaryColor,
                                  prefixIcon: Icon(
                                    Icons.business_outlined,
                                    color: AppColors.subtextColor,
                                  ),
                                  validator: (value) {
                                    if (_isEmployed &&
                                        (value == null ||
                                            value.trim().isEmpty)) {
                                      return 'Employer name is required';
                                    }
                                    return null;
                                  },
                                  autoValidate: true,
                                ),
                                const SizedBox(height: 12),
                                CustomTextField(
                                  controller: jobTitleController,
                                  labelText: 'Job Title *',
                                  focusedBorderColor: AppColors.primaryColor,
                                  prefixIcon: Icon(
                                    Icons.work_outline,
                                    color: AppColors.subtextColor,
                                  ),
                                  validator: (value) {
                                    if (_isEmployed &&
                                        (value == null ||
                                            value.trim().isEmpty)) {
                                      return 'Job title is required';
                                    }
                                    return null;
                                  },
                                  autoValidate: true,
                                ),
                                const SizedBox(height: 12),
                                CustomTextField(
                                  controller: employmentDurationController,
                                  labelText: 'Duration (e.g., 2 years) *',
                                  focusedBorderColor: AppColors.primaryColor,
                                  prefixIcon: Icon(
                                    Icons.timer_outlined,
                                    color: AppColors.subtextColor,
                                  ),
                                  validator: (value) {
                                    if (_isEmployed &&
                                        (value == null ||
                                            value.trim().isEmpty)) {
                                      return 'Employment duration is required';
                                    }
                                    return null;
                                  },
                                  autoValidate: true,
                                ),
                                const SizedBox(height: 12),
                                CustomTextField(
                                  controller: employmentLocationController,
                                  labelText: 'Work Location (Optional)',
                                  focusedBorderColor: AppColors.primaryColor,
                                  prefixIcon: Icon(
                                    Icons.location_city_outlined,
                                    color: AppColors.subtextColor,
                                  ),
                                ),
                                const SizedBox(height: 12),
                                CustomTextField(
                                  controller: employmentContactsController,
                                  labelText: 'Work Contacts (Optional)',
                                  focusedBorderColor: AppColors.primaryColor,
                                  errorBorderColor: Colors.red.shade700,
                                  prefixIcon: Icon(
                                    Icons.contact_phone_outlined,
                                    color: AppColors.subtextColor,
                                  ),
                                  validator: (value) {
                                    if (_isEmployed &&
                                        value != null &&
                                        value.isNotEmpty) {
                                      return RegisterHelper.getPhoneError(
                                        value,
                                      );
                                    }
                                    return null;
                                  },
                                  autoValidate: true,
                                  initialErrorText: _employmentContactError,
                                ),
                              ],
                            ],
                          ),
                        )
                        .animate()
                        .fadeIn(duration: 600.ms, delay: 1300.ms)
                        .slideY(begin: 0.3),

                    const SizedBox(height: 16),

                    // Next of Kin Section (Required - always shown)
                    Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            border: Border.all(color: AppColors.borderColor),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Next of Kin Information *',
                                style: GoogleFonts.poppins(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.textColor,
                                ),
                              ),
                              const SizedBox(height: 12),
                              CustomTextField(
                                controller: nextOfKinNameController,
                                labelText: 'Full Name *',
                                focusedBorderColor: AppColors.primaryColor,
                                errorBorderColor: Colors.red.shade700,
                                prefixIcon: Icon(
                                  Icons.person_outline,
                                  color: AppColors.subtextColor,
                                ),
                                validator: (value) {
                                  if (value == null || value.trim().isEmpty) {
                                    return 'Next of kin name is required';
                                  }
                                  if (value.trim().length < 2) {
                                    return 'Name must be at least 2 characters';
                                  }
                                  return null;
                                },
                                autoValidate: true,
                                initialErrorText: _nextOfKinNameError,
                              ),
                              const SizedBox(height: 12),
                              CustomTextField(
                                controller: nextOfKinRelationshipController,
                                labelText: 'Relationship *',
                                focusedBorderColor: AppColors.primaryColor,
                                errorBorderColor: Colors.red.shade700,
                                prefixIcon: Icon(
                                  Icons.family_restroom_outlined,
                                  color: AppColors.subtextColor,
                                ),
                                validator: (value) {
                                  if (value == null || value.trim().isEmpty) {
                                    return 'Relationship is required';
                                  }
                                  return null;
                                },
                                autoValidate: true,
                                initialErrorText: _nextOfKinRelationshipError,
                              ),
                              const SizedBox(height: 12),
                              CustomTextField(
                                controller: nextOfKinPhoneController,
                                labelText: 'Phone Number (Optional)',
                                focusedBorderColor: AppColors.primaryColor,
                                errorBorderColor: Colors.red.shade700,
                                prefixIcon: Icon(
                                  Icons.phone_outlined,
                                  color: AppColors.subtextColor,
                                ),
                                keyboardType: TextInputType.phone,
                                validator: (value) {
                                  if (value != null && value.isNotEmpty) {
                                    return RegisterHelper.getPhoneError(value);
                                  }
                                  return null;
                                },
                                autoValidate: true,
                                initialErrorText: _nextOfKinPhoneError,
                              ),
                              const SizedBox(height: 12),
                              CustomTextField(
                                controller: nextOfKinEmailController,
                                labelText: 'Email (Optional)',
                                focusedBorderColor: AppColors.primaryColor,
                                errorBorderColor: Colors.red.shade700,
                                prefixIcon: Icon(
                                  Icons.email_outlined,
                                  color: AppColors.subtextColor,
                                ),
                                keyboardType: TextInputType.emailAddress,
                                validator: (value) {
                                  if (value != null && value.isNotEmpty) {
                                    return RegisterHelper.getEmailError(value);
                                  }
                                  return null;
                                },
                                autoValidate: true,
                                initialErrorText: _nextOfKinEmailError,
                              ),
                              const SizedBox(height: 12),
                              CustomTextField(
                                controller: nextOfKinAddressController,
                                labelText: 'Address *',
                                focusedBorderColor: AppColors.primaryColor,
                                errorBorderColor: Colors.red.shade700,
                                prefixIcon: Icon(
                                  Icons.location_on_outlined,
                                  color: AppColors.subtextColor,
                                ),
                                validator: (value) {
                                  if (value == null || value.trim().isEmpty) {
                                    return 'Next of kin address is required';
                                  }
                                  return null;
                                },
                                autoValidate: true,
                              ),
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

                    // Password Field with real-time validation
                    CustomPasswordTextfield(
                          controller: passwordController,
                          obscureText: true,
                          labelText: 'Password',
                          prefixIcon: Icon(
                            Icons.lock_outline,
                            color: AppColors.subtextColor,
                          ),
                          validator: (value) =>
                              RegisterHelper.getPasswordError(value ?? ''),
                          autoValidate: true,
                          initialErrorText: _passwordError,
                        )
                        .animate()
                        .fadeIn(duration: 600.ms, delay: 1450.ms)
                        .slideY(begin: 0.3),

                    const SizedBox(height: 16),

                    // Confirm Password Field with real-time validation
                    CustomPasswordTextfield(
                          controller: confirmPasswordController,
                          obscureText: true,
                          labelText: 'Confirm Password',
                          prefixIcon: Icon(
                            Icons.lock_outline,
                            color: AppColors.subtextColor,
                          ),
                          validator: (value) =>
                              RegisterHelper.getConfirmPasswordError(
                                passwordController.text,
                                value ?? '',
                              ),
                          autoValidate: true,
                          initialErrorText: _confirmPasswordError,
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
                                onTap: () =>
                                    Get.to(() => const TermsOfServiceScreen()),
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
                                onTap: () =>
                                    Get.to(() => const PrivacyPolicyScreen()),
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
                            color: _isFormValid && !_isLoading
                                ? AppColors.primaryColor
                                : AppColors.primaryColor.withOpacity(0.5),
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
                              onTap: (_isFormValid && !_isLoading)
                                  ? _submitForm
                                  : null,
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
              ).animate().fadeIn(duration: 800.ms, delay: 300.ms).scale(begin: const Offset(0.95, 0.95)),

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
