import '../config/app_config.dart';
import '../models/discover_model.dart';
import 'api_service.dart';

class DiscoverService {
  final ApiService _api;

  DiscoverService(this._api);

  // Get discovery queue
  Future<List<DiscoveryCandidate>> getDiscoveryQueue() async {
    final response = await _api.get(AppConfig.discoverEndpoint);

    return (response.data['data'] as List)
        .map((candidate) => DiscoveryCandidate.fromJson(candidate))
        .toList();
  }

  // Swipe on a candidate
  Future<SwipeAction> swipe({
    required int candidateId,
    required String action, // 'like' or 'pass'
  }) async {
    final response = await _api.post(
      AppConfig.swipeEndpoint,
      data: {
        'candidate_id': candidateId,
        'action': action,
      },
    );

    return SwipeAction.fromJson(response.data['data']);
  }

  // Like a candidate
  Future<SwipeAction> like(int candidateId) async {
    return await swipe(candidateId: candidateId, action: 'like');
  }

  // Pass on a candidate
  Future<SwipeAction> pass(int candidateId) async {
    return await swipe(candidateId: candidateId, action: 'pass');
  }

  // Super like (if premium feature)
  Future<SwipeAction> superLike(int candidateId) async {
    return await swipe(candidateId: candidateId, action: 'super_like');
  }
}
