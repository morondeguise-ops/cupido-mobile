class User {
  final int id;
  final String phone;
  final String? displayName;
  final String? bio;
  final DateTime? birthdate;
  final String? gender;
  final String? location;
  final double? latitude;
  final double? longitude;
  final String status;
  final int? sponsorId;
  final bool isVerified;
  final bool isPremium;
  final int trustScore;
  final int profileCompletionPercentage;
  final DateTime? lastSeenAt;
  final DateTime createdAt;
  final Profile? profile;
  final List<ProfilePhoto>? photos;
  final List<UserHobby>? hobbies;

  User({
    required this.id,
    required this.phone,
    this.displayName,
    this.bio,
    this.birthdate,
    this.gender,
    this.location,
    this.latitude,
    this.longitude,
    required this.status,
    this.sponsorId,
    required this.isVerified,
    required this.isPremium,
    required this.trustScore,
    required this.profileCompletionPercentage,
    this.lastSeenAt,
    required this.createdAt,
    this.profile,
    this.photos,
    this.hobbies,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      phone: json['phone'],
      displayName: json['display_name'],
      bio: json['bio'],
      birthdate: json['birthdate'] != null
          ? DateTime.parse(json['birthdate'])
          : null,
      gender: json['gender'],
      location: json['location'],
      latitude: json['latitude']?.toDouble(),
      longitude: json['longitude']?.toDouble(),
      status: json['status'],
      sponsorId: json['sponsor_id'],
      isVerified: json['is_verified'] ?? false,
      isPremium: json['is_premium'] ?? false,
      trustScore: json['trust_score'] ?? 0,
      profileCompletionPercentage: json['profile_completion_percentage'] ?? 0,
      lastSeenAt: json['last_seen_at'] != null
          ? DateTime.parse(json['last_seen_at'])
          : null,
      createdAt: DateTime.parse(json['created_at']),
      profile: json['profile'] != null
          ? Profile.fromJson(json['profile'])
          : null,
      photos: json['photos'] != null
          ? (json['photos'] as List)
              .map((photo) => ProfilePhoto.fromJson(photo))
              .toList()
          : null,
      hobbies: json['hobbies'] != null
          ? (json['hobbies'] as List)
              .map((hobby) => UserHobby.fromJson(hobby))
              .toList()
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'phone': phone,
      'display_name': displayName,
      'bio': bio,
      'birthdate': birthdate?.toIso8601String(),
      'gender': gender,
      'location': location,
      'latitude': latitude,
      'longitude': longitude,
      'status': status,
      'sponsor_id': sponsorId,
      'is_verified': isVerified,
      'is_premium': isPremium,
      'trust_score': trustScore,
      'profile_completion_percentage': profileCompletionPercentage,
      'last_seen_at': lastSeenAt?.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
    };
  }

  int get age {
    if (birthdate == null) return 0;
    final now = DateTime.now();
    int age = now.year - birthdate!.year;
    if (now.month < birthdate!.month ||
        (now.month == birthdate!.month && now.day < birthdate!.day)) {
      age--;
    }
    return age;
  }
}

class Profile {
  final int id;
  final int userId;
  final String? occupation;
  final String? education;
  final String? relationshipGoal;
  final String? smokingStatus;
  final String? drinkingStatus;
  final String? dietaryPreference;
  final String? exerciseFrequency;
  final int? height;
  final String? religion;
  final String? politicalView;
  final bool? hasChildren;
  final bool? wantsChildren;
  final String? languagesSpoken;
  final String? petPreference;

  Profile({
    required this.id,
    required this.userId,
    this.occupation,
    this.education,
    this.relationshipGoal,
    this.smokingStatus,
    this.drinkingStatus,
    this.dietaryPreference,
    this.exerciseFrequency,
    this.height,
    this.religion,
    this.politicalView,
    this.hasChildren,
    this.wantsChildren,
    this.languagesSpoken,
    this.petPreference,
  });

  factory Profile.fromJson(Map<String, dynamic> json) {
    return Profile(
      id: json['id'],
      userId: json['user_id'],
      occupation: json['occupation'],
      education: json['education'],
      relationshipGoal: json['relationship_goal'],
      smokingStatus: json['smoking_status'],
      drinkingStatus: json['drinking_status'],
      dietaryPreference: json['dietary_preference'],
      exerciseFrequency: json['exercise_frequency'],
      height: json['height'],
      religion: json['religion'],
      politicalView: json['political_view'],
      hasChildren: json['has_children'],
      wantsChildren: json['wants_children'],
      languagesSpoken: json['languages_spoken'],
      petPreference: json['pet_preference'],
    );
  }
}

class ProfilePhoto {
  final int id;
  final int userId;
  final String photoUrl;
  final int order;
  final bool isPrimary;

  ProfilePhoto({
    required this.id,
    required this.userId,
    required this.photoUrl,
    required this.order,
    required this.isPrimary,
  });

  factory ProfilePhoto.fromJson(Map<String, dynamic> json) {
    return ProfilePhoto(
      id: json['id'],
      userId: json['user_id'],
      photoUrl: json['photo_url'],
      order: json['order'],
      isPrimary: json['is_primary'] ?? false,
    );
  }
}

class UserHobby {
  final int id;
  final String name;
  final String? description;
  final String? category;
  final int skillLevel;

  UserHobby({
    required this.id,
    required this.name,
    this.description,
    this.category,
    required this.skillLevel,
  });

  factory UserHobby.fromJson(Map<String, dynamic> json) {
    return UserHobby(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      category: json['category'],
      skillLevel: json['pivot']?['skill_level'] ?? json['skill_level'] ?? 1,
    );
  }
}
