// bid_mngmt/models/user_bid_models.dart
import 'package:real_time_pawn/features/auctions_mngmt/services/auctions_mngmt_service.dart';
import 'package:real_time_pawn/models/auction_models.dart';

enum BidPaymentStatus { unpaid, paid, partially_paid, refunded, failed }

enum BidDisputeStatus { none, raised, under_review, resolved, dismissed }

class UserBid {
  final String id;
  final UserBidAuction auction;
  final UserBidder bidder;
  final double amount;
  final String currency;
  final DateTime placedAt;
  final BidDispute dispute;
  final BidPaymentStatus paymentStatus;
  final double paidAmount;
  final DateTime? paidAt;
  final String? paymentReference;
  final Map<String, dynamic> meta;
  final DateTime createdAt;
  final DateTime updatedAt;

  UserBid({
    required this.id,
    required this.auction,
    required this.bidder,
    required this.amount,
    this.currency = 'USD',
    required this.placedAt,
    required this.dispute,
    required this.paymentStatus,
    required this.paidAmount,
    this.paidAt,
    this.paymentReference,
    required this.meta,
    required this.createdAt,
    required this.updatedAt,
  });

  // Replace the current UserBid.fromJson factory constructor with this:

  factory UserBid.fromJson(Map<String, dynamic> json) {
    // Handle bidder_user which might be a string ID or an object
    dynamic bidderUserData = json['bidder_user'];
    UserBidder bidder;

    if (bidderUserData is String) {
      // If it's just a string ID, create a minimal UserBidder
      bidder = UserBidder(
        id: bidderUserData,
        email: '',
        phone: '',
        roles: [],
        firstName: '',
        lastName: '',
        fullName: 'Unknown Bidder',
        status: 'active',
        emailVerified: false,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
    } else if (bidderUserData is Map<String, dynamic>) {
      // If it's already an object, parse it normally
      bidder = UserBidder.fromJson(bidderUserData);
    } else {
      // Fallback if data is null or invalid
      bidder = UserBidder(
        id: '',
        email: '',
        phone: '',
        roles: [],
        firstName: '',
        lastName: '',
        fullName: 'Unknown Bidder',
        status: 'active',
        emailVerified: false,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
    }

    return UserBid(
      id: json['_id'] ?? json['id'] ?? '',
      auction: UserBidAuction.fromJson(json['auction'] ?? {}),
      bidder: bidder,
      amount: (json['amount'] ?? 0.0).toDouble(),
      currency: json['currency'] ?? 'USD',
      placedAt: DateTime.parse(
        json['placed_at'] ?? DateTime.now().toIso8601String(),
      ),
      dispute: BidDispute.fromJson(json['dispute'] ?? {}),
      paymentStatus: _parsePaymentStatus(json['payment_status'] ?? 'unpaid'),
      paidAmount: (json['paid_amount'] ?? 0.0).toDouble(),
      paidAt: json['paid_at'] != null ? DateTime.parse(json['paid_at']) : null,
      paymentReference: json['payment_reference'],
      meta: Map<String, dynamic>.from(json['meta'] ?? {}),
      createdAt: DateTime.parse(
        json['created_at'] ?? DateTime.now().toIso8601String(),
      ),
      updatedAt: DateTime.parse(
        json['updated_at'] ?? DateTime.now().toIso8601String(),
      ),
    );
  }

  static BidPaymentStatus _parsePaymentStatus(String status) {
    switch (status.toLowerCase()) {
      case 'paid':
        return BidPaymentStatus.paid;
      case 'partially_paid':
        return BidPaymentStatus.partially_paid;
      case 'refunded':
        return BidPaymentStatus.refunded;
      case 'failed':
        return BidPaymentStatus.failed;
      case 'unpaid':
      default:
        return BidPaymentStatus.unpaid;
    }
  }
}

class UserBidAuction {
  final String id;
  final String auctionNo;
  final Asset asset;
  final double startingBidAmount;
  final double? reservePrice;
  final String auctionType;
  final DateTime startsAt;
  final DateTime endsAt;
  final String status;
  final UserBidder? winnerUser;
  final double? winningBidAmount;
  final UserBidder createdBy;
  final DateTime createdAt;
  final DateTime updatedAt;

  UserBidAuction({
    required this.id,
    required this.auctionNo,
    required this.asset,
    required this.startingBidAmount,
    this.reservePrice,
    required this.auctionType,
    required this.startsAt,
    required this.endsAt,
    required this.status,
    this.winnerUser,
    this.winningBidAmount,
    required this.createdBy,
    required this.createdAt,
    required this.updatedAt,
  });
  factory UserBidAuction.fromJson(Map<String, dynamic> json) {
    // Handle created_by which might be a string ID or an object
    dynamic createdByData = json['created_by'];
    UserBidder createdBy;

    if (createdByData is String) {
      // If it's just a string ID, create a minimal UserBidder
      createdBy = UserBidder(
        id: createdByData,
        email: '',
        phone: '',
        roles: [],
        firstName: '',
        lastName: '',
        fullName: 'Unknown User',
        status: 'active',
        emailVerified: false,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
    } else if (createdByData is Map<String, dynamic>) {
      // If it's already an object, parse it normally
      createdBy = UserBidder.fromJson(createdByData);
    } else {
      // Fallback if data is null or invalid
      createdBy = UserBidder(
        id: '',
        email: '',
        phone: '',
        roles: [],
        firstName: '',
        lastName: '',
        fullName: 'Unknown User',
        status: 'active',
        emailVerified: false,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
    }

    return UserBidAuction(
      id: json['_id'] ?? json['id'] ?? '',
      auctionNo: json['auction_no'] ?? '',
      asset: Asset.fromJson(json['asset'] ?? {}),
      startingBidAmount: (json['starting_bid_amount'] ?? 0.0).toDouble(),
      reservePrice: json['reserve_price'] != null
          ? (json['reserve_price']).toDouble()
          : null,
      auctionType: json['auction_type'] ?? 'online',
      startsAt: DateTime.parse(
        json['starts_at'] ?? DateTime.now().toIso8601String(),
      ),
      endsAt: DateTime.parse(
        json['ends_at'] ?? DateTime.now().toIso8601String(),
      ),
      status: json['status'] ?? 'draft',
      winnerUser: json['winner_user'] != null
          ? UserBidder.fromJson(json['winner_user'])
          : null,
      winningBidAmount: json['winning_bid_amount'] != null
          ? (json['winning_bid_amount']).toDouble()
          : null,
      createdBy: createdBy, // Use the handled created_by
      createdAt: DateTime.parse(
        json['created_at'] ?? DateTime.now().toIso8601String(),
      ),
      updatedAt: DateTime.parse(
        json['updated_at'] ?? DateTime.now().toIso8601String(),
      ),
    );
  }
}

class UserBidder {
  final String id;
  final String email;
  final String phone;
  final List<String> roles;
  final String firstName;
  final String lastName;
  final String fullName;
  final String status;
  final String? nationalIdNumber;
  final DateTime? dateOfBirth;
  final String? address;
  final String? location;
  final String? nationalIdImageUrl;
  final String? profilePicUrl;
  final bool emailVerified;
  final DateTime createdAt;
  final DateTime updatedAt;

  UserBidder({
    required this.id,
    required this.email,
    required this.phone,
    required this.roles,
    required this.firstName,
    required this.lastName,
    required this.fullName,
    required this.status,
    this.nationalIdNumber,
    this.dateOfBirth,
    this.address,
    this.location,
    this.nationalIdImageUrl,
    this.profilePicUrl,
    required this.emailVerified,
    required this.createdAt,
    required this.updatedAt,
  });

  factory UserBidder.fromJson(Map<String, dynamic> json) {
    return UserBidder(
      id: json['_id'] ?? json['id'] ?? '',
      email: json['email'] ?? '',
      phone: json['phone'] ?? '',
      roles: List<String>.from(json['roles'] ?? []),
      firstName: json['first_name'] ?? '',
      lastName: json['last_name'] ?? '',
      fullName: json['full_name'] ?? '',
      status: json['status'] ?? 'pending',
      nationalIdNumber: json['national_id_number'],
      dateOfBirth: json['date_of_birth'] != null
          ? DateTime.parse(json['date_of_birth'])
          : null,
      address: json['address'],
      location: json['location'],
      nationalIdImageUrl: json['national_id_image_url'],
      profilePicUrl: json['profile_pic_url'],
      emailVerified: json['email_verified'] ?? false,
      createdAt: DateTime.parse(
        json['created_at'] ?? DateTime.now().toIso8601String(),
      ),
      updatedAt: DateTime.parse(
        json['updated_at'] ?? DateTime.now().toIso8601String(),
      ),
    );
  }
}

class BidDispute {
  final BidDisputeStatus status;
  final String? reason;
  final UserBidder? raisedBy;
  final DateTime? raisedAt;
  final UserBidder? resolvedBy;
  final DateTime? resolvedAt;
  final String? resolutionNotes;

  BidDispute({
    required this.status,
    this.reason,
    this.raisedBy,
    this.raisedAt,
    this.resolvedBy,
    this.resolvedAt,
    this.resolutionNotes,
  });

  // In BidDispute.fromJson():
  factory BidDispute.fromJson(Map<String, dynamic> json) {
    // Handle raised_by which might be string or object
    dynamic raisedByData = json['raised_by'];
    UserBidder? raisedBy;

    if (raisedByData is String && raisedByData.isNotEmpty) {
      raisedBy = UserBidder(
        id: raisedByData,
        email: '',
        phone: '',
        roles: [],
        firstName: '',
        lastName: '',
        fullName: 'Unknown User',
        status: 'active',
        emailVerified: false,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
    } else if (raisedByData is Map<String, dynamic>) {
      raisedBy = UserBidder.fromJson(raisedByData);
    }

    // Similar logic for resolved_by
    dynamic resolvedByData = json['resolved_by'];
    UserBidder? resolvedBy;

    if (resolvedByData is String && resolvedByData.isNotEmpty) {
      resolvedBy = UserBidder(
        id: resolvedByData,
        email: '',
        phone: '',
        roles: [],
        firstName: '',
        lastName: '',
        fullName: 'Unknown User',
        status: 'active',
        emailVerified: false,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
    } else if (resolvedByData is Map<String, dynamic>) {
      resolvedBy = UserBidder.fromJson(resolvedByData);
    }

    return BidDispute(
      status: _parseDisputeStatus(json['status'] ?? 'none'),
      reason: json['reason'],
      raisedBy: raisedBy,
      raisedAt: json['raised_at'] != null
          ? DateTime.parse(json['raised_at'])
          : null,
      resolvedBy: resolvedBy,
      resolvedAt: json['resolved_at'] != null
          ? DateTime.parse(json['resolved_at'])
          : null,
      resolutionNotes: json['resolution_notes'],
    );
  }

  static BidDisputeStatus _parseDisputeStatus(String status) {
    switch (status.toLowerCase()) {
      case 'raised':
        return BidDisputeStatus.raised;
      case 'under_review':
        return BidDisputeStatus.under_review;
      case 'resolved':
        return BidDisputeStatus.resolved;
      case 'dismissed':
        return BidDisputeStatus.dismissed;
      case 'none':
      default:
        return BidDisputeStatus.none;
    }
  }
}

class UserBidsResponse {
  final List<UserBid> bids;
  final Pagination pagination;

  UserBidsResponse({required this.bids, required this.pagination});
}
