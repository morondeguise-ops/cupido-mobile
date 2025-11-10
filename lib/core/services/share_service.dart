import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import 'api_service.dart';

class ShareService {
  final ApiService _apiService;

  ShareService(this._apiService);

  /// Share text content
  Future<void> shareText(String text, {String? subject}) async {
    try {
      await Share.share(text, subject: subject);
    } catch (e) {
      debugPrint('Error sharing text: $e');
    }
  }

  /// Share with files
  Future<void> shareFiles(
    List<String> filePaths, {
    String? text,
    String? subject,
  }) async {
    try {
      final files = filePaths.map((path) => XFile(path)).toList();
      await Share.shareXFiles(files, text: text, subject: subject);
    } catch (e) {
      debugPrint('Error sharing files: $e');
    }
  }

  /// Share profile
  Future<void> shareProfile(String userId, String userName) async {
    try {
      final url = 'https://cupido.com/profile/$userId';
      final text = 'Check out $userName\'s profile on Cupido!\n$url';
      await Share.share(text);
    } catch (e) {
      debugPrint('Error sharing profile: $e');
    }
  }

  /// Share post
  Future<void> sharePost(String postId, String description) async {
    try {
      final url = 'https://cupido.com/post/$postId';
      final text = 'Check out this post on Cupido!\n$description\n$url';
      await Share.share(text);
    } catch (e) {
      debugPrint('Error sharing post: $e');
    }
  }

  /// Share event
  Future<void> shareEvent(
    String eventId,
    String title,
    String description,
  ) async {
    try {
      final url = 'https://cupido.com/event/$eventId';
      final text = 'Join "$title" on Cupido!\n$description\n$url';
      await Share.share(text);
    } catch (e) {
      debugPrint('Error sharing event: $e');
    }
  }

  /// Share invitation code
  Future<void> shareInvitationCode(String code) async {
    try {
      final url = 'https://cupido.com/invite?code=$code';
      final text = 'Join me on Cupido! Use my invitation code: $code\n$url';
      await Share.share(text);
    } catch (e) {
      debugPrint('Error sharing invitation code: $e');
    }
  }

  /// Share app download link
  Future<void> shareApp() async {
    try {
      const text = 'Join Cupido - Connect through shared hobbies!\n'
          'iOS: https://apps.apple.com/cupido\n'
          'Android: https://play.google.com/store/apps/cupido';
      await Share.share(text);
    } catch (e) {
      debugPrint('Error sharing app: $e');
    }
  }

  // =====================================================
  // REPORT & BLOCK FEATURES
  // =====================================================

  /// Report a user
  Future<bool> reportUser({
    required String userId,
    required String reason,
    String? description,
  }) async {
    try {
      final response = await _apiService.post(
        '/reports/user',
        data: {
          'reported_user_id': userId,
          'reason': reason,
          'description': description,
        },
      );

      return response.data['success'] == true;
    } catch (e) {
      debugPrint('Error reporting user: $e');
      return false;
    }
  }

  /// Report a post
  Future<bool> reportPost({
    required String postId,
    required String reason,
    String? description,
  }) async {
    try {
      final response = await _apiService.post(
        '/reports/post',
        data: {
          'post_id': postId,
          'reason': reason,
          'description': description,
        },
      );

      return response.data['success'] == true;
    } catch (e) {
      debugPrint('Error reporting post: $e');
      return false;
    }
  }

  /// Report a message
  Future<bool> reportMessage({
    required String messageId,
    required String reason,
    String? description,
  }) async {
    try {
      final response = await _apiService.post(
        '/reports/message',
        data: {
          'message_id': messageId,
          'reason': reason,
          'description': description,
        },
      );

      return response.data['success'] == true;
    } catch (e) {
      debugPrint('Error reporting message: $e');
      return false;
    }
  }

  /// Block a user
  Future<bool> blockUser(String userId) async {
    try {
      final response = await _apiService.post(
        '/blocks',
        data: {
          'blocked_user_id': userId,
        },
      );

      return response.data['success'] == true;
    } catch (e) {
      debugPrint('Error blocking user: $e');
      return false;
    }
  }

  /// Unblock a user
  Future<bool> unblockUser(String userId) async {
    try {
      final response = await _apiService.delete('/blocks/$userId');
      return response.data['success'] == true;
    } catch (e) {
      debugPrint('Error unblocking user: $e');
      return false;
    }
  }

  /// Get blocked users
  Future<List<Map<String, dynamic>>> getBlockedUsers() async {
    try {
      final response = await _apiService.get('/blocks');

      if (response.data['success'] == true) {
        return List<Map<String, dynamic>>.from(response.data['data']);
      }
    } catch (e) {
      debugPrint('Error getting blocked users: $e');
    }
    return [];
  }

  /// Show report dialog
  Future<void> showReportDialog({
    required BuildContext context,
    required String reportType, // 'user', 'post', 'message'
    required String targetId,
    String? targetName,
  }) async {
    final reasons = [
      'Inappropriate content',
      'Harassment or bullying',
      'Spam or scam',
      'Fake profile',
      'Underage user',
      'Other',
    ];

    String? selectedReason;
    String? description;

    await showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text('Report ${reportType == 'user' ? 'User' : 'Content'}'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (targetName != null)
                      Text(
                        'Reporting: $targetName',
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                    const SizedBox(height: 16),
                    const Text('Select a reason:'),
                    const SizedBox(height: 8),
                    ...reasons.map((reason) {
                      return RadioListTile<String>(
                        title: Text(reason),
                        value: reason,
                        groupValue: selectedReason,
                        onChanged: (value) {
                          setState(() {
                            selectedReason = value;
                          });
                        },
                      );
                    }).toList(),
                    const SizedBox(height: 16),
                    TextField(
                      decoration: const InputDecoration(
                        labelText: 'Additional details (optional)',
                        border: OutlineInputBorder(),
                      ),
                      maxLines: 3,
                      onChanged: (value) {
                        description = value;
                      },
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: selectedReason == null
                      ? null
                      : () async {
                          Navigator.pop(context);

                          bool success = false;
                          switch (reportType) {
                            case 'user':
                              success = await reportUser(
                                userId: targetId,
                                reason: selectedReason!,
                                description: description,
                              );
                              break;
                            case 'post':
                              success = await reportPost(
                                postId: targetId,
                                reason: selectedReason!,
                                description: description,
                              );
                              break;
                            case 'message':
                              success = await reportMessage(
                                messageId: targetId,
                                reason: selectedReason!,
                                description: description,
                              );
                              break;
                          }

                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(success
                                    ? 'Report submitted successfully'
                                    : 'Failed to submit report'),
                                backgroundColor: success ? Colors.green : Colors.red,
                              ),
                            );
                          }
                        },
                  child: const Text('Submit Report'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  /// Show block confirmation dialog
  Future<void> showBlockDialog({
    required BuildContext context,
    required String userId,
    required String userName,
  }) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Block User'),
          content: Text('Are you sure you want to block $userName? '
              'You will no longer see their content or receive messages from them.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
              ),
              child: const Text('Block'),
            ),
          ],
        );
      },
    );

    if (confirmed == true) {
      final success = await blockUser(userId);

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(success
                ? 'User blocked successfully'
                : 'Failed to block user'),
            backgroundColor: success ? Colors.green : Colors.red,
          ),
        );
      }
    }
  }
}
