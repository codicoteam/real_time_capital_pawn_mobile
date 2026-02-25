// =======================================
// Models Matching Backend JSON Structure
// =======================================

enum AuctionStatus { draft, live, closed, upcoming }

enum AuctionType { online, in_person, hybrid }

class AssetAttachment {
  final String id;
  final String url;
  final String type;

  AssetAttachment({required this.id, required this.url, required this.type});

  factory AssetAttachment.fromJson(Map<String, dynamic> json) {
    return AssetAttachment(
      id: json['_id'] ?? json['id'] ?? '',
      url: json['url'] ?? '',
      type: json['mime_type']?.toString().contains('image') == true
          ? 'image'
          : json['mime_type']?.toString().contains('video') == true
          ? 'video'
          : 'document',
    );
  }
}

class Asset {
  final String id;
  final String assetNo;
  final String title;
  final String description;
  final String category;
  final String condition;
  final double evaluatedValue;
  final String storageLocation;
  final List<AssetAttachment> attachments;

  Asset({
    required this.id,
    required this.assetNo,
    required this.title,
    required this.description,
    required this.category,
    required this.condition,
    required this.evaluatedValue,
    required this.storageLocation,
    required this.attachments,
  });

  factory Asset.fromJson(Map<String, dynamic> json) {
    return Asset(
      id: json['_id'] ?? json['id'] ?? '',
      assetNo: json['asset_no'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      category: json['category'] ?? '',
      condition: json['condition'] ?? 'unknown',
      evaluatedValue: (json['evaluated_value'] ?? 0.0).toDouble(),
      storageLocation: json['storage_location'] ?? '',
      attachments: List<Map<String, dynamic>>.from(json['attachments'] ?? [])
          .map((attachmentJson) => AssetAttachment.fromJson(attachmentJson))
          .toList(),
    );
  }
}

class Auction {
  final String id;
  final String auctionNo;
  final Asset asset;
  final AuctionStatus status;
  final AuctionType type;
  final DateTime startDate;
  final DateTime endDate;
  final double startingBid;
  final double? reservePrice;
  final double? winningBidAmount;
  final int? bidCount;
  final List<Bid> recentBids;
  final String? location;

  Auction({
    required this.id,
    required this.auctionNo,
    required this.asset,
    required this.status,
    required this.type,
    required this.startDate,
    required this.endDate,
    required this.startingBid,
    this.reservePrice,
    this.winningBidAmount,
    this.bidCount = 0,
    required this.recentBids,
    this.location,
  });

  factory Auction.fromJson(Map<String, dynamic> json) {
    // Map status string to enum
    AuctionStatus parseStatus(String status) {
      switch (status.toLowerCase()) {
        case 'live':
          return AuctionStatus.live;
        case 'closed':
          return AuctionStatus.closed;
        case 'upcoming':
          return AuctionStatus.upcoming;
        case 'draft':
        default:
          return AuctionStatus.draft;
      }
    }

    // Map auction type string to enum
    AuctionType parseType(String type) {
      switch (type.toLowerCase()) {
        case 'in_person':
          return AuctionType.in_person;
        case 'hybrid':
          return AuctionType.hybrid;
        case 'online':
        default:
          return AuctionType.online;
      }
    }

    return Auction(
      id: json['_id'] ?? json['id'] ?? '',
      auctionNo: json['auction_no'] ?? '',
      asset: Asset.fromJson(json['asset'] ?? {}),
      status: parseStatus(json['status'] ?? 'draft'),
      type: parseType(json['auction_type'] ?? 'online'),
      startDate: DateTime.parse(
        json['starts_at'] ?? DateTime.now().toIso8601String(),
      ),
      endDate: DateTime.parse(
        json['ends_at'] ?? DateTime.now().toIso8601String(),
      ),
      startingBid: (json['starting_bid_amount'] ?? 0.0).toDouble(),
      reservePrice: (json['reserve_price'] ?? 0.0).toDouble() == 0
          ? null
          : (json['reserve_price'] ?? 0.0).toDouble(),
      winningBidAmount: json['winning_bid_amount'] != null
          ? (json['winning_bid_amount']).toDouble()
          : null,
      bidCount: json['bid_count'] ?? 0,
      recentBids: [], // Backend doesn't provide recent bids in list endpoint
      location: json['location'] ?? json['asset']?['storage_location'] ?? '',
    );
  }

  // Helper getter for current bid (from winning bid for closed auctions)
  double? get currentBid =>
      status == AuctionStatus.closed ? winningBidAmount : null;
}

// In auction_models.dart - Update the Bid class

class Bid {
  final String id;
  final double amount;
  final String bidderName;
  final DateTime timestamp;
  final bool isWinning;
  final String? bidderUserId; // Add this field
  final String? bidderEmail; // Add this field

  Bid({
    required this.id,
    required this.amount,
    required this.bidderName,
    required this.timestamp,
    this.isWinning = false,
    this.bidderUserId,
    this.bidderEmail,
  });

  factory Bid.fromJson(Map<String, dynamic> json) {
    return Bid(
      id: json['_id'] ?? json['id'] ?? '',
      amount: (json['amount'] ?? 0.0).toDouble(),
      bidderName: json['bidder_user']?['full_name'] ?? 'Anonymous',
      bidderUserId: json['bidder_user']?['_id'] ?? json['bidder_user']?['id'],
      bidderEmail: json['bidder_user']?['email'],
      timestamp: DateTime.parse(
        json['placed_at'] ?? DateTime.now().toIso8601String(),
      ),
      isWinning: json['is_winning'] ?? false,
    );
  }

  // Add toJson method for bid placement
  Map<String, dynamic> toJson() {
    return {'amount': amount};
  }
}
