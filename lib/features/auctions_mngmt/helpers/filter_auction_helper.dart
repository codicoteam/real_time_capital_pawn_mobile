import 'package:real_time_pawn/models/auction_list_model.dart';

class AuctionFilters {
  static List<AuctionListModel> filterAuctions({
    required List<AuctionListModel> auctions,
    String? status,
    String? category,
    String? searchQuery,
    String? sortBy = 'created_at',
    String? sortOrder = 'desc',
  }) {
    List<AuctionListModel> filtered = List.from(auctions);

    // Filter by status
    if (status != null && status != 'All' && status.isNotEmpty) {
      filtered = filtered.where((auction) {
        return auction.status?.toLowerCase() == status.toLowerCase();
      }).toList();
    }

    // Filter by category
    if (category != null && category != 'All' && category.isNotEmpty) {
      filtered = filtered.where((auction) {
        final auctionCategory = auction.asset?.category ?? '';
        final formattedCategory = category.toLowerCase().replaceAll(' ', '_');
        return auctionCategory.toLowerCase() == formattedCategory;
      }).toList();
    }

    // Filter by search query
    if (searchQuery != null && searchQuery.isNotEmpty) {
      filtered = filtered.where((auction) {
        final title = auction.asset?.title?.toLowerCase() ?? '';
        final auctionNo = auction.auctionNo?.toLowerCase() ?? '';
        final query = searchQuery.toLowerCase();
        return title.contains(query) || auctionNo.contains(query);
      }).toList();
    }

    // Sort auctions
    filtered = _sortAuctions(filtered, sortBy, sortOrder);

    return filtered;
  }

  static List<AuctionListModel> _sortAuctions(
    List<AuctionListModel> auctions,
    String? sortBy,
    String? sortOrder,
  ) {
    auctions.sort((a, b) {
      int comparison = 0;

      switch (sortBy) {
        case 'starting_bid_amount':
          comparison = (a.startingBidAmount ?? 0).compareTo(
            b.startingBidAmount ?? 0,
          );
          break;
        case 'reserve_price':
          comparison = (a.reservePrice ?? 0).compareTo(b.reservePrice ?? 0);
          break;
        case 'starts_at':
          comparison = (a.startsAt ?? DateTime.now()).compareTo(
            b.startsAt ?? DateTime.now(),
          );
          break;
        case 'ends_at':
          comparison = (a.endsAt ?? DateTime.now()).compareTo(
            b.endsAt ?? DateTime.now(),
          );
          break;
        case 'title':
          final titleA = a.asset?.title?.toLowerCase() ?? '';
          final titleB = b.asset?.title?.toLowerCase() ?? '';
          comparison = titleA.compareTo(titleB);
          break;
        case 'created_at':
        default:
          comparison = (a.createdAt ?? DateTime.now()).compareTo(
            b.createdAt ?? DateTime.now(),
          );
          break;
      }

      return sortOrder == 'asc' ? comparison : -comparison;
    });

    return auctions;
  }

  static List<String> getAvailableCategories(List<AuctionListModel> auctions) {
    final categories = auctions
        .map((a) => a.asset?.category)
        .where((c) => c != null && c.isNotEmpty)
        .toSet();

    return ['All', ...categories.map((c) => _formatCategory(c!)).toList()];
  }

  static String _formatCategory(String category) {
    return category
        .split('_')
        .map((word) => word[0].toUpperCase() + word.substring(1))
        .join(' ');
  }

  static Map<String, int> getStatusCounts(List<AuctionListModel> auctions) {
    return {
      'All': auctions.length,
      'Live': auctions.where((a) => a.status?.toLowerCase() == 'live').length,
      'Draft': auctions.where((a) => a.status?.toLowerCase() == 'draft').length,
      'Closed': auctions
          .where((a) => a.status?.toLowerCase() == 'closed')
          .length,
      'Cancelled': auctions
          .where((a) => a.status?.toLowerCase() == 'cancelled')
          .length,
    };
  }
}
