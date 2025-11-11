/// Kink and interest models for the Cupido app
///
/// Corresponds to Cupido\Core\Models\Kink namespace in backend

class KinkInterest {
  final int id;
  final String name;
  final String slug;
  final String? description;
  final String? category;
  final String? icon;
  final bool ageRestricted;
  final bool requiresVerification;
  final bool isActive;
  final int sortOrder;
  final DateTime createdAt;
  final DateTime updatedAt;

  KinkInterest({
    required this.id,
    required this.name,
    required this.slug,
    this.description,
    this.category,
    this.icon,
    required this.ageRestricted,
    required this.requiresVerification,
    required this.isActive,
    required this.sortOrder,
    required this.createdAt,
    required this.updatedAt,
  });

  factory KinkInterest.fromJson(Map<String, dynamic> json) {
    return KinkInterest(
      id: json['id'],
      name: json['name'],
      slug: json['slug'],
      description: json['description'],
      category: json['category'],
      icon: json['icon'],
      ageRestricted: json['age_restricted'] ?? false,
      requiresVerification: json['requires_verification'] ?? false,
      isActive: json['is_active'] ?? true,
      sortOrder: json['sort_order'] ?? 0,
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'slug': slug,
      'description': description,
      'category': category,
      'icon': icon,
      'age_restricted': ageRestricted,
      'requires_verification': requiresVerification,
      'is_active': isActive,
      'sort_order': sortOrder,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}

/// User's kink interests with privacy settings
class UserKinkInterest {
  final int id;
  final int userId;
  final int kinkInterestId;
  final String privacyLevel;
  final bool isVerified;
  final DateTime? verifiedAt;
  final DateTime createdAt;
  final DateTime updatedAt;

  // Optional relationship
  final KinkInterest? kinkInterest;

  UserKinkInterest({
    required this.id,
    required this.userId,
    required this.kinkInterestId,
    required this.privacyLevel,
    required this.isVerified,
    this.verifiedAt,
    required this.createdAt,
    required this.updatedAt,
    this.kinkInterest,
  });

  factory UserKinkInterest.fromJson(Map<String, dynamic> json) {
    return UserKinkInterest(
      id: json['id'],
      userId: json['user_id'],
      kinkInterestId: json['kink_interest_id'],
      privacyLevel: json['privacy_level'] ?? 'private',
      isVerified: json['is_verified'] ?? false,
      verifiedAt: json['verified_at'] != null
          ? DateTime.parse(json['verified_at'])
          : null,
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
      kinkInterest: json['kink_interest'] != null
          ? KinkInterest.fromJson(json['kink_interest'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'kink_interest_id': kinkInterestId,
      'privacy_level': privacyLevel,
      'is_verified': isVerified,
      'verified_at': verifiedAt?.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}

/// Kink interest categories
class KinkCategory {
  static const String romantic = 'romantic';
  static const String physical = 'physical';
  static const String roleplay = 'roleplay';
  static const String lifestyle = 'lifestyle';
  static const String fetish = 'fetish';
  static const String bdsm = 'bdsm';
  static const String other = 'other';
}

/// Privacy levels for kink interests
class KinkPrivacyLevel {
  static const String publicLevel = 'public';
  static const String matchesOnly = 'matches_only';
  static const String privateLevel = 'private';
}
