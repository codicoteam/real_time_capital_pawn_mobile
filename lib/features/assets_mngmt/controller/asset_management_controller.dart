import 'package:get/get.dart';
import 'package:real_time_pawn/core/utils/api_response.dart';
import 'package:real_time_pawn/core/utils/logs.dart';
import 'package:real_time_pawn/features/assets_mngmt/services/asset_management_service.dart';
import 'package:real_time_pawn/models/asset_model.dart';

class AssetController extends GetxController {
  // Loading states
  var isLoading = false.obs;
  var isCreating = false.obs;
  var isFetching = false.obs;
  var isSearching = false.obs;

  // Data
  var assets = <AssetModel>[].obs;
  var selectedAsset = Rxn<AssetModel>();

  // Pagination
  var currentPage = 1.obs;
  var totalPages = 1.obs;
  var totalAssets = 0.obs;
  var hasMorePages = false.obs;
  var hasNextPage = false.obs;
  var hasPrevPage = false.obs;

  // Filters
  var selectedCategory = RxnString();
  var selectedStatus = RxnString();
  var searchQuery = ''.obs;

  // Messages
  var successMessage = ''.obs;
  var errorMessage = ''.obs;

  /// 1. CREATE ASSET
  Future<bool> createAsset({
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
    try {
      isCreating(true);
      clearMessages();

      final response = await AssetService.createAsset(
        category: category,
        title: title,
        ownerUserId: ownerUserId,
        assetType: assetType,
        description: description,
        condition: condition,
        declaredValue: declaredValue,
        storageLocation: storageLocation,
        brand: brand,
        model: model,
        serialNo: serialNo,
        accessories: accessories,
        make: make,
        registrationNo: registrationNo,
        engineNo: engineNo,
        chassisNo: chassisNo,
        ccSerialNo: ccSerialNo,
        jewelryType: jewelryType,
        material: material,
        weight: weight,
        purity: purity,
        estimatedValue: estimatedValue,
      );

      if (response.success && response.data != null) {
        // Add to beginning of list
        assets.insert(0, response.data!);
        successMessage.value = response.message ?? 'Asset created successfully';
        DevLogs.logSuccess(successMessage.value);
        return true;
      } else {
        errorMessage.value = response.message ?? 'Failed to create asset';
        DevLogs.logError(errorMessage.value);
        return false;
      }
    } catch (e) {
      errorMessage.value = 'Error creating asset: ${e.toString()}';
      DevLogs.logError(errorMessage.value);
      return false;
    } finally {
      isCreating(false);
    }
  }

  /// 2. FETCH ASSETS (with pagination)
  Future<bool> fetchAssets({
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
    bool resetList = true,
  }) async {
    try {
      if (resetList) {
        isLoading(true);
      } else {
        isFetching(true);
      }
      clearMessages();

      final response = await AssetService.getAssets(
        page: page,
        limit: limit,
        category: category ?? selectedCategory.value,
        status: status ?? selectedStatus.value,
        ownerUserId: ownerUserId,
        assetNo: assetNo,
        title:
            title ?? (searchQuery.value.isNotEmpty ? searchQuery.value : null),
        createdFrom: createdFrom,
        createdTo: createdTo,
        sortBy: sortBy,
        sortOrder: sortOrder,
      );

      if (response.success && response.data != null) {
        if (resetList) {
          assets.value = response.data!.assets;
        } else {
          assets.addAll(response.data!.assets);
        }

        currentPage.value = response.data!.pagination.page;
        totalPages.value = response.data!.pagination.pages;
        totalAssets.value = response.data!.pagination.total;
        hasNextPage.value = response.data!.pagination.hasNextPage;
        hasPrevPage.value = response.data!.pagination.hasPrevPage;
        hasMorePages.value = response.data!.pagination.hasNextPage;

        successMessage.value = response.message ?? 'Assets loaded';
        return true;
      } else {
        errorMessage.value = response.message ?? 'Failed to load assets';
        return false;
      }
    } catch (e) {
      errorMessage.value = 'Error loading assets: ${e.toString()}';
      return false;
    } finally {
      isLoading(false);
      isFetching(false);
    }
  }

  /// Load next page
  Future<bool> loadMoreAssets() async {
    if (!hasMorePages.value || isFetching.value) return false;
    return await fetchAssets(page: currentPage.value + 1, resetList: false);
  }

  /// Refresh assets
  Future<bool> refreshAssets() async {
    return await fetchAssets(resetList: true);
  }

  /// 3. GET ASSET BY ID
  Future<bool> getAssetById(String assetId) async {
    try {
      isLoading(true);
      clearMessages();

      final response = await AssetService.getAssetById(assetId);

      if (response.success && response.data != null) {
        selectedAsset.value = response.data!;
        successMessage.value = response.message ?? 'Asset loaded';
        return true;
      } else {
        errorMessage.value = response.message ?? 'Failed to load asset';
        return false;
      }
    } catch (e) {
      errorMessage.value = 'Error loading asset: ${e.toString()}';
      return false;
    } finally {
      isLoading(false);
    }
  }

  /// 4. SEARCH ASSETS
  Future<bool> searchAssets(String query) async {
    try {
      isSearching(true);
      clearMessages();

      searchQuery.value = query;

      final response = await AssetService.searchAssets(query);

      if (response.success && response.data != null) {
        assets.value = response.data!;
        return true;
      } else {
        errorMessage.value = response.message ?? 'No assets found';
        return false;
      }
    } catch (e) {
      errorMessage.value = 'Error searching assets: ${e.toString()}';
      return false;
    } finally {
      isSearching(false);
    }
  }

  /// 5. GET ALL ASSETS (without pagination)
  Future<bool> getAllAssets() async {
    try {
      isLoading(true);
      clearMessages();

      final response = await AssetService.getAllAssets();

      if (response.success && response.data != null) {
        assets.value = response.data!;
        return true;
      } else {
        errorMessage.value = response.message ?? 'Failed to load assets';
        return false;
      }
    } catch (e) {
      errorMessage.value = 'Error loading assets: ${e.toString()}';
      return false;
    } finally {
      isLoading(false);
    }
  }

  /// Filter by category
  void filterByCategory(String? category) {
    selectedCategory.value = category;
    refreshAssets();
  }

  /// Filter by status
  void filterByStatus(String? status) {
    selectedStatus.value = status;
    refreshAssets();
  }

  /// Clear search and filters
  void clearSearch() {
    searchQuery.value = '';
    selectedCategory.value = null;
    selectedStatus.value = null;
    refreshAssets();
  }

  /// Get assets for current user
  Future<bool> getMyAssets(String userId) async {
    return await fetchAssets(ownerUserId: userId, resetList: true);
  }

  /// Clear messages
  void clearMessages() {
    successMessage.value = '';
    errorMessage.value = '';
  }
}
