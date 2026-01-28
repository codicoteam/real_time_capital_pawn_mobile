import 'package:real_time_pawn/models/user_bid_models.dart';

class PaymentMethod {
  final String id;
  final String name;
  final String description;
  final String? icon;
  final List<String> supportedCountries;
  final String? phoneFormat;
  final bool isDefault;

  PaymentMethod({
    required this.id,
    required this.name,
    required this.description,
    this.icon,
    required this.supportedCountries,
    this.phoneFormat,
    this.isDefault = false,
  });

  factory PaymentMethod.fromJson(Map<String, dynamic> json) {
    return PaymentMethod(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      icon: json['icon'],
      supportedCountries: List<String>.from(json['supported_countries'] ?? []),
      phoneFormat: json['phone_format'],
      isDefault: json['default'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'icon': icon,
      'supported_countries': supportedCountries,
      'phone_format': phoneFormat,
      'default': isDefault,
    };
  }
}

enum PaymentStatus {
  pending,
  success,
  failed,
  refunded,
  initiated,
  processing,
  cancelled,
}

// SIMPLIFIED VERSION - Without requiring toJson methods
class BidPayment {
  final String id;
  final UserBid bid;
  final UserBidAuction auction;
  final UserBidder payerUser;
  final double amount;
  final String currency;
  final PaymentStatus status;
  final String method;
  final String provider;
  final String? providerTxnId;
  final String? receiptNo;
  final String? notes;
  final String? payerPhone;
  final String? redirectUrl;
  final DateTime? paidAt;
  final Map<String, dynamic>? meta;
  final DateTime createdAt;
  final DateTime updatedAt;

  BidPayment({
    required this.id,
    required this.bid,
    required this.auction,
    required this.payerUser,
    required this.amount,
    this.currency = 'USD',
    required this.status,
    required this.method,
    required this.provider,
    this.providerTxnId,
    this.receiptNo,
    this.notes,
    this.payerPhone,
    this.redirectUrl,
    this.paidAt,
    this.meta,
    required this.createdAt,
    required this.updatedAt,
  });

  factory BidPayment.fromJson(Map<String, dynamic> json) {
    return BidPayment(
      id: json['_id'] ?? json['id'] ?? '',
      bid: UserBid.fromJson(json['bid'] ?? {}),
      auction: UserBidAuction.fromJson(json['auction'] ?? {}),
      payerUser: UserBidder.fromJson(json['payer_user'] ?? {}),
      amount: (json['amount'] ?? 0).toDouble(),
      currency: json['currency'] ?? 'USD',
      status: _parsePaymentStatus(json['status']),
      method: json['method'] ?? '',
      provider: json['provider'] ?? '',
      providerTxnId: json['provider_txn_id'],
      receiptNo: json['receipt_no'],
      notes: json['notes'],
      payerPhone: json['payer_phone'],
      redirectUrl: json['redirect_url'],
      paidAt: json['paid_at'] != null ? DateTime.parse(json['paid_at']) : null,
      meta: json['meta'] != null
          ? Map<String, dynamic>.from(json['meta'])
          : null,
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }

  static PaymentStatus _parsePaymentStatus(String status) {
    switch (status.toLowerCase()) {
      case 'success':
        return PaymentStatus.success;
      case 'failed':
        return PaymentStatus.failed;
      case 'refunded':
        return PaymentStatus.refunded;
      case 'initiated':
        return PaymentStatus.initiated;
      case 'processing':
        return PaymentStatus.processing;
      case 'cancelled':
        return PaymentStatus.cancelled;
      default:
        return PaymentStatus.pending;
    }
  }

  // SIMPLE toJson - just basic data for API calls
  Map<String, dynamic> toSimpleJson() {
    return {
      'id': id,
      'bid_id': bid.id,
      'amount': amount,
      'currency': currency,
      'status': status.toString().split('.').last,
      'method': method,
      'provider': provider,
      'payer_phone': payerPhone,
      'notes': notes,
    };
  }

  String get statusText {
    switch (status) {
      case PaymentStatus.success:
        return 'Success';
      case PaymentStatus.failed:
        return 'Failed';
      case PaymentStatus.refunded:
        return 'Refunded';
      case PaymentStatus.initiated:
        return 'Initiated';
      case PaymentStatus.processing:
        return 'Processing';
      case PaymentStatus.cancelled:
        return 'Cancelled';
      default:
        return 'Pending';
    }
  }

  bool get isSuccessful => status == PaymentStatus.success;
  bool get isPending => status == PaymentStatus.pending;
  bool get isFailed => status == PaymentStatus.failed;
}
