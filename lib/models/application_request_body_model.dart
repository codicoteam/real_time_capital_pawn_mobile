import 'dart:convert';

class LoanApplicationBodyModel {
  final double? requestedLoanAmount;
  final String? collateralCategory;
  final String? collateralDescription;
  final String? suretyDescription;
  final double? declaredAssetValue;
  
  // Collateral details (only one will be used based on collateralCategory)
  final SmallLoanDetails? smallLoanDetails;
  final MotorVehicleDetails? motorVehicleDetails;
  final JewelleryDetails? jewelleryDetails;
  
  // Collateral images
  final List<String>? collateralImages;
  
  // Repayment preferences
  final String? repaymentType; // "once_off" or "installment"
  final int? repaymentDays; // Required for both types
  
  // Installment specific fields (only if repaymentType == "installment")
  final int? installmentCount;
  final String? installmentFrequency; // "weekly", "biweekly", "monthly", "quarterly"
  final double? installmentAmount;
  
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
    this.smallLoanDetails,
    this.motorVehicleDetails,
    this.jewelleryDetails,
    this.collateralImages,
    this.repaymentType,
    this.repaymentDays,
    this.installmentCount,
    this.installmentFrequency,
    this.installmentAmount,
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
        repaymentType: json["repayment_type"],
        repaymentDays: json["repayment_days"],
        installmentCount: json["installment_count"],
        installmentFrequency: json["installment_frequency"],
        installmentAmount: json["installment_amount"]?.toDouble(),
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
    if (suretyDescription != null) 
      map["surety_description"] = suretyDescription;
    if (declaredAssetValue != null) 
      map["declared_asset_value"] = declaredAssetValue;
    if (smallLoanDetails != null) 
      map["small_loan_details"] = smallLoanDetails!.toMap();
    if (motorVehicleDetails != null) 
      map["motor_vehicle_details"] = motorVehicleDetails!.toMap();
    if (jewelleryDetails != null) 
      map["jewellery_details"] = jewelleryDetails!.toMap();
    if (collateralImages != null && collateralImages!.isNotEmpty) 
      map["collateral_images"] = collateralImages;
    if (repaymentType != null) 
      map["repayment_type"] = repaymentType;
    if (repaymentDays != null) 
      map["repayment_days"] = repaymentDays;
    if (installmentCount != null) 
      map["installment_count"] = installmentCount;
    if (installmentFrequency != null) 
      map["installment_frequency"] = installmentFrequency;
    if (installmentAmount != null) 
      map["installment_amount"] = installmentAmount;
    if (declarationText != null) 
      map["declaration_text"] = declarationText;
    if (declarationSignedAt != null) 
      map["declaration_signed_at"] = declarationSignedAt!.toIso8601String();
    if (declarationSignatureName != null) 
      map["declaration_signature_name"] = declarationSignatureName;
    if (customTermsAndConditions != null) 
      map["custom_terms_and_conditions"] = customTermsAndConditions;
    
    return map;
  }

  // Helper method to validate if all required fields are present
  bool isValid() {
    // Required fields for all applications
    if (requestedLoanAmount == null || requestedLoanAmount! <= 0) return false;
    if (collateralCategory == null || collateralCategory!.isEmpty) return false;
    if (collateralCategory == "small_loans" && smallLoanDetails == null) return false;
    if (collateralCategory == "motor_vehicle" && motorVehicleDetails == null) return false;
    if (collateralCategory == "jewellery" && jewelleryDetails == null) return false;
    
    // Repayment validation
    if (repaymentType == null) return false;
    if (repaymentDays == null || repaymentDays! <= 0) return false;
    
    if (repaymentType == "installment") {
      if (installmentCount == null || installmentCount! < 1) return false;
      if (installmentFrequency == null) return false;
      if (installmentAmount == null || installmentAmount! <= 0) return false;
    }
    
    return true;
  }
}

// Small Loan Collateral Details
class SmallLoanDetails {
  final String? type;
  final String? model;
  final String? serialNo;

  SmallLoanDetails({
    this.type,
    this.model,
    this.serialNo,
  });

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

// Motor Vehicle Collateral Details
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

  factory MotorVehicleDetails.fromMap(Map<String, dynamic> json) => MotorVehicleDetails(
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

// Jewellery Collateral Details
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

// Enum for Collateral Category
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

// Enum for Repayment Type
enum RepaymentType {
  onceOff,
  installment;

  String get value {
    switch (this) {
      case RepaymentType.onceOff:
        return "once_off";
      case RepaymentType.installment:
        return "installment";
    }
  }

  static RepaymentType fromValue(String value) {
    switch (value) {
      case "once_off":
        return RepaymentType.onceOff;
      case "installment":
        return RepaymentType.installment;
      default:
        return RepaymentType.onceOff;
    }
  }
}

// Enum for Installment Frequency
enum InstallmentFrequency {
  weekly,
  biweekly,
  monthly,
  quarterly;

  String get value {
    switch (this) {
      case InstallmentFrequency.weekly:
        return "weekly";
      case InstallmentFrequency.biweekly:
        return "biweekly";
      case InstallmentFrequency.monthly:
        return "monthly";
      case InstallmentFrequency.quarterly:
        return "quarterly";
    }
  }

  static InstallmentFrequency fromValue(String value) {
    switch (value) {
      case "weekly":
        return InstallmentFrequency.weekly;
      case "biweekly":
        return InstallmentFrequency.biweekly;
      case "monthly":
        return InstallmentFrequency.monthly;
      case "quarterly":
        return InstallmentFrequency.quarterly;
      default:
        return InstallmentFrequency.monthly;
    }
  }
}
