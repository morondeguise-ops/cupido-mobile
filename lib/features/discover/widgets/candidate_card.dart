import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../../../core/models/discover_model.dart';
import '../../../core/theme/app_theme.dart';

class CandidateCard extends StatelessWidget {
  final DiscoveryCandidate candidate;

  const CandidateCard({
    super.key,
    required this.candidate,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Stack(
          children: [
            // Photo
            if (candidate.photos.isNotEmpty)
              Positioned.fill(
                child: CachedNetworkImage(
                  imageUrl: candidate.photos.first.photoUrl,
                  fit: BoxFit.cover,
                  placeholder: (context, url) => Container(
                    color: AppTheme.extraLightGray,
                    child: const Center(
                      child: CircularProgressIndicator(),
                    ),
                  ),
                  errorWidget: (context, url, error) => Container(
                    color: AppTheme.extraLightGray,
                    child: const Icon(Icons.person, size: 80),
                  ),
                ),
              ),
            // Gradient Overlay
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                height: 250,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.black.withOpacity(0.8),
                    ],
                  ),
                ),
              ),
            ),
            // Info
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            '${candidate.displayName ?? 'Unknown'}, ${candidate.age}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        if (candidate.matchScore > 80)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: AppTheme.successColor,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.star,
                                  color: Colors.white,
                                  size: 16,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  '${candidate.matchScore}%',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    if (candidate.location != null)
                      Row(
                        children: [
                          const Icon(
                            Icons.location_on,
                            color: Colors.white,
                            size: 16,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${candidate.distance?.toStringAsFixed(1) ?? ''} km away',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    const SizedBox(height: 8),
                    // Profile highlights
                    Wrap(
                      spacing: 8,
                      runSpacing: 4,
                      children: [
                        if (candidate.profile?.relationshipGoal != null)
                          _buildProfileTag(
                            Icons.favorite_outline,
                            _formatRelationshipGoal(candidate.profile!.relationshipGoal!),
                          ),
                        if (candidate.profile?.height != null)
                          _buildProfileTag(
                            Icons.height,
                            '${candidate.profile!.height} cm',
                          ),
                        if (candidate.profile?.occupation != null)
                          _buildProfileTag(
                            Icons.work_outline,
                            candidate.profile!.occupation!,
                          ),
                        if (candidate.profile?.hasChildren == true ||
                            candidate.profile?.wantsChildren == true)
                          _buildProfileTag(
                            Icons.family_restroom,
                            _formatChildrenInfo(
                              candidate.profile!.hasChildren,
                              candidate.profile!.wantsChildren,
                            ),
                          ),
                      ],
                    ),
                    if (_hasProfileHighlights(candidate))
                      const SizedBox(height: 8),
                    if (candidate.bio != null)
                      Text(
                        candidate.bio!,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    const SizedBox(height: 12),
                    // Hobbies
                    if (candidate.hobbies.isNotEmpty)
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: candidate.hobbies.take(5).map((hobby) {
                          final isCommon =
                              candidate.commonHobbies.contains(hobby.name);
                          return Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: isCommon
                                  ? AppTheme.primaryColor
                                  : Colors.white.withOpacity(0.3),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              hobby.name,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileTag(IconData icon, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.25),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.white.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: Colors.white),
          const SizedBox(width: 4),
          Text(
            text,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  bool _hasProfileHighlights(DiscoveryCandidate candidate) {
    return candidate.profile?.relationshipGoal != null ||
        candidate.profile?.height != null ||
        candidate.profile?.occupation != null ||
        candidate.profile?.hasChildren != null ||
        candidate.profile?.wantsChildren != null;
  }

  String _formatRelationshipGoal(String goal) {
    final Map<String, String> labels = {
      'friendship': 'Friendship',
      'casual': 'Casual',
      'relationship': 'Relationship',
      'marriage': 'Marriage',
      'not_sure': 'Open',
    };
    return labels[goal] ?? goal;
  }

  String _formatChildrenInfo(bool? hasChildren, bool? wantsChildren) {
    if (hasChildren == true && wantsChildren == true) {
      return 'Has & Wants Kids';
    } else if (hasChildren == true) {
      return 'Has Children';
    } else if (wantsChildren == true) {
      return 'Wants Children';
    }
    return '';
  }
}
