// auctions_mngmt_controller.dart
import 'package:get/get.dart';
import 'package:real_time_pawn/features/auctions_mngmt/services/auctions_mngmt_service.dart';
import 'package:real_time_pawn/models/auction_models.dart';
import '../../../core/utils/logs.dart';

class AuctionsController extends GetxController {
  var isLoading = false.obs;
  var isLoadingDetails = false.obs;
  var isLoadingLive = false.obs;

  var successMessage = ''.obs;
  var errorMessage = ''.obs;

  var auctionsList = <Auction>[].obs;
  var pagination = Pagination(page: 1, limit: 10, total: 0, pages: 1).obs;
  var currentPage = 1.obs;

  var selectedAuction = Rxn<Auction>();
  var currentBid = Rxn<Bid>();

  var liveAuctions = <Auction>[].obs;

  var isLoadingSearch = false.obs;
  var isLoadingBids = false.obs;
  var searchResults = <Auction>[].obs;
  var auctionBids = <Bid>[].obs;

  // Flag to prevent multiple simultaneous calls
  bool _isFetching = false;

  /// GET ALL AUCTIONS
  Future<bool> getAuctionsRequest({
    int page = 1,
    int limit = 10,
    String? status,
    String? auctionType,
    String? category,
    String? assetId,
    String? createdFrom,
    String? createdTo,
    String? startsFrom,
    String? startsTo,
    String? endsFrom,
    String? endsTo,
    String? search,
    String? sortBy = 'created_at',
    String? sortOrder = 'desc',
  }) async {
    // Prevent multiple simultaneous calls
    if (_isFetching) return false;

    try {
      _isFetching = true;

      // Use microtask to ensure we're not in build phase
      await Future.microtask(() {
        isLoading.value = true;
        successMessage.value = '';
        errorMessage.value = '';
      });

      final response = await AuctionsServices.getAuctions(
        page: page,
        limit: limit,
        status: status,
        auctionType: auctionType,
        category: category,
        assetId: assetId,
        createdFrom: createdFrom,
        createdTo: createdTo,
        startsFrom: startsFrom,
        startsTo: startsTo,
        endsFrom: endsFrom,
        endsTo: endsTo,
        search: search,
        sortBy: sortBy,
        sortOrder: sortOrder,
      );

      // Use microtask for all state updates
      await Future.microtask(() {
        if (response.success && response.data != null) {
          auctionsList.value = response.data!.auctions;
          pagination.value = response.data!.pagination;
          currentPage.value = page;

          successMessage.value =
              response.message ?? 'Auctions loaded successfully';
          DevLogs.logSuccess(successMessage.value);
        } else {
          errorMessage.value = response.message ?? 'Failed to load auctions';
          DevLogs.logError(errorMessage.value);
        }

        isLoading.value = false;
        _isFetching = false;
      });

      return response.success;
    } catch (e) {
      await Future.microtask(() {
        DevLogs.logError('Error getting auctions: ${e.toString()}');
        errorMessage.value = 'An error occurred: ${e.toString()}';
        isLoading.value = false;
        _isFetching = false;
      });
      return false;
    }
  }

  /// GET AUCTION DETAILS
  Future<bool> getAuctionDetailsRequest({required String auctionId}) async {
    if (_isFetching) return false;

    try {
      _isFetching = true;

      await Future.microtask(() {
        isLoadingDetails.value = true;
        successMessage.value = '';
        errorMessage.value = '';
      });

      final response = await AuctionsServices.getAuctionDetails(
        auctionId: auctionId,
      );

      await Future.microtask(() {
        if (response.success && response.data != null) {
          selectedAuction.value = response.data!.auction;
          currentBid.value = response.data!.currentBid;

          successMessage.value = response.message ?? 'Auction details loaded';
          DevLogs.logSuccess(successMessage.value);
        } else {
          errorMessage.value =
              response.message ?? 'Failed to load auction details';
          DevLogs.logError(errorMessage.value);
        }

        isLoadingDetails.value = false;
        _isFetching = false;
      });

      return response.success;
    } catch (e) {
      await Future.microtask(() {
        DevLogs.logError('Error getting auction details: ${e.toString()}');
        errorMessage.value = 'An error occurred: ${e.toString()}';
        isLoadingDetails.value = false;
        _isFetching = false;
      });
      return false;
    }
  }

  /// GET LIVE AUCTIONS
  Future<bool> getLiveAuctionsRequest({String? category}) async {
    if (_isFetching) return false;

    try {
      _isFetching = true;

      await Future.microtask(() {
        isLoadingLive.value = true;
        successMessage.value = '';
        errorMessage.value = '';
      });

      final response = await AuctionsServices.getLiveAuctions(
        category: category,
      );

      await Future.microtask(() {
        if (response.success && response.data != null) {
          liveAuctions.value = response.data!;

          successMessage.value = response.message ?? 'Live auctions loaded';
          DevLogs.logSuccess(successMessage.value);
        } else {
          errorMessage.value =
              response.message ?? 'Failed to load live auctions';
          DevLogs.logError(errorMessage.value);
        }

        isLoadingLive.value = false;
        _isFetching = false;
      });

      return response.success;
    } catch (e) {
      await Future.microtask(() {
        DevLogs.logError('Error getting live auctions: ${e.toString()}');
        errorMessage.value = 'An error occurred: ${e.toString()}';
        isLoadingLive.value = false;
        _isFetching = false;
      });
      return false;
    }
  }

  /// LOAD MORE AUCTIONS (Pagination)
  Future<bool> loadMoreAuctions({
    String? status,
    String? category,
    String? search,
  }) async {
    if (_isFetching || currentPage.value >= pagination.value.pages) {
      return false;
    }

    try {
      _isFetching = true;
      final nextPage = currentPage.value + 1;

      final response = await AuctionsServices.getAuctions(
        page: nextPage,
        limit: pagination.value.limit,
        status: status,
        category: category,
        search: search,
      );

      await Future.microtask(() {
        if (response.success && response.data != null) {
          auctionsList.addAll(response.data!.auctions);
          pagination.value = response.data!.pagination;
          currentPage.value = nextPage;
          successMessage.value = 'Loaded more auctions';
        } else {
          errorMessage.value =
              response.message ?? 'Failed to load more auctions';
        }
        _isFetching = false;
      });

      return response.success;
    } catch (e) {
      await Future.microtask(() {
        DevLogs.logError('Error loading more auctions: ${e.toString()}');
        errorMessage.value = 'An error occurred: ${e.toString()}';
        _isFetching = false;
      });
      return false;
    }
  }

  /// SEARCH AUCTIONS
  Future<bool> searchAuctionsRequest({
    required String query,
    String? status,
  }) async {
    if (_isFetching) return false;

    try {
      _isFetching = true;

      await Future.microtask(() {
        isLoadingSearch.value = true;
        successMessage.value = '';
        errorMessage.value = '';
      });

      final response = await AuctionsServices.searchAuctions(
        query: query,
        status: status,
      );

      await Future.microtask(() {
        if (response.success && response.data != null) {
          searchResults.value = response.data!;
          successMessage.value =
              response.message ?? 'Search completed successfully';
          DevLogs.logSuccess(successMessage.value);
        } else {
          errorMessage.value = response.message ?? 'Failed to search auctions';
          DevLogs.logError(errorMessage.value);
        }

        isLoadingSearch.value = false;
        _isFetching = false;
      });

      return response.success;
    } catch (e) {
      await Future.microtask(() {
        DevLogs.logError('Error searching auctions: ${e.toString()}');
        errorMessage.value = 'An error occurred: ${e.toString()}';
        isLoadingSearch.value = false;
        _isFetching = false;
      });
      return false;
    }
  }

  /// GET AUCTION BIDS
  Future<bool> getAuctionBidsRequest({required String auctionId}) async {
    if (_isFetching) return false;

    try {
      _isFetching = true;

      await Future.microtask(() {
        isLoadingBids.value = true;
        successMessage.value = '';
        errorMessage.value = '';
      });

      final response = await AuctionsServices.getAuctionBids(
        auctionId: auctionId,
      );

      await Future.microtask(() {
        if (response.success && response.data != null) {
          auctionBids.value = response.data!;
          successMessage.value = response.message ?? 'Bids loaded successfully';
          DevLogs.logSuccess(successMessage.value);
        } else {
          errorMessage.value = response.message ?? 'Failed to load bids';
          DevLogs.logError(errorMessage.value);
        }

        isLoadingBids.value = false;
        _isFetching = false;
      });

      return response.success;
    } catch (e) {
      await Future.microtask(() {
        DevLogs.logError('Error getting auction bids: ${e.toString()}');
        errorMessage.value = 'An error occurred: ${e.toString()}';
        isLoadingBids.value = false;
        _isFetching = false;
      });
      return false;
    }
  }

  /// PLACE BID ON AUCTION
  Future<bool> placeBidRequest({
    required String auctionId,
    required double amount,
  }) async {
    if (_isFetching) return false;

    try {
      _isFetching = true;

      await Future.microtask(() {
        isLoading.value = true;
        successMessage.value = '';
        errorMessage.value = '';
      });

      final response = await AuctionsServices.placeBid(
        auctionId: auctionId,
        amount: amount,
      );

      await Future.microtask(() {
        if (response.success && response.data != null) {
          successMessage.value = response.message ?? 'Bid placed successfully';
          DevLogs.logSuccess(successMessage.value);
        } else {
          // Check for specific server error
          final errorMsg = response.message ?? 'Failed to place bid';
          if (errorMsg.contains('next is not a function')) {
            errorMessage.value =
                'Server is temporarily unavailable. Please try again in a few minutes.';
          } else {
            errorMessage.value = errorMsg;
          }
          DevLogs.logError(errorMessage.value);
        }

        isLoading.value = false;
        _isFetching = false;
      });

      return response.success;
    } catch (e) {
      await Future.microtask(() {
        DevLogs.logError('Error placing bid: ${e.toString()}');
        errorMessage.value = 'An error occurred: ${e.toString()}';
        isLoading.value = false;
        _isFetching = false;
      });
      return false;
    }
  }

  /// CLEAR SEARCH RESULTS
  void clearSearchResults() {
    searchResults.value = [];
  }

  /// CLEAR BIDS
  void clearBids() {
    auctionBids.value = [];
  }

  /// CLEAR SELECTED AUCTION
  void clearSelectedAuction() {
    selectedAuction.value = null;
    currentBid.value = null;
  }

  /// CLEAR MESSAGES
  void clearMessages() {
    successMessage.value = '';
    errorMessage.value = '';
  }

  /// REFRESH ALL AUCTIONS
  Future<void> refreshAuctions({
    String? status,
    String? category,
    String? search,
  }) async {
    await getAuctionsRequest(
      page: 1,
      status: status,
      category: category,
      search: search,
    );
  }
}
