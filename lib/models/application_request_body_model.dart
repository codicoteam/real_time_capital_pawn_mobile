import 'dart:convert';

class LoanApplicationBodyModel {
  final double? requestedLoanAmount;
  final String? collateralCategory;
  final String? collateralDescription;
  final String? suretyDescription;
  final double? declaredAssetValue;

  // Loan period type — drives interest & storage rates on the backend
  // Must be one of: "two_weeks" or "one_month"
  final String? loanPeriodType;

  // Collateral details (only one will be populated based on collateralCategory)
  final SmallLoanDetails? smallLoanDetails;
  final MotorVehicleDetails? motorVehicleDetails;
  final JewelleryDetails? jewelleryDetails;

  // Collateral images
  final List<String>? collateralImages;

  // Declaration
  final String? declarationText;
  final DateTime? declarationSignedAt;
  final String? declarationSignatureName;

  // Custom terms
  final String? customTermsAndConditions;

  LoanApplicationBodyModel({
    this.requestedLoanAmount,
    this.collateralCategory,
    this.collateralDescription,
    this.suretyDescription,
    this.declaredAssetValue,
    this.loanPeriodType,
    this.smallLoanDetails,
    this.motorVehicleDetails,
    this.jewelleryDetails,
    this.collateralImages,
    this.declarationText,
    this.declarationSignedAt,
    this.declarationSignatureName,
    this.customTermsAndConditions,
  });

  factory LoanApplicationBodyModel.fromJson(String str) =>
      LoanApplicationBodyModel.fromMap(json.decode(str));

  String toJson() => json.encode(toMap());

  factory LoanApplicationBodyModel.fromMap(Map<String, dynamic> json) =>
      LoanApplicationBodyModel(
        requestedLoanAmount: json["requested_loan_amount"]?.toDouble(),
        collateralCategory: json["collateral_category"],
        collateralDescription: json["collateral_description"],
        suretyDescription: json["surety_description"],
        declaredAssetValue: json["declared_asset_value"]?.toDouble(),
        loanPeriodType: json["loan_period_type"],
        smallLoanDetails: json["small_loan_details"] == null
            ? null
            : SmallLoanDetails.fromMap(json["small_loan_details"]),
        motorVehicleDetails: json["motor_vehicle_details"] == null
            ? null
            : MotorVehicleDetails.fromMap(json["motor_vehicle_details"]),
        jewelleryDetails: json["jewellery_details"] == null
            ? null
            : JewelleryDetails.fromMap(json["jewellery_details"]),
        collateralImages: json["collateral_images"] == null
            ? []
            : List<String>.from(json["collateral_images"]!.map((x) => x)),
        declarationText: json["declaration_text"],
        declarationSignedAt: json["declaration_signed_at"] == null
            ? null
            : DateTime.parse(json["declaration_signed_at"]),
        declarationSignatureName: json["declaration_signature_name"],
        customTermsAndConditions: json["custom_terms_and_conditions"],
      );

  Map<String, dynamic> toMap() {
    final map = <String, dynamic>{};

    if (requestedLoanAmount != null)
      map["requested_loan_amount"] = requestedLoanAmount;
    if (collateralCategory != null)
      map["collateral_category"] = collateralCategory;
    if (collateralDescription != null)
      map["collateral_description"] = collateralDescription;
    if (suretyDescription != null) map["surety_description"] = suretyDescription;
    if (declaredAssetValue != null)
      map["declared_asset_value"] = declaredAssetValue;
    if (loanPeriodType != null) map["loan_period_type"] = loanPeriodType;
    if (smallLoanDetails != null)
      map["small_loan_details"] = smallLoanDetails!.toMap();
    if (motorVehicleDetails != null)
      map["motor_vehicle_details"] = motorVehicleDetails!.toMap();
    if (jewelleryDetails != null)
      map["jewellery_details"] = jewelleryDetails!.toMap();
    if (collateralImages != null && collateralImages!.isNotEmpty)
      map["collateral_images"] = collateralImages;
    if (declarationText != null) map["declaration_text"] = declarationText;
    if (declarationSignedAt != null)
      map["declaration_signed_at"] = declarationSignedAt!.toIso8601String();
    if (declarationSignatureName != null)
      map["declaration_signature_name"] = declarationSignatureName;
    if (customTermsAndConditions != null)
      map["custom_terms_and_conditions"] = customTermsAndConditions;

    return map;
  }

  bool isValid() {
    if (requestedLoanAmount == null || requestedLoanAmount! <= 0) return false;
    if (collateralCategory == null || collateralCategory!.isEmpty) return false;
    if (loanPeriodType == null || loanPeriodType!.isEmpty) return false;
    if (collateralCategory == "small_loans" && smallLoanDetails == null)
      return false;
    if (collateralCategory == "motor_vehicle" && motorVehicleDetails == null)
      return false;
    if (collateralCategory == "jewellery" && jewelleryDetails == null)
      return false;
    return true;
  }
}

class SmallLoanDetails {
  final String? type;
  final String? model;
  final String? serialNo;

  SmallLoanDetails({this.type, this.model, this.serialNo});

  factory SmallLoanDetails.fromJson(String str) =>
      SmallLoanDetails.fromMap(json.decode(str));

  String toJson() => json.encode(toMap());

  factory SmallLoanDetails.fromMap(Map<String, dynamic> json) => SmallLoanDetails(
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

class JewelleryDetails {
  final String? type;
  final String? description;
  final double? weight;
  final String? purity;
  final double? estimatedValue;

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

  factory JewelleryDetails.fromMap(Map<String, dynamic> json) => JewelleryDetails(
        type: json["type"],
        description: json["description"],
        weight: json["weight"]?.toDouble(),
        purity: json["purity"],
        estimatedValue: json["estimated_value"]?.toDouble(),
      );

  Map<String, dynamic> toMap() => {
        "type": type,
        "description": description,
        "weight": weight,
        "purity": purity,
        "estimated_value": estimatedValue,
      };
}

enum CollateralCategory {
  smallLoans,
  motorVehicle,
  jewellery;

  String get value {
    switch (this) {
      case CollateralCategory.smallLoans:
        return "small_loans";
      case CollateralCategory.motorVehicle:
        return "motor_vehicle";
      case CollateralCategory.jewellery:
        return "jewellery";
    }
  }

  static CollateralCategory fromValue(String value) {
    switch (value) {
      case "small_loans":
        return CollateralCategory.smallLoans;
      case "motor_vehicle":
        return CollateralCategory.motorVehicle;
      case "jewellery":
        return CollateralCategory.jewellery;
      default:
        return CollateralCategory.smallLoans;
    }
  }
}

// Loan period type — maps to backend LOAN_PERIODS config
enum LoanPeriodType {
  twoWeeks,
  oneMonth;

  String get value {
    switch (this) {
      case LoanPeriodType.twoWeeks:
        return "two_weeks";
      case LoanPeriodType.oneMonth:
        return "one_month";
    }
  }

  String get label {
    switch (this) {
      case LoanPeriodType.twoWeeks:
        return "2 Weeks";
      case LoanPeriodType.oneMonth:
        return "1 Month";
    }
  }

  static LoanPeriodType fromValue(String value) {
    switch (value) {
      case "two_weeks":
        return LoanPeriodType.twoWeeks;
      case "one_month":
        return LoanPeriodType.oneMonth;
      default:
        return LoanPeriodType.oneMonth;
    }
  }
}
