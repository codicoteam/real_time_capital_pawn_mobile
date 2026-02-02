// loan_terms_mngmt_helper.dart
// lib/features/loan_terms_mngmt/helpers/loan_terms_helper.dart
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:real_time_pawn/features/loan_terms_mngmt/controllers/loan_terms_mngmt_controller.dart';
import 'package:real_time_pawn/models/loan_terms_model.dart';
import 'package:real_time_pawn/widgets/loading_widgets/circular_loader.dart';

class LoanTermsHelper {
  static final LoanTermsController _controller =
      Get.find<LoanTermsController>();

  /// Validate renewal form
  static Map<String, String>? validateRenewalForm({
    required String principal,
    required String extensionDays,
    String? interestRate,
    String? reason,
  }) {
    final errors = <String, String>{};

    // Principal validation
    if (principal.isEmpty) {
      errors['principal'] = 'Principal amount is required';
    } else {
      final principalValue = double.tryParse(principal);
      if (principalValue == null) {
        errors['principal'] = 'Please enter a valid amount';
      } else if (principalValue <= 0) {
        errors['principal'] = 'Amount must be greater than zero';
      }
    }

    // Extension days validation
    if (extensionDays.isEmpty) {
      errors['extensionDays'] = 'Extension days are required';
    } else {
      final daysValue = int.tryParse(extensionDays);
      if (daysValue == null) {
        errors['extensionDays'] = 'Please enter valid number of days';
      } else if (daysValue < 1) {
        errors['extensionDays'] = 'Minimum 1 day required';
      } else if (daysValue > 365) {
        errors['extensionDays'] = 'Maximum 365 days allowed';
      }
    }

    // Interest rate validation (optional)
    if (interestRate != null && interestRate.isNotEmpty) {
      final rateValue = double.tryParse(interestRate);
      if (rateValue == null) {
        errors['interestRate'] = 'Please enter a valid interest rate';
      } else if (rateValue <= 0) {
        errors['interestRate'] = 'Interest rate must be greater than zero';
      } else if (rateValue > 50) {
        errors['interestRate'] = 'Interest rate cannot exceed 50%';
      }
    }

    // Reason validation (optional but recommended)
    if (reason != null && reason.isEmpty) {
      errors['reason'] = 'Please provide a reason for renewal';
    }

    return errors.isEmpty ? null : errors;
  }

  /// Calculate renewal details
  static Map<String, dynamic> calculateRenewal({
    required double principal,
    required int extensionDays,
    required double interestRate,
    String renewalType = 'full',
  }) {
    // Calculate interest amount
    final interestAmount = (principal * interestRate) / 100;

    // Calculate total amount
    final totalAmount = principal + interestAmount;

    // Calculate daily interest
    final dailyInterest = interestAmount / extensionDays;

    // Calculate new end date (assuming renewal starts now)
    final newEndDate = DateTime.now().add(Duration(days: extensionDays));

    return {
      'principal': principal,
      'extension_days': extensionDays,
      'interest_rate': interestRate,
      'interest_amount': interestAmount,
      'total_amount': totalAmount,
      'daily_interest': dailyInterest,
      'new_end_date': newEndDate,
      'renewal_type': renewalType,
    };
  }

  /// Show renewal calculation result
  static void showCalculationResult(Map<String, dynamic> calculation) {
    Get.defaultDialog(
      title: 'Renewal Calculation',
      titleStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildCalculationRow(
            'Principal',
            'ZWL ${calculation['principal'].toStringAsFixed(2)}',
          ),
          _buildCalculationRow(
            'Extension Days',
            '${calculation['extension_days']} days',
          ),
          _buildCalculationRow(
            'Interest Rate',
            '${calculation['interest_rate'].toStringAsFixed(2)}%',
          ),
          _buildCalculationRow(
            'Interest Amount',
            'ZWL ${calculation['interest_amount'].toStringAsFixed(2)}',
          ),
          const Divider(),
          _buildCalculationRow(
            'Total Amount',
            'ZWL ${calculation['total_amount'].toStringAsFixed(2)}',
            isTotal: true,
          ),
          const SizedBox(height: 8),
          Text(
            'New term will end on: ${_formatDate(calculation['new_end_date'])}',
            style: const TextStyle(fontSize: 12, color: Colors.grey),
          ),
        ],
      ),
      confirm: ElevatedButton(
        onPressed: () => Get.back(),
        child: const Text('OK'),
      ),
      radius: 12,
    );
  }

  static Widget _buildCalculationRow(
    String label,
    String value, {
    bool isTotal = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: isTotal ? 16 : 14,
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: isTotal ? 16 : 14,
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
              color: isTotal ? Colors.green : Colors.black,
            ),
          ),
        ],
      ),
    );
  }

  static String _formatDate(DateTime date) {
    final monthNames = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return '${date.day} ${monthNames[date.month - 1]} ${date.year}';
  }

  /// Submit renewal request with validation
  static Future<bool> submitRenewalRequest({
    required String loanId,
    required String currentTermId,
    required String principal,
    required String extensionDays,
    required String renewalType,
    String? interestRate,
    String? reason,
    String? notes,
  }) async {
    // Validate form
    final errors = validateRenewalForm(
      principal: principal,
      extensionDays: extensionDays,
      interestRate: interestRate,
      reason: reason,
    );

    if (errors != null) {
      // Show validation errors
      errors.forEach((field, message) {
        Get.snackbar(
          'Validation Error',
          message,
          backgroundColor: Colors.red[50],
          colorText: Colors.red[700],
          snackPosition: SnackPosition.TOP,
        );
      });
      return false;
    }

    // Show loading dialog
    Get.dialog(
      const CustomLoader(message: 'Submitting renewal request...'),
      barrierDismissible: false,
    );

    try {
      final request = RenewalRequest(
        loanId: loanId,
        currentTermId: currentTermId,
        newPrincipal: double.parse(principal),
        extensionDays: int.parse(extensionDays),
        renewalType: renewalType,
        notes: notes,
        reason: reason,
        interestRate: interestRate != null ? double.parse(interestRate) : null,
      );

      final success = await _controller.requestLoanRenewal(request);

      // Close loader
      if (Get.isDialogOpen ?? false) {
        Get.back();
      }

      if (success) {
        // Show success message
        Get.snackbar(
          'Success',
          'Renewal request submitted successfully',
          backgroundColor: Colors.green[50],
          colorText: Colors.green[700],
          snackPosition: SnackPosition.TOP,
          duration: const Duration(seconds: 3),
        );
        return true;
      } else {
        return false;
      }
    } catch (e) {
      if (Get.isDialogOpen ?? false) {
        Get.back();
      }

      Get.snackbar(
        'Error',
        'Failed to submit renewal request: ${e.toString()}',
        backgroundColor: Colors.red[50],
        colorText: Colors.red[700],
        snackPosition: SnackPosition.TOP,
      );
      return false;
    }
  }

  /// Format term type for display
  static String formatTermType(String termType) {
    switch (termType.toLowerCase()) {
      case 'initial':
        return 'Initial Term';
      case 'renewal':
        return 'Renewal';
      case 'extension':
        return 'Interest Extension';
      case 'partial_renewal':
        return 'Partial Renewal';
      case 'settlement':
        return 'Full Settlement';
      default:
        return termType;
    }
  }

  /// Get status color
  static Color getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'active':
        return const Color(0xFF10B981); // Green
      case 'approved':
        return const Color(0xFF10B981).withOpacity(0.8);
      case 'pending':
        return const Color(0xFFF59E0B); // Amber
      case 'completed':
        return const Color(0xFF3B82F6); // Blue
      case 'rejected':
        return const Color(0xFFEF4444); // Red
      default:
        return const Color(0xFF6B7280); // Gray
    }
  }

  /// Get term type color
  static Color getTermTypeColor(String termType) {
    switch (termType.toLowerCase()) {
      case 'initial':
        return const Color(0xFF8B5CF6); // Violet
      case 'renewal':
        return const Color(0xFF10B981); // Green
      case 'extension':
        return const Color(0xFFF59E0B); // Amber
      case 'partial_renewal':
        return const Color(0xFF3B82F6); // Blue
      case 'settlement':
        return const Color(0xFFEF4444); // Red
      default:
        return const Color(0xFF6B7280); // Gray
    }
  }

  /// Format date for display
  static String formatDate(DateTime date, {bool withTime = false}) {
    final format = withTime ? 'dd MMM yyyy, HH:mm' : 'dd MMM yyyy';
    return DateFormat(format).format(date);
  }

  /// Format amount for display
  static String formatAmount(double amount) {
    return 'ZWL ${amount.toStringAsFixed(2)}';
  }

  /// Check if term can be renewed
  static bool canRenewTerm(LoanTerm term) {
    return term.isActive ||
        (term.status.toLowerCase() == 'pending' &&
            term.termType.toLowerCase() != 'settlement');
  }

  /// Get renewal eligibility message
  static String getRenewalEligibilityMessage(LoanTerm term) {
    if (!canRenewTerm(term)) {
      if (term.isCompleted) {
        return 'This term is already completed and cannot be renewed.';
      } else if (term.isRejected) {
        return 'This term was rejected and cannot be renewed.';
      } else if (term.termType.toLowerCase() == 'settlement') {
        return 'Settlement terms cannot be renewed.';
      } else {
        return 'This term is not eligible for renewal.';
      }
    }

    final daysUntilEnd = term.endDate.difference(DateTime.now()).inDays;

    if (daysUntilEnd > 7) {
      return 'You can renew this term. Current term ends in $daysUntilEnd days.';
    } else if (daysUntilEnd > 0) {
      return 'Renewal recommended. Term ends in $daysUntilEnd days.';
    } else {
      return 'Term has expired. Please renew immediately.';
    }
  }
}
