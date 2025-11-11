# New Features in Cupido Mobile v2.1.0

This document summarizes the new models, services, and features added to support the updated backend (cupido-core v2.0.0 and cupido-admin v2.0.0).

## Overview

Version 2.1.0 adds support for three major new features from the backend:

1. **Chat System** - Direct messaging, group chats, and channels
2. **Enhanced Notifications** - Comprehensive notification management
3. **Kink Interests** - User preferences with privacy controls

---

## New Models

### 1. Chat Models (`lib/core/models/chat_model.dart`)

#### ChatConversation
Represents a conversation between users.

**Properties:**
- `id`, `conversationId` - Identifiers
- `type` - Conversation type (direct, group, channel)
- `participants` - List of user IDs
- `title` - Optional conversation title
- `isActive` - Whether conversation is active
- `lastMessageAt` - Timestamp of last message
- `metadata` - Additional data
- `recentMessages` - Optional list of recent messages

**Usage:**
```dart
final conversation = ChatConversation.fromJson(json);
print('Type: ${conversation.type}');
print('Participants: ${conversation.participants.length}');
```

#### ChatMessage
Represents a single message in a conversation.

**Properties:**
- `id`, `messageId` - Identifiers
- `conversationId`, `senderId` - References
- `content` - Message content
- `messageType` - Type (text, image, video, audio, file, system)
- `attachments` - List of attachments
- `sentAt` - Send timestamp
- `isEdited`, `editedAt` - Edit tracking
- `isDeleted`, `deletedAt` - Deletion tracking
- `metadata` - Additional data
- `sender` - Optional sender object

**Usage:**
```dart
final message = ChatMessage.fromJson(json);
if (message.messageType == ChatMessageType.image) {
  // Display image attachment
}
if (message.isEdited) {
  // Show "edited" indicator
}
```

---

### 2. Notification Model (`lib/core/models/notification_model.dart`)

#### UserNotification
Comprehensive notification with multi-channel support.

**Properties:**
- `id`, `userId`, `senderId` - Identifiers
- `notificationType` - Type of notification
- `title`, `message` - Content
- `actionUrl`, `actionData` - Action handling
- `priority` - Priority level (low, normal, high, urgent)
- `isRead`, `isPushSent`, `isEmailSent` - Status flags
- `readAt`, `expiresAt` - Timestamps
- `category` - Category (dating, social, subscription, etc.)
- `channelPreferences`, `metadata` - Additional data
- `sender` - Optional sender object

**Notification Types:**
- `match`, `message`, `like`, `super_like`, `boost`
- `profile_view`, `new_follower`, `comment`, `mention`
- `gift`, `subscription`, `achievement`, `event`, `system`

**Usage:**
```dart
final notification = UserNotification.fromJson(json);

// Check priority
if (notification.priority == NotificationPriority.urgent) {
  // Show as priority notification
}

// Check category
if (notification.category == NotificationCategory.dating) {
  // Show dating-specific notification
}

// Handle expiration
if (notification.isExpired) {
  // Don't show expired notification
}
```

---

### 3. Kink Interest Models (`lib/core/models/kink_model.dart`)

#### KinkInterest
Represents a kink or interest category.

**Properties:**
- `id`, `name`, `slug` - Identifiers
- `description`, `category`, `icon` - Display info
- `ageRestricted` - Whether age-restricted
- `requiresVerification` - Whether verification needed
- `isActive` - Whether active
- `sortOrder` - Display order

**Categories:**
- romantic, physical, roleplay, lifestyle, fetish, bdsm, other

**Usage:**
```dart
final kink = KinkInterest.fromJson(json);
if (kink.ageRestricted) {
  // Check user age before displaying
}
if (kink.requiresVerification) {
  // Show verification requirement
}
```

#### UserKinkInterest
User's personal kink interest with privacy settings.

**Properties:**
- `id`, `userId`, `kinkInterestId` - Identifiers
- `privacyLevel` - Privacy setting (public, matches_only, private)
- `isVerified`, `verifiedAt` - Verification status
- `kinkInterest` - Optional KinkInterest object

**Privacy Levels:**
- `public` - Visible to all users
- `matches_only` - Visible only to matches
- `private` - Hidden from all users

**Usage:**
```dart
final userKink = UserKinkInterest.fromJson(json);
if (userKink.privacyLevel == KinkPrivacyLevel.matchesOnly) {
  // Only show to matched users
}
```

---

## New Services

### 1. ChatService (`lib/core/services/chat_service.dart`)

Manages chat conversations and messages.

**Key Methods:**

```dart
// Get conversations
List<ChatConversation> conversations = await chatService.getConversations(
  type: ConversationType.direct,
  isActive: true,
);

// Create conversation
ChatConversation conversation = await chatService.createConversation(
  type: ConversationType.direct,
  participants: [userId1, userId2],
);

// Send message
ChatMessage message = await chatService.sendMessage(
  conversationId: conversationId,
  content: 'Hello!',
  messageType: ChatMessageType.text,
);

// Get messages
List<ChatMessage> messages = await chatService.getMessages(
  conversationId,
  perPage: 50,
);

// Edit message
await chatService.editMessage(
  conversationId: conversationId,
  messageId: messageId,
  content: 'Updated message',
);

// Delete message
await chatService.deleteMessage(
  conversationId: conversationId,
  messageId: messageId,
);

// Mark as read
await chatService.markConversationAsRead(conversationId);

// Get unread count
int unreadCount = await chatService.getUnreadCount();
```

---

### 2. UserNotificationService (`lib/core/services/user_notification_service.dart`)

Manages user notifications.

**Key Methods:**

```dart
// Get notifications
List<UserNotification> notifications = await notificationService.getNotifications(
  isRead: false,
  category: NotificationCategory.dating,
);

// Get unread notifications
List<UserNotification> unread = await notificationService.getUnreadNotifications();

// Mark as read
await notificationService.markAsRead(notificationId);

// Mark all as read
await notificationService.markAllAsRead();

// Get unread count
int unreadCount = await notificationService.getUnreadCount();

// Get counts by category
Map<String, int> counts = await notificationService.getCountsByCategory();

// Delete notification
await notificationService.deleteNotification(notificationId);

// Get/update settings
Map<String, dynamic> settings = await notificationService.getNotificationSettings();
await notificationService.updateNotificationSettings(settings);
```

---

### 3. KinkService (`lib/core/services/kink_service.dart`)

Manages kink interests and user preferences.

**Key Methods:**

```dart
// Get all kink interests
List<KinkInterest> kinks = await kinkService.getKinkInterests(
  category: KinkCategory.romantic,
  isActive: true,
);

// Get kink by category
List<KinkInterest> romanticKinks = await kinkService.getKinkInterestsByCategory(
  KinkCategory.romantic,
);

// Get user's kinks
List<UserKinkInterest> userKinks = await kinkService.getUserKinkInterests();

// Add kink to profile
UserKinkInterest userKink = await kinkService.addKinkInterest(
  kinkInterestId: kinkId,
  privacyLevel: KinkPrivacyLevel.matchesOnly,
);

// Update privacy
await kinkService.updateKinkPrivacy(
  userKinkInterestId: userKinkId,
  privacyLevel: KinkPrivacyLevel.publicLevel,
);

// Remove kink
await kinkService.removeKinkInterest(userKinkId);

// Search kinks
List<KinkInterest> results = await kinkService.searchKinkInterests('bondage');

// Get recommendations
List<KinkInterest> recommended = await kinkService.getRecommendedKinks();

// Get compatibility
Map<String, dynamic> compatibility = await kinkService.getKinkCompatibility(otherUserId);
```

---

## Updated Models

### User Model Updates

The `User` model has been updated with a new field:

**New Property:**
- `isFake` (bool) - Indicates if this is a fake/demo user

**Purpose:**
- Backend can generate realistic fake users for testing
- Fake users appear normal to regular users
- Only admins can see the fake user indicator
- Useful for populating the app with realistic demo data

**Usage:**
```dart
final user = User.fromJson(json);
if (user.isFake) {
  // In admin mode, show indicator
  // In normal mode, treat as regular user
}
```

---

## API Integration

The new services expect these API endpoints (should be implemented in cupido-api):

### Chat Endpoints
```
GET    /api/chat/conversations
POST   /api/chat/conversations
GET    /api/chat/conversations/{id}
GET    /api/chat/conversations/{id}/messages
POST   /api/chat/conversations/{id}/messages
PUT    /api/chat/conversations/{id}/messages/{messageId}
DELETE /api/chat/conversations/{id}/messages/{messageId}
POST   /api/chat/conversations/{id}/read
GET    /api/chat/unread-count
```

### Notification Endpoints
```
GET    /api/notifications
GET    /api/notifications/{id}
POST   /api/notifications/{id}/read
POST   /api/notifications/{id}/unread
POST   /api/notifications/mark-all-read
DELETE /api/notifications/{id}
GET    /api/notifications/unread-count
GET    /api/notifications/counts-by-category
GET    /api/notifications/settings
PUT    /api/notifications/settings
```

### Kink Endpoints
```
GET    /api/kinks
GET    /api/kinks/{id}
GET    /api/kinks/categories
GET    /api/kinks/search
GET    /api/kinks/recommended
GET    /api/profile/kinks
POST   /api/profile/kinks
PUT    /api/profile/kinks/{id}
DELETE /api/profile/kinks/{id}
GET    /api/users/{id}/kink-compatibility
```

---

## Backend Compatibility

These changes are compatible with:
- **cupido-core v2.0.0+** - Contains the new models
- **cupido-admin v2.0.0+** - Contains Filament resources for admin management
- **cupido-api v2.0.0+** - Should implement the new endpoints

The backend now includes:
- 68 new database migrations
- ChatMessage and ChatConversation models
- UserNotification model with soft deletes
- KinkInterest model
- FakeUsersSeeder for generating test data

---

## Migration Notes

### For Developers

1. **No Breaking Changes**
   - All existing features continue to work
   - New models are additive
   - Existing API endpoints unchanged

2. **Service Initialization**
   ```dart
   // Initialize new services
   final apiService = ApiService();
   final chatService = ChatService(apiService);
   final notificationService = UserNotificationService(apiService);
   final kinkService = KinkService(apiService);
   ```

3. **Error Handling**
   - All services use the same error handling as existing services
   - API exceptions are caught and handled
   - Network errors are properly reported

4. **State Management**
   - Services can be used with existing Riverpod providers
   - Models work with existing state management patterns

### For Backend Developers

Ensure cupido-api implements the new endpoints listed above. The models and relationships are already defined in cupido-core v2.0.0.

---

## Testing

To test the new features:

1. **Chat System**
   - Create a conversation
   - Send messages
   - Test message editing/deletion
   - Verify read receipts

2. **Notifications**
   - Trigger various notification types
   - Test read/unread status
   - Verify filtering by category
   - Test notification preferences

3. **Kink Interests**
   - Browse kink categories
   - Add kinks to profile
   - Test privacy settings
   - Verify compatibility matching

---

## Future Enhancements

Potential features to implement:

1. **Chat**
   - Real-time message updates via WebSocket
   - Push notifications for new messages
   - Voice messages
   - Message reactions
   - Message forwarding

2. **Notifications**
   - Rich notifications with images
   - Grouped notifications
   - Notification actions (quick reply, etc.)
   - Custom notification sounds

3. **Kink Interests**
   - Kink matching algorithm
   - Kink-based discovery
   - Educational content about kinks
   - Community discussions

---

## Support

For questions or issues:
- Backend models: See cupido-core repository
- API endpoints: See cupido-api repository
- Admin panel: See cupido-admin repository
- Mobile app: This repository

---

**Version:** 2.1.0
**Date:** November 11, 2025
**Compatibility:** cupido-core v2.0.0+, cupido-api v2.0.0+, cupido-admin v2.0.0+
