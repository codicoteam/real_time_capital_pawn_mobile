import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:real_time_pawn/core/utils/pallete.dart';
import 'package:real_time_pawn/features/assets_mngmt/controller/asset_management_controller.dart';
import 'package:real_time_pawn/models/asset_model.dart';

class AssetHelper {
  static final AssetController _controller = Get.put(AssetController());

  /// CREATE ASSET
  static Future<bool> createAsset({
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
    bool showLoader = true,
  }) async {
    if (title.isEmpty) {
      showError('Please enter a title');
      return false;
    }

    if (description.isEmpty) {
      showError('Please enter a description');
      return false;
    }

    if (showLoader) {
      showLoading('Creating asset...');
    }

    try {
      final success = await _controller.createAsset(
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

      if (showLoader) {
        Get.back();
      }

      if (success) {
        showSuccess(_controller.successMessage.value);
        return true;
      } else {
        showError(_controller.errorMessage.value);
        return false;
      }
    } catch (e) {
      if (showLoader) {
        Get.back();
      }
      showError('Failed to create asset: ${e.toString()}');
      return false;
    }
  }

  /// FETCH ASSETS
  static Future<bool> fetchAssets({
    int page = 1,
    int limit = 10,
    String? category,
    String? status,
    String? ownerUserId,
    bool showLoader = true,
  }) async {
    if (showLoader) {
      showLoading('Loading assets...');
    }

    try {
      final success = await _controller.fetchAssets(
        page: page,
        limit: limit,
        category: category,
        status: status,
        ownerUserId: ownerUserId,
        resetList: true,
      );

      if (showLoader) {
        Get.back();
      }

      if (success) {
        if (!showLoader) {
          showSuccess('Assets loaded successfully');
        }
        return true;
      } else {
        showError(_controller.errorMessage.value);
        return false;
      }
    } catch (e) {
      if (showLoader) {
        Get.back();
      }
      showError('Failed to load assets: ${e.toString()}');
      return false;
    }
  }

  /// GET MY ASSETS
  static Future<bool> getMyAssets(
    String userId, {
    bool showLoader = true,
  }) async {
    if (userId.isEmpty) {
      showError('User ID not found');
      return false;
    }

    if (showLoader) {
      showLoading('Loading your assets...');
    }

    try {
      final success = await _controller.getMyAssets(userId);

      if (showLoader) {
        Get.back();
      }

      if (success) {
        if (!showLoader) {
          showSuccess('Your assets loaded');
        }
        return true;
      } else {
        showError(_controller.errorMessage.value);
        return false;
      }
    } catch (e) {
      if (showLoader) {
        Get.back();
      }
      showError('Failed to load assets: ${e.toString()}');
      return false;
    }
  }

  /// GET ASSET BY ID
  static Future<AssetModel?> getAssetById(String assetId) async {
    showLoading('Loading asset details...');

    try {
      final success = await _controller.getAssetById(assetId);

      Get.back();

      if (success) {
        return _controller.selectedAsset.value;
      } else {
        showError(_controller.errorMessage.value);
        return null;
      }
    } catch (e) {
      Get.back();
      showError('Failed to load asset: ${e.toString()}');
      return null;
    }
  }

  /// SEARCH ASSETS
  static Future<List<AssetModel>?> searchAssets(String query) async {
    if (query.length < 2) {
      showError('Search term must be at least 2 characters');
      return null;
    }

    showLoading('Searching assets...');

    try {
      final success = await _controller.searchAssets(query);

      Get.back();

      if (success) {
        return _controller.assets;
      } else {
        showError(_controller.errorMessage.value);
        return null;
      }
    } catch (e) {
      Get.back();
      showError('Failed to search assets: ${e.toString()}');
      return null;
    }
  }

  /// LOAD MORE ASSETS
  static Future<bool> loadMoreAssets() async {
    return await _controller.loadMoreAssets();
  }

  /// REFRESH ASSETS
  static Future<bool> refreshAssets() async {
    return await _controller.refreshAssets();
  }

  /// GET ASSET STATUS COLOR
  static Color getAssetStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'submitted':
        return Colors.orange;
      case 'valuating':
        return Colors.blue;
      case 'pawned':
        return Colors.green;
      case 'auction':
        return Colors.purple;
      case 'sold':
        return Colors.brown;
      case 'redeemed':
        return Colors.teal;
      case 'closed':
        return Colors.grey;
      case 'overdue':
        return Colors.red;
      default:
        return AppColors.subtextColor;
    }
  }

  /// GET ASSET STATUS ICON
  static IconData getAssetStatusIcon(String status) {
    switch (status.toLowerCase()) {
      case 'submitted':
        return Icons.pending_outlined;
      case 'valuating':
        return Icons.assessment_outlined;
      case 'pawned':
        return Icons.attach_money_outlined;
      case 'auction':
        return Icons.gavel_rounded;
      case 'sold':
        return Icons.shopping_cart_outlined;
      case 'redeemed':
        return Icons.assignment_returned_outlined;
      case 'closed':
        return Icons.check_circle_outline;
      case 'overdue':
        return Icons.warning_amber_outlined;
      default:
        return Icons.help_outline;
    }
  }

  /// GET ASSET CATEGORY ICON
  static IconData getAssetCategoryIcon(String category) {
    switch (category.toLowerCase()) {
      case 'electronics':
        return Icons.devices;
      case 'vehicle':
        return Icons.directions_car;
      case 'jewellery':
        return Icons.diamond;
      default:
        return Icons.category_outlined;
    }
  }

  /// FORMAT CURRENCY
  static String formatCurrency(num amount) {
    return '\$${amount.toStringAsFixed(2)}';
  }

  /// SHOW LOADING DIALOG
  static void showLoading(String message) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (Get.isDialogOpen != true) {
        Get.dialog(
          Dialog(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircularProgressIndicator(color: AppColors.primaryColor),
                  const SizedBox(width: 20),
                  Text(
                    message,
                    style: TextStyle(fontSize: 16, color: AppColors.textColor),
                  ),
                ],
              ),
            ),
          ),
          barrierDismissible: false,
        );
      }
    });
  }

  /// SHOW ERROR MESSAGE
  static void showError(String message) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Get.snackbar(
        'Error',
        message,
        snackPosition: SnackPosition.TOP,
        backgroundColor: AppColors.errorColor,
        colorText: Colors.white,
        borderRadius: 12,
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 3),
      );
    });
  }

  /// SHOW SUCCESS MESSAGE
  static void showSuccess(String message) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Get.snackbar(
        'Success',
        message,
        snackPosition: SnackPosition.TOP,
        backgroundColor: AppColors.successColor,
        colorText: Colors.white,
        borderRadius: 12,
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 2),
      );
    });
  }
}
