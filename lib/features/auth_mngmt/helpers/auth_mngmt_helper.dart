import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:real_time_pawn/config/routers/router.dart';
import 'package:real_time_pawn/core/utils/pallete.dart';
import 'package:real_time_pawn/widgets/loading_widgets/circular_loader.dart';

import '../controllers/auth_controller.dart';

class AuthHelper {
  static final AuthController _authController = Get.find<AuthController>();

  /// LOGIN VALIDATION + SUBMISSION
  static Future<bool> validateAndSubmitForm({
    required String email,
    required String password,
  }) async {
    // Clear any existing errors
    _clearErrors();

    // Validation with detailed messages
    bool isValid = true;

    if (email.isEmpty) {
      _showValidationError('Email is required', 'email');
      isValid = false;
    } else {
      final emailRegExp = RegExp(
        r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
      );
      if (!emailRegExp.hasMatch(email.trim())) {
        _showValidationError('Please enter a valid email address', 'email');
        isValid = false;
      }
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
    } else if (!_hasUppercase(password)) {
      _showValidationError('Include at least one uppercase letter', 'password');
      isValid = false;
    } else if (!_hasLowercase(password)) {
      _showValidationError('Include at least one lowercase letter', 'password');
      isValid = false;
    } else if (!_hasNumber(password)) {
      _showValidationError('Include at least one number', 'password');
      isValid = false;
    }

    if (!isValid) {
      _showShakeAnimation();
      return false;
    }

    // Call the authentication service
    try {
      Get.dialog(
        const CustomLoader(message: 'Signing in...'),
        barrierDismissible: false,
      );

      final success = await _authController.authSignInRequest(
        emailAddress: email,
        password: password,
      );

      // Close loader
      if (Get.isDialogOpen ?? false) {
        Get.back();
      }

      if (success) {
        // ✅ Success animation
        _showSuccessAnimation();

        // Navigate to home page
        await Future.delayed(300.milliseconds); // Small delay for animation
        // Get.offNamed(RoutesHelper.main_home_page);
        return true;
      } else {
        // ❌ Show error from controller
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

  // Validation helpers
  static bool _hasUppercase(String value) => value.contains(RegExp(r'[A-Z]'));
  static bool _hasLowercase(String value) => value.contains(RegExp(r'[a-z]'));
  static bool _hasNumber(String value) => value.contains(RegExp(r'[0-9]'));

  // Cool validation feedback methods
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
    // You can use GetX to trigger a shake animation
    // Example: Get.find<LoginController>().triggerShake();
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

  /// REGISTER VALIDATION + SUBMISSION
  /// REGISTER VALIDATION + SUBMISSION - Updated to match new payload
  static Future<bool> validateRegisterForm({
    required String firstName,
    required String lastName,
    required String email,
    required String password,
    required String confirmPassword,
    String? phone,
    String? nationalIdNumber,
    String? dateOfBirth,
    String? address,
    String? location,
    bool acceptTerms = true,
  }) async {
    // Clear any existing errors
    _clearErrors();

    // Validation with detailed messages
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
    } else {
      final emailRegExp = RegExp(
        r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
      );
      if (!emailRegExp.hasMatch(email.trim())) {
        _showValidationError('Please enter a valid email address', 'email');
        isValid = false;
      }
    }

    // Phone Validation (Optional)
    if (phone != null && phone.isNotEmpty) {
      // Basic phone validation for Zimbabwe format
      final phoneRegExp = RegExp(r'^\+263[0-9]{9}$');
      if (!phoneRegExp.hasMatch(phone.trim())) {
        _showValidationError(
          'Please enter a valid Zimbabwe phone number (e.g., +263771234567)',
          'phone',
        );
        isValid = false;
      }
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
    } else if (!_hasUppercase(password)) {
      _showValidationError('Include at least one uppercase letter', 'password');
      isValid = false;
    } else if (!_hasLowercase(password)) {
      _showValidationError('Include at least one lowercase letter', 'password');
      isValid = false;
    } else if (!_hasNumber(password)) {
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

    // Date of Birth Validation (Optional)
    if (dateOfBirth != null && dateOfBirth.isNotEmpty) {
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
        }
      } catch (e) {
        _showValidationError(
          'Please enter a valid date (YYYY-MM-DD)',
          'dateOfBirth',
        );
        isValid = false;
      }
    }

    // National ID Validation (Optional)
    if (nationalIdNumber != null && nationalIdNumber.isNotEmpty) {
      final formattedId = nationalIdNumber.trim().toUpperCase();

      // Zimbabwe National ID format: XX-XXXXXX(X)-[A-Z|X]-XX
      final idRegExp = RegExp(r'^\d{2}-\d{6,7}-[A-Z]-\d{2}$');

      if (!idRegExp.hasMatch(formattedId)) {
        _showValidationError(
          'Please enter a valid Zimbabwe National ID (e.g., 63-1234567-A-12)',
          'nationalIdNumber',
        );
        isValid = false;
      }
    }

    // Terms Acceptance Validation
    if (!acceptTerms) {
      _showValidationError('You must accept the terms and conditions', 'terms');
      isValid = false;
    }

    if (!isValid) {
      _showShakeAnimation();
      return false;
    }

    // Call the registration service
    try {
      Get.dialog(
        const CustomLoader(message: 'Creating your account...'),
        barrierDismissible: false,
      );

      final success = await _authController.authRegisterRequest(
        firstName: firstName.trim(),
        lastName: lastName.trim(),
        email: email.trim(),
        password: password,
        phone: phone?.trim(),
        nationalIdNumber: nationalIdNumber?.trim(),
        dateOfBirth: dateOfBirth?.trim(),
        address: address?.trim(),
        location: location?.trim(),
        acceptTerms: acceptTerms,
      );

      // Close loader
      if (Get.isDialogOpen ?? false) {
        Get.back();
      }

      if (success) {
        // ✅ Success animation
        _showSuccessAnimationRegister();

        // Navigate to appropriate page
        await Future.delayed(300.milliseconds); // Small delay for animation

        // Option 1: Go to home if email verification not required
        // Get.offNamed(RoutesHelper.main_home_page);

        // Option 2: Go to email verification screen
        Get.offNamed(RoutesHelper.EmailVerificationScreen, arguments: email);

        // Option 3: Go to complete profile page for additional KYC
        // Get.offNamed(RoutesHelper.complete_profile_page);

        return true;
      } else {
        // ❌ Show error from controller
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

  // Additional helper methods for register-specific feedback
  static void _showSuccessAnimationRegister() {
    Get.snackbar(
      'Registration Successful!',
      'Your account has been created successfully',
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

  static void _showErrorDialogRegister(String message) {
    Get.defaultDialog(
      title: 'Registration Failed',
      titleStyle: TextStyle(
        fontWeight: FontWeight.bold,
        color: Colors.red[700],
      ),
      contentPadding: const EdgeInsets.all(20),
      titlePadding: const EdgeInsets.only(top: 20),
      middleText: message,
      middleTextStyle: const TextStyle(color: Colors.black54),
      confirm: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.red[700],
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          minimumSize: const Size(120, 48),
        ),
        onPressed: () => Get.back(),
        child: const Text('OK', style: TextStyle(color: Colors.white)),
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
        : nameParts.first; // Use first name as last name if only one part

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

  /// FORGOT PASSWORD VALIDATION + SUBMISSION
  static Future<bool> validateAndSubmitForgotPassword({
    required String email,
  }) async {
    // Validation
    if (email.isEmpty) {
      showError('Email is required.');
      return false;
    }

    final emailRegExp = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );
    if (!emailRegExp.hasMatch(email.trim())) {
      showError('Invalid email format.');
      return false;
    }

    try {
      Get.dialog(
        const CustomLoader(message: 'Sending OTP...'),
        barrierDismissible: false,
      );

      final success = await _authController.forgotPasswordRequest(email: email);

      // Close loader
      if (Get.isDialogOpen ?? false) {
        Get.back();
      }

      if (success) {
        // Get.toNamed(
        //   RoutesHelper.otpVerificationScreen,
        //   arguments: {'email': email},
        // );
        // ✅ Show success message and navigate to OTP verification
        showSuccess(_authController.successMessage.value);
        return true;
      } else {
        // ❌ Show error from controller
        showError(_authController.errorMessage.value);
        return false;
      }
    } catch (e) {
      if (Get.isDialogOpen ?? false) {
        Get.back();
      }
      showError(
        'An error occurred during password reset request: ${e.toString()}',
      );
      return false;
    }
  }

  /// OTP VERIFICATION VALIDATION + SUBMISSION
  static Future<bool> validateAndVerifyOtp({
    required String email,
    required String otp,
  }) async {
    // Validation
    if (email.isEmpty) {
      showError('Email is required.');
      return false;
    }

    if (otp.isEmpty) {
      showError('OTP is required.');
      return false;
    }

    if (otp.length != 6) {
      // Assuming 6-digit OTP
      showError('OTP must be 6 digits.');
      return false;
    }

    try {
      Get.dialog(
        const CustomLoader(message: 'Verifying OTP...'),
        barrierDismissible: false,
      );

      final success = await _authController.verifyOtpRequest(
        email: email,
        otp: otp,
      );

      // Close loader
      if (Get.isDialogOpen ?? false) {
        Get.back();
      }

      if (success) {
        // ✅ Show success message
        // Get.toNamed(
        //   // RoutesHelper.resetPasswordScreen,
        //   // arguments: {'email': email, 'otp': otp},
        // );
        showSuccess(_authController.successMessage.value);
        return true;
      } else {
        // ❌ Show error from controller
        showError(_authController.errorMessage.value);
        return false;
      }
    } catch (e) {
      if (Get.isDialogOpen ?? false) {
        Get.back();
      }
      showError('An error occurred during OTP verification: ${e.toString()}');
      return false;
    }
  }

  /// RESET PASSWORD VALIDATION + SUBMISSION
  static Future<bool> validateAndResetPassword({
    required String email,
    required String otp,
    required String newPassword,
    required String confirmPassword,
  }) async {
    // Validation
    if (email.isEmpty) {
      showError('Email is required.');
      return false;
    }

    if (otp.isEmpty) {
      showError('OTP is required.');
      return false;
    }

    if (otp.length != 6) {
      showError('OTP must be 6 digits.');
      return false;
    }

    if (newPassword.isEmpty) {
      showError('New password is required.');
      return false;
    }

    if (newPassword.length < 8) {
      showError('New password must be at least 8 characters long.');
      return false;
    }

    if (confirmPassword.isEmpty) {
      showError('Please confirm your new password.');
      return false;
    }

    if (newPassword != confirmPassword) {
      showError('Passwords do not match.');
      return false;
    }

    try {
      Get.dialog(
        const CustomLoader(message: 'Resetting password...'),
        barrierDismissible: false,
      );

      final success = await _authController.resetPasswordRequest(
        email: email,
        otp: otp,
        newPassword: newPassword,
      );

      // Close loader
      if (Get.isDialogOpen ?? false) {
        Get.back();
      }

      if (success) {
        // ✅ Show success message and navigate to login
        showSuccess(_authController.successMessage.value);
        // Get.offNamed(RoutesHelper.loginScreen); // Adjust route as needed
        return true;
      } else {
        // ❌ Show error from controller
        showError(_authController.errorMessage.value);
        return false;
      }
    } catch (e) {
      if (Get.isDialogOpen ?? false) {
        Get.back();
      }
      showError('An error occurred during password reset: ${e.toString()}');
      return false;
    }
  }

  /// Clear messages from auth controller
  static void clearAuthMessages() {
    _authController.clearMessages();
  }

  static void showError(String message) {
    Get.snackbar(
      'Error',
      message,
      snackPosition: SnackPosition.TOP,
      backgroundColor: AppColors.errorColor,
      colorText: Colors.white,
      borderRadius: 12,
      margin: const EdgeInsets.all(16),
    );
  }

  /// DELETE USER VALIDATION + SUBMISSION
  static Future<bool> validateAndDeleteUser({required String userId}) async {
    if (userId.isEmpty) {
      showError('User ID is required.');
      return false;
    }

    try {
      // auth_mngmt_helper.dart

      Get.dialog(
        const CustomLoader(message: 'Deleting user...'),
        barrierDismissible: false,
      );

      final success = await _authController.deleteUserRequest(userId: userId);

      // Close loader
      if (Get.isDialogOpen ?? false) {
        Get.back();
      }

      if (success) {
        // ✅ Show success message
        showSuccess(_authController.successMessage.value);

        // await CacheUtils.clearCachedToken();
        // Optionally log out / clear session
        // Get.offAllNamed(RoutesHelper.loginScreen);

        return true;
      } else {
        // ❌ Show error from controller
        showError(_authController.errorMessage.value);
        return false;
      }
    } catch (e) {
      if (Get.isDialogOpen ?? false) {
        Get.back();
      }
      showError('An error occurred while deleting user: ${e.toString()}');
      return false;
    }
  }

  static void showSuccess(String message) {
    Get.snackbar(
      'Success',
      message,
      snackPosition: SnackPosition.TOP,
      backgroundColor: AppColors.successColor, // Make sure to define this color
      colorText: Colors.white,
      borderRadius: 12,
      margin: const EdgeInsets.all(16),
    );
  }
}
