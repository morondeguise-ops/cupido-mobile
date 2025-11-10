import 'dart:io';
import 'package:dio/dio.dart';

import '../config/app_config.dart';
import '../models/user_model.dart';
import '../models/hobby_model.dart';
import 'api_service.dart';

class ProfileService {
  final ApiService _api;

  ProfileService(this._api);

  // Update profile
  Future<User> updateProfile(Map<String, dynamic> profileData) async {
    final response = await _api.put(
      AppConfig.profileEndpoint,
      data: profileData,
    );

    return User.fromJson(response.data['data']);
  }

  // Upload profile photo
  Future<ProfilePhoto> uploadPhoto(File photoFile) async {
    final fileName = photoFile.path.split('/').last;
    final formData = FormData.fromMap({
      'photo': await MultipartFile.fromFile(
        photoFile.path,
        filename: fileName,
      ),
    });

    final response = await _api.postFormData(
      AppConfig.profilePhotosEndpoint,
      formData,
    );

    return ProfilePhoto.fromJson(response.data['data']);
  }

  // Delete profile photo
  Future<void> deletePhoto(int photoId) async {
    await _api.delete('${AppConfig.profilePhotosEndpoint}/$photoId');
  }

  // Reorder photos
  Future<void> reorderPhotos(List<int> photoIds) async {
    await _api.put(
      '${AppConfig.profilePhotosEndpoint}/reorder',
      data: {'photo_ids': photoIds},
    );
  }

  // Update hobbies
  Future<List<UserHobby>> updateHobbies(
    List<Map<String, dynamic>> hobbies,
  ) async {
    final response = await _api.put(
      AppConfig.profileHobbiesEndpoint,
      data: {'hobbies': hobbies},
    );

    return (response.data['data'] as List)
        .map((hobby) => UserHobby.fromJson(hobby))
        .toList();
  }

  // Get all hobbies
  Future<List<Hobby>> getAllHobbies() async {
    final response = await _api.get(AppConfig.hobbiesEndpoint);

    return (response.data['data'] as List)
        .map((hobby) => Hobby.fromJson(hobby))
        .toList();
  }

  // Search hobbies
  Future<List<Hobby>> searchHobbies(String query) async {
    final response = await _api.get(
      '${AppConfig.hobbiesEndpoint}/search/$query',
    );

    return (response.data['data'] as List)
        .map((hobby) => Hobby.fromJson(hobby))
        .toList();
  }

  // Update location
  Future<void> updateLocation(double latitude, double longitude) async {
    await _api.put(
      AppConfig.profileEndpoint,
      data: {
        'latitude': latitude,
        'longitude': longitude,
      },
    );
  }

  // Update preferences
  Future<void> updatePreferences({
    int? minAge,
    int? maxAge,
    String? genderPreference,
    int? maxDistance,
  }) async {
    await _api.put(
      '${AppConfig.profileEndpoint}/preferences',
      data: {
        if (minAge != null) 'min_age': minAge,
        if (maxAge != null) 'max_age': maxAge,
        if (genderPreference != null) 'gender_preference': genderPreference,
        if (maxDistance != null) 'max_distance': maxDistance,
      },
    );
  }
}
