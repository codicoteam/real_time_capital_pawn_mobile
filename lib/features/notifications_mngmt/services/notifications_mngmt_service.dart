import 'dart:convert';

import 'package:flutter/foundation.dart' show debugPrint;
import 'package:http/http.dart' as http;
import 'package:real_time_pawn/config/api_config/api_keys.dart';
import '../../../core/utils/api_response.dart';
import '../../../core/utils/logs.dart';
import '../../../core/utils/shared_pref_methods.dart';
import '../../../models/notifications_model.dart';

class NotificationService {
  /// 🔹 Get all notifications with pagination and filtering
  static Future<APIResponse<NotificationsResponse>> getNotifications({
    int page = 1,
    int limit = 100000000,
    String sortBy = 'created_at',
    String sortOrder = 'desc',
    bool? isRead,
    String? type,
  }) async {
    final token = await CacheUtils.checkToken();

    // Build query parameters
    final queryParams = {
      'page': page.toString(),
      'limit': limit.toString(),
      'sort_by': sortBy,
      'sort_order': sortOrder,
    };

    // Add optional filters
    if (isRead != null) queryParams['is_read'] = isRead.toString();
    if (type != null && type.isNotEmpty) queryParams['type'] = type;

    final String url =
        '${ApiKeys.baseUrl}/notifications?${_buildQueryString(queryParams)}';

    try {
      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );

      DevLogs.logInfo('Get notifications response: ${response.body}');
      debugPrint(
        'Get notifications response: ${response.body}',
        wrapWidth: 1024,
      );

      final decoded = json.decode(response.body);

      if (response.statusCode == 200) {
        final notificationsData = decoded['data'];
        final notificationsList =
            notificationsData['notifications'] as List? ?? [];

        final notifications = notificationsList
            .map((e) => NotificationsModel.fromMap(e as Map<String, dynamic>))
            .toList();

        final pagination = notificationsData['pagination'];
        final unreadCount = notificationsData['unread_count'] ?? 0;

        return APIResponse<NotificationsResponse>(
          success: true,
          data: NotificationsResponse(
            notifications: notifications,
            pagination: PaginationInfo.fromMap(pagination),
            unreadCount: unreadCount,
          ),
          message: decoded['message'] ?? 'Notifications retrieved successfully',
        );
      } else {
        return APIResponse<NotificationsResponse>(
          success: false,
          message:
              decoded['message'] ??
              'Failed to fetch notifications. HTTP ${response.statusCode}',
        );
      }
    } catch (e) {
      DevLogs.logError('Get notifications error: $e');
      return APIResponse<NotificationsResponse>(
        success: false,
        message: 'Error fetching notifications: $e',
      );
    }
  }

  /// 🔹 Get single notification by ID
  static Future<APIResponse<NotificationsModel>> getNotificationById({
    required String notificationId,
  }) async {
    final token = await CacheUtils.checkToken();

    final String url = '${ApiKeys.baseUrl}/notifications/$notificationId';

    try {
      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );

      DevLogs.logInfo('Get notification by ID response: ${response.body}');
      debugPrint(
        'Get notification by ID response: ${response.body}',
        wrapWidth: 1024,
      );

      final decoded = json.decode(response.body);

      if (response.statusCode == 200) {
        final notification = NotificationsModel.fromMap(decoded['data']);
        return APIResponse<NotificationsModel>(
          success: true,
          data: notification,
          message: decoded['message'] ?? 'Notification retrieved successfully',
        );
      } else {
        return APIResponse<NotificationsModel>(
          success: false,
          message:
              decoded['message'] ??
              'Failed to fetch notification. HTTP ${response.statusCode}',
        );
      }
    } catch (e) {
      DevLogs.logError('Get notification by ID error: $e');
      return APIResponse<NotificationsModel>(
        success: false,
        message: 'Error fetching notification: $e',
      );
    }
  }

  /// 🔹 Mark notification as read
  static Future<APIResponse<String>> markAsRead({
    required String notificationId,
  }) async {
    final token = await CacheUtils.checkToken();

    final String url = '${ApiKeys.baseUrl}/notifications/$notificationId/read';

    try {
      final response = await http.put(
        Uri.parse(url),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );

      DevLogs.logInfo('Mark as read response: ${response.body}');
      debugPrint('Mark as read response: ${response.body}', wrapWidth: 1024);

      final decoded = json.decode(response.body);

      if (response.statusCode == 200) {
        return APIResponse<String>(
          success: true,
          data: notificationId,
          message: decoded['message'] ?? 'Notification marked as read',
        );
      } else {
        return APIResponse<String>(
          success: false,
          message:
              decoded['message'] ??
              'Failed to mark notification as read. HTTP ${response.statusCode}',
        );
      }
    } catch (e) {
      DevLogs.logError('Mark as read error: $e');
      return APIResponse<String>(
        success: false,
        message: 'Error marking notification as read: $e',
      );
    }
  }

  /// 🔹 Record action taken on notification
  static Future<APIResponse<String>> recordAction({
    required String notificationId,
    required String action,
  }) async {
    final token = await CacheUtils.checkToken();

    final String url = '${ApiKeys.baseUrl}/notifications/$notificationId/act';

    try {
      final response = await http.put(
        Uri.parse(url),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({'action': action}),
      );

      DevLogs.logInfo('Record action response: ${response.body}');
      debugPrint('Record action response: ${response.body}', wrapWidth: 1024);

      final decoded = json.decode(response.body);

      if (response.statusCode == 200) {
        return APIResponse<String>(
          success: true,
          data: notificationId,
          message: decoded['message'] ?? 'Action recorded successfully',
        );
      } else {
        return APIResponse<String>(
          success: false,
          message:
              decoded['message'] ??
              'Failed to record action. HTTP ${response.statusCode}',
        );
      }
    } catch (e) {
      DevLogs.logError('Record action error: $e');
      return APIResponse<String>(
        success: false,
        message: 'Error recording action: $e',
      );
    }
  }

  /// Helper method to build query string
  static String _buildQueryString(Map<String, dynamic> params) {
    return params.entries
        .where((entry) => entry.value != null)
        .map(
          (entry) =>
              '${Uri.encodeComponent(entry.key)}=${Uri.encodeComponent(entry.value.toString())}',
        )
        .join('&');
  }
}

/// Response wrapper for notifications list
class NotificationsResponse {
  final List<NotificationsModel> notifications;
  final PaginationInfo pagination;
  final int unreadCount;

  NotificationsResponse({
    required this.notifications,
    required this.pagination,
    required this.unreadCount,
  });
}

/// Pagination information
class PaginationInfo {
  final int page;
  final int limit;
  final int total;
  final int pages;

  PaginationInfo({
    required this.page,
    required this.limit,
    required this.total,
    required this.pages,
  });

  factory PaginationInfo.fromMap(Map<String, dynamic> json) {
    return PaginationInfo(
      page: json['page'] ?? 1,
      limit: json['limit'] ?? 20,
      total: json['total'] ?? 0,
      pages: json['pages'] ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {'page': page, 'limit': limit, 'total': total, 'pages': pages};
  }

  bool get hasNextPage => page < pages;
  bool get hasPreviousPage => page > 1;

  PaginationInfo nextPage() {
    if (!hasNextPage) return this;
    return PaginationInfo(
      page: page + 1,
      limit: limit,
      total: total,
      pages: pages,
    );
  }

  PaginationInfo previousPage() {
    if (!hasPreviousPage) return this;
    return PaginationInfo(
      page: page - 1,
      limit: limit,
      total: total,
      pages: pages,
    );
  }
}
