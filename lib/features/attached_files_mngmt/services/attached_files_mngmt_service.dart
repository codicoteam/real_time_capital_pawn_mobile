import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:real_time_pawn/config/api_config/api_keys.dart';
import '../../../core/utils/api_response.dart';
import '../../../core/utils/logs.dart';
import '../../../core/utils/shared_pref_methods.dart';
import '../../../models/attachment_model.dart';

class AttachmentService {
  /// 🔹 Fetch attachments by userId and entityType
  static Future<APIResponse<List<AttachmentModel>>>
  getAttachmentsByUserAndEntity({
    required String userId,
    required String entityType,
  }) async {
    final token = await CacheUtils.checkToken();

    final String url =
        '${ApiKeys.baseUrl}/attachments/user/$userId/entity/$entityType';

    final headers = {
      'Authorization': 'Bearer $token',
      'Accept': 'application/json',
    };

    try {
      final response = await http.get(Uri.parse(url), headers: headers);

      DevLogs.logInfo('Attachments response: ${response.body}');

      if (response.statusCode == 200) {
        final decoded = json.decode(response.body);

        final List<dynamic> data = decoded['data'] ?? [];

        final attachments = data
            .map(
              (item) => AttachmentModel.fromMap(item as Map<String, dynamic>),
            )
            .toList();

        return APIResponse<List<AttachmentModel>>(
          success: true,
          data: attachments,
          message: decoded['message'] ?? 'Attachments retrieved successfully',
        );
      } else {
        return APIResponse<List<AttachmentModel>>(
          success: false,
          message: 'Failed to fetch attachments. HTTP ${response.statusCode}',
        );
      }
    } catch (e) {
      DevLogs.logError('Fetch attachments error: $e');
      return APIResponse<List<AttachmentModel>>(
        success: false,
        message: 'Error fetching attachments: $e',
      );
    }
  }

  /// 🔹 Upload / Create attachment (multipart/form-data)
  static Future<APIResponse<AttachmentModel>> uploadAttachment({
    required String entityType,
    required String entityId,
    required String category,
    required String filename,
    required String mimeType,
    required String storage,
    required String url,
    required bool signed,
    required String meta,
    File? file,
  }) async {
    final token = await CacheUtils.checkToken();

    final uri = Uri.parse('${ApiKeys.baseUrl}/attachments/upload');

    try {
      final request = http.MultipartRequest('POST', uri);

      request.headers.addAll({
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
      });

      /// Form fields
      request.fields['entity_type'] = entityType;
      request.fields['entity_id'] = entityId;
      request.fields['category'] = category;
      request.fields['filename'] = filename;
      request.fields['mime_type'] = mimeType;
      request.fields['storage'] = storage;
      request.fields['url'] = url;
      request.fields['signed'] = signed.toString();
      request.fields['meta'] = meta;

      /// Optional file
      if (file != null) {
        request.files.add(await http.MultipartFile.fromPath('file', file.path));
      }

      final streamedResponse = await request.send();
      final responseBody = await streamedResponse.stream.bytesToString();

      DevLogs.logInfo('Upload attachment response: $responseBody');

      if (streamedResponse.statusCode == 200 ||
          streamedResponse.statusCode == 201) {
        final decoded = json.decode(responseBody);

        final attachment = AttachmentModel.fromMap(decoded['data']);

        return APIResponse<AttachmentModel>(
          success: true,
          data: attachment,
          message: decoded['message'] ?? 'Attachment uploaded successfully',
        );
      } else {
        return APIResponse<AttachmentModel>(
          success: false,
          message: 'Upload failed. HTTP ${streamedResponse.statusCode}',
        );
      }
    } catch (e) {
      DevLogs.logError('Upload attachment error: $e');
      return APIResponse<AttachmentModel>(
        success: false,
        message: 'Error uploading attachment: $e',
      );
    }
  }
}
