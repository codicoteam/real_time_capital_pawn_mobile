import 'dart:convert';

class LoanApplicationModel {
  final String? id;
  final String? applicationNo;
  final CustomerUser? customerUser;
  final String? fullName;
  final String? nationalIdNumber;
  final String? gender;
  final DateTime? dateOfBirth;
  final String? maritalStatus;
  final String? contactDetails;
  final String? alternativeNumber;
  final String? emailAddress;
  final String? homeAddress;

  // New document URL fields
  final String? nationalIdUrl;
  final String? passportUrl;
  final String? proofOfResidentUrl;
  final String? proofOfEmploymentUrl;

  // Next of kin
  final NextOfKin? nextOfKin;

  // Employment details
  final Employment? employment;

  // Basic information
  final int? requestedLoanAmount;
  final String? collateralCategory;
  final String? collateralDescription;
  final String? suretyDescription;
  final int? declaredAssetValue;

  // Collateral-specific details
  final SmallLoanDetails? smallLoanDetails;
  final MotorVehicleDetails? motorVehicleDetails;
  final JewelleryDetails? jewelleryDetails;

  // Declaration
  final String? declarationText;
  final DateTime? declarationSignedAt;
  final String? declarationSignatureName;

  // Workflow
  final String? status;
  final DebtorCheck? debtorCheck;
  final List<Attachment>? attachments;
  final String? internalNotes;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final int? v;

  LoanApplicationModel({
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
    this.motorVehicleDetails,
    this.jewelleryDetails,
    this.declarationText,
    this.declarationSignedAt,
    this.declarationSignatureName,
    this.status,
    this.debtorCheck,
    this.attachments,
    this.internalNotes,
    this.createdAt,
    this.updatedAt,
    this.v,
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

        // New document URL fields
        nationalIdUrl: json["national_id_url"],
        passportUrl: json["passport_url"],
        proofOfResidentUrl: json["proof_of_resident_url"],
        proofOfEmploymentUrl: json["proof_of_employment_url"],

        // Next of kin
        nextOfKin: json["next_of_kin"] == null
            ? null
            : NextOfKin.fromMap(json["next_of_kin"]),

        // Employment
        employment: json["employment"] == null
            ? null
            : Employment.fromMap(json["employment"]),

        // Basic information
        requestedLoanAmount: json["requested_loan_amount"],
        collateralCategory: json["collateral_category"],
        collateralDescription: json["collateral_description"],
        suretyDescription: json["surety_description"],
        declaredAssetValue: json["declared_asset_value"],

        // Collateral-specific details
        smallLoanDetails: json["small_loan_details"] == null
            ? null
            : SmallLoanDetails.fromMap(json["small_loan_details"]),
        motorVehicleDetails: json["motor_vehicle_details"] == null
            ? null
            : MotorVehicleDetails.fromMap(json["motor_vehicle_details"]),
        jewelleryDetails: json["jewellery_details"] == null
            ? null
            : JewelleryDetails.fromMap(json["jewellery_details"]),

        // Declaration
        declarationText: json["declaration_text"],
        declarationSignedAt: json["declaration_signed_at"] == null
            ? null
            : DateTime.parse(json["declaration_signed_at"]),
        declarationSignatureName: json["declaration_signature_name"],

        // Workflow
        status: json["status"],
        debtorCheck: json["debtor_check"] == null
            ? null
            : DebtorCheck.fromMap(json["debtor_check"]),
        attachments: json["attachments"] == null
            ? []
            : List<Attachment>.from(
                json["attachments"]!.map((x) => Attachment.fromMap(x)),
              ),
        internalNotes: json["internal_notes"],
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
    "application_no": applicationNo,
    "customer_user": customerUser?.toMap(),
    "full_name": fullName,
    "national_id_number": nationalIdNumber,
    "gender": gender,
    "date_of_birth": dateOfBirth?.toIso8601String(),
    "marital_status": maritalStatus,
    "contact_details": contactDetails,
    "alternative_number": alternativeNumber,
    "email_address": emailAddress,
    "home_address": homeAddress,

    // New document URL fields
    "national_id_url": nationalIdUrl,
    "passport_url": passportUrl,
    "proof_of_resident_url": proofOfResidentUrl,
    "proof_of_employment_url": proofOfEmploymentUrl,

    // Next of kin
    "next_of_kin": nextOfKin?.toMap(),

    // Employment
    "employment": employment?.toMap(),

    // Basic information
    "requested_loan_amount": requestedLoanAmount,
    "collateral_category": collateralCategory,
    "collateral_description": collateralDescription,
    "surety_description": suretyDescription,
    "declared_asset_value": declaredAssetValue,

    // Collateral-specific details
    "small_loan_details": smallLoanDetails?.toMap(),
    "motor_vehicle_details": motorVehicleDetails?.toMap(),
    "jewellery_details": jewelleryDetails?.toMap(),

    // Declaration
    "declaration_text": declarationText,
    "declaration_signed_at": declarationSignedAt?.toIso8601String(),
    "declaration_signature_name": declarationSignatureName,

    // Workflow
    "status": status,
    "debtor_check": debtorCheck?.toMap(),
    "attachments": attachments == null
        ? []
        : List<dynamic>.from(attachments!.map((x) => x.toMap())),
    "internal_notes": internalNotes,
    "created_at": createdAt?.toIso8601String(),
    "updated_at": updatedAt?.toIso8601String(),
    "__v": v,
  };
}

// New NextOfKin class
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

// New SmallLoanDetails class
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

// New MotorVehicleDetails class
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

// New JewelleryDetails class
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

// Existing classes (Attachment, CustomerUser, DebtorCheck, Employment) remain the same
class Attachment {
  final String? id;
  final String? category;
  final String? filename;
  final String? mimeType;
  final String? storage;
  final String? url;
  final bool? signed;
  final DateTime? createdAt;

  Attachment({
    this.id,
    this.category,
    this.filename,
    this.mimeType,
    this.storage,
    this.url,
    this.signed,
    this.createdAt,
  });

  factory Attachment.fromJson(String str) =>
      Attachment.fromMap(json.decode(str));

  String toJson() => json.encode(toMap());

  factory Attachment.fromMap(Map<String, dynamic> json) => Attachment(
    id: json["_id"],
    category: json["category"],
    filename: json["filename"],
    mimeType: json["mime_type"],
    storage: json["storage"],
    url: json["url"],
    signed: json["signed"],
    createdAt: json["created_at"] == null
        ? null
        : DateTime.parse(json["created_at"]),
  );

  Map<String, dynamic> toMap() => {
    "_id": id,
    "category": category,
    "filename": filename,
    "mime_type": mimeType,
    "storage": storage,
    "url": url,
    "signed": signed,
    "created_at": createdAt?.toIso8601String(),
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

class DebtorCheck {
  final bool? checked;
  final bool? matched;
  final List<dynamic>? matchedDebtorRecords;
  final String? notes;
  final DateTime? checkedAt;
  final CustomerUser? checkedBy;

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
    checkedBy: json["checked_by"] == null
        ? null
        : CustomerUser.fromMap(json["checked_by"]),
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
