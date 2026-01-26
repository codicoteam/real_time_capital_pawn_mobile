// bid_mngmt_controller.dart
// lib/features/user_bids/controllers/user_bids_controller.dart
import 'package:get/get.dart';
import 'package:real_time_pawn/core/utils/logs.dart';
import 'package:real_time_pawn/features/auctions_mngmt/services/auctions_mngmt_service.dart';
import 'package:real_time_pawn/features/auctions_mngmt/services/bid_placement_service.dart';
import 'package:real_time_pawn/features/bid_mngmt/services/bid_mngmt_service.dart';
import 'package:real_time_pawn/models/user_bid_models.dart';

class UserBidsController extends GetxController {
  var isLoading = false.obs;
  var isLoadingMore = false.obs;

  var successMessage = ''.obs;
  var errorMessage = ''.obs;

  var userBids = <UserBid>[].obs;
  var pagination = Pagination(page: 1, limit: 10, total: 0, pages: 1).obs;
  var currentPage = 1.obs;

  var selectedStatus = 'All'.obs;
  final List<String> statusFilters = [
    'All',
    'Live',
    'Upcoming',
    'Past',
    'Draft',
  ];

  /// GET CURRENT USER'S BIDDING HISTORY
  Future<bool> getUserBiddingHistoryRequest({
    String? status,
    int page = 1,
    int limit = 10,
  }) async {
    try {
      isLoading(true);
      successMessage.value = '';
      errorMessage.value = '';

      final response = await UserBidsService.getCurrentUserBiddingHistory(
        status: status,
        page: page,
        limit: limit,
      );

      if (response.success && response.data != null) {
        userBids.value = response.data!.bids;
        pagination.value = response.data!.pagination;
        currentPage.value = page;

        if (status != null) {
          selectedStatus.value = status;
        }

        successMessage.value =
            response.message ?? 'Bidding history loaded successfully';
        DevLogs.logSuccess(successMessage.value);
        return true;
      } else {
        errorMessage.value =
            response.message ?? 'Failed to load bidding history';
        DevLogs.logError(errorMessage.value);
        return false;
      }
    } catch (e) {
      DevLogs.logError('Error getting user bidding history: ${e.toString()}');
      errorMessage.value = 'An error occurred: ${e.toString()}';
      return false;
    } finally {
      isLoading(false);
    }
  }

  /// LOAD MORE BIDS (Pagination)
  Future<bool> loadMoreBids() async {
    try {
      if (currentPage.value >= pagination.value.pages) {
        return false; // No more pages
      }

      isLoadingMore(true);

      final nextPage = currentPage.value + 1;

      final response = await UserBidsService.getCurrentUserBiddingHistory(
        status: selectedStatus.value != 'All' ? selectedStatus.value : null,
        page: nextPage,
        limit: pagination.value.limit,
      );

      if (response.success && response.data != null) {
        userBids.addAll(response.data!.bids);
        pagination.value = response.data!.pagination;
        currentPage.value = nextPage;

        successMessage.value = 'Loaded more bids';
        return true;
      } else {
        errorMessage.value = response.message ?? 'Failed to load more bids';
        return false;
      }
    } catch (e) {
      DevLogs.logError('Error loading more bids: ${e.toString()}');
      errorMessage.value = 'An error occurred: ${e.toString()}';
      return false;
    } finally {
      isLoadingMore(false);
    }
  }

  /// FILTER BIDS BY STATUS
  Future<bool> filterBidsByStatus(String status) async {
    selectedStatus.value = status;
    return await getUserBiddingHistoryRequest(
      status: status != 'All' ? status : null,
      page: 1,
    );
  }

  /// REFRESH BIDS
  Future<void> refreshBids() async {
    await getUserBiddingHistoryRequest(
      status: selectedStatus.value != 'All' ? selectedStatus.value : null,
      page: 1,
    );
  }

  // Add these methods to your existing AuctionsController in auctions_mngmt_controller.dart

  /// PLACE BID ON AUCTION
  Future<bool> placeBidRequest({
    required String auctionId,
    required double amount,
  }) async {
    try {
      isLoading(true);
      successMessage.value = '';
      errorMessage.value = '';

      // We'll create this service method
      // For now, using direct API call through BidPlacementService
      final response = await BidPlacementService.placeBid(
        auctionId: auctionId,
        amount: amount,
      );

      if (response.success && response.data != null) {
        successMessage.value = response.message ?? 'Bid placed successfully';

        // Update auction details with new bid
        await getAuctionDetailsRequest(auctionId: auctionId);

        // Also refresh live auctions if needed
        await getLiveAuctionsRequest();

        DevLogs.logSuccess(successMessage.value);
        return true;
      } else {
        errorMessage.value = response.message ?? 'Failed to place bid';
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

  /// GET MY ACTIVE BIDS (for current user)
  Future<List<Auction>> getMyActiveBidsRequest() async {
    try {
      // This would require a new API endpoint or filtering
      // For now, return empty list
      return [];
    } catch (e) {
      DevLogs.logError('Error getting active bids: ${e.toString()}');
      return [];
    }
  }

  /// CLEAR ALL DATA
  void clearData() {
    userBids.value = [];
    pagination.value = Pagination(page: 1, limit: 10, total: 0, pages: 1);
    currentPage.value = 1;
    successMessage.value = '';
    errorMessage.value = '';
  }

  /// CHECK IF USER HAS BIDS
  bool get hasBids => userBids.isNotEmpty;

  /// GET TOTAL BID AMOUNT
  double get totalBidAmount {
    return userBids.fold(0.0, (sum, bid) => sum + bid.amount);
  }

  /// GET WON AUCTIONS COUNT
  int get wonAuctionsCount {
    return userBids.where((bid) {
      return bid.auction.winnerUser != null &&
          bid.auction.winnerUser?.id == bid.bidder.id;
    }).length;
  }
}
