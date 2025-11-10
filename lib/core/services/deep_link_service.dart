import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:app_links/app_links.dart';

class DeepLinkService {
  final AppLinks _appLinks = AppLinks();
  StreamSubscription<Uri>? _linkSubscription;

  /// Initialize deep link handling
  Future<void> initialize({
    required Function(Uri) onLinkReceived,
  }) async {
    try {
      // Handle initial link if app was opened via deep link
      final initialUri = await _appLinks.getInitialLink();
      if (initialUri != null) {
        debugPrint('Initial deep link: $initialUri');
        onLinkReceived(initialUri);
      }

      // Handle links while app is running
      _linkSubscription = _appLinks.uriLinkStream.listen(
        (Uri uri) {
          debugPrint('Received deep link: $uri');
          onLinkReceived(uri);
        },
        onError: (err) {
          debugPrint('Error handling deep link: $err');
        },
      );
    } catch (e) {
      debugPrint('Error initializing deep links: $e');
    }
  }

  /// Parse and handle deep link
  DeepLinkData? parseDeepLink(Uri uri) {
    try {
      final path = uri.path;
      final queryParams = uri.queryParameters;

      debugPrint('Parsing deep link - Path: $path, Params: $queryParams');

      // Profile links: /profile/{userId}
      if (path.startsWith('/profile/')) {
        final userId = path.replaceFirst('/profile/', '');
        return DeepLinkData(
          type: DeepLinkType.profile,
          id: userId,
        );
      }

      // Match/Chat links: /chat/{matchId}
      if (path.startsWith('/chat/')) {
        final matchId = path.replaceFirst('/chat/', '');
        return DeepLinkData(
          type: DeepLinkType.chat,
          id: matchId,
        );
      }

      // Post links: /post/{postId}
      if (path.startsWith('/post/')) {
        final postId = path.replaceFirst('/post/', '');
        return DeepLinkData(
          type: DeepLinkType.post,
          id: postId,
        );
      }

      // Event links: /event/{eventId}
      if (path.startsWith('/event/')) {
        final eventId = path.replaceFirst('/event/', '');
        return DeepLinkData(
          type: DeepLinkType.event,
          id: eventId,
        );
      }

      // Invitation links: /invite?code={invitationCode}
      if (path == '/invite' && queryParams.containsKey('code')) {
        return DeepLinkData(
          type: DeepLinkType.invitation,
          id: queryParams['code'],
        );
      }

      // Hobby links: /hobby/{hobbyId}
      if (path.startsWith('/hobby/')) {
        final hobbyId = path.replaceFirst('/hobby/', '');
        return DeepLinkData(
          type: DeepLinkType.hobby,
          id: hobbyId,
        );
      }

      // Reset password: /reset-password?token={token}
      if (path == '/reset-password' && queryParams.containsKey('token')) {
        return DeepLinkData(
          type: DeepLinkType.resetPassword,
          id: queryParams['token'],
        );
      }

      // Verify email: /verify-email?token={token}
      if (path == '/verify-email' && queryParams.containsKey('token')) {
        return DeepLinkData(
          type: DeepLinkType.verifyEmail,
          id: queryParams['token'],
        );
      }

      // Gift links: /gift/{giftId}
      if (path.startsWith('/gift/')) {
        final giftId = path.replaceFirst('/gift/', '');
        return DeepLinkData(
          type: DeepLinkType.gift,
          id: giftId,
        );
      }

      // Notification links: /notification/{notificationId}
      if (path.startsWith('/notification/')) {
        final notificationId = path.replaceFirst('/notification/', '');
        return DeepLinkData(
          type: DeepLinkType.notification,
          id: notificationId,
        );
      }

      debugPrint('Unknown deep link path: $path');
      return null;
    } catch (e) {
      debugPrint('Error parsing deep link: $e');
      return null;
    }
  }

  /// Generate deep link URL
  String generateDeepLink({
    required DeepLinkType type,
    required String id,
    Map<String, String>? queryParams,
  }) {
    String baseUrl = 'https://cupido.com'; // Replace with your domain
    String path = '';

    switch (type) {
      case DeepLinkType.profile:
        path = '/profile/$id';
        break;
      case DeepLinkType.chat:
        path = '/chat/$id';
        break;
      case DeepLinkType.post:
        path = '/post/$id';
        break;
      case DeepLinkType.event:
        path = '/event/$id';
        break;
      case DeepLinkType.hobby:
        path = '/hobby/$id';
        break;
      case DeepLinkType.gift:
        path = '/gift/$id';
        break;
      case DeepLinkType.invitation:
        path = '/invite?code=$id';
        break;
      case DeepLinkType.notification:
        path = '/notification/$id';
        break;
      case DeepLinkType.resetPassword:
        path = '/reset-password?token=$id';
        break;
      case DeepLinkType.verifyEmail:
        path = '/verify-email?token=$id';
        break;
    }

    String url = baseUrl + path;

    if (queryParams != null && queryParams.isNotEmpty) {
      final params = queryParams.entries
          .map((e) => '${e.key}=${Uri.encodeComponent(e.value)}')
          .join('&');
      url += path.contains('?') ? '&$params' : '?$params';
    }

    return url;
  }

  /// Dispose deep link subscription
  void dispose() {
    _linkSubscription?.cancel();
  }
}

enum DeepLinkType {
  profile,
  chat,
  post,
  event,
  hobby,
  gift,
  invitation,
  notification,
  resetPassword,
  verifyEmail,
}

class DeepLinkData {
  final DeepLinkType type;
  final String? id;
  final Map<String, dynamic>? extra;

  DeepLinkData({
    required this.type,
    this.id,
    this.extra,
  });

  @override
  String toString() {
    return 'DeepLinkData{type: $type, id: $id, extra: $extra}';
  }
}
