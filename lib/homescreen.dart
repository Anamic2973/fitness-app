import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:math';
import 'package:ft/main.dart';
import 'package:ft/food_item.dart';
import 'package:ft/exercise.dart';
import 'package:ft/history_screen.dart';
import 'package:ft/ProfileScrwwn.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<User>(context);
    final themeNotifier = Provider.of<ThemeNotifier>(context);
    return Scaffold(
      appBar: AppBar(
        backgroundColor: themeNotifier.isDark ? color6 : color1,
        title: Text(
          'Dashboard',
          style: GoogleFonts.lexendGiga(
              fontWeight: FontWeight.w700,
              color: themeNotifier.isDark ? color1 : color6),
        ),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => ProfileScreen()),
              );
            },
            icon: const CircleAvatar(
              radius: 16,
              backgroundColor: Colors.white,
              child: Icon(Icons.person, size: 16, color: Colors.black),
            ),
          ),
        ],
      ),
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 0,
            floating: false,
            pinned: true,
            backgroundColor: Colors.transparent,
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  _buildProfileCard(context),
                  const SizedBox(height: 20),
                  _buildSummaryCard(context),
                  const SizedBox(height: 20),
                  _buildProgressChart(context),
                  const SizedBox(height: 20),
                  _buildQuickActions(context),
                  const SizedBox(height: 20),
                  _buildTodaysItems(context),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: _buildBottomNav(context),
    );
  }

  /// A Profile Card on HomeScreen (shows basic user info).
  Widget _buildProfileCard(BuildContext context) {
    final user = Provider.of<User>(context);
    return Card(
      elevation: 6,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Theme.of(context).brightness == Brightness.light
                  ? color5
                  : color1,
              Theme.of(context).brightness == Brightness.light
                  ? color3
                  : color6,
            ],
          ),
          borderRadius: BorderRadius.circular(20),
        ),
        padding: const EdgeInsets.all(30),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "User Data",
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.bold,
                fontSize: 18,
                color: color6,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              "Age: ${user.age}  •  Weight: ${user.weight}kg  •  Height: ${user.height}cm",
              style: GoogleFonts.poppins(
                  fontSize: 14, color: color6.withOpacity(0.8)),
            ),
            const SizedBox(height: 4),
            Text(
              "Activity: ${user.activityLevel}",
              style: GoogleFonts.poppins(
                  fontSize: 14, color: color6.withOpacity(0.8)),
            ),
            const SizedBox(height: 4),
            Text(
              "Maintenance: ${user.maintenanceCalories.round()} cal",
              style: GoogleFonts.poppins(
                  fontSize: 14, color: color6.withOpacity(0.8)),
            ),
          ],
        ),
      ),
    );
  }

  /// Summary Card with a hollow half pie chart.
  Widget _buildSummaryCard(BuildContext context) {
    final user = Provider.of<User>(context);
    final todayRecord = user.currentDayRecord;
    // Calculate net calories = food - exercise (minimum 0)
    final int consumed = todayRecord?.totalCaloriesConsumed ?? 0;
    final int burned = todayRecord?.totalCaloriesBurned ?? 0;
    final int net = max(consumed - burned, consumed > 0 ? 1 : 0);

    final int maintenance = user.maintenanceCalories.round();
    final int remaining = maintenance - net < 0 ? 0 : maintenance - net;

    return Card(
      elevation: 6,
      margin: const EdgeInsets.all(16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Theme.of(context).brightness == Brightness.light
                  ? color3
                  : color6,
              Theme.of(context).brightness == Brightness.light
                  ? color6
                  : color3,
            ],
          ),
          borderRadius: BorderRadius.circular(20),
        ),
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Text(
              'Daily Summary',
              style: GoogleFonts.poppins(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 40),
            _buildHalfPieChart(context, net, maintenance),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildMetric('Net', '$net', Colors.white),
                _buildMetric('Exercise', '$burned', Colors.white),
                _buildMetric('Remaining', '$remaining', Colors.white),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMetric(String label, String value, Color textColor) {
    return Column(
      children: [
        Text(
          value,
          style: GoogleFonts.poppins(
              fontSize: 24, fontWeight: FontWeight.bold, color: textColor),
        ),
        Text(
          label,
          style: GoogleFonts.poppins(
              fontSize: 12, color: textColor.withOpacity(0.8)),
        ),
      ],
    );
  }

  /// Hollow Half Pie Chart showing net progress.
  Widget _buildHalfPieChart(BuildContext context, int net, int maintenance) {
    final double progress = maintenance > 0
        ? max(net / maintenance, 0.05) // Ensure at least 5% progress
        : 0.05;

    final double percentage = (progress * 100).clamp(0.0, 100.0);

    return Padding(
      padding: const EdgeInsets.only(top: 16),
      child: Stack(
        alignment: Alignment.center,
        children: [
          SizedBox(
            height: 160,
            width: 160,
            child: PieChart(
              PieChartData(
                startDegreeOffset: 180,
                centerSpaceRadius: 50,
                sectionsSpace: 4,
                sections: [
                  // Progress section
                  PieChartSectionData(
                    value: progress,
                    color: percentage > 90
                        ? Colors.red
                        : percentage > 75
                            ? Colors.orange
                            : Colors.green,
                    radius: 45,
                    showTitle: false,
                    borderSide: const BorderSide(width: 0),
                  ),
                  // Remainder section
                  PieChartSectionData(
                    value: 1 - progress,
                    color: Colors.grey.withOpacity(0.2),
                    radius: 45,
                    showTitle: false,
                    borderSide: const BorderSide(width: 0),
                  ),
                  // Dummy section for bottom half
                  PieChartSectionData(
                    value: 1,
                    color: Colors.transparent,
                    radius: 0,
                    showTitle: false,
                  ),
                ],
              ),
            ),
          ),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '${percentage.toStringAsFixed(1)}%',
                style: GoogleFonts.poppins(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              Text(
                'of daily goal',
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  color: Colors.white70,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// (Other widgets remain unchanged: _buildProgressChart, _buildQuickActions, _buildTodaysItems, _buildBottomNav, etc.)

  Widget _buildProgressChart(BuildContext context) {
    return Card(
      elevation: 6,
      margin: const EdgeInsets.symmetric(horizontal: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Weekly Progress',
                style: GoogleFonts.poppins(
                    fontSize: 18, fontWeight: FontWeight.bold)),
            SizedBox(
              height: 200,
              child: LineChart(
                LineChartData(
                  gridData: FlGridData(
                      show: true,
                      drawVerticalLine: false,
                      getDrawingHorizontalLine: (value) => FlLine(
                          color: Colors.grey.withOpacity(0.3), strokeWidth: 1)),
                  titlesData: FlTitlesData(
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 40,
                        getTitlesWidget: (value, meta) {
                          return Text(value.toInt().toString(),
                              style: GoogleFonts.poppins(fontSize: 10));
                        },
                      ),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          const weekDays = [
                            'Mon',
                            'Tue',
                            'Wed',
                            'Thu',
                            'Fri',
                            'Sat',
                            'Sun'
                          ];
                          int index = value.toInt();
                          if (index < 0 || index > 6)
                            return const SizedBox.shrink();
                          return Text(weekDays[index],
                              style: GoogleFonts.poppins(fontSize: 10));
                        },
                      ),
                    ),
                  ),
                  borderData: FlBorderData(
                      show: true,
                      border: Border.all(color: Colors.grey.withOpacity(0.3))),
                  minX: 0,
                  maxX: 6,
                  minY: 0,
                  maxY: 3000,
                  lineBarsData: [
                    LineChartBarData(
                      isCurved: true,
                      color: Colors.blueAccent,
                      belowBarData: BarAreaData(
                        show: true,
                        gradient: LinearGradient(
                          colors: [
                            Colors.blueAccent.withOpacity(0.5),
                            Colors.blueAccent.withOpacity(0.1)
                          ],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                        ),
                      ),
                      dotData: FlDotData(show: false),
                      spots: const [
                        FlSpot(0, 2000),
                        FlSpot(1, 2100),
                        FlSpot(2, 1950),
                        FlSpot(3, 2200),
                        FlSpot(4, 2300),
                        FlSpot(5, 1800),
                        FlSpot(6, 2100)
                      ],
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

  Widget _buildQuickActions(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildActionButton(
              context,
              'Add Food',
              Icons.restaurant,
              () => Navigator.push(context,
                  MaterialPageRoute(builder: (_) => const FoodScreen()))),
          _buildActionButton(
              context,
              'Add Exercise',
              Icons.fitness_center,
              () => Navigator.push(context,
                  MaterialPageRoute(builder: (_) => const ExerciseScreen()))),
          _buildActionButton(
              context,
              'History',
              Icons.history,
              () => Navigator.push(context,
                  MaterialPageRoute(builder: (_) => const HistoryScreen()))),
        ],
      ),
    );
  }

  Widget _buildActionButton(BuildContext context, String label, IconData icon,
      VoidCallback onPressed) {
    return Column(
      children: [
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 6,
                  offset: const Offset(0, 3))
            ],
          ),
          child: IconButton(
            onPressed: onPressed,
            icon: Icon(icon, size: 30, color: Theme.of(context).primaryColor),
          ),
        ),
        const SizedBox(height: 6),
        Text(label, style: GoogleFonts.poppins(fontSize: 12)),
      ],
    );
  }

  /// Display Today's Food & Exercise Items with a "Clear All" button.
  Widget _buildTodaysItems(BuildContext context) {
    final user = Provider.of<User>(context);
    final todayRecord = user.currentDayRecord;
    if (todayRecord == null) return const SizedBox.shrink();

    return Card(
      elevation: 6,
      margin: const EdgeInsets.all(16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("Today's Items",
                    style: GoogleFonts.poppins(
                        fontSize: 18, fontWeight: FontWeight.bold)),
                TextButton(
                  onPressed: () => _clearTodayItems(context),
                  child: Text("Clear All",
                      style: GoogleFonts.poppins(
                          color: Theme.of(context).primaryColor)),
                ),
              ],
            ),
            const SizedBox(height: 8),
            if (todayRecord.consumedFood.isNotEmpty) ...[
              Text("Food Items",
                  style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              ...todayRecord.consumedFood.map(
                (food) => ListTile(
                  leading: const Icon(Icons.restaurant),
                  title: Text(food.name, style: GoogleFonts.poppins()),
                  subtitle: Text('${food.calories} cal',
                      style: GoogleFonts.poppins(fontSize: 12)),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete),
                    onPressed: () => user.removeFood(food),
                  ),
                ),
              ),
            ],
            if (todayRecord.consumedFood.isNotEmpty &&
                todayRecord.exercises.isNotEmpty)
              const Divider(),
            if (todayRecord.exercises.isNotEmpty) ...[
              Text("Exercise Items",
                  style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              ...todayRecord.exercises.map(
                (ex) => ListTile(
                  leading: const Icon(Icons.fitness_center),
                  title: Text(ex.exercise.name, style: GoogleFonts.poppins()),
                  subtitle: Text(
                      '${ex.durationHours.toStringAsFixed(1)} hrs, ${ex.totalCaloriesBurned} cal burned',
                      style: GoogleFonts.poppins(fontSize: 12)),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete),
                    onPressed: () => user.removeExercise(ex),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  // Method to clear today's food and exercise items.
  void _clearTodayItems(BuildContext context) {
    final user = Provider.of<User>(context, listen: false);
    final todayRecord = user.currentDayRecord;
    if (todayRecord != null) {
      todayRecord.consumedFood.clear();
      todayRecord.exercises.clear();
      user.notifyListeners();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Today's items cleared.")),
      );
    }
  }

  Widget _buildBottomNav(BuildContext context) {
    return BottomNavigationBar(
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
        BottomNavigationBarItem(icon: Icon(Icons.restaurant), label: 'Food'),
        BottomNavigationBarItem(
            icon: Icon(Icons.fitness_center), label: 'Exercise'),
        BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
      ],
      currentIndex: 0,
      onTap: (index) {
        if (index == 1) {
          Navigator.push(
              context, MaterialPageRoute(builder: (_) => const FoodScreen()));
        } else if (index == 2) {
          Navigator.push(context,
              MaterialPageRoute(builder: (_) => const ExerciseScreen()));
        } else if (index == 3) {
          Navigator.push(context,
              MaterialPageRoute(builder: (_) => const ProfileScreen()));
        }
      },
    );
  }
}
