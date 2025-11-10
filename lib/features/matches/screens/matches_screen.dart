import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:timeago/timeago.dart' as timeago;

import '../../../core/theme/app_theme.dart';
import '../../../core/routes/app_router.dart';
import '../../../core/models/match_model.dart';
import '../../../core/providers/match_provider.dart';

class MatchesScreen extends ConsumerWidget {
  const MatchesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final matchesState = ref.watch(matchesProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Matches'),
        actions: [
          if (!matchesState.isLoading)
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: () {
                ref.read(matchesProvider.notifier).loadMatches();
              },
            ),
        ],
      ),
      body: matchesState.isLoading
          ? const Center(child: CircularProgressIndicator())
          : matchesState.matches.isEmpty
              ? _buildEmptyState(context)
              : RefreshIndicator(
                  onRefresh: () => ref.read(matchesProvider.notifier).loadMatches(),
                  child: ListView.builder(
                    itemCount: matchesState.matches.length,
                    itemBuilder: (context, index) {
                      return _buildMatchItem(context, matchesState.matches[index]);
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
            Icons.favorite_border,
            size: 80,
            color: AppTheme.lightGray,
          ),
          const SizedBox(height: 16),
          Text(
            'No matches yet',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          Text(
            'Start swiping to find your matches!',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppTheme.textSecondary,
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildMatchItem(BuildContext context, Match match) {
    return ListTile(
      onTap: () {
        Navigator.pushNamed(
          context,
          AppRouter.chat,
          arguments: {
            'matchId': match.id,
            'matchedUser': match.matchedUser,
          },
        );
      },
      leading: Stack(
        children: [
          CircleAvatar(
            radius: 30,
            backgroundImage: match.matchedUser.photoUrl != null
                ? CachedNetworkImageProvider(match.matchedUser.photoUrl!)
                : null,
            child: match.matchedUser.photoUrl == null
                ? const Icon(Icons.person)
                : null,
          ),
          if (match.matchedUser.isOnline)
            Positioned(
              right: 0,
              bottom: 0,
              child: Container(
                width: 14,
                height: 14,
                decoration: BoxDecoration(
                  color: AppTheme.successColor,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2),
                ),
              ),
            ),
        ],
      ),
      title: Row(
        children: [
          Expanded(
            child: Text(
              match.matchedUser.displayName ?? 'Unknown',
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
          if (match.unreadCount > 0)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: AppTheme.primaryColor,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                match.unreadCount.toString(),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
        ],
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (match.matchedHobby != null)
            Text(
              'Matched on ${match.matchedHobby}',
              style: const TextStyle(
                color: AppTheme.primaryColor,
                fontSize: 12,
              ),
            ),
          if (match.lastMessage != null)
            Text(
              match.lastMessage!,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          if (match.lastMessageAt != null)
            Text(
              timeago.format(match.lastMessageAt!),
              style: const TextStyle(
                fontSize: 12,
                color: AppTheme.textLight,
              ),
            ),
        ],
      ),
      trailing: const Icon(Icons.chevron_right),
    );
  }
}
