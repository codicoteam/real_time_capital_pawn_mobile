import 'dart:convert';

class LoanModel {
  final String? id;
  final String? loanNo;
  final CustomerUser? customerUser;
  final Application? application;
  final Asset? asset;
  final String? collateralCategory;
  final int? principalAmount;
  final int? currentBalance;
  final String? currency;
  final double? interestRatePercent;
  final double? interestPeriodDays;
  final double? storageChargePercent;
  final int? penaltyPercent;
  final int? graceDays;
  final DateTime? startDate;
  final DateTime? dueDate;
  final String? status;
  final List<dynamic>? attachments;
  final String? createdBy;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final int? v;
  final String? approvedBy;
  final DateTime? disbursedAt;
  final String? processedBy;

  LoanModel({
    this.id,
    this.loanNo,
    this.customerUser,
    this.application,
    this.asset,
    this.collateralCategory,
    this.principalAmount,
    this.currentBalance,
    this.currency,
    this.interestRatePercent,
    this.interestPeriodDays,
    this.storageChargePercent,
    this.penaltyPercent,
    this.graceDays,
    this.startDate,
    this.dueDate,
    this.status,
    this.attachments,
    this.createdBy,
    this.createdAt,
    this.updatedAt,
    this.v,
    this.approvedBy,
    this.disbursedAt,
    this.processedBy,
  });

  factory LoanModel.fromJson(String str) => LoanModel.fromMap(json.decode(str));

  String toJson() => json.encode(toMap());

  factory LoanModel.fromMap(Map<String, dynamic> json) => LoanModel(
    id: json["_id"],
    loanNo: json["loan_no"],
    customerUser: json["customer_user"] == null
        ? null
        : CustomerUser.fromMap(json["customer_user"]),
    application: json["application"] == null
        ? null
        : Application.fromMap(json["application"]),
    asset: json["asset"] == null ? null : Asset.fromMap(json["asset"]),
    collateralCategory: json["collateral_category"],
    principalAmount: json["principal_amount"],
    currentBalance: json["current_balance"],
    currency: json["currency"],
    interestRatePercent: json["interest_rate_percent"]?.toDouble(),
    interestPeriodDays: json["interest_period_days"]?.toDouble(),
    storageChargePercent: json["storage_charge_percent"]?.toDouble(),
    penaltyPercent: json["penalty_percent"],
    graceDays: json["grace_days"],
    startDate: json["start_date"] == null
        ? null
        : DateTime.parse(json["start_date"]),
    dueDate: json["due_date"] == null ? null : DateTime.parse(json["due_date"]),
    status: json["status"],
    attachments: json["attachments"] == null
        ? []
        : List<dynamic>.from(json["attachments"]!.map((x) => x)),
    createdBy: json["created_by"],
    createdAt: json["created_at"] == null
        ? null
        : DateTime.parse(json["created_at"]),
    updatedAt: json["updated_at"] == null
        ? null
        : DateTime.parse(json["updated_at"]),
    v: json["__v"],
    approvedBy: json["approved_by"],
    disbursedAt: json["disbursed_at"] == null
        ? null
        : DateTime.parse(json["disbursed_at"]),
    processedBy: json["processed_by"],
  );

  Map<String, dynamic> toMap() => {
    "_id": id,
    "loan_no": loanNo,
    "customer_user": customerUser?.toMap(),
    "application": application?.toMap(),
    "asset": asset?.toMap(),
    "collateral_category": collateralCategory,
    "principal_amount": principalAmount,
    "current_balance": currentBalance,
    "currency": currency,
    "interest_rate_percent": interestRatePercent,
    "interest_period_days": interestPeriodDays,
    "storage_charge_percent": storageChargePercent,
    "penalty_percent": penaltyPercent,
    "grace_days": graceDays,
    "start_date": startDate?.toIso8601String(),
    "due_date": dueDate?.toIso8601String(),
    "status": status,
    "attachments": attachments == null
        ? []
        : List<dynamic>.from(attachments!.map((x) => x)),
    "created_by": createdBy,
    "created_at": createdAt?.toIso8601String(),
    "updated_at": updatedAt?.toIso8601String(),
    "__v": v,
    "approved_by": approvedBy,
    "disbursed_at": disbursedAt?.toIso8601String(),
    "processed_by": processedBy,
  };
}

class Application {
  final String? id;
  final String? applicationNo;
  final String? customerUser;
  final String? fullName;
  final String? nationalIdNumber;
  final String? gender;
  final DateTime? dateOfBirth;
  final String? maritalStatus;
  final String? contactDetails;
  final String? alternativeNumber;
  final String? emailAddress;
  final String? homeAddress;
  final String? nationalIdUrl;
  final String? passportUrl;
  final String? proofOfResidentUrl;
  final String? proofOfEmploymentUrl;
  final NextOfKin? nextOfKin;
  final Employment? employment;
  final int? requestedLoanAmount;
  final String? collateralCategory;
  final String? collateralDescription;
  final String? suretyDescription;
  final int? declaredAssetValue;
  final SmallLoanDetails? smallLoanDetails;
  final String? declarationText;
  final DateTime? declarationSignedAt;
  final String? declarationSignatureName;
  final String? status;
  final DebtorCheck? debtorCheck;
  final List<dynamic>? attachments;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final int? v;
  final JewelleryDetails? jewelleryDetails;
  final MotorVehicleDetails? motorVehicleDetails;
  final String? internalNotes;

  Application({
    this.id,
    this.applicationNo,
    this.customerUser,
    this.fullName,
    this.nationalIdNumber,
    this.gender,
    this.dateOfBirth,
    this.maritalStatus,
    this.contactDetails,
    this.alternativeNumber,
    this.emailAddress,
    this.homeAddress,
    this.nationalIdUrl,
    this.passportUrl,
    this.proofOfResidentUrl,
    this.proofOfEmploymentUrl,
    this.nextOfKin,
    this.employment,
    this.requestedLoanAmount,
    this.collateralCategory,
    this.collateralDescription,
    this.suretyDescription,
    this.declaredAssetValue,
    this.smallLoanDetails,
    this.declarationText,
    this.declarationSignedAt,
    this.declarationSignatureName,
    this.status,
    this.debtorCheck,
    this.attachments,
    this.createdAt,
    this.updatedAt,
    this.v,
    this.jewelleryDetails,
    this.motorVehicleDetails,
    this.internalNotes,
  });

  factory Application.fromJson(String str) =>
      Application.fromMap(json.decode(str));

  String toJson() => json.encode(toMap());

  factory Application.fromMap(Map<String, dynamic> json) => Application(
    id: json["_id"],
    applicationNo: json["application_no"],
    customerUser: json["customer_user"],
    fullName: json["full_name"],
    nationalIdNumber: json["national_id_number"],
    gender: json["gender"],
    dateOfBirth: json["date_of_birth"] == null
        ? null
        : DateTime.parse(json["date_of_birth"]),
    maritalStatus: json["marital_status"],
    contactDetails: json["contact_details"],
    alternativeNumber: json["alternative_number"],
    emailAddress: json["email_address"],
    homeAddress: json["home_address"],
    nationalIdUrl: json["national_id_url"],
    passportUrl: json["passport_url"],
    proofOfResidentUrl: json["proof_of_resident_url"],
    proofOfEmploymentUrl: json["proof_of_employment_url"],
    nextOfKin: json["next_of_kin"] == null
        ? null
        : NextOfKin.fromMap(json["next_of_kin"]),
    employment: json["employment"] == null
        ? null
        : Employment.fromMap(json["employment"]),
    requestedLoanAmount: json["requested_loan_amount"],
    collateralCategory: json["collateral_category"],
    collateralDescription: json["collateral_description"],
    suretyDescription: json["surety_description"],
    declaredAssetValue: json["declared_asset_value"],
    smallLoanDetails: json["small_loan_details"] == null
        ? null
        : SmallLoanDetails.fromMap(json["small_loan_details"]),
    declarationText: json["declaration_text"],
    declarationSignedAt: json["declaration_signed_at"] == null
        ? null
        : DateTime.parse(json["declaration_signed_at"]),
    declarationSignatureName: json["declaration_signature_name"],
    status: json["status"],
    debtorCheck: json["debtor_check"] == null
        ? null
        : DebtorCheck.fromMap(json["debtor_check"]),
    attachments: json["attachments"] == null
        ? []
        : List<dynamic>.from(json["attachments"]!.map((x) => x)),
    createdAt: json["created_at"] == null
        ? null
        : DateTime.parse(json["created_at"]),
    updatedAt: json["updated_at"] == null
        ? null
        : DateTime.parse(json["updated_at"]),
    v: json["__v"],
    jewelleryDetails: json["jewellery_details"] == null
        ? null
        : JewelleryDetails.fromMap(json["jewellery_details"]),
    motorVehicleDetails: json["motor_vehicle_details"] == null
        ? null
        : MotorVehicleDetails.fromMap(json["motor_vehicle_details"]),
    internalNotes: json["internal_notes"],
  );

  Map<String, dynamic> toMap() => {
    "_id": id,
    "application_no": applicationNo,
    "customer_user": customerUser,
    "full_name": fullName,
    "national_id_number": nationalIdNumber,
    "gender": gender,
    "date_of_birth": dateOfBirth?.toIso8601String(),
    "marital_status": maritalStatus,
    "contact_details": contactDetails,
    "alternative_number": alternativeNumber,
    "email_address": emailAddress,
    "home_address": homeAddress,
    "national_id_url": nationalIdUrl,
    "passport_url": passportUrl,
    "proof_of_resident_url": proofOfResidentUrl,
    "proof_of_employment_url": proofOfEmploymentUrl,
    "next_of_kin": nextOfKin?.toMap(),
    "employment": employment?.toMap(),
    "requested_loan_amount": requestedLoanAmount,
    "collateral_category": collateralCategory,
    "collateral_description": collateralDescription,
    "surety_description": suretyDescription,
    "declared_asset_value": declaredAssetValue,
    "small_loan_details": smallLoanDetails?.toMap(),
    "declaration_text": declarationText,
    "declaration_signed_at": declarationSignedAt?.toIso8601String(),
    "declaration_signature_name": declarationSignatureName,
    "status": status,
    "debtor_check": debtorCheck?.toMap(),
    "attachments": attachments == null
        ? []
        : List<dynamic>.from(attachments!.map((x) => x)),
    "created_at": createdAt?.toIso8601String(),
    "updated_at": updatedAt?.toIso8601String(),
    "__v": v,
    "jewellery_details": jewelleryDetails?.toMap(),
    "motor_vehicle_details": motorVehicleDetails?.toMap(),
    "internal_notes": internalNotes,
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

class Employment {
  final String? employmentType;
  final String? title;
  final String? duration;
  final String? location;
  final String? contacts;

  Employment({
    this.employmentType,
    this.title,
    this.duration,
    this.location,
    this.contacts,
  });

  factory Employment.fromJson(String str) =>
      Employment.fromMap(json.decode(str));

  String toJson() => json.encode(toMap());

  factory Employment.fromMap(Map<String, dynamic> json) => Employment(
    employmentType: json["employment_type"],
    title: json["title"],
    duration: json["duration"],
    location: json["location"],
    contacts: json["contacts"],
  );

  Map<String, dynamic> toMap() => {
    "employment_type": employmentType,
    "title": title,
    "duration": duration,
    "location": location,
    "contacts": contacts,
  };
}

class JewelleryDetails {
  final String? type;
  final String? description;
  final double? weight;
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
        weight: json["weight"]?.toDouble(),
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

class NextOfKin {
  final String? fullName;
  final String? relationship;
  final String? phoneNumber;
  final String? email;
  final String? address;

  NextOfKin({
    this.fullName,
    this.relationship,
    this.phoneNumber,
    this.email,
    this.address,
  });

  factory NextOfKin.fromJson(String str) => NextOfKin.fromMap(json.decode(str));

  String toJson() => json.encode(toMap());

  factory NextOfKin.fromMap(Map<String, dynamic> json) => NextOfKin(
    fullName: json["full_name"],
    relationship: json["relationship"],
    phoneNumber: json["phone_number"],
    email: json["email"],
    address: json["address"],
  );

  Map<String, dynamic> toMap() => {
    "full_name": fullName,
    "relationship": relationship,
    "phone_number": phoneNumber,
    "email": email,
    "address": address,
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

class Asset {
  final String? id;
  final String? assetNo;
  final String? category;
  final String? title;
  final String? assetType;

  Asset({this.id, this.assetNo, this.category, this.title, this.assetType});

  factory Asset.fromJson(String str) => Asset.fromMap(json.decode(str));

  String toJson() => json.encode(toMap());

  factory Asset.fromMap(Map<String, dynamic> json) => Asset(
    id: json["_id"],
    assetNo: json["asset_no"],
    category: json["category"],
    title: json["title"],
    assetType: json["asset_type"],
  );

  Map<String, dynamic> toMap() => {
    "_id": id,
    "asset_no": assetNo,
    "category": category,
    "title": title,
    "asset_type": assetType,
  };
}

class CustomerUser {
  final String? id;
  final String? email;
  final String? phone;
  final String? firstName;
  final String? lastName;

  CustomerUser({
    this.id,
    this.email,
    this.phone,
    this.firstName,
    this.lastName,
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
  );

  Map<String, dynamic> toMap() => {
    "_id": id,
    "email": email,
    "phone": phone,
    "first_name": firstName,
    "last_name": lastName,
  };
}
