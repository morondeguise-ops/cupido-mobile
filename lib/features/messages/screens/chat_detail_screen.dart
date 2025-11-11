import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:timeago/timeago.dart' as timeago;

import '../../../core/models/chat_model.dart';
import '../../../core/services/chat_service.dart';
import '../../../core/services/api_service.dart';
import '../../../core/theme/app_theme.dart';

/// Provider for chat service
final chatServiceProvider = Provider<ChatService>((ref) {
  return ChatService(ApiService());
});

/// Provider for messages in a conversation
final messagesProvider = FutureProvider.family<List<ChatMessage>, int>((ref, conversationId) async {
  final chatService = ref.watch(chatServiceProvider);
  return await chatService.getMessages(conversationId, perPage: 50);
});

class ChatDetailScreen extends ConsumerStatefulWidget {
  final int conversationId;
  final ChatConversation conversation;

  const ChatDetailScreen({
    super.key,
    required this.conversationId,
    required this.conversation,
  });

  @override
  ConsumerState<ChatDetailScreen> createState() => _ChatDetailScreenState();
}

class _ChatDetailScreenState extends ConsumerState<ChatDetailScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool _isSending = false;

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _sendMessage() async {
    final content = _messageController.text.trim();
    if (content.isEmpty || _isSending) return;

    setState(() => _isSending = true);
    _messageController.clear();

    try {
      final chatService = ref.read(chatServiceProvider);
      await chatService.sendMessage(
        conversationId: widget.conversationId,
        content: content,
        messageType: ChatMessageType.text,
      );

      // Refresh messages
      ref.invalidate(messagesProvider(widget.conversationId));

      // Scroll to bottom
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          0,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to send message: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSending = false);
      }
    }
  }

  Future<void> _deleteMessage(ChatMessage message) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Message'),
        content: const Text('Are you sure you want to delete this message?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete', style: TextStyle(color: AppTheme.errorColor)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        final chatService = ref.read(chatServiceProvider);
        await chatService.deleteMessage(
          conversationId: widget.conversationId,
          messageId: message.id,
        );
        ref.invalidate(messagesProvider(widget.conversationId));
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to delete message: $e')),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final messagesAsync = ref.watch(messagesProvider(widget.conversationId));

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.conversation.title ?? 'Conversation',
              style: const TextStyle(fontSize: 16),
            ),
            Text(
              '${widget.conversation.participants.length} participants',
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.normal,
                color: AppTheme.textSecondary,
              ),
            ),
          ],
        ),
        actions: [
          if (widget.conversation.type == ConversationType.direct)
            IconButton(
              icon: const Icon(Icons.videocam),
              onPressed: () {
                // TODO: Start video call
              },
            ),
          if (widget.conversation.type == ConversationType.direct)
            IconButton(
              icon: const Icon(Icons.call),
              onPressed: () {
                // TODO: Start voice call
              },
            ),
          IconButton(
            icon: const Icon(Icons.more_vert),
            onPressed: () {
              _showOptionsMenu();
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: messagesAsync.when(
              data: (messages) {
                if (messages.isEmpty) {
                  return _buildEmptyState();
                }
                return ListView.builder(
                  reverse: true,
                  controller: _scrollController,
                  padding: const EdgeInsets.all(16),
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final message = messages[index];
                    final showDateSeparator = _shouldShowDateSeparator(
                      message,
                      index < messages.length - 1 ? messages[index + 1] : null,
                    );
                    return Column(
                      children: [
                        if (showDateSeparator) _buildDateSeparator(message.sentAt),
                        _buildMessageBubble(message),
                      ],
                    );
                  },
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, stack) => Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error_outline, size: 48, color: AppTheme.errorColor),
                    const SizedBox(height: 16),
                    Text('Error loading messages'),
                    const SizedBox(height: 8),
                    ElevatedButton(
                      onPressed: () {
                        ref.invalidate(messagesProvider(widget.conversationId));
                      },
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              ),
            ),
          ),
          _buildMessageInput(),
        ],
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
            size: 60,
            color: AppTheme.primaryColor,
          ),
          const SizedBox(height: 16),
          Text(
            'Start the conversation',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          Text(
            'Send a message to break the ice!',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppTheme.textSecondary,
                ),
          ),
        ],
      ),
    );
  }

  bool _shouldShowDateSeparator(ChatMessage current, ChatMessage? previous) {
    if (previous == null) return true;

    final currentDate = DateTime(
      current.sentAt.year,
      current.sentAt.month,
      current.sentAt.day,
    );
    final previousDate = DateTime(
      previous.sentAt.year,
      previous.sentAt.month,
      previous.sentAt.day,
    );

    return currentDate != previousDate;
  }

  Widget _buildDateSeparator(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final messageDate = DateTime(date.year, date.month, date.day);

    String dateText;
    if (messageDate == today) {
      dateText = 'Today';
    } else if (messageDate == today.subtract(const Duration(days: 1))) {
      dateText = 'Yesterday';
    } else {
      dateText = '${date.day}/${date.month}/${date.year}';
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Center(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(
            color: AppTheme.extraLightGray,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            dateText,
            style: const TextStyle(
              fontSize: 12,
              color: AppTheme.textSecondary,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMessageBubble(ChatMessage message) {
    // TODO: Get current user ID to determine if message is from self
    final isMe = message.senderId == 1; // Replace with actual user ID check

    if (message.isDeleted) {
      return _buildDeletedMessageBubble(isMe);
    }

    return GestureDetector(
      onLongPress: () {
        _showMessageOptions(message, isMe);
      },
      child: Align(
        alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
        child: Container(
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          constraints: BoxConstraints(
            maxWidth: MediaQuery.of(context).size.width * 0.75,
          ),
          decoration: BoxDecoration(
            color: isMe ? AppTheme.primaryColor : AppTheme.extraLightGray,
            borderRadius: BorderRadius.circular(18),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (message.messageType != ChatMessageType.text)
                _buildAttachmentIndicator(message.messageType),
              Text(
                message.content,
                style: TextStyle(
                  color: isMe ? Colors.white : AppTheme.textPrimary,
                ),
              ),
              const SizedBox(height: 4),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    timeago.format(message.sentAt),
                    style: TextStyle(
                      fontSize: 11,
                      color: isMe
                          ? Colors.white.withOpacity(0.8)
                          : AppTheme.textSecondary,
                    ),
                  ),
                  if (message.isEdited) ...[
                    const SizedBox(width: 4),
                    Text(
                      '• edited',
                      style: TextStyle(
                        fontSize: 11,
                        color: isMe
                            ? Colors.white.withOpacity(0.8)
                            : AppTheme.textSecondary,
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDeletedMessageBubble(bool isMe) {
    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: AppTheme.extraLightGray,
          borderRadius: BorderRadius.circular(18),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: const [
            Icon(Icons.block, size: 14, color: AppTheme.textSecondary),
            SizedBox(width: 6),
            Text(
              'This message was deleted',
              style: TextStyle(
                fontStyle: FontStyle.italic,
                color: AppTheme.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAttachmentIndicator(String messageType) {
    IconData icon;
    String label;

    switch (messageType) {
      case ChatMessageType.image:
        icon = Icons.photo;
        label = 'Photo';
        break;
      case ChatMessageType.video:
        icon = Icons.videocam;
        label = 'Video';
        break;
      case ChatMessageType.audio:
        icon = Icons.mic;
        label = 'Audio';
        break;
      case ChatMessageType.file:
        icon = Icons.insert_drive_file;
        label = 'File';
        break;
      default:
        return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16),
          const SizedBox(width: 4),
          Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  Widget _buildMessageInput() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              _showAttachmentOptions();
            },
          ),
          Expanded(
            child: TextField(
              controller: _messageController,
              decoration: InputDecoration(
                hintText: 'Type a message...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: AppTheme.extraLightGray,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 10,
                ),
              ),
              maxLines: null,
              textCapitalization: TextCapitalization.sentences,
            ),
          ),
          const SizedBox(width: 8),
          _isSending
              ? const SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : IconButton(
                  icon: const Icon(Icons.send, color: AppTheme.primaryColor),
                  onPressed: _sendMessage,
                ),
        ],
      ),
    );
  }

  void _showMessageOptions(ChatMessage message, bool isMe) {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (isMe && !message.isDeleted)
              ListTile(
                leading: const Icon(Icons.edit),
                title: const Text('Edit'),
                onTap: () {
                  Navigator.pop(context);
                  // TODO: Implement edit
                },
              ),
            ListTile(
              leading: const Icon(Icons.copy),
              title: const Text('Copy'),
              onTap: () {
                Navigator.pop(context);
                // TODO: Implement copy to clipboard
              },
            ),
            if (isMe && !message.isDeleted)
              ListTile(
                leading: const Icon(Icons.delete, color: AppTheme.errorColor),
                title: const Text('Delete', style: TextStyle(color: AppTheme.errorColor)),
                onTap: () {
                  Navigator.pop(context);
                  _deleteMessage(message);
                },
              ),
          ],
        ),
      ),
    );
  }

  void _showAttachmentOptions() {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.photo, color: AppTheme.primaryColor),
              title: const Text('Photo'),
              onTap: () {
                Navigator.pop(context);
                // TODO: Pick photo
              },
            ),
            ListTile(
              leading: const Icon(Icons.videocam, color: AppTheme.primaryColor),
              title: const Text('Video'),
              onTap: () {
                Navigator.pop(context);
                // TODO: Pick video
              },
            ),
            ListTile(
              leading: const Icon(Icons.insert_drive_file, color: AppTheme.primaryColor),
              title: const Text('File'),
              onTap: () {
                Navigator.pop(context);
                // TODO: Pick file
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showOptionsMenu() {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.search),
              title: const Text('Search in conversation'),
              onTap: () {
                Navigator.pop(context);
                // TODO: Implement search
              },
            ),
            ListTile(
              leading: const Icon(Icons.notifications_off),
              title: const Text('Mute notifications'),
              onTap: () {
                Navigator.pop(context);
                // TODO: Mute conversation
              },
            ),
            ListTile(
              leading: const Icon(Icons.archive),
              title: const Text('Archive conversation'),
              onTap: () {
                Navigator.pop(context);
                // TODO: Archive conversation
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete, color: AppTheme.errorColor),
              title: const Text('Delete conversation', style: TextStyle(color: AppTheme.errorColor)),
              onTap: () {
                Navigator.pop(context);
                // TODO: Delete conversation
              },
            ),
          ],
        ),
      ),
    );
  }
}
