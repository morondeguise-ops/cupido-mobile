import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:timeago/timeago.dart' as timeago;

import '../../../core/models/notification_model.dart';
import '../../../core/services/user_notification_service.dart';
import '../../../core/services/api_service.dart';
import '../../../core/theme/app_theme.dart';

/// Provider for notification service
final notificationServiceProvider = Provider<UserNotificationService>((ref) {
  return UserNotificationService(ApiService());
});

/// Provider for notifications list
final notificationsProvider = FutureProvider<List<UserNotification>>((ref) async {
  final service = ref.watch(notificationServiceProvider);
  return await service.getNotifications();
});

/// Provider for unread count
final unreadCountProvider = FutureProvider<int>((ref) async {
  final service = ref.watch(notificationServiceProvider);
  return await service.getUnreadCount();
});

class NotificationsScreen extends ConsumerStatefulWidget {
  const NotificationsScreen({super.key});

  @override
  ConsumerState<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends ConsumerState<NotificationsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String _selectedCategory = 'all';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final unreadCountAsync = ref.watch(unreadCountProvider);

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            const Text('Notifications'),
            const SizedBox(width: 8),
            unreadCountAsync.when(
              data: (count) {
                if (count == 0) return const SizedBox.shrink();
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryColor,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    count > 99 ? '99+' : count.toString(),
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.white,
                    ),
                  ),
                );
              },
              loading: () => const SizedBox.shrink(),
              error: (_, __) => const SizedBox.shrink(),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.check_circle_outline),
            onPressed: _markAllAsRead,
            tooltip: 'Mark all as read',
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              // TODO: Navigate to notification settings
            },
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          tabs: const [
            Tab(text: 'All'),
            Tab(text: 'Dating'),
            Tab(text: 'Social'),
            Tab(text: 'System'),
          ],
          onTap: (index) {
            setState(() {
              switch (index) {
                case 0:
                  _selectedCategory = 'all';
                  break;
                case 1:
                  _selectedCategory = NotificationCategory.dating;
                  break;
                case 2:
                  _selectedCategory = NotificationCategory.social;
                  break;
                case 3:
                  _selectedCategory = NotificationCategory.system;
                  break;
              }
            });
          },
        ),
      ),
      body: _buildNotificationsList(),
    );
  }

  Widget _buildNotificationsList() {
    final notificationsAsync = ref.watch(notificationsProvider);

    return notificationsAsync.when(
      data: (notifications) {
        // Filter by category
        final filteredNotifications = _selectedCategory == 'all'
            ? notifications
            : notifications.where((n) => n.category == _selectedCategory).toList();

        if (filteredNotifications.isEmpty) {
          return _buildEmptyState();
        }

        return RefreshIndicator(
          onRefresh: () async {
            ref.invalidate(notificationsProvider);
            ref.invalidate(unreadCountProvider);
          },
          child: ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: filteredNotifications.length,
            separatorBuilder: (context, index) => const Divider(height: 1),
            itemBuilder: (context, index) {
              return _buildNotificationTile(filteredNotifications[index]);
            },
          ),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 48, color: AppTheme.errorColor),
            const SizedBox(height: 16),
            Text('Error loading notifications'),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                ref.invalidate(notificationsProvider);
              },
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.notifications_none,
            size: 80,
            color: AppTheme.lightGray,
          ),
          const SizedBox(height: 16),
          Text(
            'No notifications',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          Text(
            'You\'re all caught up!',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppTheme.textSecondary,
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationTile(UserNotification notification) {
    return Dismissible(
      key: Key('notification_${notification.id}'),
      background: Container(
        color: AppTheme.errorColor,
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 16),
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      direction: DismissDirection.endToStart,
      onDismissed: (direction) {
        _deleteNotification(notification.id);
      },
      child: ListTile(
        onTap: () {
          _handleNotificationTap(notification);
        },
        leading: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: notification.isRead
                ? AppTheme.extraLightGray
                : AppTheme.primaryColor.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(
            _getNotificationIcon(notification.notificationType),
            color: notification.isRead
                ? AppTheme.textSecondary
                : AppTheme.primaryColor,
          ),
        ),
        title: Row(
          children: [
            Expanded(
              child: Text(
                notification.title,
                style: TextStyle(
                  fontWeight: notification.isRead ? FontWeight.normal : FontWeight.bold,
                ),
              ),
            ),
            if (!notification.isRead)
              Container(
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                  color: AppTheme.primaryColor,
                  shape: BoxShape.circle,
                ),
              ),
          ],
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              notification.message,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: AppTheme.textSecondary,
                fontWeight: notification.isRead ? FontWeight.normal : FontWeight.w500,
              ),
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                _buildPriorityBadge(notification.priority),
                const SizedBox(width: 8),
                Text(
                  timeago.format(notification.createdAt),
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppTheme.textSecondary,
                  ),
                ),
                if (notification.isExpired) ...[
                  const SizedBox(width: 8),
                  const Text(
                    '• Expired',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppTheme.errorColor,
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
        trailing: IconButton(
          icon: const Icon(Icons.more_vert, size: 20),
          onPressed: () {
            _showNotificationOptions(notification);
          },
        ),
      ),
    );
  }

  Widget _buildPriorityBadge(String priority) {
    Color color;
    String label;

    switch (priority) {
      case NotificationPriority.urgent:
        color = AppTheme.errorColor;
        label = 'Urgent';
        break;
      case NotificationPriority.high:
        color = Colors.orange;
        label = 'High';
        break;
      case NotificationPriority.low:
        color = AppTheme.lightGray;
        label = 'Low';
        break;
      default:
        return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.bold,
          color: color,
        ),
      ),
    );
  }

  IconData _getNotificationIcon(String type) {
    switch (type) {
      case NotificationType.match:
        return Icons.favorite;
      case NotificationType.message:
        return Icons.message;
      case NotificationType.like:
        return Icons.thumb_up;
      case NotificationType.superLike:
        return Icons.star;
      case NotificationType.boost:
        return Icons.rocket_launch;
      case NotificationType.profileView:
        return Icons.visibility;
      case NotificationType.newFollower:
        return Icons.person_add;
      case NotificationType.comment:
        return Icons.comment;
      case NotificationType.mention:
        return Icons.alternate_email;
      case NotificationType.gift:
        return Icons.card_giftcard;
      case NotificationType.subscription:
        return Icons.credit_card;
      case NotificationType.achievement:
        return Icons.emoji_events;
      case NotificationType.event:
        return Icons.event;
      default:
        return Icons.notifications;
    }
  }

  void _handleNotificationTap(UserNotification notification) async {
    // Mark as read
    if (!notification.isRead) {
      try {
        final service = ref.read(notificationServiceProvider);
        await service.markAsRead(notification.id);
        ref.invalidate(notificationsProvider);
        ref.invalidate(unreadCountProvider);
      } catch (e) {
        // Ignore error, just for UX improvement
      }
    }

    // Handle action
    if (notification.actionUrl != null) {
      // TODO: Navigate to action URL
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Navigate to: ${notification.actionUrl}')),
        );
      }
    }
  }

  void _showNotificationOptions(UserNotification notification) {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (notification.isRead)
              ListTile(
                leading: const Icon(Icons.mark_email_unread),
                title: const Text('Mark as unread'),
                onTap: () {
                  Navigator.pop(context);
                  _markAsUnread(notification.id);
                },
              )
            else
              ListTile(
                leading: const Icon(Icons.mark_email_read),
                title: const Text('Mark as read'),
                onTap: () {
                  Navigator.pop(context);
                  _markAsRead(notification.id);
                },
              ),
            ListTile(
              leading: const Icon(Icons.delete, color: AppTheme.errorColor),
              title: const Text('Delete', style: TextStyle(color: AppTheme.errorColor)),
              onTap: () {
                Navigator.pop(context);
                _deleteNotification(notification.id);
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _markAsRead(int notificationId) async {
    try {
      final service = ref.read(notificationServiceProvider);
      await service.markAsRead(notificationId);
      ref.invalidate(notificationsProvider);
      ref.invalidate(unreadCountProvider);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to mark as read: $e')),
        );
      }
    }
  }

  Future<void> _markAsUnread(int notificationId) async {
    try {
      final service = ref.read(notificationServiceProvider);
      await service.markAsUnread(notificationId);
      ref.invalidate(notificationsProvider);
      ref.invalidate(unreadCountProvider);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to mark as unread: $e')),
        );
      }
    }
  }

  Future<void> _markAllAsRead() async {
    try {
      final service = ref.read(notificationServiceProvider);
      await service.markAllAsRead();
      ref.invalidate(notificationsProvider);
      ref.invalidate(unreadCountProvider);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('All notifications marked as read')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to mark all as read: $e')),
        );
      }
    }
  }

  Future<void> _deleteNotification(int notificationId) async {
    try {
      final service = ref.read(notificationServiceProvider);
      await service.deleteNotification(notificationId);
      ref.invalidate(notificationsProvider);
      ref.invalidate(unreadCountProvider);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Notification deleted')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to delete notification: $e')),
        );
      }
    }
  }
}
