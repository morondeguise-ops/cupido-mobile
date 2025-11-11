import '../models/notification_model.dart';
import 'api_service.dart';

/// Service for managing user notifications
///
/// Handles:
/// - Fetching notifications
/// - Marking notifications as read/unread
/// - Managing notification preferences
/// - Deleting notifications
class UserNotificationService {
  final ApiService _apiService;

  UserNotificationService(this._apiService);

  /// Get all notifications for the current user
  Future<List<UserNotification>> getNotifications({
    bool? isRead,
    String? category,
    String? notificationType,
    int? page,
    int? perPage,
  }) async {
    final queryParams = <String, dynamic>{};
    if (isRead != null) queryParams['is_read'] = isRead;
    if (category != null) queryParams['category'] = category;
    if (notificationType != null) {
      queryParams['notification_type'] = notificationType;
    }
    if (page != null) queryParams['page'] = page;
    if (perPage != null) queryParams['per_page'] = perPage;

    final response = await _apiService.get(
      '/notifications',
      queryParameters: queryParams,
    );

    final List<dynamic> data = response.data['data'] ?? response.data;
    return data.map((json) => UserNotification.fromJson(json)).toList();
  }

  /// Get unread notifications
  Future<List<UserNotification>> getUnreadNotifications({
    int? page,
    int? perPage,
  }) async {
    return getNotifications(
      isRead: false,
      page: page,
      perPage: perPage,
    );
  }

  /// Get a specific notification by ID
  Future<UserNotification> getNotification(int notificationId) async {
    final response = await _apiService.get('/notifications/$notificationId');
    return UserNotification.fromJson(response.data['data'] ?? response.data);
  }

  /// Mark notification as read
  Future<void> markAsRead(int notificationId) async {
    await _apiService.post('/notifications/$notificationId/read');
  }

  /// Mark notification as unread
  Future<void> markAsUnread(int notificationId) async {
    await _apiService.post('/notifications/$notificationId/unread');
  }

  /// Mark all notifications as read
  Future<void> markAllAsRead() async {
    await _apiService.post('/notifications/mark-all-read');
  }

  /// Delete a notification
  Future<void> deleteNotification(int notificationId) async {
    await _apiService.delete('/notifications/$notificationId');
  }

  /// Delete all notifications
  Future<void> deleteAllNotifications() async {
    await _apiService.delete('/notifications/all');
  }

  /// Get unread notification count
  Future<int> getUnreadCount() async {
    final response = await _apiService.get('/notifications/unread-count');
    return response.data['count'] ?? 0;
  }

  /// Get notification counts by category
  Future<Map<String, int>> getCountsByCategory() async {
    final response = await _apiService.get('/notifications/counts-by-category');
    return Map<String, int>.from(response.data['data'] ?? {});
  }

  /// Get notification settings/preferences
  Future<Map<String, dynamic>> getNotificationSettings() async {
    final response = await _apiService.get('/notifications/settings');
    return response.data['data'] ?? response.data;
  }

  /// Update notification settings/preferences
  Future<void> updateNotificationSettings(
    Map<String, dynamic> settings,
  ) async {
    await _apiService.put(
      '/notifications/settings',
      data: settings,
    );
  }

  /// Test a notification (for debugging)
  Future<UserNotification> sendTestNotification({
    required String title,
    required String message,
    String? notificationType,
    Map<String, dynamic>? actionData,
  }) async {
    final response = await _apiService.post(
      '/notifications/test',
      data: {
        'title': title,
        'message': message,
        'notification_type': notificationType ?? NotificationType.system,
        'action_data': actionData,
      },
    );

    return UserNotification.fromJson(response.data['data'] ?? response.data);
  }

  /// Clear expired notifications
  Future<int> clearExpiredNotifications() async {
    final response = await _apiService.delete('/notifications/expired');
    return response.data['deleted_count'] ?? 0;
  }

  /// Get notifications by type
  Future<List<UserNotification>> getNotificationsByType(
    String notificationType, {
    int? page,
    int? perPage,
  }) async {
    return getNotifications(
      notificationType: notificationType,
      page: page,
      perPage: perPage,
    );
  }

  /// Get notifications by category
  Future<List<UserNotification>> getNotificationsByCategory(
    String category, {
    int? page,
    int? perPage,
  }) async {
    return getNotifications(
      category: category,
      page: page,
      perPage: perPage,
    );
  }
}
