// lib/features/user_bids/models/user_bid_models.dart
import 'package:real_time_pawn/models/auction_models.dart';

import '../features/auctions_mngmt/services/auctions_mngmt_service.dart';

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

  factory UserBid.fromJson(Map<String, dynamic> json) {
    return UserBid(
      id: json['_id'] ?? json['id'] ?? '',
      auction: UserBidAuction.fromJson(json['auction'] ?? {}),
      bidder: UserBidder.fromJson(json['bidder_user'] ?? {}),
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
      createdBy: UserBidder.fromJson(json['created_by'] ?? {}),
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

  factory BidDispute.fromJson(Map<String, dynamic> json) {
    return BidDispute(
      status: _parseDisputeStatus(json['status'] ?? 'none'),
      reason: json['reason'],
      raisedBy: json['raised_by'] != null
          ? UserBidder.fromJson(json['raised_by'])
          : null,
      raisedAt: json['raised_at'] != null
          ? DateTime.parse(json['raised_at'])
          : null,
      resolvedBy: json['resolved_by'] != null
          ? UserBidder.fromJson(json['resolved_by'])
          : null,
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
