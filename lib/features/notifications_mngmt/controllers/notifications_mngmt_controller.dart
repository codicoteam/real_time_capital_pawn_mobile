import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/utils/logs.dart';
import '../../../models/notifications_model.dart';
import '../services/notifications_mngmt_service.dart';

class NotificationController extends GetxController {
  // =====================
  // Observable states
  // =====================
  final isLoading = false.obs;
  final successMessage = ''.obs;
  final errorMessage = ''.obs;

  // =====================
  // Notifications list
  // =====================
  final notifications = <NotificationsModel>[].obs;
  final selectedNotification = Rx<NotificationsModel?>(null);
  final unreadCount = 0.obs;

  // =====================
  // Search & filter
  // =====================
  final searchQuery = ''.obs;
  final selectedFilter = 'All'.obs;

  // =====================
  // Fetch notifications
  // =====================
  Future<void> fetchNotifications({bool refresh = false}) async {
    if (refresh) {
      notifications.clear();
    }

    try {
      isLoading.value = true;
      errorMessage.value = '';

      DevLogs.logInfo(
        'Fetching notifications with filter: ${selectedFilter.value}',
      );

      final response = await NotificationService.getNotifications(
        isRead: selectedFilter.value == 'Read'
            ? true
            : (selectedFilter.value == 'Unread' ? false : null),
      );

      if (response.success && response.data != null) {
        notifications.value = response.data!.notifications;
        unreadCount.value = response.data!.unreadCount;
        successMessage.value =
            response.message ?? 'Notifications loaded successfully';
        DevLogs.logSuccess('Loaded ${notifications.length} notifications');
      } else {
        errorMessage.value = response.message ?? 'Failed to load notifications';
        DevLogs.logError(errorMessage.value);
      }
    } catch (e) {
      errorMessage.value = 'An error occurred while fetching notifications: $e';
      DevLogs.logError(errorMessage.value);
    } finally {
      isLoading.value = false;
    }
  }

  // =====================
  // Refresh notifications
  // =====================
  Future<void> refreshNotifications() async {
    await fetchNotifications(refresh: true);
  }

  // =====================
  // Get notification details by ID
  // =====================
  Future<NotificationsModel?> getNotificationDetails(
    String notificationId,
  ) async {
    try {
      isLoading.value = true;

      final response = await NotificationService.getNotificationById(
        notificationId: notificationId,
      );

      if (response.success && response.data != null) {
        selectedNotification.value = response.data;

        // Update in list if exists
        final index = notifications.indexWhere((n) => n.id == notificationId);
        if (index != -1) {
          notifications[index] = response.data!;
          notifications.refresh();
        }

        return response.data;
      } else {
        errorMessage.value =
            response.message ?? 'Failed to load notification details';
        Get.snackbar(
          'Error',
          errorMessage.value,
          snackPosition: SnackPosition.BOTTOM,
        );
        return null;
      }
    } catch (e) {
      errorMessage.value = 'Failed to load notification details: $e';
      Get.snackbar(
        'Error',
        errorMessage.value,
        snackPosition: SnackPosition.BOTTOM,
      );
      return null;
    } finally {
      isLoading.value = false;
    }
  }

  // =====================
  // Mark notification as read
  // =====================
  Future<bool> markAsRead(String notificationId) async {
    try {
      isLoading.value = true;

      final response = await NotificationService.markAsRead(
        notificationId: notificationId,
      );

      if (response.success) {
        // Update local notification
        final notification = notifications.firstWhere(
          (n) => n.id == notificationId,
          orElse: () => selectedNotification.value!,
        );

        if (notification.id != null) {
          notification.isRead = true;
          notification.readAt = DateTime.now();

          notifications.refresh();
          unreadCount.value--;

          if (selectedNotification.value?.id == notificationId) {
            selectedNotification.value = notification;
          }
        }

        Get.snackbar(
          'Success',
          'Notification marked as read',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Get.theme.primaryColor,
          colorText: Colors.white,
        );
        return true;
      } else {
        errorMessage.value = response.message ?? 'Failed to mark as read';
        Get.snackbar(
          'Error',
          errorMessage.value,
          snackPosition: SnackPosition.BOTTOM,
        );
        return false;
      }
    } catch (e) {
      errorMessage.value = 'Failed to mark as read: $e';
      Get.snackbar(
        'Error',
        errorMessage.value,
        snackPosition: SnackPosition.BOTTOM,
      );
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  // =====================
  // Record action on notification
  // =====================
  Future<bool> recordAction({
    required String notificationId,
    required String action,
  }) async {
    try {
      isLoading.value = true;

      final response = await NotificationService.recordAction(
        notificationId: notificationId,
        action: action,
      );

      if (response.success) {
        // Update local notification
        final notification = notifications.firstWhere(
          (n) => n.id == notificationId,
          orElse: () => selectedNotification.value!,
        );

        if (notification.id != null) {
          notification.isActed = true;
          notification.actedAt = DateTime.now();
          notification.actionTaken = action;

          notifications.refresh();

          if (selectedNotification.value?.id == notificationId) {
            selectedNotification.value = notification;
          }
        }

        Get.snackbar(
          'Success',
          'Action recorded successfully',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Get.theme.primaryColor,
          colorText: Colors.white,
        );
        return true;
      } else {
        errorMessage.value = response.message ?? 'Failed to record action';
        Get.snackbar(
          'Error',
          errorMessage.value,
          snackPosition: SnackPosition.BOTTOM,
        );
        return false;
      }
    } catch (e) {
      errorMessage.value = 'Failed to record action: $e';
      Get.snackbar(
        'Error',
        errorMessage.value,
        snackPosition: SnackPosition.BOTTOM,
      );
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  // =====================
  // Mark as read and record action in one call
  // =====================
  Future<bool> markAsReadAndAct({
    required String notificationId,
    required String action,
  }) async {
    final readSuccess = await markAsRead(notificationId);
    if (!readSuccess) return false;

    return await recordAction(notificationId: notificationId, action: action);
  }

  // =====================
  // Set filter
  // =====================
  void setFilter(String filter) {
    selectedFilter.value = filter;
    fetchNotifications(refresh: true);
  }

  // =====================
  // Set search query
  // =====================
  void setSearchQuery(String query) {
    searchQuery.value = query;
  }

  // =====================
  // Clear search
  // =====================
  void clearSearch() {
    searchQuery.value = '';
  }

  // =====================
  // Clear all filters (reset to default)
  // =====================
  void clearFilters() {
    selectedFilter.value = 'All';
    searchQuery.value = '';
    fetchNotifications(refresh: true);
  }

  // =====================
  // Select notification
  // =====================
  void selectNotification(NotificationsModel notification) {
    selectedNotification.value = notification;
  }

  // =====================
  // Clear selected notification
  // =====================
  void clearSelectedNotification() {
    selectedNotification.value = null;
  }

  // =====================
  // Computed properties
  // =====================
  List<NotificationsModel> get filteredNotifications {
    if (searchQuery.value.isEmpty) return notifications;

    return notifications.where((notification) {
      return notification.title?.toLowerCase().contains(
                searchQuery.value.toLowerCase(),
              ) ==
              true ||
          notification.message?.toLowerCase().contains(
                searchQuery.value.toLowerCase(),
              ) ==
              true;
    }).toList();
  }

  int get readCount => notifications.where((n) => n.isRead == true).length;
  int get unreadNotificationsCount =>
      notifications.where((n) => n.isRead == false).length;

  // =====================
  // Lifecycle
  // =====================
  @override
  void onInit() {
    super.onInit();
    fetchNotifications();
  }
}
