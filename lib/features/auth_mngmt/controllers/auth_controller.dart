import 'package:get/get.dart';
import 'package:real_time_pawn/features/auth_mngmt/services/auth_service.dart';
import '../../../core/utils/logs.dart';

class AuthController extends GetxController {
  var isLoading = false.obs;
  var successMessage = ''.obs;
  var errorMessage = ''.obs;

  /// LOGIN
  Future<bool> authSignInRequest({
    required String emailAddress,
    required String password,
  }) async {
    try {
      isLoading(true);
      final response = await AuthServices.login(
        emailAddress: emailAddress,
        password: password,
      );
      if (response.success) {
        successMessage.value = response.message ?? '';
        return true;
      } else {
        errorMessage.value = response.message ?? 'Login failed';
        DevLogs.logError(errorMessage.value);
        return false;
      }
    } catch (e) {
      DevLogs.logError('Error logging in user: ${e.toString()}');
      errorMessage.value =
          'An error occurred while logging in: ${e.toString()}';
      return false;
    } finally {
      isLoading(false); // End loading
    }
  }

  /// REGISTER

  Future<bool> authRegisterRequest({
    required String firstName,
    required String lastName,
    required String email,
    required String password,
    String? phone,
    String? nationalIdNumber,
    String? dateOfBirth,
    String? address,
    String? location,
    bool acceptTerms = true,
  }) async {
    try {
      isLoading(true);
      successMessage.value = '';
      errorMessage.value = '';

      final response = await AuthServices.register(
        firstName: firstName,
        lastName: lastName,
        email: email,
        password: password,
        phone: phone,
        nationalIdNumber: nationalIdNumber,
        dateOfBirth: dateOfBirth,
        address: address,
        location: location,
        acceptTerms: acceptTerms,
      );

      if (response.success) {
        successMessage.value = response.message ?? 'Registration successful!';
        DevLogs.logSuccess(successMessage.value);
        return true;
      } else {
        errorMessage.value = response.message ?? 'Registration failed';
        DevLogs.logError(errorMessage.value);
        return false;
      }
    } catch (e) {
      DevLogs.logError('Error registering user: ${e.toString()}');
      errorMessage.value =
          'An error occurred while registering: ${e.toString()}';
      return false;
    } finally {
      isLoading(false); // End loading
    }
  }

  /// FORGOT PASSWORD - Request OTP
  Future<bool> forgotPasswordRequest({required String email}) async {
    try {
      isLoading(true);
      final response = await AuthServices.forgotUserPassword(email: email);
      if (response.success) {
        successMessage.value = response.message ?? 'OTP sent successfully';
        return true;
      } else {
        errorMessage.value = response.message ?? 'Failed to send OTP';
        DevLogs.logError(errorMessage.value);
        return false;
      }
    } catch (e) {
      DevLogs.logError('Error in forgot password request: ${e.toString()}');
      errorMessage.value =
          'An error occurred while processing your request: ${e.toString()}';
      return false;
    } finally {
      isLoading(false);
    }
  }

  /// VERIFY OTP
  Future<bool> verifyOtpRequest({
    required String email,
    required String otp,
  }) async {
    try {
      isLoading(true);
      final response = await AuthServices.verifyOtp(email: email, otp: otp);
      if (response.success) {
        successMessage.value = response.message ?? 'OTP verified successfully';
        return true;
      } else {
        errorMessage.value = response.message ?? 'OTP verification failed';
        DevLogs.logError(errorMessage.value);
        return false;
      }
    } catch (e) {
      DevLogs.logError('Error in OTP verification: ${e.toString()}');
      errorMessage.value =
          'An error occurred while verifying OTP: ${e.toString()}';
      return false;
    } finally {
      isLoading(false);
    }
  }

  /// VERIFY EMAIL
  Future<bool> verifyEmailRequest({
    required String email,
    required String otp,
  }) async {
    try {
      isLoading(true);
      successMessage.value = '';
      errorMessage.value = '';

      final response = await AuthServices.verifyEmail(email: email, otp: otp);

      if (response.success) {
        successMessage.value =
            response.message ?? 'Email verified successfully';
        DevLogs.logSuccess(successMessage.value);
        return true;
      } else {
        errorMessage.value = response.message ?? 'Email verification failed';
        DevLogs.logError(errorMessage.value);
        return false;
      }
    } catch (e) {
      DevLogs.logError('Error verifying email: ${e.toString()}');
      errorMessage.value =
          'An error occurred while verifying email: ${e.toString()}';
      return false;
    } finally {
      isLoading(false);
    }
  }

  /// RESEND VERIFICATION EMAIL
  Future<bool> resendVerificationEmailRequest({required String email}) async {
    try {
      isLoading(true);
      successMessage.value = '';
      errorMessage.value = '';

      final response = await AuthServices.resendVerificationEmail(email: email);

      if (response.success) {
        successMessage.value =
            response.message ?? 'Verification email sent successfully';
        DevLogs.logSuccess(successMessage.value);
        return true;
      } else {
        errorMessage.value =
            response.message ?? 'Failed to resend verification email';
        DevLogs.logError(errorMessage.value);
        return false;
      }
    } catch (e) {
      DevLogs.logError('Error resending verification email: ${e.toString()}');
      errorMessage.value =
          'An error occurred while resending verification email: ${e.toString()}';
      return false;
    } finally {
      isLoading(false);
    }
  }

  /// RESET PASSWORD
  Future<bool> resetPasswordRequest({
    required String email,
    required String otp,
    required String newPassword,
  }) async {
    try {
      isLoading(true);
      final response = await AuthServices.resetPassword(
        email: email,
        otp: otp,
        newPassword: newPassword,
      );
      if (response.success) {
        successMessage.value =
            response.message ?? 'Password reset successfully';
        return true;
      } else {
        errorMessage.value = response.message ?? 'Password reset failed';
        DevLogs.logError(errorMessage.value);
        return false;
      }
    } catch (e) {
      DevLogs.logError('Error in password reset: ${e.toString()}');
      errorMessage.value =
          'An error occurred while resetting password: ${e.toString()}';
      return false;
    } finally {
      isLoading(false);
    }
  }

  /// DELETE USER
  Future<bool> deleteUserRequest({required String userId}) async {
    try {
      isLoading(true);
      final response = await AuthServices.deleteUser(userId);
      if (response.success) {
        successMessage.value = response.message ?? 'User deleted successfully';
        return true;
      } else {
        errorMessage.value = response.message ?? 'User deletion failed';
        DevLogs.logError(errorMessage.value);
        return false;
      }
    } catch (e) {
      DevLogs.logError('Error deleting user: ${e.toString()}');
      errorMessage.value =
          'An error occurred while deleting user: ${e.toString()}';
      return false;
    } finally {
      isLoading(false); // End loading
    }
  }

  /// Clear messages (useful for resetting state between operations)
  void clearMessages() {
    successMessage.value = '';
    errorMessage.value = '';
  }
}
