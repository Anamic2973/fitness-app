//

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:ft/main.dart';

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<User>(context);
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('History'),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Daily'),
              Tab(text: 'Trends'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildDailyHistory(user),
            _buildTrends(user),
          ],
        ),
      ),
    );
  }

  Widget _buildDailyHistory(User user) {
    return ListView.builder(
      itemCount: user.dailyRecords.length,
      itemBuilder: (context, index) {
        final record = user.dailyRecords[index];
        return Card(
          margin: const EdgeInsets.all(8),
          child: ExpansionTile(
            title: Text(DateFormat('MMM dd, yyyy').format(record.date),
                style: GoogleFonts.poppins()),
            subtitle: Text(
                'Calories: ${record.totalCaloriesConsumed} in, ${record.totalCaloriesBurned} out',
                style: GoogleFonts.poppins(fontSize: 12)),
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Food Log:',
                        style:
                            GoogleFonts.poppins(fontWeight: FontWeight.bold)),
                    ...record.consumedFood.map((food) => ListTile(
                          leading: const Icon(Icons.restaurant),
                          title: Text(food.name, style: GoogleFonts.poppins()),
                          trailing: Text('${food.calories} cal',
                              style: GoogleFonts.poppins(fontSize: 12)),
                        )),
                    const Divider(),
                    Text('Exercise Log:',
                        style:
                            GoogleFonts.poppins(fontWeight: FontWeight.bold)),
                    ...record.exercises.map((ex) => ListTile(
                          leading: const Icon(Icons.fitness_center),
                          title: Text(ex.exercise.name,
                              style: GoogleFonts.poppins()),
                          trailing: Text('${ex.totalCaloriesBurned} cal',
                              style: GoogleFonts.poppins(fontSize: 12)),
                        )),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildTrends(User user) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _buildWeeklyCalorieChart(user),
          const SizedBox(height: 16),
          _buildExerciseChart(user),
        ],
      ),
    );
  }

  Widget _buildWeeklyCalorieChart(User user) {
    final records =
        user.dailyRecords.reversed.take(7).toList().reversed.toList();
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Text('Weekly Calorie Intake',
                style: GoogleFonts.poppins(fontSize: 18)),
            SizedBox(
              height: 200,
              child: BarChart(
                BarChartData(
                  alignment: BarChartAlignment.spaceAround,
                  barTouchData: BarTouchData(enabled: false),
                  titlesData: FlTitlesData(
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          if (value.toInt() < records.length) {
                            return Text(
                                DateFormat('E')
                                    .format(records[value.toInt()].date),
                                style: GoogleFonts.poppins(fontSize: 10));
                          }
                          return const SizedBox.shrink();
                        },
                      ),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: true),
                    ),
                  ),
                  borderData: FlBorderData(show: false),
                  barGroups: List.generate(records.length, (index) {
                    final record = records[index];
                    return BarChartGroupData(
                      x: index,
                      barRods: [
                        BarChartRodData(
                          toY: record.totalCaloriesConsumed.toDouble(),
                          color: Colors.teal,
                          width: 16,
                        )
                      ],
                    );
                  }),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExerciseChart(User user) {
    final records =
        user.dailyRecords.reversed.take(7).toList().reversed.toList();
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Text('Weekly Exercise', style: GoogleFonts.poppins(fontSize: 18)),
            SizedBox(
              height: 200,
              child: BarChart(
                BarChartData(
                  alignment: BarChartAlignment.spaceAround,
                  barTouchData: BarTouchData(enabled: false),
                  titlesData: FlTitlesData(
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          if (value.toInt() < records.length) {
                            return Text(
                                DateFormat('E')
                                    .format(records[value.toInt()].date),
                                style: GoogleFonts.poppins(fontSize: 10));
                          }
                          return const SizedBox.shrink();
                        },
                      ),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: true),
                    ),
                  ),
                  borderData: FlBorderData(show: false),
                  barGroups: List.generate(records.length, (index) {
                    final record = records[index];
                    return BarChartGroupData(
                      x: index,
                      barRods: [
                        BarChartRodData(
                          toY: record.totalCaloriesBurned.toDouble(),
                          color: Colors.deepOrange,
                          width: 16,
                        )
                      ],
                    );
                  }),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
