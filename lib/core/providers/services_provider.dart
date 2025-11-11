import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../services/api_service.dart';
import '../services/auth_service.dart';
import '../services/profile_service.dart';
import '../services/discover_service.dart';
import '../services/match_service.dart';
import '../services/post_service.dart';
import '../services/story_service.dart';
import '../services/websocket_service.dart';
import '../services/subscription_service.dart';
import '../services/ad_service.dart';

// Export services so they can be used by providers
export '../services/api_service.dart';
export '../services/auth_service.dart';
export '../services/profile_service.dart';
export '../services/discover_service.dart';
export '../services/match_service.dart';
export '../services/post_service.dart';
export '../services/story_service.dart';
export '../services/websocket_service.dart';
export '../services/subscription_service.dart';
export '../services/ad_service.dart';

// API Service Provider
final apiServiceProvider = Provider<ApiService>((ref) => ApiService());

// Service Providers
final authServiceProvider = Provider<AuthService>(
  (ref) => AuthService(ref.read(apiServiceProvider)),
);

final profileServiceProvider = Provider<ProfileService>(
  (ref) => ProfileService(ref.read(apiServiceProvider)),
);

final discoverServiceProvider = Provider<DiscoverService>(
  (ref) => DiscoverService(ref.read(apiServiceProvider)),
);

final matchServiceProvider = Provider<MatchService>(
  (ref) => MatchService(ref.read(apiServiceProvider)),
);

final postServiceProvider = Provider<PostService>(
  (ref) => PostService(ref.read(apiServiceProvider)),
);

final storyServiceProvider = Provider<StoryService>(
  (ref) => StoryService(ref.read(apiServiceProvider)),
);

final webSocketServiceProvider = Provider<WebSocketService>(
  (ref) => WebSocketService(ref.read(apiServiceProvider)),
);

final subscriptionServiceProvider = Provider<SubscriptionService>(
  (ref) => SubscriptionService(),
);

final adServiceProvider = Provider<AdService>(
  (ref) => AdService(
    ref.read(apiServiceProvider),
    ref.read(subscriptionServiceProvider),
  ),
);
