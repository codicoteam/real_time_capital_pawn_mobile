import 'dart:convert';

class LoanModel {
  final String? id;
  final String? loanNo;
  final CustomerUser? customerUser;
  final Application? application;
  final Asset? asset;
  final String? collateralCategory;
  final double? principalAmount;
  final double? currentBalance;
  final String? currency;
  final String? loanPeriodType;
  final double? interestRatePercent;
  final int? interestPeriodDays;
  final double? storageChargePercent;
  final double? penaltyPercent;
  final int? graceDays;
  final double? interestAmount;
  final double? storageChargeAmount;
  final double? expectedTotalRepayable;
  final Map<String, dynamic>? repaymentBreakdown;
  final String? repaymentType;
  // Disbursement details
  final DateTime? disbursementDate;
  final String? paymentMethod;
  final String? disbursementReference;
  final String? disbursedBy;
  final String? disbursementNotes;
  final DateTime? startDate;
  final DateTime? dueDate;
  final double? totalPaid;
  final String? status;
  final bool? requiresSuperAdminApproval;
  final String? approvalStatus;
  final String? createdBy;
  final String? approvedBy;
  final String? processedBy;
  final List<Payment>? payments;
  final List<RequestedSuperAdmin>? requestedSuperAdmins;
  final List<SuperAdminApproval>? superAdminApprovals;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final int? v;

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
    this.loanPeriodType,
    this.interestRatePercent,
    this.interestPeriodDays,
    this.storageChargePercent,
    this.penaltyPercent,
    this.graceDays,
    this.interestAmount,
    this.storageChargeAmount,
    this.expectedTotalRepayable,
    this.repaymentBreakdown,
    this.repaymentType,
    this.disbursementDate,
    this.paymentMethod,
    this.disbursementReference,
    this.disbursedBy,
    this.disbursementNotes,
    this.startDate,
    this.dueDate,
    this.totalPaid,
    this.status,
    this.requiresSuperAdminApproval,
    this.approvalStatus,
    this.createdBy,
    this.approvedBy,
    this.processedBy,
    this.payments,
    this.requestedSuperAdmins,
    this.superAdminApprovals,
    this.createdAt,
    this.updatedAt,
    this.v,
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
        principalAmount: json["principal_amount"]?.toDouble(),
        currentBalance: json["current_balance"]?.toDouble(),
        currency: json["currency"],
        loanPeriodType: json["loan_period_type"],
        interestRatePercent: json["interest_rate_percent"]?.toDouble(),
        interestPeriodDays: json["interest_period_days"],
        storageChargePercent: json["storage_charge_percent"]?.toDouble(),
        penaltyPercent: json["penalty_percent"]?.toDouble(),
        graceDays: json["grace_days"],
        interestAmount: json["interest_amount"]?.toDouble(),
        storageChargeAmount: json["storage_charge_amount"]?.toDouble(),
        expectedTotalRepayable: json["expected_total_repayable"]?.toDouble(),
        repaymentBreakdown: json["repayment_breakdown"] is Map
            ? Map<String, dynamic>.from(json["repayment_breakdown"])
            : null,
        repaymentType: json["repayment_type"],
        disbursementDate: json["disbursement_date"] == null
            ? null
            : DateTime.parse(json["disbursement_date"]),
        paymentMethod: json["payment_method"],
        disbursementReference: json["disbursement_reference"],
        disbursedBy: json["disbursed_by"] is String
            ? json["disbursed_by"]
            : json["disbursed_by"]?["_id"],
        disbursementNotes: json["disbursement_notes"],
        startDate: json["start_date"] == null
            ? null
            : DateTime.parse(json["start_date"]),
        dueDate:
            json["due_date"] == null ? null : DateTime.parse(json["due_date"]),
        totalPaid: json["total_paid"]?.toDouble(),
        status: json["status"],
        requiresSuperAdminApproval: json["requires_super_admin_approval"],
        approvalStatus: json["approval_status"],
        createdBy: json["created_by"] is String
            ? json["created_by"]
            : json["created_by"]?["_id"],
        approvedBy: json["approved_by"] is String
            ? json["approved_by"]
            : json["approved_by"]?["_id"],
        processedBy: json["processed_by"] is String
            ? json["processed_by"]
            : json["processed_by"]?["_id"],
        payments: json["payments"] == null
            ? []
            : List<Payment>.from(
                json["payments"]!.map((x) => Payment.fromMap(x))),
        requestedSuperAdmins: json["requested_super_admins"] == null
            ? []
            : List<RequestedSuperAdmin>.from(
                json["requested_super_admins"]!.map(
                  (x) => RequestedSuperAdmin.fromMap(x),
                ),
              ),
        superAdminApprovals: json["super_admin_approvals"] == null
            ? []
            : List<SuperAdminApproval>.from(
                json["super_admin_approvals"]!.map(
                  (x) => SuperAdminApproval.fromMap(x),
                ),
              ),
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
        "loan_no": loanNo,
        "customer_user": customerUser?.toMap(),
        "application": application?.toMap(),
        "asset": asset?.toMap(),
        "collateral_category": collateralCategory,
        "principal_amount": principalAmount,
        "current_balance": currentBalance,
        "currency": currency,
        "loan_period_type": loanPeriodType,
        "interest_rate_percent": interestRatePercent,
        "interest_period_days": interestPeriodDays,
        "storage_charge_percent": storageChargePercent,
        "penalty_percent": penaltyPercent,
        "grace_days": graceDays,
        "interest_amount": interestAmount,
        "storage_charge_amount": storageChargeAmount,
        "expected_total_repayable": expectedTotalRepayable,
        "repayment_breakdown": repaymentBreakdown,
        "repayment_type": repaymentType,
        "disbursement_date": disbursementDate?.toIso8601String(),
        "payment_method": paymentMethod,
        "disbursement_reference": disbursementReference,
        "disbursed_by": disbursedBy,
        "disbursement_notes": disbursementNotes,
        "start_date": startDate?.toIso8601String(),
        "due_date": dueDate?.toIso8601String(),
        "total_paid": totalPaid,
        "status": status,
        "requires_super_admin_approval": requiresSuperAdminApproval,
        "approval_status": approvalStatus,
        "created_by": createdBy,
        "approved_by": approvedBy,
        "processed_by": processedBy,
        "payments": payments == null
            ? []
            : List<dynamic>.from(payments!.map((x) => x.toMap())),
        "requested_super_admins": requestedSuperAdmins == null
            ? []
            : List<dynamic>.from(requestedSuperAdmins!.map((x) => x.toMap())),
        "super_admin_approvals": superAdminApprovals == null
            ? []
            : List<dynamic>.from(superAdminApprovals!.map((x) => x.toMap())),
        "created_at": createdAt?.toIso8601String(),
        "updated_at": updatedAt?.toIso8601String(),
        "__v": v,
      };
}

class Application {
  final String? id;
  final String? applicationNo;
  final int? requestedLoanAmount;
  final String? collateralCategory;
  final String? collateralDescription;
  final int? declaredAssetValue;
  final String? repaymentType;
  final String? status;

  Application({
    this.id,
    this.applicationNo,
    this.requestedLoanAmount,
    this.collateralCategory,
    this.collateralDescription,
    this.declaredAssetValue,
    this.repaymentType,
    this.status,
  });

  factory Application.fromJson(String str) =>
      Application.fromMap(json.decode(str));

  String toJson() => json.encode(toMap());

  factory Application.fromMap(Map<String, dynamic> json) => Application(
    id: json["_id"],
    applicationNo: json["application_no"],
    requestedLoanAmount: json["requested_loan_amount"],
    collateralCategory: json["collateral_category"],
    collateralDescription: json["collateral_description"],
    declaredAssetValue: json["declared_asset_value"],
    repaymentType: json["repayment_type"],
    status: json["status"],
  );

  Map<String, dynamic> toMap() => {
    "_id": id,
    "application_no": applicationNo,
    "requested_loan_amount": requestedLoanAmount,
    "collateral_category": collateralCategory,
    "collateral_description": collateralDescription,
    "declared_asset_value": declaredAssetValue,
    "repayment_type": repaymentType,
    "status": status,
  };
}

class Asset {
  final String? id;
  final String? assetNo;
  final String? category;
  final String? title;
  final List<String>? assetImages;
  final String? status;
  final int? evaluatedValue;

  Asset({
    this.id,
    this.assetNo,
    this.category,
    this.title,
    this.assetImages,
    this.status,
    this.evaluatedValue,
  });

  factory Asset.fromJson(String str) => Asset.fromMap(json.decode(str));

  String toJson() => json.encode(toMap());

  factory Asset.fromMap(Map<String, dynamic> json) => Asset(
    id: json["_id"],
    assetNo: json["asset_no"],
    category: json["category"],
    title: json["title"],
    assetImages: json["asset_images"] == null
        ? []
        : List<String>.from(json["asset_images"]!.map((x) => x)),
    status: json["status"],
    evaluatedValue: json["evaluated_value"],
  );

  Map<String, dynamic> toMap() => {
    "_id": id,
    "asset_no": assetNo,
    "category": category,
    "title": title,
    "asset_images": assetImages == null
        ? []
        : List<dynamic>.from(assetImages!.map((x) => x)),
    "status": status,
    "evaluated_value": evaluatedValue,
  };
}

class CustomerUser {
  final String? id;
  final String? email;
  final String? phone;
  final String? firstName;
  final String? lastName;
  final String? nationalIdNumber;

  CustomerUser({
    this.id,
    this.email,
    this.phone,
    this.firstName,
    this.lastName,
    this.nationalIdNumber,
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
  );

  Map<String, dynamic> toMap() => {
    "_id": id,
    "email": email,
    "phone": phone,
    "first_name": firstName,
    "last_name": lastName,
    "national_id_number": nationalIdNumber,
  };
}

class Payment {
  final double? amount;
  final DateTime? paymentDate;
  final String? paymentMethod;
  final String? status;
  final String? referenceNo;
  final String? receivedBy;
  final String? notes;
  final String? id;

  Payment({
    this.amount,
    this.paymentDate,
    this.paymentMethod,
    this.status,
    this.referenceNo,
    this.receivedBy,
    this.notes,
    this.id,
  });

  factory Payment.fromJson(String str) => Payment.fromMap(json.decode(str));

  String toJson() => json.encode(toMap());

  factory Payment.fromMap(Map<String, dynamic> json) => Payment(
        amount: json["amount"]?.toDouble(),
        paymentDate: json["payment_date"] == null
            ? null
            : DateTime.parse(json["payment_date"]),
        paymentMethod: json["payment_method"],
        status: json["status"],
        referenceNo: json["reference_no"],
        receivedBy: json["received_by"] is String
            ? json["received_by"]
            : json["received_by"]?["_id"],
        notes: json["notes"],
        id: json["_id"],
      );

  Map<String, dynamic> toMap() => {
        "amount": amount,
        "payment_date": paymentDate?.toIso8601String(),
        "payment_method": paymentMethod,
        "status": status,
        "reference_no": referenceNo,
        "received_by": receivedBy,
        "notes": notes,
        "_id": id,
      };
}

class RequestedSuperAdmin {
  final String? superAdmin;
  final String? status;
  final DateTime? requestedAt;
  final String? id;

  RequestedSuperAdmin({
    this.superAdmin,
    this.status,
    this.requestedAt,
    this.id,
  });

  factory RequestedSuperAdmin.fromJson(String str) =>
      RequestedSuperAdmin.fromMap(json.decode(str));

  String toJson() => json.encode(toMap());

  factory RequestedSuperAdmin.fromMap(Map<String, dynamic> json) =>
      RequestedSuperAdmin(
        superAdmin: json["super_admin"],
        status: json["status"],
        requestedAt: json["requested_at"] == null
            ? null
            : DateTime.parse(json["requested_at"]),
        id: json["_id"],
      );

  Map<String, dynamic> toMap() => {
    "super_admin": superAdmin,
    "status": status,
    "requested_at": requestedAt?.toIso8601String(),
    "_id": id,
  };
}

class SuperAdminApproval {
  final String? approvedBy;
  final DateTime? approvedAt;
  final String? id;

  SuperAdminApproval({this.approvedBy, this.approvedAt, this.id});

  factory SuperAdminApproval.fromJson(String str) =>
      SuperAdminApproval.fromMap(json.decode(str));

  String toJson() => json.encode(toMap());

  factory SuperAdminApproval.fromMap(Map<String, dynamic> json) =>
      SuperAdminApproval(
        approvedBy: json["approved_by"],
        approvedAt: json["approved_at"] == null
            ? null
            : DateTime.parse(json["approved_at"]),
        id: json["_id"],
      );

  Map<String, dynamic> toMap() => {
    "approved_by": approvedBy,
    "approved_at": approvedAt?.toIso8601String(),
    "_id": id,
  };
}
