/// Chat-related models for the Cupido app
///
/// Corresponds to Cupido\Core\Models\Chat namespace in backend

class ChatConversation {
  final int id;
  final String conversationId;
  final String type;
  final List<int> participants;
  final String? title;
  final bool isActive;
  final DateTime? lastMessageAt;
  final Map<String, dynamic>? metadata;
  final DateTime createdAt;
  final DateTime updatedAt;
  final List<ChatMessage>? recentMessages;

  ChatConversation({
    required this.id,
    required this.conversationId,
    required this.type,
    required this.participants,
    this.title,
    required this.isActive,
    this.lastMessageAt,
    this.metadata,
    required this.createdAt,
    required this.updatedAt,
    this.recentMessages,
  });

  factory ChatConversation.fromJson(Map<String, dynamic> json) {
    return ChatConversation(
      id: json['id'],
      conversationId: json['conversation_id'],
      type: json['type'],
      participants: json['participants'] != null
          ? List<int>.from(json['participants'])
          : [],
      title: json['title'],
      isActive: json['is_active'] ?? true,
      lastMessageAt: json['last_message_at'] != null
          ? DateTime.parse(json['last_message_at'])
          : null,
      metadata: json['metadata'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
      recentMessages: json['recent_messages'] != null
          ? (json['recent_messages'] as List)
              .map((msg) => ChatMessage.fromJson(msg))
              .toList()
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'conversation_id': conversationId,
      'type': type,
      'participants': participants,
      'title': title,
      'is_active': isActive,
      'last_message_at': lastMessageAt?.toIso8601String(),
      'metadata': metadata,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}

class ChatMessage {
  final int id;
  final String messageId;
  final int conversationId;
  final int senderId;
  final String content;
  final String messageType;
  final List<dynamic>? attachments;
  final DateTime sentAt;
  final bool isEdited;
  final DateTime? editedAt;
  final bool isDeleted;
  final DateTime? deletedAt;
  final Map<String, dynamic>? metadata;
  final DateTime createdAt;
  final DateTime updatedAt;

  // Optional relationships
  final dynamic sender; // Can be User object

  ChatMessage({
    required this.id,
    required this.messageId,
    required this.conversationId,
    required this.senderId,
    required this.content,
    required this.messageType,
    this.attachments,
    required this.sentAt,
    required this.isEdited,
    this.editedAt,
    required this.isDeleted,
    this.deletedAt,
    this.metadata,
    required this.createdAt,
    required this.updatedAt,
    this.sender,
  });

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    return ChatMessage(
      id: json['id'],
      messageId: json['message_id'],
      conversationId: json['conversation_id'],
      senderId: json['sender_id'],
      content: json['content'],
      messageType: json['message_type'] ?? 'text',
      attachments: json['attachments'],
      sentAt: DateTime.parse(json['sent_at']),
      isEdited: json['is_edited'] ?? false,
      editedAt:
          json['edited_at'] != null ? DateTime.parse(json['edited_at']) : null,
      isDeleted: json['is_deleted'] ?? false,
      deletedAt: json['deleted_at'] != null
          ? DateTime.parse(json['deleted_at'])
          : null,
      metadata: json['metadata'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
      sender: json['sender'], // Can be processed further if needed
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'message_id': messageId,
      'conversation_id': conversationId,
      'sender_id': senderId,
      'content': content,
      'message_type': messageType,
      'attachments': attachments,
      'sent_at': sentAt.toIso8601String(),
      'is_edited': isEdited,
      'edited_at': editedAt?.toIso8601String(),
      'is_deleted': isDeleted,
      'deleted_at': deletedAt?.toIso8601String(),
      'metadata': metadata,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  bool get isActive => !isDeleted;
}

/// Message types
class ChatMessageType {
  static const String text = 'text';
  static const String image = 'image';
  static const String video = 'video';
  static const String audio = 'audio';
  static const String file = 'file';
  static const String system = 'system';
}

/// Conversation types
class ConversationType {
  static const String direct = 'direct';
  static const String group = 'group';
  static const String channel = 'channel';
}
