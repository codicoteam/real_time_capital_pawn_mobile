enum TicketStatus { open, in_progress, resolved, closed }

enum TicketPriority { low, medium, high, urgent }

enum TicketCategory { loan, payment, auction, account, technical, general }

class User {
  final String id;
  final String email;

  User({required this.id, required this.email});

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['_id']?.toString() ?? json['id']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
    );
  }
}

class SupportTicket {
  final String id;
  final String ticketNo;
  final User customerUser;
  final TicketCategory category;
  final String subject;
  final String description;
  final TicketStatus status;
  final TicketPriority priority;
  final List<String> attachments;
  final DateTime createdAt;
  final DateTime updatedAt;

  SupportTicket({
    required this.id,
    required this.ticketNo,
    required this.customerUser,
    required this.category,
    required this.subject,
    required this.description,
    required this.status,
    required this.priority,
    required this.attachments,
    required this.createdAt,
    required this.updatedAt,
  });

  factory SupportTicket.fromJson(Map<String, dynamic> json) {
    // Handle customer_user which could be a string ID or User object
    User customerUser;

    if (json['customer_user'] is String) {
      // It's just an ID string, create a basic User
      customerUser = User(
        id: json['customer_user'] as String,
        email: '', // Email might not be available
      );
    } else if (json['customer_user'] is Map) {
      // It's a User object
      customerUser = User.fromJson(
        json['customer_user'] as Map<String, dynamic>,
      );
    } else {
      // Fallback
      customerUser = User(id: '', email: '');
    }

    return SupportTicket(
      id: json['_id']?.toString() ?? json['id']?.toString() ?? '',
      ticketNo: json['ticket_no']?.toString() ?? '',
      customerUser: customerUser,
      category: _parseCategory(json['category']?.toString() ?? 'general'),
      subject: json['subject']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      status: _parseStatus(json['status']?.toString() ?? 'open'),
      priority: _parsePriority(json['priority']?.toString() ?? 'medium'),
      attachments: _parseAttachments(json['attachments']),
      createdAt: DateTime.parse(
        json['created_at']?.toString() ?? DateTime.now().toIso8601String(),
      ),
      updatedAt: DateTime.parse(
        json['updated_at']?.toString() ?? DateTime.now().toIso8601String(),
      ),
    );
  }

  static TicketCategory _parseCategory(String category) {
    switch (category.toLowerCase()) {
      case 'loan':
        return TicketCategory.loan;
      case 'payment':
        return TicketCategory.payment;
      case 'auction':
        return TicketCategory.auction;
      case 'account':
        return TicketCategory.account;
      case 'technical':
        return TicketCategory.technical;
      default:
        return TicketCategory.general;
    }
  }

  static TicketStatus _parseStatus(String status) {
    switch (status.toLowerCase()) {
      case 'in_progress':
        return TicketStatus.in_progress;
      case 'resolved':
        return TicketStatus.resolved;
      case 'closed':
        return TicketStatus.closed;
      default:
        return TicketStatus.open;
    }
  }

  static TicketPriority _parsePriority(String priority) {
    switch (priority.toLowerCase()) {
      case 'low':
        return TicketPriority.low;
      case 'high':
        return TicketPriority.high;
      case 'urgent':
        return TicketPriority.urgent;
      default:
        return TicketPriority.medium;
    }
  }

  // ✅ MOVED THIS INSIDE THE CLASS
  static List<String> _parseAttachments(dynamic attachments) {
    if (attachments == null) return [];

    // If it's already a List<String>
    if (attachments is List && attachments.every((e) => e is String)) {
      return List<String>.from(attachments);
    }

    // If it's a List of Maps (attachment objects)
    if (attachments is List) {
      return attachments.map((item) {
        if (item is String) return item;
        if (item is Map) {
          // Return the ID or URL based on what you want to display
          return item['_id']?.toString() ??
              item['url']?.toString() ??
              item.toString();
        }
        return item.toString();
      }).toList();
    }

    return [];
  }
}

class TicketResponse {
  final List<SupportTicket> tickets;
  final Pagination pagination;

  TicketResponse({required this.tickets, required this.pagination});

  factory TicketResponse.fromJson(Map<String, dynamic> json) {
    try {
      print('DEBUG: Full JSON response structure check');

      List<SupportTicket> parsedTickets = [];
      Map<String, dynamic> paginationData = {};

      // Check if 'data' exists
      if (json['data'] != null) {
        print('DEBUG: data field exists, type: ${json['data'].runtimeType}');

        if (json['data'] is List) {
          // CASE 1: data is a List of tickets directly (your API's actual response)
          print('DEBUG: data is a List (direct tickets array)');
          parsedTickets = List<SupportTicket>.from(
            (json['data'] as List).map((x) => SupportTicket.fromJson(x)),
          );
          print(
            'DEBUG: Parsed ${parsedTickets.length} tickets from direct list',
          );
        } else if (json['data'] is Map) {
          // CASE 2: data is a Map (old structure with tickets and pagination)
          final data = json['data'] as Map<String, dynamic>;
          print('DEBUG: data is a Map with keys: ${data.keys}');

          if (data['tickets'] != null && data['tickets'] is List) {
            parsedTickets = List<SupportTicket>.from(
              (data['tickets'] as List).map((x) => SupportTicket.fromJson(x)),
            );
            print(
              'DEBUG: Parsed ${parsedTickets.length} tickets from tickets field',
            );
          }

          if (data['pagination'] != null && data['pagination'] is Map) {
            paginationData = data['pagination'] as Map<String, dynamic>;
            print('DEBUG: Found pagination data: $paginationData');
          }
        }
      } else {
        // CASE 3: No data field, maybe tickets are directly in response
        print('DEBUG: No data field, checking root level');

        if (json['tickets'] != null && json['tickets'] is List) {
          parsedTickets = List<SupportTicket>.from(
            (json['tickets'] as List).map((x) => SupportTicket.fromJson(x)),
          );
          print(
            'DEBUG: Parsed ${parsedTickets.length} tickets from root tickets',
          );
        }

        if (json['pagination'] != null && json['pagination'] is Map) {
          paginationData = json['pagination'] as Map<String, dynamic>;
          print('DEBUG: Found pagination at root: $paginationData');
        }
      }

      // If we have tickets but no pagination in response, create default pagination
      if (paginationData.isEmpty && parsedTickets.isNotEmpty) {
        print('DEBUG: No pagination in response, creating default');
        paginationData = {
          'page': 1,
          'limit': parsedTickets.length,
          'total': parsedTickets.length,
          'pages': 1,
        };
      }

      // Create pagination from data or defaults
      final pagination = Pagination.fromJson(paginationData);

      print(
        'DEBUG: Final result - ${parsedTickets.length} tickets, pagination: $pagination',
      );

      return TicketResponse(tickets: parsedTickets, pagination: pagination);
    } catch (e) {
      print('ERROR in TicketResponse.fromJson: $e');
      print('ERROR JSON was: $json');
      return TicketResponse(
        tickets: [],
        pagination: Pagination(page: 1, limit: 10, total: 0, pages: 0),
      );
    }
  }
}

class Pagination {
  final int page;
  final int limit;
  final int total;
  final int pages;

  Pagination({
    required this.page,
    required this.limit,
    required this.total,
    required this.pages,
  });

  factory Pagination.fromJson(Map<String, dynamic> json) {
    try {
      return Pagination(
        page: int.tryParse((json['page'] ?? '1').toString()) ?? 1,
        limit: int.tryParse((json['limit'] ?? '10').toString()) ?? 10,
        total: int.tryParse((json['total'] ?? '0').toString()) ?? 0,
        pages: int.tryParse((json['pages'] ?? '1').toString()) ?? 1,
      );
    } catch (e) {
      print('ERROR in Pagination.fromJson: $e');
      print('ERROR JSON was: $json');
      return Pagination(page: 1, limit: 10, total: 0, pages: 0);
    }
  }
}
