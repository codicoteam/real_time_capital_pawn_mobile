import 'dart:convert';

class PaymentModel {
  final String id;
  final String reference;
  final String loan;
  final String? loanTerm;
  final double amount;
  final String currency;
  final String? provider;
  final String? method;
  final String paymentStatus;
  final double interestComponent;
  final double principalComponent;
  final double storageComponent;
  final double penaltyComponent;
  final String? notes;
  final String? pollUrl;
  final String? receiptNo;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? paymentDate;

  PaymentModel({
    required this.id,
    required this.reference,
    required this.loan,
    this.loanTerm,
    required this.amount,
    this.currency = 'USD',
    this.provider,
    this.method,
    required this.paymentStatus,
    required this.interestComponent,
    required this.principalComponent,
    required this.storageComponent,
    required this.penaltyComponent,
    this.notes,
    this.pollUrl,
    this.receiptNo,
    required this.createdAt,
    required this.updatedAt,
    this.paymentDate,
  });

  factory PaymentModel.fromJson(String str) =>
      PaymentModel.fromMap(json.decode(str));

  String toJson() => json.encode(toMap());

  factory PaymentModel.fromMap(Map<String, dynamic> json) => PaymentModel(
    id: json["_id"] ?? '',
    reference: json["reference"] ?? '',
    loan: json["loan"] is Map
        ? (json["loan"]["_id"] ?? json["loan"]["loan_no"] ?? '')
        : (json["loan"]?.toString() ?? ''),
    loanTerm: json["loan_term"],
    amount: (json["amount"] as num?)?.toDouble() ?? 0.0,
    currency: json["currency"] ?? 'USD',
    provider: json["provider"],
    method: json["method"],
    paymentStatus: json["payment_status"] ?? 'pending',
    interestComponent: (json["interest_component"] as num?)?.toDouble() ?? 0.0,
    principalComponent:
        (json["principal_component"] as num?)?.toDouble() ?? 0.0,
    storageComponent: (json["storage_component"] as num?)?.toDouble() ?? 0.0,
    penaltyComponent: (json["penalty_component"] as num?)?.toDouble() ?? 0.0,
    notes: json["notes"],
    pollUrl: json["pollUrl"],
    receiptNo: json["receipt_no"],
    createdAt: json["created_at"] != null
        ? DateTime.parse(json["created_at"])
        : DateTime.now(),
    updatedAt: json["updated_at"] != null
        ? DateTime.parse(json["updated_at"])
        : DateTime.now(),
    paymentDate: json["payment_date"],
  );

  Map<String, dynamic> toMap() => {
    "loan": loan,
    "loan_term": loanTerm,
    "amount": amount,
    "currency": currency,
    "provider": provider,
    "method": method,
    "payment_status": paymentStatus,
    "interest_component": interestComponent,
    "principal_component": principalComponent,
    "storage_component": storageComponent,
    "penalty_component": penaltyComponent,
    "notes": notes,
  };

  // Helper getters
  String get formattedAmount => '$currency ${amount.toStringAsFixed(2)}';
  String get formattedDate => paymentDate ?? createdAt.toString();
  bool get isPending => paymentStatus.toLowerCase() == 'pending';
  bool get isPaid => paymentStatus.toLowerCase() == 'paid';
  bool get isFailed => paymentStatus.toLowerCase() == 'failed';
  bool get isProcessing => paymentStatus.toLowerCase() == 'processing';

  double get totalComponents =>
      interestComponent +
      principalComponent +
      storageComponent +
      penaltyComponent;

  Map<String, double> get componentPercentages {
    if (amount == 0) return {};

    return {
      'interest': interestComponent / amount * 100,
      'principal': principalComponent / amount * 100,
      'storage': storageComponent / amount * 100,
      'penalty': penaltyComponent / amount * 100,
    };
  }
}

class PaymentListResponse {
  final List<PaymentModel> payments;
  final Pagination pagination;

  PaymentListResponse({required this.payments, required this.pagination});

  factory PaymentListResponse.fromJson(String str) =>
      PaymentListResponse.fromMap(json.decode(str));

  String toJson() => json.encode(toMap());

  factory PaymentListResponse.fromMap(Map<String, dynamic> json) =>
      PaymentListResponse(
        payments: List<PaymentModel>.from(
          (json["payments"] as List?)?.map((x) => PaymentModel.fromMap(x)) ??
              [],
        ),
        pagination: Pagination.fromMap(json["pagination"] ?? {}),
      );

  Map<String, dynamic> toMap() => {
    "payments": List<dynamic>.from(payments.map((x) => x.toMap())),
    "pagination": pagination.toMap(),
  };
}

// Reuse existing Pagination class or create new one
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
