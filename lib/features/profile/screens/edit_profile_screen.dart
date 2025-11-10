import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/providers/auth_provider.dart';

class EditProfileScreen extends ConsumerStatefulWidget {
  const EditProfileScreen({super.key});

  @override
  ConsumerState<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends ConsumerState<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();

  // Text controllers
  final _nameController = TextEditingController();
  final _bioController = TextEditingController();
  final _occupationController = TextEditingController();
  final _languagesController = TextEditingController();

  // Dropdown values
  String? _gender;
  String? _education;
  String? _relationshipGoal;
  String? _religion;
  String? _politicalView;
  String? _smokingStatus;
  String? _drinkingStatus;
  String? _dietaryPreference;
  String? _exerciseFrequency;
  String? _petPreference;

  // Other values
  DateTime? _birthdate;
  int? _height;
  bool? _hasChildren;
  bool? _wantsChildren;

  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _loadCurrentProfile();
  }

  void _loadCurrentProfile() {
    final user = ref.read(authProvider).user;
    if (user != null) {
      _nameController.text = user.displayName ?? '';
      _bioController.text = user.bio ?? '';
      _occupationController.text = user.profile?.occupation ?? '';
      _languagesController.text = user.profile?.languagesSpoken ?? '';

      _gender = user.gender;
      _birthdate = user.birthdate;
      _education = user.profile?.education;
      _relationshipGoal = user.profile?.relationshipGoal;
      _religion = user.profile?.religion;
      _politicalView = user.profile?.politicalView;
      _smokingStatus = user.profile?.smokingStatus;
      _drinkingStatus = user.profile?.drinkingStatus;
      _dietaryPreference = user.profile?.dietaryPreference;
      _exerciseFrequency = user.profile?.exerciseFrequency;
      _petPreference = user.profile?.petPreference;
      _height = user.profile?.height;
      _hasChildren = user.profile?.hasChildren;
      _wantsChildren = user.profile?.wantsChildren;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _bioController.dispose();
    _occupationController.dispose();
    _languagesController.dispose();
    super.dispose();
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isSaving = true;
    });

    // TODO: Save profile via API
    // final profileData = {
    //   'display_name': _nameController.text,
    //   'bio': _bioController.text,
    //   'gender': _gender,
    //   'birthdate': _birthdate?.toIso8601String(),
    //   'occupation': _occupationController.text,
    //   'education': _education,
    //   'relationship_goal': _relationshipGoal,
    //   'religion': _religion,
    //   'political_view': _politicalView,
    //   'smoking_status': _smokingStatus,
    //   'drinking_status': _drinkingStatus,
    //   'dietary_preference': _dietaryPreference,
    //   'exercise_frequency': _exerciseFrequency,
    //   'pet_preference': _petPreference,
    //   'height': _height,
    //   'has_children': _hasChildren,
    //   'wants_children': _wantsChildren,
    //   'languages_spoken': _languagesController.text,
    // };

    setState(() {
      _isSaving = false;
    });

    if (!mounted) return;

    Navigator.pop(context);
  }

  Future<void> _selectBirthdate() async {
    final now = DateTime.now();
    final initialDate = _birthdate ?? DateTime(now.year - 25);

    final date = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(now.year - 100),
      lastDate: DateTime(now.year - 18),
    );

    if (date != null) {
      setState(() {
        _birthdate = date;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Profile'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Basic Info Section
              _buildSectionTitle('Basic Information'),
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Display Name',
                  prefixIcon: Icon(Icons.person),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _bioController,
                decoration: const InputDecoration(
                  labelText: 'Bio',
                  hintText: 'Tell us about yourself',
                  prefixIcon: Icon(Icons.info_outline),
                ),
                maxLines: 4,
                maxLength: 500,
              ),
              const SizedBox(height: 16),
              InkWell(
                onTap: _selectBirthdate,
                child: InputDecorator(
                  decoration: const InputDecoration(
                    labelText: 'Birthday',
                    prefixIcon: Icon(Icons.cake),
                  ),
                  child: Text(
                    _birthdate != null
                        ? '${_birthdate!.day}/${_birthdate!.month}/${_birthdate!.year}'
                        : 'Select your birthday',
                    style: TextStyle(
                      color: _birthdate != null ? null : AppTheme.textSecondary,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _gender,
                decoration: const InputDecoration(
                  labelText: 'Gender',
                  prefixIcon: Icon(Icons.wc),
                ),
                items: const [
                  DropdownMenuItem(value: 'male', child: Text('Male')),
                  DropdownMenuItem(value: 'female', child: Text('Female')),
                  DropdownMenuItem(value: 'other', child: Text('Other')),
                ],
                onChanged: (value) => setState(() => _gender = value),
              ),

              const SizedBox(height: 32),

              // Relationship & Family Section
              _buildSectionTitle('Relationship & Family'),
              DropdownButtonFormField<String>(
                value: _relationshipGoal,
                decoration: const InputDecoration(
                  labelText: 'Looking For',
                  prefixIcon: Icon(Icons.favorite_outline),
                ),
                items: const [
                  DropdownMenuItem(value: 'friendship', child: Text('Friendship')),
                  DropdownMenuItem(value: 'casual', child: Text('Casual Dating')),
                  DropdownMenuItem(value: 'relationship', child: Text('Relationship')),
                  DropdownMenuItem(value: 'marriage', child: Text('Marriage')),
                  DropdownMenuItem(value: 'not_sure', child: Text('Not Sure Yet')),
                ],
                onChanged: (value) => setState(() => _relationshipGoal = value),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: CheckboxListTile(
                      title: const Text('Have Children'),
                      value: _hasChildren ?? false,
                      onChanged: (value) => setState(() => _hasChildren = value),
                      controlAffinity: ListTileControlAffinity.leading,
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                  Expanded(
                    child: CheckboxListTile(
                      title: const Text('Want Children'),
                      value: _wantsChildren ?? false,
                      onChanged: (value) => setState(() => _wantsChildren = value),
                      controlAffinity: ListTileControlAffinity.leading,
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 32),

              // Background & Education Section
              _buildSectionTitle('Background & Education'),
              TextFormField(
                controller: _occupationController,
                decoration: const InputDecoration(
                  labelText: 'Occupation',
                  hintText: 'e.g., Software Engineer',
                  prefixIcon: Icon(Icons.work_outline),
                ),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _education,
                decoration: const InputDecoration(
                  labelText: 'Education Level',
                  prefixIcon: Icon(Icons.school),
                ),
                items: const [
                  DropdownMenuItem(value: 'high_school', child: Text('High School')),
                  DropdownMenuItem(value: 'some_college', child: Text('Some College')),
                  DropdownMenuItem(value: 'bachelors', child: Text('Bachelor\'s Degree')),
                  DropdownMenuItem(value: 'masters', child: Text('Master\'s Degree')),
                  DropdownMenuItem(value: 'phd', child: Text('PhD')),
                ],
                onChanged: (value) => setState(() => _education = value),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _languagesController,
                decoration: const InputDecoration(
                  labelText: 'Languages Spoken',
                  hintText: 'e.g., English, Spanish, French',
                  prefixIcon: Icon(Icons.language),
                ),
              ),

              const SizedBox(height: 32),

              // Values & Beliefs Section
              _buildSectionTitle('Values & Beliefs'),
              DropdownButtonFormField<String>(
                value: _religion,
                decoration: const InputDecoration(
                  labelText: 'Religion',
                  prefixIcon: Icon(Icons.church),
                ),
                items: const [
                  DropdownMenuItem(value: 'christian', child: Text('Christian')),
                  DropdownMenuItem(value: 'muslim', child: Text('Muslim')),
                  DropdownMenuItem(value: 'jewish', child: Text('Jewish')),
                  DropdownMenuItem(value: 'hindu', child: Text('Hindu')),
                  DropdownMenuItem(value: 'buddhist', child: Text('Buddhist')),
                  DropdownMenuItem(value: 'atheist', child: Text('Atheist')),
                  DropdownMenuItem(value: 'agnostic', child: Text('Agnostic')),
                  DropdownMenuItem(value: 'spiritual', child: Text('Spiritual')),
                  DropdownMenuItem(value: 'other', child: Text('Other')),
                  DropdownMenuItem(value: 'prefer_not_to_say', child: Text('Prefer Not to Say')),
                ],
                onChanged: (value) => setState(() => _religion = value),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _politicalView,
                decoration: const InputDecoration(
                  labelText: 'Political Views',
                  prefixIcon: Icon(Icons.how_to_vote),
                ),
                items: const [
                  DropdownMenuItem(value: 'very_liberal', child: Text('Very Liberal')),
                  DropdownMenuItem(value: 'liberal', child: Text('Liberal')),
                  DropdownMenuItem(value: 'moderate', child: Text('Moderate')),
                  DropdownMenuItem(value: 'conservative', child: Text('Conservative')),
                  DropdownMenuItem(value: 'very_conservative', child: Text('Very Conservative')),
                  DropdownMenuItem(value: 'apolitical', child: Text('Apolitical')),
                  DropdownMenuItem(value: 'prefer_not_to_say', child: Text('Prefer Not to Say')),
                ],
                onChanged: (value) => setState(() => _politicalView = value),
              ),

              const SizedBox(height: 32),

              // Lifestyle Section
              _buildSectionTitle('Lifestyle'),
              DropdownButtonFormField<int>(
                value: _height,
                decoration: const InputDecoration(
                  labelText: 'Height (cm)',
                  prefixIcon: Icon(Icons.height),
                ),
                items: List.generate(
                  100,
                  (index) {
                    final height = 140 + index;
                    return DropdownMenuItem(
                      value: height,
                      child: Text('$height cm'),
                    );
                  },
                ),
                onChanged: (value) => setState(() => _height = value),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _exerciseFrequency,
                decoration: const InputDecoration(
                  labelText: 'Exercise Frequency',
                  prefixIcon: Icon(Icons.fitness_center),
                ),
                items: const [
                  DropdownMenuItem(value: 'never', child: Text('Never')),
                  DropdownMenuItem(value: 'rarely', child: Text('Rarely')),
                  DropdownMenuItem(value: 'sometimes', child: Text('Sometimes')),
                  DropdownMenuItem(value: 'often', child: Text('Often')),
                  DropdownMenuItem(value: 'daily', child: Text('Daily')),
                ],
                onChanged: (value) => setState(() => _exerciseFrequency = value),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _smokingStatus,
                decoration: const InputDecoration(
                  labelText: 'Smoking',
                  prefixIcon: Icon(Icons.smoking_rooms),
                ),
                items: const [
                  DropdownMenuItem(value: 'non_smoker', child: Text('Non-smoker')),
                  DropdownMenuItem(value: 'social', child: Text('Social Smoker')),
                  DropdownMenuItem(value: 'regular', child: Text('Regular Smoker')),
                  DropdownMenuItem(value: 'trying_to_quit', child: Text('Trying to Quit')),
                ],
                onChanged: (value) => setState(() => _smokingStatus = value),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _drinkingStatus,
                decoration: const InputDecoration(
                  labelText: 'Drinking',
                  prefixIcon: Icon(Icons.local_bar),
                ),
                items: const [
                  DropdownMenuItem(value: 'never', child: Text('Never')),
                  DropdownMenuItem(value: 'socially', child: Text('Socially')),
                  DropdownMenuItem(value: 'regularly', child: Text('Regularly')),
                ],
                onChanged: (value) => setState(() => _drinkingStatus = value),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _dietaryPreference,
                decoration: const InputDecoration(
                  labelText: 'Diet',
                  prefixIcon: Icon(Icons.restaurant),
                ),
                items: const [
                  DropdownMenuItem(value: 'omnivore', child: Text('Omnivore')),
                  DropdownMenuItem(value: 'vegetarian', child: Text('Vegetarian')),
                  DropdownMenuItem(value: 'vegan', child: Text('Vegan')),
                  DropdownMenuItem(value: 'pescatarian', child: Text('Pescatarian')),
                  DropdownMenuItem(value: 'halal', child: Text('Halal')),
                  DropdownMenuItem(value: 'kosher', child: Text('Kosher')),
                ],
                onChanged: (value) => setState(() => _dietaryPreference = value),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _petPreference,
                decoration: const InputDecoration(
                  labelText: 'Pets',
                  prefixIcon: Icon(Icons.pets),
                ),
                items: const [
                  DropdownMenuItem(value: 'have_pets', child: Text('Have Pets')),
                  DropdownMenuItem(value: 'want_pets', child: Text('Want Pets')),
                  DropdownMenuItem(value: 'no_pets', child: Text('No Pets')),
                  DropdownMenuItem(value: 'allergic', child: Text('Allergic to Pets')),
                ],
                onChanged: (value) => setState(() => _petPreference = value),
              ),

              const SizedBox(height: 32),

              // Save Button
              ElevatedButton(
                onPressed: _isSaving ? null : _saveProfile,
                child: _isSaving
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Text('Save Changes'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
      ),
    );
  }
}
