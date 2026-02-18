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
    // Safely parse nested objects
    final bidData = json['bid'];
    final auctionData = json['auction'];
    final payerUserData = json['payer_user'];

    return BidPayment(
      id: json['_id']?.toString() ?? json['id']?.toString() ?? '',

      // Handle bid data safely
      bid: bidData is Map<String, dynamic>
          ? UserBid.fromJson(bidData)
          : UserBid.fromJson({}),

      // Handle auction data safely
      auction: auctionData is Map<String, dynamic>
          ? UserBidAuction.fromJson(auctionData)
          : UserBidAuction.fromJson({}),

      // Handle payer user data safely
      payerUser: payerUserData is Map<String, dynamic>
          ? UserBidder.fromJson(payerUserData)
          : UserBidder.fromJson({}),

      amount: (json['amount'] is num)
          ? (json['amount'] as num).toDouble()
          : 0.0,

      currency: json['currency']?.toString() ?? 'USD',

      status: json['status'] != null
          ? _parsePaymentStatus(json['status'].toString())
          : PaymentStatus.pending,

      method: json['method']?.toString() ?? '',
      provider: json['provider']?.toString() ?? '',

      // ✅ CRITICAL FIX: Handle null values properly with toString() conversion
      providerTxnId: json['provider_txn_id'] != null
          ? json['provider_txn_id'].toString()
          : null,

      receiptNo: json['receipt_no'] != null
          ? json['receipt_no'].toString()
          : null,

      notes: json['notes'] != null ? json['notes'].toString() : null,

      payerPhone: json['payer_phone'] != null
          ? json['payer_phone'].toString()
          : null,

      redirectUrl: json['redirect_url'] != null
          ? json['redirect_url'].toString()
          : null,

      paidAt: json['paid_at'] != null
          ? DateTime.tryParse(json['paid_at'].toString())
          : null,

      meta: json['meta'] is Map<String, dynamic>
          ? Map<String, dynamic>.from(json['meta'])
          : null,

      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'].toString()) ?? DateTime.now()
          : DateTime.now(),

      updatedAt: json['updated_at'] != null
          ? DateTime.tryParse(json['updated_at'].toString()) ?? DateTime.now()
          : DateTime.now(),
    );
  }

  static PaymentStatus _parsePaymentStatus(String status) {
    switch (status.toLowerCase()) {
      case 'success':
      case 'successful':
      case 'paid':
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
      case 'canceled':
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

  /// ✅ NEW HELPER: Get the PayNow poll URL for checking payment status
  String? get pollUrl {
    // Check multiple possible locations in the response structure
    if (meta != null) {
      // Direct poll_url in meta (from your API response)
      if (meta!['poll_url'] != null) {
        return meta!['poll_url'].toString();
      }

      // Nested in paynow_response (from your API response)
      if (meta!['paynow_response'] is Map) {
        final paynowResponse = meta!['paynow_response'] as Map;
        if (paynowResponse['poll_url'] != null) {
          return paynowResponse['poll_url'].toString();
        }
      }

      // Check for any URL-like field
      if (meta!['url'] != null) {
        return meta!['url'].toString();
      }
    }
    return null;
  }

  /// ✅ NEW HELPER: Get payment instructions for the user
  String? get paymentInstructions {
    if (meta != null) {
      // Direct instructions in meta
      if (meta!['instructions'] != null) {
        return meta!['instructions'].toString();
      }

      // Nested in paynow_response
      if (meta!['paynow_response'] is Map) {
        final paynowResponse = meta!['paynow_response'] as Map;
        if (paynowResponse['instructions'] != null) {
          return paynowResponse['instructions'].toString();
        }
      }
    }
    return null;
  }

  /// ✅ NEW HELPER: Get the USSD code from instructions (extract *151*2*7# pattern)
  String? get ussdCode {
    final instructions = paymentInstructions;
    if (instructions == null) return null;

    // Try to extract USSD code pattern like *151*2*7#
    final RegExp ussdRegex = RegExp(r'\*[0-9\*]+\#');
    final match = ussdRegex.firstMatch(instructions);
    return match?.group(0);
  }

  /// ✅ NEW HELPER: Check if payment requires user action (like dialing USSD)
  bool get requiresUserAction {
    return method.toLowerCase() == 'ecocash' ||
        provider.toLowerCase() == 'ecocash' ||
        (paymentInstructions?.contains('*151') ?? false);
  }

  /// ✅ NEW HELPER: Get the full PayNow response object
  Map<String, dynamic>? get paynowResponse {
    if (meta != null && meta!['paynow_response'] is Map) {
      return Map<String, dynamic>.from(meta!['paynow_response']);
    }
    return null;
  }

  /// ✅ NEW HELPER: Check if payment was successful from gateway
  bool get isGatewaySuccess {
    if (paynowResponse != null) {
      return paynowResponse!['success'] == true;
    }
    return isSuccessful;
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
  bool get isInitiated => status == PaymentStatus.initiated;
  bool get isProcessing => status == PaymentStatus.processing;
  bool get isCancelled => status == PaymentStatus.cancelled;
  bool get isRefunded => status == PaymentStatus.refunded;

  /// Check if payment can be checked for status (has poll URL)
  bool get canCheckStatus => pollUrl != null && !isSuccessful && !isFailed;

  /// Get formatted amount with currency
  String get formattedAmount => '\$${amount.toStringAsFixed(2)} $currency';
}
