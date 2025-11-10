import 'dart:io';
import 'package:dio/dio.dart';

import '../config/app_config.dart';
import '../models/post_model.dart';
import 'api_service.dart';

class PostService {
  final ApiService _api;

  PostService(this._api);

  // Get feed
  Future<List<Post>> getFeed({int page = 1, int limit = 20}) async {
    final response = await _api.get(
      AppConfig.postsEndpoint,
      queryParameters: {
        'page': page,
        'limit': limit,
      },
    );

    return (response.data['data'] as List)
        .map((post) => Post.fromJson(post))
        .toList();
  }

  // Create post
  Future<Post> createPost({
    String? caption,
    List<File>? mediaFiles,
    List<String>? hobbies,
  }) async {
    final formData = FormData.fromMap({
      if (caption != null) 'caption': caption,
      if (hobbies != null) 'hobbies': hobbies,
    });

    if (mediaFiles != null && mediaFiles.isNotEmpty) {
      for (var i = 0; i < mediaFiles.length; i++) {
        final file = mediaFiles[i];
        final fileName = file.path.split('/').last;
        formData.files.add(MapEntry(
          'media[$i]',
          await MultipartFile.fromFile(
            file.path,
            filename: fileName,
          ),
        ));
      }
    }

    final response = await _api.postFormData(
      AppConfig.postsEndpoint,
      formData,
    );

    return Post.fromJson(response.data['data']);
  }

  // Like post
  Future<void> likePost(int postId) async {
    await _api.post('${AppConfig.postsEndpoint}/$postId/like');
  }

  // Unlike post
  Future<void> unlikePost(int postId) async {
    await _api.delete('${AppConfig.postsEndpoint}/$postId/like');
  }

  // Get comments
  Future<List<Comment>> getComments(int postId) async {
    final response = await _api.get(
      '${AppConfig.postsEndpoint}/$postId/comments',
    );

    return (response.data['data'] as List)
        .map((comment) => Comment.fromJson(comment))
        .toList();
  }

  // Add comment
  Future<Comment> addComment(int postId, String content) async {
    final response = await _api.post(
      '${AppConfig.postsEndpoint}/$postId/comments',
      data: {'content': content},
    );

    return Comment.fromJson(response.data['data']);
  }

  // Delete post
  Future<void> deletePost(int postId) async {
    await _api.delete('${AppConfig.postsEndpoint}/$postId');
  }
}
