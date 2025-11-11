# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

Cupido Mobile (v2.1.0) - Flutter-based exclusive dating app with OTP authentication, swipe discovery, real-time messaging, social feeds, and premium subscriptions. Connects to Laravel backend (cupido-api v2.0.0) using REST API + WebSocket.

## Core Principles

### Design Principles

- **DRY (Don't Repeat Yourself)** - Eliminate code duplication
- **YAGNI (You Aren't Gonna Need It)** - Don't build what you don't need yet
- **KISS (Keep It Simple, Stupid)** - Simple solutions over complex ones
- **SOLID** - Single responsibility, Open/closed, Liskov substitution, Interface segregation, Dependency inversion

### Priorities

- **Clarity > Cleverness** - Readable code beats smart tricks
- **Consistency > Optimization** - Maintainability over micro-optimizations

### Development Actions

- ✅ **No Hardcoding** - Use config files, environment variables
- ✅ **Stateless** - Functions should be stateless where possible
- ✅ **Confirm Changes** - Verify before destructive operations
- ✅ **Fail Loudly** - Explicit errors, never silent failures
- ✅ **Sanitize Inputs** - Validate and sanitize all user input
- ✅ **Reversible Changes** - Git commits, migrations, backups
- ✅ **Test Behavior** - Test actual behavior, not implementation
- ✅ **Explicit Dependencies** - No magic, clear imports and dependencies

## Development Commands

### Setup & Installation
```bash
# Install dependencies
flutter pub get

# Generate code (for Hive models)
flutter pub run build_runner build --delete-conflicting-outputs
```

### Running the App
```bash
# List available devices
flutter devices

# Run on specific device
flutter run -d chrome          # Web (Chrome)
flutter run -d linux           # Linux desktop
flutter run -d <device-id>     # Android/iOS emulator

# Run with specific flavor (when implemented)
flutter run --dart-define=ENVIRONMENT=development
```

### Building
```bash
# Android
flutter build apk --release
flutter build appbundle --release

# iOS
flutter build ios --release

# Web
flutter build web --release
```

### Testing & Quality
```bash
# Run tests (when implemented)
flutter test

# Analyze code
flutter analyze

# Format code
dart format lib/

# Check for outdated packages
flutter pub outdated
```

### Code Generation
```bash
# Watch mode for Hive generators
flutter pub run build_runner watch

# Clean and rebuild
flutter pub run build_runner clean
flutter pub run build_runner build --delete-conflicting-outputs
```

## Architecture Overview

### Clean Architecture with Feature-Based Organization

```
lib/
├── core/              # Shared infrastructure
│   ├── config/        # Environment, app config, constants
│   ├── models/        # Data models (User, Post, Match, Chat, etc.)
│   ├── services/      # Business logic (19 services)
│   ├── providers/     # Riverpod state management
│   ├── routes/        # Navigation routing
│   ├── theme/         # Material 3 theming
│   └── widgets/       # Reusable components
└── features/          # Feature modules (auth, discover, feed, etc.)
    └── [feature]/
        ├── screens/   # Full-page screens
        └── widgets/   # Feature-specific widgets
```

### Dependency Flow
```
Features → Providers → Services → ApiService → Backend
                ↓
             Models
```

## State Management (Riverpod)

### Pattern: StateNotifier + Provider

All state management uses Riverpod with this pattern:

```dart
// 1. Immutable State class
class SomeState {
  final bool isLoading;
  final Data? data;
  final String? error;

  SomeState copyWith({...}) { ... }
}

// 2. StateNotifier with business logic
class SomeNotifier extends StateNotifier<SomeState> {
  final SomeService _service;

  SomeNotifier(this._service) : super(SomeState()) {
    _initialize();  // Auto-load on creation
  }
}

// 3. Provider declaration
final someProvider = StateNotifierProvider<SomeNotifier, SomeState>(
  (ref) => SomeNotifier(ref.read(someServiceProvider)),
);
```

### Key Providers
- `authProvider` - Authentication state (user, token, isAuthenticated)
- `discoverProvider` - Discovery queue and swipe logic
- `matchesProvider` - Matches list management
- `messagesProvider.family(matchId)` - Chat messages per match (family provider)
- `feedProvider` - Social feed with pagination
- `storiesProvider` - Ephemeral stories

### Provider Families
Use for parameterized state (e.g., messages per match):
```dart
final messagesProvider = StateNotifierProvider.family<
    MessagesNotifier, MessagesState, int>((ref, matchId) {
  return MessagesNotifier(ref.read(matchServiceProvider), matchId);
});

// Usage: ref.watch(messagesProvider(matchId))
```

## API Integration

### Three-Layer Architecture

**Layer 1: ApiService (Core HTTP Client)**
- Based on Dio
- Automatic JWT token injection via interceptors
- Token stored in flutter_secure_storage
- Error transformation to ApiException
- Request/response logging in debug mode

**Layer 2: Domain Services (19 services)**
- `AuthService` - OTP authentication flow
- `ProfileService` - User profile and photo management
- `DiscoverService` - Discovery queue and swipe actions
- `MatchService` - Matches and messaging
- `ChatService` - Advanced chat features (v2.1)
- `WebSocketService` - Real-time messaging
- `SubscriptionService` - RevenueCat integration
- Others: Post, Story, Notification, Location, Analytics, Ads, etc.

**Layer 3: Providers**
- Riverpod providers wrap services
- Manage UI state (loading, data, error)

### Authentication Flow
```
1. POST /api/auth/send-otp (phone)
2. POST /api/auth/verify-otp (phone, otp) → returns JWT token
3. Store token in secure storage
4. Auto-inject in all requests via Dio interceptor
5. On 401, clear token and redirect to login
```

### API Base URLs (Environment-based)
Configured in `/lib/core/config/environment.dart`:
- Development: `http://localhost:8000`
- Staging: `https://staging-api.cupido.com`
- Production: `https://api.cupido.com`

All endpoints prefixed with `/api`

## WebSocket Real-Time Features

### CppServer Protocol

**Connection Flow:**
```
1. Connect to wss://api.cupido.com
2. Server sends: { "type": "auth_required" }
3. Client responds: { "type": "auth", "token": "JWT_TOKEN" }
4. Server confirms: { "type": "success" }
5. Ready for events
```

**Event Types:**
- `new_message` - Incoming chat messages
- `user_typing` - Typing indicators
- `new_match` - Match notifications
- `read_receipt` - Message read status

**Usage in ChatScreen:**
```dart
// Listen to messages
webSocketService.messageStream.listen((data) {
  // Update UI with new message
});

// Send typing indicator
webSocketService.sendTyping(matchId, true);

// Send read receipt
webSocketService.sendReadReceipt(matchId, messageId);
```

**Auto-reconnection:** Reconnects after 5 seconds on disconnect

## Navigation & Routing

**Router:** Imperative routing with named routes in `/lib/core/routes/app_router.dart`

### Main Flows
1. **Auth Flow:** welcome → phone-auth → otp-verification → registration
2. **Onboarding:** profile-setup → photo-upload → hobby-selection
3. **Main App:** home (with bottom nav: discover/matches/feed/profile)
4. **Secondary:** chat, settings, edit-profile

### Passing Arguments
```dart
Navigator.pushNamed(
  context,
  AppRouter.chat,
  arguments: {
    'matchId': matchId,
    'matchedUser': matchedUser,
  },
);
```

## Firebase Integration

### Required Setup Files
- Android: `google-services.json` in `android/app/`
- iOS: `GoogleService-Info.plist` in `ios/Runner/`

### Push Notifications
**File:** `/lib/core/services/notification_service.dart`

**Three notification states:**
- Foreground: App open - show local notification
- Background: App backgrounded - OS notification
- Terminated: App closed - notification opens app

**Device token registration:**
```dart
1. Initialize Firebase
2. Request permissions
3. Get FCM device token
4. Register token with backend (POST /api/fcm-token)
```

## Coding Conventions

### File Naming
- snake_case: `auth_provider.dart`, `user_model.dart`
- Screens: `*_screen.dart` (e.g., `chat_screen.dart`)
- Services: `*_service.dart` (e.g., `auth_service.dart`)
- Providers: `*_provider.dart` (e.g., `auth_provider.dart`)
- Models: `*_model.dart` (e.g., `user_model.dart`)

### Model Pattern
All models include:
```dart
class User {
  final int id;
  final String phone;

  // Deserialization from API
  factory User.fromJson(Map<String, dynamic> json) { ... }

  // Serialization for API
  Map<String, dynamic> toJson() { ... }

  // Computed properties
  int get age { ... }
}
```

### Error Handling
**Services:** Catch DioException, transform to ApiException
**Providers:** Catch errors, store in state.error, update UI

### Optimistic Updates
For better UX, update UI immediately, then sync with API:
```dart
// 1. Update UI
state = state.copyWith(posts: optimisticUpdate);

// 2. API call
await _service.likePost(postId);

// 3. On error, revert
catch (e) {
  loadFeed(); // Reload from server
}
```

## Key Models

### Core Business Models (8 domains)
- `user_model.dart` - User, Profile, ProfilePhoto, UserHobby
- `chat_model.dart` - ChatConversation, ChatMessage (v2.1)
- `match_model.dart` - Match, Message
- `post_model.dart` - Post, Comment, Story
- `discover_model.dart` - DiscoveryCandidate, SwipeAction
- `hobby_model.dart` - Hobby with skill levels (1-5)
- `notification_model.dart` - Push notification data
- `ad_placement.dart` - AdMob placement config

## Asset Structure

```
assets/
├── images/       # General images
├── icons/        # Icon files
├── animations/   # Lottie animations
├── logos/        # Brand logos
└── fonts/        # Inter font family (Regular, Medium, SemiBold, Bold)
```

## Environment Configuration

**File:** `/lib/core/config/environment.dart`

Switch environments:
```dart
static const Environment currentEnvironment = Environment.development;
```

**Environments:**
- `development` - localhost:8000
- `staging` - staging-api.cupido.com
- `production` - api.cupido.com

## Theme & Design

**File:** `/lib/core/theme/app_theme.dart`

- Material 3 design system
- Primary color: #6C5CE7 (purple)
- Font: Inter (weights: 400, 500, 600, 700)
- Light and dark themes supported
- Custom component themes for buttons, cards, inputs

## Common Development Tasks

### Adding a New Feature
1. Create feature directory in `lib/features/[feature_name]/`
2. Add screens in `screens/` subdirectory
3. Add feature-specific widgets in `widgets/`
4. Create service in `lib/core/services/` if API integration needed
5. Create provider in `lib/core/providers/` for state management
6. Add routes in `app_router.dart`
7. Add navigation from existing screens

### Adding a New API Endpoint
1. Add method to appropriate service in `lib/core/services/`
2. Define response model in `lib/core/models/` if needed
3. Call from provider or screen
4. Handle loading/error states in UI

### Adding New Model
1. Create in `lib/core/models/`
2. Add `fromJson` factory constructor
3. Add `toJson` method
4. Add computed properties if needed
5. If using Hive, add annotations and run code generation

### Implementing Real-time Feature
1. Define event type in WebSocketService
2. Add handler method in service
3. Listen to `messageStream` in screen
4. Update Riverpod state on events
5. UI auto-updates via provider watch

## Backend Architecture

**Multi-repository setup:**
- **cupido-core** - Shared Laravel package with models and business logic
- **cupido-api** - REST API with Sanctum authentication (10 domains)
- **cupido-admin** - Filament admin panel

**Backend Domains (v2.0.0):**
1. Auth - OTP-based authentication
2. Profile - User profiles and photos
3. Discovery - Swipe algorithm and queue
4. Match - Match creation and management
5. Chat - Real-time messaging
6. Post - Social feed
7. Story - Ephemeral stories
8. Sponsor - Invitation system
9. Subscription - Premium features
10. Notification - Push notifications

## Known Issues & TODOs

From README.md:
- Some API endpoints are placeholders (marked with `// TODO:`)
- WebSocket integration incomplete in some chat screens
- Image compression before upload needs implementation
- Story viewer timer not implemented
- Missing: deep linking, analytics tracking, unit tests, CI/CD
- Firebase configuration files must be added manually
- Location permission handling needs refinement

## Monetization

**Subscriptions:** RevenueCat integration (`SubscriptionService`)
- Premium features: unlimited swipes, see who liked you, ad removal

**Ads:** Google Mobile Ads (`AdService`)
- Banner ads via `AdBannerWidget`
- Interstitial and rewarded ads supported
- Ad placement configuration in `ad_placement.dart`

## Version Compatibility

- Flutter SDK: >=3.2.0 <4.0.0
- Dart SDK: >=3.2.0
- Backend: cupido-api v2.0.0, cupido-core v2.0.0
- Current app version: 2.1.0+3

## Credentials & Access Tokens

### GitHub Personal Access Token (Classic)
**Note:** Store tokens securely in environment variables or secure credential managers. Never commit tokens to the repository.

**Permissions:** Full repository access
**Usage:** For GitHub API operations, cloning private repos, CI/CD pipelines
