import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:ft/main.dart';

class ExerciseScreen extends StatefulWidget {
  const ExerciseScreen({super.key});

  @override
  _ExerciseScreenState createState() => _ExerciseScreenState();
}

class _ExerciseScreenState extends State<ExerciseScreen> {
  final List<String> _categories = ['All', 'Cardio', 'Strength'];
  String _selectedCategory = 'All';

  @override
  Widget build(BuildContext context) {
    List<Exercise> filteredExercises = exerciseList
        .where((e) =>
            _selectedCategory == 'All' || e.category == _selectedCategory)
        .toList();
    return Scaffold(
      appBar: AppBar(title: const Text('Add Exercise')),
      body: Column(
        children: [
          SizedBox(
            height: 60,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: _categories
                  .map((category) => Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        child: ChoiceChip(
                          label: Text(category),
                          selected: _selectedCategory == category,
                          onSelected: (selected) =>
                              setState(() => _selectedCategory = category),
                        ),
                      ))
                  .toList(),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: filteredExercises.length,
              itemBuilder: (context, index) {
                final exercise = filteredExercises[index];
                return ListTile(
                  title: Text(exercise.name),
                  subtitle: Text('${exercise.caloriesBurnedPerHour} cal/hour'),
                  trailing: IconButton(
                    icon: const Icon(Icons.add),
                    onPressed: () => _showDurationDialog(context, exercise),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _showDurationDialog(BuildContext context, Exercise exercise) {
    TextEditingController controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Add ${exercise.name}'),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(labelText: 'Duration (minutes)'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (controller.text.isNotEmpty) {
                final duration = double.tryParse(controller.text) ?? 0;
                if (duration > 0) {
                  Provider.of<User>(context, listen: false)
                      .addExercise(exercise, duration / 60);
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Added ${exercise.name}')));
                }
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }
}
