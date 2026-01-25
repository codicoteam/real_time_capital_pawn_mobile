import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:real_time_pawn/config/routers/router.dart';
import 'package:real_time_pawn/core/utils/pallete.dart';
import 'package:real_time_pawn/features/auctions_mngmt/controllers/auctions_mngmt_controller.dart';
import 'package:real_time_pawn/models/auction_models.dart';
import 'package:real_time_pawn/widgets/loading_widgets/circular_loader.dart';

class AuctionsHelper {
  static final AuctionsController _auctionsController =
      Get.find<AuctionsController>();

  /// LOAD AUCTIONS WITH FILTERS - FIXED VERSION
  static Future<bool> loadAuctions({
    int page = 1,
    String? status,
    String? category,
    String? search,
    bool showLoader = true,
  }) async {
    if (showLoader) {
      // FIX: Show dialog AFTER build
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (Get.isDialogOpen != true) {
          Get.dialog(
            const CustomLoader(message: 'Loading auctions...'),
            barrierDismissible: false,
          );
        }
      });
    }

    try {
      final success = await _auctionsController.getAuctionsRequest(
        page: page,
        status: status,
        category: category,
        search: search,
      );

      // FIX: Close dialog AFTER build
      if (showLoader) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (Get.isDialogOpen == true) {
            Get.back();
          }
        });
      }

      if (success) {
        return true;
      } else {
        showError(_auctionsController.errorMessage.value);
        return false;
      }
    } catch (e) {
      // FIX: Close dialog AFTER build
      if (showLoader) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (Get.isDialogOpen == true) {
            Get.back();
          }
        });
      }
      showError('Failed to load auctions: ${e.toString()}');
      return false;
    }
  }

  /// LOAD AUCTION DETAILS - FIXED VERSION
  static Future<bool> loadAuctionDetails({required String auctionId}) async {
    // FIX: Show dialog AFTER build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (Get.isDialogOpen != true) {
        Get.dialog(
          const CustomLoader(message: 'Loading auction details...'),
          barrierDismissible: false,
        );
      }
    });

    try {
      final success = await _auctionsController.getAuctionDetailsRequest(
        auctionId: auctionId,
      );

      // FIX: Close dialog AFTER build
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (Get.isDialogOpen == true) {
          Get.back();
        }
      });

      if (success) {
        return true;
      } else {
        showError(_auctionsController.errorMessage.value);
        return false;
      }
    } catch (e) {
      // FIX: Close dialog AFTER build
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (Get.isDialogOpen == true) {
          Get.back();
        }
      });
      showError('Failed to load auction details: ${e.toString()}');
      return false;
    }
  }

  /// LOAD LIVE AUCTIONS - FIXED VERSION
  static Future<bool> loadLiveAuctions({
    String? category,
    bool showLoader = true,
  }) async {
    if (showLoader) {
      // FIX: Show dialog AFTER build
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (Get.isDialogOpen != true) {
          Get.dialog(
            const CustomLoader(message: 'Loading live auctions...'),
            barrierDismissible: false,
          );
        }
      });
    }

    try {
      final success = await _auctionsController.getLiveAuctionsRequest(
        category: category,
      );

      // FIX: Close dialog AFTER build
      if (showLoader) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (Get.isDialogOpen == true) {
            Get.back();
          }
        });
      }

      if (success) {
        return true;
      } else {
        showError(_auctionsController.errorMessage.value);
        return false;
      }
    } catch (e) {
      // FIX: Close dialog AFTER build
      if (showLoader) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (Get.isDialogOpen == true) {
            Get.back();
          }
        });
      }
      showError('Failed to load live auctions: ${e.toString()}');
      return false;
    }
  }

  /// NAVIGATE TO AUCTION DETAILS - FIXED VERSION
  /// NAVIGATE TO AUCTION DETAILS - OPTIMIZED VERSION
  static Future<void> navigateToAuctionDetails({
    required String auctionId,
    required BuildContext context,
  }) async {
    print('🔍 NAVIGATING WITH ID: "$auctionId"');

    if (auctionId == ":id") {
      print('❌❌❌ ERROR: Cannot use ":id" - this is a placeholder!');

      if (_auctionsController.auctionsList.isNotEmpty) {
        auctionId = _auctionsController.auctionsList.first.id;
        print('🔄 Using real ID instead: $auctionId');
      } else {
        showError('No auctions available');
        return;
      }
    }

    // CHECK 1: Prevent duplicate navigation
    if (_isNavigating) {
      print('⚠️ Already navigating, skipping...');
      return;
    }

    // CHECK 2: Check if we already have this auction loaded
    final alreadyLoaded =
        _auctionsController.selectedAuction.value?.id == auctionId;

    _isNavigating = true;

    try {
      // Only load if not already loaded
      if (!alreadyLoaded) {
        final success = await loadAuctionDetails(auctionId: auctionId);
        if (!success) return;
      }

      // Navigate to the details screen
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Get.toNamed(
          RoutesHelper.auctionDetailsScreen.replaceFirst(':id', auctionId),
        );
      });
    } finally {
      // Reset the flag after a short delay
      Future.delayed(const Duration(milliseconds: 500), () {
        _isNavigating = false;
      });
    }
  }

  static bool _isNavigating = false;

  /// STATUS COLOR HELPER
  static Color getStatusColor(AuctionStatus status) {
    switch (status) {
      case AuctionStatus.live:
        return RealTimeColors.success;
      case AuctionStatus.upcoming:
        return RealTimeColors.warning;
      case AuctionStatus.closed:
        return RealTimeColors.error;
      case AuctionStatus.draft:
        return RealTimeColors.grey500;
    }
  }

  /// STATUS TEXT HELPER
  static String getStatusText(AuctionStatus status) {
    switch (status) {
      case AuctionStatus.live:
        return 'LIVE';
      case AuctionStatus.upcoming:
        return 'UPCOMING';
      case AuctionStatus.closed:
        return 'CLOSED';
      case AuctionStatus.draft:
        return 'DRAFT';
    }
  }

  /// AUCTION TYPE TEXT HELPER
  static String getAuctionTypeText(AuctionType type) {
    switch (type) {
      case AuctionType.in_person:
        return 'In-person';
      case AuctionType.online:
        return 'Online';
      case AuctionType.hybrid:
        return 'Hybrid';
    }
  }

  /// CATEGORY DISPLAY TEXT HELPER
  static String getCategoryDisplayText(String backendCategory) {
    switch (backendCategory.toLowerCase()) {
      case 'electronics':
        return 'Electronics';
      case 'vehicle':
        return 'Vehicle';
      case 'jewellery':
        return 'Jewellery';
      case 'art':
        return 'Art';
      case 'real_estate':
        return 'Real Estate';
      default:
        return backendCategory.replaceAll('_', ' ').toTitleCase();
    }
  }

  /// SHOW ERROR - FIXED VERSION
  static void showError(String message) {
    // FIX: Show snackbar AFTER build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Get.snackbar(
        'Error',
        message,
        snackPosition: SnackPosition.TOP,
        backgroundColor: AppColors.errorColor,
        colorText: Colors.white,
        borderRadius: 12,
        margin: const EdgeInsets.all(16),
        duration: 3.seconds,
      );
    });
  }

  /// SHOW SUCCESS - FIXED VERSION
  static void showSuccess(String message) {
    // FIX: Show snackbar AFTER build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Get.snackbar(
        'Success',
        message,
        snackPosition: SnackPosition.TOP,
        backgroundColor: AppColors.successColor,
        colorText: Colors.white,
        borderRadius: 12,
        margin: const EdgeInsets.all(16),
        duration: 2.seconds,
      );
    });
  }

  /// SIMPLER FIX: Use Future.delayed as alternative
  static Future<bool> simpleLoadAuctionDetails({
    required String auctionId,
  }) async {
    // Alternative: Use Future.delayed instead of addPostFrameCallback
    Future.delayed(Duration.zero, () {
      if (Get.isDialogOpen != true) {
        Get.dialog(
          const CustomLoader(message: 'Loading auction details...'),
          barrierDismissible: false,
        );
      }
    });

    try {
      final success = await _auctionsController.getAuctionDetailsRequest(
        auctionId: auctionId,
      );

      Future.delayed(Duration.zero, () {
        if (Get.isDialogOpen == true) {
          Get.back();
        }
      });

      return success;
    } catch (e) {
      Future.delayed(Duration.zero, () {
        if (Get.isDialogOpen == true) {
          Get.back();
        }
      });
      showError('Failed to load auction details: ${e.toString()}');
      return false;
    }
  }
}

// Add to auctions_mngmt_helper.dart

/// NAVIGATE TO SEARCH SCREEN
static void navigateToSearchScreen(BuildContext context) {
  WidgetsBinding.instance.addPostFrameCallback((_) {
    Get.to(() => const SearchAuctionsScreen());
  });
}

/// NAVIGATE TO BIDS SCREEN
static void navigateToBidsScreen({
  required String auctionId,
  required String auctionTitle,
  required BuildContext context,
}) {
  WidgetsBinding.instance.addPostFrameCallback((_) {
    Get.to(() => AuctionBidsScreen(
      auctionId: auctionId,
      auctionTitle: auctionTitle,
    ));
  });
}

extension StringExtension on String {
  String toTitleCase() {
    if (isEmpty) return this;
    return split('_')
        .map(
          (word) => word.isNotEmpty
              ? '${word[0].toUpperCase()}${word.substring(1).toLowerCase()}'
              : '',
        )
        .join(' ');
  }
}
