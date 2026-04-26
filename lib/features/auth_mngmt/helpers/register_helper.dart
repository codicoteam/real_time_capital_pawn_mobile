import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:real_time_pawn/config/routers/router.dart';
import 'package:real_time_pawn/core/utils/pallete.dart';
import 'package:real_time_pawn/widgets/loading_widgets/circular_loader.dart';
import '../../../models/register_body_model.dart';
import '../controllers/auth_controller.dart';

class RegisterHelper {
  static final AuthController _authController = Get.find<AuthController>();

  // Validation helpers (made public for real-time validation)
  static bool hasUppercase(String value) => value.contains(RegExp(r'[A-Z]'));
  static bool hasLowercase(String value) => value.contains(RegExp(r'[a-z]'));
  static bool hasNumber(String value) => value.contains(RegExp(r'[0-9]'));
  static bool hasSpecialChar(String value) =>
      value.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'));

  // Password strength getter
  static int getPasswordStrength(String password) {
    int strength = 0;
    if (password.length >= 8) strength++;
    if (hasUppercase(password)) strength++;
    if (hasLowercase(password)) strength++;
    if (hasNumber(password)) strength++;
    if (hasSpecialChar(password)) strength++;
    return strength;
  }

  // Zimbabwe phone validation (public for real-time validation)
  static bool isValidZimbabwePhone(String phone) {
    if (phone.isEmpty) return true; // Optional field
    final phoneRegExp = RegExp(r'^(\+263|0)[0-9]{9}$');
    return phoneRegExp.hasMatch(phone);
  }

  // Zimbabwe National ID validation (public for real-time validation)
  static bool isValidNationalId(String id) {
    if (id.isEmpty) return false;
    final idRegExp = RegExp(r'^\d{2}-\d{6,8}[A-Z]\d{2}$');
    return idRegExp.hasMatch(id.toUpperCase());
  }

  // Email validation (public for real-time validation)
  static bool isValidEmail(String email) {
    if (email.isEmpty) return false;
    final emailRegExp = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );
    return emailRegExp.hasMatch(email);
  }

  // Get email validation error message
  static String? getEmailError(String email) {
    if (email.isEmpty) return 'Email is required';
    if (!isValidEmail(email.trim()))
      return 'Please enter a valid email address';
    return null;
  }

  // Get phone validation error message
  static String? getPhoneError(String phone) {
    if (phone.isEmpty) return null; // Optional field
    if (!isValidZimbabwePhone(phone.trim())) {
      return 'Enter valid Zim number (e.g., +263771234567 or 0771234567)';
    }
    return null;
  }

  // Get national ID validation error message
  static String? getNationalIdError(String nationalId) {
    if (nationalId.isEmpty) return 'National ID is required';
    if (!isValidNationalId(nationalId.trim())) {
      return 'Enter valid ID (e.g., 63-1234567A12 or 63-12345678A12)';
    }
    return null;
  }

  // Get password validation error message
  static String? getPasswordError(String password) {
    if (password.isEmpty) return 'Password is required';
    if (password.length < 8) return 'Password must be at least 8 characters';
    if (!hasUppercase(password)) return 'Include at least one uppercase letter';
    if (!hasLowercase(password)) return 'Include at least one lowercase letter';
    if (!hasNumber(password)) return 'Include at least one number';
    return null;
  }

  // Get confirm password validation error message
  static String? getConfirmPasswordError(
    String password,
    String confirmPassword,
  ) {
    if (confirmPassword.isEmpty) return 'Please confirm your password';
    if (password != confirmPassword) return 'Passwords do not match';
    return null;
  }

  static void _clearErrors() {
    // Implement if using reactive error states
  }

  static void _showValidationError(String message, String field) {
    Get.snackbar(
      'Validation Error',
      message,
      backgroundColor: Colors.red[50],
      colorText: Colors.red[700],
      icon: Icon(Icons.error_outline, color: Colors.red[700]),
      snackPosition: SnackPosition.TOP,
      duration: 3.seconds,
      margin: const EdgeInsets.all(16),
      borderRadius: 12,
      isDismissible: true,
      dismissDirection: DismissDirection.horizontal,
      forwardAnimationCurve: Curves.easeOutCubic,
    );
  }

  static void _showShakeAnimation() {
    // This would be handled in the UI layer
  }

  /// LOGIN VALIDATION + SUBMISSION
  static Future<bool> validateAndSubmitForm({
    required String email,
    required String password,
  }) async {
    _clearErrors();

    bool isValid = true;

    if (email.isEmpty) {
      _showValidationError('Email is required', 'email');
      isValid = false;
    } else if (!isValidEmail(email.trim())) {
      _showValidationError('Please enter a valid email address', 'email');
      isValid = false;
    }

    if (password.isEmpty) {
      _showValidationError('Password is required', 'password');
      isValid = false;
    } else if (password.length < 8) {
      _showValidationError(
        'Password must be at least 8 characters',
        'password',
      );
      isValid = false;
    } else if (!hasUppercase(password)) {
      _showValidationError('Include at least one uppercase letter', 'password');
      isValid = false;
    } else if (!hasLowercase(password)) {
      _showValidationError('Include at least one lowercase letter', 'password');
      isValid = false;
    } else if (!hasNumber(password)) {
      _showValidationError('Include at least one number', 'password');
      isValid = false;
    }

    if (!isValid) {
      _showShakeAnimation();
      return false;
    }

    try {
      Get.dialog(
        const CustomLoader(message: 'Signing in...'),
        barrierDismissible: false,
      );

      final success = await _authController.authSignInRequest(
        emailAddress: email,
        password: password,
      );

      if (Get.isDialogOpen ?? false) {
        Get.back();
      }

      if (success) {
        _showSuccessAnimation();
        Get.offNamed(RoutesHelper.main_home_page);
        return true;
      } else {
        _showErrorDialog(_authController.errorMessage.value);
        return false;
      }
    } catch (e) {
      if (Get.isDialogOpen ?? false) {
        Get.back();
      }
      _showErrorDialog('An error occurred during login: ${e.toString()}');
      return false;
    }
  }

  static void _showTermsError() {
    Get.snackbar(
      'Terms & Conditions',
      'Please accept the terms and conditions to continue',
      backgroundColor: Colors.red[50],
      colorText: Colors.red[700],
      icon: Icon(Icons.error_outline, color: Colors.red[700]),
      snackPosition: SnackPosition.TOP,
      duration: 3.seconds,
      margin: const EdgeInsets.all(16),
      borderRadius: 12,
      isDismissible: true,
    );
  }

  /// REGISTER SUBMISSION - With comprehensive validation
  static Future<bool> validateRegisterForm({
    required String firstName,
    required String lastName,
    required String email,
    required String password,
    required String confirmPassword,
    String? phone,
    String? alternativePhone,
    String? identificationType,
    String? nationalIdNumber,
    String? passportNumber,
    DateTime? passportExpiryDate,
    DateTime? nationalIdExpiryDate,
    DateTime? drivingLicenseExpiryDate,
    String? nationalIdImageUrl,
    String? passportImageUrl,
    String? profilePicUrl,
    String? proofOfAddressUrl,
    String? dateOfBirth,
    String? address,
    String? location,
    String? gender,
    String? maritalStatus,
    bool isEmployed = false,
    String? employerName,
    String? jobTitle,
    String? employmentDuration,
    String? employmentLocation,
    String? employmentContacts,
    String? nextOfKinFullName,
    String? nextOfKinRelationship,
    String? nextOfKinPhone,
    String? nextOfKinEmail,
    String? nextOfKinAddress,
    List<Map<String, dynamic>>? documents,
    bool acceptTerms = true,
  }) async {
    _clearErrors();
    bool isValid = true;

    // First Name Validation
    if (firstName.isEmpty) {
      _showValidationError('First name is required', 'firstName');
      isValid = false;
    } else if (firstName.trim().length < 2) {
      _showValidationError(
        'First name must be at least 2 characters',
        'firstName',
      );
      isValid = false;
    }

    // Last Name Validation
    if (lastName.isEmpty) {
      _showValidationError('Last name is required', 'lastName');
      isValid = false;
    } else if (lastName.trim().length < 2) {
      _showValidationError(
        'Last name must be at least 2 characters',
        'lastName',
      );
      isValid = false;
    }

    // Email Validation
    if (email.isEmpty) {
      _showValidationError('Email is required', 'email');
      isValid = false;
    } else if (!isValidEmail(email.trim())) {
      _showValidationError('Please enter a valid email address', 'email');
      isValid = false;
    }

    // Phone Validation (Optional but validate if provided)
    if (phone != null && phone.isNotEmpty) {
      if (!isValidZimbabwePhone(phone.trim())) {
        _showValidationError(
          'Please enter a valid Zimbabwe phone number (e.g., +263771234567 or 0771234567)',
          'phone',
        );
        isValid = false;
      }
    }

    // Alternative Phone Validation (Optional but validate if provided)
    if (alternativePhone != null && alternativePhone.isNotEmpty) {
      if (!isValidZimbabwePhone(alternativePhone.trim())) {
        _showValidationError(
          'Please enter a valid alternative phone number (e.g., +263771234567 or 0771234567)',
          'alternativePhone',
        );
        isValid = false;
      }
    }

    // Identification Type Validation
    if (identificationType == null || identificationType.isEmpty) {
      _showValidationError(
        'Please select identification type',
        'identificationType',
      );
      isValid = false;
    } else if (identificationType == 'national_id') {
      // National ID Validation
      if (nationalIdNumber == null || nationalIdNumber.isEmpty) {
        _showValidationError(
          'National ID number is required',
          'nationalIdNumber',
        );
        isValid = false;
      } else if (!isValidNationalId(nationalIdNumber.trim())) {
        _showValidationError(
          'Please enter a valid Zimbabwe National ID (e.g., 63-1234567A12 or 63-12345678A12)',
          'nationalIdNumber',
        );
        isValid = false;
      }

      // National ID Expiry Date Validation (if provided)
      if (nationalIdExpiryDate != null &&
          nationalIdExpiryDate.isBefore(DateTime.now())) {
        _showValidationError('National ID has expired', 'nationalIdExpiryDate');
        isValid = false;
      }

      // National ID Image Validation
      if (nationalIdImageUrl == null || nationalIdImageUrl.isEmpty) {
        _showValidationError(
          'Please upload National ID image',
          'nationalIdImageUrl',
        );
        isValid = false;
      }
    } else if (identificationType == 'passport') {
      // Passport Validation
      if (passportNumber == null || passportNumber.isEmpty) {
        _showValidationError('Passport number is required', 'passportNumber');
        isValid = false;
      } else if (passportNumber.trim().length < 6) {
        _showValidationError(
          'Please enter a valid passport number',
          'passportNumber',
        );
        isValid = false;
      }

      // Passport Expiry Date Validation
      if (passportExpiryDate == null) {
        _showValidationError(
          'Passport expiry date is required',
          'passportExpiryDate',
        );
        isValid = false;
      } else if (passportExpiryDate.isBefore(DateTime.now())) {
        _showValidationError('Passport has expired', 'passportExpiryDate');
        isValid = false;
      }

      // Passport Image Validation
      if (passportImageUrl == null || passportImageUrl.isEmpty) {
        _showValidationError(
          'Please upload passport image',
          'passportImageUrl',
        );
        isValid = false;
      }
    }

    // Driving License Expiry Date Validation (if provided)
    if (drivingLicenseExpiryDate != null &&
        drivingLicenseExpiryDate.isBefore(DateTime.now())) {
      _showValidationError(
        'Driving license has expired',
        'drivingLicenseExpiryDate',
      );
      isValid = false;
    }

    // Password Validation
    if (password.isEmpty) {
      _showValidationError('Password is required', 'password');
      isValid = false;
    } else if (password.length < 8) {
      _showValidationError(
        'Password must be at least 8 characters',
        'password',
      );
      isValid = false;
    } else if (!hasUppercase(password)) {
      _showValidationError('Include at least one uppercase letter', 'password');
      isValid = false;
    } else if (!hasLowercase(password)) {
      _showValidationError('Include at least one lowercase letter', 'password');
      isValid = false;
    } else if (!hasNumber(password)) {
      _showValidationError('Include at least one number', 'password');
      isValid = false;
    }

    // Confirm Password Validation
    if (confirmPassword.isEmpty) {
      _showValidationError('Please confirm your password', 'confirmPassword');
      isValid = false;
    } else if (password != confirmPassword) {
      _showValidationError('Passwords do not match', 'confirmPassword');
      isValid = false;
    }

    // Date of Birth Validation
    if (dateOfBirth == null || dateOfBirth.isEmpty) {
      _showValidationError('Date of birth is required', 'dateOfBirth');
      isValid = false;
    } else {
      try {
        final dob = DateTime.parse(dateOfBirth);
        final now = DateTime.now();
        final age = now.year - dob.year;

        if (dob.isAfter(now)) {
          _showValidationError(
            'Date of birth cannot be in the future',
            'dateOfBirth',
          );
          isValid = false;
        } else if (age < 18) {
          _showValidationError(
            'You must be at least 18 years old',
            'dateOfBirth',
          );
          isValid = false;
        } else if (age > 100) {
          _showValidationError(
            'Please enter a valid date of birth',
            'dateOfBirth',
          );
          isValid = false;
        }
      } catch (e) {
        _showValidationError(
          'Please enter a valid date (YYYY-MM-DD)',
          'dateOfBirth',
        );
        isValid = false;
      }
    }

    // Gender Validation (Optional but recommended)
    if (gender != null && gender.isNotEmpty) {
      final validGenders = ['Male', 'Female', 'Other', 'Prefer not to say'];
      if (!validGenders.contains(gender)) {
        _showValidationError('Please select a valid gender option', 'gender');
        isValid = false;
      }
    }

    // Marital Status Validation (Optional but recommended)
    if (maritalStatus != null && maritalStatus.isNotEmpty) {
      final validStatuses = [
        'Single',
        'Married',
        'Divorced',
        'Widowed',
        'Separated',
        'Prefer not to say',
      ];
      if (!validStatuses.contains(maritalStatus)) {
        _showValidationError(
          'Please select a valid marital status',
          'maritalStatus',
        );
        isValid = false;
      }
    }

    // Employment Validation - if employed, employment details required
    if (isEmployed) {
      if (employerName == null || employerName.isEmpty) {
        _showValidationError('Employer name is required', 'employerName');
        isValid = false;
      } else if (employerName.trim().length < 2) {
        _showValidationError(
          'Please enter a valid employer name',
          'employerName',
        );
        isValid = false;
      }

      if (jobTitle == null || jobTitle.isEmpty) {
        _showValidationError('Job title is required', 'jobTitle');
        isValid = false;
      } else if (jobTitle.trim().length < 2) {
        _showValidationError('Please enter a valid job title', 'jobTitle');
        isValid = false;
      }

      if (employmentDuration == null || employmentDuration.isEmpty) {
        _showValidationError(
          'Employment duration is required',
          'employmentDuration',
        );
        isValid = false;
      }

      // Optional employment contact validation
      if (employmentContacts != null && employmentContacts.isNotEmpty) {
        if (!isValidZimbabwePhone(employmentContacts)) {
          _showValidationError(
            'Please enter a valid work contact number',
            'employmentContacts',
          );
          isValid = false;
        }
      }
    }

    // Next of Kin Validation (Optional but validate if provided)
    if (nextOfKinFullName != null && nextOfKinFullName.isNotEmpty) {
      if (nextOfKinFullName.trim().length < 2) {
        _showValidationError(
          'Next of kin full name must be at least 2 characters',
          'nextOfKinFullName',
        );
        isValid = false;
      }

      if (nextOfKinRelationship != null && nextOfKinRelationship.isNotEmpty) {
        if (nextOfKinRelationship.trim().length < 2) {
          _showValidationError(
            'Please enter a valid relationship',
            'nextOfKinRelationship',
          );
          isValid = false;
        }
      }

      if (nextOfKinPhone != null && nextOfKinPhone.isNotEmpty) {
        if (!isValidZimbabwePhone(nextOfKinPhone)) {
          _showValidationError(
            'Please enter a valid next of kin phone number',
            'nextOfKinPhone',
          );
          isValid = false;
        }
      }

      if (nextOfKinEmail != null && nextOfKinEmail.isNotEmpty) {
        if (!isValidEmail(nextOfKinEmail)) {
          _showValidationError(
            'Please enter a valid next of kin email address',
            'nextOfKinEmail',
          );
          isValid = false;
        }
      }
    }

    // Terms Acceptance Validation
    if (!acceptTerms) {
      _showTermsError();
      isValid = false;
    }

    if (!isValid) {
      _showShakeAnimation();
      return false;
    }

    // Convert documents from Map to Document objects
    List<Document>? documentObjects;
    if (documents != null && documents.isNotEmpty) {
      documentObjects = documents.map((doc) {
        return Document(
          type: doc['type'],
          url: doc['url'],
          fileName: doc['file_name'],
          mimeType: doc['mime_type'],
          notes: doc['notes'],
        );
      }).toList();
    }

    // Build RegisterBodyModel with all fields
    final registerBody = RegisterBodyModel(
      email: email.trim(),
      password: password,
      firstName: firstName.trim(),
      lastName: lastName.trim(),
      phone: phone?.trim(),
      alternativePhone: alternativePhone?.trim(),
      roles: ["customer"],
      dateOfBirth: dateOfBirth != null && dateOfBirth.isNotEmpty
          ? DateTime.tryParse(dateOfBirth)
          : null,
      address: address?.trim(),
      location: location?.trim(),
      gender: gender,
      maritalStatus: maritalStatus,
      nationalIdNumber: identificationType == 'national_id'
          ? nationalIdNumber?.trim()
          : null,
      nationalIdImageUrl: identificationType == 'national_id'
          ? nationalIdImageUrl
          : null,
      nationalIdExpiryDate: identificationType == 'national_id'
          ? nationalIdExpiryDate
          : null,
      passportImageUrl: identificationType == 'passport'
          ? passportImageUrl
          : null,
      passportExpiryDate: identificationType == 'passport'
          ? passportExpiryDate
          : null,
      drivingLicenseExpiryDate: drivingLicenseExpiryDate,
      profilePicUrl: profilePicUrl,
      proofOfAddressUrl: proofOfAddressUrl,
      isEmployed: isEmployed,
      employmentDetails:
          isEmployed && employerName != null && employerName.isNotEmpty
          ? EmploymentDetails(
              employerName: employerName,
              jobTitle: jobTitle,
              duration: employmentDuration,
              location: employmentLocation,
              contacts: employmentContacts,
            )
          : null,
      nextOfKin: nextOfKinFullName != null && nextOfKinFullName.isNotEmpty
          ? NextOfKin(
              fullName: nextOfKinFullName,
              relationship: nextOfKinRelationship,
              phoneNumber: nextOfKinPhone,
              email: nextOfKinEmail,
              address: nextOfKinAddress,
            )
          : null,
      documents: documentObjects,
      termsAcceptedAt: acceptTerms ? DateTime.now() : null,
    );

    // Log the payload for debugging
    print('📝 Registration Payload:');
    print('  - Email: ${registerBody.email}');
    print('  - First Name: ${registerBody.firstName}');
    print('  - Last Name: ${registerBody.lastName}');
    print('  - Phone: ${registerBody.phone}');
    print('  - Alternative Phone: ${registerBody.alternativePhone}');
    print('  - Gender: ${registerBody.gender}');
    print('  - Marital Status: ${registerBody.maritalStatus}');
    print('  - Date of Birth: ${registerBody.dateOfBirth}');
    print('  - Address: ${registerBody.address}');
    print('  - Location: ${registerBody.location}');
    print('  - Identification Type: $identificationType');
    print('  - Is Employed: ${registerBody.isEmployed}');
    print('  - Documents Count: ${registerBody.documents?.length ?? 0}');
    print('  - Profile Pic URL: ${registerBody.profilePicUrl}');
    print('  - Proof of Address URL: ${registerBody.proofOfAddressUrl}');

    // Call the registration service
    try {
      Get.dialog(
        const CustomLoader(message: 'Creating your account...'),
        barrierDismissible: false,
      );

      final success = await _authController.authRegisterRequest(
        registerBody: registerBody,
      );

      if (Get.isDialogOpen ?? false) {
        Get.back();
      }

      if (success) {
        _showSuccessAnimationRegister();
        await Future.delayed(300.milliseconds);
        Get.offNamed(RoutesHelper.EmailVerificationScreen, arguments: email);
        return true;
      } else {
        _showErrorDialogRegister(_authController.errorMessage.value);
        return false;
      }
    } catch (e) {
      if (Get.isDialogOpen ?? false) {
        Get.back();
      }
      _showErrorDialogRegister(
        'An error occurred during registration: ${e.toString()}',
      );
      return false;
    }
  }

  static void _showSuccessAnimation() {
    Get.snackbar(
      'Success!',
      'Welcome back!',
      backgroundColor: Colors.green[50],
      colorText: Colors.green[700],
      icon: Icon(Icons.check_circle, color: Colors.green[700]),
      snackPosition: SnackPosition.TOP,
      duration: 2.seconds,
      margin: const EdgeInsets.all(16),
      borderRadius: 12,
      isDismissible: true,
      forwardAnimationCurve: Curves.easeOutBack,
    );
  }

  static void _showSuccessAnimationRegister() {
    Get.snackbar(
      'Registration Successful!',
      'Your account has been created successfully. Please check your email for verification OTP.',
      backgroundColor: Colors.green[50],
      colorText: Colors.green[700],
      icon: Icon(Icons.check_circle, color: Colors.green[700]),
      snackPosition: SnackPosition.TOP,
      duration: 3.seconds,
      margin: const EdgeInsets.all(16),
      borderRadius: 12,
      isDismissible: true,
      forwardAnimationCurve: Curves.easeOutBack,
    );
  }

  static void _showErrorDialog(String message) {
    Get.defaultDialog(
      title: 'Login Failed',
      titleStyle: TextStyle(
        fontWeight: FontWeight.bold,
        color: Colors.red[700],
      ),
      middleText: message,
      middleTextStyle: const TextStyle(color: Colors.black54),
      confirm: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.red[700],
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
        onPressed: () => Get.back(),
        child: const Text('Try Again', style: TextStyle(color: Colors.white)),
      ),
      radius: 12,
    );
  }

  static void _showErrorDialogRegister(String message) {
    Get.defaultDialog(
      title: 'Registration Failed',
      titleStyle: TextStyle(
        fontWeight: FontWeight.bold,
        color: Colors.red[700],
      ),
      middleText: message,
      middleTextStyle: const TextStyle(color: Colors.black54),
      confirm: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.red[700],
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
        onPressed: () => Get.back(),
        child: const Text('Try Again', style: TextStyle(color: Colors.white)),
      ),
      radius: 12,
    );
  }

  // Keep the old method for backward compatibility if needed
  static Future<bool> validateRegisterFormLegacy({
    required String userName,
    required String email,
    required String password,
    required String confirmPassword,
  }) async {
    // Split userName into first and last name
    final nameParts = userName.trim().split(' ');
    final firstName = nameParts.first;
    final lastName = nameParts.length > 1
        ? nameParts.sublist(1).join(' ')
        : nameParts.first;

    if (firstName.isEmpty || lastName.isEmpty) {
      _showValidationError(
        'Please enter your full name (first and last)',
        'userName',
      );
      return false;
    }

    return await validateRegisterForm(
      firstName: firstName,
      lastName: lastName,
      email: email,
      password: password,
      confirmPassword: confirmPassword,
    );
  }
}
