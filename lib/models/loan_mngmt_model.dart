import 'dart:convert';

class LoanModel {
  final String id;
  final String loanNo;
  final CustomerUser customerUser;
  final String? application;
  final String? asset;
  final String collateralCategory;
  final double principalAmount;
  final double currentBalance;
  final String currency;
  final double interestRatePercent;
  final int interestPeriodDays;
  final double storageChargePercent;
  final double penaltyPercent;
  final int graceDays;
  final DateTime startDate;
  final DateTime dueDate;
  final String status; // 'active', 'overdue', 'settled', 'defaulted'
  final List<dynamic> attachments;
  final String createdBy;
  final DateTime createdAt;
  final DateTime updatedAt;

  LoanModel({
    required this.id,
    required this.loanNo,
    required this.customerUser,
    this.application,
    this.asset,
    required this.collateralCategory,
    required this.principalAmount,
    required this.currentBalance,
    required this.currency,
    required this.interestRatePercent,
    required this.interestPeriodDays,
    required this.storageChargePercent,
    required this.penaltyPercent,
    required this.graceDays,
    required this.startDate,
    required this.dueDate,
    required this.status,
    required this.attachments,
    required this.createdBy,
    required this.createdAt,
    required this.updatedAt,
  });

  factory LoanModel.fromJson(String str) => LoanModel.fromMap(json.decode(str));

  String toJson() => json.encode(toMap());

  factory LoanModel.fromMap(Map<String, dynamic> json) => LoanModel(
    id: json["_id"] ?? '',
    loanNo: json["loan_no"] ?? '',
    customerUser: CustomerUser.fromMap(json["customer_user"] ?? {}),
    application: json["application"],
    asset: json["asset"],
    collateralCategory: json["collateral_category"] ?? '',
    principalAmount: (json["principal_amount"] as num?)?.toDouble() ?? 0.0,
    currentBalance: (json["current_balance"] as num?)?.toDouble() ?? 0.0,
    currency: json["currency"] ?? 'USD',
    interestRatePercent:
        (json["interest_rate_percent"] as num?)?.toDouble() ?? 0.0,
    interestPeriodDays: json["interest_period_days"] ?? 0,
    storageChargePercent:
        (json["storage_charge_percent"] as num?)?.toDouble() ?? 0.0,
    penaltyPercent: (json["penalty_percent"] as num?)?.toDouble() ?? 0.0,
    graceDays: json["grace_days"] ?? 0,
    startDate: json["start_date"] != null
        ? DateTime.parse(json["start_date"])
        : DateTime.now(),
    dueDate: json["due_date"] != null
        ? DateTime.parse(json["due_date"])
        : DateTime.now(),
    status: json["status"] ?? 'active',
    attachments: json["attachments"] ?? [],
    createdBy: json["created_by"] ?? '',
    createdAt: json["created_at"] != null
        ? DateTime.parse(json["created_at"])
        : DateTime.now(),
    updatedAt: json["updated_at"] != null
        ? DateTime.parse(json["updated_at"])
        : DateTime.now(),
  );

  Map<String, dynamic> toMap() => {
    "_id": id,
    "loan_no": loanNo,
    "customer_user": customerUser.toMap(),
    "application": application,
    "asset": asset,
    "collateral_category": collateralCategory,
    "principal_amount": principalAmount,
    "current_balance": currentBalance,
    "currency": currency,
    "interest_rate_percent": interestRatePercent,
    "interest_period_days": interestPeriodDays,
    "storage_charge_percent": storageChargePercent,
    "penalty_percent": penaltyPercent,
    "grace_days": graceDays,
    "start_date": startDate.toIso8601String(),
    "due_date": dueDate.toIso8601String(),
    "status": status,
    "attachments": attachments,
    "created_by": createdBy,
    "created_at": createdAt.toIso8601String(),
    "updated_at": updatedAt.toIso8601String(),
  };

  // Helper getters
  String get customerName =>
      '${customerUser.firstName} ${customerUser.lastName}';
  String get customerEmail => customerUser.email;
  String get customerPhone => customerUser.phone;
  String get formattedPrincipalAmount =>
      '$currency ${principalAmount.toStringAsFixed(2)}';
  String get formattedCurrentBalance =>
      '$currency ${currentBalance.toStringAsFixed(2)}';
  bool get isActive => status == 'active';
  bool get isOverdue => status == 'overdue';
  bool get isSettled => status == 'settled';
}

class CustomerUser {
  final String id;
  final String email;
  final String phone;
  final String firstName;
  final String lastName;

  CustomerUser({
    required this.id,
    required this.email,
    required this.phone,
    required this.firstName,
    required this.lastName,
  });

  factory CustomerUser.fromJson(String str) =>
      CustomerUser.fromMap(json.decode(str));

  String toJson() => json.encode(toMap());

  factory CustomerUser.fromMap(Map<String, dynamic> json) => CustomerUser(
    id: json["_id"] ?? '',
    email: json["email"] ?? '',
    phone: json["phone"] ?? '',
    firstName: json["first_name"] ?? '',
    lastName: json["last_name"] ?? '',
  );

  Map<String, dynamic> toMap() => {
    "_id": id,
    "email": email,
    "phone": phone,
    "first_name": firstName,
    "last_name": lastName,
  };
}

// ✅ FIXED: This matches what LoanService expects
class LoansResponse {
  final List<LoanModel> loans;
  final Pagination pagination;

  LoansResponse({required this.loans, required this.pagination});

  factory LoansResponse.fromJson(String str) =>
      LoansResponse.fromMap(json.decode(str));

  String toJson() => json.encode(toMap());

  factory LoansResponse.fromMap(Map<String, dynamic> json) => LoansResponse(
    loans: List<LoanModel>.from(
      (json["loans"] as List?)?.map((x) => LoanModel.fromMap(x)) ?? [],
    ),
    pagination: Pagination.fromMap(json["pagination"] ?? {}),
  );

  Map<String, dynamic> toMap() => {
    "loans": List<dynamic>.from(loans.map((x) => x.toMap())),
    "pagination": pagination.toMap(),
  };
}

class Pagination {
  final int total;
  final int page;
  final int limit;
  final int totalPages;
  final bool hasNextPage;
  final bool hasPrevPage;

  Pagination({
    required this.total,
    required this.page,
    required this.limit,
    required this.totalPages,
    required this.hasNextPage,
    required this.hasPrevPage,
  });

  factory Pagination.fromJson(String str) =>
      Pagination.fromMap(json.decode(str));

  String toJson() => json.encode(toMap());

  factory Pagination.fromMap(Map<String, dynamic> json) => Pagination(
    total: json["total"] ?? 0,
    page: json["page"] ?? 1,
    limit: json["limit"] ?? 10,
    totalPages: json["totalPages"] ?? 1,
    hasNextPage: json["hasNextPage"] ?? false,
    hasPrevPage: json["hasPrevPage"] ?? false,
  );

  Map<String, dynamic> toMap() => {
    "total": total,
    "page": page,
    "limit": limit,
    "totalPages": totalPages,
    "hasNextPage": hasNextPage,
    "hasPrevPage": hasPrevPage,
  };
}

// For loan charges response
class LoanChargesResponse {
  final double totalCharges;
  final double totalPaid;
  final double outstandingCharges;
  final Map<String, dynamic> breakdown;
  final List<dynamic> charges;

  LoanChargesResponse({
    required this.totalCharges,
    required this.totalPaid,
    required this.outstandingCharges,
    required this.breakdown,
    required this.charges,
  });

  factory LoanChargesResponse.fromMap(Map<String, dynamic> json) =>
      LoanChargesResponse(
        totalCharges: (json["totalCharges"] as num?)?.toDouble() ?? 0.0,
        totalPaid: (json["totalPaid"] as num?)?.toDouble() ?? 0.0,
        outstandingCharges:
            (json["outstandingCharges"] as num?)?.toDouble() ?? 0.0,
        breakdown: Map<String, dynamic>.from(json["breakdown"] ?? {}),
        charges: List<dynamic>.from(json["charges"] ?? []),
      );

  Map<String, dynamic> toMap() => {
    "totalCharges": totalCharges,
    "totalPaid": totalPaid,
    "outstandingCharges": outstandingCharges,
    "breakdown": breakdown,
    "charges": charges,
  };
}
