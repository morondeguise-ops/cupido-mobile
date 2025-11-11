import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_card_swiper/flutter_card_swiper.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/providers/discover_provider.dart';
import '../../../core/widgets/ad_banner_widget.dart';
import '../widgets/candidate_card.dart';

class DiscoverScreen extends ConsumerStatefulWidget {
  const DiscoverScreen({super.key});

  @override
  ConsumerState<DiscoverScreen> createState() => _DiscoverScreenState();
}

class _DiscoverScreenState extends ConsumerState<DiscoverScreen> {
  final CardSwiperController _cardController = CardSwiperController();

  Future<bool> _onSwipe(int previousIndex, int? currentIndex, CardSwiperDirection direction) async {
    if (currentIndex == null) return false;

    final state = ref.read(discoverProvider);
    if (previousIndex >= state.candidates.length) return false;

    final candidate = state.candidates[previousIndex];
    final action = direction == CardSwiperDirection.right ? 'like' : 'pass';

    // Send swipe action to API
    final swipeAction = await ref.read(discoverProvider.notifier).swipe(
      candidate.id,
      action,
    );

    // Show match dialog if it's a match
    if (swipeAction != null && swipeAction.isMatch && mounted) {
      _showMatchDialog(swipeAction);
    }

    return true;
  }

  void _showMatchDialog(swipeAction) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('It\'s a Match! 🎉'),
        content: Text(
          'You and ${swipeAction.match?.matchedUser.displayName ?? 'someone'} liked each other!',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Keep Swiping'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              // Navigate to chat
            },
            child: const Text('Send Message'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final discoverState = ref.watch(discoverProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Discover'),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () {
              // TODO: Show filters dialog
            },
          ),
        ],
      ),
      body: SafeArea(
        child: discoverState.isLoading
            ? const Center(child: CircularProgressIndicator())
            : discoverState.candidates.isEmpty
                ? _buildEmptyState()
                : _buildSwipeView(discoverState.candidates),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.person_search,
            size: 80,
            color: AppTheme.lightGray,
          ),
          const SizedBox(height: 16),
          Text(
            'No more profiles nearby',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          Text(
            'Try adjusting your filters',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppTheme.textSecondary,
                ),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () => ref.read(discoverProvider.notifier).loadCandidates(),
            child: const Text('Reload'),
          ),
        ],
      ),
    );
  }

  Widget _buildSwipeView(candidates) {
    return Column(
      children: [
        Expanded(
          child: CardSwiper(
            controller: _cardController,
            cardsCount: candidates.length,
            onSwipe: _onSwipe,
            numberOfCardsDisplayed: 3,
            backCardOffset: const Offset(0, 40),
            padding: const EdgeInsets.all(24.0),
            cardBuilder: (context, index, horizontalThresholdPercentage,
                verticalThresholdPercentage) {
              return CandidateCard(candidate: candidates[index]);
            },
          ),
        ),
        const AdBannerWidget(
          placementKey: 'discover_banner',
          margin: EdgeInsets.symmetric(vertical: 8),
        ),
        _buildActionButtons(),
        const SizedBox(height: 24),
      ],
    );
  }

  Widget _buildActionButtons() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          // Pass Button
          FloatingActionButton(
            onPressed: () => _cardController.swipe(CardSwiperDirection.left),
            backgroundColor: Colors.white,
            child: const Icon(Icons.close, color: AppTheme.errorColor, size: 32),
          ),
          // Super Like Button (Premium)
          FloatingActionButton(
            onPressed: () {
              // TODO: Handle super like
            },
            backgroundColor: Colors.white,
            child: const Icon(Icons.star, color: AppTheme.warningColor, size: 32),
          ),
          // Like Button
          FloatingActionButton(
            onPressed: () => _cardController.swipe(CardSwiperDirection.right),
            backgroundColor: Colors.white,
            child: const Icon(Icons.favorite, color: AppTheme.successColor, size: 32),
          ),
        ],
      ),
    );
  }
}
