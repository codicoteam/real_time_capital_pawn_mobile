import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:real_time_pawn/config/routers/router.dart';
import 'package:real_time_pawn/core/utils/logs.dart';
import 'package:real_time_pawn/core/utils/pallete.dart';
import 'package:real_time_pawn/core/utils/shared_pref_methods.dart';
import 'package:real_time_pawn/features/chat_mngmt/services/chat_service.dart';
import 'package:real_time_pawn/models/chat_model.dart';

class ChatController extends GetxController {
  // ── State ──────────────────────────────────────────────────────────────────
  final conversations = <Conversation>[].obs;
  final currentConversation = Rxn<Conversation>();
  final messages = <ChatMessage>[].obs;
  final isLoading = false.obs;
  final isLoadingMessages = false.obs;
  final isConnected = false.obs;
  final isSending = false.obs;
  final typingInfo = ''.obs;
  final unreadTotal = 0.obs;
  final errorMessage = ''.obs;

  // Current user's ID — populated on ensureConnected so optimistic updates work
  String myUserId = '';

  // Guard to prevent registering socket event handlers more than once
  bool _eventsBound = false;

  // ── Lifecycle ──────────────────────────────────────────────────────────────
  @override
  void onInit() {
    super.onInit();
    ensureConnected();
  }

  @override
  void onClose() {
    ChatSocketService.disconnect();
    super.onClose();
  }

  // ── Socket ─────────────────────────────────────────────────────────────────

  Future<void> ensureConnected() async {
    final token = await CacheUtils.checkToken();
    if (token == null || token.isEmpty) {
      DevLogs.logError('[Chat] ensureConnected — NO AUTH TOKEN found');
      return;
    }

    // Cache current user ID for optimistic message updates
    final uid = await CacheUtils.getUserId();
    if (uid != null && uid.isNotEmpty) myUserId = uid;
    DevLogs.logInfo('[Chat] ensureConnected — userId=$myUserId, socketConnected=${ChatSocketService.isConnected}');

    // connect() must run first — it creates _socket. Only then can we bind
    // events to it. The _eventsBound guard prevents double-binding on
    // subsequent ensureConnected() calls.
    ChatSocketService.connect(token);

    if (!_eventsBound) {
      _bindSocketEvents();
      _eventsBound = true;
    }

    await _registerFcmToken();
    await loadConversations();
  }

  Future<void> _registerFcmToken() async {
    try {
      final fcmToken = await FirebaseMessaging.instance.getToken();
      DevLogs.logInfo('[FCM] Got token from Firebase: ${fcmToken == null ? "NULL" : "OK (${fcmToken.length} chars)"}');
      if (fcmToken != null) {
        final ok = await ChatApiService.registerFcmToken(fcmToken);
        if (ok) {
          DevLogs.logSuccess('[FCM] Token registered with backend successfully');
        } else {
          DevLogs.logError('[FCM] Backend rejected token registration');
        }
      } else {
        DevLogs.logError('[FCM] FirebaseMessaging.getToken() returned null — check google-services.json / Firebase project');
      }
    } catch (e) {
      DevLogs.logError('[FCM] _registerFcmToken exception: $e');
    }
  }

  void _bindSocketEvents() {
    DevLogs.logInfo('[Socket] Binding socket events');

    ChatSocketService.on('connect', (_) {
      isConnected.value = true;
      DevLogs.logSuccess('[Socket] CONNECTED — myUserId=$myUserId');
    });

    ChatSocketService.on('disconnect', (reason) {
      isConnected.value = false;
      DevLogs.logWarning('[Socket] DISCONNECTED — reason: $reason');
    });

    // Authentication or network failure during connection
    ChatSocketService.on('connect_error', (data) {
      isConnected.value = false;
      DevLogs.logError('[Socket] CONNECT_ERROR: $data — will use REST fallback');
    });

    ChatSocketService.on('error', (data) {
      DevLogs.logError('[Socket] Server error event: $data');
    });

    // A new message arrived in a conversation
    ChatSocketService.on('message:new', (data) {
      try {
        DevLogs.logInfo('[Socket] message:new received — raw: $data');
        final rawData = data is Map ? Map<String, dynamic>.from(data) : <String, dynamic>{};
        final convId = rawData['conversationId']?.toString() ?? '';
        final rawMsg = rawData['message'];
        if (rawMsg == null) {
          DevLogs.logError('[Socket] message:new — "message" field is null in payload');
          return;
        }
        final newMsg = ChatMessage.fromMap(Map<String, dynamic>.from(rawMsg as Map));
        DevLogs.logInfo('[Socket] message:new — msgId=${newMsg.id}, convId=$convId, currentConv=${currentConversation.value?.id}');

        if (currentConversation.value?.id == convId) {
          // Replace a matching optimistic (temp) message, or add if new
          final tempIdx = messages.indexWhere((m) =>
              m.id.startsWith('temp_') &&
              m.content == newMsg.content &&
              m.sender.id == newMsg.sender.id);
          if (tempIdx >= 0) {
            DevLogs.logInfo('[Socket] Replacing optimistic message at index $tempIdx');
            messages[tempIdx] = newMsg;
          } else if (!messages.any((m) => m.id == newMsg.id)) {
            DevLogs.logInfo('[Socket] Adding new message to list');
            messages.add(newMsg);
          } else {
            DevLogs.logWarning('[Socket] message:new — duplicate, already in list');
          }
          ChatSocketService.markAsRead(convId);
        }

        _refreshConversationPreview(convId, newMsg);
      } catch (e) {
        DevLogs.logError('[Socket] message:new parse error: $e');
      }
    });

    // Notification for a message in a conversation we're NOT viewing
    ChatSocketService.on('notification:message', (data) {
      try {
        final from = data['from'];
        final senderName =
            '${from['first_name']} ${from['last_name']}'.trim();
        final preview = data['preview']?.toString() ?? 'New message';
        final convId = data['conversationId']?.toString() ?? '';

        unreadTotal.value++;
        loadConversations(); // Refresh unread counts

        Get.snackbar(
          senderName,
          preview,
          snackPosition: SnackPosition.TOP,
          backgroundColor: AppColors.primaryColor,
          colorText: Colors.white,
          duration: const Duration(seconds: 4),
          margin: const EdgeInsets.all(12),
          borderRadius: 12,
          icon: const Icon(Icons.chat_bubble_outline, color: Colors.white),
          mainButton: TextButton(
            onPressed: () {
              Get.back(); // close snackbar
              openConversationById(convId);
            },
            child: const Text('Reply', style: TextStyle(color: Colors.white)),
          ),
        );
      } catch (e) {
        DevLogs.logError('notification:message parse error: $e');
      }
    });

    // Typing indicators
    ChatSocketService.on('typing:start', (data) {
      try {
        final convId = data['conversationId']?.toString() ?? '';
        if (currentConversation.value?.id == convId) {
          typingInfo.value = '${data['name']} is typing…';
        }
      } catch (_) {}
    });

    ChatSocketService.on('typing:stop', (data) {
      try {
        final convId = data['conversationId']?.toString() ?? '';
        if (currentConversation.value?.id == convId) {
          typingInfo.value = '';
        }
      } catch (_) {}
    });

    // Read receipts — reload messages to update ticks
    ChatSocketService.on('messages:read', (data) {
      try {
        final convId = data['conversationId']?.toString() ?? '';
        if (currentConversation.value?.id == convId) {
          loadConversation(convId);
        }
      } catch (_) {}
    });

    // Soft-deleted message
    ChatSocketService.on('message:deleted', (data) {
      try {
        final msgId = data['messageId']?.toString() ?? '';
        final idx = messages.indexWhere((m) => m.id == msgId);
        if (idx >= 0) {
          final old = messages[idx];
          messages[idx] = ChatMessage(
            id: old.id,
            sender: old.sender,
            content: '',
            imagesUrl: [],
            imageNames: [],
            messageType: 'text',
            readBy: old.readBy,
            isDeleted: true,
            sentAt: old.sentAt,
          );
        }
      } catch (_) {}
    });
  }

  void _refreshConversationPreview(String convId, ChatMessage msg) {
    final idx = conversations.indexWhere((c) => c.id == convId);
    if (idx < 0) {
      loadConversations();
      return;
    }
    final conv = conversations[idx];
    final newUnread = conv.unreadCount + 1;
    final updated = Conversation(
      id: conv.id,
      participants: conv.participants,
      messages: conv.messages,
      lastMessage: msg.isDeleted
          ? '🗑 Message deleted'
          : msg.hasImages && !msg.hasText
          ? '📷 Image'
          : msg.content,
      lastMessageAt: msg.sentAt,
      unreadCount:
          currentConversation.value?.id == convId ? 0 : newUnread,
      isActive: conv.isActive,
    );
    conversations[idx] = updated;
    _recalcUnread();
  }

  // ── Conversations ──────────────────────────────────────────────────────────

  Future<void> loadConversations() async {
    isLoading.value = true;
    errorMessage.value = '';
    try {
      final convs = await ChatApiService.getUserConversations();
      // Sort by last message time descending
      convs.sort((a, b) {
        final ta = a.lastMessageAt ?? DateTime(2000);
        final tb = b.lastMessageAt ?? DateTime(2000);
        return tb.compareTo(ta);
      });
      conversations.value = convs;
      _recalcUnread();
    } catch (e) {
      errorMessage.value = 'Failed to load messages';
      DevLogs.logError('loadConversations error: $e');
    } finally {
      isLoading.value = false;
    }
  }

  void _recalcUnread() {
    unreadTotal.value =
        conversations.fold(0, (sum, c) => sum + c.unreadCount);
  }

  // ── Open a conversation ────────────────────────────────────────────────────

  Future<void> openConversationWithUser(String otherUserId) async {
    isLoadingMessages.value = true;
    try {
      final conv = await ChatApiService.getOrCreateConversation(otherUserId);
      if (conv == null) {
        Get.snackbar('Error', 'Could not open conversation',
            backgroundColor: Colors.red.shade100);
        return;
      }
      _activateConversation(conv);
    } catch (e) {
      DevLogs.logError('openConversationWithUser error: $e');
    } finally {
      isLoadingMessages.value = false;
    }
  }

  Future<void> openConversationById(String convId) async {
    isLoadingMessages.value = true;
    try {
      final conv = await ChatApiService.getConversation(convId);
      if (conv == null) {
        Get.snackbar('Error', 'Conversation not found',
            backgroundColor: Colors.red.shade100);
        return;
      }
      _activateConversation(conv);
      Get.toNamed(RoutesHelper.chatScreen);
    } catch (e) {
      DevLogs.logError('openConversationById error: $e');
    } finally {
      isLoadingMessages.value = false;
    }
  }

  Future<void> loadConversation(String convId) async {
    try {
      final conv = await ChatApiService.getConversation(convId);
      if (conv != null) _activateConversation(conv);
    } catch (e) {
      DevLogs.logError('loadConversation error: $e');
    }
  }

  void _activateConversation(Conversation conv) {
    currentConversation.value = conv;
    messages.value = List<ChatMessage>.from(conv.messages);
    typingInfo.value = '';
    ChatSocketService.joinConversation(conv.id);
    ChatSocketService.markAsRead(conv.id);

    // Also mark as read via REST to be safe
    ChatApiService.markAsRead(conv.id);
  }

  void leaveCurrentConversation() {
    if (currentConversation.value != null) {
      ChatSocketService.sendTypingStop(currentConversation.value!.id);
      ChatSocketService.leaveConversation(currentConversation.value!.id);
    }
    currentConversation.value = null;
    messages.clear();
    typingInfo.value = '';
    loadConversations(); // Refresh list
  }

  // ── Messaging ──────────────────────────────────────────────────────────────

  Future<void> sendMessage(String content) async {
    final convId = currentConversation.value?.id;
    if (convId == null || content.trim().isEmpty) return;
    if (isSending.value) return;

    isSending.value = true;
    final tempId = 'temp_${DateTime.now().millisecondsSinceEpoch}';

    DevLogs.logInfo('[Chat] sendMessage — convId=$convId, socketConnected=${ChatSocketService.isConnected}, content="${content.trim()}"');

    // Show message immediately in UI
    _addOptimisticMessage(content.trim(), tempId: tempId);

    try {
      if (ChatSocketService.isConnected) {
        // Happy path: socket sends message; server echoes it back as message:new
        // which replaces the optimistic entry in the message:new handler.
        DevLogs.logInfo('[Chat] Using SOCKET path to send');
        ChatSocketService.sendMessage(convId, content.trim());
        // isSending is reset immediately — socket is fire-and-forget.
        // The optimistic message is replaced when message:new arrives.
      } else {
        // Socket unavailable — save via REST so the message is not lost.
        // Backend also broadcasts message:new to the room, so web sees it.
        DevLogs.logWarning('[Chat] Socket not connected — using REST fallback');
        final saved = await ChatApiService.sendMessage(
          convId,
          content: content.trim(),
        );
        final tempIdx = messages.indexWhere((m) => m.id == tempId);
        if (saved != null) {
          DevLogs.logSuccess('[Chat] REST fallback succeeded — msgId=${saved.id}');
          if (tempIdx >= 0) {
            messages[tempIdx] = saved;
          } else if (!messages.any((m) => m.id == saved.id)) {
            messages.add(saved);
          }
          _refreshConversationPreview(convId, saved);
        } else {
          // Both socket and REST failed — remove ghost message and alert user
          DevLogs.logError('[Chat] REST fallback ALSO FAILED — message lost');
          if (tempIdx >= 0) messages.removeAt(tempIdx);
          Get.snackbar(
            'Send failed',
            'Message could not be sent. Check your connection and try again.',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.red.shade700,
            colorText: Colors.white,
            duration: const Duration(seconds: 4),
          );
        }
      }
    } catch (e) {
      DevLogs.logError('[Chat] sendMessage exception: $e');
      final tempIdx = messages.indexWhere((m) => m.id == tempId);
      if (tempIdx >= 0) messages.removeAt(tempIdx);
    } finally {
      isSending.value = false;
    }
  }

  String _addOptimisticMessage(String content, {required String tempId}) {
    messages.add(ChatMessage(
      id: tempId,
      sender: ChatParticipant(
        id: myUserId,
        firstName: '',
        lastName: '',
        roles: [],
      ),
      content: content,
      imagesUrl: [],
      imageNames: [],
      messageType: 'text',
      readBy: [myUserId],
      isDeleted: false,
      sentAt: DateTime.now(),
    ));
    return tempId;
  }

  void notifyTypingStart() {
    final convId = currentConversation.value?.id;
    if (convId != null) ChatSocketService.sendTypingStart(convId);
  }

  void notifyTypingStop() {
    final convId = currentConversation.value?.id;
    if (convId != null) ChatSocketService.sendTypingStop(convId);
  }
}
