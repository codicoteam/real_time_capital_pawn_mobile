import 'dart:convert';

class AttachmentModel {
  final String? id;
  final OwnerUser? ownerUser;
  final String? entityType;
  final String? entityId;
  final String? category;
  final String? filename;
  final String? mimeType;
  final String? storage;
  final String? url;
  final bool? signed;
  final String? meta;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final int? v;

  AttachmentModel({
    this.id,
    this.ownerUser,
    this.entityType,
    this.entityId,
    this.category,
    this.filename,
    this.mimeType,
    this.storage,
    this.url,
    this.signed,
    this.meta,
    this.createdAt,
    this.updatedAt,
    this.v,
  });

  factory AttachmentModel.fromJson(String str) =>
      AttachmentModel.fromMap(json.decode(str));

  String toJson() => json.encode(toMap());

  factory AttachmentModel.fromMap(Map<String, dynamic> json) => AttachmentModel(
    id: json["_id"],
    ownerUser: json["owner_user"] == null
        ? null
        : OwnerUser.fromMap(json["owner_user"]),
    entityType: json["entity_type"],
    entityId: json["entity_id"],
    category: json["category"],
    filename: json["filename"],
    mimeType: json["mime_type"],
    storage: json["storage"],
    url: json["url"],
    signed: json["signed"],
    meta: json["meta"],
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
    "owner_user": ownerUser?.toMap(),
    "entity_type": entityType,
    "entity_id": entityId,
    "category": category,
    "filename": filename,
    "mime_type": mimeType,
    "storage": storage,
    "url": url,
    "signed": signed,
    "meta": meta,
    "created_at": createdAt?.toIso8601String(),
    "updated_at": updatedAt?.toIso8601String(),
    "__v": v,
  };
}

class OwnerUser {
  final String? id;
  final String? email;
  final String? firstName;
  final String? lastName;

  OwnerUser({this.id, this.email, this.firstName, this.lastName});

  factory OwnerUser.fromJson(String str) => OwnerUser.fromMap(json.decode(str));

  String toJson() => json.encode(toMap());

  factory OwnerUser.fromMap(Map<String, dynamic> json) => OwnerUser(
    id: json["_id"],
    email: json["email"],
    firstName: json["first_name"],
    lastName: json["last_name"],
  );

  Map<String, dynamic> toMap() => {
    "_id": id,
    "email": email,
    "first_name": firstName,
    "last_name": lastName,
  };
}
