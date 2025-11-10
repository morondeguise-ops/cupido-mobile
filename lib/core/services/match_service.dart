import '../config/app_config.dart';
import '../models/match_model.dart';
import 'api_service.dart';

class MatchService {
  final ApiService _api;

  MatchService(this._api);

  // Get all matches
  Future<List<Match>> getMatches() async {
    final response = await _api.get(AppConfig.matchesEndpoint);

    return (response.data['data'] as List)
        .map((match) => Match.fromJson(match))
        .toList();
  }

  // Unmatch
  Future<void> unmatch(int matchId) async {
    await _api.delete('${AppConfig.matchesEndpoint}/$matchId');
  }

  // Get messages for a match
  Future<List<Message>> getMessages(
    int matchId, {
    int page = 1,
    int limit = 50,
  }) async {
    final response = await _api.get(
      '${AppConfig.messagesEndpoint}/$matchId',
      queryParameters: {
        'page': page,
        'limit': limit,
      },
    );

    return (response.data['data'] as List)
        .map((message) => Message.fromJson(message))
        .toList();
  }

  // Send message
  Future<Message> sendMessage({
    required int matchId,
    String? content,
    String? mediaUrl,
    String? mediaType,
  }) async {
    final response = await _api.post(
      '${AppConfig.messagesEndpoint}/$matchId',
      data: {
        if (content != null) 'content': content,
        if (mediaUrl != null) 'media_url': mediaUrl,
        if (mediaType != null) 'media_type': mediaType,
      },
    );

    return Message.fromJson(response.data['data']);
  }

  // Mark messages as read
  Future<void> markAsRead(int matchId) async {
    await _api.post(
      '${AppConfig.messagesEndpoint}/$matchId/read',
    );
  }
}
