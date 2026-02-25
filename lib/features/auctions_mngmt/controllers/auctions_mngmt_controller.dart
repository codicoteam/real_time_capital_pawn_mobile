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
    try {
      isLoading(true);
      successMessage.value = '';
      errorMessage.value = '';

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

      if (response.success && response.data != null) {
        auctionsList.value = response.data!.auctions;
        pagination.value = response.data!.pagination;
        currentPage.value = page;

        successMessage.value =
            response.message ?? 'Auctions loaded successfully';
        DevLogs.logSuccess(successMessage.value);
        return true;
      } else {
        errorMessage.value = response.message ?? 'Failed to load auctions';
        DevLogs.logError(errorMessage.value);
        return false;
      }
    } catch (e) {
      DevLogs.logError('Error getting auctions: ${e.toString()}');
      errorMessage.value = 'An error occurred: ${e.toString()}';
      return false;
    } finally {
      isLoading(false);
    }
  }

  /// GET AUCTION DETAILS
  Future<bool> getAuctionDetailsRequest({required String auctionId}) async {
    try {
      isLoadingDetails(true);
      successMessage.value = '';
      errorMessage.value = '';

      final response = await AuctionsServices.getAuctionDetails(
        auctionId: auctionId,
      );

      if (response.success && response.data != null) {
        selectedAuction.value = response.data!.auction;
        currentBid.value = response.data!.currentBid;

        successMessage.value = response.message ?? 'Auction details loaded';
        DevLogs.logSuccess(successMessage.value);
        return true;
      } else {
        errorMessage.value =
            response.message ?? 'Failed to load auction details';
        DevLogs.logError(errorMessage.value);
        return false;
      }
    } catch (e) {
      DevLogs.logError('Error getting auction details: ${e.toString()}');
      errorMessage.value = 'An error occurred: ${e.toString()}';
      return false;
    } finally {
      isLoadingDetails(false);
    }
  }

  /// GET LIVE AUCTIONS
  Future<bool> getLiveAuctionsRequest({String? category}) async {
    try {
      isLoadingLive(true);
      successMessage.value = '';
      errorMessage.value = '';

      final response = await AuctionsServices.getLiveAuctions(
        category: category,
      );

      if (response.success && response.data != null) {
        liveAuctions.value = response.data!;

        successMessage.value = response.message ?? 'Live auctions loaded';
        DevLogs.logSuccess(successMessage.value);
        return true;
      } else {
        errorMessage.value = response.message ?? 'Failed to load live auctions';
        DevLogs.logError(errorMessage.value);
        return false;
      }
    } catch (e) {
      DevLogs.logError('Error getting live auctions: ${e.toString()}');
      errorMessage.value = 'An error occurred: ${e.toString()}';
      return false;
    } finally {
      isLoadingLive(false);
    }
  }

  /// LOAD MORE AUCTIONS (Pagination)
  Future<bool> loadMoreAuctions({
    String? status,
    String? category,
    String? search,
  }) async {
    try {
      if (currentPage.value >= pagination.value.pages) {
        return false; // No more pages
      }

      final nextPage = currentPage.value + 1;

      final response = await AuctionsServices.getAuctions(
        page: nextPage,
        limit: pagination.value.limit,
        status: status,
        category: category,
        search: search,
      );

      if (response.success && response.data != null) {
        auctionsList.addAll(response.data!.auctions);
        pagination.value = response.data!.pagination;
        currentPage.value = nextPage;

        successMessage.value = 'Loaded more auctions';
        return true;
      } else {
        errorMessage.value = response.message ?? 'Failed to load more auctions';
        return false;
      }
    } catch (e) {
      DevLogs.logError('Error loading more auctions: ${e.toString()}');
      errorMessage.value = 'An error occurred: ${e.toString()}';
      return false;
    }
  }

  /// SEARCH AUCTIONS
  Future<bool> searchAuctionsRequest({
    required String query,
    String? status,
  }) async {
    try {
      isLoadingSearch(true);
      successMessage.value = '';
      errorMessage.value = '';

      final response = await AuctionsServices.searchAuctions(
        query: query,
        status: status,
      );

      if (response.success && response.data != null) {
        searchResults.value = response.data!;
        successMessage.value =
            response.message ?? 'Search completed successfully';
        DevLogs.logSuccess(successMessage.value);
        return true;
      } else {
        errorMessage.value = response.message ?? 'Failed to search auctions';
        DevLogs.logError(errorMessage.value);
        return false;
      }
    } catch (e) {
      DevLogs.logError('Error searching auctions: ${e.toString()}');
      errorMessage.value = 'An error occurred: ${e.toString()}';
      return false;
    } finally {
      isLoadingSearch(false);
    }
  }

  /// GET AUCTION BIDS
  Future<bool> getAuctionBidsRequest({required String auctionId}) async {
    try {
      isLoadingBids(true);
      successMessage.value = '';
      errorMessage.value = '';

      final response = await AuctionsServices.getAuctionBids(
        auctionId: auctionId,
      );

      if (response.success && response.data != null) {
        auctionBids.value = response.data!;
        successMessage.value = response.message ?? 'Bids loaded successfully';
        DevLogs.logSuccess(successMessage.value);
        return true;
      } else {
        errorMessage.value = response.message ?? 'Failed to load bids';
        DevLogs.logError(errorMessage.value);
        return false;
      }
    } catch (e) {
      DevLogs.logError('Error getting auction bids: ${e.toString()}');
      errorMessage.value = 'An error occurred: ${e.toString()}';
      return false;
    } finally {
      isLoadingBids(false);
    }
  }

  /// PLACE BID ON AUCTION
  /// PLACE BID ON AUCTION
  Future<bool> placeBidRequest({
    required String auctionId,
    required double amount,
  }) async {
    try {
      isLoading(true);
      successMessage.value = '';
      errorMessage.value = '';

      final response = await AuctionsServices.placeBid(
        auctionId: auctionId,
        amount: amount,
      );

      if (response.success && response.data != null) {
        successMessage.value = response.message ?? 'Bid placed successfully';
        DevLogs.logSuccess(successMessage.value);
        return true;
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
        return false;
      }
    } catch (e) {
      DevLogs.logError('Error placing bid: ${e.toString()}');
      errorMessage.value = 'An error occurred: ${e.toString()}';
      return false;
    } finally {
      isLoading(false);
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
