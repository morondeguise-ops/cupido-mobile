class AppConfig {
  // API Configuration
  static const String apiBaseUrl = 'https://api.cupido.com';
  static const String apiPrefix = '/api';
  static const String webSocketUrl = 'wss://api.cupido.com';

  // API Endpoints
  static const String sendOtpEndpoint = '/auth/send-otp';
  static const String verifyOtpEndpoint = '/auth/verify-otp';
  static const String logoutEndpoint = '/auth/logout';
  static const String meEndpoint = '/auth/me';
  static const String registerEndpoint = '/register';
  static const String profileEndpoint = '/profile';
  static const String profilePhotosEndpoint = '/profile/photos';
  static const String profileHobbiesEndpoint = '/profile/hobbies';
  static const String hobbiesEndpoint = '/hobbies';
  static const String discoverEndpoint = '/discover';
  static const String swipeEndpoint = '/discover/swipe';
  static const String matchesEndpoint = '/matches';
  static const String messagesEndpoint = '/messages';
  static const String postsEndpoint = '/posts';
  static const String storiesEndpoint = '/stories';
  static const String sponsorPendingEndpoint = '/sponsor/pending';
  static const String sponsorApproveEndpoint = '/sponsor/approve';

  // Storage Keys
  static const String tokenKey = 'auth_token';
  static const String userKey = 'user_data';
  static const String deviceTokenKey = 'device_token';

  // App Configuration
  static const String appName = 'Cupido';
  static const String appVersion = '1.0.0';
  static const int otpLength = 6;
  static const int otpExpiryMinutes = 10;
  static const int maxProfilePhotos = 6;
  static const int maxPhotoSizeMB = 10;
  static const int discoveryBatchSize = 20;
  static const int postsPerPage = 20;
  static const int messagesPerPage = 50;

  // Validation
  static const int minAge = 18;
  static const int maxAge = 100;
  static const int minBioLength = 10;
  static const int maxBioLength = 500;
  static const int minHobbies = 3;
  static const int maxHobbies = 10;

  // WebSocket Events
  static const String messageEvent = 'message';
  static const String typingEvent = 'typing';
  static const String readReceiptEvent = 'read';
  static const String matchEvent = 'match';

  // Get full API URL
  static String getApiUrl(String endpoint) {
    return '$apiBaseUrl$apiPrefix$endpoint';
  }

  // Check if in development mode
  static bool get isDevelopment =>
      apiBaseUrl.contains('localhost') || apiBaseUrl.contains('192.168');
}
