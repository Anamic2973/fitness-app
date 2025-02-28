import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:math';
import 'package:ft/main.dart';

class FoodScreen extends StatefulWidget {
  const FoodScreen({super.key});

  @override
  _FoodScreenState createState() => _FoodScreenState();
}

class _FoodScreenState extends State<FoodScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<FoodItem> _filteredFoods = [];

  @override
  void initState() {
    super.initState();
    _filteredFoods = realFoodItems;
    _searchController.addListener(_filterFoods);
  }

  void _filterFoods() {
    setState(() {
      _filteredFoods = realFoodItems
          .where((food) => food.name
              .toLowerCase()
              .contains(_searchController.text.toLowerCase()))
          .toList();
    });
  }

  @override
  void dispose() {
    _searchController.removeListener(_filterFoods);
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add Food')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              decoration: const InputDecoration(
                labelText: 'Search Foods',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _filteredFoods.length,
              itemBuilder: (context, index) => ListTile(
                title: Text(_filteredFoods[index].name),
                subtitle: Text('${_filteredFoods[index].calories} cal'),
                trailing: IconButton(
                  icon: const Icon(Icons.add),
                  onPressed: () {
                    Provider.of<User>(context, listen: false)
                        .addFood(_filteredFoods[index]);
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                        content: Text('Added ${_filteredFoods[index].name}')));
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
