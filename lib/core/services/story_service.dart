import 'dart:io';
import 'package:dio/dio.dart';

import '../config/app_config.dart';
import '../models/post_model.dart';
import 'api_service.dart';

class StoryService {
  final ApiService _api;

  StoryService(this._api);

  // Get all active stories
  Future<List<Story>> getStories() async {
    final response = await _api.get(AppConfig.storiesEndpoint);

    return (response.data['data'] as List)
        .map((story) => Story.fromJson(story))
        .toList();
  }

  // Create story
  Future<Story> createStory(File mediaFile) async {
    final fileName = mediaFile.path.split('/').last;
    final formData = FormData.fromMap({
      'media': await MultipartFile.fromFile(
        mediaFile.path,
        filename: fileName,
      ),
    });

    final response = await _api.postFormData(
      AppConfig.storiesEndpoint,
      formData,
    );

    return Story.fromJson(response.data['data']);
  }

  // Mark story as viewed
  Future<void> viewStory(int storyId) async {
    await _api.post('${AppConfig.storiesEndpoint}/$storyId/view');
  }

  // Delete story
  Future<void> deleteStory(int storyId) async {
    await _api.delete('${AppConfig.storiesEndpoint}/$storyId');
  }
}
