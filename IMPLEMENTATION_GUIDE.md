# Flutter App Implementation Guide

## ✅ What's Been Implemented

### Phase 1: Backend Environment Setup
- ✅ Laravel `.env` file configured for local development
- ✅ Composer dependencies installed
- ✅ Application key generated
- ⚠️ **Database setup pending** - Requires MySQL/PostgreSQL server

### Phase 2: Flutter API Integration
- ✅ **Complete Service Layer** - All API services implemented:
  - `ApiService` - Base HTTP client with Dio
  - `AuthService` - OTP authentication
  - `ProfileService` - Profile management
  - `DiscoverService` - Discovery/swipe
  - `MatchService` - Matches & messaging
  - `PostService` - Social feed
  - `StoryService` - Stories
  - `WebSocketService` - Real-time messaging

- ✅ **State Management Providers**:
  - `authProvider` - Authentication state
  - `discoverProvider` - Discovery queue management
  - `matchesProvider` - Matches list
  - `messagesProvider` - Chat messages (family provider)
  - `feedProvider` - Social feed
  - `storiesProvider` - Stories

- ✅ **UI Integration**:
  - Discover screen connected to provider
  - All other screens have service hooks ready

## 🚀 Quick Start (Without Database)

Since the database isn't set up yet, you can still test the Flutter app UI and navigation:

### 1. Update API URL

Edit `flutter_app/lib/core/config/app_config.dart`:

```dart
static const String apiBaseUrl = 'http://localhost:8000';  // For Android emulator
// OR
static const String apiBaseUrl = 'http://10.0.2.2:8000';  // Alternative for Android emulator
// OR
static const String apiBaseUrl = 'http://YOUR_IP:8000';  // For physical device
```

### 2. Run Flutter App

```bash
cd flutter_app
flutter pub get
flutter run
```

**Note**: API calls will fail until backend is fully set up, but you can navigate through the UI.

## 📋 What Still Needs TO Be Done

### Critical (Backend)
1. **Setup Database**
   - Option A: Install MySQL locally
     ```bash
     # Ubuntu/Debian
     sudo apt install mysql-server
     sudo mysql_secure_installation

     # Create database
     mysql -u root -p
     CREATE DATABASE cupido;
     CREATE USER 'cupido'@'localhost' IDENTIFIED BY 'password';
     GRANT ALL ON cupido.* TO 'cupido'@'localhost';
     ```

   - Option B: Use Docker
     ```bash
     docker run --name mysql -e MYSQL_ROOT_PASSWORD=root -e MYSQL_DATABASE=cupido -p 3306:3306 -d mysql:8
     ```

2. **Run Migrations**
   ```bash
   cd laravel-api
   # Update .env with database credentials
   php artisan migrate
   php artisan db:seed --class=HobbySeeder
   ```

3. **Start Laravel Server**
   ```bash
   php artisan serve
   # Server will run at http://localhost:8000
   ```

### Important (Flutter)
1. **Connect Remaining Screens** ✅ COMPLETED
   - ✅ Discover screen - DONE
   - ✅ Matches screen - DONE (2025-11-08)
   - ✅ Chat screen - DONE (2025-11-08)
   - ✅ Feed screen - DONE (2025-11-08)

2. **Firebase Setup** (Phase 3)
   - Create Firebase project
   - Add Android & iOS apps
   - Download config files
   - Setup push notifications

3. **Test Flow**
   - Test authentication
   - Test discovery/swiping
   - Test matching
   - Test messaging
   - Test feed

## 🔧 How to Connect Remaining Screens

### Matches Screen

Update `lib/features/matches/screens/matches_screen.dart`:

```dart
// Change line 1-8:
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';  // ADD THIS
import 'package:cached_network_image/cached_network_image.dart';
import 'package:timeago/timeago.dart' as timeago;

import '../../../core/theme/app_theme.dart';
import '../../../core/routes/app_router.dart';
import '../../../core/providers/match_provider.dart';  // ADD THIS

// Change line 10:
class MatchesScreen extends ConsumerStatefulWidget {  // Change to ConsumerStatefulWidget
  const MatchesScreen({super.key});

  @override
  ConsumerState<MatchesScreen> createState() => _MatchesScreenState();  // Change to ConsumerState
}

class _MatchesScreenState extends ConsumerState<MatchesScreen> {  // Change to ConsumerState
  // REMOVE: List<Match> _matches = [];
  // REMOVE: bool _isLoading = true;
  // REMOVE: initState and _loadMatches method

  @override
  Widget build(BuildContext context) {
    final matchesState = ref.watch(matchesProvider);  // ADD THIS

    return Scaffold(
      appBar: AppBar(
        title: const Text('Matches'),
      ),
      body: matchesState.isLoading  // CHANGE from _isLoading
          ? const Center(child: CircularProgressIndicator())
          : matchesState.matches.isEmpty  // CHANGE from _matches
              ? _buildEmptyState()
              : ListView.builder(
                  itemCount: matchesState.matches.length,  // CHANGE from _matches.length
                  itemBuilder: (context, index) {
                    return _buildMatchItem(matchesState.matches[index]);  // CHANGE
                  },
                ),
    );
  }
  // Rest stays the same...
}
```

### Chat Screen

Update `lib/features/messages/screens/chat_screen.dart`:

```dart
// Change imports:
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';  // ADD THIS
import 'package:cached_network_image/cached_network_image.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/models/match_model.dart' as match_model;
import '../../../core/providers/match_provider.dart';  // ADD THIS

// Change class:
class ChatScreen extends ConsumerStatefulWidget {  // Change to ConsumerStatefulWidget
  final int matchId;
  final match_model.User matchedUser;

  const ChatScreen({
    super.key,
    required this.matchId,
    required this.matchedUser,
  });

  @override
  ConsumerState<ChatScreen> createState() => _ChatScreenState();  // Change
}

class _ChatScreenState extends ConsumerState<ChatScreen> {  // Change to ConsumerState
  final TextEditingController _messageController = TextEditingController();
  // REMOVE: final List<match_model.Message> _messages = [];
  // REMOVE: bool _isLoading = true;
  // REMOVE: initState and _loadMessages method

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  Future<void> _sendMessage() async {
    final content = _messageController.text.trim();
    if (content.isEmpty) return;

    _messageController.clear();

    // Send message via provider
    await ref.read(messagesProvider(widget.matchId).notifier).sendMessage(content);  // ADD THIS
  }

  @override
  Widget build(BuildContext context) {
    final messagesState = ref.watch(messagesProvider(widget.matchId));  // ADD THIS

    return Scaffold(
      // ... appBar stays the same
      body: Column(
        children: [
          Expanded(
            child: messagesState.isLoading  // CHANGE from _isLoading
                ? const Center(child: CircularProgressIndicator())
                : messagesState.messages.isEmpty  // CHANGE from _messages
                    ? _buildEmptyState()
                    : ListView.builder(
                        reverse: true,
                        padding: const EdgeInsets.all(16),
                        itemCount: messagesState.messages.length,  // CHANGE
                        itemBuilder: (context, index) {
                          return _buildMessageBubble(messagesState.messages[index]);  // CHANGE
                        },
                      ),
          ),
          _buildMessageInput(),
        ],
      ),
    );
  }
  // Rest stays the same...
}
```

### Feed Screen

Update `lib/features/feed/screens/feed_screen.dart`:

```dart
// Change imports:
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';  // ADD THIS
import 'package:cached_network_image/cached_network_image.dart';
import 'package:timeago/timeago.dart' as timeago;

import '../../../core/theme/app_theme.dart';
import '../../../core/providers/post_provider.dart';  // ADD THIS

// Change class:
class FeedScreen extends ConsumerStatefulWidget {  // Change to ConsumerStatefulWidget
  const FeedScreen({super.key});

  @override
  ConsumerState<FeedScreen> createState() => _FeedScreenState();  // Change
}

class _FeedScreenState extends ConsumerState<FeedScreen> {  // Change to ConsumerState
  // REMOVE: List<Post> _posts = [];
  // REMOVE: bool _isLoading = true;
  // REMOVE: int _currentPage = 1;
  // REMOVE: initState and _loadPosts method

  Future<void> _likePost(int postId) async {
    await ref.read(feedProvider.notifier).likePost(postId);  // ADD THIS
  }

  @override
  Widget build(BuildContext context) {
    final feedState = ref.watch(feedProvider);  // ADD THIS

    return Scaffold(
      appBar: AppBar(
        title: const Text('Feed'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_box_outlined),
            onPressed: () {
              // TODO: Create new post
            },
          ),
        ],
      ),
      body: feedState.isLoading  // CHANGE from _isLoading
          ? const Center(child: CircularProgressIndicator())
          : feedState.posts.isEmpty  // CHANGE from _posts
              ? _buildEmptyState()
              : ListView.builder(
                  itemCount: feedState.posts.length,  // CHANGE
                  itemBuilder: (context, index) {
                    return _buildPostItem(feedState.posts[index]);  // CHANGE
                  },
                ),
    );
  }
  // Rest stays the same...
}
```

## 🔐 Setting Up Twilio (for OTP)

1. Create account at https://www.twilio.com
2. Get free trial phone number
3. Get Account SID and Auth Token
4. Update `laravel-api/.env`:
   ```
   TWILIO_SID=your_account_sid
   TWILIO_TOKEN=your_auth_token
   TWILIO_FROM=+1234567890
   ```

## 🎨 Firebase Setup (Phase 3)

### Android

1. Go to https://console.firebase.google.com
2. Create project: "Cupido"
3. Add Android app
   - Package name: `com.cupido.app` (or your package name)
   - Download `google-services.json`
   - Place in `flutter_app/android/app/`

4. Update `android/build.gradle`:
   ```gradle
   dependencies {
       classpath 'com.google.gms:google-services:4.4.0'
   }
   ```

5. Update `android/app/build.gradle`:
   ```gradle
   apply plugin: 'com.google.gms.google-services'

   defaultConfig {
       applicationId "com.cupido.app"
       minSdkVersion 21
       targetSdkVersion 33
   }
   ```

### iOS

1. Add iOS app in Firebase
   - Bundle ID: `com.cupido.app`
   - Download `GoogleService-Info.plist`
   - Place in `flutter_app/ios/Runner/`

2. Update `ios/Runner/Info.plist` - add permissions

## 📱 Testing Checklist

Once database is set up:

- [ ] Start Laravel: `php artisan serve`
- [ ] Update Flutter API URL
- [ ] Run Flutter app
- [ ] Test phone auth (enter phone)
- [ ] Receive OTP (check Twilio logs)
- [ ] Verify OTP
- [ ] Complete profile setup
- [ ] Upload photos
- [ ] Select hobbies
- [ ] View discovery queue
- [ ] Swipe on candidates
- [ ] Check matches
- [ ] Send messages
- [ ] View feed
- [ ] Create posts

## 🐛 Common Issues & Solutions

### Issue: "could not find driver" (SQLite)
**Solution**: Use MySQL instead (see Setup Database section above)

### Issue: API calls return 404
**Solution**:
- Make sure Laravel server is running: `php artisan serve`
- Check API URL in Flutter app config
- For Android emulator, use `http://10.0.2.2:8000`

### Issue: CORS errors
**Solution**: Laravel has CORS middleware configured, but if issues persist:
```php
// config/cors.php
'paths' => ['api/*'],
'allowed_origins' => ['*'],  // For development only
```

### Issue: Token not persisting
**Solution**: Check flutter_secure_storage permissions in AndroidManifest.xml

### Issue: Images not loading
**Solution**:
- Configure local storage (change FILESYSTEM_DISK=public in .env)
- Create storage symlink: `php artisan storage:link`
- Verify storage permissions: `sudo chmod -R 775 storage`
- See LOCAL_STORAGE_SETUP.md for complete guide

## 📝 Next Steps Priority

1. **HIGH**: Setup MySQL database and run migrations
2. **HIGH**: Start Laravel server
3. **HIGH**: Setup local storage (see LOCAL_STORAGE_SETUP.md)
4. **MEDIUM**: Setup Firebase for push notifications
5. **MEDIUM**: Setup Twilio for OTP
6. **LOW**: Implement CDN (optional, for global performance)

## 📚 Useful Commands

### Laravel
```bash
php artisan serve              # Start server
php artisan migrate            # Run migrations
php artisan db:seed            # Seed database
php artisan tinker             # Laravel REPL
php artisan queue:work         # Start queue worker
php artisan cache:clear        # Clear cache
```

### Flutter
```bash
flutter pub get                # Install dependencies
flutter run                    # Run app
flutter build apk              # Build Android APK
flutter build ios              # Build iOS
flutter clean                  # Clean build
flutter doctor                 # Check setup
```

## 🎯 Project Status

| Component | Status | Notes |
|-----------|--------|-------|
| Laravel Backend | ⚠️ 90% | Database setup pending |
| Flutter UI | ✅ 100% | All screens created |
| API Services | ✅ 100% | All services implemented |
| State Management | ✅ 100% | **All screens connected to providers!** |
| Authentication | ⚠️ 60% | Twilio setup needed |
| Real-time Chat | ⚠️ 50% | WebSocket needs testing |
| Firebase | ❌ 0% | Not configured |
| Local Storage | ⚠️ 50% | Config ready, needs deployment setup |
| Testing | ❌ 0% | No tests written |

---

**Last Updated**: 2025-11-08
**Version**: 1.0.0-alpha
**Status**: Ready for local testing (database setup required)
**Latest**: All Flutter provider integrations completed!
