import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:real_time_pawn/core/utils/logs.dart';
import 'package:real_time_pawn/core/utils/pallete.dart';
import 'package:real_time_pawn/features/bid_payment_mngmt/controllers/bid_payment_mngmt_controller.dart';
import 'package:real_time_pawn/features/bid_payment_mngmt/services/bid_payment_mngmt_service.dart';
import 'package:real_time_pawn/models/bid_payment_model.dart';
import 'package:real_time_pawn/widgets/loading_widgets/circular_loader.dart';

class BidPaymentHelper {
  static final BidPaymentController _paymentController =
      Get.find<BidPaymentController>();

  /// LOAD PAYMENT METHODS
  static Future<bool> loadPaymentMethods() async {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (Get.isDialogOpen != true) {
        Get.dialog(
          const CustomLoader(message: 'Loading payment methods...'),
          barrierDismissible: false,
        );
      }
    });

    try {
      final success = await _paymentController.getPaymentMethodsRequest();

      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (Get.isDialogOpen == true) {
          Get.back();
        }
      });

      if (success) {
        return true;
      } else {
        showError(_paymentController.errorMessage.value);
        return false;
      }
    } catch (e) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (Get.isDialogOpen == true) {
          Get.back();
        }
      });
      showError('Failed to load payment methods: ${e.toString()}');
      return false;
    }
  }

  /// LOAD PAYER PAYMENTS
  static Future<bool> loadPayerPayments({
    int page = 1,
    bool showLoader = true,
  }) async {
    if (showLoader) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (Get.isDialogOpen != true) {
          Get.dialog(
            const CustomLoader(message: 'Loading payments...'),
            barrierDismissible: false,
          );
        }
      });
    }

    try {
      final success = await _paymentController.getPayerPaymentsRequest(
        page: page,
      );

      if (showLoader) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (Get.isDialogOpen == true) {
            Get.back();
          }
        });
      }

      if (success) {
        return true;
      } else {
        showError(_paymentController.errorMessage.value);
        return false;
      }
    } catch (e) {
      if (showLoader) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (Get.isDialogOpen == true) {
            Get.back();
          }
        });
      }
      showError('Failed to load payments: ${e.toString()}');
      return false;
    }
  }

  /// CREATE PAYMENT
  static Future<bool> createPayment({
    required String bidId,
    required double amount,
    required String method,
    required String provider,
    required String payerPhone,
    String? redirectUrl,
    String? notes,
  }) async {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (Get.isDialogOpen != true) {
        Get.dialog(
          const CustomLoader(message: 'Processing payment...'),
          barrierDismissible: false,
        );
      }
    });

    try {
      final success = await _paymentController.createPaymentRequest(
        bidId: bidId,
        amount: amount,
        method: method,
        provider: provider,
        payerPhone: payerPhone,
        redirectUrl: redirectUrl,
        notes: notes,
      );

      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (Get.isDialogOpen == true) {
          Get.back();
        }
      });

      if (success) {
        showSuccess(_paymentController.successMessage.value);
        return true;
      } else {
        showError(_paymentController.errorMessage.value);
        return false;
      }
    } catch (e) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (Get.isDialogOpen == true) {
          Get.back();
        }
      });
      showError('Failed to create payment: ${e.toString()}');
      return false;
    }
  }

  /// LOAD PAYMENT DETAILS
  static Future<bool> loadPaymentDetails({required String paymentId}) async {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (Get.isDialogOpen != true) {
        Get.dialog(
          const CustomLoader(message: 'Loading payment details...'),
          barrierDismissible: false,
        );
      }
    });

    try {
      final success = await _paymentController.getPaymentDetailsRequest(
        paymentId: paymentId,
      );

      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (Get.isDialogOpen == true) {
          Get.back();
        }
      });

      if (success) {
        return true;
      } else {
        showError(_paymentController.errorMessage.value);
        return false;
      }
    } catch (e) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (Get.isDialogOpen == true) {
          Get.back();
        }
      });
      showError('Failed to load payment details: ${e.toString()}');
      return false;
    }
  }

  /// CHECK PAYMENT STATUS
  static Future<Map<String, dynamic>?> checkPaymentStatus({
    required String paymentId,
  }) async {
    try {
      final response = await BidPaymentService.checkPaymentStatus(
        paymentId: paymentId,
      );

      if (response.success && response.data != null) {
        showSuccess('Payment status checked successfully');
        return response.data;
      } else {
        showError(response.message ?? 'Failed to check payment status');
        return null;
      }
    } catch (e) {
      showError('Error checking payment status: ${e.toString()}');
      return null;
    }
  }

  /// POLL PAYMENT STATUS CONTINUOUSLY
  static Future<Map<String, dynamic>?> pollPaymentStatus({
    required String paymentId,
    int maxAttempts = 30,
    int intervalSeconds = 2,
    Function(Map<String, dynamic>? statusData)? onStatusUpdate,
  }) async {
    try {
      final statusData = await BidPaymentService.pollPaymentStatus(
        paymentId: paymentId,
        maxAttempts: maxAttempts,
        intervalSeconds: intervalSeconds,
      );

      if (onStatusUpdate != null) {
        onStatusUpdate(statusData);
      }

      return statusData;
    } catch (e) {
      showError('Error polling payment status: ${e.toString()}');
      return null;
    }
  }

  /// SEARCH PAYMENTS
  static Future<List<BidPayment>?> searchPayments({
    required String query,
    String? auctionId,
    String? payerUserId,
    String? status,
    String? method,
    int page = 1,
    int limit = 10,
    bool showLoader = true,
  }) async {
    if (showLoader) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (Get.isDialogOpen != true) {
          Get.dialog(
            const CustomLoader(message: 'Searching payments...'),
            barrierDismissible: false,
          );
        }
      });
    }

    try {
      final response = await BidPaymentService.searchPayments(
        query: query,
        auctionId: auctionId,
        payerUserId: payerUserId,
        status: status,
        method: method,
        page: page,
        limit: limit,
      );

      if (showLoader) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (Get.isDialogOpen == true) {
            Get.back();
          }
        });
      }

      if (response.success && response.data != null) {
        showSuccess('Found ${response.data!.length} payments');
        return response.data;
      } else {
        showError(response.message ?? 'Failed to search payments');
        return null;
      }
    } catch (e) {
      if (showLoader) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (Get.isDialogOpen == true) {
            Get.back();
          }
        });
      }
      showError('Error searching payments: ${e.toString()}');
      return null;
    }
  }

  /// PROCESS PAYNOW WEBHOOK
  static Future<bool> processPayNowWebhook({
    required String reference,
    required String status,
    String? pollUrl,
    String? method,
    double? amount,
  }) async {
    try {
      final response = await BidPaymentService.processPayNowWebhook(
        reference: reference,
        status: status,
        pollUrl: pollUrl,
        method: method,
        amount: amount,
      );

      if (response.success) {
        DevLogs.logSuccess('PayNow webhook processed successfully');
        return true;
      } else {
        DevLogs.logError('PayNow webhook failed: ${response.message}');
        return false;
      }
    } catch (e) {
      DevLogs.logError('Error processing PayNow webhook: $e');
      return false;
    }
  }

  /// SETUP SEARCH CONTROLLER WITH DEBOUNCE
  static void setupSearchController(
    TextEditingController searchController,
    Function(String) onSearch,
  ) {
    Timer? _debounceTimer;

    searchController.addListener(() {
      if (_debounceTimer != null) {
        _debounceTimer!.cancel();
      }

      _debounceTimer = Timer(const Duration(milliseconds: 500), () {
        final query = searchController.text.trim();
        if (query.length >= 2 || query.isEmpty) {
          onSearch(query);
        }
      });
    });
  }

  /// SHOW ERROR
  static void showError(String message) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Get.snackbar(
        'Error',
        message,
        snackPosition: SnackPosition.TOP,
        backgroundColor: AppColors.errorColor,
        colorText: Colors.white,
        borderRadius: 12,
        margin: const EdgeInsets.all(16),
        duration: 3.seconds,
      );
    });
  }

  /// SHOW SUCCESS
  static void showSuccess(String message) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Get.snackbar(
        'Success',
        message,
        snackPosition: SnackPosition.TOP,
        backgroundColor: AppColors.successColor,
        colorText: Colors.white,
        borderRadius: 12,
        margin: const EdgeInsets.all(16),
        duration: 2.seconds,
      );
    });
  }

  /// FORMAT CURRENCY
  static String formatCurrency(double amount, [String currency = 'USD']) {
    if (amount >= 1000) {
      return '\$${(amount / 1000).toStringAsFixed(1)}k';
    }
    return '\$${amount.toStringAsFixed(2)}';
  }

  /// GET TIME AGO
  static String getTimeAgo(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays > 365) {
      final years = (difference.inDays / 365).floor();
      return '$years year${years > 1 ? 's' : ''} ago';
    } else if (difference.inDays > 30) {
      final months = (difference.inDays / 30).floor();
      return '$months month${months > 1 ? 's' : ''} ago';
    } else if (difference.inDays > 0) {
      return '${difference.inDays} day${difference.inDays > 1 ? 's' : ''} ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} hour${difference.inHours > 1 ? 's' : ''} ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} minute${difference.inMinutes > 1 ? 's' : ''} ago';
    } else {
      return 'Just now';
    }
  }

  /// GET PAYMENT STATUS COLOR
  static Color getPaymentStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'success':
        return RealTimeColors.success;
      case 'pending':
      case 'initiated':
      case 'processing':
        return RealTimeColors.warning;
      case 'failed':
        return RealTimeColors.error;
      case 'refunded':
        return RealTimeColors.grey500;
      case 'cancelled':
        return RealTimeColors.grey600;
      default:
        return RealTimeColors.grey400;
    }
  }

  /// GET PAYMENT STATUS TEXT
  static String getPaymentStatusText(String status) {
    return _getPaymentStatusTextFromString(status);
  }

  /// GET PAYMENT METHOD DISPLAY NAME
  static String getPaymentMethodDisplayName(String method) {
    switch (method.toLowerCase()) {
      case 'ecocash':
        return 'EcoCash';
      case 'onemoney':
        return 'OneMoney';
      case 'telecash':
        return 'Telecash';
      case 'cash':
        return 'Cash';
      case 'bank_transfer':
        return 'Bank Transfer';
      case 'mobile_money':
        return 'Mobile Money';
      default:
        return method;
    }
  }

  /// VALIDATE PHONE NUMBER
  static bool isValidPhoneNumber(String phone) {
    // Simple validation for Zimbabwean numbers
    if (phone.isEmpty) return false;

    // Remove spaces and special characters
    final cleanPhone = phone.replaceAll(RegExp(r'[^0-9+]'), '');

    // Check if starts with +263 or 0
    if (cleanPhone.startsWith('+263')) {
      return cleanPhone.length == 13; // +263XXXXXXXXX
    } else if (cleanPhone.startsWith('0')) {
      return cleanPhone.length == 10; // 0XXXXXXXXX
    } else if (cleanPhone.startsWith('263')) {
      return cleanPhone.length == 12; // 263XXXXXXXXX
    }

    return false;
  }

  /// FORMAT PHONE NUMBER
  static String formatPhoneNumber(String phone) {
    if (phone.isEmpty) return phone;

    final cleanPhone = phone.replaceAll(RegExp(r'[^0-9+]'), '');

    if (cleanPhone.startsWith('+263')) {
      return cleanPhone;
    } else if (cleanPhone.startsWith('263')) {
      return '+$cleanPhone';
    } else if (cleanPhone.startsWith('0') && cleanPhone.length == 10) {
      return '+263${cleanPhone.substring(1)}';
    }

    return phone;
  }

  /// NAVIGATE TO PAYMENT DETAILS
  static void navigateToPaymentDetails({
    required String paymentId,
    required BuildContext context,
  }) {
    Get.toNamed('/payment-details/$paymentId');
  }

  /// NAVIGATE TO SELECT PAYMENT METHOD
  static void navigateToSelectPaymentMethod({
    required String bidId,
    required double amount,
    required BuildContext context,
  }) {
    Get.toNamed(
      '/select-payment-method',
      arguments: {'bidId': bidId, 'amount': amount},
    );
  }

  /// CHECK IF PAYMENT CAN BE MADE
  static bool canMakePayment(dynamic bid) {
    // Payment can be made if:
    // 1. Auction is closed
    // 2. Bid is won
    // 3. Bid is not fully paid
    final auctionStatus =
        bid.auction.status?.toString().toLowerCase() ?? 'draft';
    final paymentStatus =
        bid.paymentStatus?.toString().toLowerCase() ?? 'unpaid';

    // Check if bid is won
    final isWon = _isBidWon(bid);

    return auctionStatus == 'closed' &&
        isWon &&
        paymentStatus != 'paid' &&
        paymentStatus != 'partially_paid';
  }

  /// HELPER: Check if bid is won
  static bool _isBidWon(dynamic bid) {
    final auctionStatus =
        bid.auction.status?.toString().toLowerCase() ?? 'draft';
    final bidderId = bid.bidder?.id;

    if (auctionStatus == 'closed') {
      return bid.auction.winnerUser != null &&
          bid.auction.winnerUser?.id == bidderId;
    }
    return false;
  }

  /// HELPER: Get payment status from string
  static PaymentStatus _getPaymentStatusFromString(String status) {
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

  /// HELPER: Get payment status text from string
  static String _getPaymentStatusTextFromString(String status) {
    switch (status.toLowerCase()) {
      case 'success':
        return 'Successful';
      case 'failed':
        return 'Failed';
      case 'refunded':
        return 'Refunded';
      case 'initiated':
        return 'Initiated';
      case 'processing':
        return 'Processing';
      case 'cancelled':
        return 'Cancelled';
      default:
        return 'Pending';
    }
  }

  /// CHECK IF PAYMENT IS PENDING
  static bool isPaymentPending(BidPayment payment) {
    return payment.status == PaymentStatus.pending ||
        payment.status == PaymentStatus.initiated ||
        payment.status == PaymentStatus.processing;
  }

  /// CHECK IF PAYMENT IS SUCCESSFUL
  static bool isPaymentSuccessful(BidPayment payment) {
    return payment.status == PaymentStatus.success;
  }

  /// CHECK IF PAYMENT IS FAILED
  static bool isPaymentFailed(BidPayment payment) {
    return payment.status == PaymentStatus.failed ||
        payment.status == PaymentStatus.cancelled;
  }

  /// GET PAYMENT STATUS BADGE COLOR
  static Color getPaymentStatusBadgeColor(PaymentStatus status) {
    switch (status) {
      case PaymentStatus.success:
        return RealTimeColors.success;
      case PaymentStatus.failed:
        return RealTimeColors.error;
      case PaymentStatus.cancelled:
        return RealTimeColors.grey600;
      case PaymentStatus.refunded:
        return RealTimeColors.grey500;
      case PaymentStatus.pending:
      case PaymentStatus.initiated:
      case PaymentStatus.processing:
        return RealTimeColors.warning;
      default:
        return RealTimeColors.grey400;
    }
  }

  /// GET PAYMENT STATUS ICON
  static IconData getPaymentStatusIcon(PaymentStatus status) {
    switch (status) {
      case PaymentStatus.success:
        return Icons.check_circle;
      case PaymentStatus.failed:
        return Icons.error;
      case PaymentStatus.cancelled:
        return Icons.cancel;
      case PaymentStatus.refunded:
        return Icons.refresh;
      case PaymentStatus.pending:
      case PaymentStatus.initiated:
      case PaymentStatus.processing:
        return Icons.pending;
      default:
        return Icons.info;
    }
  }

  /// GET PAYMENT STATUS BADGE TEXT
  static String getPaymentStatusBadgeText(PaymentStatus status) {
    return _getPaymentStatusTextFromString(status.toString().split('.').last);
  }

  /// GET PAYMENT METHOD ICON
  static IconData getPaymentMethodIcon(String method) {
    switch (method.toLowerCase()) {
      case 'ecocash':
        return Icons.phone_android;
      case 'onemoney':
        return Icons.account_balance_wallet;
      case 'telecash':
        return Icons.phone_iphone;
      case 'cash':
        return Icons.money;
      case 'bank_transfer':
        return Icons.account_balance;
      case 'mobile_money':
        return Icons.mobile_friendly;
      default:
        return Icons.payment;
    }
  }
}
