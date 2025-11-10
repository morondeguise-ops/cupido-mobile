class Post {
  final int id;
  final int userId;
  final String? caption;
  final int likesCount;
  final int commentsCount;
  final bool isLiked;
  final DateTime createdAt;
  final User user;
  final List<PostMedia> media;
  final List<String> hobbies;

  Post({
    required this.id,
    required this.userId,
    this.caption,
    required this.likesCount,
    required this.commentsCount,
    required this.isLiked,
    required this.createdAt,
    required this.user,
    required this.media,
    required this.hobbies,
  });

  factory Post.fromJson(Map<String, dynamic> json) {
    return Post(
      id: json['id'],
      userId: json['user_id'],
      caption: json['caption'],
      likesCount: json['likes_count'] ?? 0,
      commentsCount: json['comments_count'] ?? 0,
      isLiked: json['is_liked'] ?? false,
      createdAt: DateTime.parse(json['created_at']),
      user: User.fromJson(json['user']),
      media: (json['media'] as List?)
              ?.map((m) => PostMedia.fromJson(m))
              .toList() ??
          [],
      hobbies: (json['hobbies'] as List?)?.cast<String>() ?? [],
    );
  }
}

class PostMedia {
  final int id;
  final String mediaUrl;
  final String mediaType;
  final int order;

  PostMedia({
    required this.id,
    required this.mediaUrl,
    required this.mediaType,
    required this.order,
  });

  factory PostMedia.fromJson(Map<String, dynamic> json) {
    return PostMedia(
      id: json['id'],
      mediaUrl: json['media_url'],
      mediaType: json['media_type'],
      order: json['order'] ?? 0,
    );
  }
}

class Comment {
  final int id;
  final int postId;
  final int userId;
  final String content;
  final DateTime createdAt;
  final User user;

  Comment({
    required this.id,
    required this.postId,
    required this.userId,
    required this.content,
    required this.createdAt,
    required this.user,
  });

  factory Comment.fromJson(Map<String, dynamic> json) {
    return Comment(
      id: json['id'],
      postId: json['post_id'],
      userId: json['user_id'],
      content: json['content'],
      createdAt: DateTime.parse(json['created_at']),
      user: User.fromJson(json['user']),
    );
  }
}

class Story {
  final int id;
  final int userId;
  final String mediaUrl;
  final String mediaType;
  final int viewsCount;
  final bool isViewed;
  final DateTime expiresAt;
  final DateTime createdAt;
  final User user;

  Story({
    required this.id,
    required this.userId,
    required this.mediaUrl,
    required this.mediaType,
    required this.viewsCount,
    required this.isViewed,
    required this.expiresAt,
    required this.createdAt,
    required this.user,
  });

  factory Story.fromJson(Map<String, dynamic> json) {
    return Story(
      id: json['id'],
      userId: json['user_id'],
      mediaUrl: json['media_url'],
      mediaType: json['media_type'],
      viewsCount: json['views_count'] ?? 0,
      isViewed: json['is_viewed'] ?? false,
      expiresAt: DateTime.parse(json['expires_at']),
      createdAt: DateTime.parse(json['created_at']),
      user: User.fromJson(json['user']),
    );
  }

  bool get isExpired => DateTime.now().isAfter(expiresAt);
}

class User {
  final int id;
  final String? displayName;
  final String? photoUrl;

  User({
    required this.id,
    this.displayName,
    this.photoUrl,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      displayName: json['display_name'],
      photoUrl: json['photo_url'] ?? json['photos']?[0]?['photo_url'],
    );
  }
}
