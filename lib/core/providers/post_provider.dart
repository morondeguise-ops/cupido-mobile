import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/post_model.dart';
import 'services_provider.dart';

// Feed State
class FeedState {
  final List<Post> posts;
  final bool isLoading;
  final bool isLoadingMore;
  final String? error;
  final int currentPage;
  final bool hasMore;

  FeedState({
    this.posts = const [],
    this.isLoading = false,
    this.isLoadingMore = false,
    this.error,
    this.currentPage = 1,
    this.hasMore = true,
  });

  FeedState copyWith({
    List<Post>? posts,
    bool? isLoading,
    bool? isLoadingMore,
    String? error,
    int? currentPage,
    bool? hasMore,
  }) {
    return FeedState(
      posts: posts ?? this.posts,
      isLoading: isLoading ?? this.isLoading,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      error: error,
      currentPage: currentPage ?? this.currentPage,
      hasMore: hasMore ?? this.hasMore,
    );
  }
}

class FeedNotifier extends StateNotifier<FeedState> {
  final PostService _postService;

  FeedNotifier(this._postService) : super(FeedState()) {
    loadFeed();
  }

  Future<void> loadFeed() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final posts = await _postService.getFeed(page: 1);
      state = state.copyWith(
        posts: posts,
        isLoading: false,
        currentPage: 1,
        hasMore: posts.length >= 20,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> loadMore() async {
    if (!state.hasMore || state.isLoadingMore) return;

    state = state.copyWith(isLoadingMore: true);
    try {
      final nextPage = state.currentPage + 1;
      final posts = await _postService.getFeed(page: nextPage);

      state = state.copyWith(
        posts: [...state.posts, ...posts],
        isLoadingMore: false,
        currentPage: nextPage,
        hasMore: posts.length >= 20,
      );
    } catch (e) {
      state = state.copyWith(isLoadingMore: false, error: e.toString());
    }
  }

  Future<void> likePost(int postId) async {
    try {
      final postIndex = state.posts.indexWhere((p) => p.id == postId);
      if (postIndex == -1) return;

      final post = state.posts[postIndex];
      final isCurrentlyLiked = post.isLiked;

      // Optimistically update UI
      final updatedPosts = List<Post>.from(state.posts);
      updatedPosts[postIndex] = Post(
        id: post.id,
        userId: post.userId,
        caption: post.caption,
        likesCount: isCurrentlyLiked ? post.likesCount - 1 : post.likesCount + 1,
        commentsCount: post.commentsCount,
        isLiked: !isCurrentlyLiked,
        createdAt: post.createdAt,
        user: post.user,
        media: post.media,
        hobbies: post.hobbies,
      );

      state = state.copyWith(posts: updatedPosts);

      // Make API call
      if (isCurrentlyLiked) {
        await _postService.unlikePost(postId);
      } else {
        await _postService.likePost(postId);
      }
    } catch (e) {
      // Revert on error
      loadFeed();
      state = state.copyWith(error: e.toString());
    }
  }

  Future<void> deletePost(int postId) async {
    try {
      await _postService.deletePost(postId);
      state = state.copyWith(
        posts: state.posts.where((p) => p.id != postId).toList(),
      );
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  Future<void> refresh() => loadFeed();
}

final feedProvider = StateNotifierProvider<FeedNotifier, FeedState>((ref) {
  return FeedNotifier(ref.read(postServiceProvider));
});

// Stories State
class StoriesState {
  final List<Story> stories;
  final bool isLoading;
  final String? error;

  StoriesState({
    this.stories = const [],
    this.isLoading = false,
    this.error,
  });

  StoriesState copyWith({
    List<Story>? stories,
    bool? isLoading,
    String? error,
  }) {
    return StoriesState(
      stories: stories ?? this.stories,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

class StoriesNotifier extends StateNotifier<StoriesState> {
  final StoryService _storyService;

  StoriesNotifier(this._storyService) : super(StoriesState()) {
    loadStories();
  }

  Future<void> loadStories() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final stories = await _storyService.getStories();
      state = state.copyWith(stories: stories, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> viewStory(int storyId) async {
    try {
      await _storyService.viewStory(storyId);

      final updatedStories = state.stories.map((story) {
        if (story.id == storyId) {
          return Story(
            id: story.id,
            userId: story.userId,
            mediaUrl: story.mediaUrl,
            mediaType: story.mediaType,
            viewsCount: story.viewsCount + 1,
            isViewed: true,
            expiresAt: story.expiresAt,
            createdAt: story.createdAt,
            user: story.user,
          );
        }
        return story;
      }).toList();

      state = state.copyWith(stories: updatedStories);
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }
}

final storiesProvider =
    StateNotifierProvider<StoriesNotifier, StoriesState>((ref) {
  return StoriesNotifier(ref.read(storyServiceProvider));
});
