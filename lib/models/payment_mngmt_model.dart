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

  // 🔴 THIS IS THE ONLY METHOD YOU NEED TO REPLACE - COPY THIS EXACTLY
  factory PaymentModel.fromMap(Map<String, dynamic> json) {
    // STEP 1: Get the actual payment data regardless of wrapper
    Map<String, dynamic> data;

    if (json.containsKey('data') && json['data'] != null) {
      data = json['data'] is Map ? Map<String, dynamic>.from(json['data']) : {};
    } else if (json.containsKey('payment') && json['payment'] != null) {
      data = json['payment'] is Map
          ? Map<String, dynamic>.from(json['payment'])
          : {};
    } else {
      data = json;
    }

    // STEP 2: Extract loan ID
    String loanId = '';
    if (data['loan'] != null) {
      if (data['loan'] is Map) {
        loanId =
            data['loan']['_id']?.toString() ??
            data['loan']['loan_no']?.toString() ??
            '';
      } else {
        loanId = data['loan'].toString();
      }
    }

    // STEP 3: Parse dates safely
    DateTime parseDate(dynamic dateValue) {
      if (dateValue == null) return DateTime.now();
      try {
        return DateTime.parse(dateValue.toString());
      } catch (e) {
        return DateTime.now();
      }
    }

    return PaymentModel(
      id: data["_id"]?.toString() ?? '',
      reference: data["reference"]?.toString() ?? '',
      loan: loanId,
      loanTerm: data["loan_term"]?.toString(),
      amount: (data["amount"] as num?)?.toDouble() ?? 0.0,
      currency: data["currency"]?.toString() ?? 'USD',
      provider: data["provider"]?.toString(),
      method: data["method"]?.toString(),
      paymentStatus:
          data["payment_status"]?.toString().toLowerCase() ?? 'pending',
      interestComponent:
          (data["interest_component"] as num?)?.toDouble() ?? 0.0,
      principalComponent:
          (data["principal_component"] as num?)?.toDouble() ?? 0.0,
      storageComponent: (data["storage_component"] as num?)?.toDouble() ?? 0.0,
      penaltyComponent: (data["penalty_component"] as num?)?.toDouble() ?? 0.0,
      notes: data["notes"]?.toString(),
      pollUrl: data["pollUrl"]?.toString(),
      receiptNo: data["receipt_no"]?.toString(),
      createdAt: parseDate(data["created_at"]),
      updatedAt: parseDate(data["updated_at"]),
      paymentDate: data["payment_date"]?.toString(),
    );
  }

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
  String get formattedAmount => '\$${amount.toStringAsFixed(2)}';
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
      'interest': (interestComponent / amount * 100),
      'principal': (principalComponent / amount * 100),
      'storage': (storageComponent / amount * 100),
      'penalty': (penaltyComponent / amount * 100),
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

  factory PaymentListResponse.fromMap(Map<String, dynamic> json) {
    Map<String, dynamic> data;
    if (json.containsKey('data') && json['data'] != null) {
      data = json['data'] is Map ? Map<String, dynamic>.from(json['data']) : {};
    } else {
      data = json;
    }

    return PaymentListResponse(
      payments: List<PaymentModel>.from(
        (data["payments"] as List?)?.map((x) => PaymentModel.fromMap(x)) ?? [],
      ),
      pagination: Pagination.fromMap(data["pagination"] ?? {}),
    );
  }

  Map<String, dynamic> toMap() => {
    "payments": List<dynamic>.from(payments.map((x) => x.toMap())),
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
