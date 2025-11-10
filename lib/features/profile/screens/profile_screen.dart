import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/routes/app_router.dart';
import '../../../core/providers/auth_provider.dart';

class ProfileScreen extends ConsumerWidget {
  final int? userId;

  const ProfileScreen({super.key, this.userId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);
    final user = authState.user;
    final isOwnProfile = userId == null;

    if (user == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(isOwnProfile ? 'Profile' : user.displayName ?? 'Profile'),
        actions: isOwnProfile
            ? [
                IconButton(
                  icon: const Icon(Icons.settings),
                  onPressed: () {
                    Navigator.pushNamed(context, AppRouter.settings);
                  },
                ),
              ]
            : null,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Photos
            SizedBox(
              height: 400,
              child: user.photos != null && user.photos!.isNotEmpty
                  ? PageView.builder(
                      itemCount: user.photos!.length,
                      itemBuilder: (context, index) {
                        return CachedNetworkImage(
                          imageUrl: user.photos![index].photoUrl,
                          fit: BoxFit.cover,
                        );
                      },
                    )
                  : Container(
                      color: AppTheme.extraLightGray,
                      child: const Center(
                        child: Icon(Icons.person, size: 100),
                      ),
                    ),
            ),
            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Name and Age
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          '${user.displayName}, ${user.age}',
                          style: Theme.of(context).textTheme.displaySmall,
                        ),
                      ),
                      if (user.isVerified)
                        const Icon(
                          Icons.verified,
                          color: AppTheme.primaryColor,
                          size: 28,
                        ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  // Location
                  if (user.location != null)
                    Row(
                      children: [
                        const Icon(Icons.location_on, size: 16),
                        const SizedBox(width: 4),
                        Text(user.location!),
                      ],
                    ),
                  const SizedBox(height: 16),
                  // Bio
                  if (user.bio != null)
                    Text(
                      user.bio!,
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                  const SizedBox(height: 24),

                  // About Me Section
                  if (_hasAboutMeInfo(user)) ...[
                    _buildSectionTitle(context, 'About Me'),
                    _buildInfoGrid(context, [
                      if (user.gender != null)
                        _InfoItem(
                          icon: Icons.wc,
                          label: 'Gender',
                          value: _formatGender(user.gender!),
                        ),
                      if (user.profile?.height != null)
                        _InfoItem(
                          icon: Icons.height,
                          label: 'Height',
                          value: '${user.profile!.height} cm',
                        ),
                      if (user.profile?.occupation != null)
                        _InfoItem(
                          icon: Icons.work_outline,
                          label: 'Occupation',
                          value: user.profile!.occupation!,
                        ),
                      if (user.profile?.education != null)
                        _InfoItem(
                          icon: Icons.school,
                          label: 'Education',
                          value: _formatEducation(user.profile!.education!),
                        ),
                      if (user.profile?.languagesSpoken != null)
                        _InfoItem(
                          icon: Icons.language,
                          label: 'Languages',
                          value: user.profile!.languagesSpoken!,
                        ),
                    ]),
                    const SizedBox(height: 24),
                  ],

                  // Relationship & Family Section
                  if (_hasRelationshipInfo(user)) ...[
                    _buildSectionTitle(context, 'Relationship & Family'),
                    _buildInfoGrid(context, [
                      if (user.profile?.relationshipGoal != null)
                        _InfoItem(
                          icon: Icons.favorite_outline,
                          label: 'Looking For',
                          value: _formatRelationshipGoal(user.profile!.relationshipGoal!),
                        ),
                      if (user.profile?.hasChildren != null)
                        _InfoItem(
                          icon: Icons.child_care,
                          label: 'Children',
                          value: user.profile!.hasChildren! ? 'Has Children' : 'No Children',
                        ),
                      if (user.profile?.wantsChildren != null)
                        _InfoItem(
                          icon: Icons.family_restroom,
                          label: 'Want Children',
                          value: user.profile!.wantsChildren! ? 'Yes' : 'No',
                        ),
                    ]),
                    const SizedBox(height: 24),
                  ],

                  // Values & Beliefs Section
                  if (_hasValuesInfo(user)) ...[
                    _buildSectionTitle(context, 'Values & Beliefs'),
                    _buildInfoGrid(context, [
                      if (user.profile?.religion != null)
                        _InfoItem(
                          icon: Icons.church,
                          label: 'Religion',
                          value: _formatReligion(user.profile!.religion!),
                        ),
                      if (user.profile?.politicalView != null)
                        _InfoItem(
                          icon: Icons.how_to_vote,
                          label: 'Political Views',
                          value: _formatPoliticalView(user.profile!.politicalView!),
                        ),
                    ]),
                    const SizedBox(height: 24),
                  ],

                  // Lifestyle Section
                  if (_hasLifestyleInfo(user)) ...[
                    _buildSectionTitle(context, 'Lifestyle'),
                    _buildInfoGrid(context, [
                      if (user.profile?.exerciseFrequency != null)
                        _InfoItem(
                          icon: Icons.fitness_center,
                          label: 'Exercise',
                          value: _formatExercise(user.profile!.exerciseFrequency!),
                        ),
                      if (user.profile?.smokingStatus != null)
                        _InfoItem(
                          icon: Icons.smoking_rooms,
                          label: 'Smoking',
                          value: _formatSmoking(user.profile!.smokingStatus!),
                        ),
                      if (user.profile?.drinkingStatus != null)
                        _InfoItem(
                          icon: Icons.local_bar,
                          label: 'Drinking',
                          value: _formatDrinking(user.profile!.drinkingStatus!),
                        ),
                      if (user.profile?.dietaryPreference != null)
                        _InfoItem(
                          icon: Icons.restaurant,
                          label: 'Diet',
                          value: _formatDiet(user.profile!.dietaryPreference!),
                        ),
                      if (user.profile?.petPreference != null)
                        _InfoItem(
                          icon: Icons.pets,
                          label: 'Pets',
                          value: _formatPets(user.profile!.petPreference!),
                        ),
                    ]),
                    const SizedBox(height: 24),
                  ],

                  // Hobbies
                  if (user.hobbies != null && user.hobbies!.isNotEmpty) ...[
                    Text(
                      'Hobbies & Interests',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: user.hobbies!.map((hobby) {
                        return Chip(
                          label: Text(hobby.name),
                          avatar: CircleAvatar(
                            backgroundColor: AppTheme.primaryColor,
                            child: Text(
                              hobby.skillLevel.toString(),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 24),
                  ],
                  // Stats
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildStat(
                        context,
                        'Trust Score',
                        user.trustScore.toString(),
                      ),
                      _buildStat(
                        context,
                        'Profile',
                        '${user.profileCompletionPercentage}%',
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  // Edit Button (for own profile)
                  if (isOwnProfile)
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.pushNamed(context, AppRouter.editProfile);
                        },
                        child: const Text('Edit Profile'),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStat(BuildContext context, String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                color: AppTheme.primaryColor,
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppTheme.textSecondary,
              ),
        ),
      ],
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
      ),
    );
  }

  Widget _buildInfoGrid(BuildContext context, List<_InfoItem> items) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 3,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        return Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppTheme.extraLightGray,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Icon(item.icon, size: 20, color: AppTheme.primaryColor),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      item.label,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppTheme.textSecondary,
                          ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      item.value,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // Section visibility helpers
  bool _hasAboutMeInfo(user) {
    return user.gender != null ||
        user.profile?.height != null ||
        user.profile?.occupation != null ||
        user.profile?.education != null ||
        user.profile?.languagesSpoken != null;
  }

  bool _hasRelationshipInfo(user) {
    return user.profile?.relationshipGoal != null ||
        user.profile?.hasChildren != null ||
        user.profile?.wantsChildren != null;
  }

  bool _hasValuesInfo(user) {
    return user.profile?.religion != null || user.profile?.politicalView != null;
  }

  bool _hasLifestyleInfo(user) {
    return user.profile?.exerciseFrequency != null ||
        user.profile?.smokingStatus != null ||
        user.profile?.drinkingStatus != null ||
        user.profile?.dietaryPreference != null ||
        user.profile?.petPreference != null;
  }

  // Formatting helpers
  String _formatGender(String gender) {
    return gender[0].toUpperCase() + gender.substring(1);
  }

  String _formatEducation(String education) {
    final Map<String, String> labels = {
      'high_school': 'High School',
      'some_college': 'Some College',
      'bachelors': 'Bachelor\'s',
      'masters': 'Master\'s',
      'phd': 'PhD',
    };
    return labels[education] ?? education;
  }

  String _formatRelationshipGoal(String goal) {
    final Map<String, String> labels = {
      'friendship': 'Friendship',
      'casual': 'Casual Dating',
      'relationship': 'Relationship',
      'marriage': 'Marriage',
      'not_sure': 'Not Sure Yet',
    };
    return labels[goal] ?? goal;
  }

  String _formatReligion(String religion) {
    final Map<String, String> labels = {
      'christian': 'Christian',
      'muslim': 'Muslim',
      'jewish': 'Jewish',
      'hindu': 'Hindu',
      'buddhist': 'Buddhist',
      'atheist': 'Atheist',
      'agnostic': 'Agnostic',
      'spiritual': 'Spiritual',
      'other': 'Other',
      'prefer_not_to_say': 'Prefer Not to Say',
    };
    return labels[religion] ?? religion;
  }

  String _formatPoliticalView(String view) {
    final Map<String, String> labels = {
      'very_liberal': 'Very Liberal',
      'liberal': 'Liberal',
      'moderate': 'Moderate',
      'conservative': 'Conservative',
      'very_conservative': 'Very Conservative',
      'apolitical': 'Apolitical',
      'prefer_not_to_say': 'Prefer Not to Say',
    };
    return labels[view] ?? view;
  }

  String _formatExercise(String frequency) {
    return frequency[0].toUpperCase() + frequency.substring(1);
  }

  String _formatSmoking(String status) {
    final Map<String, String> labels = {
      'non_smoker': 'Non-smoker',
      'social': 'Social',
      'regular': 'Regular',
      'trying_to_quit': 'Trying to Quit',
    };
    return labels[status] ?? status;
  }

  String _formatDrinking(String status) {
    return status[0].toUpperCase() + status.substring(1);
  }

  String _formatDiet(String diet) {
    return diet[0].toUpperCase() + diet.substring(1);
  }

  String _formatPets(String preference) {
    final Map<String, String> labels = {
      'have_pets': 'Have Pets',
      'want_pets': 'Want Pets',
      'no_pets': 'No Pets',
      'allergic': 'Allergic',
    };
    return labels[preference] ?? preference;
  }
}

class _InfoItem {
  final IconData icon;
  final String label;
  final String value;

  _InfoItem({
    required this.icon,
    required this.label,
    required this.value,
  });
}
