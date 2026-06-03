class ChatParticipant {
  final String id;
  final String firstName;
  final String lastName;
  final List<String> roles;
  final String? profilePicUrl;
  final String? email;

  const ChatParticipant({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.roles,
    this.profilePicUrl,
    this.email,
  });

  factory ChatParticipant.fromMap(Map<String, dynamic> map) {
    return ChatParticipant(
      id: map['_id']?.toString() ?? '',
      firstName: map['first_name']?.toString() ?? '',
      lastName: map['last_name']?.toString() ?? '',
      roles: List<String>.from(map['roles'] ?? []),
      profilePicUrl: map['profile_pic_url']?.toString(),
      email: map['email']?.toString(),
    );
  }

  String get fullName => '$firstName $lastName'.trim();

  String get initials {
    final f = firstName.isNotEmpty ? firstName[0].toUpperCase() : '';
    final l = lastName.isNotEmpty ? lastName[0].toUpperCase() : '';
    return '$f$l';
  }

  String get roleLabel {
    if (roles.isEmpty) return '';
    switch (roles.first) {
      case 'loan_officer_processor':
        return 'Loan Processor';
      case 'loan_officer_approval':
        return 'Loan Approver';
      case 'super_admin_vendor':
        return 'Super Admin';
      case 'admin_pawn_limited':
        return 'Admin';
      case 'agent':
        return 'Agent';
      case 'customer':
        return 'Customer';
      default:
        return roles.first
            .replaceAll('_', ' ')
            .split(' ')
            .map(
              (w) => w.isEmpty
                  ? ''
                  : '${w[0].toUpperCase()}${w.substring(1)}',
            )
            .join(' ');
    }
  }
}

class ChatMessage {
  final String id;
  final ChatParticipant sender;
  final String content;
  final List<String> imagesUrl;
  final List<String> imageNames;
  final String messageType;
  final List<String> readBy;
  final bool isDeleted;
  final DateTime sentAt;

  const ChatMessage({
    required this.id,
    required this.sender,
    required this.content,
    required this.imagesUrl,
    required this.imageNames,
    required this.messageType,
    required this.readBy,
    required this.isDeleted,
    required this.sentAt,
  });

  factory ChatMessage.fromMap(Map<String, dynamic> map) {
    final senderData = map['sender'];
    // socket.io returns Map<dynamic,dynamic>; accept any Map type
    final sender = senderData is Map
        ? ChatParticipant.fromMap(Map<String, dynamic>.from(senderData))
        : ChatParticipant(
            id: senderData?.toString() ?? '',
            firstName: 'Unknown',
            lastName: '',
            roles: [],
          );

    return ChatMessage(
      id: map['_id']?.toString() ?? '',
      sender: sender,
      content: map['content']?.toString() ?? '',
      imagesUrl: List<String>.from(map['images_url'] ?? []),
      imageNames: List<String>.from(map['image_names'] ?? []),
      messageType: map['message_type']?.toString() ?? 'text',
      readBy: List<String>.from(
        (map['read_by'] ?? []).map((e) => e.toString()),
      ),
      isDeleted: map['is_deleted'] == true,
      sentAt: _parseDate(map['sent_at']),
    );
  }

  static DateTime _parseDate(dynamic date) {
    if (date == null) return DateTime.now();
    if (date is String) return DateTime.tryParse(date) ?? DateTime.now();
    return DateTime.now();
  }

  bool get hasImages => imagesUrl.isNotEmpty;
  bool get hasText => content.isNotEmpty;

  bool isReadBy(String userId) => readBy.contains(userId);
}

class Conversation {
  final String id;
  final List<ChatParticipant> participants;
  final List<ChatMessage> messages;
  final String? lastMessage;
  final DateTime? lastMessageAt;
  final int unreadCount;
  final bool isActive;

  const Conversation({
    required this.id,
    required this.participants,
    required this.messages,
    this.lastMessage,
    this.lastMessageAt,
    required this.unreadCount,
    required this.isActive,
  });

  factory Conversation.fromMap(Map<String, dynamic> map) {
    return Conversation(
      id: map['_id']?.toString() ?? '',
      participants: (map['participants'] as List? ?? [])
          .whereType<Map>()
          .map((m) => ChatParticipant.fromMap(Map<String, dynamic>.from(m)))
          .toList(),
      messages: (map['messages'] as List? ?? [])
          .whereType<Map>()
          .map((m) => ChatMessage.fromMap(Map<String, dynamic>.from(m)))
          .toList(),
      lastMessage: map['last_message']?.toString(),
      lastMessageAt: map['last_message_at'] != null
          ? DateTime.tryParse(map['last_message_at'].toString())
          : null,
      unreadCount: (map['unread_count'] as num?)?.toInt() ?? 0,
      isActive: map['is_active'] != false,
    );
  }

  ChatParticipant? getOtherParticipant(String myUserId) {
    try {
      return participants.firstWhere((p) => p.id != myUserId);
    } catch (_) {
      return participants.isNotEmpty ? participants.first : null;
    }
  }
}
