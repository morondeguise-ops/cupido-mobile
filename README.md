# Cupido Flutter App

A Flutter mobile application for Cupido - an exclusive, community-vetted social discovery platform connecting people through shared passions and hobbies.

## Features

### Core Features
- **OTP-Based Authentication**: Passwordless login using phone number and OTP verification via Twilio
- **Sponsor-Based Registration**: Exclusive access through sponsor verification system
- **Profile Management**: Upload up to 6 photos, detailed profile information, bio, and location
- **Hobby-Based Matching**: Select hobbies with skill levels (1-5) for better matching
- **Swipe Discovery**: Tinder-style card swiper interface to discover potential matches
- **Real-Time Messaging**: WebSocket-powered chat for instant communication
- **Social Feed**: Share posts with photos, like, and comment on content
- **Stories**: 24-hour ephemeral stories feature
- **Match Management**: View and manage your matches

### Technical Features
- Clean architecture with separation of concerns
- State management using Riverpod
- API integration with Dio (HTTP client)
- WebSocket support for real-time features
- Image caching and optimization
- Secure token storage with flutter_secure_storage
- Push notifications via Firebase Cloud Messaging
- Location services integration

## Project Structure

```
lib/
├── core/
│   ├── config/
│   │   └── app_config.dart           # App configuration and constants
│   ├── models/                        # Data models
│   │   ├── user_model.dart
│   │   ├── match_model.dart
│   │   ├── post_model.dart
│   │   ├── hobby_model.dart
│   │   └── discover_model.dart
│   ├── services/                      # API and business logic services
│   │   ├── api_service.dart           # Base HTTP service
│   │   ├── auth_service.dart          # Authentication
│   │   ├── profile_service.dart       # Profile management
│   │   ├── discover_service.dart      # Discovery/swipe
│   │   ├── match_service.dart         # Matches and messaging
│   │   ├── post_service.dart          # Posts
│   │   ├── story_service.dart         # Stories
│   │   ├── websocket_service.dart     # Real-time messaging
│   │   └── notification_service.dart  # Push notifications
│   ├── providers/
│   │   └── auth_provider.dart         # Auth state management
│   ├── routes/
│   │   └── app_router.dart            # Navigation
│   └── theme/
│       └── app_theme.dart             # Theme configuration
├── features/
│   ├── auth/                          # Authentication screens
│   │   └── screens/
│   │       ├── welcome_screen.dart
│   │       ├── phone_auth_screen.dart
│   │       ├── otp_verification_screen.dart
│   │       └── registration_screen.dart
│   ├── onboarding/                    # Onboarding flow
│   │   └── screens/
│   │       ├── profile_setup_screen.dart
│   │       ├── photo_upload_screen.dart
│   │       └── hobby_selection_screen.dart
│   ├── home/
│   │   └── screens/
│   │       └── main_screen.dart       # Main screen with bottom nav
│   ├── discover/                      # Discovery/swipe feature
│   │   ├── screens/
│   │   │   └── discover_screen.dart
│   │   └── widgets/
│   │       └── candidate_card.dart
│   ├── matches/                       # Matches list
│   │   └── screens/
│   │       └── matches_screen.dart
│   ├── messages/                      # Chat/messaging
│   │   └── screens/
│   │       └── chat_screen.dart
│   ├── feed/                          # Social feed
│   │   └── screens/
│   │       └── feed_screen.dart
│   ├── profile/                       # Profile screens
│   │   └── screens/
│   │       ├── profile_screen.dart
│   │       └── edit_profile_screen.dart
│   └── settings/                      # Settings
│       └── screens/
│           └── settings_screen.dart
└── main.dart
```

## Getting Started

### Prerequisites

- Flutter SDK (>=3.2.0)
- Dart SDK
- Android Studio / Xcode for mobile development
- Firebase project for push notifications

### Installation

1. Clone the repository:
```bash
cd cupido/flutter_app
```

2. Install dependencies:
```bash
flutter pub get
```

3. Configure Firebase:
   - Add your `google-services.json` (Android) to `android/app/`
   - Add your `GoogleService-Info.plist` (iOS) to `ios/Runner/`

4. Update API configuration in `lib/core/config/app_config.dart`:
```dart
static const String apiBaseUrl = 'https://your-api-url.com';
static const String webSocketUrl = 'wss://your-api-url.com';
```

5. Run the app:
```bash
flutter run
```

## Configuration

### API Endpoints

Update the API base URL in `lib/core/config/app_config.dart`:

```dart
class AppConfig {
  static const String apiBaseUrl = 'https://api.cupido.com';
  static const String apiPrefix = '/api';
  static const String webSocketUrl = 'wss://api.cupido.com';
}
```

### Firebase Setup

1. Create a Firebase project at https://console.firebase.google.com
2. Add Android and iOS apps to your Firebase project
3. Download configuration files:
   - `google-services.json` for Android
   - `GoogleService-Info.plist` for iOS
4. Enable Firebase Cloud Messaging (FCM)

### Platform-Specific Setup

#### Android

1. Update `android/app/build.gradle`:
```gradle
minSdkVersion 21
targetSdkVersion 33
```

2. Add permissions in `android/app/src/main/AndroidManifest.xml`:
```xml
<uses-permission android:name="android.permission.INTERNET" />
<uses-permission android:name="android.permission.ACCESS_FINE_LOCATION" />
<uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION" />
<uses-permission android:name="android.permission.CAMERA" />
<uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE" />
```

#### iOS

1. Update `ios/Runner/Info.plist`:
```xml
<key>NSLocationWhenInUseUsageDescription</key>
<string>We need your location to find matches nearby</string>
<key>NSCameraUsageDescription</key>
<string>We need camera access to take photos</string>
<key>NSPhotoLibraryUsageDescription</key>
<string>We need photo library access to upload photos</string>
```

2. Update minimum deployment target to iOS 12.0 in Xcode

## Dependencies

### Core Dependencies
- **flutter_riverpod**: State management
- **dio**: HTTP client for API calls
- **web_socket_channel**: WebSocket support
- **flutter_secure_storage**: Secure token storage
- **hive**: Local database

### UI Dependencies
- **cached_network_image**: Image caching
- **flutter_card_swiper**: Swipe cards UI
- **intl_phone_field**: Phone number input
- **shimmer**: Loading placeholders
- **timeago**: Relative time formatting

### Media Dependencies
- **image_picker**: Pick images from gallery/camera
- **flutter_image_compress**: Image compression
- **video_player**: Video playback

### Location & Notifications
- **geolocator**: Location services
- **firebase_messaging**: Push notifications
- **flutter_local_notifications**: Local notifications

## API Integration

The app integrates with the Cupido Laravel backend API. All API endpoints are defined in the service classes:

### Authentication Flow
1. `POST /api/auth/send-otp` - Send OTP to phone
2. `POST /api/auth/verify-otp` - Verify OTP and login
3. `GET /api/auth/me` - Get current user
4. `POST /api/auth/logout` - Logout

### Main Features
- Profile: `PUT /api/profile`, `POST /api/profile/photos`
- Discovery: `GET /api/discover`, `POST /api/discover/swipe`
- Matches: `GET /api/matches`, `GET /api/messages/:matchId`
- Feed: `GET /api/posts`, `POST /api/posts`
- Stories: `GET /api/stories`, `POST /api/stories`

## State Management

The app uses Riverpod for state management:

```dart
// Reading state
final authState = ref.watch(authProvider);

// Calling methods
await ref.read(authProvider.notifier).login(phone, otp);

// Listening to changes
ref.listen(authProvider, (previous, next) {
  // Handle state changes
});
```

## WebSocket Implementation

Real-time messaging uses WebSocket:

```dart
// Connect
await webSocketService.connect();

// Send message
webSocketService.sendMessage({
  'event': 'message',
  'match_id': matchId,
  'content': 'Hello!',
});

// Listen to messages
webSocketService.messageStream.listen((data) {
  // Handle incoming message
});
```

## Building for Production

### Android

```bash
flutter build apk --release
# or
flutter build appbundle --release
```

### iOS

```bash
flutter build ios --release
```

## TODO / Next Steps

- [ ] Connect all API endpoints (marked with `// TODO:` comments)
- [ ] Implement WebSocket connection in chat screens
- [ ] Add image compression before upload
- [ ] Implement story viewer with timer
- [ ] Add filters and search functionality
- [ ] Implement premium subscription flow
- [ ] Add deep linking support
- [ ] Implement analytics tracking
- [ ] Add unit and widget tests
- [ ] Setup CI/CD pipeline
- [ ] Implement error tracking (Sentry/Crashlytics)

## Known Issues

- API endpoints are currently placeholders and need to be connected
- WebSocket service needs to be integrated with Laravel Reverb
- Firebase configuration files need to be added
- Push notification handling needs implementation
- Location services need proper permission handling

## Contributing

This is a private project. For any questions or issues, contact the development team.

## License

Private and proprietary. All rights reserved.

## Support

For support, please contact the Cupido team.
