import 'dart:convert';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';
import 'package:real_time_pawn/core/utils/logs.dart';
import 'package:real_time_pawn/features/chat_mngmt/controllers/chat_controller.dart';

const _channelId = 'chat_messages';
const _channelName = 'Chat Messages';

class ChatNotificationService {
  static final _plugin = FlutterLocalNotificationsPlugin();
  static bool _initialized = false;

  static Future<void> initialize() async {
    if (_initialized) return;

    const androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );

    // v21 uses named `settings:` parameter
    await _plugin.initialize(
      settings: const InitializationSettings(
        android: androidSettings,
        iOS: iosSettings,
      ),
      onDidReceiveNotificationResponse: _onTap,
      onDidReceiveBackgroundNotificationResponse: _onTap,
    );

    // Create Android notification channel
    await _plugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(
          const AndroidNotificationChannel(
            _channelId,
            _channelName,
            description: 'Real-time chat message notifications',
            importance: Importance.high,
            playSound: true,
            enableVibration: true,
          ),
        );

    _initialized = true;
    DevLogs.logSuccess('ChatNotificationService initialized');
  }

  static Future<void> showChatMessage({
    required String senderName,
    required String preview,
    required String conversationId,
  }) async {
    if (!_initialized) await initialize();
    try {
      // v21 uses all named parameters
      await _plugin.show(
        id: conversationId.hashCode.abs(),
        title: senderName,
        body: preview.isNotEmpty ? preview : 'New message',
        notificationDetails: NotificationDetails(
          android: AndroidNotificationDetails(
            _channelId,
            _channelName,
            channelDescription: 'Real-time chat message notifications',
            importance: Importance.high,
            priority: Priority.high,
            icon: '@mipmap/ic_launcher',
            styleInformation: BigTextStyleInformation(
              preview.isNotEmpty ? preview : 'New message',
              contentTitle: senderName,
            ),
          ),
          iOS: const DarwinNotificationDetails(
            presentAlert: true,
            presentBadge: true,
            presentSound: true,
          ),
        ),
        payload: json.encode({'conversationId': conversationId}),
      );
    } catch (e) {
      DevLogs.logError('showChatMessage notification failed: $e');
    }
  }

  // Called when the user taps a local notification
  @pragma('vm:entry-point')
  static void _onTap(NotificationResponse details) {
    try {
      final payload = details.payload;
      if (payload == null || payload.isEmpty) return;
      final data = json.decode(payload) as Map<String, dynamic>;
      final convId = data['conversationId']?.toString() ?? '';
      if (convId.isEmpty) return;

      try {
        Get.find<ChatController>().openConversationById(convId);
      } catch (_) {
        // Controller not yet registered on cold-start; main.dart's
        // getInitialMessage handler will navigate once ready.
      }
    } catch (e) {
      DevLogs.logError('Notification tap handling error: $e');
    }
  }
}
