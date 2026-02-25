// support_mngmt_helper.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:real_time_pawn/core/utils/pallete.dart';
import 'package:real_time_pawn/features/support_mngmt/controllers/support_mngmt_controller.dart';
import 'package:real_time_pawn/models/support_ticket_model.dart';

class SupportTicketHelper {
  static final SupportTicketController _controller = Get.put(
    SupportTicketController(),
  );

  /// CREATE NEW TICKET
  static Future<bool> createNewTicket({
    required String subject,
    required String description,
    required TicketCategory category,
    required TicketPriority priority,
  }) async {
    final success = await _controller.createTicket(
      subject: subject,
      description: description,
      category: category,
      priority: priority,
    );

    if (success) {
      showSuccess(_controller.successMessage.value);
      return true;
    } else {
      showError(_controller.errorMessage.value);
      return false;
    }
  }

  /// GET CUSTOMER TICKETS
  static Future<bool> getCustomerTickets({
    required String customerId,
    int page = 1,
    int limit = 10,
    bool showLoader = true,
  }) async {
    if (customerId.isEmpty) {
      showError('Unable to load tickets: No customer ID found');
      return false;
    }

    if (showLoader) {
      showLoading('Loading tickets...');
    }

    try {
      final success = await _controller.getCustomerTickets(
        customerId: customerId,
        page: page,
        limit: limit,
      );

      if (showLoader) {
        Get.back();
      }

      if (success) {
        if (!showLoader) {
          showSuccess('Tickets loaded successfully');
        }
        return true;
      } else {
        showError(_controller.errorMessage.value);
        return false;
      }
    } catch (e) {
      if (showLoader) {
        Get.back();
      }
      showError('Failed to load tickets: ${e.toString()}');
      return false;
    }
  }

  /// GET TICKET BY ID
  static Future<bool> getTicketById(String ticketId) async {
    showLoading('Loading ticket details...');

    try {
      final success = await _controller.getTicketById(ticketId);

      Get.back();

      if (success) {
        return true;
      } else {
        showError(_controller.errorMessage.value);
        return false;
      }
    } catch (e) {
      Get.back();
      showError('Failed to load ticket details: ${e.toString()}');
      return false;
    }
  }

  /// UPDATE TICKET
  static Future<bool> updateTicket({
    required String ticketId,
    required String subject,
    required String description,
    required TicketCategory category,
    required TicketPriority priority,
  }) async {
    showLoading('Updating ticket...');

    try {
      final success = await _controller.updateTicket(
        ticketId: ticketId,
        subject: subject,
        description: description,
        category: category,
        priority: priority,
      );

      Get.back();

      if (success) {
        showSuccess(_controller.successMessage.value);
        return true;
      } else {
        showError(_controller.errorMessage.value);
        return false;
      }
    } catch (e) {
      Get.back();
      showError('Failed to update ticket: ${e.toString()}');
      return false;
    }
  }

  /// ADD ATTACHMENT
  static Future<bool> addAttachment({
    required String ticketId,
    required String attachmentId,
  }) async {
    showLoading('Adding attachment...');

    try {
      final success = await _controller.addAttachment(
        ticketId: ticketId,
        attachmentId: attachmentId,
      );

      Get.back();

      if (success) {
        showSuccess('Attachment added successfully');
        return true;
      } else {
        showError(_controller.errorMessage.value);
        return false;
      }
    } catch (e) {
      Get.back();
      showError('Failed to add attachment: ${e.toString()}');
      return false;
    }
  }

  /// SEARCH TICKETS
  static Future<List<SupportTicket>?> searchTickets(String query) async {
    if (query.length < 2) {
      showError('Search term must be at least 2 characters');
      return null;
    }

    showLoading('Searching tickets...');

    try {
      final success = await _controller.searchTickets(query);

      Get.back();

      if (success) {
        return _controller.tickets;
      } else {
        showError(_controller.errorMessage.value);
        return null;
      }
    } catch (e) {
      Get.back();
      showError('Failed to search tickets: ${e.toString()}');
      return null;
    }
  }

  /// SHOW LOADING DIALOG
  static void showLoading(String message) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (Get.isDialogOpen != true) {
        Get.dialog(
          Dialog(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircularProgressIndicator(color: AppColors.primaryColor),
                  const SizedBox(width: 20),
                  Text(
                    message,
                    style: TextStyle(fontSize: 16, color: AppColors.textColor),
                  ),
                ],
              ),
            ),
          ),
          barrierDismissible: false,
        );
      }
    });
  }

  /// SHOW CONFIRMATION DIALOG
  static Future<bool> showConfirmationDialog({
    required String title,
    required String message,
    String confirmText = 'Confirm',
    String cancelText = 'Cancel',
  }) async {
    final result = await Get.dialog<bool>(
      AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: Text(cancelText),
          ),
          TextButton(
            onPressed: () => Get.back(result: true),
            child: Text(
              confirmText,
              style: TextStyle(color: AppColors.primaryColor),
            ),
          ),
        ],
      ),
    );

    return result ?? false;
  }

  /// SHOW ERROR MESSAGE
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
        duration: const Duration(seconds: 3),
      );
    });
  }

  /// SHOW SUCCESS MESSAGE
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
        duration: const Duration(seconds: 2),
      );
    });
  }

  /// VALIDATE TICKET FORM
  static String? validateTicketForm({
    required String subject,
    required String description,
  }) {
    if (subject.isEmpty) {
      return 'Please enter a subject';
    }

    if (subject.length < 5) {
      return 'Subject must be at least 5 characters';
    }

    if (description.isEmpty) {
      return 'Please enter a description';
    }

    if (description.length < 10) {
      return 'Description must be at least 10 characters';
    }

    return null;
  }

  /// NAVIGATE TO CREATE TICKET
  static void navigateToCreateTicket() {
    Get.toNamed('/create-ticket');
  }

  /// NAVIGATE TO TICKET DETAILS
  static void navigateToTicketDetails(String ticketId) {
    Get.toNamed('/ticket-details/$ticketId');
  }
}
