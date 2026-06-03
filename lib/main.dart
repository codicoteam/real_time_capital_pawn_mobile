import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:real_time_pawn/core/utils/logs.dart';
import 'package:real_time_pawn/core/utils/pallete.dart';
import 'package:real_time_pawn/features/payments_mngmt/screens/welcome_page/splash_screen.dart';
import 'package:real_time_pawn/global/user_controller.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'app_pages.dart';
import 'config/api_config/api_keys.dart';
import 'features/attached_files_mngmt/controllers/attached_files_mngmt_controller.dart'
    show AttachmentController;
import 'features/auctions_mngmt/controllers/auctions_mngmt_controller.dart'
    show AuctionsController;
import 'features/auth_mngmt/controllers/auth_controller.dart';
import 'features/bid_mngmnt/controllers/bid_mngmt_controller.dart'
    show BidManagementController;
import 'features/bid_payment_mngmt/controllers/bid_payment_mngmt_controller.dart'
    show BidPaymentController;
import 'features/loan_application_mngmt/controllers/loan_application_controller.dart'
    show LoanApplicationControllerTwo;
import 'features/loan_application_mngmt/controllers/loan_application_mngmt_controller.dart';
import 'features/loan_terms_mngmt/controllers/loan_terms_mngmt_controller.dart'
    show LoanTermsController;
import 'features/notifications_mngmt/controllers/notifications_mngmt_controller.dart';
import 'features/chat_mngmt/controllers/chat_controller.dart';
import 'features/chat_mngmt/services/chat_notification_service.dart';
import 'features/support_mngmt/controllers/support_mngmt_controller.dart'
    show SupportTicketController;

// Holds a local notification payload captured before controllers are registered
String? _pendingLocalNotificationPayload;

Map<String, dynamic> _parseLocalPayload(String payload) {
  try {
    final decoded = json.decode(payload) as Map<String, dynamic>;
    // Map local notification payload keys to the standard notification format
    return {
      'type': 'chat_message',
      'conversationId': decoded['conversationId'] ?? '',
    };
  } catch (_) {
    return {};
  }
}

// ✅ Background message handler (required for Firebase)
@pragma('vm:entry-point')
Future<void> _firebaseBackgroundHandler(RemoteMessage message) async {
  debugPrint("Handling a background message: ${message.messageId}");
  debugPrint("Message data: ${message.data}");
  debugPrint("Notification title: ${message.notification?.title}");
  debugPrint("Notification body: ${message.notification?.body}");
}

void main() {
  runZonedGuarded(
    () async {
      WidgetsFlutterBinding.ensureInitialized();

      // ✅ Initialize Supabase
      await Supabase.initialize(
        url: ApiKeys.supabaseUrl,
        anonKey: ApiKeys.supabaseKey,
      );

      // ✅ Initialize Firebase
      await Firebase.initializeApp();

      // ✅ Set up Firebase Messaging background handler
      FirebaseMessaging.onBackgroundMessage(_firebaseBackgroundHandler);

      // ✅ Initialize local notification channel (for foreground messages)
      await ChatNotificationService.initialize();

      // ✅ Request notification permissions (important for iOS)
      NotificationSettings settings = await FirebaseMessaging.instance
          .requestPermission(
            alert: true,
            badge: true,
            sound: true,
            provisional: false,
          );

      DevLogs.logInfo(
        'Notification permission status: ${settings.authorizationStatus}',
      );

      // ✅ Get and log FCM token (for debugging)
      String? fcmToken = await FirebaseMessaging.instance.getToken();
      DevLogs.logInfo('FCM Token: $fcmToken');

      // ✅ Listen for foreground messages — show local notification for chat
      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        final data = message.data;
        if (data['type'] == 'chat_message') {
          final convId = data['conversationId'] ?? '';
          // Skip if user is actively viewing that conversation
          try {
            final chatCtrl = Get.find<ChatController>();
            if (chatCtrl.currentConversation.value?.id == convId) return;
          } catch (_) {}

          final senderName = message.notification?.title ??
              data['senderName'] ??
              'New Message';
          final preview =
              message.notification?.body ?? 'You have a new message';

          ChatNotificationService.showChatMessage(
            senderName: senderName,
            preview: preview,
            conversationId: convId,
          );
        }
      });

      // ✅ Listen for when app is opened from a terminated state
      RemoteMessage? initialMessage = await FirebaseMessaging.instance
          .getInitialMessage();
      if (initialMessage != null) {
        DevLogs.logInfo('App opened from terminated state with notification');
        // Handle navigation based on notification data
        _handleNotificationNavigation(initialMessage.data);
      }

      // ✅ Listen for when app is in background and opened via notification
      FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
        DevLogs.logInfo('App opened from background state with notification');
        _handleNotificationNavigation(message.data);
      });

      // ✅ Handle local notification tap from terminated state
      final launchDetails =
          await FlutterLocalNotificationsPlugin().getNotificationAppLaunchDetails();
      if (launchDetails?.didNotificationLaunchApp == true) {
        final payload = launchDetails!.notificationResponse?.payload;
        if (payload != null && payload.isNotEmpty) {
          // Will be handled once ChatController is registered below
          _pendingLocalNotificationPayload = payload;
        }
      }

      // Register controllers
      Get.put(AuthController());
      Get.put(AttachmentController());
      Get.put(LoanApplicationController());
      Get.put(LoanApplicationControllerTwo());
      Get.put(UserController());
      Get.put(LoanTermsController());
      Get.put(BidPaymentController());
      Get.put(BidManagementController());
      Get.put(AuctionsController());
      Get.put(SupportTicketController());
      Get.put(NotificationController());
      Get.put(ChatController());

      // Handle local notification tap from terminated state
      if (_pendingLocalNotificationPayload != null) {
        _handleNotificationNavigation(
            _parseLocalPayload(_pendingLocalNotificationPayload!));
        _pendingLocalNotificationPayload = null;
      }

      runApp(const MyApp());
    },
    (error, stack) {
      // Minimal crash logging so startup failures aren't silent
      DevLogs.logError('❌ Uncaught error in main(): $error');
      DevLogs.logError('$stack');
    },
  );
}

/// ✅ Handle navigation when user taps on a notification
void _handleNotificationNavigation(Map<String, dynamic> messageData) {
  try {
    final entityType = messageData['entity_type'];
    final entityId = messageData['entity_id'];
    final notificationType = messageData['type'];

    DevLogs.logInfo('Navigate to: $entityType with ID: $entityId');
    DevLogs.logInfo('Notification type: $notificationType');

    if (notificationType == 'chat_message') {
      final convId = messageData['conversationId']?.toString() ?? '';
      if (convId.isNotEmpty) {
        final chatCtrl = Get.find<ChatController>();
        chatCtrl.openConversationById(convId);
      }
    }
  } catch (e) {
    DevLogs.logError('Error handling notification navigation: $e');
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Pawn Management System',
      theme: Pallete.appTheme,
      initialRoute: '/',
      getPages: AppPages.pages,
      home: const SplashScreen(),
    );
  }
}
