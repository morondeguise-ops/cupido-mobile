import 'package:flutter/material.dart';

import '../../../core/routes/app_router.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/config/app_config.dart';
import '../../../core/models/hobby_model.dart';

class HobbySelectionScreen extends StatefulWidget {
  const HobbySelectionScreen({super.key});

  @override
  State<HobbySelectionScreen> createState() => _HobbySelectionScreenState();
}

class _HobbySelectionScreenState extends State<HobbySelectionScreen> {
  final List<SelectedHobby> _selectedHobbies = [];
  bool _isLoading = true;
  bool _isSaving = false;
  List<Hobby> _allHobbies = [];

  @override
  void initState() {
    super.initState();
    _loadHobbies();
  }

  Future<void> _loadHobbies() async {
    setState(() {
      _isLoading = true;
    });

    // TODO: Load hobbies from API
    // final hobbies = await ref.read(profileServiceProvider).getAllHobbies();

    setState(() {
      // _allHobbies = hobbies;
      _isLoading = false;
    });
  }

  void _toggleHobby(Hobby hobby) {
    setState(() {
      final index = _selectedHobbies.indexWhere((h) => h.hobby.id == hobby.id);
      if (index >= 0) {
        _selectedHobbies.removeAt(index);
      } else if (_selectedHobbies.length < AppConfig.maxHobbies) {
        _selectedHobbies.add(SelectedHobby(hobby: hobby, skillLevel: 3));
      }
    });
  }

  bool _isSelected(Hobby hobby) {
    return _selectedHobbies.any((h) => h.hobby.id == hobby.id);
  }

  Future<void> _saveHobbies() async {
    if (_selectedHobbies.length < AppConfig.minHobbies) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please select at least ${AppConfig.minHobbies} hobbies'),
        ),
      );
      return;
    }

    setState(() {
      _isSaving = true;
    });

    // TODO: Save hobbies to API
    // final hobbiesData = _selectedHobbies.map((h) => h.toJson()).toList();
    // await ref.read(profileServiceProvider).updateHobbies(hobbiesData);

    setState(() {
      _isSaving = false;
    });

    if (!mounted) return;

    Navigator.pushNamedAndRemoveUntil(
      context,
      AppRouter.home,
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Select Hobbies'),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'What are you passionate about?',
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Select ${AppConfig.minHobbies}-${AppConfig.maxHobbies} hobbies (${_selectedHobbies.length} selected)',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppTheme.textSecondary,
                        ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      itemCount: _allHobbies.length,
                      itemBuilder: (context, index) {
                        final hobby = _allHobbies[index];
                        final isSelected = _isSelected(hobby);

                        return CheckboxListTile(
                          value: isSelected,
                          onChanged: (value) => _toggleHobby(hobby),
                          title: Text(hobby.name),
                          subtitle: hobby.description != null
                              ? Text(hobby.description!)
                              : null,
                          secondary: hobby.iconUrl != null
                              ? Image.network(hobby.iconUrl!, width: 40)
                              : const Icon(Icons.interests),
                          activeColor: AppTheme.primaryColor,
                        );
                      },
                    ),
            ),
            Padding(
              padding: const EdgeInsets.all(24),
              child: ElevatedButton(
                onPressed: _isSaving ? null : _saveHobbies,
                child: _isSaving
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Text('Continue'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
