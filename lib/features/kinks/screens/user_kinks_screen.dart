import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/models/kink_model.dart';
import '../../../core/services/kink_service.dart';
import '../../../core/services/api_service.dart';
import '../../../core/theme/app_theme.dart';
import 'kink_interests_browse_screen.dart';

/// Provider for user's kink interests
final userKinksProvider = FutureProvider<List<UserKinkInterest>>((ref) async {
  final service = ref.watch(kinkServiceProvider);
  return await service.getUserKinkInterests();
});

class UserKinksScreen extends ConsumerWidget {
  const UserKinksScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userKinksAsync = ref.watch(userKinksProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Interests'),
        actions: [
          IconButton(
            icon: const Icon(Icons.help_outline),
            onPressed: () {
              _showHelpDialog(context);
            },
          ),
        ],
      ),
      body: userKinksAsync.when(
        data: (userKinks) {
          if (userKinks.isEmpty) {
            return _buildEmptyState(context);
          }

          // Group by privacy level
          final publicKinks = userKinks
              .where((k) => k.privacyLevel == KinkPrivacyLevel.publicLevel)
              .toList();
          final matchesOnlyKinks = userKinks
              .where((k) => k.privacyLevel == KinkPrivacyLevel.matchesOnly)
              .toList();
          final privateKinks = userKinks
              .where((k) => k.privacyLevel == KinkPrivacyLevel.privateLevel)
              .toList();

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _buildStatsCard(context, userKinks),
              const SizedBox(height: 24),
              if (publicKinks.isNotEmpty) ...[
                _buildSectionHeader(context, 'Public', Icons.public,
                    'Visible to everyone'),
                ...publicKinks.map((uk) => _buildKinkTile(context, ref, uk)),
                const SizedBox(height: 16),
              ],
              if (matchesOnlyKinks.isNotEmpty) ...[
                _buildSectionHeader(context, 'Matches Only', Icons.favorite,
                    'Only visible to your matches'),
                ...matchesOnlyKinks
                    .map((uk) => _buildKinkTile(context, ref, uk)),
                const SizedBox(height: 16),
              ],
              if (privateKinks.isNotEmpty) ...[
                _buildSectionHeader(context, 'Private', Icons.lock,
                    'Hidden from everyone'),
                ...privateKinks.map((uk) => _buildKinkTile(context, ref, uk)),
              ],
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline,
                  size: 48, color: AppTheme.errorColor),
              const SizedBox(height: 16),
              const Text('Error loading your interests'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  ref.invalidate(userKinksProvider);
                },
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const KinkInterestsBrowseScreen(),
            ),
          ).then((_) {
            // Refresh list after returning
            ref.invalidate(userKinksProvider);
          });
        },
        icon: const Icon(Icons.add),
        label: const Text('Add Interest'),
      ),
    );
  }

  static Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
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
              'No interests added yet',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(
              'Add your interests to find better matches and connect with like-minded people',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppTheme.textSecondary,
                  ),
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const KinkInterestsBrowseScreen(),
                  ),
                );
              },
              icon: const Icon(Icons.explore),
              label: const Text('Browse Interests'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  static Widget _buildStatsCard(
      BuildContext context, List<UserKinkInterest> userKinks) {
    final verifiedCount =
        userKinks.where((k) => k.isVerified).length;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildStatItem(
              context,
              Icons.favorite,
              userKinks.length.toString(),
              'Total',
            ),
            Container(width: 1, height: 40, color: AppTheme.lightGray),
            _buildStatItem(
              context,
              Icons.verified,
              verifiedCount.toString(),
              'Verified',
            ),
            Container(width: 1, height: 40, color: AppTheme.lightGray),
            _buildStatItem(
              context,
              Icons.public,
              userKinks
                  .where(
                      (k) => k.privacyLevel == KinkPrivacyLevel.publicLevel)
                  .length
                  .toString(),
              'Public',
            ),
          ],
        ),
      ),
    );
  }

  static Widget _buildStatItem(
      BuildContext context, IconData icon, String value, String label) {
    return Column(
      children: [
        Icon(icon, color: AppTheme.primaryColor),
        const SizedBox(height: 8),
        Text(
          value,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: AppTheme.textSecondary,
          ),
        ),
      ],
    );
  }

  static Widget _buildSectionHeader(
      BuildContext context, String title, IconData icon, String subtitle) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(icon, size: 20, color: AppTheme.primaryColor),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              Text(
                subtitle,
                style: const TextStyle(
                  fontSize: 12,
                  color: AppTheme.textSecondary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  static Widget _buildKinkTile(
      BuildContext context, WidgetRef ref, UserKinkInterest userKink) {
    final kink = userKink.kinkInterest;
    if (kink == null) {
      return const SizedBox.shrink();
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: AppTheme.primaryColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Center(
            child: kink.icon != null
                ? Text(kink.icon!, style: const TextStyle(fontSize: 20))
                : const Icon(Icons.favorite, color: AppTheme.primaryColor),
          ),
        ),
        title: Row(
          children: [
            Expanded(child: Text(kink.name)),
            if (userKink.isVerified)
              const Icon(
                Icons.verified,
                size: 16,
                color: AppTheme.successColor,
              ),
          ],
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (kink.category != null)
              Text(
                kink.category![0].toUpperCase() + kink.category!.substring(1),
                style: const TextStyle(fontSize: 12),
              ),
            const SizedBox(height: 4),
            _buildPrivacyBadge(userKink.privacyLevel),
          ],
        ),
        trailing: PopupMenuButton<String>(
          icon: const Icon(Icons.more_vert),
          onSelected: (value) {
            _handleMenuAction(context, ref, userKink, value);
          },
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'privacy',
              child: Row(
                children: [
                  Icon(Icons.lock_outline, size: 20),
                  SizedBox(width: 12),
                  Text('Change Privacy'),
                ],
              ),
            ),
            if (kink.requiresVerification && !userKink.isVerified)
              const PopupMenuItem(
                value: 'verify',
                child: Row(
                  children: [
                    Icon(Icons.verified, size: 20),
                    SizedBox(width: 12),
                    Text('Verify'),
                  ],
                ),
              ),
            const PopupMenuItem(
              value: 'remove',
              child: Row(
                children: [
                  Icon(Icons.delete, size: 20, color: AppTheme.errorColor),
                  SizedBox(width: 12),
                  Text('Remove', style: TextStyle(color: AppTheme.errorColor)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  static Widget _buildPrivacyBadge(String privacyLevel) {
    IconData icon;
    String label;
    Color color;

    switch (privacyLevel) {
      case KinkPrivacyLevel.publicLevel:
        icon = Icons.public;
        label = 'Public';
        color = AppTheme.successColor;
        break;
      case KinkPrivacyLevel.matchesOnly:
        icon = Icons.favorite;
        label = 'Matches Only';
        color = AppTheme.primaryColor;
        break;
      default:
        icon = Icons.lock;
        label = 'Private';
        color = AppTheme.textSecondary;
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 12, color: color),
        const SizedBox(width: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            color: color,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  static void _handleMenuAction(BuildContext context, WidgetRef ref,
      UserKinkInterest userKink, String action) {
    switch (action) {
      case 'privacy':
        _changePrivacy(context, ref, userKink);
        break;
      case 'verify':
        _verifyInterest(context, ref, userKink);
        break;
      case 'remove':
        _removeInterest(context, ref, userKink);
        break;
    }
  }

  static void _changePrivacy(
      BuildContext context, WidgetRef ref, UserKinkInterest userKink) {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Padding(
              padding: EdgeInsets.all(16),
              child: Text(
                'Change Privacy',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.public, color: AppTheme.successColor),
              title: const Text('Public'),
              subtitle: const Text('Visible to everyone'),
              trailing: userKink.privacyLevel == KinkPrivacyLevel.publicLevel
                  ? const Icon(Icons.check, color: AppTheme.primaryColor)
                  : null,
              onTap: () {
                Navigator.pop(context);
                _updatePrivacy(
                    context, ref, userKink, KinkPrivacyLevel.publicLevel);
              },
            ),
            ListTile(
              leading: const Icon(Icons.favorite, color: AppTheme.primaryColor),
              title: const Text('Matches Only'),
              subtitle: const Text('Only visible to your matches'),
              trailing: userKink.privacyLevel == KinkPrivacyLevel.matchesOnly
                  ? const Icon(Icons.check, color: AppTheme.primaryColor)
                  : null,
              onTap: () {
                Navigator.pop(context);
                _updatePrivacy(
                    context, ref, userKink, KinkPrivacyLevel.matchesOnly);
              },
            ),
            ListTile(
              leading: const Icon(Icons.lock, color: AppTheme.textSecondary),
              title: const Text('Private'),
              subtitle: const Text('Hidden from everyone'),
              trailing: userKink.privacyLevel == KinkPrivacyLevel.privateLevel
                  ? const Icon(Icons.check, color: AppTheme.primaryColor)
                  : null,
              onTap: () {
                Navigator.pop(context);
                _updatePrivacy(
                    context, ref, userKink, KinkPrivacyLevel.privateLevel);
              },
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  static Future<void> _updatePrivacy(BuildContext context, WidgetRef ref,
      UserKinkInterest userKink, String newPrivacy) async {
    try {
      final service = ref.read(kinkServiceProvider);
      await service.updateKinkPrivacy(
        userKinkInterestId: userKink.id,
        privacyLevel: newPrivacy,
      );
      ref.invalidate(userKinksProvider);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Privacy updated')),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to update privacy: $e')),
        );
      }
    }
  }

  static void _verifyInterest(
      BuildContext context, WidgetRef ref, UserKinkInterest userKink) {
    // TODO: Implement verification flow
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Verification coming soon')),
    );
  }

  static void _removeInterest(
      BuildContext context, WidgetRef ref, UserKinkInterest userKink) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Remove Interest'),
        content: Text(
            'Are you sure you want to remove "${userKink.kinkInterest?.name}" from your interests?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Remove',
                style: TextStyle(color: AppTheme.errorColor)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        final service = ref.read(kinkServiceProvider);
        await service.removeKinkInterest(userKink.id);
        ref.invalidate(userKinksProvider);
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Interest removed')),
          );
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to remove interest: $e')),
          );
        }
      }
    }
  }

  static void _showHelpDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Privacy Levels'),
        content: const SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _HelpItem(
                icon: Icons.public,
                title: 'Public',
                description:
                    'Everyone can see this interest on your profile. Great for interests you\'re proud of and want to share.',
                color: AppTheme.successColor,
              ),
              SizedBox(height: 16),
              _HelpItem(
                icon: Icons.favorite,
                title: 'Matches Only',
                description:
                    'Only people you\'ve matched with can see this interest. Good for more personal interests.',
                color: AppTheme.primaryColor,
              ),
              SizedBox(height: 16),
              _HelpItem(
                icon: Icons.lock,
                title: 'Private',
                description:
                    'Nobody can see this interest. Use this for interests you want to keep to yourself but still want recommendations for.',
                color: AppTheme.textSecondary,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Got it'),
          ),
        ],
      ),
    );
  }
}

class _HelpItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;
  final Color color;

  const _HelpItem({
    required this.icon,
    required this.title,
    required this.description,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: color, size: 24),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                description,
                style: const TextStyle(
                  fontSize: 14,
                  color: AppTheme.textSecondary,
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
