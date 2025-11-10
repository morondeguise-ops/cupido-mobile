import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/discover_model.dart';
import 'services_provider.dart';

// Discover State
class DiscoverState {
  final List<DiscoveryCandidate> candidates;
  final bool isLoading;
  final String? error;
  final int currentIndex;

  DiscoverState({
    this.candidates = const [],
    this.isLoading = false,
    this.error,
    this.currentIndex = 0,
  });

  DiscoverState copyWith({
    List<DiscoveryCandidate>? candidates,
    bool? isLoading,
    String? error,
    int? currentIndex,
  }) {
    return DiscoverState(
      candidates: candidates ?? this.candidates,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      currentIndex: currentIndex ?? this.currentIndex,
    );
  }
}

// Discover Provider
class DiscoverNotifier extends StateNotifier<DiscoverState> {
  final DiscoverService _discoverService;

  DiscoverNotifier(this._discoverService) : super(DiscoverState()) {
    loadCandidates();
  }

  Future<void> loadCandidates() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final candidates = await _discoverService.getDiscoveryQueue();
      state = state.copyWith(
        candidates: candidates,
        isLoading: false,
        currentIndex: 0,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  Future<SwipeAction?> swipe(int candidateId, String action) async {
    try {
      final swipeAction = await _discoverService.swipe(
        candidateId: candidateId,
        action: action,
      );

      // Move to next candidate
      if (state.currentIndex < state.candidates.length - 1) {
        state = state.copyWith(currentIndex: state.currentIndex + 1);
      }

      // Load more candidates if running low
      if (state.candidates.length - state.currentIndex < 5) {
        loadCandidates();
      }

      return swipeAction;
    } catch (e) {
      state = state.copyWith(error: e.toString());
      return null;
    }
  }

  Future<SwipeAction?> like(int candidateId) => swipe(candidateId, 'like');
  Future<SwipeAction?> pass(int candidateId) => swipe(candidateId, 'pass');
}

final discoverProvider =
    StateNotifierProvider<DiscoverNotifier, DiscoverState>((ref) {
  return DiscoverNotifier(ref.read(discoverServiceProvider));
});
