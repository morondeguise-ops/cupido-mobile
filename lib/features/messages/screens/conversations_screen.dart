import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:timeago/timeago.dart' as timeago;

import '../../../core/models/chat_model.dart';
import '../../../core/services/chat_service.dart';
import '../../../core/services/api_service.dart';
import '../../../core/theme/app_theme.dart';
import 'chat_detail_screen.dart';

/// Provider for chat service
final chatServiceProvider = Provider<ChatService>((ref) {
  return ChatService(ApiService());
});

/// Provider for conversations list
final conversationsProvider = FutureProvider<List<ChatConversation>>((ref) async {
  final chatService = ref.watch(chatServiceProvider);
  return await chatService.getConversations();
});

class ConversationsScreen extends ConsumerStatefulWidget {
  const ConversationsScreen({super.key});

  @override
  ConsumerState<ConversationsScreen> createState() => _ConversationsScreenState();
}

class _ConversationsScreenState extends ConsumerState<ConversationsScreen> {
  @override
  Widget build(BuildContext context) {
    final conversationsAsync = ref.watch(conversationsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Messages'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              // TODO: Implement search
            },
          ),
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              // TODO: Create new conversation
            },
          ),
        ],
      ),
      body: conversationsAsync.when(
        data: (conversations) {
          if (conversations.isEmpty) {
            return _buildEmptyState();
          }
          return RefreshIndicator(
            onRefresh: () async {
              ref.invalidate(conversationsProvider);
            },
            child: ListView.builder(
              itemCount: conversations.length,
              itemBuilder: (context, index) {
                return _buildConversationTile(conversations[index]);
              },
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 48, color: AppTheme.errorColor),
              const SizedBox(height: 16),
              Text('Error: $error'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  ref.invalidate(conversationsProvider);
                },
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.chat_bubble_outline,
            size: 80,
            color: AppTheme.lightGray,
          ),
          const SizedBox(height: 16),
          Text(
            'No conversations yet',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          Text(
            'Start matching to begin chatting!',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppTheme.textSecondary,
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildConversationTile(ChatConversation conversation) {
    final lastMessage = conversation.recentMessages?.isNotEmpty == true
        ? conversation.recentMessages!.first
        : null;
    final hasUnread = lastMessage != null && !lastMessage.isRead;

    return ListTile(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ChatDetailScreen(
              conversationId: conversation.id,
              conversation: conversation,
            ),
          ),
        );
      },
      leading: Stack(
        children: [
          CircleAvatar(
            radius: 28,
            backgroundColor: AppTheme.primaryColor,
            child: Text(
              _getConversationInitials(conversation),
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          if (hasUnread)
            Positioned(
              right: 0,
              top: 0,
              child: Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  color: AppTheme.primaryColor,
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
              conversation.title ?? 'Conversation',
              style: TextStyle(
                fontWeight: hasUnread ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ),
          if (lastMessage != null && lastMessage.sentAt != null)
            Text(
              timeago.format(lastMessage.sentAt),
              style: TextStyle(
                fontSize: 12,
                color: AppTheme.textSecondary,
                fontWeight: hasUnread ? FontWeight.bold : FontWeight.normal,
              ),
            ),
        ],
      ),
      subtitle: lastMessage != null
          ? Row(
              children: [
                if (lastMessage.isDeleted)
                  const Icon(Icons.block, size: 14, color: AppTheme.textSecondary)
                else if (lastMessage.messageType == ChatMessageType.image)
                  const Icon(Icons.photo, size: 14, color: AppTheme.textSecondary)
                else if (lastMessage.messageType == ChatMessageType.video)
                  const Icon(Icons.videocam, size: 14, color: AppTheme.textSecondary)
                else if (lastMessage.messageType == ChatMessageType.audio)
                  const Icon(Icons.mic, size: 14, color: AppTheme.textSecondary),
                if (lastMessage.messageType != ChatMessageType.text)
                  const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    lastMessage.isDeleted
                        ? 'Message deleted'
                        : _getMessagePreview(lastMessage),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: AppTheme.textSecondary,
                      fontWeight: hasUnread ? FontWeight.w600 : FontWeight.normal,
                    ),
                  ),
                ),
              ],
            )
          : const Text(
              'No messages yet',
              style: TextStyle(color: AppTheme.textSecondary),
            ),
      trailing: conversation.type == ConversationType.group
          ? const Icon(Icons.group, size: 20, color: AppTheme.textSecondary)
          : null,
    );
  }

  String _getConversationInitials(ChatConversation conversation) {
    if (conversation.title != null && conversation.title!.isNotEmpty) {
      return conversation.title!.substring(0, 1).toUpperCase();
    }
    return 'C';
  }

  String _getMessagePreview(ChatMessage message) {
    switch (message.messageType) {
      case ChatMessageType.image:
        return 'Photo';
      case ChatMessageType.video:
        return 'Video';
      case ChatMessageType.audio:
        return 'Audio';
      case ChatMessageType.file:
        return 'File';
      default:
        return message.content;
    }
  }
}
