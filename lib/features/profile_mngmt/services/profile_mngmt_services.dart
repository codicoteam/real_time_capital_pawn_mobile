// lib/features/profile_mngmt/services/profile_mngmt_services.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:real_time_pawn/core/utils/api_response.dart';
import 'package:real_time_pawn/core/utils/logs.dart';
import 'package:real_time_pawn/core/utils/shared_pref_methods.dart';
import 'package:real_time_pawn/config/api_config/api_keys.dart';
import 'package:real_time_pawn/models/profile_mngmt_model.dart';

class ProfileMngmtServices {
  // Helper method to get auth headers
  static Future<Map<String, String>> _getAuthHeaders() async {
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

        // Parse documents safely
        List<Document> documents = [];
        if (data['documents'] != null && data['documents'] is List) {
          try {
            documents = _parseDocuments(data['documents']);
          } catch (e) {
            DevLogs.logError('Error parsing documents: $e');
            documents = [];
          }
        }

        final userProfile = UserProfile(
          id: data['_id']?.toString() ?? '',
          email: data['email']?.toString() ?? '',
          phone: data['phone']?.toString(),
          roles: _parseUserRoles(data['roles'] ?? []),
          firstName: data['first_name']?.toString() ?? '',
          lastName: data['last_name']?.toString() ?? '',
          fullName: data['full_name']?.toString(),
          status: _parseUserStatus(data['status']?.toString() ?? 'pending'),
          nationalIdNumber: data['national_id_number']?.toString(),
          dateOfBirth: data['date_of_birth'] != null
              ? DateTime.tryParse(data['date_of_birth'].toString())
              : null,
          address: data['address']?.toString(),
          location: data['location']?.toString(),
          termsAcceptedAt: data['terms_accepted_at'] != null
              ? DateTime.tryParse(data['terms_accepted_at'].toString())
              : null,
          nationalIdImageUrl: data['national_id_image_url']?.toString(),
          profilePicUrl: data['profile_pic_url']?.toString(),
          documents: documents,
          isEmailVerified: data['email_verified'] == true,
          createdAt: data['created_at'] != null
              ? DateTime.parse(data['created_at'].toString())
              : DateTime.now(),
          updatedAt: data['updated_at'] != null
              ? DateTime.parse(data['updated_at'].toString())
              : DateTime.now(),
        );

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
    required String firstName,
    required String lastName,
    String? phone,
    String? dateOfBirth,
    String? address,
    String? location,
    String? profilePicUrl,
  }) async {
    try {
      final headers = await _getAuthHeaders();
      final url = Uri.parse('${ApiKeys.baseUrl}/users/profile');

      final payload = {
        'first_name': firstName,
        'last_name': lastName,
        if (phone != null && phone.isNotEmpty) 'phone': phone,
        if (dateOfBirth != null && dateOfBirth.isNotEmpty)
          'date_of_birth': dateOfBirth,
        if (address != null && address.isNotEmpty) 'address': address,
        if (location != null && location.isNotEmpty) 'location': location,
        if (profilePicUrl != null && profilePicUrl.isNotEmpty)
          'profile_pic_url': profilePicUrl,
      };

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

        // Parse documents safely
        List<Document> documents = [];
        if (data['documents'] != null && data['documents'] is List) {
          try {
            documents = _parseDocuments(data['documents']);
          } catch (e) {
            DevLogs.logError('Error parsing documents: $e');
            documents = [];
          }
        }

        final userProfile = UserProfile(
          id: data['_id']?.toString() ?? '',
          email: data['email']?.toString() ?? '',
          phone: data['phone']?.toString(),
          roles: _parseUserRoles(data['roles'] ?? []),
          firstName: data['first_name']?.toString() ?? '',
          lastName: data['last_name']?.toString() ?? '',
          fullName: data['full_name']?.toString(),
          status: _parseUserStatus(data['status']?.toString() ?? 'pending'),
          nationalIdNumber: data['national_id_number']?.toString(),
          dateOfBirth: data['date_of_birth'] != null
              ? DateTime.tryParse(data['date_of_birth'].toString())
              : null,
          address: data['address']?.toString(),
          location: data['location']?.toString(),
          termsAcceptedAt: data['terms_accepted_at'] != null
              ? DateTime.tryParse(data['terms_accepted_at'].toString())
              : null,
          nationalIdImageUrl: data['national_id_image_url']?.toString(),
          profilePicUrl: data['profile_pic_url']?.toString(),
          documents: documents,
          isEmailVerified: data['email_verified'] == true,
          createdAt: data['created_at'] != null
              ? DateTime.parse(data['created_at'].toString())
              : DateTime.now(),
          updatedAt: data['updated_at'] != null
              ? DateTime.parse(data['updated_at'].toString())
              : DateTime.now(),
        );

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

  /// POST - Upload a document
  static Future<APIResponse<Document>> uploadDocument({
    required String type,
    required String url,
    required String fileName,
    required String mimeType,
    String? notes,
  }) async {
    try {
      final headers = await _getAuthHeaders();
      final urlPath = Uri.parse('${ApiKeys.baseUrl}/users/documents');

      final payload = {
        'type': type,
        'url': url,
        'file_name': fileName,
        'mime_type': mimeType,
        if (notes != null && notes.isNotEmpty) 'notes': notes,
      };

      DevLogs.logInfo('Uploading document with payload: $payload');

      final response = await http.post(
        urlPath,
        headers: headers,
        body: json.encode(payload),
      );

      final responseBody = response.body;
      final responseData = json.decode(responseBody);

      DevLogs.logInfo(
        'Upload document response status: ${response.statusCode}',
      );
      DevLogs.logInfo('Upload document response data: $responseData');

      if (response.statusCode == 201) {
        final data = responseData['data'];
        final document = Document(
          id: data['_id'] ?? DateTime.now().millisecondsSinceEpoch.toString(),
          type: _parseDocumentType(data['type']),
          url: data['url'],
          fileName: data['file_name'],
          mimeType: data['mime_type'],
          uploadedAt: DateTime.parse(data['uploaded_at']),
          notes: data['notes'],
        );

        return APIResponse<Document>(
          success: true,
          message: responseData['message'] ?? 'Document uploaded successfully',
          data: document,
        );
      } else {
        return APIResponse<Document>(
          success: false,
          message: responseData['message'] ?? 'Failed to upload document',
        );
      }
    } catch (e) {
      DevLogs.logError('Error uploading document: $e');
      return APIResponse<Document>(
        success: false,
        message: 'An error occurred: $e',
      );
    }
  }

  /// DELETE - Remove a document
  static Future<APIResponse<bool>> deleteDocument(String documentId) async {
    try {
      final headers = await _getAuthHeaders();
      final url = Uri.parse('${ApiKeys.baseUrl}/users/documents/$documentId');

      DevLogs.logInfo('Deleting document: $documentId');

      final response = await http.delete(url, headers: headers);
      final responseBody = response.body;
      final responseData = json.decode(responseBody);

      DevLogs.logInfo(
        'Delete document response status: ${response.statusCode}',
      );
      DevLogs.logInfo('Delete document response data: $responseData');

      if (response.statusCode == 200) {
        return APIResponse<bool>(
          success: true,
          message: responseData['message'] ?? 'Document deleted successfully',
          data: true,
        );
      } else {
        return APIResponse<bool>(
          success: false,
          message: responseData['message'] ?? 'Failed to delete document',
        );
      }
    } catch (e) {
      DevLogs.logError('Error deleting document: $e');
      return APIResponse<bool>(
        success: false,
        message: 'An error occurred: $e',
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

      if (response.statusCode == 200) {
        return APIResponse<String>(
          success: true,
          message: responseData['message'] ?? 'Deletion OTP sent to email',
          data: email,
        );
      } else {
        return APIResponse<String>(
          success: false,
          message: responseData['message'] ?? 'Failed to request deletion',
        );
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

      if (response.statusCode == 200) {
        return APIResponse<bool>(
          success: true,
          message: responseData['message'] ?? 'Account deleted successfully',
          data: true,
        );
      } else {
        return APIResponse<bool>(
          success: false,
          message: responseData['message'] ?? 'Failed to delete account',
        );
      }
    } catch (e) {
      DevLogs.logError('Error confirming account deletion: $e');
      return APIResponse<bool>(
        success: false,
        message: 'An error occurred: $e',
      );
    }
  }

  // Helper methods for parsing
  static List<UserRole> _parseUserRoles(List<dynamic> roles) {
    if (roles.isEmpty) return [UserRole.customer];

    return roles.map((role) {
      if (role is String) {
        switch (role) {
          case 'super_admin_vendor':
            return UserRole.super_admin_vendor;
          case 'admin_pawn_limited':
            return UserRole.admin_pawn_limited;
          case 'call_centre_support':
            return UserRole.call_centre_support;
          case 'loan_officer_processor':
            return UserRole.loan_officer_processor;
          case 'loan_officer_approval':
            return UserRole.loan_officer_approval;
          case 'management':
            return UserRole.management;
          case 'customer':
            return UserRole.customer;
          default:
            return UserRole.customer;
        }
      }
      return UserRole.customer;
    }).toList();
  }

  static UserStatus _parseUserStatus(String status) {
    switch (status) {
      case 'active':
        return UserStatus.active;
      case 'pending':
        return UserStatus.pending;
      case 'suspended':
        return UserStatus.suspended;
      case 'deleted':
        return UserStatus.deleted;
      default:
        return UserStatus.pending;
    }
  }

  static DocumentType _parseDocumentType(dynamic type) {
    if (type is String) {
      switch (type) {
        case 'national_id':
          return DocumentType.national_id;
        case 'passport':
          return DocumentType.passport;
        case 'proof_of_address':
          return DocumentType.proof_of_address;
        default:
          return DocumentType.other;
      }
    }
    return DocumentType.other;
  }

  // In profile_mngmt_services.dart, update the _parseDocuments method:

  static List<Document> _parseDocuments(List<dynamic> documents) {
    return documents.map((doc) {
      try {
        // Handle mock data case where _id might be "string"
        String id;
        if (doc['_id'] != null) {
          if (doc['_id'] is String && doc['_id'] != 'string') {
            id = doc['_id'];
          } else {
            // Use uploaded_at or generate a new ID for mock data
            id = doc['uploaded_at'] != null
                ? DateTime.parse(
                    doc['uploaded_at'].toString(),
                  ).millisecondsSinceEpoch.toString()
                : DateTime.now().millisecondsSinceEpoch.toString();
          }
        } else {
          id = DateTime.now().millisecondsSinceEpoch.toString();
        }

        return Document(
          id: id,
          type: _parseDocumentType(doc['type']),
          url: doc['url']?.toString() ?? '',
          fileName: doc['file_name']?.toString() ?? '',
          mimeType: doc['mime_type']?.toString() ?? '',
          uploadedAt: DateTime.parse(doc['uploaded_at'].toString()),
          notes: doc['notes']?.toString(),
        );
      } catch (e) {
        DevLogs.logError('Error parsing document: $e, document: $doc');
        return Document(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          type: DocumentType.other,
          url: '',
          fileName: 'Unknown',
          mimeType: 'application/octet-stream',
          uploadedAt: DateTime.now(),
          notes: 'Failed to parse document data',
        );
      }
    }).toList();
  }
}
