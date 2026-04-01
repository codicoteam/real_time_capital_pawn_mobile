import 'dart:convert';

class AssetModel {
  final String? id;
  final String assetNo;
  final OwnerUser? ownerUser;
  final SubmittedBy? submittedBy;
  final String category;
  final String title;
  final String description;
  final String condition;
  final String status;
  final String? storageLocation;
  final num? declaredValue; // ✅ Make this nullable
  final List<Attachment> attachments;
  final String assetType;
  final DateTime createdAt;
  final DateTime updatedAt;

  // Electronics specific
  final String? brand;
  final String? model;
  final String? serialNo;
  final List<String>? accessories;

  // Vehicle specific
  final String? make;
  final String? vehicleModel;
  final String? registrationNo;
  final String? engineNo;
  final String? chassisNo;
  final String? ccSerialNo;

  // Jewellery specific
  final String? jewelryType;
  final String? material;
  final double? weight;
  final String? purity;
  final double? estimatedValue;

  // Constructor for response/display
  AssetModel({
    this.id,
    required this.assetNo,
    this.ownerUser,
    this.submittedBy,
    required this.category,
    required this.title,
    required this.description,
    required this.condition,
    required this.status,
    this.storageLocation,
    this.declaredValue, // ✅ Now nullable
    required this.attachments,
    required this.assetType,
    required this.createdAt,
    required this.updatedAt,
    this.brand,
    this.model,
    this.serialNo,
    this.accessories,
    this.make,
    this.vehicleModel,
    this.registrationNo,
    this.engineNo,
    this.chassisNo,
    this.ccSerialNo,
    this.jewelryType,
    this.material,
    this.weight,
    this.purity,
    this.estimatedValue,
  });

  // Constructor for creating/payload
  AssetModel.create({
    required this.category,
    required this.title,
    required this.description,
    required this.condition,
    required this.assetType,
    this.declaredValue, // ✅ Optional when creating
    this.storageLocation,
    this.brand,
    this.model,
    this.serialNo,
    this.accessories,
    this.make,
    this.vehicleModel,
    this.registrationNo,
    this.engineNo,
    this.chassisNo,
    this.ccSerialNo,
    this.jewelryType,
    this.material,
    this.weight,
    this.purity,
    this.estimatedValue,
  }) : id = null,
       assetNo = '',
       ownerUser = null,
       submittedBy = null,
       status = '',
       attachments = const [],
       createdAt = DateTime.now(),
       updatedAt = DateTime.now();

  factory AssetModel.fromJson(String str) =>
      AssetModel.fromMap(json.decode(str));

  String toJson() => json.encode(toMap());

  factory AssetModel.fromMap(Map<String, dynamic> json) => AssetModel(
    id: json["_id"],
    assetNo: json["asset_no"] ?? '',
    ownerUser: json["owner_user"] == null
        ? null
        : OwnerUser.fromMap(json["owner_user"]),
    submittedBy: json["submitted_by"] == null
        ? null
        : SubmittedBy.fromMap(json["submitted_by"]),
    category: json["category"] ?? '',
    title: json["title"] ?? '',
    description: json["description"] ?? '',
    condition: json["condition"] ?? '',
    status: json["status"] ?? '',
    storageLocation: json["storage_location"],
    declaredValue: (json["declared_value"] as num?)
        ?.toDouble(), // ✅ Handle null
    attachments: json["attachments"] == null
        ? []
        : List<Attachment>.from(
            json["attachments"].map((x) => Attachment.fromMap(x)),
          ),
    assetType: json["asset_type"] ?? '',
    createdAt: json["created_at"] == null
        ? DateTime.now()
        : DateTime.parse(json["created_at"]),
    updatedAt: json["updated_at"] == null
        ? DateTime.now()
        : DateTime.parse(json["updated_at"]),
    brand: json["brand"],
    model: json["model"],
    serialNo: json["serial_no"],
    accessories: json["accessories"] == null
        ? null
        : List<String>.from(json["accessories"]),
    make: json["make"],
    vehicleModel: json["model"],
    registrationNo: json["registration_no"],
    engineNo: json["engine_no"],
    chassisNo: json["chassis_no"],
    ccSerialNo: json["cc_serial_no"],
    jewelryType: json["type"],
    material: json["material"],
    weight: json["weight"]?.toDouble(),
    purity: json["purity"],
    estimatedValue: json["estimated_value"]?.toDouble(),
  );

  Map<String, dynamic> toMap() => {
    "_id": id,
    "asset_no": assetNo,
    "owner_user": ownerUser?.toMap(),
    "submitted_by": submittedBy?.toMap(),
    "category": category,
    "title": title,
    "description": description,
    "condition": condition,
    "status": status,
    "storage_location": storageLocation,
    "declared_value": declaredValue,
    "attachments": attachments.map((x) => x.toMap()).toList(),
    "asset_type": assetType,
    "created_at": createdAt.toIso8601String(),
    "updated_at": updatedAt.toIso8601String(),
    "brand": brand,
    "model": model,
    "serial_no": serialNo,
    "accessories": accessories,
    "make": make,
    "registration_no": registrationNo,
    "engine_no": engineNo,
    "chassis_no": chassisNo,
    "cc_serial_no": ccSerialNo,
    "type": jewelryType,
    "material": material,
    "weight": weight,
    "purity": purity,
    "estimated_value": estimatedValue,
  };

  // Payload for creating asset (only the fields needed for POST request)
  Map<String, dynamic> toCreatePayload(String ownerUserId) {
    final payload = <String, dynamic>{
      'category': category,
      'title': title,
      'owner_user': ownerUserId,
      'asset_type': assetType,
      'description': description,
      'condition': condition,
    };

    if (declaredValue != null) payload['declared_value'] = declaredValue;
    if (storageLocation != null) payload['storage_location'] = storageLocation;

    // Electronics fields
    if (brand != null) payload['brand'] = brand;
    if (model != null) payload['model'] = model;
    if (serialNo != null) payload['serial_no'] = serialNo;
    if (accessories != null) payload['accessories'] = accessories;

    // Vehicle fields
    if (make != null) payload['make'] = make;
    if (registrationNo != null) payload['registration_no'] = registrationNo;
    if (engineNo != null) payload['engine_no'] = engineNo;
    if (chassisNo != null) payload['chassis_no'] = chassisNo;
    if (ccSerialNo != null) payload['cc_serial_no'] = ccSerialNo;

    // Jewellery fields
    if (jewelryType != null) payload['type'] = jewelryType;
    if (material != null) payload['material'] = material;
    if (weight != null) payload['weight'] = weight;
    if (purity != null) payload['purity'] = purity;
    if (estimatedValue != null) payload['estimated_value'] = estimatedValue;

    return payload;
  }
}

class OwnerUser {
  final String? id;
  final String? email;
  final String? phone;
  final String? firstName;
  final String? lastName;
  final String? nationalIdNumber;
  final String? address;

  OwnerUser({
    this.id,
    this.email,
    this.phone,
    this.firstName,
    this.lastName,
    this.nationalIdNumber,
    this.address,
  });

  factory OwnerUser.fromMap(Map<String, dynamic> json) => OwnerUser(
    id: json["_id"],
    email: json["email"],
    phone: json["phone"],
    firstName: json["first_name"],
    lastName: json["last_name"],
    nationalIdNumber: json["national_id_number"],
    address: json["address"],
  );

  Map<String, dynamic> toMap() => {
    "_id": id,
    "email": email,
    "phone": phone,
    "first_name": firstName,
    "last_name": lastName,
    "national_id_number": nationalIdNumber,
    "address": address,
  };
}

class SubmittedBy {
  final String? id;
  final String? email;
  final String? phone;
  final String? firstName;
  final String? lastName;

  SubmittedBy({this.id, this.email, this.phone, this.firstName, this.lastName});

  factory SubmittedBy.fromMap(Map<String, dynamic> json) => SubmittedBy(
    id: json["_id"],
    email: json["email"],
    phone: json["phone"],
    firstName: json["first_name"],
    lastName: json["last_name"],
  );

  Map<String, dynamic> toMap() => {
    "_id": id,
    "email": email,
    "phone": phone,
    "first_name": firstName,
    "last_name": lastName,
  };
}

class Attachment {
  final String? id;
  final String? category;
  final String? filename;
  final String? mimeType;
  final String? url;
  final DateTime? createdAt;

  Attachment({
    this.id,
    this.category,
    this.filename,
    this.mimeType,
    this.url,
    this.createdAt,
  });

  factory Attachment.fromMap(Map<String, dynamic> json) => Attachment(
    id: json["_id"],
    category: json["category"],
    filename: json["filename"],
    mimeType: json["mime_type"],
    url: json["url"],
    createdAt: json["created_at"] == null
        ? null
        : DateTime.parse(json["created_at"]),
  );

  Map<String, dynamic> toMap() => {
    "_id": id,
    "category": category,
    "filename": filename,
    "mime_type": mimeType,
    "url": url,
    "created_at": createdAt?.toIso8601String(),
  };
}

class AssetResponse {
  final List<AssetModel> assets;
  final Pagination pagination;

  AssetResponse({required this.assets, required this.pagination});

  factory AssetResponse.fromJson(Map<String, dynamic> json) {
    try {
      List<AssetModel> parsedAssets = [];
      Map<String, dynamic> paginationData = {};

      if (json['data'] != null) {
        final data = json['data'] as Map<String, dynamic>;

        if (data['assets'] != null && data['assets'] is List) {
          parsedAssets = List<AssetModel>.from(
            (data['assets'] as List).map((x) => AssetModel.fromMap(x)),
          );
        }

        if (data['pagination'] != null && data['pagination'] is Map) {
          paginationData = data['pagination'] as Map<String, dynamic>;
        }
      }

      final pagination = Pagination.fromJson(paginationData);

      return AssetResponse(assets: parsedAssets, pagination: pagination);
    } catch (e) {
      print('ERROR in AssetResponse.fromJson: $e');
      return AssetResponse(
        assets: [],
        pagination: Pagination(page: 1, limit: 10, total: 0, pages: 0),
      );
    }
  }
}

class Pagination {
  final int page;
  final int limit;
  final int total;
  final int pages;
  final bool hasNextPage;
  final bool hasPrevPage;

  Pagination({
    required this.page,
    required this.limit,
    required this.total,
    required this.pages,
    this.hasNextPage = false,
    this.hasPrevPage = false,
  });

  factory Pagination.fromJson(Map<String, dynamic> json) {
    try {
      return Pagination(
        page: int.tryParse((json['page'] ?? '1').toString()) ?? 1,
        limit: int.tryParse((json['limit'] ?? '10').toString()) ?? 10,
        total: int.tryParse((json['total'] ?? '0').toString()) ?? 0,
        pages:
            int.tryParse(
              (json['totalPages'] ?? json['pages'] ?? '1').toString(),
            ) ??
            1,
        hasNextPage: json['hasNextPage'] ?? false,
        hasPrevPage: json['hasPrevPage'] ?? false,
      );
    } catch (e) {
      return Pagination(page: 1, limit: 10, total: 0, pages: 0);
    }
  }
}
