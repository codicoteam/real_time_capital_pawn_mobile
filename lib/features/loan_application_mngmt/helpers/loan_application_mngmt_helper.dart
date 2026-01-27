import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:real_time_pawn/models/loan_application.model.dart' show LoanApplicationModel;

import '../../../core/utils/api_response.dart';
import '../../../widgets/loading_widgets/circular_loader.dart';
import '../../../core/utils/pallete.dart';
import '../controllers/loan_application_mngmt_controller.dart';

class LoanApplicationResult {
  final bool success;
  final String? loanId;
  final String? applicationNo;
  final String? message;

  LoanApplicationResult({
    required this.success,
    this.loanId,
    this.applicationNo,
    this.message,
  });
}

class LoanApplicationHelper {
  static final LoanApplicationController _loanController =
      Get.find<LoanApplicationController>();

  // ============================
  // Create Loan Application
  // ============================
  static Future<LoanApplicationResult> createLoanApplication({
    required Map<String, dynamic> payload,
  }) async {
    _clearMessages();

    try {
      Get.dialog(
        const CustomLoader(message: 'Submitting loan application...'),
        barrierDismissible: false,
      );

      final APIResponse<LoanApplicationModel> response = 
          await _loanController.createLoanApplication(payload);

      if (Get.isDialogOpen ?? false) {
        Get.back();
      }

      if (response.success && response.data != null) {
        // response.data is already a LoanApplicationModel
        final loanApplication = response.data!;

        _showSuccessSnackbar(
          response.message ?? 'Loan application submitted successfully',
        );

        return LoanApplicationResult(
          success: true,
          loanId: loanApplication.id,
          applicationNo: loanApplication.applicationNo,
          message: response.message,
        );
      } else {
        _showErrorDialog(
          response.message ?? 'Failed to submit loan application',
        );
        
        return LoanApplicationResult(
          success: false,
          message: response.message,
        );
      }
    } catch (e) {
      if (Get.isDialogOpen ?? false) {
        Get.back();
      }
      
      final errorMessage =
          'An unexpected error occurred while submitting the loan application: ${e.toString()}';
      
      _showErrorDialog(errorMessage);
      
      return LoanApplicationResult(
        success: false,
        message: errorMessage,
      );
    }
  }

  // ============================
  // Update Loan Application
  // ============================
  static Future<bool> updateLoanApplication({
    required String loanApplicationId,
    required Map<String, dynamic> payload,
  }) async {
    _clearMessages();

    try {
      Get.dialog(
        const CustomLoader(message: 'Updating loan application...'),
        barrierDismissible: false,
      );

      final APIResponse response = await _loanController.updateLoanApplication(
        loanApplicationId: loanApplicationId,
        payload: payload,
      );

      if (Get.isDialogOpen ?? false) {
        Get.back();
      }

      if (response.success) {
        _showSuccessSnackbar(
          response.message ?? 'Loan application updated successfully',
        );
        return true;
      } else {
        _showErrorDialog(
          response.message ?? 'Failed to update loan application',
        );
        return false;
      }
    } catch (e) {
      if (Get.isDialogOpen ?? false) {
        Get.back();
      }
      _showErrorDialog(
        'An unexpected error occurred while updating the loan application',
      );
      return false;
    }
  }

  // ============================
  // UI Helpers
  // ============================
  static void _clearMessages() {
    _loanController.successMessage.value = '';
    _loanController.errorMessage.value = '';
  }

  static void _showSuccessSnackbar(String message) {
    Get.snackbar(
      'Success',
      message,
      backgroundColor: AppColors.successColor.withOpacity(0.1),
      colorText: AppColors.successColor,
      icon: Icon(Icons.check_circle, color: AppColors.successColor),
      snackPosition: SnackPosition.TOP,
      duration: 2.seconds,
      margin: const EdgeInsets.all(16),
      borderRadius: 12,
      isDismissible: true,
      forwardAnimationCurve: Curves.easeOutBack,
    );
  }

  static void _showErrorDialog(String message) {
    Get.defaultDialog(
      title: 'Action Failed',
      titleStyle: TextStyle(
        fontWeight: FontWeight.bold,
        color: AppColors.errorColor,
      ),
      middleText: message,
      middleTextStyle: TextStyle(color: AppColors.subtextColor),
      confirm: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.errorColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        onPressed: () => Get.back(),
        child: const Text('OK', style: TextStyle(color: Colors.white)),
      ),
      radius: 14,
    );
  }
}