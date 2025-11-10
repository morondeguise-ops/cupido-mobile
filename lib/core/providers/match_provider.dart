import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/match_model.dart';
import 'services_provider.dart';

// Matches State
class MatchesState {
  final List<Match> matches;
  final bool isLoading;
  final String? error;

  MatchesState({
    this.matches = const [],
    this.isLoading = false,
    this.error,
  });

  MatchesState copyWith({
    List<Match>? matches,
    bool? isLoading,
    String? error,
  }) {
    return MatchesState(
      matches: matches ?? this.matches,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

class MatchesNotifier extends StateNotifier<MatchesState> {
  final MatchService _matchService;

  MatchesNotifier(this._matchService) : super(MatchesState()) {
    loadMatches();
  }

  Future<void> loadMatches() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final matches = await _matchService.getMatches();
      state = state.copyWith(matches: matches, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> unmatch(int matchId) async {
    try {
      await _matchService.unmatch(matchId);
      state = state.copyWith(
        matches: state.matches.where((m) => m.id != matchId).toList(),
      );
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }
}

final matchesProvider =
    StateNotifierProvider<MatchesNotifier, MatchesState>((ref) {
  return MatchesNotifier(ref.read(matchServiceProvider));
});

// Messages State for a specific match
class MessagesState {
  final List<Message> messages;
  final bool isLoading;
  final bool isSending;
  final String? error;

  MessagesState({
    this.messages = const [],
    this.isLoading = false,
    this.isSending = false,
    this.error,
  });

  MessagesState copyWith({
    List<Message>? messages,
    bool? isLoading,
    bool? isSending,
    String? error,
  }) {
    return MessagesState(
      messages: messages ?? this.messages,
      isLoading: isLoading ?? this.isLoading,
      isSending: isSending ?? this.isSending,
      error: error,
    );
  }
}

class MessagesNotifier extends StateNotifier<MessagesState> {
  final MatchService _matchService;
  final int matchId;

  MessagesNotifier(this._matchService, this.matchId) : super(MessagesState()) {
    loadMessages();
  }

  Future<void> loadMessages() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final messages = await _matchService.getMessages(matchId);
      state = state.copyWith(
        messages: messages.reversed.toList(),
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> sendMessage(String content) async {
    state = state.copyWith(isSending: true);
    try {
      final message = await _matchService.sendMessage(
        matchId: matchId,
        content: content,
      );
      state = state.copyWith(
        messages: [message, ...state.messages],
        isSending: false,
      );

      // Mark messages as read
      await _matchService.markAsRead(matchId);
    } catch (e) {
      state = state.copyWith(isSending: false, error: e.toString());
    }
  }
}

// Provider family for messages by match ID
final messagesProvider = StateNotifierProvider.family<
    MessagesNotifier,
    MessagesState,
    int>((ref, matchId) {
  return MessagesNotifier(ref.read(matchServiceProvider), matchId);
});
