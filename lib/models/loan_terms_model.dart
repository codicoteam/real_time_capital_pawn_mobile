// lib/models/loan_terms_model.dart
import 'dart:convert';

class LoanTerm {
  final String id;
  final String loanId;
  final String loanNo;
  final String termNo;
  final String termType; // 'initial', 'renewal', 'extension', 'settlement'
  final double principalAmount;
  final double interestRatePercent;
  final int termDays;
  final DateTime startDate;
  final DateTime endDate;
  final double currentBalance;
  final String
  status; // 'active', 'completed', 'pending', 'approved', 'rejected', 'draft'
  final DateTime createdAt;
  final DateTime updatedAt;
  final String createdBy;
  final String? approvedBy;
  final DateTime? approvedAt;
  final String? notes;

  // Formatted getters
  String get formattedPrincipalAmount =>
      'ZWL ${principalAmount.toStringAsFixed(2)}';
  String get formattedCurrentBalance =>
      'ZWL ${currentBalance.toStringAsFixed(2)}';
  String get formattedInterestRate => '$interestRatePercent%';
  String get formattedTermDuration => '$termDays days';

  // Status getters
  bool get isActive => status.toLowerCase() == 'active';
  bool get isCompleted => status.toLowerCase() == 'completed';
  bool get isPending => status.toLowerCase() == 'pending';
  bool get isApproved => status.toLowerCase() == 'approved';
  bool get isRejected => status.toLowerCase() == 'rejected';

  LoanTerm({
    required this.id,
    required this.loanId,
    required this.loanNo,
    required this.termNo,
    required this.termType,
    required this.principalAmount,
    required this.interestRatePercent,
    required this.termDays,
    required this.startDate,
    required this.endDate,
    required this.currentBalance,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
    required this.createdBy,
    this.approvedBy,
    this.approvedAt,
    this.notes,
  });

  factory LoanTerm.fromJson(String str) => LoanTerm.fromMap(json.decode(str));

  String toJson() => json.encode(toMap());

  factory LoanTerm.fromMap(Map<String, dynamic> json) {
    // Handle nested loan object structure from your API
    Map<String, dynamic> loanData = {};
    if (json['loan'] != null && json['loan'] is Map<String, dynamic>) {
      loanData = json['loan'] as Map<String, dynamic>;
    }

    return LoanTerm(
      id: json["_id"] ?? json["id"] ?? '',
      loanId: json["loan_id"] ?? loanData["_id"] ?? loanData["id"] ?? '',
      loanNo:
          json["loan_no"] ?? loanData["loan_no"] ?? loanData["loanNo"] ?? '',
      termNo: (json["term_no"] ?? json["termNo"] ?? 1).toString(),
      termType:
          json["term_type"] ??
          json["termType"] ??
          json["renewal_type"] ??
          'initial',
      principalAmount:
          (json["principal_amount"] ??
                  json["principalAmount"] ??
                  json["opening_balance"] ??
                  0)
              .toDouble(),
      interestRatePercent:
          (json["interest_rate_percent"] ??
                  json["interestRatePercent"] ??
                  json["interest_rate"] ??
                  0)
              .toDouble(),
      termDays: json["term_days"] ?? json["termDays"] ?? 0,
      startDate: DateTime.parse(
        json["start_date"] ?? json["startDate"] ?? json["created_at"],
      ),
      endDate: DateTime.parse(
        json["end_date"] ??
            json["endDate"] ??
            json["due_date"] ??
            json["created_at"],
      ),
      currentBalance:
          (json["current_balance"] ??
                  json["currentBalance"] ??
                  json["closing_balance"] ??
                  0)
              .toDouble(),
      status: json["status"] ?? 'pending',
      createdAt: DateTime.parse(json["created_at"] ?? json["createdAt"]),
      updatedAt: DateTime.parse(json["updated_at"] ?? json["updatedAt"]),
      createdBy: json["created_by"] ?? json["createdBy"] ?? 'System',
      approvedBy: json["approved_by"] ?? json["approvedBy"],
      approvedAt: json["approved_at"] != null || json["approvedAt"] != null
          ? DateTime.parse(json["approved_at"] ?? json["approvedAt"])
          : null,
      notes: json["notes"],
    );
  }

  Map<String, dynamic> toMap() => {
    "_id": id,
    "loan_id": loanId,
    "loan_no": loanNo,
    "term_no": termNo,
    "term_type": termType,
    "principal_amount": principalAmount,
    "interest_rate_percent": interestRatePercent,
    "term_days": termDays,
    "start_date": startDate.toIso8601String(),
    "end_date": endDate.toIso8601String(),
    "current_balance": currentBalance,
    "status": status,
    "created_at": createdAt.toIso8601String(),
    "updated_at": updatedAt.toIso8601String(),
    "created_by": createdBy,
    "approved_by": approvedBy,
    "approved_at": approvedAt?.toIso8601String(),
    "notes": notes,
  };
}
