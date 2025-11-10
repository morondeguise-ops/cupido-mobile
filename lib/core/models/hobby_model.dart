class Hobby {
  final int id;
  final String name;
  final String? description;
  final String? category;
  final String? iconUrl;
  final bool isActive;

  Hobby({
    required this.id,
    required this.name,
    this.description,
    this.category,
    this.iconUrl,
    required this.isActive,
  });

  factory Hobby.fromJson(Map<String, dynamic> json) {
    return Hobby(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      category: json['category'],
      iconUrl: json['icon_url'],
      isActive: json['is_active'] ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'category': category,
      'icon_url': iconUrl,
      'is_active': isActive,
    };
  }
}

class HobbyCategory {
  final String name;
  final List<Hobby> hobbies;

  HobbyCategory({
    required this.name,
    required this.hobbies,
  });
}

class SelectedHobby {
  final Hobby hobby;
  int skillLevel;

  SelectedHobby({
    required this.hobby,
    required this.skillLevel,
  });

  Map<String, dynamic> toJson() {
    return {
      'hobby_id': hobby.id,
      'skill_level': skillLevel,
    };
  }
}
