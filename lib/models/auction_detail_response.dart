import 'dart:convert';

class AuctionDetailResponse {
  final bool? success;
  final Data? data;

  AuctionDetailResponse({this.success, this.data});

  factory AuctionDetailResponse.fromJson(String str) =>
      AuctionDetailResponse.fromMap(json.decode(str));

  String toJson() => json.encode(toMap());

  factory AuctionDetailResponse.fromMap(Map<String, dynamic> json) =>
      AuctionDetailResponse(
        success: json["success"],
        data: json["data"] == null ? null : Data.fromMap(json["data"]),
      );

  Map<String, dynamic> toMap() => {"success": success, "data": data?.toMap()};
}

class Data {
  final Auction? auction;
  final CurrentBid? currentBid;

  Data({this.auction, this.currentBid});

  factory Data.fromJson(String str) => Data.fromMap(json.decode(str));

  String toJson() => json.encode(toMap());

  factory Data.fromMap(Map<String, dynamic> json) => Data(
    auction: json["auction"] == null ? null : Auction.fromMap(json["auction"]),
    currentBid: json["current_bid"] == null
        ? null
        : CurrentBid.fromMap(json["current_bid"]),
  );

  Map<String, dynamic> toMap() => {
    "auction": auction?.toMap(),
    "current_bid": currentBid?.toMap(),
  };
}

class Auction {
  final String? id;
  final String? auctionNo;
  final Asset? asset;
  final int? startingBidAmount;
  final int? reservePrice;
  final String? auctionType;
  final DateTime? startsAt;
  final DateTime? endsAt;
  final String? status;
  final CreatedBy? createdBy;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final int? v;

  Auction({
    this.id,
    this.auctionNo,
    this.asset,
    this.startingBidAmount,
    this.reservePrice,
    this.auctionType,
    this.startsAt,
    this.endsAt,
    this.status,
    this.createdBy,
    this.createdAt,
    this.updatedAt,
    this.v,
  });

  factory Auction.fromJson(String str) => Auction.fromMap(json.decode(str));

  String toJson() => json.encode(toMap());

  factory Auction.fromMap(Map<String, dynamic> json) => Auction(
    id: json["_id"],
    auctionNo: json["auction_no"],
    asset: json["asset"] == null ? null : Asset.fromMap(json["asset"]),
    startingBidAmount: json["starting_bid_amount"],
    reservePrice: json["reserve_price"],
    auctionType: json["auction_type"],
    startsAt: json["starts_at"] == null
        ? null
        : DateTime.parse(json["starts_at"]),
    endsAt: json["ends_at"] == null ? null : DateTime.parse(json["ends_at"]),
    status: json["status"],
    createdBy: json["created_by"] == null
        ? null
        : CreatedBy.fromMap(json["created_by"]),
    createdAt: json["created_at"] == null
        ? null
        : DateTime.parse(json["created_at"]),
    updatedAt: json["updated_at"] == null
        ? null
        : DateTime.parse(json["updated_at"]),
    v: json["__v"],
  );

  Map<String, dynamic> toMap() => {
    "_id": id,
    "auction_no": auctionNo,
    "asset": asset?.toMap(),
    "starting_bid_amount": startingBidAmount,
    "reserve_price": reservePrice,
    "auction_type": auctionType,
    "starts_at": startsAt?.toIso8601String(),
    "ends_at": endsAt?.toIso8601String(),
    "status": status,
    "created_by": createdBy?.toMap(),
    "created_at": createdAt?.toIso8601String(),
    "updated_at": updatedAt?.toIso8601String(),
    "__v": v,
  };
}

class Asset {
  final String? id;
  final String? assetNo;
  final String? ownerUser;
  final String? category;
  final String? title;
  final String? description;
  final String? condition;
  final List<String>? assetImages;
  final String? status;
  final String? storageLocation;
  final int? declaredValue;
  final int? evaluatedValue;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final int? v;
  final String? activeLoan;

  Asset({
    this.id,
    this.assetNo,
    this.ownerUser,
    this.category,
    this.title,
    this.description,
    this.condition,
    this.assetImages,
    this.status,
    this.storageLocation,
    this.declaredValue,
    this.evaluatedValue,
    this.createdAt,
    this.updatedAt,
    this.v,
    this.activeLoan,
  });

  factory Asset.fromJson(String str) => Asset.fromMap(json.decode(str));

  String toJson() => json.encode(toMap());

  factory Asset.fromMap(Map<String, dynamic> json) => Asset(
    id: json["_id"],
    assetNo: json["asset_no"],
    ownerUser: json["owner_user"],
    category: json["category"],
    title: json["title"],
    description: json["description"],
    condition: json["condition"],
    assetImages: json["asset_images"] == null
        ? []
        : List<String>.from(json["asset_images"]!.map((x) => x)),
    status: json["status"],
    storageLocation: json["storage_location"],
    declaredValue: json["declared_value"],
    evaluatedValue: json["evaluated_value"],
    createdAt: json["created_at"] == null
        ? null
        : DateTime.parse(json["created_at"]),
    updatedAt: json["updated_at"] == null
        ? null
        : DateTime.parse(json["updated_at"]),
    v: json["__v"],
    activeLoan: json["active_loan"],
  );

  Map<String, dynamic> toMap() => {
    "_id": id,
    "asset_no": assetNo,
    "owner_user": ownerUser,
    "category": category,
    "title": title,
    "description": description,
    "condition": condition,
    "asset_images": assetImages == null
        ? []
        : List<dynamic>.from(assetImages!.map((x) => x)),
    "status": status,
    "storage_location": storageLocation,
    "declared_value": declaredValue,
    "evaluated_value": evaluatedValue,
    "created_at": createdAt?.toIso8601String(),
    "updated_at": updatedAt?.toIso8601String(),
    "__v": v,
    "active_loan": activeLoan,
  };
}

class CreatedBy {
  final String? id;
  final String? email;

  CreatedBy({this.id, this.email});

  factory CreatedBy.fromJson(String str) => CreatedBy.fromMap(json.decode(str));

  String toJson() => json.encode(toMap());

  factory CreatedBy.fromMap(Map<String, dynamic> json) =>
      CreatedBy(id: json["_id"], email: json["email"]);

  Map<String, dynamic> toMap() => {"_id": id, "email": email};
}

class CurrentBid {
  final String? id;
  final String? auction;
  final CreatedBy? bidderUser;
  final int? amount;
  final String? currency;
  final DateTime? placedAt;
  final String? paymentStatus;
  final int? paidAmount;
  final Dispute? dispute;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final int? v;

  CurrentBid({
    this.id,
    this.auction,
    this.bidderUser,
    this.amount,
    this.currency,
    this.placedAt,
    this.paymentStatus,
    this.paidAmount,
    this.dispute,
    this.createdAt,
    this.updatedAt,
    this.v,
  });

  factory CurrentBid.fromJson(String str) =>
      CurrentBid.fromMap(json.decode(str));

  String toJson() => json.encode(toMap());

  factory CurrentBid.fromMap(Map<String, dynamic> json) => CurrentBid(
    id: json["_id"],
    auction: json["auction"],
    bidderUser: json["bidder_user"] == null
        ? null
        : CreatedBy.fromMap(json["bidder_user"]),
    amount: json["amount"],
    currency: json["currency"],
    placedAt: json["placed_at"] == null
        ? null
        : DateTime.parse(json["placed_at"]),
    paymentStatus: json["payment_status"],
    paidAmount: json["paid_amount"],
    dispute: json["dispute"] == null ? null : Dispute.fromMap(json["dispute"]),
    createdAt: json["created_at"] == null
        ? null
        : DateTime.parse(json["created_at"]),
    updatedAt: json["updated_at"] == null
        ? null
        : DateTime.parse(json["updated_at"]),
    v: json["__v"],
  );

  Map<String, dynamic> toMap() => {
    "_id": id,
    "auction": auction,
    "bidder_user": bidderUser?.toMap(),
    "amount": amount,
    "currency": currency,
    "placed_at": placedAt?.toIso8601String(),
    "payment_status": paymentStatus,
    "paid_amount": paidAmount,
    "dispute": dispute?.toMap(),
    "created_at": createdAt?.toIso8601String(),
    "updated_at": updatedAt?.toIso8601String(),
    "__v": v,
  };
}

class Dispute {
  final String? status;

  Dispute({this.status});

  factory Dispute.fromJson(String str) => Dispute.fromMap(json.decode(str));

  String toJson() => json.encode(toMap());

  factory Dispute.fromMap(Map<String, dynamic> json) =>
      Dispute(status: json["status"]);

  Map<String, dynamic> toMap() => {"status": status};
}
