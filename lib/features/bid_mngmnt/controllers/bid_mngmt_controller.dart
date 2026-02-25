import 'package:get/get.dart';
import 'package:real_time_pawn/core/utils/logs.dart';
import 'package:real_time_pawn/models/user_bid_models.dart';
import '../services/bid_mngmt_service.dart';
import '../services/dispute_service.dart';

class BidManagementController extends GetxController {
  // Loading states
  var isLoading = false.obs;
  var isLoadingDetails = false.obs;
  var isLoadingDispute = false.obs;

  // Data
  var userBids = <UserBid>[].obs;
  var selectedBid = Rxn<UserBid>();
  var selectedDispute = Rxn<BidDispute>();

  // Pagination
  var currentPage = 1.obs;
  var hasMoreBids = true.obs;

  // Filters
  var statusFilters = [
    'All',
    'Active',
    'Winning',
    'Lost',
    'Won',
    'Pending',
  ].obs;
  var selectedStatus = 'All'.obs;
  var searchQuery = ''.obs;

  // Messages
  var successMessage = ''.obs;
  var errorMessage = ''.obs;

  /// GET USER BIDS
  Future<bool> getUserBidsRequest({
    int page = 1,
    int limit = 10,
    String? status,
    bool showLoader = true,
  }) async {
    try {
      if (showLoader) isLoading(true);
      successMessage.value = '';
      errorMessage.value = '';

      final response = await BidManagementService.getUserBids(
        page: page,
        limit: limit,
        status: status != 'All' ? status : null,
      );

      if (response.success && response.data != null) {
        if (page == 1) {
          userBids.value = response.data!;
        } else {
          userBids.addAll(response.data!);
        }

        currentPage.value = page;
        // Simple check: if we got fewer bids than limit, we've reached the end
        hasMoreBids.value = response.data!.length == limit;

        successMessage.value = response.message ?? 'Bids loaded successfully';
        DevLogs.logSuccess(successMessage.value);
        return true;
      } else {
        errorMessage.value = response.message ?? 'Failed to load bids';
        DevLogs.logError(errorMessage.value);
        return false;
      }
    } catch (e) {
      DevLogs.logError('Error getting user bids: ${e.toString()}');
      errorMessage.value = 'An error occurred: ${e.toString()}';
      return false;
    } finally {
      if (showLoader) isLoading(false);
    }
  }

  /// LOAD MORE BIDS
  Future<bool> loadMoreBids() async {
    if (!hasMoreBids.value || isLoading.value) return false;

    final nextPage = currentPage.value + 1;
    return await getUserBidsRequest(page: nextPage, showLoader: false);
  }

  /// GET BID DETAILS
  Future<bool> getBidDetailsRequest({required String bidId}) async {
    try {
      isLoadingDetails(true);
      successMessage.value = '';
      errorMessage.value = '';

      final response = await BidManagementService.getBidDetails(bidId: bidId);

      if (response.success && response.data != null) {
        selectedBid.value = response.data!;

        // Update the bid in the list if it exists
        final index = userBids.indexWhere((bid) => bid.id == bidId);
        if (index != -1) {
          userBids[index] = response.data!;
        }

        successMessage.value = response.message ?? 'Bid details loaded';
        DevLogs.logSuccess(successMessage.value);
        return true;
      } else {
        errorMessage.value = response.message ?? 'Failed to load bid details';
        DevLogs.logError(errorMessage.value);
        return false;
      }
    } catch (e) {
      DevLogs.logError('Error getting bid details: ${e.toString()}');
      errorMessage.value = 'An error occurred: ${e.toString()}';
      return false;
    } finally {
      isLoadingDetails(false);
    }
  }

  /// RAISE DISPUTE
  Future<bool> raiseDisputeRequest({
    required String bidId,
    required String reason,
  }) async {
    try {
      isLoadingDispute(true);
      successMessage.value = '';
      errorMessage.value = '';

      final response = await DisputeService.raiseDispute(
        bidId: bidId,
        reason: reason,
      );

      if (response.success && response.data != null) {
        selectedDispute.value = response.data!;

        // Update bid dispute status in the selected bid
        final bid = selectedBid.value;
        if (bid != null && bid.id == bidId) {
          // Create updated bid with new dispute
          final updatedBid = UserBid(
            id: bid.id,
            auction: bid.auction,
            bidder: bid.bidder,
            amount: bid.amount,
            currency: bid.currency,
            placedAt: bid.placedAt,
            dispute: response.data!, // Updated dispute
            paymentStatus: bid.paymentStatus,
            paidAmount: bid.paidAmount,
            paidAt: bid.paidAt,
            paymentReference: bid.paymentReference,
            meta: bid.meta,
            createdAt: bid.createdAt,
            updatedAt: DateTime.now(),
          );
          selectedBid.value = updatedBid;
        }

        successMessage.value =
            response.message ?? 'Dispute raised successfully';
        DevLogs.logSuccess(successMessage.value);
        return true;
      } else {
        errorMessage.value = response.message ?? 'Failed to raise dispute';
        DevLogs.logError(errorMessage.value);
        return false;
      }
    } catch (e) {
      DevLogs.logError('Error raising dispute: ${e.toString()}');
      errorMessage.value = 'An error occurred: ${e.toString()}';
      return false;
    } finally {
      isLoadingDispute(false);
    }
  }

  /// CANCEL DISPUTE
  Future<bool> cancelDisputeRequest({
    required String bidId,
    required String disputeId,
  }) async {
    try {
      isLoadingDispute(true);
      successMessage.value = '';
      errorMessage.value = '';

      final response = await DisputeService.cancelDispute(
        bidId: bidId,
        disputeId: disputeId,
      );

      if (response.success && response.data == true) {
        selectedDispute.value = null;

        // Update bid dispute status
        final bid = selectedBid.value;
        if (bid != null && bid.id == bidId) {
          // Create updated bid with cancelled dispute
          final updatedDispute = BidDispute(
            status: BidDisputeStatus.none,
            reason: null,
            raisedBy: null,
            raisedAt: null,
            resolvedBy: null,
            resolvedAt: null,
            resolutionNotes: null,
          );

          final updatedBid = UserBid(
            id: bid.id,
            auction: bid.auction,
            bidder: bid.bidder,
            amount: bid.amount,
            currency: bid.currency,
            placedAt: bid.placedAt,
            dispute: updatedDispute,
            paymentStatus: bid.paymentStatus,
            paidAmount: bid.paidAmount,
            paidAt: bid.paidAt,
            paymentReference: bid.paymentReference,
            meta: bid.meta,
            createdAt: bid.createdAt,
            updatedAt: DateTime.now(),
          );
          selectedBid.value = updatedBid;
        }

        successMessage.value =
            response.message ?? 'Dispute cancelled successfully';
        DevLogs.logSuccess(successMessage.value);
        return true;
      } else {
        errorMessage.value = response.message ?? 'Failed to cancel dispute';
        DevLogs.logError(errorMessage.value);
        return false;
      }
    } catch (e) {
      DevLogs.logError('Error cancelling dispute: ${e.toString()}');
      errorMessage.value = 'An error occurred: ${e.toString()}';
      return false;
    } finally {
      isLoadingDispute(false);
    }
  }

  /// FILTER BIDS BY STATUS
  void filterBidsByStatus(String status) {
    selectedStatus.value = status;
    getUserBidsRequest(page: 1, status: status != 'All' ? status : null);
  }

  /// SEARCH BIDS
  void searchBids(String query) {
    searchQuery.value = query;
    // Filter locally for now - could implement API search
    if (query.isEmpty) {
      getUserBidsRequest(page: 1);
    } else {
      final filtered = userBids.where((bid) {
        return bid.auction.asset.title.toLowerCase().contains(
              query.toLowerCase(),
            ) ||
            bid.auction.auctionNo.toLowerCase().contains(query.toLowerCase());
      }).toList();
      userBids.value = filtered;
    }
  }

  /// CLEAR SELECTED BID
  void clearSelectedBid() {
    selectedBid.value = null;
    selectedDispute.value = null;
  }

  /// CLEAR MESSAGES
  void clearMessages() {
    successMessage.value = '';
    errorMessage.value = '';
  }

  /// REFRESH BIDS
  Future<void> refreshBids() async {
    await getUserBidsRequest(page: 1, showLoader: false);
  }

  /// GET BID STATISTICS
  Map<String, int> getBidStatistics() {
    final total = userBids.length;
    int active = 0;
    int winning = 0;
    int won = 0;
    int lost = 0;
    int withDispute = 0;

    for (var bid in userBids) {
      // Check if bid has dispute
      if (bid.dispute.status != BidDisputeStatus.none) {
        withDispute++;
      }

      // Determine bid status based on auction status
      final auctionStatus = bid.auction.status.toLowerCase();

      if (auctionStatus == 'live') {
        if (bid.auction.winningBidAmount == bid.amount) {
          winning++;
          active++;
        } else {
          active++;
        }
      } else if (auctionStatus == 'closed') {
        if (bid.auction.winnerUser != null &&
            bid.auction.winnerUser?.id == bid.bidder.id) {
          won++;
        } else {
          lost++;
        }
      }
    }

    return {
      'total': total,
      'active': active,
      'winning': winning,
      'won': won,
      'lost': lost,
      'withDispute': withDispute,
    };
  }

  /// GET TOTAL BID AMOUNT
  double get totalBidAmount {
    return userBids.fold(0.0, (sum, bid) => sum + bid.amount);
  }

  /// GET TOTAL PAID AMOUNT
  double get totalPaidAmount {
    return userBids.fold(0.0, (sum, bid) => sum + bid.paidAmount);
  }

  /// Helper methods for UserBid properties

  bool isBidActive(UserBid bid) {
    return bid.auction.status.toLowerCase() == 'live';
  }

  bool isBidWinning(UserBid bid) {
    if (bid.auction.status.toLowerCase() == 'live') {
      return bid.auction.winningBidAmount == bid.amount;
    }
    return false;
  }

  bool hasBidDispute(UserBid bid) {
    return bid.dispute.status != BidDisputeStatus.none;
  }

  bool isBidPaid(UserBid bid) {
    return bid.paymentStatus == BidPaymentStatus.paid ||
        bid.paymentStatus == BidPaymentStatus.partially_paid;
  }

  bool isBidWon(UserBid bid) {
    if (bid.auction.status.toLowerCase() == 'closed') {
      return bid.auction.winnerUser != null &&
          bid.auction.winnerUser?.id == bid.bidder.id;
    }
    return false;
  }
}
