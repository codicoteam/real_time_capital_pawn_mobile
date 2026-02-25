import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:real_time_pawn/core/utils/logs.dart';
import 'package:real_time_pawn/core/utils/api_response.dart';
import 'package:real_time_pawn/core/utils/shared_pref_methods.dart';
import 'package:real_time_pawn/models/support_ticket_model.dart';
import '../../../../config/api_config/api_keys.dart';

class SupportTicketService {
  /// 1. CREATE TICKET
  /// POST /api/v1/support-tickets
  static Future<APIResponse<SupportTicket>> createTicket({
    required String subject,
    required String description,
    required TicketCategory category,
    required TicketPriority priority,
    Map<String, dynamic>? meta,
  }) async {
    final token = await CacheUtils.checkToken();
    if (token == null || token.isEmpty) {
      return APIResponse(
        success: false,
        message: 'Authentication required',
        data: null,
      );
    }

    final headers = {
      'accept': 'application/json',
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
    };

    final body = json.encode({
      'subject': subject,
      'description': description,
      'category': category.name,
      'priority': priority.name,
      'meta': meta ?? {},
    });

    // FIXED: Removed /api/v1/ since baseUrl already has it
    final uri = Uri.parse('${ApiKeys.baseUrl}/support-tickets');

    DevLogs.logInfo('Creating support ticket: $uri');

    try {
      final response = await http.post(uri, headers: headers, body: body);
      final responseData = json.decode(response.body);

      DevLogs.logInfo('Create ticket response: ${response.statusCode}');

      if (response.statusCode >= 200 && response.statusCode < 300) {
        if (responseData['success'] == true) {
          final ticket = SupportTicket.fromJson(responseData['data']);
          return APIResponse(
            success: true,
            data: ticket,
            message: responseData['message'] ?? 'Ticket created successfully',
          );
        }
      }

      return APIResponse(
        success: false,
        message: responseData['message'] ?? 'Failed to create ticket',
        data: null,
      );
    } catch (e) {
      DevLogs.logError('Error creating ticket: $e');
      return APIResponse(
        success: false,
        message: 'Error creating ticket: ${e.toString()}',
        data: null,
      );
    }
  }

  /// 2. GET CUSTOMER TICKETS
  /// GET /api/v1/support-tickets/customer/{customerId}
  static Future<APIResponse<TicketResponse>> getCustomerTickets({
    required String customerId,
    int page = 1,
    int limit = 10,
    String? status,
    String? priority,
    String? category,
    String? search,
    String sortBy = 'created_at',
    String sortOrder = 'desc',
  }) async {
    final token = await CacheUtils.checkToken();
    if (token == null || token.isEmpty) {
      return APIResponse(
        success: false,
        message: 'Authentication required',
        data: null,
      );
    }

    final headers = {
      'accept': 'application/json',
      'Authorization': 'Bearer $token',
    };

    final params = <String, String>{
      'page': page.toString(),
      'limit': limit.toString(),
      'sort_by': sortBy,
      'sort_order': sortOrder,
      if (status != null && status.isNotEmpty) 'status': status,
      if (priority != null && priority.isNotEmpty) 'priority': priority,
      if (category != null && category.isNotEmpty) 'category': category,
      if (search != null && search.isNotEmpty && search.length >= 2)
        'search': search,
    };

    // FIXED: Removed /api/v1/ since baseUrl already has it
    final uri = Uri.parse(
      '${ApiKeys.baseUrl}/support-tickets/customer/$customerId',
    ).replace(queryParameters: params);

    DevLogs.logInfo('Fetching customer tickets: $uri');

    try {
      final response = await http.get(uri, headers: headers);
      final responseData = json.decode(response.body);

      DevLogs.logInfo('Get customer tickets response: ${response.statusCode}');

      if (response.statusCode >= 200 && response.statusCode < 300) {
        if (responseData['success'] == true) {
          final ticketResponse = TicketResponse.fromJson(responseData);
          return APIResponse(
            success: true,
            data: ticketResponse,
            message:
                responseData['message'] ?? 'Tickets retrieved successfully',
          );
        }
      }

      return APIResponse(
        success: false,
        message: responseData['message'] ?? 'Failed to fetch tickets',
        data: null,
      );
    } catch (e) {
      DevLogs.logError('Error fetching customer tickets: $e');
      return APIResponse(
        success: false,
        message: 'Error fetching tickets: ${e.toString()}',
        data: null,
      );
    }
  }

  /// 3. GET TICKET BY ID
  /// GET /api/v1/support-tickets/{id}
  static Future<APIResponse<SupportTicket>> getTicketById(
    String ticketId,
  ) async {
    final token = await CacheUtils.checkToken();
    if (token == null || token.isEmpty) {
      return APIResponse(
        success: false,
        message: 'Authentication required',
        data: null,
      );
    }

    final headers = {
      'accept': 'application/json',
      'Authorization': 'Bearer $token',
    };

    // FIXED: Removed /api/v1/ since baseUrl already has it
    final uri = Uri.parse('${ApiKeys.baseUrl}/support-tickets/$ticketId');

    DevLogs.logInfo('Fetching ticket details: $uri');

    try {
      final response = await http.get(uri, headers: headers);
      final responseData = json.decode(response.body);

      DevLogs.logInfo('Get ticket response: ${response.statusCode}');

      if (response.statusCode >= 200 && response.statusCode < 300) {
        if (responseData['success'] == true) {
          final ticket = SupportTicket.fromJson(responseData['data']);
          return APIResponse(
            success: true,
            data: ticket,
            message: responseData['message'] ?? 'Ticket retrieved successfully',
          );
        }
      }

      return APIResponse(
        success: false,
        message: responseData['message'] ?? 'Failed to fetch ticket',
        data: null,
      );
    } catch (e) {
      DevLogs.logError('Error fetching ticket: $e');
      return APIResponse(
        success: false,
        message: 'Error fetching ticket: ${e.toString()}',
        data: null,
      );
    }
  }

  /// 4. SEARCH TICKETS
  /// GET /api/v1/support-tickets/search
  static Future<APIResponse<List<SupportTicket>>> searchTickets(
    String query,
  ) async {
    final token = await CacheUtils.checkToken();
    if (token == null || token.isEmpty) {
      return APIResponse(
        success: false,
        message: 'Authentication required',
        data: null,
      );
    }

    if (query.length < 2) {
      return APIResponse(
        success: false,
        message: 'Search term must be at least 2 characters',
        data: null,
      );
    }

    final headers = {
      'accept': 'application/json',
      'Authorization': 'Bearer $token',
    };

    // FIXED: Removed /api/v1/ since baseUrl already has it
    final uri = Uri.parse(
      '${ApiKeys.baseUrl}/support-tickets/search',
    ).replace(queryParameters: {'q': query});

    DevLogs.logInfo('Searching tickets: $uri');

    try {
      final response = await http.get(uri, headers: headers);
      final responseData = json.decode(response.body);

      DevLogs.logInfo('Search tickets response: ${response.statusCode}');

      if (response.statusCode >= 200 && response.statusCode < 300) {
        if (responseData['success'] == true) {
          final tickets = List<SupportTicket>.from(
            (responseData['data'] as List).map(
              (x) => SupportTicket.fromJson(x),
            ),
          );
          return APIResponse(
            success: true,
            data: tickets,
            message: responseData['message'] ?? 'Search completed',
          );
        }
      }

      return APIResponse(
        success: false,
        message: responseData['message'] ?? 'No tickets found',
        data: null,
      );
    } catch (e) {
      DevLogs.logError('Error searching tickets: $e');
      return APIResponse(
        success: false,
        message: 'Error searching tickets: ${e.toString()}',
        data: null,
      );
    }
  }

  /// 5. ADD ATTACHMENT
  /// POST /api/v1/support-tickets/{id}/attachments
  static Future<APIResponse<SupportTicket>> addAttachment({
    required String ticketId,
    required String attachmentId,
  }) async {
    final token = await CacheUtils.checkToken();
    if (token == null || token.isEmpty) {
      return APIResponse(
        success: false,
        message: 'Authentication required',
        data: null,
      );
    }

    final headers = {
      'accept': 'application/json',
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
    };

    final body = json.encode({'attachment_id': attachmentId});

    // FIXED: Removed /api/v1/ since baseUrl already has it
    final uri = Uri.parse(
      '${ApiKeys.baseUrl}/support-tickets/$ticketId/attachments',
    );

    DevLogs.logInfo('Adding attachment: $uri');

    try {
      final response = await http.post(uri, headers: headers, body: body);
      final responseData = json.decode(response.body);

      DevLogs.logInfo('Add attachment response: ${response.statusCode}');

      if (response.statusCode >= 200 && response.statusCode < 300) {
        if (responseData['success'] == true) {
          final ticket = SupportTicket.fromJson(responseData['data']);
          return APIResponse(
            success: true,
            data: ticket,
            message: responseData['message'] ?? 'Attachment added successfully',
          );
        }
      }

      return APIResponse(
        success: false,
        message: responseData['message'] ?? 'Failed to add attachment',
        data: null,
      );
    } catch (e) {
      DevLogs.logError('Error adding attachment: $e');
      return APIResponse(
        success: false,
        message: 'Error adding attachment: ${e.toString()}',
        data: null,
      );
    }
  }

  /// 6. UPDATE TICKET
  /// PUT /api/v1/support-tickets/{id}
  static Future<APIResponse<SupportTicket>> updateTicket({
    required String ticketId,
    required String subject,
    required String description,
    required TicketCategory category,
    required TicketPriority priority,
  }) async {
    final token = await CacheUtils.checkToken();
    if (token == null || token.isEmpty) {
      return APIResponse(
        success: false,
        message: 'Authentication required',
        data: null,
      );
    }

    final headers = {
      'accept': 'application/json',
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
    };

    final body = json.encode({
      'subject': subject,
      'description': description,
      'category': category.name,
      'priority': priority.name,
    });

    // FIXED: Removed /api/v1/ since baseUrl already has it
    final uri = Uri.parse('${ApiKeys.baseUrl}/support-tickets/$ticketId');

    DevLogs.logInfo('Updating ticket: $uri');

    try {
      final response = await http.put(uri, headers: headers, body: body);
      final responseData = json.decode(response.body);

      DevLogs.logInfo('Update ticket response: ${response.statusCode}');

      if (response.statusCode >= 200 && response.statusCode < 300) {
        if (responseData['success'] == true) {
          final ticket = SupportTicket.fromJson(responseData['data']);
          return APIResponse(
            success: true,
            data: ticket,
            message: responseData['message'] ?? 'Ticket updated successfully',
          );
        }
      }

      return APIResponse(
        success: false,
        message: responseData['message'] ?? 'Failed to update ticket',
        data: null,
      );
    } catch (e) {
      DevLogs.logError('Error updating ticket: $e');
      return APIResponse(
        success: false,
        message: 'Error updating ticket: ${e.toString()}',
        data: null,
      );
    }
  }
}
