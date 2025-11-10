import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/foundation.dart';

class AnalyticsService {
  final FirebaseAnalytics _analytics = FirebaseAnalytics.instance;
  FirebaseAnalyticsObserver get observer => FirebaseAnalyticsObserver(analytics: _analytics);

  // User Events
  Future<void> logLogin(String method) async {
    await _analytics.logLogin(loginMethod: method);
    debugPrint('Analytics: User logged in with $method');
  }

  Future<void> logSignUp(String method) async {
    await _analytics.logSignUp(signUpMethod: method);
    debugPrint('Analytics: User signed up with $method');
  }

  Future<void> setUserId(String userId) async {
    await _analytics.setUserId(id: userId);
    debugPrint('Analytics: User ID set to $userId');
  }

  Future<void> setUserProperties({
    String? age,
    String? gender,
    String? location,
    String? subscriptionType,
  }) async {
    if (age != null) {
      await _analytics.setUserProperty(name: 'age_group', value: age);
    }
    if (gender != null) {
      await _analytics.setUserProperty(name: 'gender', value: gender);
    }
    if (location != null) {
      await _analytics.setUserProperty(name: 'location', value: location);
    }
    if (subscriptionType != null) {
      await _analytics.setUserProperty(name: 'subscription_type', value: subscriptionType);
    }
    debugPrint('Analytics: User properties set');
  }

  // Screen View Events
  Future<void> logScreenView(String screenName, {String? screenClass}) async {
    await _analytics.logScreenView(
      screenName: screenName,
      screenClass: screenClass,
    );
    debugPrint('Analytics: Screen view - $screenName');
  }

  // Discovery & Matching Events
  Future<void> logSwipe(String direction, String userId) async {
    await _analytics.logEvent(
      name: 'swipe',
      parameters: {
        'direction': direction,
        'target_user_id': userId,
      },
    );
    debugPrint('Analytics: Swipe $direction on user $userId');
  }

  Future<void> logMatch(String matchId, String userId) async {
    await _analytics.logEvent(
      name: 'match_created',
      parameters: {
        'match_id': matchId,
        'matched_user_id': userId,
      },
    );
    debugPrint('Analytics: Match created with $userId');
  }

  Future<void> logUnmatch(String matchId) async {
    await _analytics.logEvent(
      name: 'match_removed',
      parameters: {
        'match_id': matchId,
      },
    );
    debugPrint('Analytics: Match removed');
  }

  // Messaging Events
  Future<void> logMessageSent(String matchId, String messageType) async {
    await _analytics.logEvent(
      name: 'message_sent',
      parameters: {
        'match_id': matchId,
        'message_type': messageType,
      },
    );
    debugPrint('Analytics: Message sent');
  }

  Future<void> logChatOpened(String matchId) async {
    await _analytics.logEvent(
      name: 'chat_opened',
      parameters: {
        'match_id': matchId,
      },
    );
    debugPrint('Analytics: Chat opened');
  }

  // Social Events
  Future<void> logPostCreated(String postId, String postType) async {
    await _analytics.logEvent(
      name: 'post_created',
      parameters: {
        'post_id': postId,
        'post_type': postType,
      },
    );
    debugPrint('Analytics: Post created');
  }

  Future<void> logPostLiked(String postId) async {
    await _analytics.logEvent(
      name: 'post_liked',
      parameters: {
        'post_id': postId,
      },
    );
    debugPrint('Analytics: Post liked');
  }

  Future<void> logPostCommented(String postId) async {
    await _analytics.logEvent(
      name: 'post_commented',
      parameters: {
        'post_id': postId,
      },
    );
    debugPrint('Analytics: Post commented');
  }

  Future<void> logStoryCreated(String storyId) async {
    await _analytics.logEvent(
      name: 'story_created',
      parameters: {
        'story_id': storyId,
      },
    );
    debugPrint('Analytics: Story created');
  }

  Future<void> logStoryViewed(String storyId, String userId) async {
    await _analytics.logEvent(
      name: 'story_viewed',
      parameters: {
        'story_id': storyId,
        'story_owner_id': userId,
      },
    );
    debugPrint('Analytics: Story viewed');
  }

  // Profile Events
  Future<void> logProfileViewed(String userId) async {
    await _analytics.logEvent(
      name: 'profile_viewed',
      parameters: {
        'viewed_user_id': userId,
      },
    );
    debugPrint('Analytics: Profile viewed');
  }

  Future<void> logProfileUpdated(String updateType) async {
    await _analytics.logEvent(
      name: 'profile_updated',
      parameters: {
        'update_type': updateType,
      },
    );
    debugPrint('Analytics: Profile updated - $updateType');
  }

  // Gift Events (2.5 Feature)
  Future<void> logGiftSent(String giftId, String recipientId) async {
    await _analytics.logEvent(
      name: 'gift_sent',
      parameters: {
        'gift_id': giftId,
        'recipient_id': recipientId,
      },
    );
    debugPrint('Analytics: Gift sent');
  }

  Future<void> logGiftReceived(String giftId) async {
    await _analytics.logEvent(
      name: 'gift_received',
      parameters: {
        'gift_id': giftId,
      },
    );
    debugPrint('Analytics: Gift received');
  }

  // Event/Calendar Events (2.5 Feature)
  Future<void> logEventCreated(String eventId, String eventType) async {
    await _analytics.logEvent(
      name: 'event_created',
      parameters: {
        'event_id': eventId,
        'event_type': eventType,
      },
    );
    debugPrint('Analytics: Event created');
  }

  Future<void> logEventJoined(String eventId) async {
    await _analytics.logEvent(
      name: 'event_joined',
      parameters: {
        'event_id': eventId,
      },
    );
    debugPrint('Analytics: Event joined');
  }

  // Subscription Events
  Future<void> logSubscriptionStarted(String productId, double price) async {
    await _analytics.logEvent(
      name: 'subscription_started',
      parameters: {
        'product_id': productId,
        'price': price,
        'currency': 'USD',
      },
    );
    debugPrint('Analytics: Subscription started - $productId');
  }

  Future<void> logSubscriptionCancelled() async {
    await _analytics.logEvent(
      name: 'subscription_cancelled',
      parameters: {},
    );
    debugPrint('Analytics: Subscription cancelled');
  }

  Future<void> logPurchase({
    required String transactionId,
    required double value,
    required String currency,
    required String itemName,
  }) async {
    await _analytics.logPurchase(
      transactionId: transactionId,
      value: value,
      currency: currency,
      items: [
        AnalyticsEventItem(
          itemName: itemName,
          itemId: transactionId,
          price: value,
        ),
      ],
    );
    debugPrint('Analytics: Purchase logged - $itemName');
  }

  // Share Events
  Future<void> logShare(String contentType, String contentId) async {
    await _analytics.logShare(
      contentType: contentType,
      itemId: contentId,
      method: 'app_share',
    );
    debugPrint('Analytics: Content shared - $contentType');
  }

  // Report/Block Events
  Future<void> logUserReported(String userId, String reason) async {
    await _analytics.logEvent(
      name: 'user_reported',
      parameters: {
        'reported_user_id': userId,
        'reason': reason,
      },
    );
    debugPrint('Analytics: User reported');
  }

  Future<void> logUserBlocked(String userId) async {
    await _analytics.logEvent(
      name: 'user_blocked',
      parameters: {
        'blocked_user_id': userId,
      },
    );
    debugPrint('Analytics: User blocked');
  }

  // Search Events
  Future<void> logSearch(String searchTerm, String category) async {
    await _analytics.logSearch(
      searchTerm: searchTerm,
      parameters: {
        'category': category,
      },
    );
    debugPrint('Analytics: Search - $searchTerm');
  }

  // Error Events
  Future<void> logError(String errorMessage, {String? screen}) async {
    await _analytics.logEvent(
      name: 'app_error',
      parameters: {
        'error_message': errorMessage,
        if (screen != null) 'screen': screen,
      },
    );
    debugPrint('Analytics: Error - $errorMessage');
  }

  // Custom Events
  Future<void> logCustomEvent(String eventName, Map<String, dynamic>? parameters) async {
    await _analytics.logEvent(
      name: eventName,
      parameters: parameters,
    );
    debugPrint('Analytics: Custom event - $eventName');
  }
}
