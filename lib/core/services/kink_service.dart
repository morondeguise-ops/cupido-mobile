import '../models/kink_model.dart';
import 'api_service.dart';

/// Service for managing kink interests
///
/// Handles:
/// - Fetching available kink interests
/// - Managing user's kink interests
/// - Privacy settings for kink interests
class KinkService {
  final ApiService _apiService;

  KinkService(this._apiService);

  /// Get all available kink interests
  Future<List<KinkInterest>> getKinkInterests({
    String? category,
    bool? isActive,
    bool? ageRestricted,
    int? page,
    int? perPage,
  }) async {
    final queryParams = <String, dynamic>{};
    if (category != null) queryParams['category'] = category;
    if (isActive != null) queryParams['is_active'] = isActive;
    if (ageRestricted != null) queryParams['age_restricted'] = ageRestricted;
    if (page != null) queryParams['page'] = page;
    if (perPage != null) queryParams['per_page'] = perPage;

    final response = await _apiService.get(
      '/kinks',
      queryParameters: queryParams,
    );

    final List<dynamic> data = response.data['data'] ?? response.data;
    return data.map((json) => KinkInterest.fromJson(json)).toList();
  }

  /// Get a specific kink interest by ID
  Future<KinkInterest> getKinkInterest(int kinkId) async {
    final response = await _apiService.get('/kinks/$kinkId');
    return KinkInterest.fromJson(response.data['data'] ?? response.data);
  }

  /// Get kink interests by category
  Future<List<KinkInterest>> getKinkInterestsByCategory(
    String category,
  ) async {
    return getKinkInterests(category: category, isActive: true);
  }

  /// Get user's kink interests
  Future<List<UserKinkInterest>> getUserKinkInterests({
    int? userId,
  }) async {
    final path = userId != null
        ? '/users/$userId/kinks'
        : '/profile/kinks';

    final response = await _apiService.get(path);

    final List<dynamic> data = response.data['data'] ?? response.data;
    return data.map((json) => UserKinkInterest.fromJson(json)).toList();
  }

  /// Add a kink interest to user's profile
  Future<UserKinkInterest> addKinkInterest({
    required int kinkInterestId,
    String privacyLevel = KinkPrivacyLevel.privateLevel,
  }) async {
    final response = await _apiService.post(
      '/profile/kinks',
      data: {
        'kink_interest_id': kinkInterestId,
        'privacy_level': privacyLevel,
      },
    );

    return UserKinkInterest.fromJson(response.data['data'] ?? response.data);
  }

  /// Remove a kink interest from user's profile
  Future<void> removeKinkInterest(int userKinkInterestId) async {
    await _apiService.delete('/profile/kinks/$userKinkInterestId');
  }

  /// Update kink interest privacy settings
  Future<UserKinkInterest> updateKinkPrivacy({
    required int userKinkInterestId,
    required String privacyLevel,
  }) async {
    final response = await _apiService.put(
      '/profile/kinks/$userKinkInterestId',
      data: {'privacy_level': privacyLevel},
    );

    return UserKinkInterest.fromJson(response.data['data'] ?? response.data);
  }

  /// Get kink interest categories
  Future<List<String>> getKinkCategories() async {
    final response = await _apiService.get('/kinks/categories');
    final List<dynamic> data = response.data['data'] ?? response.data;
    return data.cast<String>();
  }

  /// Search kink interests
  Future<List<KinkInterest>> searchKinkInterests(
    String query, {
    int? page,
    int? perPage,
  }) async {
    final queryParams = <String, dynamic>{
      'query': query,
    };
    if (page != null) queryParams['page'] = page;
    if (perPage != null) queryParams['per_page'] = perPage;

    final response = await _apiService.get(
      '/kinks/search',
      queryParameters: queryParams,
    );

    final List<dynamic> data = response.data['data'] ?? response.data;
    return data.map((json) => KinkInterest.fromJson(json)).toList();
  }

  /// Get recommended kink interests based on user profile
  Future<List<KinkInterest>> getRecommendedKinks() async {
    final response = await _apiService.get('/kinks/recommended');
    final List<dynamic> data = response.data['data'] ?? response.data;
    return data.map((json) => KinkInterest.fromJson(json)).toList();
  }

  /// Verify a kink interest (if verification is required)
  Future<void> verifyKinkInterest({
    required int userKinkInterestId,
    required Map<String, dynamic> verificationData,
  }) async {
    await _apiService.post(
      '/profile/kinks/$userKinkInterestId/verify',
      data: verificationData,
    );
  }

  /// Get kink compatibility with another user
  Future<Map<String, dynamic>> getKinkCompatibility(int otherUserId) async {
    final response = await _apiService.get(
      '/users/$otherUserId/kink-compatibility',
    );
    return response.data['data'] ?? response.data;
  }
}
