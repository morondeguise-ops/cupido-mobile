/// Notification models for the Cupido app
///
/// Corresponds to Cupido\Core\Models\Notifications namespace in backend

class UserNotification {
  final int id;
  final int userId;
  final int? senderId;
  final String notificationType;
  final String title;
  final String message;
  final String? actionUrl;
  final Map<String, dynamic>? actionData;
  final String priority;
  final bool isRead;
  final bool isPushSent;
  final bool isEmailSent;
  final DateTime? readAt;
  final DateTime? expiresAt;
  final String? category;
  final Map<String, dynamic>? channelPreferences;
  final Map<String, dynamic>? metadata;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;

  // Optional relationships
  final dynamic sender; // Can be User object

  UserNotification({
    required this.id,
    required this.userId,
    this.senderId,
    required this.notificationType,
    required this.title,
    required this.message,
    this.actionUrl,
    this.actionData,
    required this.priority,
    required this.isRead,
    required this.isPushSent,
    required this.isEmailSent,
    this.readAt,
    this.expiresAt,
    this.category,
    this.channelPreferences,
    this.metadata,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
    this.sender,
  });

  factory UserNotification.fromJson(Map<String, dynamic> json) {
    return UserNotification(
      id: json['id'],
      userId: json['user_id'],
      senderId: json['sender_id'],
      notificationType: json['notification_type'],
      title: json['title'],
      message: json['message'],
      actionUrl: json['action_url'],
      actionData: json['action_data'],
      priority: json['priority'] ?? 'normal',
      isRead: json['is_read'] ?? false,
      isPushSent: json['is_push_sent'] ?? false,
      isEmailSent: json['is_email_sent'] ?? false,
      readAt: json['read_at'] != null ? DateTime.parse(json['read_at']) : null,
      expiresAt:
          json['expires_at'] != null ? DateTime.parse(json['expires_at']) : null,
      category: json['category'],
      channelPreferences: json['channel_preferences'],
      metadata: json['metadata'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
      deletedAt:
          json['deleted_at'] != null ? DateTime.parse(json['deleted_at']) : null,
      sender: json['sender'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'sender_id': senderId,
      'notification_type': notificationType,
      'title': title,
      'message': message,
      'action_url': actionUrl,
      'action_data': actionData,
      'priority': priority,
      'is_read': isRead,
      'is_push_sent': isPushSent,
      'is_email_sent': isEmailSent,
      'read_at': readAt?.toIso8601String(),
      'expires_at': expiresAt?.toIso8601String(),
      'category': category,
      'channel_preferences': channelPreferences,
      'metadata': metadata,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'deleted_at': deletedAt?.toIso8601String(),
    };
  }

  bool get isExpired {
    if (expiresAt == null) return false;
    return DateTime.now().isAfter(expiresAt!);
  }

  bool get isDeleted => deletedAt != null;

  bool get isUnread => !isRead;
}

/// Notification types
class NotificationType {
  static const String match = 'match';
  static const String message = 'message';
  static const String like = 'like';
  static const String superLike = 'super_like';
  static const String boost = 'boost';
  static const String profileView = 'profile_view';
  static const String newFollower = 'new_follower';
  static const String comment = 'comment';
  static const String mention = 'mention';
  static const String gift = 'gift';
  static const String subscription = 'subscription';
  static const String achievement = 'achievement';
  static const String event = 'event';
  static const String system = 'system';
}

/// Notification priorities
class NotificationPriority {
  static const String low = 'low';
  static const String normal = 'normal';
  static const String high = 'high';
  static const String urgent = 'urgent';
}

/// Notification categories
class NotificationCategory {
  static const String dating = 'dating';
  static const String social = 'social';
  static const String subscription = 'subscription';
  static const String gamification = 'gamification';
  static const String system = 'system';
  static const String security = 'security';
}
