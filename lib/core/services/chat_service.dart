import '../models/chat_model.dart';
import 'api_service.dart';

/// Service for managing chat conversations and messages
///
/// Handles:
/// - Fetching conversations
/// - Sending and receiving messages
/// - Message editing and deletion
/// - Real-time message updates (via WebSocket)
class ChatService {
  final ApiService _apiService;

  ChatService(this._apiService);

  /// Get all conversations for the current user
  Future<List<ChatConversation>> getConversations({
    String? type,
    bool? isActive,
    int? page,
    int? perPage,
  }) async {
    final queryParams = <String, dynamic>{};
    if (type != null) queryParams['type'] = type;
    if (isActive != null) queryParams['is_active'] = isActive;
    if (page != null) queryParams['page'] = page;
    if (perPage != null) queryParams['per_page'] = perPage;

    final response = await _apiService.get(
      '/chat/conversations',
      queryParameters: queryParams,
    );

    final List<dynamic> data = response.data['data'] ?? response.data;
    return data.map((json) => ChatConversation.fromJson(json)).toList();
  }

  /// Get a specific conversation by ID
  Future<ChatConversation> getConversation(int conversationId) async {
    final response = await _apiService.get('/chat/conversations/$conversationId');
    return ChatConversation.fromJson(response.data['data'] ?? response.data);
  }

  /// Create a new conversation
  Future<ChatConversation> createConversation({
    required String type,
    required List<int> participants,
    String? title,
    Map<String, dynamic>? metadata,
  }) async {
    final response = await _apiService.post(
      '/chat/conversations',
      data: {
        'type': type,
        'participants': participants,
        'title': title,
        'metadata': metadata,
      },
    );

    return ChatConversation.fromJson(response.data['data'] ?? response.data);
  }

  /// Get messages for a conversation
  Future<List<ChatMessage>> getMessages(
    int conversationId, {
    int? page,
    int? perPage,
    DateTime? before,
    DateTime? after,
  }) async {
    final queryParams = <String, dynamic>{};
    if (page != null) queryParams['page'] = page;
    if (perPage != null) queryParams['per_page'] = perPage;
    if (before != null) queryParams['before'] = before.toIso8601String();
    if (after != null) queryParams['after'] = after.toIso8601String();

    final response = await _apiService.get(
      '/chat/conversations/$conversationId/messages',
      queryParameters: queryParams,
    );

    final List<dynamic> data = response.data['data'] ?? response.data;
    return data.map((json) => ChatMessage.fromJson(json)).toList();
  }

  /// Send a new message
  Future<ChatMessage> sendMessage({
    required int conversationId,
    required String content,
    String messageType = ChatMessageType.text,
    List<dynamic>? attachments,
    Map<String, dynamic>? metadata,
  }) async {
    final response = await _apiService.post(
      '/chat/conversations/$conversationId/messages',
      data: {
        'content': content,
        'message_type': messageType,
        'attachments': attachments,
        'metadata': metadata,
      },
    );

    return ChatMessage.fromJson(response.data['data'] ?? response.data);
  }

  /// Edit a message
  Future<ChatMessage> editMessage({
    required int conversationId,
    required int messageId,
    required String content,
  }) async {
    final response = await _apiService.put(
      '/chat/conversations/$conversationId/messages/$messageId',
      data: {'content': content},
    );

    return ChatMessage.fromJson(response.data['data'] ?? response.data);
  }

  /// Delete a message
  Future<void> deleteMessage({
    required int conversationId,
    required int messageId,
  }) async {
    await _apiService.delete(
      '/chat/conversations/$conversationId/messages/$messageId',
    );
  }

  /// Mark message as read
  Future<void> markMessageAsRead({
    required int conversationId,
    required int messageId,
  }) async {
    await _apiService.post(
      '/chat/conversations/$conversationId/messages/$messageId/read',
    );
  }

  /// Mark all messages in conversation as read
  Future<void> markConversationAsRead(int conversationId) async {
    await _apiService.post('/chat/conversations/$conversationId/read');
  }

  /// Archive a conversation
  Future<void> archiveConversation(int conversationId) async {
    await _apiService.post('/chat/conversations/$conversationId/archive');
  }

  /// Unarchive a conversation
  Future<void> unarchiveConversation(int conversationId) async {
    await _apiService.post('/chat/conversations/$conversationId/unarchive');
  }

  /// Delete a conversation
  Future<void> deleteConversation(int conversationId) async {
    await _apiService.delete('/chat/conversations/$conversationId');
  }

  /// Get unread message count
  Future<int> getUnreadCount() async {
    final response = await _apiService.get('/chat/unread-count');
    return response.data['count'] ?? 0;
  }

  /// Search messages in a conversation
  Future<List<ChatMessage>> searchMessages({
    required int conversationId,
    required String query,
    int? page,
    int? perPage,
  }) async {
    final queryParams = <String, dynamic>{
      'query': query,
    };
    if (page != null) queryParams['page'] = page;
    if (perPage != null) queryParams['per_page'] = perPage;

    final response = await _apiService.get(
      '/chat/conversations/$conversationId/search',
      queryParameters: queryParams,
    );

    final List<dynamic> data = response.data['data'] ?? response.data;
    return data.map((json) => ChatMessage.fromJson(json)).toList();
  }

  /// Send typing indicator
  Future<void> sendTypingIndicator(int conversationId) async {
    await _apiService.post('/chat/conversations/$conversationId/typing');
  }

  /// Upload attachment for chat
  Future<Map<String, dynamic>> uploadAttachment({
    required int conversationId,
    required String filePath,
    required String fileType,
  }) async {
    // Implementation depends on file upload handling
    // This is a placeholder - actual implementation may vary
    final response = await _apiService.post(
      '/chat/conversations/$conversationId/attachments',
      data: {
        'file_path': filePath,
        'file_type': fileType,
      },
    );

    return response.data['data'] ?? response.data;
  }
}
