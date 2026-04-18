import 'dart:convert';

class LoanApplicationModel {
  final String? id;
  final String? applicationNo;
  final CustomerUser? customerUser;
  final int? requestedLoanAmount;
  final String? collateralCategory;
  final String? collateralDescription;
  final String? suretyDescription;
  final int? declaredAssetValue;
  final JewelleryDetails? jewelleryDetails;
  final List<String>? collateralImages;
  final String? repaymentType;
  final int? repaymentDays;
  final String? declarationText;
  final DateTime? declarationSignedAt;
  final String? declarationSignatureName;
  final String? status;
  final DebtorCheck? debtorCheck;
  final String? customTermsAndConditions;
  final CreatedBy? createdBy;
  final String? applicationSource;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final List<AdminNote>? adminNotes;
  final int? v;
  final int? installmentCount;
  final String? installmentFrequency;
  final int? installmentAmount;
  final MotorVehicleDetails? motorVehicleDetails;
  final SmallLoanDetails? smallLoanDetails;

  LoanApplicationModel({
    this.id,
    this.applicationNo,
    this.customerUser,
    this.requestedLoanAmount,
    this.collateralCategory,
    this.collateralDescription,
    this.suretyDescription,
    this.declaredAssetValue,
    this.jewelleryDetails,
    this.collateralImages,
    this.repaymentType,
    this.repaymentDays,
    this.declarationText,
    this.declarationSignedAt,
    this.declarationSignatureName,
    this.status,
    this.debtorCheck,
    this.customTermsAndConditions,
    this.createdBy,
    this.applicationSource,
    this.createdAt,
    this.updatedAt,
    this.adminNotes,
    this.v,
    this.installmentCount,
    this.installmentFrequency,
    this.installmentAmount,
    this.motorVehicleDetails,
    this.smallLoanDetails,
  });

  factory LoanApplicationModel.fromJson(String str) =>
      LoanApplicationModel.fromMap(json.decode(str));

  String toJson() => json.encode(toMap());

  factory LoanApplicationModel.fromMap(Map<String, dynamic> json) =>
      LoanApplicationModel(
        id: json["_id"],
        applicationNo: json["application_no"],
        customerUser: json["customer_user"] == null
            ? null
            : CustomerUser.fromMap(json["customer_user"]),
        requestedLoanAmount: json["requested_loan_amount"],
        collateralCategory: json["collateral_category"],
        collateralDescription: json["collateral_description"],
        suretyDescription: json["surety_description"],
        declaredAssetValue: json["declared_asset_value"],
        jewelleryDetails: json["jewellery_details"] == null
            ? null
            : JewelleryDetails.fromMap(json["jewellery_details"]),
        collateralImages: json["collateral_images"] == null
            ? []
            : List<String>.from(json["collateral_images"]!.map((x) => x)),
        repaymentType: json["repayment_type"],
        repaymentDays: json["repayment_days"],
        declarationText: json["declaration_text"],
        declarationSignedAt: json["declaration_signed_at"] == null
            ? null
            : DateTime.parse(json["declaration_signed_at"]),
        declarationSignatureName: json["declaration_signature_name"],
        status: json["status"],
        debtorCheck: json["debtor_check"] == null
            ? null
            : DebtorCheck.fromMap(json["debtor_check"]),
        customTermsAndConditions: json["custom_terms_and_conditions"],
        createdBy: json["created_by"] == null
            ? null
            : CreatedBy.fromMap(json["created_by"]),
        applicationSource: json["application_source"],
        createdAt: json["created_at"] == null
            ? null
            : DateTime.parse(json["created_at"]),
        updatedAt: json["updated_at"] == null
            ? null
            : DateTime.parse(json["updated_at"]),
        adminNotes: json["admin_notes"] == null
            ? []
            : List<AdminNote>.from(
                json["admin_notes"]!.map((x) => AdminNote.fromMap(x)),
              ),
        v: json["__v"],
        installmentCount: json["installment_count"],
        installmentFrequency: json["installment_frequency"],
        installmentAmount: json["installment_amount"],
        motorVehicleDetails: json["motor_vehicle_details"] == null
            ? null
            : MotorVehicleDetails.fromMap(json["motor_vehicle_details"]),
        smallLoanDetails: json["small_loan_details"] == null
            ? null
            : SmallLoanDetails.fromMap(json["small_loan_details"]),
      );

  Map<String, dynamic> toMap() => {
    "_id": id,
    "application_no": applicationNo,
    "customer_user": customerUser?.toMap(),
    "requested_loan_amount": requestedLoanAmount,
    "collateral_category": collateralCategory,
    "collateral_description": collateralDescription,
    "surety_description": suretyDescription,
    "declared_asset_value": declaredAssetValue,
    "jewellery_details": jewelleryDetails?.toMap(),
    "collateral_images": collateralImages == null
        ? []
        : List<dynamic>.from(collateralImages!.map((x) => x)),
    "repayment_type": repaymentType,
    "repayment_days": repaymentDays,
    "declaration_text": declarationText,
    "declaration_signed_at": declarationSignedAt?.toIso8601String(),
    "declaration_signature_name": declarationSignatureName,
    "status": status,
    "debtor_check": debtorCheck?.toMap(),
    "custom_terms_and_conditions": customTermsAndConditions,
    "created_by": createdBy?.toMap(),
    "application_source": applicationSource,
    "created_at": createdAt?.toIso8601String(),
    "updated_at": updatedAt?.toIso8601String(),
    "admin_notes": adminNotes == null
        ? []
        : List<dynamic>.from(adminNotes!.map((x) => x.toMap())),
    "__v": v,
    "installment_count": installmentCount,
    "installment_frequency": installmentFrequency,
    "installment_amount": installmentAmount,
    "motor_vehicle_details": motorVehicleDetails?.toMap(),
    "small_loan_details": smallLoanDetails?.toMap(),
  };
}

class AdminNote {
  final String? note;
  final CreatedBy? createdBy;
  final DateTime? createdAt;
  final String? id;

  AdminNote({this.note, this.createdBy, this.createdAt, this.id});

  factory AdminNote.fromJson(String str) => AdminNote.fromMap(json.decode(str));

  String toJson() => json.encode(toMap());

  factory AdminNote.fromMap(Map<String, dynamic> json) => AdminNote(
    note: json["note"],
    createdBy: json["created_by"] == null
        ? null
        : CreatedBy.fromMap(json["created_by"]),
    createdAt: json["created_at"] == null
        ? null
        : DateTime.parse(json["created_at"]),
    id: json["_id"],
  );

  Map<String, dynamic> toMap() => {
    "note": note,
    "created_by": createdBy?.toMap(),
    "created_at": createdAt?.toIso8601String(),
    "_id": id,
  };
}

class CreatedBy {
  final String? id;
  final String? email;
  final List<String>? roles;
  final String? firstName;
  final String? lastName;

  CreatedBy({this.id, this.email, this.roles, this.firstName, this.lastName});

  factory CreatedBy.fromJson(String str) => CreatedBy.fromMap(json.decode(str));

  String toJson() => json.encode(toMap());

  factory CreatedBy.fromMap(Map<String, dynamic> json) => CreatedBy(
    id: json["_id"],
    email: json["email"],
    roles: json["roles"] == null
        ? []
        : List<String>.from(json["roles"]!.map((x) => x)),
    firstName: json["first_name"],
    lastName: json["last_name"],
  );

  Map<String, dynamic> toMap() => {
    "_id": id,
    "email": email,
    "roles": roles == null ? [] : List<dynamic>.from(roles!.map((x) => x)),
    "first_name": firstName,
    "last_name": lastName,
  };
}

class CustomerUser {
  final String? id;
  final String? email;
  final String? phone;
  final String? firstName;
  final String? lastName;
  final String? nationalIdNumber;
  final DateTime? dateOfBirth;
  final String? address;
  final String? gender;
  final String? maritalStatus;

  CustomerUser({
    this.id,
    this.email,
    this.phone,
    this.firstName,
    this.lastName,
    this.nationalIdNumber,
    this.dateOfBirth,
    this.address,
    this.gender,
    this.maritalStatus,
  });

  factory CustomerUser.fromJson(String str) =>
      CustomerUser.fromMap(json.decode(str));

  String toJson() => json.encode(toMap());

  factory CustomerUser.fromMap(Map<String, dynamic> json) => CustomerUser(
    id: json["_id"],
    email: json["email"],
    phone: json["phone"],
    firstName: json["first_name"],
    lastName: json["last_name"],
    nationalIdNumber: json["national_id_number"],
    dateOfBirth: json["date_of_birth"] == null
        ? null
        : DateTime.parse(json["date_of_birth"]),
    address: json["address"],
    gender: json["gender"],
    maritalStatus: json["marital_status"],
  );

  Map<String, dynamic> toMap() => {
    "_id": id,
    "email": email,
    "phone": phone,
    "first_name": firstName,
    "last_name": lastName,
    "national_id_number": nationalIdNumber,
    "date_of_birth": dateOfBirth?.toIso8601String(),
    "address": address,
    "gender": gender,
    "marital_status": maritalStatus,
  };
}

class DebtorCheck {
  final bool? checked;
  final bool? matched;
  final List<dynamic>? matchedDebtorRecords;

  DebtorCheck({this.checked, this.matched, this.matchedDebtorRecords});

  factory DebtorCheck.fromJson(String str) =>
      DebtorCheck.fromMap(json.decode(str));

  String toJson() => json.encode(toMap());

  factory DebtorCheck.fromMap(Map<String, dynamic> json) => DebtorCheck(
    checked: json["checked"],
    matched: json["matched"],
    matchedDebtorRecords: json["matched_debtor_records"] == null
        ? []
        : List<dynamic>.from(json["matched_debtor_records"]!.map((x) => x)),
  );

  Map<String, dynamic> toMap() => {
    "checked": checked,
    "matched": matched,
    "matched_debtor_records": matchedDebtorRecords == null
        ? []
        : List<dynamic>.from(matchedDebtorRecords!.map((x) => x)),
  };
}

class JewelleryDetails {
  final String? type;
  final String? description;
  final int? weight;
  final String? purity;
  final int? estimatedValue;

  JewelleryDetails({
    this.type,
    this.description,
    this.weight,
    this.purity,
    this.estimatedValue,
  });

  factory JewelleryDetails.fromJson(String str) =>
      JewelleryDetails.fromMap(json.decode(str));

  String toJson() => json.encode(toMap());

  factory JewelleryDetails.fromMap(Map<String, dynamic> json) =>
      JewelleryDetails(
        type: json["type"],
        description: json["description"],
        weight: json["weight"],
        purity: json["purity"],
        estimatedValue: json["estimated_value"],
      );

  Map<String, dynamic> toMap() => {
    "type": type,
    "description": description,
    "weight": weight,
    "purity": purity,
    "estimated_value": estimatedValue,
  };
}

class MotorVehicleDetails {
  final String? make;
  final String? model;
  final String? registrationNo;
  final String? ccSerialNo;
  final String? engineNo;
  final String? chassisNo;
  final int? year;

  MotorVehicleDetails({
    this.make,
    this.model,
    this.registrationNo,
    this.ccSerialNo,
    this.engineNo,
    this.chassisNo,
    this.year,
  });

  factory MotorVehicleDetails.fromJson(String str) =>
      MotorVehicleDetails.fromMap(json.decode(str));

  String toJson() => json.encode(toMap());

  factory MotorVehicleDetails.fromMap(Map<String, dynamic> json) =>
      MotorVehicleDetails(
        make: json["make"],
        model: json["model"],
        registrationNo: json["registration_no"],
        ccSerialNo: json["cc_serial_no"],
        engineNo: json["engine_no"],
        chassisNo: json["chassis_no"],
        year: json["year"],
      );

  Map<String, dynamic> toMap() => {
    "make": make,
    "model": model,
    "registration_no": registrationNo,
    "cc_serial_no": ccSerialNo,
    "engine_no": engineNo,
    "chassis_no": chassisNo,
    "year": year,
  };
}

class SmallLoanDetails {
  final String? type;
  final String? model;
  final String? serialNo;

  SmallLoanDetails({this.type, this.model, this.serialNo});

  factory SmallLoanDetails.fromJson(String str) =>
      SmallLoanDetails.fromMap(json.decode(str));

  String toJson() => json.encode(toMap());

  factory SmallLoanDetails.fromMap(Map<String, dynamic> json) =>
      SmallLoanDetails(
        type: json["type"],
        model: json["model"],
        serialNo: json["serial_no"],
      );

  Map<String, dynamic> toMap() => {
    "type": type,
    "model": model,
    "serial_no": serialNo,
  };
}
