// bid_mngmt/models/user_bid_models.dart
import 'package:flutter/foundation.dart';
import 'package:real_time_pawn/features/auctions_mngmt/services/auctions_mngmt_service.dart';
import 'package:real_time_pawn/models/auction_models.dart';
// Import Pagination from auctions service

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
    // Handle bidder_user which might be a string ID or an object
    dynamic bidderUserData = json['bidder_user'];
    UserBidder bidder;

    try {
      if (bidderUserData is String) {
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
        bidder = UserBidder.fromJson(bidderUserData);
      } else {
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
    } catch (e) {
      debugPrint('Error parsing bidder: $e');
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
      id: json['_id']?.toString() ?? json['id']?.toString() ?? '',
      auction: UserBidAuction.fromJson(json['auction'] ?? {}),
      bidder: bidder,
      amount: (json['amount'] is num)
          ? (json['amount'] as num).toDouble()
          : 0.0,
      currency: json['currency'] ?? 'USD',
      placedAt: _parseDate(json['placed_at']),
      dispute: BidDispute.fromJson(json['dispute'] ?? {}),
      paymentStatus: _parsePaymentStatus(json['payment_status'] ?? 'unpaid'),
      paidAmount: (json['paid_amount'] is num)
          ? (json['paid_amount'] as num).toDouble()
          : 0.0,
      paidAt: _parseNullableDate(json['paid_at']),
      paymentReference: json['payment_reference']?.toString(),
      meta: Map<String, dynamic>.from(json['meta'] ?? {}),
      createdAt: _parseDate(json['created_at']),
      updatedAt: _parseDate(json['updated_at']),
    );
  }

  static DateTime _parseDate(dynamic date) {
    if (date == null) return DateTime.now();
    try {
      return DateTime.parse(date.toString());
    } catch (e) {
      return DateTime.now();
    }
  }

  static DateTime? _parseNullableDate(dynamic date) {
    if (date == null) return null;
    try {
      return DateTime.parse(date.toString());
    } catch (e) {
      return null;
    }
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

    try {
      if (createdByData is String) {
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
        createdBy = UserBidder.fromJson(createdByData);
      } else {
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
    } catch (e) {
      debugPrint('Error parsing created_by: $e');
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

    // Handle winner_user
    UserBidder? winnerUser;
    try {
      dynamic winnerData = json['winner_user'];
      if (winnerData is Map<String, dynamic>) {
        winnerUser = UserBidder.fromJson(winnerData);
      } else if (winnerData is String) {
        winnerUser = UserBidder(
          id: winnerData,
          email: '',
          phone: '',
          roles: [],
          firstName: '',
          lastName: '',
          fullName: 'Winner',
          status: 'active',
          emailVerified: false,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );
      }
    } catch (e) {
      debugPrint('Error parsing winner_user: $e');
    }

    return UserBidAuction(
      id: json['_id']?.toString() ?? json['id']?.toString() ?? '',
      auctionNo: json['auction_no']?.toString() ?? '',
      asset: Asset.fromJson(json['asset'] ?? {}),
      startingBidAmount: (json['starting_bid_amount'] is num)
          ? (json['starting_bid_amount'] as num).toDouble()
          : 0.0,
      reservePrice: json['reserve_price'] != null
          ? (json['reserve_price'] as num).toDouble()
          : null,
      auctionType: json['auction_type']?.toString() ?? 'online',
      startsAt: _parseDate(json['starts_at']),
      endsAt: _parseDate(json['ends_at']),
      status: json['status']?.toString() ?? 'draft',
      winnerUser: winnerUser,
      winningBidAmount: json['winning_bid_amount'] != null
          ? (json['winning_bid_amount'] as num).toDouble()
          : null,
      createdBy: createdBy,
      createdAt: _parseDate(json['created_at']),
      updatedAt: _parseDate(json['updated_at']),
    );
  }

  static DateTime _parseDate(dynamic date) {
    if (date == null) return DateTime.now();
    try {
      return DateTime.parse(date.toString());
    } catch (e) {
      return DateTime.now();
    }
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
      id: json['_id']?.toString() ?? json['id']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      phone: json['phone']?.toString() ?? '',
      roles: List<String>.from(json['roles'] ?? []),
      firstName: json['first_name']?.toString() ?? '',
      lastName: json['last_name']?.toString() ?? '',
      fullName: json['full_name']?.toString() ?? '',
      status: json['status']?.toString() ?? 'pending',
      nationalIdNumber: json['national_id_number']?.toString(),
      dateOfBirth: json['date_of_birth'] != null
          ? DateTime.tryParse(json['date_of_birth'].toString())
          : null,
      address: json['address']?.toString(),
      location: json['location']?.toString(),
      nationalIdImageUrl: json['national_id_image_url']?.toString(),
      profilePicUrl: json['profile_pic_url']?.toString(),
      emailVerified: json['email_verified'] == true,
      createdAt: _parseDate(json['created_at']),
      updatedAt: _parseDate(json['updated_at']),
    );
  }

  static DateTime _parseDate(dynamic date) {
    if (date == null) return DateTime.now();
    try {
      return DateTime.parse(date.toString());
    } catch (e) {
      return DateTime.now();
    }
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
    // Handle raised_by
    UserBidder? raisedBy;
    try {
      dynamic raisedByData = json['raised_by'];
      if (raisedByData is Map<String, dynamic>) {
        raisedBy = UserBidder.fromJson(raisedByData);
      } else if (raisedByData is String && raisedByData.isNotEmpty) {
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
      }
    } catch (e) {
      debugPrint('Error parsing raised_by: $e');
    }

    // Handle resolved_by
    UserBidder? resolvedBy;
    try {
      dynamic resolvedByData = json['resolved_by'];
      if (resolvedByData is Map<String, dynamic>) {
        resolvedBy = UserBidder.fromJson(resolvedByData);
      } else if (resolvedByData is String && resolvedByData.isNotEmpty) {
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
      }
    } catch (e) {
      debugPrint('Error parsing resolved_by: $e');
    }

    return BidDispute(
      status: _parseDisputeStatus(json['status']?.toString() ?? 'none'),
      reason: json['reason']?.toString(),
      raisedBy: raisedBy,
      raisedAt: _parseNullableDate(json['raised_at']),
      resolvedBy: resolvedBy,
      resolvedAt: _parseNullableDate(json['resolved_at']),
      resolutionNotes: json['resolution_notes']?.toString(),
    );
  }

  static DateTime? _parseNullableDate(dynamic date) {
    if (date == null) return null;
    try {
      return DateTime.parse(date.toString());
    } catch (e) {
      return null;
    }
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

  factory UserBidsResponse.fromJson(Map<String, dynamic> json) {
    return UserBidsResponse(
      bids:
          (json['data'] as List?)
              ?.map((e) => UserBid.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      pagination: Pagination.fromJson(json['pagination'] ?? {}),
    );
  }
}

// REMOVED: The duplicate Pagination class from here
// It is now imported from auctions_mngmt_service.dart
