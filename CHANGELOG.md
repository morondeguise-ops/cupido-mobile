# Changelog - Cupido Mobile App

All notable changes to the Cupido Flutter mobile application will be documented in this file.

## [2.2.0] - 2025-11-11

### Added - UI Screens for New Features

Added comprehensive UI screens for all new models and features introduced in v2.1.0.

## [2.1.0] - 2025-11-11

### Added - New Models and Features

**New Models:**

1. **Chat System** (`lib/core/models/chat_model.dart`):
   - `ChatConversation` - Support for direct, group, and channel conversations
   - `ChatMessage` - Rich messaging with attachments, editing, and deletion support
   - Message types: text, image, video, audio, file, system

2. **Enhanced Notifications** (`lib/core/models/notification_model.dart`):
   - `UserNotification` - Comprehensive notification system
   - Support for multiple notification types: match, message, like, super_like, boost, profile_view, etc.
   - Priority levels: low, normal, high, urgent
   - Categories: dating, social, subscription, gamification, system, security
   - Channel preferences and metadata support

3. **Kink Interests** (`lib/core/models/kink_model.dart`):
   - `KinkInterest` - Browse and discover kink interests
   - `UserKinkInterest` - Manage personal kink preferences with privacy controls
   - Privacy levels: public, matches_only, private
   - Age restriction and verification support
   - Categories: romantic, physical, roleplay, lifestyle, fetish, bdsm, other

**New Services:**

1. **ChatService** (`lib/core/services/chat_service.dart`):
   - Create and manage conversations
   - Send, edit, and delete messages
   - Mark messages as read
   - Search messages
   - Upload attachments
   - Typing indicators

2. **UserNotificationService** (`lib/core/services/user_notification_service.dart`):
   - Fetch notifications with filtering
   - Mark as read/unread
   - Manage notification preferences
   - Get unread counts
   - Clear expired notifications

3. **KinkService** (`lib/core/services/kink_service.dart`):
   - Browse kink interests by category
   - Add/remove kink interests to profile
   - Update privacy settings
   - Get kink compatibility with other users
   - Search and get recommendations

**New Screens:**

1. **Chat Screens** (`lib/features/messages/screens/`):
   - `conversations_screen.dart` - List all conversations with unread indicators
   - `chat_detail_screen.dart` - Full-featured chat with message editing, deletion, and attachments
   - Support for direct, group, and channel conversations
   - Date separators and message timestamps
   - Typing indicators and read receipts

2. **Notifications Screen** (`lib/features/notifications/screens/`):
   - `notifications_screen.dart` - Comprehensive notifications list with tabs
   - Filter by category (All, Dating, Social, System)
   - Unread count badge in app bar
   - Swipe to delete notifications
   - Priority badges (Low, Normal, High, Urgent)
   - Mark all as read functionality

3. **Kink Interests Screens** (`lib/features/kinks/screens/`):
   - `kink_interests_browse_screen.dart` - Browse and search all available kink interests
   - `user_kinks_screen.dart` - Manage personal kink interests with privacy controls
   - Category filtering and search
   - Privacy level management (Public, Matches Only, Private)
   - Age restriction and verification indicators
   - Statistics dashboard showing total, verified, and public interests

**Updated Models:**

1. **User Model** (`lib/core/models/user_model.dart`):
   - Added `isFake` field to support fake user profiles for testing/demo
   - Fake users are marked in backend but appear normal to regular users
   - Only admins can see the fake user indicator

**Backend Compatibility:**

- Compatible with cupido-core v2.0.0+
- Compatible with cupido-admin v2.0.0+ (with new Filament resources)
- New migrations added to backend: 68 tables including chat, notifications, kink interests
- FakeUsersSeeder available in backend for generating test data

**Example Data:**

Backend now includes:
- `FakeUsersSeeder` - Generate realistic fake users with profiles and hobbies
- `GamificationSeeder` - Seed gamification data
- `AdminUserSeeder` - Create admin users
- `SettingsSeeder` - Initialize app settings

### Technical Details

**New API Endpoints (Expected):**

```
Chat:
GET    /chat/conversations
POST   /chat/conversations
GET    /chat/conversations/{id}
GET    /chat/conversations/{id}/messages
POST   /chat/conversations/{id}/messages
PUT    /chat/conversations/{id}/messages/{messageId}
DELETE /chat/conversations/{id}/messages/{messageId}

Notifications:
GET    /notifications
GET    /notifications/{id}
POST   /notifications/{id}/read
POST   /notifications/mark-all-read
DELETE /notifications/{id}
GET    /notifications/unread-count

Kinks:
GET    /kinks
GET    /kinks/{id}
GET    /kinks/categories
GET    /profile/kinks
POST   /profile/kinks
PUT    /profile/kinks/{id}
DELETE /profile/kinks/{id}
GET    /users/{id}/kink-compatibility
```

**Model Mapping to Backend:**

- Flutter `ChatConversation` ↔ Laravel `Cupido\Core\Models\Chat\ChatConversation`
- Flutter `ChatMessage` ↔ Laravel `Cupido\Core\Models\Chat\ChatMessage`
- Flutter `UserNotification` ↔ Laravel `Cupido\Core\Models\Notifications\UserNotification`
- Flutter `KinkInterest` ↔ Laravel `Cupido\Core\Models\Kink\KinkInterest`

---

## [2.0.0] - 2025-11-10

### Changed - Backend Architecture Update

**Multi-Repository Architecture**

The Cupido backend has been restructured into separate repositories for better modularity and maintainability:

- **cupido-core v2.0.0** - Shared models, services, and business logic with domain-based organization
- **cupido-api v2.0.0** - REST API backend (https://github.com/morondeguise-ops/cupido-api)
- **cupido-admin v2.0.0** - Filament admin panel (https://github.com/morondeguise-ops/cupido-admin)

**API Compatibility**

- ✅ **No breaking changes** - All API endpoints remain the same
- ✅ **Same authentication** - Sanctum token-based auth unchanged
- ✅ **Same responses** - JSON response structure maintained
- ✅ **Backward compatible** - This version works with both old and new backends

**What Changed in Backend:**

1. **Domain-Based Models** (cupido-core v2.0.0):
   - User models: `Cupido\Core\Models\User\*`
   - Dating models: `Cupido\Core\Models\Dating\*`
   - Social models: `Cupido\Core\Models\Social\*`
   - Better code organization by business domain

2. **Security Improvements:**
   - ✅ SQL injection prevention in location queries
   - ✅ XSS protection in message content
   - ✅ Exception exposure prevention
   - ✅ Silent failure prevention with error logging

3. **Service Organization:**
   - Services reorganized into functional domains
   - Better separation of concerns
   - Enhanced modularity

**Mobile App Updates:**

- Added environment configuration (`lib/core/config/environment.dart`)
- Support for multiple environments (development, staging, production)
- Updated documentation with new architecture details
- No code changes required for API compatibility

**Environment Configuration:**

```dart
// Switch between environments in environment.dart
static const Environment currentEnvironment = Environment.development;

// Development
'apiBaseUrl': 'http://localhost:8000'

// Staging
'apiBaseUrl': 'https://staging-api.cupido.com'

// Production
'apiBaseUrl': 'https://api.cupido.com'
```

**Migration Notes:**

- If upgrading from v1.x, no changes needed to mobile app code
- API endpoints remain identical
- Authentication flow unchanged
- All features continue to work as before

**Testing:**

- ✅ Authentication flow verified
- ✅ Profile management tested
- ✅ Discovery and matching tested
- ✅ Messaging functionality verified
- ✅ Push notifications working
- ✅ WebSocket connections stable

### Technical Details

**API Structure (Unchanged):**
```
Base URL: https://api.cupido.com/api

Authentication:
POST /auth/send-otp
POST /auth/verify-otp
GET  /auth/me
POST /auth/logout

Profile:
GET  /profile/{userId}
PUT  /profile
POST /profile/photos
PUT  /profile/hobbies

Discovery:
GET  /discover
POST /discover/swipe

Matching:
GET  /matches
GET  /messages/{matchId}
POST /messages/{matchId}

... (all other endpoints unchanged)
```

**Dependencies:**

Backend now uses:
- Laravel 12.0
- cupido-core v2.0.0 (domain-based architecture)
- Filament 4.2 (admin panel)

Mobile app continues using:
- Flutter SDK
- Dio (HTTP client)
- Riverpod (state management)
- Firebase (push notifications)

---

## [1.0.0] - 2025-11-08

### Added
- Initial release of Cupido dating mobile application
- User authentication with OTP verification
- Profile creation and management
- Discovery and swiping functionality
- Matching system
- Real-time messaging
- Social features (posts, stories)
- Premium features (boost, rewind, super likes)
- Calendar dating events
- Gamification (levels, achievements, virtual currency)
- Multi-language support
- Push notifications
- WebSocket real-time updates

### Security
- Token-based authentication
- Secure storage for sensitive data
- HTTPS for all API calls
- Input validation and sanitization

---

## Version History

- **v2.2.0** (2025-11-11) - UI screens for Chat, Notifications, and Kink Interests
- **v2.1.0** (2025-11-11) - New models and features: Chat, Enhanced Notifications, Kink Interests
- **v2.0.0** (2025-11-10) - Backend architecture update, environment configs
- **v1.0.0** (2025-11-08) - Initial release
