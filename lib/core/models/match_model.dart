class Match {
  final int id;
  final int userId;
  final int matchedUserId;
  final User matchedUser;
  final String? matchedHobby;
  final String? lastMessage;
  final DateTime? lastMessageAt;
  final int unreadCount;
  final DateTime createdAt;

  Match({
    required this.id,
    required this.userId,
    required this.matchedUserId,
    required this.matchedUser,
    this.matchedHobby,
    this.lastMessage,
    this.lastMessageAt,
    required this.unreadCount,
    required this.createdAt,
  });

  factory Match.fromJson(Map<String, dynamic> json) {
    return Match(
      id: json['id'],
      userId: json['user_id'],
      matchedUserId: json['matched_user_id'],
      matchedUser: User.fromJson(json['matched_user']),
      matchedHobby: json['matched_hobby'],
      lastMessage: json['last_message'],
      lastMessageAt: json['last_message_at'] != null
          ? DateTime.parse(json['last_message_at'])
          : null,
      unreadCount: json['unread_count'] ?? 0,
      createdAt: DateTime.parse(json['created_at']),
    );
  }
}

class Message {
  final int id;
  final int matchId;
  final int senderId;
  final String? content;
  final String? mediaUrl;
  final String? mediaType;
  final bool isRead;
  final DateTime createdAt;

  Message({
    required this.id,
    required this.matchId,
    required this.senderId,
    this.content,
    this.mediaUrl,
    this.mediaType,
    required this.isRead,
    required this.createdAt,
  });

  factory Message.fromJson(Map<String, dynamic> json) {
    return Message(
      id: json['id'],
      matchId: json['match_id'],
      senderId: json['sender_id'],
      content: json['content'],
      mediaUrl: json['media_url'],
      mediaType: json['media_type'],
      isRead: json['is_read'] ?? false,
      createdAt: DateTime.parse(json['created_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'match_id': matchId,
      'sender_id': senderId,
      'content': content,
      'media_url': mediaUrl,
      'media_type': mediaType,
      'is_read': isRead,
      'created_at': createdAt.toIso8601String(),
    };
  }
}

class User {
  final int id;
  final String? displayName;
  final String? photoUrl;
  final bool isOnline;

  User({
    required this.id,
    this.displayName,
    this.photoUrl,
    required this.isOnline,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      displayName: json['display_name'],
      photoUrl: json['photo_url'] ?? json['photos']?[0]?['photo_url'],
      isOnline: json['is_online'] ?? false,
    );
  }
}
