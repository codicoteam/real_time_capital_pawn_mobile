import 'dart:convert';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:real_time_pawn/core/utils/logs.dart';
import '../../../config/api_config/api_keys.dart';
import '../../../core/utils/api_response.dart';
import '../../../core/utils/shared_pref_methods.dart';

class AuthServices {
  /// LOGIN
  static Future<APIResponse<String>> login({
    required String emailAddress,
    required String password,
  }) async {
    var headers = {'Content-Type': 'application/json'};

    var request = http.Request(
      'POST',
      Uri.parse('${ApiKeys.baseUrl}/user_route/login'),
    );

    request.body = json.encode({"email": emailAddress, "password": password});
    request.headers.addAll(headers);

    try {
      http.StreamedResponse response = await request.send();
      DevLogs.logInfo('Response status: ${response.statusCode}');
      DevLogs.logInfo('Response message: ${response.reasonPhrase}');

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final responseData = json.decode(await response.stream.bytesToString());

        final token = responseData['token'];
        final user = responseData['user'];

        // Cache the token
        await CacheUtils.storeToken(token: "$token");

        DevLogs.logSuccess(
          'Login successful. Token: $token, User: ${user['email']}',
        );

        final decodedUser = await _getUserFromToken();
        if (decodedUser != null) {
          DevLogs.logInfo(
            "User loaded from token: ${decodedUser} (${decodedUser})",
          );
          // Get.find<UserController>().setUser(decodedUser);
        }

        return APIResponse(
          success: true,
          message: 'Login successful',
          data: token,
        );
      } else {
        final errorData = json.decode(await response.stream.bytesToString());
        final errorMessage = errorData['message'] ?? 'Login failed';
        DevLogs.logError('Login failed: $errorMessage');

        return APIResponse(success: false, message: errorMessage, data: null);
      }
    } catch (e) {
      DevLogs.logError('An error occurred: $e');
      return APIResponse(
        success: false,
        message: 'An error occurred: $e',
        data: null,
      );
    }
  }

  /// REGISTER
  static Future<APIResponse<String>> register({
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
    var headers = {'Content-Type': 'application/json'};

    var request = http.Request(
      'POST',
      Uri.parse('${ApiKeys.baseUrl}/users/register'),
    );

    Map<String, dynamic> payload = {
      "first_name": firstName,
      "last_name": lastName,
      "full_name": "$firstName $lastName",
      "email": email,
      "password": password,
      "status": "pending",
      "email_verified": false,
      "terms_accepted_at": acceptTerms
          ? DateTime.now().toUtc().toIso8601String()
          : null,
      "roles": ["customer"],
      "auth_providers": [
        {
          "provider": "email",
          "provider_user_id": email,
          "added_at": DateTime.now().toUtc().toIso8601String(),
        },
      ],
    };

    if (phone != null && phone.isNotEmpty) {
      payload["phone"] = phone;
    }
    if (nationalIdNumber != null && nationalIdNumber.isNotEmpty) {
      payload["national_id_number"] = nationalIdNumber;
    }
    if (dateOfBirth != null && dateOfBirth.isNotEmpty) {
      payload["date_of_birth"] = dateOfBirth;
    }
    if (address != null && address.isNotEmpty) {
      payload["address"] = address;
    }
    if (location != null && location.isNotEmpty) {
      payload["location"] = location;
    }

    payload.removeWhere((key, value) => value == null);

    DevLogs.logInfo('Registration payload: ${json.encode(payload)}');

    request.body = json.encode(payload);
    request.headers.addAll(headers);

    try {
      http.StreamedResponse response = await request.send();
      final responseBody = await response.stream.bytesToString();
      final responseData = json.decode(responseBody);

      DevLogs.logInfo('Response status: ${response.statusCode}');
      DevLogs.logInfo('Response body: $responseBody');

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final message = responseData['message'] ?? 'Registration successful';

        DevLogs.logSuccess(message);

        return APIResponse(
          success: true,
          message: message,
          data: email, // or null if you prefer
        );
      } else {
        final errorMessage = responseData['message'] ?? 'Registration failed';

        DevLogs.logError('Registration failed: $errorMessage');

        return APIResponse(success: false, message: errorMessage, data: null);
      }
    } catch (e) {
      DevLogs.logError('Registration error: $e');

      return APIResponse(
        success: false,
        message: 'An error occurred during registration',
        data: null,
      );
    }
  }

  /// VERIFY EMAIL
  static Future<APIResponse<Map<String, dynamic>>> verifyEmail({
    required String email,
    required String otp,
  }) async {
    var headers = {'Content-Type': 'application/json'};

    var request = http.Request(
      'POST',
      Uri.parse('${ApiKeys.baseUrl}/users/verify-email'),
    );

    request.body = json.encode({"email": email, "otp": otp});
    request.headers.addAll(headers);

    try {
      http.StreamedResponse response = await request.send();
      DevLogs.logInfo('Verify email response status: ${response.statusCode}');
      DevLogs.logInfo(
        'Verify email response message: ${response.reasonPhrase}',
      );

      final responseBody = await response.stream.bytesToString();
      final responseData = json.decode(responseBody);

      DevLogs.logInfo('Verify email response data: $responseData');

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final message =
            responseData['message'] ?? 'Email verified successfully';
        final data = responseData['data'];

        if (data != null && data is Map<String, dynamic>) {
          final token = data['token'];
          final user = data['user'];

          // Cache the token
          if (token != null && token.isNotEmpty) {
            await CacheUtils.storeToken(token: token);
          }

          DevLogs.logSuccess('Email verification successful: $message');

          // Decode user from token for app state
          final decodedUser = await _getUserFromToken();
          if (decodedUser != null) {
            DevLogs.logInfo("User loaded from token after email verification");
            // Get.find<UserController>().setUser(decodedUser);
          }

          return APIResponse<Map<String, dynamic>>(
            success: true,
            message: message,
            data: {'token': token, 'user': user},
          );
        } else {
          DevLogs.logError('Invalid response format: missing data field');
          return APIResponse<Map<String, dynamic>>(
            success: false,
            message: 'Invalid response format',
            data: null,
          );
        }
      } else {
        final errorMessage =
            responseData['message'] ?? 'Email verification failed';
        DevLogs.logError('Email verification failed: $errorMessage');

        return APIResponse<Map<String, dynamic>>(
          success: false,
          message: errorMessage,
          data: null,
        );
      }
    } catch (e) {
      DevLogs.logError('An error occurred in verifyEmail: $e');
      return APIResponse<Map<String, dynamic>>(
        success: false,
        message: 'An error occurred: $e',
        data: null,
      );
    }
  }

  /// RESEND VERIFICATION EMAIL
  static Future<APIResponse<String>> resendVerificationEmail({
    required String email,
  }) async {
    var headers = {'Content-Type': 'application/json'};

    var request = http.Request(
      'POST',
      Uri.parse('${ApiKeys.baseUrl}/users/resend-verification'),
    );

    request.body = json.encode({"email": email});
    request.headers.addAll(headers);

    try {
      http.StreamedResponse response = await request.send();
      DevLogs.logInfo(
        'Resend verification response status: ${response.statusCode}',
      );
      DevLogs.logInfo(
        'Resend verification response message: ${response.reasonPhrase}',
      );

      final responseBody = await response.stream.bytesToString();
      final responseData = json.decode(responseBody);

      DevLogs.logInfo('Resend verification response data: $responseData');

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final message =
            responseData['message'] ?? 'Verification email sent successfully';

        DevLogs.logSuccess('Resend verification successful: $message');

        return APIResponse<String>(
          success: true,
          message: message,
          data: email,
        );
      } else {
        final errorMessage =
            responseData['message'] ?? 'Failed to resend verification email';
        DevLogs.logError('Resend verification failed: $errorMessage');

        return APIResponse<String>(
          success: false,
          message: errorMessage,
          data: null,
        );
      }
    } catch (e) {
      DevLogs.logError('An error occurred in resendVerificationEmail: $e');
      return APIResponse<String>(
        success: false,
        message: 'An error occurred: $e',
        data: null,
      );
    }
  }

  /// FORGOT PASSWORD
  static Future<APIResponse<String>> forgotUserPassword({
    required String email,
  }) async {
    var headers = {'Content-Type': 'application/json'};

    var request = http.Request(
      'POST',
      Uri.parse('${ApiKeys.baseUrl}/user_route/forgot-password'),
    );

    request.body = json.encode({"email": email});
    request.headers.addAll(headers);

    try {
      http.StreamedResponse response = await request.send();
      DevLogs.logInfo(
        'Forgot password response status: ${response.statusCode}',
      );
      DevLogs.logInfo(
        'Forgot password response message: ${response.reasonPhrase}',
      );

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final responseData = json.decode(await response.stream.bytesToString());
        final message =
            responseData['message'] ?? 'Password reset OTP sent successfully';

        DevLogs.logSuccess('Forgot password request successful: $message');

        return APIResponse(success: true, message: message, data: null);
      } else {
        final errorData = json.decode(await response.stream.bytesToString());
        final errorMessage =
            errorData['message'] ?? 'Failed to send password reset OTP';
        DevLogs.logError('Forgot password failed: $errorMessage');

        return APIResponse(success: false, message: errorMessage, data: null);
      }
    } catch (e) {
      DevLogs.logError('An error occurred in forgotUserPassword: $e');
      return APIResponse(
        success: false,
        message: 'An error occurred: $e',
        data: null,
      );
    }
  }

  /// VERIFY OTP (for password reset)
  static Future<APIResponse<String>> verifyOtp({
    required String email,
    required String otp,
  }) async {
    var headers = {'Content-Type': 'application/json'};

    var request = http.Request(
      'POST',
      Uri.parse('${ApiKeys.baseUrl}/user_route/verify-otp'),
    );

    request.body = json.encode({"email": email, "otp": otp});
    request.headers.addAll(headers);

    try {
      http.StreamedResponse response = await request.send();
      DevLogs.logInfo('Verify OTP response status: ${response.statusCode}');
      DevLogs.logInfo('Verify OTP response message: ${response.reasonPhrase}');

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final responseData = json.decode(await response.stream.bytesToString());
        final message = responseData['message'] ?? 'OTP verified successfully';

        DevLogs.logSuccess('OTP verification successful: $message');

        return APIResponse(success: true, message: message, data: null);
      } else {
        final errorData = json.decode(await response.stream.bytesToString());
        final errorMessage = errorData['message'] ?? 'Invalid or expired OTP';
        DevLogs.logError('OTP verification failed: $errorMessage');

        return APIResponse(success: false, message: errorMessage, data: null);
      }
    } catch (e) {
      DevLogs.logError('An error occurred in verifyOtp: $e');
      return APIResponse(
        success: false,
        message: 'An error occurred: $e',
        data: null,
      );
    }
  }

  /// RESET PASSWORD
  static Future<APIResponse<String>> resetPassword({
    required String email,
    required String otp,
    required String newPassword,
  }) async {
    var headers = {'Content-Type': 'application/json'};

    var request = http.Request(
      'POST',
      Uri.parse('${ApiKeys.baseUrl}/user_route/reset-password'),
    );

    request.body = json.encode({
      "email": email,
      "otp": otp,
      "newPassword": newPassword,
    });
    request.headers.addAll(headers);

    try {
      http.StreamedResponse response = await request.send();
      DevLogs.logInfo('Reset password response status: ${response.statusCode}');
      DevLogs.logInfo(
        'Reset password response message: ${response.reasonPhrase}',
      );

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final responseData = json.decode(await response.stream.bytesToString());
        final message =
            responseData['message'] ?? 'Password reset successfully';

        DevLogs.logSuccess('Password reset successful: $message');

        return APIResponse(success: true, message: message, data: null);
      } else {
        final errorData = json.decode(await response.stream.bytesToString());
        final errorMessage = errorData['message'] ?? 'Failed to reset password';
        DevLogs.logError('Password reset failed: $errorMessage');

        return APIResponse(success: false, message: errorMessage, data: null);
      }
    } catch (e) {
      DevLogs.logError('An error occurred in resetPassword: $e');
      return APIResponse(
        success: false,
        message: 'An error occurred: $e',
        data: null,
      );
    }
  }

  /// DELETE USER
  static Future<APIResponse<String>> deleteUser(String userId) async {
    final token = await CacheUtils.checkToken();
    final String url = "${ApiKeys.baseUrl}/user_route/users/$userId";

    try {
      final response = await http.delete(
        Uri.parse(url),
        headers: {'accept': '*/*', 'Authorization': 'Bearer $token'},
      );

      DevLogs.logInfo('Delete user response: ${response.body}');

      if (response.statusCode >= 200 && response.statusCode < 300) {
        return APIResponse<String>(
          success: true,
          data: 'User deleted successfully',
          message: 'User with ID $userId deleted successfully.',
        );
      } else {
        return APIResponse<String>(
          success: false,
          message:
              'Failed to delete user. HTTP Status: ${response.statusCode} - ${response.reasonPhrase}',
        );
      }
    } catch (e) {
      DevLogs.logError('Error deleting user: $e');
      return APIResponse<String>(
        success: false,
        message: 'Error deleting user: $e',
      );
    }
  }

  /// Extract the user info from the stored token
  static Future<String?> _getUserFromToken() async {
    final token = await CacheUtils.checkToken();
    if (token != null && token.isNotEmpty) {
      if (JwtDecoder.isExpired(token)) {
        await CacheUtils.clearCachedToken();
        return null; // Token expired
      } else {
        final decodedToken = JwtDecoder.decode(token);
        DevLogs.logInfo("Decoded token: $decodedToken");
        return decodedToken['user'] as String?;
      }
    }
    return null; // No token found
  }
}
