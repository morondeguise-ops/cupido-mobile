import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/models/kink_model.dart';
import '../../../core/services/kink_service.dart';
import '../../../core/services/api_service.dart';
import '../../../core/theme/app_theme.dart';
import 'user_kinks_screen.dart';

/// Provider for kink service
final kinkServiceProvider = Provider<KinkService>((ref) {
  return KinkService(ApiService());
});

/// Provider for kink interests
final kinkInterestsProvider = FutureProvider<List<KinkInterest>>((ref) async {
  final service = ref.watch(kinkServiceProvider);
  return await service.getKinkInterests(isActive: true);
});

/// Provider for kink categories
final kinkCategoriesProvider = FutureProvider<List<String>>((ref) async {
  final service = ref.watch(kinkServiceProvider);
  return await service.getKinkCategories();
});

class KinkInterestsBrowseScreen extends ConsumerStatefulWidget {
  const KinkInterestsBrowseScreen({super.key});

  @override
  ConsumerState<KinkInterestsBrowseScreen> createState() =>
      _KinkInterestsBrowseScreenState();
}

class _KinkInterestsBrowseScreenState
    extends ConsumerState<KinkInterestsBrowseScreen> {
  String? _selectedCategory;
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    final kinkInterestsAsync = ref.watch(kinkInterestsProvider);
    final categoriesAsync = ref.watch(kinkCategoriesProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Browse Interests'),
        actions: [
          IconButton(
            icon: const Icon(Icons.person),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const UserKinksScreen(),
                ),
              );
            },
            tooltip: 'My Interests',
          ),
        ],
      ),
      body: Column(
        children: [
          _buildSearchBar(),
          _buildCategoryFilter(categoriesAsync),
          Expanded(
            child: kinkInterestsAsync.when(
              data: (kinks) {
                final filteredKinks = _filterKinks(kinks);
                if (filteredKinks.isEmpty) {
                  return _buildEmptyState();
                }
                return _buildKinksList(filteredKinks);
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, stack) => Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error_outline,
                        size: 48, color: AppTheme.errorColor),
                    const SizedBox(height: 16),
                    Text('Error loading interests'),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () {
                        ref.invalidate(kinkInterestsProvider);
                      },
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: TextField(
        decoration: InputDecoration(
          hintText: 'Search interests...',
          prefixIcon: const Icon(Icons.search),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          filled: true,
          fillColor: AppTheme.extraLightGray,
        ),
        onChanged: (value) {
          setState(() {
            _searchQuery = value.toLowerCase();
          });
        },
      ),
    );
  }

  Widget _buildCategoryFilter(AsyncValue<List<String>> categoriesAsync) {
    return categoriesAsync.when(
      data: (categories) {
        if (categories.isEmpty) return const SizedBox.shrink();

        return SizedBox(
          height: 50,
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            children: [
              _buildCategoryChip('All', null),
              ...categories.map((category) {
                return _buildCategoryChip(
                  category[0].toUpperCase() + category.substring(1),
                  category,
                );
              }).toList(),
            ],
          ),
        );
      },
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
    );
  }

  Widget _buildCategoryChip(String label, String? category) {
    final isSelected = _selectedCategory == category;

    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: FilterChip(
        label: Text(label),
        selected: isSelected,
        onSelected: (selected) {
          setState(() {
            _selectedCategory = selected ? category : null;
          });
        },
        backgroundColor: AppTheme.extraLightGray,
        selectedColor: AppTheme.primaryColor,
        labelStyle: TextStyle(
          color: isSelected ? Colors.white : AppTheme.textPrimary,
        ),
      ),
    );
  }

  List<KinkInterest> _filterKinks(List<KinkInterest> kinks) {
    var filtered = kinks;

    // Filter by category
    if (_selectedCategory != null) {
      filtered = filtered
          .where((kink) => kink.category == _selectedCategory)
          .toList();
    }

    // Filter by search query
    if (_searchQuery.isNotEmpty) {
      filtered = filtered.where((kink) {
        return kink.name.toLowerCase().contains(_searchQuery) ||
            (kink.description?.toLowerCase().contains(_searchQuery) ?? false);
      }).toList();
    }

    return filtered;
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.search_off,
            size: 80,
            color: AppTheme.lightGray,
          ),
          const SizedBox(height: 16),
          Text(
            'No interests found',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          Text(
            'Try a different search or category',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppTheme.textSecondary,
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildKinksList(List<KinkInterest> kinks) {
    // Group by category
    final groupedKinks = <String, List<KinkInterest>>{};
    for (final kink in kinks) {
      final category = kink.category ?? 'Other';
      groupedKinks.putIfAbsent(category, () => []).add(kink);
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: groupedKinks.length,
      itemBuilder: (context, index) {
        final category = groupedKinks.keys.elementAt(index);
        final categoryKinks = groupedKinks[category]!;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (_selectedCategory == null) ...[
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Text(
                  category[0].toUpperCase() + category.substring(1),
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ),
            ],
            ...categoryKinks.map((kink) => _buildKinkCard(kink)).toList(),
            const SizedBox(height: 16),
          ],
        );
      },
    );
  }

  Widget _buildKinkCard(KinkInterest kink) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () {
          _showKinkDetails(kink);
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              if (kink.icon != null)
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: AppTheme.primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(
                    child: Text(
                      kink.icon!,
                      style: const TextStyle(fontSize: 24),
                    ),
                  ),
                )
              else
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: AppTheme.primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.favorite,
                    color: AppTheme.primaryColor,
                  ),
                ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            kink.name,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ),
                        if (kink.ageRestricted)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: AppTheme.errorColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: const Text(
                              '18+',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: AppTheme.errorColor,
                              ),
                            ),
                          ),
                        if (kink.requiresVerification)
                          const Padding(
                            padding: EdgeInsets.only(left: 4),
                            child: Icon(
                              Icons.verified,
                              size: 16,
                              color: AppTheme.successColor,
                            ),
                          ),
                      ],
                    ),
                    if (kink.description != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        kink.description!,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: AppTheme.textSecondary,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, color: AppTheme.textSecondary),
            ],
          ),
        ),
      ),
    );
  }

  void _showKinkDetails(KinkInterest kink) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.5,
        maxChildSize: 0.9,
        expand: false,
        builder: (context, scrollController) {
          return SingleChildScrollView(
            controller: scrollController,
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    if (kink.icon != null)
                      Container(
                        width: 64,
                        height: 64,
                        decoration: BoxDecoration(
                          color: AppTheme.primaryColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Center(
                          child: Text(
                            kink.icon!,
                            style: const TextStyle(fontSize: 32),
                          ),
                        ),
                      ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            kink.name,
                            style: Theme.of(context)
                                .textTheme
                                .headlineSmall
                                ?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                          if (kink.category != null)
                            Text(
                              kink.category![0].toUpperCase() +
                                  kink.category!.substring(1),
                              style: const TextStyle(
                                color: AppTheme.textSecondary,
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                if (kink.description != null) ...[
                  Text(
                    'About',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    kink.description!,
                    style: const TextStyle(
                      color: AppTheme.textSecondary,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
                if (kink.ageRestricted || kink.requiresVerification) ...[
                  Text(
                    'Requirements',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 8),
                  if (kink.ageRestricted)
                    _buildInfoRow(
                      Icons.warning,
                      'Age Restricted',
                      'Must be 18+ to add this interest',
                      AppTheme.errorColor,
                    ),
                  if (kink.requiresVerification)
                    _buildInfoRow(
                      Icons.verified,
                      'Verification Required',
                      'Account verification needed',
                      AppTheme.successColor,
                    ),
                  const SizedBox(height: 24),
                ],
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pop(context);
                      _addToProfile(kink);
                    },
                    icon: const Icon(Icons.add),
                    label: const Text('Add to My Interests'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.all(16),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildInfoRow(
      IconData icon, String title, String subtitle, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontWeight: FontWeight.w600),
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
          ),
        ],
      ),
    );
  }

  Future<void> _addToProfile(KinkInterest kink) async {
    try {
      final service = ref.read(kinkServiceProvider);
      await service.addKinkInterest(
        kinkInterestId: kink.id,
        privacyLevel: KinkPrivacyLevel.privateLevel,
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${kink.name} added to your interests')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to add interest: $e')),
        );
      }
    }
  }
}
