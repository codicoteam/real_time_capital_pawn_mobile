// lib/models/loan_terms_model.dart
import 'dart:convert';

class LoanTerm {
  final String id;
  final String loanId;
  final String loanNo;
  final String termNo;
  final String
  termType; // 'initial', 'renewal', 'extension', 'partial_renewal', 'settlement'
  final double principalAmount;
  final double interestRatePercent;
  final int termDays;
  final DateTime startDate;
  final DateTime endDate;
  final double currentBalance;
  final String
  status; // 'active', 'completed', 'pending', 'approved', 'rejected'
  final List<Approval> approvals;
  final Map<String, dynamic>? termsData;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String createdBy;
  final String? approvedBy;
  final DateTime? approvedAt;
  final String? notes;
  final String? renewalReason;
  final double? previousBalance;
  final double? interestAmount;
  final double? storageChargeAmount;
  final double? penaltyAmount;

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
    required this.approvals,
    this.termsData,
    required this.createdAt,
    required this.updatedAt,
    required this.createdBy,
    this.approvedBy,
    this.approvedAt,
    this.notes,
    this.renewalReason,
    this.previousBalance,
    this.interestAmount,
    this.storageChargeAmount,
    this.penaltyAmount,
  });

  factory LoanTerm.fromJson(String str) => LoanTerm.fromMap(json.decode(str));

  String toJson() => json.encode(toMap());

  factory LoanTerm.fromMap(Map<String, dynamic> json) => LoanTerm(
    id: json["_id"] ?? json["id"] ?? '',
    loanId: json["loan_id"] ?? json["loanId"] ?? '',
    loanNo: json["loan_no"] ?? json["loanNo"] ?? '',
    termNo: json["term_no"] ?? json["termNo"] ?? '',
    termType: json["term_type"] ?? json["termType"] ?? 'initial',
    principalAmount: (json["principal_amount"] ?? json["principalAmount"] ?? 0)
        .toDouble(),
    interestRatePercent:
        (json["interest_rate_percent"] ?? json["interestRatePercent"] ?? 0)
            .toDouble(),
    termDays: json["term_days"] ?? json["termDays"] ?? 0,
    startDate: DateTime.parse(json["start_date"] ?? json["startDate"]),
    endDate: DateTime.parse(json["end_date"] ?? json["endDate"]),
    currentBalance: (json["current_balance"] ?? json["currentBalance"] ?? 0)
        .toDouble(),
    status: json["status"] ?? 'pending',
    approvals: json["approvals"] != null
        ? List<Approval>.from(json["approvals"].map((x) => Approval.fromMap(x)))
        : [],
    termsData: json["terms_data"] ?? json["termsData"],
    createdAt: DateTime.parse(json["created_at"] ?? json["createdAt"]),
    updatedAt: DateTime.parse(json["updated_at"] ?? json["updatedAt"]),
    createdBy: json["created_by"] ?? json["createdBy"] ?? '',
    approvedBy: json["approved_by"] ?? json["approvedBy"],
    approvedAt: json["approved_at"] != null || json["approvedAt"] != null
        ? DateTime.parse(json["approved_at"] ?? json["approvedAt"])
        : null,
    notes: json["notes"],
    renewalReason: json["renewal_reason"] ?? json["renewalReason"],
    previousBalance:
        json["previous_balance"] != null || json["previousBalance"] != null
        ? (json["previous_balance"] ?? json["previousBalance"]).toDouble()
        : null,
    interestAmount:
        json["interest_amount"] != null || json["interestAmount"] != null
        ? (json["interest_amount"] ?? json["interestAmount"]).toDouble()
        : null,
    storageChargeAmount:
        json["storage_charge_amount"] != null ||
            json["storageChargeAmount"] != null
        ? (json["storage_charge_amount"] ?? json["storageChargeAmount"])
              .toDouble()
        : null,
    penaltyAmount:
        json["penalty_amount"] != null || json["penaltyAmount"] != null
        ? (json["penalty_amount"] ?? json["penaltyAmount"]).toDouble()
        : null,
  );

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
    "approvals": List<dynamic>.from(approvals.map((x) => x.toMap())),
    "terms_data": termsData,
    "created_at": createdAt.toIso8601String(),
    "updated_at": updatedAt.toIso8601String(),
    "created_by": createdBy,
    "approved_by": approvedBy,
    "approved_at": approvedAt?.toIso8601String(),
    "notes": notes,
    "renewal_reason": renewalReason,
    "previous_balance": previousBalance,
    "interest_amount": interestAmount,
    "storage_charge_amount": storageChargeAmount,
    "penalty_amount": penaltyAmount,
  };
}

class Approval {
  final String id;
  final String approvedBy;
  final String role;
  final DateTime approvedAt;
  final String? notes;
  final String status;

  Approval({
    required this.id,
    required this.approvedBy,
    required this.role,
    required this.approvedAt,
    this.notes,
    required this.status,
  });

  factory Approval.fromJson(String str) => Approval.fromMap(json.decode(str));

  String toJson() => json.encode(toMap());

  factory Approval.fromMap(Map<String, dynamic> json) => Approval(
    id: json["_id"] ?? json["id"] ?? '',
    approvedBy: json["approved_by"] ?? json["approvedBy"] ?? '',
    role: json["role"] ?? '',
    approvedAt: DateTime.parse(json["approved_at"] ?? json["approvedAt"]),
    notes: json["notes"],
    status: json["status"] ?? 'approved',
  );

  Map<String, dynamic> toMap() => {
    "_id": id,
    "approved_by": approvedBy,
    "role": role,
    "approved_at": approvedAt.toIso8601String(),
    "notes": notes,
    "status": status,
  };
}

class LoanTermTimeline {
  final String loanId;
  final String loanNo;
  final List<TimelineEvent> events;
  final int totalTerms;
  final double totalPrincipal;
  final double totalInterest;
  final double totalPaid;
  final double outstandingBalance;

  LoanTermTimeline({
    required this.loanId,
    required this.loanNo,
    required this.events,
    required this.totalTerms,
    required this.totalPrincipal,
    required this.totalInterest,
    required this.totalPaid,
    required this.outstandingBalance,
  });

  factory LoanTermTimeline.fromJson(String str) =>
      LoanTermTimeline.fromMap(json.decode(str));

  String toJson() => json.encode(toMap());

  factory LoanTermTimeline.fromMap(Map<String, dynamic> json) =>
      LoanTermTimeline(
        loanId: json["loan_id"] ?? json["loanId"] ?? '',
        loanNo: json["loan_no"] ?? json["loanNo"] ?? '',
        events: json["events"] != null
            ? List<TimelineEvent>.from(
                json["events"].map((x) => TimelineEvent.fromMap(x)),
              )
            : [],
        totalTerms: json["total_terms"] ?? json["totalTerms"] ?? 0,
        totalPrincipal: (json["total_principal"] ?? json["totalPrincipal"] ?? 0)
            .toDouble(),
        totalInterest: (json["total_interest"] ?? json["totalInterest"] ?? 0)
            .toDouble(),
        totalPaid: (json["total_paid"] ?? json["totalPaid"] ?? 0).toDouble(),
        outstandingBalance:
            (json["outstanding_balance"] ?? json["outstandingBalance"] ?? 0)
                .toDouble(),
      );

  Map<String, dynamic> toMap() => {
    "loan_id": loanId,
    "loan_no": loanNo,
    "events": List<dynamic>.from(events.map((x) => x.toMap())),
    "total_terms": totalTerms,
    "total_principal": totalPrincipal,
    "total_interest": totalInterest,
    "total_paid": totalPaid,
    "outstanding_balance": outstandingBalance,
  };
}

class TimelineEvent {
  final DateTime date;
  final String
  eventType; // 'term_start', 'renewal', 'extension', 'payment', 'approval', 'due_date'
  final String description;
  final Map<String, dynamic> data;
  final String? termNo;
  final double? amount;
  final String? status;

  TimelineEvent({
    required this.date,
    required this.eventType,
    required this.description,
    required this.data,
    this.termNo,
    this.amount,
    this.status,
  });

  factory TimelineEvent.fromJson(String str) =>
      TimelineEvent.fromMap(json.decode(str));

  String toJson() => json.encode(toMap());

  factory TimelineEvent.fromMap(Map<String, dynamic> json) => TimelineEvent(
    date: DateTime.parse(json["date"]),
    eventType: json["event_type"] ?? json["eventType"] ?? '',
    description: json["description"] ?? '',
    data: json["data"] ?? {},
    termNo: json["term_no"] ?? json["termNo"],
    amount: json["amount"] != null ? json["amount"].toDouble() : null,
    status: json["status"],
  );

  Map<String, dynamic> toMap() => {
    "date": date.toIso8601String(),
    "event_type": eventType,
    "description": description,
    "data": data,
    "term_no": termNo,
    "amount": amount,
    "status": status,
  };
}

class RenewalRequest {
  final String loanId;
  final String currentTermId;
  final double newPrincipal;
  final int extensionDays;
  final String renewalType; // 'full', 'partial', 'interest_only'
  final String? notes;
  final String? reason;
  final double? interestRate;
  final double? storageChargeRate;
  final double? penaltyRate;

  RenewalRequest({
    required this.loanId,
    required this.currentTermId,
    required this.newPrincipal,
    required this.extensionDays,
    required this.renewalType,
    this.notes,
    this.reason,
    this.interestRate,
    this.storageChargeRate,
    this.penaltyRate,
  });

  Map<String, dynamic> toMap() => {
    "loan_id": loanId,
    "current_term_id": currentTermId,
    "new_principal": newPrincipal,
    "extension_days": extensionDays,
    "renewal_type": renewalType,
    "notes": notes,
    "reason": reason,
    "interest_rate": interestRate,
    "storage_charge_rate": storageChargeRate,
    "penalty_rate": penaltyRate,
  };

  String toJson() => json.encode(toMap());
}

class LoanTermStats {
  final int totalTerms;
  final int activeTerms;
  final int completedTerms;
  final int pendingTerms;
  final double totalPrincipal;
  final double totalOutstanding;
  final double totalInterest;
  final Map<String, int> termTypeCount;

  LoanTermStats({
    required this.totalTerms,
    required this.activeTerms,
    required this.completedTerms,
    required this.pendingTerms,
    required this.totalPrincipal,
    required this.totalOutstanding,
    required this.totalInterest,
    required this.termTypeCount,
  });

  factory LoanTermStats.fromMap(Map<String, dynamic> json) => LoanTermStats(
    totalTerms: json["total_terms"] ?? json["totalTerms"] ?? 0,
    activeTerms: json["active_terms"] ?? json["activeTerms"] ?? 0,
    completedTerms: json["completed_terms"] ?? json["completedTerms"] ?? 0,
    pendingTerms: json["pending_terms"] ?? json["pendingTerms"] ?? 0,
    totalPrincipal: (json["total_principal"] ?? json["totalPrincipal"] ?? 0)
        .toDouble(),
    totalOutstanding:
        (json["total_outstanding"] ?? json["totalOutstanding"] ?? 0).toDouble(),
    totalInterest: (json["total_interest"] ?? json["totalInterest"] ?? 0)
        .toDouble(),
    termTypeCount: Map<String, int>.from(
      json["term_type_count"] ?? json["termTypeCount"] ?? {},
    ),
  );
}
