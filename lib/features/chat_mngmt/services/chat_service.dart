import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:real_time_pawn/config/api_config/api_keys.dart';
import 'package:real_time_pawn/core/utils/logs.dart';
import 'package:real_time_pawn/core/utils/shared_pref_methods.dart';
import 'package:real_time_pawn/models/chat_model.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

// ── REST API ──────────────────────────────────────────────────────────────────

class ChatApiService {
  static Future<Map<String, String>> _headers() async {
    final token = await CacheUtils.checkToken();
    return {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
  }

  static Future<Conversation?> getOrCreateConversation(
    String otherUserId,
  ) async {
    try {
      final headers = await _headers();
      final url = '${ApiKeys.baseUrl}/chat/with/$otherUserId';
      final response = await http
          .get(Uri.parse(url), headers: headers)
          .timeout(const Duration(seconds: 15));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return Conversation.fromMap(data['data'] as Map<String, dynamic>);
      }
      DevLogs.logError(
        'getOrCreateConversation: ${response.statusCode} ${response.body}',
      );
    } catch (e) {
      DevLogs.logError('getOrCreateConversation error: $e');
    }
    return null;
  }

  static Future<List<Conversation>> getUserConversations() async {
    try {
      final headers = await _headers();
      final response = await http
          .get(Uri.parse('${ApiKeys.baseUrl}/chat'), headers: headers)
          .timeout(const Duration(seconds: 15));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final list = data['data'] as List? ?? [];
        return list
            .whereType<Map<String, dynamic>>()
            .map(Conversation.fromMap)
            .toList();
      }
    } catch (e) {
      DevLogs.logError('getUserConversations error: $e');
    }
    return [];
  }

  static Future<Conversation?> getConversation(String conversationId) async {
    try {
      final headers = await _headers();
      final url = '${ApiKeys.baseUrl}/chat/$conversationId';
      final response = await http
          .get(Uri.parse(url), headers: headers)
          .timeout(const Duration(seconds: 15));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return Conversation.fromMap(data['data'] as Map<String, dynamic>);
      }
    } catch (e) {
      DevLogs.logError('getConversation error: $e');
    }
    return null;
  }

  static Future<void> markAsRead(String conversationId) async {
    try {
      final headers = await _headers();
      await http
          .put(
            Uri.parse('${ApiKeys.baseUrl}/chat/$conversationId/read'),
            headers: headers,
          )
          .timeout(const Duration(seconds: 10));
    } catch (e) {
      DevLogs.logError('markAsRead error: $e');
    }
  }

  static Future<List<ChatParticipant>> getChatableUsers() async {
    try {
      final headers = await _headers();
      final response = await http
          .get(
            Uri.parse('${ApiKeys.baseUrl}/chat/chatable-users'),
            headers: headers,
          )
          .timeout(const Duration(seconds: 15));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final list = data['data'] as List? ?? [];
        return list
            .whereType<Map<String, dynamic>>()
            .map(ChatParticipant.fromMap)
            .toList();
      }
    } catch (e) {
      DevLogs.logError('getChatableUsers error: $e');
    }
    return [];
  }

  static Future<bool> registerFcmToken(String fcmToken) async {
    try {
      final headers = await _headers();
      final shortToken = fcmToken.length > 20 ? '${fcmToken.substring(0, 20)}…' : fcmToken;
      DevLogs.logInfo('[FCM] Registering token: $shortToken');
      final response = await http
          .post(
            Uri.parse('${ApiKeys.baseUrl}/users/fcm-token'),
            headers: headers,
            body: json.encode({'fcm_token': fcmToken}),
          )
          .timeout(const Duration(seconds: 10));
      if (response.statusCode == 200 || response.statusCode == 201) {
        DevLogs.logSuccess('[FCM] Token registered — status ${response.statusCode}');
        return true;
      }
      DevLogs.logError('[FCM] Token registration failed — status ${response.statusCode} body: ${response.body}');
      return false;
    } catch (e) {
      DevLogs.logError('[FCM] registerFcmToken exception: $e');
      return false;
    }
  }

  // REST fallback — used when socket is unavailable
  static Future<ChatMessage?> sendMessage(
    String conversationId, {
    String? content,
    List<String>? imagesUrl,
    List<String>? imageNames,
  }) async {
    final url = '${ApiKeys.baseUrl}/chat/$conversationId/messages';
    DevLogs.logInfo('[REST] sendMessage → POST $url');
    try {
      final headers = await _headers();
      final body = <String, dynamic>{};
      if (content != null && content.trim().isNotEmpty) {
        body['content'] = content.trim();
      }
      if (imagesUrl != null && imagesUrl.isNotEmpty) {
        body['images_url'] = imagesUrl;
        if (imageNames != null) body['image_names'] = imageNames;
      }
      DevLogs.logInfo('[REST] sendMessage body: $body');
      final response = await http
          .post(
            Uri.parse(url),
            headers: headers,
            body: json.encode(body),
          )
          .timeout(const Duration(seconds: 15));
      DevLogs.logInfo('[REST] sendMessage response: ${response.statusCode}');
      if (response.statusCode == 201 || response.statusCode == 200) {
        final data = json.decode(response.body);
        DevLogs.logSuccess('[REST] Message saved — id: ${(data['data'] as Map?)?['_id']}');
        return ChatMessage.fromMap(
            Map<String, dynamic>.from(data['data'] as Map));
      }
      DevLogs.logError('[REST] sendMessage FAILED — ${response.statusCode}: ${response.body}');
    } catch (e) {
      DevLogs.logError('[REST] sendMessage exception: $e');
    }
    return null;
  }
}

// ── Socket.IO ─────────────────────────────────────────────────────────────────

class ChatSocketService {
  static IO.Socket? _socket;

  static bool get isConnected => _socket?.connected ?? false;

  static void connect(String token) {
    if (_socket != null) {
      DevLogs.logInfo('[Socket] connect() — socket already exists, connected=${_socket!.connected}');
      if (!_socket!.connected) {
        // Not connected: kick off an explicit reconnect attempt
        DevLogs.logInfo('[Socket] Calling socket.connect() to retry');
        _socket!.connect();
      }
      return;
    }

    DevLogs.logInfo('[Socket] Creating new socket → ${ApiKeys.socketUrl}');

    _socket = IO.io(
      ApiKeys.socketUrl,
      IO.OptionBuilder()
          .setTransports(['websocket'])
          .setAuth({'token': token})
          .enableAutoConnect()
          .enableReconnection()
          .setReconnectionAttempts(10)
          .setReconnectionDelay(2000)
          .build(),
    );

    _socket!.connect();
  }

  static void joinConversation(String conversationId) {
    _socket?.emit('conversation:join', {'conversationId': conversationId});
  }

  static void leaveConversation(String conversationId) {
    _socket?.emit('conversation:leave', {'conversationId': conversationId});
  }

  static void sendMessage(
    String conversationId,
    String? content, {
    List<String>? imagesUrl,
  }) {
    final payload = <String, dynamic>{'conversationId': conversationId};
    if (content != null && content.trim().isNotEmpty) {
      payload['content'] = content.trim();
    }
    if (imagesUrl != null && imagesUrl.isNotEmpty) {
      payload['images_url'] = imagesUrl;
    }
    DevLogs.logInfo('[Socket] emit message:send — connected=$isConnected, convId=$conversationId, content="${content?.trim()}"');
    if (_socket == null) {
      DevLogs.logError('[Socket] CANNOT SEND — _socket is null');
      return;
    }
    if (!isConnected) {
      DevLogs.logError('[Socket] CANNOT SEND — socket not connected (status: ${_socket!.connected})');
      return;
    }
    _socket!.emit('message:send', payload);
    DevLogs.logSuccess('[Socket] message:send emitted');
  }

  static void sendTypingStart(String conversationId) {
    _socket?.emit('typing:start', {'conversationId': conversationId});
  }

  static void sendTypingStop(String conversationId) {
    _socket?.emit('typing:stop', {'conversationId': conversationId});
  }

  static void markAsRead(String conversationId) {
    _socket?.emit('messages:read', {'conversationId': conversationId});
  }

  static void on(String event, dynamic Function(dynamic) handler) {
    _socket?.on(event, handler);
  }

  static void off(String event) {
    _socket?.off(event);
  }

  static void disconnect() {
    DevLogs.logInfo('[Socket] disconnect() — was connected=$isConnected');
    _socket?.disconnect();
    _socket?.dispose();
    _socket = null;
  }
}
