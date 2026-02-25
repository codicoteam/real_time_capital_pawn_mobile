// support_mngmt_controller.dart
import 'package:get/get.dart';
import 'package:real_time_pawn/core/utils/logs.dart';
import 'package:real_time_pawn/features/support_mngmt/services/support_mngmt_service.dart';
import 'package:real_time_pawn/models/support_ticket_model.dart';

class SupportTicketController extends GetxController {
  // Loading states - ONLY for your 6 APIs
  var isCreatingTicket = false.obs;
  var isLoadingTicket = false.obs;
  var isAddingAttachment = false.obs;
  var isSearchingTickets = false.obs;

  // Data
  var tickets = <SupportTicket>[].obs;
  var selectedTicket = Rxn<SupportTicket>();

  // Messages
  var successMessage = ''.obs;
  var errorMessage = ''.obs;

  /// 1. CREATE TICKET
  Future<bool> createTicket({
    required String subject,
    required String description,
    required TicketCategory category,
    required TicketPriority priority,
  }) async {
    try {
      isCreatingTicket(true);
      clearMessages();

      final response = await SupportTicketService.createTicket(
        subject: subject,
        description: description,
        category: category,
        priority: priority,
      );

      if (response.success && response.data != null) {
        successMessage.value = 'Ticket created successfully!';
        DevLogs.logSuccess(successMessage.value);
        return true;
      } else {
        errorMessage.value = response.message ?? 'Failed to create ticket';
        DevLogs.logError(errorMessage.value);
        return false;
      }
    } catch (e) {
      errorMessage.value = 'Error creating ticket: ${e.toString()}';
      DevLogs.logError(errorMessage.value);
      return false;
    } finally {
      isCreatingTicket(false);
    }
  }

  /// 2. GET CUSTOMER TICKETS
  Future<bool> getCustomerTickets({
    required String customerId,
    int page = 1,
    int limit = 10,
  }) async {
    try {
      clearMessages();

      final response = await SupportTicketService.getCustomerTickets(
        customerId: customerId,
        page: page,
        limit: limit,
      );

      if (response.success && response.data != null) {
        tickets.value = response.data!.tickets;
        successMessage.value = 'Tickets loaded';
        return true;
      } else {
        errorMessage.value = response.message ?? 'Failed to load tickets';
        return false;
      }
    } catch (e) {
      errorMessage.value = 'Error loading tickets: ${e.toString()}';
      return false;
    }
  }

  /// 3. GET TICKET BY ID
  Future<bool> getTicketById(String ticketId) async {
    try {
      isLoadingTicket(true);
      clearMessages();

      final response = await SupportTicketService.getTicketById(ticketId);

      if (response.success && response.data != null) {
        selectedTicket.value = response.data!;
        successMessage.value = 'Ticket loaded';
        return true;
      } else {
        errorMessage.value = response.message ?? 'Failed to load ticket';
        return false;
      }
    } catch (e) {
      errorMessage.value = 'Error loading ticket: ${e.toString()}';
      return false;
    } finally {
      isLoadingTicket(false);
    }
  }

  /// 4. SEARCH TICKETS
  Future<bool> searchTickets(String query) async {
    try {
      isSearchingTickets(true);
      clearMessages();

      final response = await SupportTicketService.searchTickets(query);

      if (response.success && response.data != null) {
        tickets.value = response.data!;
        return true;
      } else {
        errorMessage.value = response.message ?? 'No tickets found';
        return false;
      }
    } catch (e) {
      errorMessage.value = 'Error searching tickets: ${e.toString()}';
      return false;
    } finally {
      isSearchingTickets(false);
    }
  }

  /// 5. ADD ATTACHMENT
  Future<bool> addAttachment({
    required String ticketId,
    required String attachmentId,
  }) async {
    try {
      isAddingAttachment(true);
      clearMessages();

      final response = await SupportTicketService.addAttachment(
        ticketId: ticketId,
        attachmentId: attachmentId,
      );

      if (response.success && response.data != null) {
        selectedTicket.value = response.data!;
        successMessage.value = 'Attachment added';
        return true;
      } else {
        errorMessage.value = response.message ?? 'Failed to add attachment';
        return false;
      }
    } catch (e) {
      errorMessage.value = 'Error adding attachment: ${e.toString()}';
      return false;
    } finally {
      isAddingAttachment(false);
    }
  }

  /// 6. UPDATE TICKET
  Future<bool> updateTicket({
    required String ticketId,
    required String subject,
    required String description,
    required TicketCategory category,
    required TicketPriority priority,
  }) async {
    try {
      isLoadingTicket(true);
      clearMessages();

      final response = await SupportTicketService.updateTicket(
        ticketId: ticketId,
        subject: subject,
        description: description,
        category: category,
        priority: priority,
      );

      if (response.success && response.data != null) {
        selectedTicket.value = response.data!;
        successMessage.value = 'Ticket updated';
        return true;
      } else {
        errorMessage.value = response.message ?? 'Failed to update ticket';
        return false;
      }
    } catch (e) {
      errorMessage.value = 'Error updating ticket: ${e.toString()}';
      return false;
    } finally {
      isLoadingTicket(false);
    }
  }

  /// CLEAR MESSAGES
  void clearMessages() {
    successMessage.value = '';
    errorMessage.value = '';
  }
}
