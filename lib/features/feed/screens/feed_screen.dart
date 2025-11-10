import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:timeago/timeago.dart' as timeago;

import '../../../core/theme/app_theme.dart';
import '../../../core/models/post_model.dart';
import '../../../core/providers/post_provider.dart';
import '../../../core/widgets/ad_banner_widget.dart';

class FeedScreen extends ConsumerWidget {
  const FeedScreen({super.key});

  Future<void> _likePost(WidgetRef ref, int postId) async {
    await ref.read(feedProvider.notifier).likePost(postId);
  }

  int _calculateItemCount(int postCount, bool hasMore) {
    const adFrequency = 5;
    // Calculate number of ads that will be shown
    final adCount = postCount ~/ adFrequency;
    // Total items = posts + ads + (load more indicator if hasMore)
    return postCount + adCount + (hasMore ? 1 : 0);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final feedState = ref.watch(feedProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Feed'),
        actions: [
          if (!feedState.isLoading)
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: () {
                ref.read(feedProvider.notifier).refresh();
              },
            ),
          IconButton(
            icon: const Icon(Icons.add_box_outlined),
            onPressed: () {
              // TODO: Create new post
            },
          ),
        ],
      ),
      body: feedState.isLoading
          ? const Center(child: CircularProgressIndicator())
          : feedState.posts.isEmpty
              ? _buildEmptyState(context)
              : RefreshIndicator(
                  onRefresh: () => ref.read(feedProvider.notifier).refresh(),
                  child: ListView.builder(
                    itemCount: _calculateItemCount(feedState.posts.length, feedState.hasMore),
                    itemBuilder: (context, index) {
                      // Handle load more indicator
                      if (feedState.hasMore && index == _calculateItemCount(feedState.posts.length, feedState.hasMore) - 1) {
                        if (!feedState.isLoadingMore) {
                          ref.read(feedProvider.notifier).loadMore();
                        }
                        return const Padding(
                          padding: EdgeInsets.all(16.0),
                          child: Center(child: CircularProgressIndicator()),
                        );
                      }

                      // Calculate if this position should show an ad
                      // Ads appear every 5 items (configurable via admin)
                      const adFrequency = 5;
                      final adjustedIndex = index;

                      // Show ad after every adFrequency posts
                      if ((adjustedIndex + 1) % (adFrequency + 1) == 0) {
                        return const AdBannerWidget(
                          placementKey: 'feed_banner',
                          margin: EdgeInsets.symmetric(vertical: 8),
                        );
                      }

                      // Calculate the actual post index (accounting for ads)
                      final adsBefore = adjustedIndex ~/ (adFrequency + 1);
                      final postIndex = adjustedIndex - adsBefore;

                      if (postIndex >= feedState.posts.length) {
                        return const SizedBox.shrink();
                      }

                      return _buildPostItem(context, ref, feedState.posts[postIndex]);
                    },
                  ),
                ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.feed_outlined,
            size: 80,
            color: AppTheme.lightGray,
          ),
          const SizedBox(height: 16),
          Text(
            'No posts yet',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          Text(
            'Start following people to see their posts',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppTheme.textSecondary,
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildPostItem(BuildContext context, WidgetRef ref, Post post) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // User Info
          ListTile(
            leading: CircleAvatar(
              backgroundImage: post.user.photoUrl != null
                  ? CachedNetworkImageProvider(post.user.photoUrl!)
                  : null,
              child: post.user.photoUrl == null
                  ? const Icon(Icons.person)
                  : null,
            ),
            title: Text(post.user.displayName ?? 'Unknown'),
            subtitle: Text(timeago.format(post.createdAt)),
            trailing: IconButton(
              icon: const Icon(Icons.more_vert),
              onPressed: () {
                // TODO: Show post options
              },
            ),
          ),
          // Media
          if (post.media.isNotEmpty)
            AspectRatio(
              aspectRatio: 1,
              child: CachedNetworkImage(
                imageUrl: post.media.first.mediaUrl,
                fit: BoxFit.cover,
              ),
            ),
          // Actions
          Row(
            children: [
              IconButton(
                icon: Icon(
                  post.isLiked ? Icons.favorite : Icons.favorite_border,
                  color: post.isLiked ? AppTheme.errorColor : null,
                ),
                onPressed: () => _likePost(ref, post.id),
              ),
              Text('${post.likesCount}'),
              const SizedBox(width: 16),
              IconButton(
                icon: const Icon(Icons.comment_outlined),
                onPressed: () {
                  // TODO: Show comments
                },
              ),
              Text('${post.commentsCount}'),
            ],
          ),
          // Caption
          if (post.caption != null)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Text(post.caption!),
            ),
          // Hobbies
          if (post.hobbies.isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Wrap(
                spacing: 8,
                children: post.hobbies.map((hobby) {
                  return Chip(
                    label: Text(hobby),
                    backgroundColor: AppTheme.primaryColor.withOpacity(0.1),
                    labelStyle: const TextStyle(
                      color: AppTheme.primaryColor,
                      fontSize: 12,
                    ),
                  );
                }).toList(),
              ),
            ),
        ],
      ),
    );
  }
}
