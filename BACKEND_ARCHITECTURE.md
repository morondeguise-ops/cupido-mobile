# Backend Architecture - Cupido Platform

## Overview

As of v2.0.0, the Cupido backend has been restructured into a modern multi-repository architecture for better modularity, maintainability, and scalability.

---

## Multi-Repository Structure

### 1. cupido-core (v2.0.0)
**Repository:** https://github.com/morondeguise-ops/cupido-core

**Purpose:** Shared models, services, and business logic

**Domain-Based Organization:**

Models organized into 10 business domains:
- **User:** User, Profile, UserPreference, Device, PhoneOtp, UserLocation, ProfilePhoto
- **Dating:** Swipe, UserMatch, Message
- **Social:** Post, Story, Hobby, PostComment, PostLike, etc.
- **Subscriptions:** Subscription, InvitationCode, UserGift, etc.
- **Gamification:** UserAchievement, UserLevel
- **Calendar:** CalendarEvent, CalendarAvailability, etc.
- **Notifications:** UserNotification, PushDevice
- **Admin:** AdminUser, Block, Report, SecurityEvent
- **System:** Settings, Language, Translation, CdnFile, AdPlacement
- **Activity:** CupidoActivityLog

Services organized into 6 functional domains:
- **Notification:** NotificationService, FCMService
- **Communication:** TwilioService, EmailBackupReminderService
- **Location:** LocationService
- **Subscription:** SubscriptionService
- **Gamification:** CondomService, LevelService
- **System:** ActivityLogService, SettingsService, TranslationImportService

**Key Features:**
- 47 models with relationships
- 11 services
- 56 database migrations
- Service contracts (interfaces)
- Security fixes included

---

### 2. cupido-api (v2.0.0)
**Repository:** https://github.com/morondeguise-ops/cupido-api

**Purpose:** REST API backend for mobile application

**Features:**
- 25 API controllers
- Laravel Sanctum authentication
- Form request validation
- JSON API resources
- Rate limiting
- WebSocket support (Laravel Reverb)

**Dependencies:**
- cupido/core ^2.0
- Laravel 12.0
- Laravel Sanctum 4.0

---

### 3. cupido-admin (v2.0.0)
**Repository:** https://github.com/morondeguise-ops/cupido-admin

**Purpose:** Filament admin panel for platform management

**Features:**
- 150+ Filament resources
- User management
- Content moderation
- Analytics dashboards
- Security logging
- IP whitelist
- Session management

**Dependencies:**
- cupido/core ^2.0
- Laravel 12.0
- Filament 4.2

---

### 4. cupido-mobile
**Repository:** Your Flutter application

**Purpose:** Mobile client (iOS/Android)

**Integration:**
- Connects to cupido-api via REST
- WebSocket for real-time features
- Push notifications via Firebase
- Token-based authentication

---

## Architecture Diagram

```
┌─────────────────────────────────────────────────────────────┐
│                    cupido-core (v2.0.0)                      │
│              Models • Services • Business Logic               │
│         Domain-Based: User, Dating, Social, etc.             │
└───────────────┬────────────────────────┬────────────────────┘
                │                        │
                │ Composer dependency    │ Composer dependency
                │                        │
     ┌──────────▼──────────┐  ┌─────────▼──────────┐
     │    cupido-api       │  │   cupido-admin      │
     │   REST API          │  │   Filament Panel    │
     │   Laravel 12        │  │   Management UI     │
     │   Sanctum Auth      │  │   Analytics         │
     └──────────┬──────────┘  └─────────────────────┘
                │
                │ HTTPS / WebSocket
                │
     ┌──────────▼──────────┐
     │   cupido-mobile     │
     │   Flutter App       │
     │   iOS / Android     │
     └─────────────────────┘
```

---

## API Integration

### Base URL

```dart
// Production
static const String apiBaseUrl = 'https://api.cupido.com';

// Staging
static const String apiBaseUrl = 'https://staging-api.cupido.com';

// Development
static const String apiBaseUrl = 'http://localhost:8000';
```

### Authentication

The API uses Laravel Sanctum for token-based authentication:

```dart
// 1. Send OTP
POST /api/auth/send-otp
Body: { "phone": "+1234567890" }

// 2. Verify OTP
POST /api/auth/verify-otp
Body: { "phone": "+1234567890", "code": "123456" }
Response: { "token": "1|abc123...", "user": {...} }

// 3. Use token in requests
Headers: { "Authorization": "Bearer 1|abc123..." }
```

### Endpoints

All endpoints prefixed with `/api`:

**Authentication:**
- `POST /auth/send-otp`
- `POST /auth/verify-otp`
- `GET /auth/me`
- `POST /auth/logout`
- `POST /register`

**Profile:**
- `GET /profile/{userId}`
- `PUT /profile`
- `POST /profile/photos`
- `DELETE /profile/photos/{photoId}`
- `PUT /profile/hobbies`

**Discovery:**
- `GET /discover`
- `POST /discover/swipe`

**Matching:**
- `GET /matches`
- `DELETE /matches/{matchId}`

**Messaging:**
- `GET /messages/{matchId}`
- `POST /messages/{matchId}`

**Social:**
- `GET /posts`
- `POST /posts`
- `POST /posts/{postId}/like`
- `POST /posts/{postId}/comment`
- `GET /stories`
- `POST /stories`

**Premium:**
- `POST /premium/boost`
- `POST /premium/rewind`
- `GET /premium/who-liked-me`

**Subscriptions:**
- `GET /subscriptions`
- `POST /subscriptions`
- `DELETE /subscriptions`

And many more...

---

## Security

### Backend Security Features (v2.0.0)

**Fixed Critical Issues:**
1. ✅ SQL Injection Prevention - LocationService with parameter binding
2. ✅ XSS Protection - Message content sanitization
3. ✅ Exception Exposure Prevention - Generic error messages to clients
4. ✅ Silent Failure Prevention - Comprehensive error logging

**Additional Security:**
- HTTPS enforced in production
- CSRF protection via Sanctum
- Rate limiting on all endpoints
- Input validation via Form Requests
- Token expiration and refresh
- IP whitelist for admin panel
- Activity logging

### Mobile Security

- Token stored in secure storage (flutter_secure_storage)
- HTTPS for all API calls
- Certificate pinning (recommended)
- Input validation
- Secure WebSocket connections (WSS)

---

## Environment Configuration

### Mobile App Setup

Edit `lib/core/config/environment.dart`:

```dart
// Choose your environment
static const Environment currentEnvironment = Environment.production;

// Environments:
// - Environment.development (localhost)
// - Environment.staging (staging server)
// - Environment.production (production server)
```

### API Configuration

The mobile app automatically uses the correct API URL based on environment:

```dart
// Get API URL
String url = AppConfig.getApiUrl('/profile');
// Returns: https://api.cupido.com/api/profile (production)
//      or: http://localhost:8000/api/profile (development)
```

---

## Deployment

### Backend Deployment

**cupido-api (Production):**
```bash
git clone https://github.com/morondeguise-ops/cupido-api.git
cd cupido-api
composer install --no-dev --optimize-autoloader
cp .env.example .env
php artisan key:generate
php artisan migrate --force
php artisan config:cache
php artisan route:cache
```

**cupido-admin (Production):**
```bash
git clone https://github.com/morondeguise-ops/cupido-admin.git
cd cupido-admin
composer install --no-dev --optimize-autoloader
cp .env.example .env
php artisan key:generate
php artisan migrate --force
php artisan filament:cache-components
```

### Mobile Deployment

**iOS:**
```bash
flutter build ios --release
# Submit to App Store via Xcode
```

**Android:**
```bash
flutter build appbundle --release
# Submit to Google Play Console
```

---

## Version Compatibility

| Mobile App | cupido-api | cupido-core | Status |
|------------|------------|-------------|---------|
| v2.0.0 | v2.0.0 | v2.0.0 | ✅ Current |
| v1.0.0 | v1.0.0 | v1.0.0 | ⚠️ Legacy |

---

## Migration Guide

### Updating from v1.0.0 to v2.0.0

**Good News:** No code changes required in mobile app!

The API structure remains identical between v1.0.0 and v2.0.0. The backend refactoring was purely architectural and maintains full backward compatibility.

**What Changed:**
- Backend split into separate repositories
- Models organized by domain
- Services reorganized
- Security improvements
- Better code organization

**What Stayed the Same:**
- All API endpoints
- Authentication flow
- Request/response formats
- WebSocket connections
- Push notifications

**Steps:**
1. Update environment configuration if needed
2. Test against new API endpoints
3. Deploy updated mobile app

---

## Support & Resources

**Documentation:**
- cupido-core: See MIGRATION_GUIDE.md for namespace changes
- cupido-api: See README.md for API documentation
- cupido-admin: See README.md for admin panel guide
- cupido-mobile: See this file and CHANGELOG.md

**Issues:**
- Core issues: https://github.com/morondeguise-ops/cupido-core/issues
- API issues: https://github.com/morondeguise-ops/cupido-api/issues
- Admin issues: https://github.com/morondeguise-ops/cupido-admin/issues
- Mobile issues: Your repository issues

**Contact:**
- For backend questions: Create issue in relevant backend repository
- For mobile questions: Create issue in mobile repository

---

## Development Workflow

### Local Development Setup

**1. Start Backend API:**
```bash
cd cupido-api
php artisan serve
# API available at http://localhost:8000
```

**2. Update Mobile Config:**
```dart
// lib/core/config/environment.dart
static const Environment currentEnvironment = Environment.development;
```

**3. Run Mobile App:**
```bash
flutter run
```

**4. Monitor Logs:**
```bash
# API logs
tail -f cupido-api/storage/logs/laravel.log

# Mobile logs
flutter logs
```

---

## Best Practices

### API Integration

1. **Always use environment config** - Don't hardcode URLs
2. **Handle errors gracefully** - Show user-friendly messages
3. **Implement retry logic** - For network failures
4. **Cache responses** - Where appropriate
5. **Validate input** - Before sending to API
6. **Monitor performance** - Track API response times

### Security

1. **Never log sensitive data** - Tokens, passwords, personal info
2. **Use HTTPS** - Always in production
3. **Validate SSL certificates** - Implement certificate pinning
4. **Rotate tokens** - Handle token expiration
5. **Clear storage on logout** - Remove all sensitive data

### Testing

1. **Test all environments** - Development, staging, production
2. **Test offline mode** - Handle network failures
3. **Test edge cases** - Empty states, errors, timeouts
4. **Test on real devices** - iOS and Android
5. **Test push notifications** - End-to-end flow

---

## Changelog

See [CHANGELOG.md](CHANGELOG.md) for detailed version history and changes.

---

## License

Proprietary - © 2025 Cupido Team
