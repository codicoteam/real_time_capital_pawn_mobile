import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:real_time_pawn/config/api_config/api_keys.dart';
import '../../../core/utils/api_response.dart';
import '../../../core/utils/logs.dart';
import '../../../core/utils/shared_pref_methods.dart';
import '../../../models/asset_model.dart';

class AssetService {
  /// 1. CREATE ASSET
  /// POST /api/v1/assets
  static Future<APIResponse<AssetModel>> createAsset({
    required String category,
    required String title,
    required String ownerUserId,
    required String assetType,
    required String description,
    required String condition,
    num? declaredValue,
    String? storageLocation,
    // Electronics fields
    String? brand,
    String? model,
    String? serialNo,
    List<String>? accessories,
    // Vehicle fields
    String? make,
    String? registrationNo,
    String? engineNo,
    String? chassisNo,
    String? ccSerialNo,
    // Jewellery fields
    String? jewelryType,
    String? material,
    double? weight,
    String? purity,
    double? estimatedValue,
  }) async {
    final token = await CacheUtils.checkToken();
    if (token == null || token.isEmpty) {
      return APIResponse(
        success: false,
        message: 'Authentication required',
        data: null,
      );
    }

    final headers = {
      'accept': 'application/json',
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
    };

    final body = json.encode({
      'category': category,
      'title': title,
      'owner_user': ownerUserId,
      'asset_type': assetType,
      'description': description,
      'condition': condition,
      'declared_value': declaredValue,
      'storage_location': storageLocation,
      // Electronics fields
      if (brand != null) 'brand': brand,
      if (model != null) 'model': model,
      if (serialNo != null) 'serial_no': serialNo,
      if (accessories != null) 'accessories': accessories,
      // Vehicle fields
      if (make != null) 'make': make,
      if (registrationNo != null) 'registration_no': registrationNo,
      if (engineNo != null) 'engine_no': engineNo,
      if (chassisNo != null) 'chassis_no': chassisNo,
      if (ccSerialNo != null) 'cc_serial_no': ccSerialNo,
      // Jewellery fields
      if (jewelryType != null) 'type': jewelryType,
      if (material != null) 'material': material,
      if (weight != null) 'weight': weight,
      if (purity != null) 'purity': purity,
      if (estimatedValue != null) 'estimated_value': estimatedValue,
    });

    final uri = Uri.parse('${ApiKeys.baseUrl}/assets');

    DevLogs.logInfo('Creating asset: $uri');

    try {
      final response = await http.post(uri, headers: headers, body: body);
      final responseData = json.decode(response.body);

      DevLogs.logInfo('Create asset response: ${response.statusCode}');

      if (response.statusCode >= 200 && response.statusCode < 300) {
        if (responseData['success'] == true) {
          final asset = AssetModel.fromMap(responseData['data']);
          return APIResponse(
            success: true,
            data: asset,
            message: responseData['message'] ?? 'Asset created successfully',
          );
        }
      }

      return APIResponse(
        success: false,
        message: responseData['message'] ?? 'Failed to create asset',
        data: null,
      );
    } catch (e) {
      DevLogs.logError('Error creating asset: $e');
      return APIResponse(
        success: false,
        message: 'Error creating asset: ${e.toString()}',
        data: null,
      );
    }
  }

  /// 2. GET ASSETS (with pagination)
  /// GET /api/v1/assets
  static Future<APIResponse<AssetResponse>> getAssets({
    int page = 1,
    int limit = 10,
    String? category,
    String? status,
    String? ownerUserId,
    String? assetNo,
    String? title,
    DateTime? createdFrom,
    DateTime? createdTo,
    String sortBy = 'created_at',
    String sortOrder = 'desc',
  }) async {
    final token = await CacheUtils.checkToken();
    if (token == null || token.isEmpty) {
      return APIResponse(
        success: false,
        message: 'Authentication required',
        data: null,
      );
    }

    final headers = {
      'accept': 'application/json',
      'Authorization': 'Bearer $token',
    };

    final params = <String, String>{
      'page': page.toString(),
      'limit': limit.toString(),
      'sort_by': sortBy,
      'sort_order': sortOrder,
      if (category != null && category.isNotEmpty) 'category': category,
      if (status != null && status.isNotEmpty) 'status': status,
      if (ownerUserId != null && ownerUserId.isNotEmpty)
        'owner_user': ownerUserId,
      if (assetNo != null && assetNo.isNotEmpty) 'asset_no': assetNo,
      if (title != null && title.isNotEmpty) 'title': title,
      if (createdFrom != null) 'created_from': createdFrom.toIso8601String(),
      if (createdTo != null) 'created_to': createdTo.toIso8601String(),
    };

    final uri = Uri.parse(
      '${ApiKeys.baseUrl}/assets',
    ).replace(queryParameters: params);

    DevLogs.logInfo('Fetching assets: $uri');

    try {
      final response = await http.get(uri, headers: headers);
      final responseData = json.decode(response.body);

      DevLogs.logInfo('Get assets response: ${response.statusCode}');

      if (response.statusCode >= 200 && response.statusCode < 300) {
        if (responseData['success'] == true) {
          final assetResponse = AssetResponse.fromJson(responseData);
          return APIResponse(
            success: true,
            data: assetResponse,
            message: responseData['message'] ?? 'Assets retrieved successfully',
          );
        }
      }

      return APIResponse(
        success: false,
        message: responseData['message'] ?? 'Failed to fetch assets',
        data: null,
      );
    } catch (e) {
      DevLogs.logError('Error fetching assets: $e');
      return APIResponse(
        success: false,
        message: 'Error fetching assets: ${e.toString()}',
        data: null,
      );
    }
  }

  /// 3. GET ASSET BY ID
  /// GET /api/v1/assets/{id}
  static Future<APIResponse<AssetModel>> getAssetById(String assetId) async {
    final token = await CacheUtils.checkToken();
    if (token == null || token.isEmpty) {
      return APIResponse(
        success: false,
        message: 'Authentication required',
        data: null,
      );
    }

    final headers = {
      'accept': 'application/json',
      'Authorization': 'Bearer $token',
    };

    final uri = Uri.parse('${ApiKeys.baseUrl}/assets/$assetId');

    DevLogs.logInfo('Fetching asset details: $uri');

    try {
      final response = await http.get(uri, headers: headers);
      final responseData = json.decode(response.body);

      DevLogs.logInfo('Get asset response: ${response.statusCode}');

      if (response.statusCode >= 200 && response.statusCode < 300) {
        if (responseData['success'] == true) {
          final asset = AssetModel.fromMap(responseData['data']);
          return APIResponse(
            success: true,
            data: asset,
            message: responseData['message'] ?? 'Asset retrieved successfully',
          );
        }
      }

      return APIResponse(
        success: false,
        message: responseData['message'] ?? 'Failed to fetch asset',
        data: null,
      );
    } catch (e) {
      DevLogs.logError('Error fetching asset: $e');
      return APIResponse(
        success: false,
        message: 'Error fetching asset: ${e.toString()}',
        data: null,
      );
    }
  }

  /// 4. SEARCH ASSETS
  /// GET /api/v1/assets/search
  static Future<APIResponse<List<AssetModel>>> searchAssets(
    String query,
  ) async {
    final token = await CacheUtils.checkToken();
    if (token == null || token.isEmpty) {
      return APIResponse(
        success: false,
        message: 'Authentication required',
        data: null,
      );
    }

    if (query.length < 2) {
      return APIResponse(
        success: false,
        message: 'Search term must be at least 2 characters',
        data: null,
      );
    }

    final headers = {
      'accept': 'application/json',
      'Authorization': 'Bearer $token',
    };

    final uri = Uri.parse(
      '${ApiKeys.baseUrl}/assets/search',
    ).replace(queryParameters: {'q': query});

    DevLogs.logInfo('Searching assets: $uri');

    try {
      final response = await http.get(uri, headers: headers);
      final responseData = json.decode(response.body);

      DevLogs.logInfo('Search assets response: ${response.statusCode}');

      if (response.statusCode >= 200 && response.statusCode < 300) {
        if (responseData['success'] == true) {
          final assets = List<AssetModel>.from(
            (responseData['data'] as List).map((x) => AssetModel.fromMap(x)),
          );
          return APIResponse(
            success: true,
            data: assets,
            message: responseData['message'] ?? 'Search completed',
          );
        }
      }

      return APIResponse(
        success: false,
        message: responseData['message'] ?? 'No assets found',
        data: null,
      );
    } catch (e) {
      DevLogs.logError('Error searching assets: $e');
      return APIResponse(
        success: false,
        message: 'Error searching assets: ${e.toString()}',
        data: null,
      );
    }
  }

  /// 5. GET ALL ASSETS (without pagination)
  /// GET /api/v1/assets/all
  static Future<APIResponse<List<AssetModel>>> getAllAssets() async {
    final token = await CacheUtils.checkToken();
    if (token == null || token.isEmpty) {
      return APIResponse(
        success: false,
        message: 'Authentication required',
        data: null,
      );
    }

    final headers = {
      'accept': 'application/json',
      'Authorization': 'Bearer $token',
    };

    final uri = Uri.parse('${ApiKeys.baseUrl}/assets/all');

    DevLogs.logInfo('Fetching all assets: $uri');

    try {
      final response = await http.get(uri, headers: headers);
      final responseData = json.decode(response.body);

      DevLogs.logInfo('Get all assets response: ${response.statusCode}');

      if (response.statusCode >= 200 && response.statusCode < 300) {
        if (responseData['success'] == true) {
          final assets = List<AssetModel>.from(
            (responseData['data'] as List).map((x) => AssetModel.fromMap(x)),
          );
          return APIResponse(
            success: true,
            data: assets,
            message: responseData['message'] ?? 'Assets retrieved successfully',
          );
        }
      }

      return APIResponse(
        success: false,
        message: responseData['message'] ?? 'Failed to fetch assets',
        data: null,
      );
    } catch (e) {
      DevLogs.logError('Error fetching all assets: $e');
      return APIResponse(
        success: false,
        message: 'Error fetching assets: ${e.toString()}',
        data: null,
      );
    }
  }
}
