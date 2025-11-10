import 'user_model.dart';

class DiscoveryCandidate {
  final int id;
  final String? displayName;
  final int age;
  final String? bio;
  final String? location;
  final double? distance;
  final int matchScore;
  final List<ProfilePhoto> photos;
  final List<UserHobby> hobbies;
  final List<String> commonHobbies;
  final Profile? profile;

  DiscoveryCandidate({
    required this.id,
    this.displayName,
    required this.age,
    this.bio,
    this.location,
    this.distance,
    required this.matchScore,
    required this.photos,
    required this.hobbies,
    required this.commonHobbies,
    this.profile,
  });

  factory DiscoveryCandidate.fromJson(Map<String, dynamic> json) {
    return DiscoveryCandidate(
      id: json['id'],
      displayName: json['display_name'],
      age: json['age'] ?? 0,
      bio: json['bio'],
      location: json['location'],
      distance: json['distance']?.toDouble(),
      matchScore: json['match_score'] ?? 0,
      photos: (json['photos'] as List?)
              ?.map((p) => ProfilePhoto.fromJson(p))
              .toList() ??
          [],
      hobbies: (json['hobbies'] as List?)
              ?.map((h) => UserHobby.fromJson(h))
              .toList() ??
          [],
      commonHobbies: (json['common_hobbies'] as List?)?.cast<String>() ?? [],
      profile:
          json['profile'] != null ? Profile.fromJson(json['profile']) : null,
    );
  }
}

class SwipeAction {
  final int userId;
  final String action; // 'like' or 'pass'
  final bool isMatch;
  final Match? match;

  SwipeAction({
    required this.userId,
    required this.action,
    required this.isMatch,
    this.match,
  });

  factory SwipeAction.fromJson(Map<String, dynamic> json) {
    return SwipeAction(
      userId: json['user_id'],
      action: json['action'],
      isMatch: json['is_match'] ?? false,
      match: json['match'] != null ? Match.fromJson(json['match']) : null,
    );
  }
}

class Match {
  final int id;
  final int matchedUserId;
  final String? matchedHobby;
  final User matchedUser;
  final DateTime createdAt;

  Match({
    required this.id,
    required this.matchedUserId,
    this.matchedHobby,
    required this.matchedUser,
    required this.createdAt,
  });

  factory Match.fromJson(Map<String, dynamic> json) {
    return Match(
      id: json['id'],
      matchedUserId: json['matched_user_id'],
      matchedHobby: json['matched_hobby'],
      matchedUser: User.fromJson(json['matched_user']),
      createdAt: DateTime.parse(json['created_at']),
    );
  }
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
