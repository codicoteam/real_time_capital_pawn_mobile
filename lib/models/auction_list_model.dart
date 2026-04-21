import 'dart:convert';

class AuctionListModel {
    final String? id;
    final String? auctionNo;
    final Asset? asset;
    final int? startingBidAmount;
    final int? reservePrice;
    final String? auctionType;
    final DateTime? startsAt;
    final DateTime? endsAt;
    final String? status;
    final String? createdBy;
    final DateTime? createdAt;
    final DateTime? updatedAt;
    final int? v;

    AuctionListModel({
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

    factory AuctionListModel.fromJson(String str) => AuctionListModel.fromMap(json.decode(str));

    String toJson() => json.encode(toMap());

    factory AuctionListModel.fromMap(Map<String, dynamic> json) => AuctionListModel(
        id: json["_id"],
        auctionNo: json["auction_no"],
        asset: json["asset"] == null ? null : Asset.fromMap(json["asset"]),
        startingBidAmount: json["starting_bid_amount"],
        reservePrice: json["reserve_price"],
        auctionType: json["auction_type"],
        startsAt: json["starts_at"] == null ? null : DateTime.parse(json["starts_at"]),
        endsAt: json["ends_at"] == null ? null : DateTime.parse(json["ends_at"]),
        status: json["status"],
        createdBy: json["created_by"],
        createdAt: json["created_at"] == null ? null : DateTime.parse(json["created_at"]),
        updatedAt: json["updated_at"] == null ? null : DateTime.parse(json["updated_at"]),
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
        "created_by": createdBy,
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
    final List<dynamic>? attachments;

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
        this.attachments,
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
        assetImages: json["asset_images"] == null ? [] : List<String>.from(json["asset_images"]!.map((x) => x)),
        status: json["status"],
        storageLocation: json["storage_location"],
        declaredValue: json["declared_value"],
        evaluatedValue: json["evaluated_value"],
        createdAt: json["created_at"] == null ? null : DateTime.parse(json["created_at"]),
        updatedAt: json["updated_at"] == null ? null : DateTime.parse(json["updated_at"]),
        v: json["__v"],
        activeLoan: json["active_loan"],
        attachments: json["attachments"] == null ? [] : List<dynamic>.from(json["attachments"]!.map((x) => x)),
    );

    Map<String, dynamic> toMap() => {
        "_id": id,
        "asset_no": assetNo,
        "owner_user": ownerUser,
        "category": category,
        "title": title,
        "description": description,
        "condition": condition,
        "asset_images": assetImages == null ? [] : List<dynamic>.from(assetImages!.map((x) => x)),
        "status": status,
        "storage_location": storageLocation,
        "declared_value": declaredValue,
        "evaluated_value": evaluatedValue,
        "created_at": createdAt?.toIso8601String(),
        "updated_at": updatedAt?.toIso8601String(),
        "__v": v,
        "active_loan": activeLoan,
        "attachments": attachments == null ? [] : List<dynamic>.from(attachments!.map((x) => x)),
    };
}
