import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:ft/main.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _ageController;
  late TextEditingController _weightController;
  late TextEditingController _heightController;
  String _selectedActivityLevel = 'Moderately Active';

  final List<String> _activityLevels = [
    'Sedentary',
    'Lightly Active',
    'Moderately Active',
    'Very Active',
    'Extra Active'
  ];

  // Goals – stored locally for this demo
  String _weightGoal = 'Maintain Weight';
  String _activityGoal = '10,000 steps';
  String _workoutGoal = '4 times per week';

  @override
  void initState() {
    super.initState();
    final user = Provider.of<User>(context, listen: false);
    _ageController = TextEditingController(text: user.age.toString());
    _weightController = TextEditingController(text: user.weight.toString());
    _heightController = TextEditingController(text: user.height.toString());
    _selectedActivityLevel = user.activityLevel;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildProfileHeader(),
              const SizedBox(height: 24),
              _buildPersonalInfoSection(),
              const SizedBox(height: 24),
              _buildGoalsSection(),
              const SizedBox(height: 24),
              _buildSettingsSection(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfileHeader() {
    return Center(
      child: Column(
        children: [
          CircleAvatar(
            radius: 50,
            backgroundColor: Theme.of(context).primaryColor,
            child: const Icon(Icons.person, size: 50, color: Colors.white),
          ),
          const SizedBox(height: 16),
          Text(
            'Your Profile',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
        ],
      ),
    );
  }

  Widget _buildPersonalInfoSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Personal Information',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _ageController,
              decoration: const InputDecoration(
                labelText: 'Age',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value == null || value.isEmpty)
                  return 'Please enter your age';
                if (int.tryParse(value) == null)
                  return 'Please enter a valid number';
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _weightController,
              decoration: const InputDecoration(
                labelText: 'Weight (kg)',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value == null || value.isEmpty)
                  return 'Please enter your weight';
                if (double.tryParse(value) == null)
                  return 'Please enter a valid number';
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _heightController,
              decoration: const InputDecoration(
                labelText: 'Height (cm)',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value == null || value.isEmpty)
                  return 'Please enter your height';
                if (double.tryParse(value) == null)
                  return 'Please enter a valid number';
                return null;
              },
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _selectedActivityLevel,
              decoration: const InputDecoration(
                labelText: 'Activity Level',
                border: OutlineInputBorder(),
              ),
              items: _activityLevels.map((level) {
                return DropdownMenuItem(
                  value: level,
                  child: Text(level),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedActivityLevel = value!;
                });
              },
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                if (_formKey.currentState!.validate()) {
                  Provider.of<User>(context, listen: false).updateUserDetails(
                    age: int.parse(_ageController.text),
                    weight: double.parse(_weightController.text),
                    height: double.parse(_heightController.text),
                    activityLevel: _selectedActivityLevel,
                  );
                  ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Profile Updated')));
                }
              },
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGoalsSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Goals',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            _buildGoalTile(
              'Weight Goal',
              _weightGoal,
              Icons.track_changes,
              onTap: _showWeightGoalDialog,
            ),
            _buildGoalTile(
              'Daily Activity Goal',
              _activityGoal,
              Icons.directions_walk,
              onTap: _showActivityGoalDialog,
            ),
            _buildGoalTile(
              'Workout Goal',
              _workoutGoal,
              Icons.fitness_center,
              onTap: _showWorkoutGoalDialog,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGoalTile(String title, String subtitle, IconData icon,
      {required VoidCallback onTap}) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      subtitle: Text(subtitle),
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }

  Widget _buildSettingsSection() {
    final themeNotifier = Provider.of<ThemeNotifier>(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Settings',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            SwitchListTile(
              title: const Text('Daily Reminders'),
              subtitle: const Text('Get notifications for tracking'),
              value: true,
              onChanged: (value) {
                // Implement reminder settings if needed
              },
            ),
            SwitchListTile(
              title: const Text('Dark Mode'),
              subtitle: const Text('Toggle dark/light theme'),
              value: themeNotifier.isDark,
              onChanged: (value) {
                themeNotifier.toggleTheme();
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showWeightGoalDialog() {
    TextEditingController goalController =
        TextEditingController(text: _weightGoal);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Set Weight Goal'),
        content: TextField(
          controller: goalController,
          decoration: const InputDecoration(labelText: 'Weight Goal'),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel')),
          ElevatedButton(
              onPressed: () {
                setState(() {
                  _weightGoal = goalController.text;
                });
                Navigator.pop(context);
              },
              child: const Text('Save')),
        ],
      ),
    );
  }

  void _showActivityGoalDialog() {
    TextEditingController goalController =
        TextEditingController(text: _activityGoal);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Set Daily Activity Goal'),
        content: TextField(
          controller: goalController,
          decoration: const InputDecoration(labelText: 'Activity Goal'),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel')),
          ElevatedButton(
              onPressed: () {
                setState(() {
                  _activityGoal = goalController.text;
                });
                Navigator.pop(context);
              },
              child: const Text('Save')),
        ],
      ),
    );
  }

  void _showWorkoutGoalDialog() {
    TextEditingController goalController =
        TextEditingController(text: _workoutGoal);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Set Workout Goal'),
        content: TextField(
          controller: goalController,
          decoration: const InputDecoration(labelText: 'Workout Goal'),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel')),
          ElevatedButton(
              onPressed: () {
                setState(() {
                  _workoutGoal = goalController.text;
                });
                Navigator.pop(context);
              },
              child: const Text('Save')),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _ageController.dispose();
    _weightController.dispose();
    _heightController.dispose();
    super.dispose();
  }
}
