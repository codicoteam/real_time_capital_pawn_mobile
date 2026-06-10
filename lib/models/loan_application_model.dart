import 'dart:convert';

class LoanApplicationModel {
  final String? id;
  final String? applicationNo;
  final CustomerUser? customerUser;
  final double? requestedLoanAmount;
  final String? loanPeriodType;
  final double? interestRate;
  final double? interestAmount;
  final double? storageRate;
  final double? storageAmount;
  final double? totalRepayableAmount;
  final String? collateralCategory;
  final String? collateralDescription;
  final String? suretyDescription;
  final double? declaredAssetValue;
  final SmallLoanDetails? smallLoanDetails;
  final List<String>? collateralImages;
  final String? repaymentType;
  final int? repaymentDays;
  final String? declarationText;
  final DateTime? declarationSignedAt;
  final String? declarationSignatureName;
  final String? status;
  final bool? loanCreated;
  final String? loanId;
  final DebtorCheck? debtorCheck;
  final String? customTermsAndConditions;
  final DateTime? termsAcceptedAt;
  final EdBy? createdBy;
  final EdBy? submittedBy;
  final String? applicationSource;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final List<AdminNote>? adminNotes;
  final List<StatusUpdate>? statusUpdates;
  final int? v;
  final MotorVehicleDetails? motorVehicleDetails;
  final String? internalNotes;
  final EdBy? processedBy;
  final JewelleryDetails? jewelleryDetails;

  LoanApplicationModel({
    this.id,
    this.applicationNo,
    this.customerUser,
    this.requestedLoanAmount,
    this.loanPeriodType,
    this.interestRate,
    this.interestAmount,
    this.storageRate,
    this.storageAmount,
    this.totalRepayableAmount,
    this.collateralCategory,
    this.collateralDescription,
    this.suretyDescription,
    this.declaredAssetValue,
    this.smallLoanDetails,
    this.collateralImages,
    this.repaymentType,
    this.repaymentDays,
    this.declarationText,
    this.declarationSignedAt,
    this.declarationSignatureName,
    this.status,
    this.loanCreated,
    this.loanId,
    this.debtorCheck,
    this.customTermsAndConditions,
    this.termsAcceptedAt,
    this.createdBy,
    this.submittedBy,
    this.applicationSource,
    this.createdAt,
    this.updatedAt,
    this.adminNotes,
    this.statusUpdates,
    this.v,
    this.motorVehicleDetails,
    this.internalNotes,
    this.processedBy,
    this.jewelleryDetails,
  });

  factory LoanApplicationModel.fromJson(String str) =>
      LoanApplicationModel.fromMap(json.decode(str));

  String toJson() => json.encode(toMap());

  factory LoanApplicationModel.fromMap(Map<String, dynamic> json) =>
      LoanApplicationModel(
        id: json["_id"],
        applicationNo: json["application_no"],
        customerUser: json["customer_user"] is Map
            ? CustomerUser.fromMap(Map<String, dynamic>.from(json["customer_user"]))
            : null,
        requestedLoanAmount: json["requested_loan_amount"]?.toDouble(),
        loanPeriodType: json["loan_period_type"],
        interestRate: json["interest_rate"]?.toDouble(),
        interestAmount: json["interest_amount"]?.toDouble(),
        storageRate: json["storage_rate"]?.toDouble(),
        storageAmount: json["storage_amount"]?.toDouble(),
        totalRepayableAmount: json["total_repayable_amount"]?.toDouble(),
        collateralCategory: json["collateral_category"],
        collateralDescription: json["collateral_description"],
        suretyDescription: json["surety_description"],
        declaredAssetValue: json["declared_asset_value"]?.toDouble(),
        smallLoanDetails: json["small_loan_details"] is Map
            ? SmallLoanDetails.fromMap(Map<String, dynamic>.from(json["small_loan_details"]))
            : null,
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
        loanCreated: json["loan_created"],
        loanId: json["loan_id"] is String
            ? json["loan_id"]
            : json["loan_id"]?["_id"],
        debtorCheck: json["debtor_check"] is Map
            ? DebtorCheck.fromMap(Map<String, dynamic>.from(json["debtor_check"]))
            : null,
        customTermsAndConditions: json["custom_terms_and_conditions"],
        termsAcceptedAt: json["terms_accepted_at"] == null
            ? null
            : DateTime.parse(json["terms_accepted_at"]),
        createdBy: json["created_by"] is Map
            ? EdBy.fromMap(Map<String, dynamic>.from(json["created_by"]))
            : null,
        submittedBy: json["submitted_by"] is Map
            ? EdBy.fromMap(Map<String, dynamic>.from(json["submitted_by"]))
            : null,
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
        statusUpdates: json["status_updates"] == null
            ? []
            : List<StatusUpdate>.from(
                json["status_updates"]!.map((x) => StatusUpdate.fromMap(x)),
              ),
        v: json["__v"],
        motorVehicleDetails: json["motor_vehicle_details"] is Map
            ? MotorVehicleDetails.fromMap(Map<String, dynamic>.from(json["motor_vehicle_details"]))
            : null,
        internalNotes: json["internal_notes"],
        processedBy: json["processed_by"] is Map
            ? EdBy.fromMap(Map<String, dynamic>.from(json["processed_by"]))
            : null,
        jewelleryDetails: json["jewellery_details"] is Map
            ? JewelleryDetails.fromMap(Map<String, dynamic>.from(json["jewellery_details"]))
            : null,
      );

  Map<String, dynamic> toMap() => {
        "_id": id,
        "application_no": applicationNo,
        "customer_user": customerUser?.toMap(),
        "requested_loan_amount": requestedLoanAmount,
        "loan_period_type": loanPeriodType,
        "interest_rate": interestRate,
        "interest_amount": interestAmount,
        "storage_rate": storageRate,
        "storage_amount": storageAmount,
        "total_repayable_amount": totalRepayableAmount,
        "collateral_category": collateralCategory,
        "collateral_description": collateralDescription,
        "surety_description": suretyDescription,
        "declared_asset_value": declaredAssetValue,
        "small_loan_details": smallLoanDetails?.toMap(),
        "collateral_images": collateralImages == null
            ? []
            : List<dynamic>.from(collateralImages!.map((x) => x)),
        "repayment_type": repaymentType,
        "repayment_days": repaymentDays,
        "declaration_text": declarationText,
        "declaration_signed_at": declarationSignedAt?.toIso8601String(),
        "declaration_signature_name": declarationSignatureName,
        "status": status,
        "loan_created": loanCreated,
        "loan_id": loanId,
        "debtor_check": debtorCheck?.toMap(),
        "custom_terms_and_conditions": customTermsAndConditions,
        "terms_accepted_at": termsAcceptedAt?.toIso8601String(),
        "created_by": createdBy?.toMap(),
        "submitted_by": submittedBy?.toMap(),
        "application_source": applicationSource,
        "created_at": createdAt?.toIso8601String(),
        "updated_at": updatedAt?.toIso8601String(),
        "admin_notes": adminNotes == null
            ? []
            : List<dynamic>.from(adminNotes!.map((x) => x.toMap())),
        "status_updates": statusUpdates == null
            ? []
            : List<dynamic>.from(statusUpdates!.map((x) => x.toMap())),
        "__v": v,
        "motor_vehicle_details": motorVehicleDetails?.toMap(),
        "internal_notes": internalNotes,
        "processed_by": processedBy?.toMap(),
        "jewellery_details": jewelleryDetails?.toMap(),
      };
}

// ✅ All enum fields replaced with plain String?
class EdBy {
  final String? id;
  final String? email;
  final List<String>? roles;
  final String? firstName;
  final String? lastName;

  EdBy({this.id, this.email, this.roles, this.firstName, this.lastName});

  factory EdBy.fromJson(String str) => EdBy.fromMap(json.decode(str));

  String toJson() => json.encode(toMap());

  factory EdBy.fromMap(Map<String, dynamic> json) => EdBy(
    id: json["_id"],
    email: json["email"],
    roles: json["roles"] == null
        ? []
        : List<String>.from(json["roles"]!.map((x) => x.toString())),
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

// ✅ All enum fields replaced with plain String?
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

class AdminNote {
  final String? note;
  final EdBy? createdBy;
  final DateTime? createdAt;
  final String? id;

  AdminNote({this.note, this.createdBy, this.createdAt, this.id});

  factory AdminNote.fromJson(String str) => AdminNote.fromMap(json.decode(str));

  String toJson() => json.encode(toMap());

  factory AdminNote.fromMap(Map<String, dynamic> json) => AdminNote(
    note: json["note"],
    createdBy: json["created_by"] is Map
        ? EdBy.fromMap(Map<String, dynamic>.from(json["created_by"]))
        : null,
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

class DebtorCheck {
  final bool? checked;
  final bool? matched;
  final List<dynamic>? matchedDebtorRecords;
  final String? notes;
  final DateTime? checkedAt;
  final EdBy? checkedBy;

  DebtorCheck({
    this.checked,
    this.matched,
    this.matchedDebtorRecords,
    this.notes,
    this.checkedAt,
    this.checkedBy,
  });

  factory DebtorCheck.fromJson(String str) =>
      DebtorCheck.fromMap(json.decode(str));

  String toJson() => json.encode(toMap());

  factory DebtorCheck.fromMap(Map<String, dynamic> json) => DebtorCheck(
        checked: json["checked"],
        matched: json["matched"],
        matchedDebtorRecords: json["matched_debtor_records"] == null
            ? []
            : List<dynamic>.from(json["matched_debtor_records"]!.map((x) => x)),
        notes: json["notes"],
        checkedAt: json["checked_at"] == null
            ? null
            : DateTime.parse(json["checked_at"]),
        checkedBy: json["checked_by"] is Map
            ? EdBy.fromMap(Map<String, dynamic>.from(json["checked_by"]))
            : null,
      );

  Map<String, dynamic> toMap() => {
        "checked": checked,
        "matched": matched,
        "matched_debtor_records": matchedDebtorRecords == null
            ? []
            : List<dynamic>.from(matchedDebtorRecords!.map((x) => x)),
        "notes": notes,
        "checked_at": checkedAt?.toIso8601String(),
        "checked_by": checkedBy?.toMap(),
      };
}

class StatusUpdate {
  final String? status;
  final String? note;
  final EdBy? createdBy;
  final DateTime? createdAt;
  final String? id;

  StatusUpdate({this.status, this.note, this.createdBy, this.createdAt, this.id});

  factory StatusUpdate.fromJson(String str) =>
      StatusUpdate.fromMap(json.decode(str));

  String toJson() => json.encode(toMap());

  factory StatusUpdate.fromMap(Map<String, dynamic> json) => StatusUpdate(
        status: json["status"],
        note: json["note"],
        createdBy: json["created_by"] is Map
            ? EdBy.fromMap(Map<String, dynamic>.from(json["created_by"]))
            : null,
        createdAt: json["created_at"] == null
            ? null
            : DateTime.parse(json["created_at"]),
        id: json["_id"],
      );

  Map<String, dynamic> toMap() => {
        "status": status,
        "note": note,
        "created_by": createdBy?.toMap(),
        "created_at": createdAt?.toIso8601String(),
        "_id": id,
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

