// lib/features/profile_mngmt/services/profile_mngmt_services.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:real_time_pawn/core/utils/api_response.dart';
import 'package:real_time_pawn/core/utils/logs.dart';
import 'package:real_time_pawn/core/utils/shared_pref_methods.dart';
import 'package:real_time_pawn/config/api_config/api_keys.dart';
import 'package:real_time_pawn/models/profile_mngmt_model.dart';
import 'package:real_time_pawn/models/register_body_model.dart';

class ProfileMngmtServices {
  // Helper method to get auth headers
  static Future<Map<String, String>>  _getAuthHeaders() async {
    final token = await CacheUtils.checkToken();
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
      'accept': '*/*',
    };
  }

  /// GET - Get user profile
  static Future<APIResponse<UserProfile>> getUserProfile() async {
    try {
      final headers = await _getAuthHeaders();
      final url = Uri.parse('${ApiKeys.baseUrl}/users/profile');

      DevLogs.logInfo('Fetching user profile from: $url');

      final response = await http.get(url, headers: headers);

      DevLogs.logInfo('Profile response status: ${response.statusCode}');

      // Check if response is HTML (error page)
      if (response.statusCode != 200 ||
          (response.body.isNotEmpty && response.body.startsWith('<'))) {
        DevLogs.logError(
          'Server error or HTML response: ${response.statusCode}',
        );

        // Try to parse error message
        String errorMsg = 'Server error (${response.statusCode})';
        try {
          final data = json.decode(response.body);
          errorMsg = data['message'] ?? errorMsg;
        } catch (_) {
          // Not JSON
        }

        return APIResponse<UserProfile>(success: false, message: errorMsg);
      }

      final responseBody = response.body;
      final responseData = json.decode(responseBody);

      DevLogs.logInfo('Profile response data: $responseData');

      if (response.statusCode == 200 && responseData['success'] == true) {
        final data = responseData['data'];

        // Use UserProfile.fromMap to parse the complete profile
        final userProfile = UserProfile.fromMap(data);

        DevLogs.logSuccess('Profile parsed successfully: ${userProfile.email}');

        return APIResponse<UserProfile>(
          success: true,
          message:
              responseData['message']?.toString() ??
              'Profile fetched successfully',
          data: userProfile,
        );
      } else {
        String errorMessage =
            responseData['message']?.toString() ?? 'Failed to fetch profile';
        if (response.statusCode == 401) {
          errorMessage = 'Authentication failed. Please login again.';
        } else if (response.statusCode == 404) {
          errorMessage = 'Profile not found.';
        }

        return APIResponse<UserProfile>(success: false, message: errorMessage);
      }
    } catch (e, stackTrace) {
      DevLogs.logError('Error fetching profile: $e');
      DevLogs.logError('Stack trace: $stackTrace');
      return APIResponse<UserProfile>(
        success: false,
        message: 'Error parsing profile data: ${e.toString()}',
      );
    }
  }

  /// PUT - Update user profile
  static Future<APIResponse<UserProfile>> updateUserProfile({
    required RegisterBodyModel profileData,
  }) async {
    try {
      final headers = await _getAuthHeaders();
      final url = Uri.parse('${ApiKeys.baseUrl}/users/profile');

      // Convert RegisterBodyModel to Map, removing null values
      final payload = profileData.toMap();

      // Remove fields that shouldn't be updated (like password, roles, etc.)
      payload.removeWhere((key, value) => value == null);
      // Don't send password, email, or roles in update
      payload.remove('password');
      payload.remove('email');
      payload.remove('roles');

      DevLogs.logInfo('Updating profile with payload: $payload');

      final response = await http.put(
        url,
        headers: headers,
        body: json.encode(payload),
      );

      DevLogs.logInfo('Update profile response status: ${response.statusCode}');

      if (response.statusCode != 200) {
        DevLogs.logError('Update failed: ${response.statusCode}');
        return APIResponse<UserProfile>(
          success: false,
          message: 'Update failed (${response.statusCode})',
        );
      }

      final responseBody = response.body;
      final responseData = json.decode(responseBody);

      DevLogs.logInfo('Update profile response data: $responseData');

      if (response.statusCode == 200 && responseData['success'] == true) {
        final data = responseData['data'];

        // Use UserProfile.fromMap to parse the complete profile
        final userProfile = UserProfile.fromMap(data);

        DevLogs.logSuccess('Profile updated successfully');

        return APIResponse<UserProfile>(
          success: true,
          message:
              responseData['message']?.toString() ??
              'Profile updated successfully',
          data: userProfile,
        );
      } else {
        String errorMessage =
            responseData['message']?.toString() ?? 'Failed to update profile';
        if (response.statusCode == 401) {
          errorMessage = 'Authentication failed. Please login again.';
        }

        return APIResponse<UserProfile>(success: false, message: errorMessage);
      }
    } catch (e, stackTrace) {
      DevLogs.logError('Error updating profile: $e');
      DevLogs.logError('Stack trace: $stackTrace');
      return APIResponse<UserProfile>(
        success: false,
        message: 'Network error: ${e.toString()}',
      );
    }
  }

  /// PUT - Update profile picture (standalone)
  static Future<APIResponse<String>> updateProfilePicture({
    required String profilePicUrl,
  }) async {
    try {
      final headers = await _getAuthHeaders();
      final url = Uri.parse('${ApiKeys.baseUrl}/users/profile/picture');

      final payload = {'profile_pic_url': profilePicUrl};

      DevLogs.logInfo('Updating profile picture with URL: $profilePicUrl');

      final response = await http.put(
        url,
        headers: headers,
        body: json.encode(payload),
      );

      final responseBody = response.body;
      final responseData = json.decode(responseBody);

      DevLogs.logInfo(
        'Update profile picture response status: ${response.statusCode}',
      );
      DevLogs.logInfo('Update profile picture response data: $responseData');

      if (response.statusCode == 200 && responseData['success'] == true) {
        final message =
            responseData['message']?.toString() ??
            'Profile picture updated successfully';
        DevLogs.logSuccess(message);

        return APIResponse<String>(
          success: true,
          message: message,
          data: profilePicUrl,
        );
      } else {
        String errorMessage =
            responseData['message']?.toString() ??
            'Failed to update profile picture';
        if (response.statusCode == 401) {
          errorMessage = 'Authentication failed. Please login again.';
        }

        return APIResponse<String>(success: false, message: errorMessage);
      }
    } catch (e, stackTrace) {
      DevLogs.logError('Error updating profile picture: $e');
      DevLogs.logError('Stack trace: $stackTrace');
      return APIResponse<String>(
        success: false,
        message: 'Network error: ${e.toString()}',
      );
    }
  }

  /// PUT - Update next of kin details (standalone)
  static Future<APIResponse<Map<String, dynamic>>> updateNextOfKin({
    required String fullName,
    required String relationship,
    required String phoneNumber,
    required String email,
    required String address,
  }) async {
    try {
      final headers = await _getAuthHeaders();
      final url = Uri.parse('${ApiKeys.baseUrl}/users/next-of-kin');

      final payload = {
        'full_name': fullName,
        'relationship': relationship,
        'phone_number': phoneNumber,
        'email': email,
        'address': address,
      };

      DevLogs.logInfo('Updating next of kin details: $payload');

      final response = await http.put(
        url,
        headers: headers,
        body: json.encode(payload),
      );

      final responseBody = response.body;
      final responseData = json.decode(responseBody);

      DevLogs.logInfo(
        'Update next of kin response status: ${response.statusCode}',
      );
      DevLogs.logInfo('Update next of kin response data: $responseData');

      if (response.statusCode == 200 && responseData['success'] == true) {
        final message =
            responseData['message']?.toString() ??
            'Next of kin details updated successfully';
        DevLogs.logSuccess(message);

        return APIResponse<Map<String, dynamic>>(
          success: true,
          message: message,
          data: responseData['data']?['next_of_kin'] ?? {},
        );
      } else {
        String errorMessage =
            responseData['message']?.toString() ??
            'Failed to update next of kin details';
        if (response.statusCode == 401) {
          errorMessage = 'Authentication failed. Please login again.';
        }

        return APIResponse<Map<String, dynamic>>(
          success: false,
          message: errorMessage,
        );
      }
    } catch (e, stackTrace) {
      DevLogs.logError('Error updating next of kin: $e');
      DevLogs.logError('Stack trace: $stackTrace');
      return APIResponse<Map<String, dynamic>>(
        success: false,
        message: 'Network error: ${e.toString()}',
      );
    }
  }

  /// PUT - Update KYC documents and details (standalone)
  static Future<APIResponse<UserProfile>> updateKycDetails({
    String? nationalIdNumber,
    DateTime? dateOfBirth,
    String? address,
    String? location,
    String? gender,
    String? maritalStatus,
    String? alternativePhone,
    String? nationalIdImageUrl,
    String? passportImageUrl,
    String? proofOfAddressUrl,
    DateTime? passportExpiryDate,
    DateTime? drivingLicenseExpiryDate,
    DateTime? nationalIdExpiryDate,
    bool? isEmployed,
    Map<String, dynamic>? employmentDetails,
  }) async {
    try {
      final headers = await _getAuthHeaders();
      final url = Uri.parse('${ApiKeys.baseUrl}/users/kyc');

      final Map<String, dynamic> payload = {};

      if (nationalIdNumber != null)
        payload['national_id_number'] = nationalIdNumber;
      if (dateOfBirth != null)
        payload['date_of_birth'] = dateOfBirth
            .toIso8601String()
            .split('T')
            .first;
      if (address != null) payload['address'] = address;
      if (location != null) payload['location'] = location;
      if (gender != null) payload['gender'] = gender;
      if (maritalStatus != null) payload['marital_status'] = maritalStatus;
      if (alternativePhone != null)
        payload['alternative_phone'] = alternativePhone;
      if (nationalIdImageUrl != null)
        payload['national_id_image_url'] = nationalIdImageUrl;
      if (passportImageUrl != null)
        payload['passport_image_url'] = passportImageUrl;
      if (proofOfAddressUrl != null)
        payload['proof_of_address_url'] = proofOfAddressUrl;
      if (passportExpiryDate != null)
        payload['passport_expiry_date'] = passportExpiryDate
            .toIso8601String()
            .split('T')
            .first;
      if (drivingLicenseExpiryDate != null)
        payload['driving_license_expiry_date'] = drivingLicenseExpiryDate
            .toIso8601String()
            .split('T')
            .first;
      if (nationalIdExpiryDate != null)
        payload['national_id_expiry_date'] = nationalIdExpiryDate
            .toIso8601String()
            .split('T')
            .first;
      if (isEmployed != null) payload['is_employed'] = isEmployed;
      if (employmentDetails != null)
        payload['employment_details'] = employmentDetails;

      DevLogs.logInfo('Updating KYC details with payload: $payload');

      final response = await http.put(
        url,
        headers: headers,
        body: json.encode(payload),
      );

      final responseBody = response.body;
      final responseData = json.decode(responseBody);

      DevLogs.logInfo('Update KYC response status: ${response.statusCode}');
      DevLogs.logInfo('Update KYC response data: $responseData');

      if (response.statusCode == 200 && responseData['success'] == true) {
        final message =
            responseData['message']?.toString() ??
            'KYC details updated successfully';
        DevLogs.logSuccess(message);

        // Parse the updated user profile from response
        final updatedProfile = UserProfile.fromMap(responseData['data']);

        return APIResponse<UserProfile>(
          success: true,
          message: message,
          data: updatedProfile,
        );
      } else {
        String errorMessage =
            responseData['message']?.toString() ??
            'Failed to update KYC details';
        if (response.statusCode == 401) {
          errorMessage = 'Authentication failed. Please login again.';
        }

        return APIResponse<UserProfile>(success: false, message: errorMessage);
      }
    } catch (e, stackTrace) {
      DevLogs.logError('Error updating KYC details: $e');
      DevLogs.logError('Stack trace: $stackTrace');
      return APIResponse<UserProfile>(
        success: false,
        message: 'Network error: ${e.toString()}',
      );
    }
  }

  /// PUT - Update password for logged-in user (standalone)
  static Future<APIResponse<String>> updatePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    try {
      final headers = await _getAuthHeaders();
      final url = Uri.parse('${ApiKeys.baseUrl}/users/update-password');

      final payload = {
        'current_password': currentPassword,
        'new_password': newPassword,
      };

      DevLogs.logInfo('Updating password for logged-in user');

      final response = await http.put(
        url,
        headers: headers,
        body: json.encode(payload),
      );

      final responseBody = response.body;
      final responseData = json.decode(responseBody);

      DevLogs.logInfo(
        'Update password response status: ${response.statusCode}',
      );
      DevLogs.logInfo('Update password response data: $responseData');

      if (response.statusCode == 200 && responseData['success'] == true) {
        final message =
            responseData['message']?.toString() ??
            'Password updated successfully';
        DevLogs.logSuccess(message);

        return APIResponse<String>(
          success: true,
          message: message,
          data: message,
        );
      } else {
        String errorMessage =
            responseData['message']?.toString() ?? 'Failed to update password';
        if (response.statusCode == 401) {
          errorMessage = 'Current password is incorrect';
        } else if (response.statusCode == 400) {
          errorMessage =
              responseData['message']?.toString() ?? 'Invalid password format';
        }

        return APIResponse<String>(success: false, message: errorMessage);
      }
    } catch (e, stackTrace) {
      DevLogs.logError('Error updating password: $e');
      DevLogs.logError('Stack trace: $stackTrace');
      return APIResponse<String>(
        success: false,
        message: 'Network error: ${e.toString()}',
      );
    }
  }

  /// PUT - Update personal details (standalone)
  static Future<APIResponse<UserProfile>> updatePersonalDetails({
    String? firstName,
    String? lastName,
    String? phone,
    DateTime? dateOfBirth,
    String? address,
    String? location,
    String? gender,
    String? maritalStatus,
    String? alternativePhone,
  }) async {
    try {
      final headers = await _getAuthHeaders();
      final url = Uri.parse('${ApiKeys.baseUrl}/users/personal-details');

      final Map<String, dynamic> payload = {};

      if (firstName != null) payload['first_name'] = firstName;
      if (lastName != null) payload['last_name'] = lastName;
      if (phone != null) payload['phone'] = phone;
      if (dateOfBirth != null)
        payload['date_of_birth'] = dateOfBirth
            .toIso8601String()
            .split('T')
            .first;
      if (address != null) payload['address'] = address;
      if (location != null) payload['location'] = location;
      if (gender != null) payload['gender'] = gender;
      if (maritalStatus != null) payload['marital_status'] = maritalStatus;
      if (alternativePhone != null)
        payload['alternative_phone'] = alternativePhone;

      DevLogs.logInfo('Updating personal details with payload: $payload');

      final response = await http.put(
        url,
        headers: headers,
        body: json.encode(payload),
      );

      final responseBody = response.body;
      final responseData = json.decode(responseBody);

      DevLogs.logInfo(
        'Update personal details response status: ${response.statusCode}',
      );
      DevLogs.logInfo('Update personal details response data: $responseData');

      if (response.statusCode == 200 && responseData['success'] == true) {
        final message =
            responseData['message']?.toString() ??
            'Personal details updated successfully';
        DevLogs.logSuccess(message);

        // Parse the updated user profile from response
        final updatedProfile = UserProfile.fromMap(responseData['data']);

        return APIResponse<UserProfile>(
          success: true,
          message: message,
          data: updatedProfile,
        );
      } else {
        String errorMessage =
            responseData['message']?.toString() ??
            'Failed to update personal details';
        if (response.statusCode == 401) {
          errorMessage = 'Authentication failed. Please login again.';
        }

        return APIResponse<UserProfile>(success: false, message: errorMessage);
      }
    } catch (e, stackTrace) {
      DevLogs.logError('Error updating personal details: $e');
      DevLogs.logError('Stack trace: $stackTrace');
      return APIResponse<UserProfile>(
        success: false,
        message: 'Network error: ${e.toString()}',
      );
    }
  }

  /// POST - Request account deletion
  static Future<APIResponse<String>> requestAccountDeletion({
    required String email,
  }) async {
    try {
      final headers = await _getAuthHeaders();
      final url = Uri.parse('${ApiKeys.baseUrl}/users/request-deletion');

      final payload = {'email': email};

      DevLogs.logInfo('Requesting account deletion for: $email');

      final response = await http.post(
        url,
        headers: headers,
        body: json.encode(payload),
      );

      final responseBody = response.body;
      final responseData = json.decode(responseBody);

      DevLogs.logInfo(
        'Request deletion response status: ${response.statusCode}',
      );
      DevLogs.logInfo('Request deletion response data: $responseData');

      if (response.statusCode == 200 && responseData['success'] == true) {
        final message =
            responseData['message']?.toString() ?? 'Deletion OTP sent to email';
        DevLogs.logSuccess(message);

        return APIResponse<String>(
          success: true,
          message: message,
          data: message,
        );
      } else {
        String errorMessage =
            responseData['message']?.toString() ?? 'Failed to request deletion';

        return APIResponse<String>(success: false, message: errorMessage);
      }
    } catch (e) {
      DevLogs.logError('Error requesting account deletion: $e');
      return APIResponse<String>(
        success: false,
        message: 'An error occurred: $e',
      );
    }
  }

  /// POST - Confirm account deletion with OTP
  static Future<APIResponse<bool>> confirmAccountDeletion({
    required String email,
    required String otp,
  }) async {
    try {
      final headers = await _getAuthHeaders();
      final url = Uri.parse('${ApiKeys.baseUrl}/users/confirm-deletion');

      final payload = {'email': email, 'otp': otp};

      DevLogs.logInfo('Confirming account deletion for: $email');

      final response = await http.post(
        url,
        headers: headers,
        body: json.encode(payload),
      );

      final responseBody = response.body;
      final responseData = json.decode(responseBody);

      DevLogs.logInfo(
        'Confirm deletion response status: ${response.statusCode}',
      );
      DevLogs.logInfo('Confirm deletion response data: $responseData');

      if (response.statusCode == 200 && responseData['success'] == true) {
        final message =
            responseData['message']?.toString() ??
            'Account deleted successfully';
        DevLogs.logSuccess(message);

        return APIResponse<bool>(success: true, message: message, data: true);
      } else {
        String errorMessage =
            responseData['message']?.toString() ?? 'Failed to delete account';

        return APIResponse<bool>(success: false, message: errorMessage);
      }
    } catch (e) {
      DevLogs.logError('Error confirming account deletion: $e');
      return APIResponse<bool>(
        success: false,
        message: 'An error occurred: $e',
      );
    }
  }
}
