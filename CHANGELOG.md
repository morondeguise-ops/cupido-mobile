# Changelog - Cupido Mobile App

All notable changes to the Cupido Flutter mobile application will be documented in this file.

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

- **v2.0.0** (2025-11-10) - Backend architecture update, environment configs
- **v1.0.0** (2025-11-08) - Initial release
