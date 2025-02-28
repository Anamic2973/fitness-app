import 'package:firebase_core/firebase_core.dart';
import 'package:ft/Authscreen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:math';
import 'package:ft/homescreen.dart';

/// DATA MODELS

class FoodItem {
  final String name;
  final int calories;
  final double protein;
  final double carbs;
  final double fat;

  FoodItem({
    required this.name,
    required this.calories,
    required this.protein,
    required this.carbs,
    required this.fat,
  });
}

class Exercise {
  final String name;
  final String category;
  final double caloriesBurnedPerHour;

  Exercise({
    required this.name,
    required this.category,
    required this.caloriesBurnedPerHour,
  });
}

class DailyRecord {
  final DateTime date;
  final List<FoodItem> consumedFood;
  final List<ExerciseRecord> exercises;

  DailyRecord({
    required this.date,
    required this.consumedFood,
    required this.exercises,
  });

  int get totalCaloriesConsumed =>
      consumedFood.fold(0, (sum, item) => sum + item.calories);

  int get totalCaloriesBurned =>
      exercises.fold(0, (sum, e) => sum + e.totalCaloriesBurned);
}

class ExerciseRecord {
  final Exercise exercise;
  final double durationHours;

  ExerciseRecord({
    required this.exercise,
    required this.durationHours,
  });

  int get totalCaloriesBurned =>
      (exercise.caloriesBurnedPerHour * durationHours).round();
}

/// USER PROVIDER
class User with ChangeNotifier {
  int age = 25;
  double weight = 70.0;
  double height = 170.0;
  String activityLevel = 'Moderately Active';
  // Default maintenance calories (will be recalculated when profile updates)
  double maintenanceCalories = 2000.0;
  final List<DailyRecord> _dailyRecords = [];

  DailyRecord? get currentDayRecord {
    final today = DateTime.now();
    try {
      return _dailyRecords.firstWhere((record) =>
          record.date.year == today.year &&
          record.date.month == today.month &&
          record.date.day == today.day);
    } catch (e) {
      return null;
    }
  }

  void removeFood(FoodItem food) {
    final todayRecord = _getOrCreateTodayRecord();
    todayRecord.consumedFood.remove(food);
    notifyListeners();
  }

  void removeExercise(ExerciseRecord exercise) {
    final todayRecord = _getOrCreateTodayRecord();
    todayRecord.exercises.remove(exercise);
    notifyListeners();
  }

  List<DailyRecord> get dailyRecords => _dailyRecords;

  /// When profile details are updated, recalc maintenance calories.
  void updateUserDetails({
    required int age,
    required double weight,
    required double height,
    required String activityLevel,
  }) {
    this.age = age;
    this.weight = weight;
    this.height = height;
    this.activityLevel = activityLevel;
    _calculateMaintenanceCalories();
    notifyListeners();
  }

  void _calculateMaintenanceCalories() {
    // Using the Mifflin-St Jeor equation for BMR
    double bmr = 10 * weight + 6.25 * height - 5 * age + 5; // For men
    // For women: BMR = 10 * weight + 6.25 * height - 5 * age - 161

    switch (activityLevel) {
      case 'Sedentary':
        maintenanceCalories = bmr * 1.2; // Little to no exercise
        break;
      case 'Lightly Active':
        maintenanceCalories = bmr * 1.375; // Light exercise 1-3 days/week
        break;
      case 'Moderately Active':
        maintenanceCalories = bmr * 1.55; // Moderate exercise 3-5 days/week
        break;
      case 'Very Active':
        maintenanceCalories = bmr * 1.725; // Heavy exercise 6-7 days/week
        break;
      case 'Extra Active':
        maintenanceCalories = bmr * 1.9; // Very heavy exercise, physical job
        break;
      default:
        maintenanceCalories = bmr * 1.2;
    }
  }

  void addFood(FoodItem food) {
    final todayRecord = _getOrCreateTodayRecord();
    todayRecord.consumedFood.add(food);
    notifyListeners();
  }

  void addExercise(Exercise exercise, double durationHours) {
    final todayRecord = _getOrCreateTodayRecord();
    todayRecord.exercises.add(ExerciseRecord(
      exercise: exercise,
      durationHours: durationHours,
    ));
    notifyListeners();
  }

  DailyRecord _getOrCreateTodayRecord() {
    final today = DateTime.now();
    try {
      final existing = _dailyRecords.firstWhere((record) =>
          record.date.year == today.year &&
          record.date.month == today.month &&
          record.date.day == today.day);
      return existing;
    } catch (e) {
      final newRecord = DailyRecord(
        date: today,
        consumedFood: [],
        exercises: [],
      );
      _dailyRecords.add(newRecord);
      return newRecord;
    }
  }
}

/// THEME PROVIDER
class ThemeNotifier with ChangeNotifier {
  bool _isDark = true;
  bool get isDark => _isDark;
  void toggleTheme() {
    _isDark = !_isDark;
    notifyListeners();
  }
}

/// SAMPLE DATA
final List<FoodItem> realFoodItems = [
  // Fruits
  FoodItem(
      name: 'Apple (Seb)', calories: 95, protein: 0.5, carbs: 25, fat: 0.3),
  FoodItem(
      name: 'Banana (Kela)', calories: 105, protein: 1.3, carbs: 27, fat: 0.4),
  FoodItem(
      name: 'Mango (Aam)', calories: 150, protein: 1.0, carbs: 35, fat: 0.6),
  FoodItem(
      name: 'Orange (Santra)', calories: 62, protein: 1.2, carbs: 15, fat: 0.2),
  FoodItem(
      name: 'Papaya (Papita)', calories: 43, protein: 0.5, carbs: 11, fat: 0.3),

  // Vegetables
  FoodItem(
      name: 'Potato (Aloo)', calories: 77, protein: 2.0, carbs: 17, fat: 0.1),
  FoodItem(
      name: 'Tomato (Tamatar)',
      calories: 18,
      protein: 0.9,
      carbs: 3.9,
      fat: 0.2),
  FoodItem(
      name: 'Onion (Pyaaz)', calories: 40, protein: 1.1, carbs: 9.3, fat: 0.1),
  FoodItem(
      name: 'Spinach (Palak)',
      calories: 23,
      protein: 2.9,
      carbs: 3.6,
      fat: 0.4),
  FoodItem(
      name: 'Brinjal (Baingan)',
      calories: 25,
      protein: 1.0,
      carbs: 6.0,
      fat: 0.2),

  // Grains and Pulses
  FoodItem(
      name: 'Rice (Chawal)', calories: 130, protein: 2.7, carbs: 28, fat: 0.3),
  FoodItem(
      name: 'Wheat (Gehu)', calories: 340, protein: 13, carbs: 72, fat: 2.5),
  FoodItem(
      name: 'Lentils (Dal)', calories: 116, protein: 9, carbs: 20, fat: 0.4),
  FoodItem(
      name: 'Chickpeas (Chana)',
      calories: 164,
      protein: 8.9,
      carbs: 27,
      fat: 2.6),
  FoodItem(
      name: 'Kidney Beans (Rajma)',
      calories: 127,
      protein: 8.7,
      carbs: 22,
      fat: 0.5),

  // Dairy
  FoodItem(name: 'Milk (Doodh)', calories: 42, protein: 3.4, carbs: 5, fat: 1),
  FoodItem(
      name: 'Curd (Dahi)', calories: 98, protein: 11, carbs: 3.4, fat: 4.3),
  FoodItem(name: 'Paneer', calories: 265, protein: 18, carbs: 1.2, fat: 20),
  FoodItem(name: 'Ghee', calories: 112, protein: 0, carbs: 0, fat: 12.7),
  FoodItem(
      name: 'Buttermilk (Chaas)',
      calories: 19,
      protein: 1.0,
      carbs: 2.0,
      fat: 0.6),

  // Snacks
  FoodItem(name: 'Samosa', calories: 262, protein: 4.0, carbs: 31, fat: 13),
  FoodItem(name: 'Pakora', calories: 140, protein: 3.0, carbs: 15, fat: 7),
  FoodItem(name: 'Poha', calories: 250, protein: 5.0, carbs: 50, fat: 4),
  FoodItem(name: 'Upma', calories: 200, protein: 4.5, carbs: 30, fat: 6),
  FoodItem(name: 'Idli', calories: 39, protein: 2.0, carbs: 8, fat: 0.4),

  // Non-Veg
  FoodItem(name: 'Egg (Anda)', calories: 70, protein: 6, carbs: 0.6, fat: 5),
  FoodItem(
      name: 'Chicken Curry', calories: 250, protein: 20, carbs: 10, fat: 15),
  FoodItem(name: 'Fish Curry', calories: 200, protein: 22, carbs: 5, fat: 10),
  FoodItem(name: 'Mutton Curry', calories: 300, protein: 25, carbs: 8, fat: 18),
  FoodItem(
      name: 'Prawns (Jhinga)', calories: 99, protein: 24, carbs: 0.2, fat: 0.3),

  // Sweets
  FoodItem(name: 'Gulab Jamun', calories: 150, protein: 2.0, carbs: 20, fat: 7),
  FoodItem(name: 'Jalebi', calories: 150, protein: 1.0, carbs: 35, fat: 3),
  FoodItem(name: 'Rasgulla', calories: 186, protein: 4.0, carbs: 40, fat: 0.5),
  FoodItem(name: 'Kheer', calories: 200, protein: 5.0, carbs: 30, fat: 6),
  FoodItem(name: 'Ladoo', calories: 150, protein: 3.0, carbs: 20, fat: 6),
];
//----------------------------------------------------------------
final List<Exercise> exerciseList = [
  // Cardio
  Exercise(
      name: 'Running (Daud)', category: 'Cardio', caloriesBurnedPerHour: 600),
  Exercise(
      name: 'Cycling (Cycle Chalana)',
      category: 'Cardio',
      caloriesBurnedPerHour: 500),
  Exercise(
      name: 'Jump Rope (Rassi Koodna)',
      category: 'Cardio',
      caloriesBurnedPerHour: 700),
  Exercise(
      name: 'Brisk Walking (Tez Chalna)',
      category: 'Cardio',
      caloriesBurnedPerHour: 300),
  Exercise(
      name: 'Dancing (Naachna)',
      category: 'Cardio',
      caloriesBurnedPerHour: 400),

  // Strength
  Exercise(
      name: 'Push-ups (Dand)',
      category: 'Strength',
      caloriesBurnedPerHour: 400),
  Exercise(
      name: 'Squats (Baithak)',
      category: 'Strength',
      caloriesBurnedPerHour: 350),
  Exercise(name: 'Plank', category: 'Strength', caloriesBurnedPerHour: 200),
  Exercise(
      name: 'Yoga (Surya Namaskar)',
      category: 'Strength',
      caloriesBurnedPerHour: 250),
  Exercise(
      name: 'Weight Lifting (Wajan Uthana)',
      category: 'Strength',
      caloriesBurnedPerHour: 400),

  // Household Activities
  Exercise(
      name: 'Cleaning (Safai Karna)',
      category: 'Household',
      caloriesBurnedPerHour: 200),
  Exercise(
      name: 'Cooking (Khana Pakana)',
      category: 'Household',
      caloriesBurnedPerHour: 150),
  Exercise(
      name: 'Gardening (Bagwani)',
      category: 'Household',
      caloriesBurnedPerHour: 300),
  Exercise(
      name: 'Washing Clothes (Kapde Dhona)',
      category: 'Household',
      caloriesBurnedPerHour: 250),
  Exercise(
      name: 'Mopping (Pochha Lagana)',
      category: 'Household',
      caloriesBurnedPerHour: 200),

  // Traditional Exercises
  Exercise(name: 'Kabbadi', category: 'Sports', caloriesBurnedPerHour: 600),
  Exercise(name: 'Kho Kho', category: 'Sports', caloriesBurnedPerHour: 500),
  Exercise(name: 'Gilli Danda', category: 'Sports', caloriesBurnedPerHour: 400),
  Exercise(name: 'Lathi Play', category: 'Sports', caloriesBurnedPerHour: 450),
  Exercise(name: 'Mallakhamb', category: 'Sports', caloriesBurnedPerHour: 550),
];
const Color color1 = Color(0xFF051F20); // darkest
const Color color2 = Color(0xFF0B2B26);
const Color color3 = Color(0xFF163632);
const Color color4 = Color(0xFF253F37);
const Color color5 = Color(0xFFBEC69B); // for text or accents
const Color color6 = Color(0xFFDAF1DE);

/// MAIN APP
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
      options: const FirebaseOptions(
    appId: '1:461823819242:ios:20e23b76dbb798c86d8693',
    apiKey: 'AIzaSyC-pJQoSmUTRN3SEuTQ2DqT3cMTkBGYuBQ',
    projectId: 'fitnesstracker-b098d',
    messagingSenderId: '461823819242',
  ));

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => User()),
        ChangeNotifierProvider(create: (_) => ThemeNotifier()),
      ],
      child: const FitnessApp(),
    ),
  );
}

class FitnessApp extends StatelessWidget {
  const FitnessApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeNotifier = Provider.of<ThemeNotifier>(context);
    return MaterialApp(
      title: 'Fitness Tracker',
      debugShowCheckedModeBanner: false,
      theme: themeNotifier.isDark ? _darkTheme() : _lightTheme(),
      home: const AuthScreen(),
    );
  }

  ThemeData _darkTheme() {
    return ThemeData.dark().copyWith(
      scaffoldBackgroundColor: color1,
      cardColor: color2,
      primaryColor: color5,
      appBarTheme: AppBarTheme(
        backgroundColor: color2,
        titleTextStyle: TextStyle(color: color6),
      ),
      textTheme: GoogleFonts.poppinsTextTheme(ThemeData.dark().textTheme).apply(
        bodyColor: color6,
        displayColor: color6,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: color3,
          foregroundColor: color6,
        ),
      ),
    );
  }

  ThemeData _lightTheme() {
    return ThemeData.light().copyWith(
      primaryColor: Colors.teal,
      scaffoldBackgroundColor: Colors.white,
      textTheme: GoogleFonts.poppinsTextTheme(ThemeData.light().textTheme)
          .apply(bodyColor: Colors.black, displayColor: Colors.black),
      appBarTheme: AppBarTheme(backgroundColor: Colors.teal[700]),
    );
  }
}

/// HOME SCREEN
// class HomeScreen extends StatelessWidget {
//   const HomeScreen({super.key});

//   @override
//   Widget build(BuildContext context) {
//     final user = Provider.of<User>(context);
//     final themeNotifier = Provider.of<ThemeNotifier>(context);
//     return Scaffold(
//       appBar: AppBar(
//         backgroundColor: themeNotifier.isDark ? color6 : color1,
//         title: Text(
//           'Dashboard',
//           style: GoogleFonts.lexendGiga(
//               fontWeight: FontWeight.w700,
//               color: themeNotifier.isDark ? color1 : color6),
//         ),
//         actions: [
//           IconButton(
//             onPressed: () {
//               Navigator.push(
//                 context,
//                 MaterialPageRoute(builder: (_) => const ProfileScreen()),
//               );
//             },
//             icon: const CircleAvatar(
//               radius: 16,
//               backgroundColor: Colors.white,
//               child: Icon(Icons.person, size: 16, color: Colors.black),
//             ),
//           ),
//         ],
//       ),
//       body: CustomScrollView(
//         slivers: [
//           SliverAppBar(
//             expandedHeight: 0,
//             floating: false,
//             pinned: true,
//             backgroundColor: Colors.transparent,
//           ),
//           SliverToBoxAdapter(
//             child: Padding(
//               padding: const EdgeInsets.all(16.0),
//               child: Column(
//                 children: [
//                   _buildProfileCard(context),
//                   const SizedBox(height: 20),
//                   _buildSummaryCard(context),
//                   const SizedBox(height: 20),
//                   _buildProgressChart(context),
//                   const SizedBox(height: 20),
//                   _buildQuickActions(context),
//                   const SizedBox(height: 20),
//                   _buildTodaysItems(context),
//                 ],
//               ),
//             ),
//           ),
//         ],
//       ),
//       bottomNavigationBar: _buildBottomNav(context),
//     );
//   }

//   /// A Profile Card on HomeScreen (shows basic user info).
//   Widget _buildProfileCard(BuildContext context) {
//     final user = Provider.of<User>(context);
//     return Card(
//       elevation: 6,
//       margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
//       shape: RoundedRectangleBorder(
//         borderRadius: BorderRadius.circular(20),
//       ),
//       child: Container(
//         decoration: BoxDecoration(
//           gradient: LinearGradient(
//             colors: [
//               Theme.of(context).brightness == Brightness.light
//                   ? color5
//                   : color1,
//               Theme.of(context).brightness == Brightness.light
//                   ? color3
//                   : color6,
//             ],
//           ),
//           borderRadius: BorderRadius.circular(20),
//         ),
//         padding: const EdgeInsets.all(30),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Text(
//               "User Data",
//               style: GoogleFonts.poppins(
//                 fontWeight: FontWeight.bold,
//                 fontSize: 18,
//                 color: color6,
//               ),
//             ),
//             const SizedBox(height: 8),
//             Text(
//               "Age: ${user.age}  •  Weight: ${user.weight}kg  •  Height: ${user.height}cm",
//               style: GoogleFonts.poppins(
//                   fontSize: 14, color: color6.withOpacity(0.8)),
//             ),
//             const SizedBox(height: 4),
//             Text(
//               "Activity: ${user.activityLevel}",
//               style: GoogleFonts.poppins(
//                   fontSize: 14, color: color6.withOpacity(0.8)),
//             ),
//             const SizedBox(height: 4),
//             Text(
//               "Maintenance: ${user.maintenanceCalories.round()} cal",
//               style: GoogleFonts.poppins(
//                   fontSize: 14, color: color6.withOpacity(0.8)),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   /// Summary Card with a hollow half pie chart.
//   Widget _buildSummaryCard(BuildContext context) {
//     final user = Provider.of<User>(context);
//     final todayRecord = user.currentDayRecord;
//     // Calculate net calories = food - exercise (minimum 0)
//     final int consumed = todayRecord?.totalCaloriesConsumed ?? 0;
//     final int burned = todayRecord?.totalCaloriesBurned ?? 0;
//     final int net = max(consumed - burned, consumed > 0 ? 1 : 0);

//     final int maintenance = user.maintenanceCalories.round();
//     final int remaining = maintenance - net < 0 ? 0 : maintenance - net;

//     return Card(
//       elevation: 6,
//       margin: const EdgeInsets.all(16),
//       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
//       child: Container(
//         decoration: BoxDecoration(
//           gradient: LinearGradient(
//             colors: [
//               Theme.of(context).brightness == Brightness.light
//                   ? color3
//                   : color6,
//               Theme.of(context).brightness == Brightness.light
//                   ? color6
//                   : color3,
//             ],
//           ),
//           borderRadius: BorderRadius.circular(20),
//         ),
//         padding: const EdgeInsets.all(20),
//         child: Column(
//           children: [
//             Text(
//               'Daily Summary',
//               style: GoogleFonts.poppins(
//                 fontSize: 20,
//                 fontWeight: FontWeight.bold,
//                 color: Colors.white,
//               ),
//             ),
//             const SizedBox(height: 40),
//             _buildHalfPieChart(context, net, maintenance),
//             const SizedBox(height: 16),
//             Row(
//               mainAxisAlignment: MainAxisAlignment.spaceAround,
//               children: [
//                 _buildMetric('Net', '$net', Colors.white),
//                 _buildMetric('Exercise', '$burned', Colors.white),
//                 _buildMetric('Remaining', '$remaining', Colors.white),
//               ],
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildMetric(String label, String value, Color textColor) {
//     return Column(
//       children: [
//         Text(
//           value,
//           style: GoogleFonts.poppins(
//               fontSize: 24, fontWeight: FontWeight.bold, color: textColor),
//         ),
//         Text(
//           label,
//           style: GoogleFonts.poppins(
//               fontSize: 12, color: textColor.withOpacity(0.8)),
//         ),
//       ],
//     );
//   }

//   /// Hollow Half Pie Chart showing net progress.
//   Widget _buildHalfPieChart(BuildContext context, int net, int maintenance) {
//     final double progress = maintenance > 0
//         ? max(net / maintenance, 0.05) // Ensure at least 5% progress
//         : 0.05;

//     final double percentage = (progress * 100).clamp(0.0, 100.0);

//     return Padding(
//       padding: const EdgeInsets.only(top: 16),
//       child: Stack(
//         alignment: Alignment.center,
//         children: [
//           SizedBox(
//             height: 160,
//             width: 160,
//             child: PieChart(
//               PieChartData(
//                 startDegreeOffset: 180,
//                 centerSpaceRadius: 50,
//                 sectionsSpace: 4,
//                 sections: [
//                   // Progress section
//                   PieChartSectionData(
//                     value: progress,
//                     color: percentage > 90
//                         ? Colors.red
//                         : percentage > 75
//                             ? Colors.orange
//                             : Colors.green,
//                     radius: 45,
//                     showTitle: false,
//                     borderSide: const BorderSide(width: 0),
//                   ),
//                   // Remainder section
//                   PieChartSectionData(
//                     value: 1 - progress,
//                     color: Colors.grey.withOpacity(0.2),
//                     radius: 45,
//                     showTitle: false,
//                     borderSide: const BorderSide(width: 0),
//                   ),
//                   // Dummy section for bottom half
//                   PieChartSectionData(
//                     value: 1,
//                     color: Colors.transparent,
//                     radius: 0,
//                     showTitle: false,
//                   ),
//                 ],
//               ),
//             ),
//           ),
//           Column(
//             mainAxisSize: MainAxisSize.min,
//             children: [
//               Text(
//                 '${percentage.toStringAsFixed(1)}%',
//                 style: GoogleFonts.poppins(
//                   fontSize: 24,
//                   fontWeight: FontWeight.bold,
//                   color: Colors.white,
//                 ),
//               ),
//               Text(
//                 'of daily goal',
//                 style: GoogleFonts.poppins(
//                   fontSize: 12,
//                   color: Colors.white70,
//                 ),
//               ),
//             ],
//           ),
//         ],
//       ),
//     );
//   }

//   /// (Other widgets remain unchanged: _buildProgressChart, _buildQuickActions, _buildTodaysItems, _buildBottomNav, etc.)

//   Widget _buildProgressChart(BuildContext context) {
//     return Card(
//       elevation: 6,
//       margin: const EdgeInsets.symmetric(horizontal: 16),
//       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
//       child: Padding(
//         padding: const EdgeInsets.all(16),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Text('Weekly Progress',
//                 style: GoogleFonts.poppins(
//                     fontSize: 18, fontWeight: FontWeight.bold)),
//             SizedBox(
//               height: 200,
//               child: LineChart(
//                 LineChartData(
//                   gridData: FlGridData(
//                       show: true,
//                       drawVerticalLine: false,
//                       getDrawingHorizontalLine: (value) => FlLine(
//                           color: Colors.grey.withOpacity(0.3), strokeWidth: 1)),
//                   titlesData: FlTitlesData(
//                     leftTitles: AxisTitles(
//                       sideTitles: SideTitles(
//                         showTitles: true,
//                         reservedSize: 40,
//                         getTitlesWidget: (value, meta) {
//                           return Text(value.toInt().toString(),
//                               style: GoogleFonts.poppins(fontSize: 10));
//                         },
//                       ),
//                     ),
//                     bottomTitles: AxisTitles(
//                       sideTitles: SideTitles(
//                         showTitles: true,
//                         getTitlesWidget: (value, meta) {
//                           const weekDays = [
//                             'Mon',
//                             'Tue',
//                             'Wed',
//                             'Thu',
//                             'Fri',
//                             'Sat',
//                             'Sun'
//                           ];
//                           int index = value.toInt();
//                           if (index < 0 || index > 6)
//                             return const SizedBox.shrink();
//                           return Text(weekDays[index],
//                               style: GoogleFonts.poppins(fontSize: 10));
//                         },
//                       ),
//                     ),
//                   ),
//                   borderData: FlBorderData(
//                       show: true,
//                       border: Border.all(color: Colors.grey.withOpacity(0.3))),
//                   minX: 0,
//                   maxX: 6,
//                   minY: 0,
//                   maxY: 3000,
//                   lineBarsData: [
//                     LineChartBarData(
//                       isCurved: true,
//                       color: Colors.blueAccent,
//                       belowBarData: BarAreaData(
//                         show: true,
//                         gradient: LinearGradient(
//                           colors: [
//                             Colors.blueAccent.withOpacity(0.5),
//                             Colors.blueAccent.withOpacity(0.1)
//                           ],
//                           begin: Alignment.topCenter,
//                           end: Alignment.bottomCenter,
//                         ),
//                       ),
//                       dotData: FlDotData(show: false),
//                       spots: const [
//                         FlSpot(0, 2000),
//                         FlSpot(1, 2100),
//                         FlSpot(2, 1950),
//                         FlSpot(3, 2200),
//                         FlSpot(4, 2300),
//                         FlSpot(5, 1800),
//                         FlSpot(6, 2100)
//                       ],
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildQuickActions(BuildContext context) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(horizontal: 16),
//       child: Row(
//         mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//         children: [
//           _buildActionButton(
//               context,
//               'Add Food',
//               Icons.restaurant,
//               () => Navigator.push(context,
//                   MaterialPageRoute(builder: (_) => const FoodScreen()))),
//           _buildActionButton(
//               context,
//               'Add Exercise',
//               Icons.fitness_center,
//               () => Navigator.push(context,
//                   MaterialPageRoute(builder: (_) => const ExerciseScreen()))),
//           _buildActionButton(
//               context,
//               'History',
//               Icons.history,
//               () => Navigator.push(context,
//                   MaterialPageRoute(builder: (_) => const HistoryScreen()))),
//         ],
//       ),
//     );
//   }

//   Widget _buildActionButton(BuildContext context, String label, IconData icon,
//       VoidCallback onPressed) {
//     return Column(
//       children: [
//         Container(
//           decoration: BoxDecoration(
//             color: Colors.white,
//             shape: BoxShape.circle,
//             boxShadow: [
//               BoxShadow(
//                   color: Colors.black.withOpacity(0.1),
//                   blurRadius: 6,
//                   offset: const Offset(0, 3))
//             ],
//           ),
//           child: IconButton(
//             onPressed: onPressed,
//             icon: Icon(icon, size: 30, color: Theme.of(context).primaryColor),
//           ),
//         ),
//         const SizedBox(height: 6),
//         Text(label, style: GoogleFonts.poppins(fontSize: 12)),
//       ],
//     );
//   }

//   /// Display Today's Food & Exercise Items with a "Clear All" button.
//   Widget _buildTodaysItems(BuildContext context) {
//     final user = Provider.of<User>(context);
//     final todayRecord = user.currentDayRecord;
//     if (todayRecord == null) return const SizedBox.shrink();

//     return Card(
//       elevation: 6,
//       margin: const EdgeInsets.all(16),
//       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
//       child: Padding(
//         padding: const EdgeInsets.all(16),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Row(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: [
//                 Text("Today's Items",
//                     style: GoogleFonts.poppins(
//                         fontSize: 18, fontWeight: FontWeight.bold)),
//                 TextButton(
//                   onPressed: () => _clearTodayItems(context),
//                   child: Text("Clear All",
//                       style: GoogleFonts.poppins(
//                           color: Theme.of(context).primaryColor)),
//                 ),
//               ],
//             ),
//             const SizedBox(height: 8),
//             if (todayRecord.consumedFood.isNotEmpty) ...[
//               Text("Food Items",
//                   style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
//               const SizedBox(height: 4),
//               ...todayRecord.consumedFood.map(
//                 (food) => ListTile(
//                   leading: const Icon(Icons.restaurant),
//                   title: Text(food.name, style: GoogleFonts.poppins()),
//                   subtitle: Text('${food.calories} cal',
//                       style: GoogleFonts.poppins(fontSize: 12)),
//                   trailing: IconButton(
//                     icon: const Icon(Icons.delete),
//                     onPressed: () => user.removeFood(food),
//                   ),
//                 ),
//               ),
//             ],
//             if (todayRecord.consumedFood.isNotEmpty &&
//                 todayRecord.exercises.isNotEmpty)
//               const Divider(),
//             if (todayRecord.exercises.isNotEmpty) ...[
//               Text("Exercise Items",
//                   style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
//               const SizedBox(height: 4),
//               ...todayRecord.exercises.map(
//                 (ex) => ListTile(
//                   leading: const Icon(Icons.fitness_center),
//                   title: Text(ex.exercise.name, style: GoogleFonts.poppins()),
//                   subtitle: Text(
//                       '${ex.durationHours.toStringAsFixed(1)} hrs, ${ex.totalCaloriesBurned} cal burned',
//                       style: GoogleFonts.poppins(fontSize: 12)),
//                   trailing: IconButton(
//                     icon: const Icon(Icons.delete),
//                     onPressed: () => user.removeExercise(ex),
//                   ),
//                 ),
//               ),
//             ],
//           ],
//         ),
//       ),
//     );
//   }

//   // Method to clear today's food and exercise items.
//   void _clearTodayItems(BuildContext context) {
//     final user = Provider.of<User>(context, listen: false);
//     final todayRecord = user.currentDayRecord;
//     if (todayRecord != null) {
//       todayRecord.consumedFood.clear();
//       todayRecord.exercises.clear();
//       user.notifyListeners();
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text("Today's items cleared.")),
//       );
//     }
//   }

//   Widget _buildBottomNav(BuildContext context) {
//     return BottomNavigationBar(
//       items: const [
//         BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
//         BottomNavigationBarItem(icon: Icon(Icons.restaurant), label: 'Food'),
//         BottomNavigationBarItem(
//             icon: Icon(Icons.fitness_center), label: 'Exercise'),
//         BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
//       ],
//       currentIndex: 0,
//       onTap: (index) {
//         if (index == 1) {
//           Navigator.push(
//               context, MaterialPageRoute(builder: (_) => const FoodScreen()));
//         } else if (index == 2) {
//           Navigator.push(context,
//               MaterialPageRoute(builder: (_) => const ExerciseScreen()));
//         } else if (index == 3) {
//           Navigator.push(context,
//               MaterialPageRoute(builder: (_) => const ProfileScreen()));
//         }
//       },
//     );
//   }
// }

/// FOOD SCREEN (Updated UI)
// class FoodScreen extends StatefulWidget {
//   const FoodScreen({super.key});

//   @override
//   _FoodScreenState createState() => _FoodScreenState();
// }

// class _FoodScreenState extends State<FoodScreen> {
//   final TextEditingController _searchController = TextEditingController();
//   List<FoodItem> _filteredFoods = [];

//   @override
//   void initState() {
//     super.initState();
//     _filteredFoods = realFoodItems;
//     _searchController.addListener(_filterFoods);
//   }

//   void _filterFoods() {
//     setState(() {
//       _filteredFoods = realFoodItems
//           .where((food) => food.name
//               .toLowerCase()
//               .contains(_searchController.text.toLowerCase()))
//           .toList();
//     });
//   }

//   @override
//   void dispose() {
//     _searchController.removeListener(_filterFoods);
//     _searchController.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: const Text('Add Food')),
//       body: Column(
//         children: [
//           Padding(
//             padding: const EdgeInsets.all(16),
//             child: TextField(
//               controller: _searchController,
//               decoration: const InputDecoration(
//                 labelText: 'Search Foods',
//                 prefixIcon: Icon(Icons.search),
//                 border: OutlineInputBorder(),
//               ),
//             ),
//           ),
//           Expanded(
//             child: ListView.builder(
//               itemCount: _filteredFoods.length,
//               itemBuilder: (context, index) => ListTile(
//                 title: Text(_filteredFoods[index].name),
//                 subtitle: Text('${_filteredFoods[index].calories} cal'),
//                 trailing: IconButton(
//                   icon: const Icon(Icons.add),
//                   onPressed: () {
//                     Provider.of<User>(context, listen: false)
//                         .addFood(_filteredFoods[index]);
//                     ScaffoldMessenger.of(context).showSnackBar(SnackBar(
//                         content: Text('Added ${_filteredFoods[index].name}')));
//                   },
//                 ),
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

/// EXERCISE SCREEN (Updated UI)
// class ExerciseScreen extends StatefulWidget {
//   const ExerciseScreen({super.key});

//   @override
//   _ExerciseScreenState createState() => _ExerciseScreenState();
// }

// class _ExerciseScreenState extends State<ExerciseScreen> {
//   final List<String> _categories = ['All', 'Cardio', 'Strength'];
//   String _selectedCategory = 'All';

//   @override
//   Widget build(BuildContext context) {
//     List<Exercise> filteredExercises = exerciseList
//         .where((e) =>
//             _selectedCategory == 'All' || e.category == _selectedCategory)
//         .toList();
//     return Scaffold(
//       appBar: AppBar(title: const Text('Add Exercise')),
//       body: Column(
//         children: [
//           SizedBox(
//             height: 60,
//             child: ListView(
//               scrollDirection: Axis.horizontal,
//               children: _categories
//                   .map((category) => Padding(
//                         padding: const EdgeInsets.symmetric(horizontal: 8),
//                         child: ChoiceChip(
//                           label: Text(category),
//                           selected: _selectedCategory == category,
//                           onSelected: (selected) =>
//                               setState(() => _selectedCategory = category),
//                         ),
//                       ))
//                   .toList(),
//             ),
//           ),
//           Expanded(
//             child: ListView.builder(
//               itemCount: filteredExercises.length,
//               itemBuilder: (context, index) {
//                 final exercise = filteredExercises[index];
//                 return ListTile(
//                   title: Text(exercise.name),
//                   subtitle: Text('${exercise.caloriesBurnedPerHour} cal/hour'),
//                   trailing: IconButton(
//                     icon: const Icon(Icons.add),
//                     onPressed: () => _showDurationDialog(context, exercise),
//                   ),
//                 );
//               },
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   void _showDurationDialog(BuildContext context, Exercise exercise) {
//     TextEditingController controller = TextEditingController();
//     showDialog(
//       context: context,
//       builder: (context) => AlertDialog(
//         title: Text('Add ${exercise.name}'),
//         content: TextField(
//           controller: controller,
//           keyboardType: TextInputType.number,
//           decoration: const InputDecoration(labelText: 'Duration (minutes)'),
//         ),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.pop(context),
//             child: const Text('Cancel'),
//           ),
//           ElevatedButton(
//             onPressed: () {
//               if (controller.text.isNotEmpty) {
//                 final duration = double.tryParse(controller.text) ?? 0;
//                 if (duration > 0) {
//                   Provider.of<User>(context, listen: false)
//                       .addExercise(exercise, duration / 60);
//                   Navigator.pop(context);
//                   ScaffoldMessenger.of(context).showSnackBar(
//                       SnackBar(content: Text('Added ${exercise.name}')));
//                 }
//               }
//             },
//             child: const Text('Add'),
//           ),
//         ],
//       ),
//     );
//   }
// }

/// HISTORY SCREEN (Updated UI)
// class HistoryScreen extends StatelessWidget {
//   const HistoryScreen({super.key});

//   @override
//   Widget build(BuildContext context) {
//     final user = Provider.of<User>(context);
//     return DefaultTabController(
//       length: 2,
//       child: Scaffold(
//         appBar: AppBar(
//           title: const Text('History'),
//           bottom: const TabBar(
//             tabs: [
//               Tab(text: 'Daily'),
//               Tab(text: 'Trends'),
//             ],
//           ),
//         ),
//         body: TabBarView(
//           children: [
//             _buildDailyHistory(user),
//             _buildTrends(user),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildDailyHistory(User user) {
//     return ListView.builder(
//       itemCount: user.dailyRecords.length,
//       itemBuilder: (context, index) {
//         final record = user.dailyRecords[index];
//         return Card(
//           margin: const EdgeInsets.all(8),
//           child: ExpansionTile(
//             title: Text(DateFormat('MMM dd, yyyy').format(record.date),
//                 style: GoogleFonts.poppins()),
//             subtitle: Text(
//                 'Calories: ${record.totalCaloriesConsumed} in, ${record.totalCaloriesBurned} out',
//                 style: GoogleFonts.poppins(fontSize: 12)),
//             children: [
//               Padding(
//                 padding: const EdgeInsets.all(16),
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Text('Food Log:',
//                         style:
//                             GoogleFonts.poppins(fontWeight: FontWeight.bold)),
//                     ...record.consumedFood.map((food) => ListTile(
//                           leading: const Icon(Icons.restaurant),
//                           title: Text(food.name, style: GoogleFonts.poppins()),
//                           trailing: Text('${food.calories} cal',
//                               style: GoogleFonts.poppins(fontSize: 12)),
//                         )),
//                     const Divider(),
//                     Text('Exercise Log:',
//                         style:
//                             GoogleFonts.poppins(fontWeight: FontWeight.bold)),
//                     ...record.exercises.map((ex) => ListTile(
//                           leading: const Icon(Icons.fitness_center),
//                           title: Text(ex.exercise.name,
//                               style: GoogleFonts.poppins()),
//                           trailing: Text('${ex.totalCaloriesBurned} cal',
//                               style: GoogleFonts.poppins(fontSize: 12)),
//                         )),
//                   ],
//                 ),
//               ),
//             ],
//           ),
//         );
//       },
//     );
//   }

//   Widget _buildTrends(User user) {
//     return SingleChildScrollView(
//       padding: const EdgeInsets.all(16),
//       child: Column(
//         children: [
//           _buildWeeklyCalorieChart(user),
//           const SizedBox(height: 16),
//           _buildExerciseChart(user),
//         ],
//       ),
//     );
//   }

//   Widget _buildWeeklyCalorieChart(User user) {
//     final records =
//         user.dailyRecords.reversed.take(7).toList().reversed.toList();
//     return Card(
//       elevation: 4,
//       child: Padding(
//         padding: const EdgeInsets.all(16),
//         child: Column(
//           children: [
//             Text('Weekly Calorie Intake',
//                 style: GoogleFonts.poppins(fontSize: 18)),
//             SizedBox(
//               height: 200,
//               child: BarChart(
//                 BarChartData(
//                   alignment: BarChartAlignment.spaceAround,
//                   barTouchData: BarTouchData(enabled: false),
//                   titlesData: FlTitlesData(
//                     bottomTitles: AxisTitles(
//                       sideTitles: SideTitles(
//                         showTitles: true,
//                         getTitlesWidget: (value, meta) {
//                           if (value.toInt() < records.length) {
//                             return Text(
//                                 DateFormat('E')
//                                     .format(records[value.toInt()].date),
//                                 style: GoogleFonts.poppins(fontSize: 10));
//                           }
//                           return const SizedBox.shrink();
//                         },
//                       ),
//                     ),
//                     leftTitles: AxisTitles(
//                       sideTitles: SideTitles(showTitles: true),
//                     ),
//                   ),
//                   borderData: FlBorderData(show: false),
//                   barGroups: List.generate(records.length, (index) {
//                     final record = records[index];
//                     return BarChartGroupData(
//                       x: index,
//                       barRods: [
//                         BarChartRodData(
//                           toY: record.totalCaloriesConsumed.toDouble(),
//                           color: Colors.teal,
//                           width: 16,
//                         )
//                       ],
//                     );
//                   }),
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildExerciseChart(User user) {
//     final records =
//         user.dailyRecords.reversed.take(7).toList().reversed.toList();
//     return Card(
//       elevation: 4,
//       child: Padding(
//         padding: const EdgeInsets.all(16),
//         child: Column(
//           children: [
//             Text('Weekly Exercise', style: GoogleFonts.poppins(fontSize: 18)),
//             SizedBox(
//               height: 200,
//               child: BarChart(
//                 BarChartData(
//                   alignment: BarChartAlignment.spaceAround,
//                   barTouchData: BarTouchData(enabled: false),
//                   titlesData: FlTitlesData(
//                     bottomTitles: AxisTitles(
//                       sideTitles: SideTitles(
//                         showTitles: true,
//                         getTitlesWidget: (value, meta) {
//                           if (value.toInt() < records.length) {
//                             return Text(
//                                 DateFormat('E')
//                                     .format(records[value.toInt()].date),
//                                 style: GoogleFonts.poppins(fontSize: 10));
//                           }
//                           return const SizedBox.shrink();
//                         },
//                       ),
//                     ),
//                     leftTitles: AxisTitles(
//                       sideTitles: SideTitles(showTitles: true),
//                     ),
//                   ),
//                   borderData: FlBorderData(show: false),
//                   barGroups: List.generate(records.length, (index) {
//                     final record = records[index];
//                     return BarChartGroupData(
//                       x: index,
//                       barRods: [
//                         BarChartRodData(
//                           toY: record.totalCaloriesBurned.toDouble(),
//                           color: Colors.deepOrange,
//                           width: 16,
//                         )
//                       ],
//                     );
//                   }),
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

/// PROFILE SCREEN
// class ProfileScreen extends StatefulWidget {
//   const ProfileScreen({super.key});

//   @override
//   _ProfileScreenState createState() => _ProfileScreenState();
// }

// class _ProfileScreenState extends State<ProfileScreen> {
//   final _formKey = GlobalKey<FormState>();
//   late TextEditingController _ageController;
//   late TextEditingController _weightController;
//   late TextEditingController _heightController;
//   String _selectedActivityLevel = 'Moderately Active';

//   final List<String> _activityLevels = [
//     'Sedentary',
//     'Lightly Active',
//     'Moderately Active',
//     'Very Active',
//     'Extra Active'
//   ];

//   // Goals – stored locally for this demo
//   String _weightGoal = 'Maintain Weight';
//   String _activityGoal = '10,000 steps';
//   String _workoutGoal = '4 times per week';

//   @override
//   void initState() {
//     super.initState();
//     final user = Provider.of<User>(context, listen: false);
//     _ageController = TextEditingController(text: user.age.toString());
//     _weightController = TextEditingController(text: user.weight.toString());
//     _heightController = TextEditingController(text: user.height.toString());
//     _selectedActivityLevel = user.activityLevel;
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: const Text('Profile')),
//       body: SingleChildScrollView(
//         padding: const EdgeInsets.all(16),
//         child: Form(
//           key: _formKey,
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               _buildProfileHeader(),
//               const SizedBox(height: 24),
//               _buildPersonalInfoSection(),
//               const SizedBox(height: 24),
//               _buildGoalsSection(),
//               const SizedBox(height: 24),
//               _buildSettingsSection(),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildProfileHeader() {
//     return Center(
//       child: Column(
//         children: [
//           CircleAvatar(
//             radius: 50,
//             backgroundColor: Theme.of(context).primaryColor,
//             child: const Icon(Icons.person, size: 50, color: Colors.white),
//           ),
//           const SizedBox(height: 16),
//           Text(
//             'Your Profile',
//             style: Theme.of(context).textTheme.headlineSmall,
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildPersonalInfoSection() {
//     return Card(
//       child: Padding(
//         padding: const EdgeInsets.all(16),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Text(
//               'Personal Information',
//               style: Theme.of(context).textTheme.titleLarge,
//             ),
//             const SizedBox(height: 16),
//             TextFormField(
//               controller: _ageController,
//               decoration: const InputDecoration(
//                 labelText: 'Age',
//                 border: OutlineInputBorder(),
//               ),
//               keyboardType: TextInputType.number,
//               validator: (value) {
//                 if (value == null || value.isEmpty)
//                   return 'Please enter your age';
//                 if (int.tryParse(value) == null)
//                   return 'Please enter a valid number';
//                 return null;
//               },
//             ),
//             const SizedBox(height: 16),
//             TextFormField(
//               controller: _weightController,
//               decoration: const InputDecoration(
//                 labelText: 'Weight (kg)',
//                 border: OutlineInputBorder(),
//               ),
//               keyboardType: TextInputType.number,
//               validator: (value) {
//                 if (value == null || value.isEmpty)
//                   return 'Please enter your weight';
//                 if (double.tryParse(value) == null)
//                   return 'Please enter a valid number';
//                 return null;
//               },
//             ),
//             const SizedBox(height: 16),
//             TextFormField(
//               controller: _heightController,
//               decoration: const InputDecoration(
//                 labelText: 'Height (cm)',
//                 border: OutlineInputBorder(),
//               ),
//               keyboardType: TextInputType.number,
//               validator: (value) {
//                 if (value == null || value.isEmpty)
//                   return 'Please enter your height';
//                 if (double.tryParse(value) == null)
//                   return 'Please enter a valid number';
//                 return null;
//               },
//             ),
//             const SizedBox(height: 16),
//             DropdownButtonFormField<String>(
//               value: _selectedActivityLevel,
//               decoration: const InputDecoration(
//                 labelText: 'Activity Level',
//                 border: OutlineInputBorder(),
//               ),
//               items: _activityLevels.map((level) {
//                 return DropdownMenuItem(
//                   value: level,
//                   child: Text(level),
//                 );
//               }).toList(),
//               onChanged: (value) {
//                 setState(() {
//                   _selectedActivityLevel = value!;
//                 });
//               },
//             ),
//             const SizedBox(height: 16),
//             ElevatedButton(
//               onPressed: () {
//                 if (_formKey.currentState!.validate()) {
//                   Provider.of<User>(context, listen: false).updateUserDetails(
//                     age: int.parse(_ageController.text),
//                     weight: double.parse(_weightController.text),
//                     height: double.parse(_heightController.text),
//                     activityLevel: _selectedActivityLevel,
//                   );
//                   ScaffoldMessenger.of(context).showSnackBar(
//                       const SnackBar(content: Text('Profile Updated')));
//                 }
//               },
//               child: const Text('Save'),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildGoalsSection() {
//     return Card(
//       child: Padding(
//         padding: const EdgeInsets.all(16),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Text(
//               'Goals',
//               style: Theme.of(context).textTheme.titleLarge,
//             ),
//             const SizedBox(height: 16),
//             _buildGoalTile(
//               'Weight Goal',
//               _weightGoal,
//               Icons.track_changes,
//               onTap: _showWeightGoalDialog,
//             ),
//             _buildGoalTile(
//               'Daily Activity Goal',
//               _activityGoal,
//               Icons.directions_walk,
//               onTap: _showActivityGoalDialog,
//             ),
//             _buildGoalTile(
//               'Workout Goal',
//               _workoutGoal,
//               Icons.fitness_center,
//               onTap: _showWorkoutGoalDialog,
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildGoalTile(String title, String subtitle, IconData icon,
//       {required VoidCallback onTap}) {
//     return ListTile(
//       leading: Icon(icon),
//       title: Text(title),
//       subtitle: Text(subtitle),
//       trailing: const Icon(Icons.chevron_right),
//       onTap: onTap,
//     );
//   }

//   Widget _buildSettingsSection() {
//     final themeNotifier = Provider.of<ThemeNotifier>(context);
//     return Card(
//       child: Padding(
//         padding: const EdgeInsets.all(16),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Text(
//               'Settings',
//               style: Theme.of(context).textTheme.titleLarge,
//             ),
//             const SizedBox(height: 16),
//             SwitchListTile(
//               title: const Text('Daily Reminders'),
//               subtitle: const Text('Get notifications for tracking'),
//               value: true,
//               onChanged: (value) {
//                 // Implement reminder settings if needed
//               },
//             ),
//             SwitchListTile(
//               title: const Text('Dark Mode'),
//               subtitle: const Text('Toggle dark/light theme'),
//               value: themeNotifier.isDark,
//               onChanged: (value) {
//                 themeNotifier.toggleTheme();
//               },
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   void _showWeightGoalDialog() {
//     TextEditingController goalController =
//         TextEditingController(text: _weightGoal);
//     showDialog(
//       context: context,
//       builder: (context) => AlertDialog(
//         title: const Text('Set Weight Goal'),
//         content: TextField(
//           controller: goalController,
//           decoration: const InputDecoration(labelText: 'Weight Goal'),
//         ),
//         actions: [
//           TextButton(
//               onPressed: () => Navigator.pop(context),
//               child: const Text('Cancel')),
//           ElevatedButton(
//               onPressed: () {
//                 setState(() {
//                   _weightGoal = goalController.text;
//                 });
//                 Navigator.pop(context);
//               },
//               child: const Text('Save')),
//         ],
//       ),
//     );
//   }

//   void _showActivityGoalDialog() {
//     TextEditingController goalController =
//         TextEditingController(text: _activityGoal);
//     showDialog(
//       context: context,
//       builder: (context) => AlertDialog(
//         title: const Text('Set Daily Activity Goal'),
//         content: TextField(
//           controller: goalController,
//           decoration: const InputDecoration(labelText: 'Activity Goal'),
//         ),
//         actions: [
//           TextButton(
//               onPressed: () => Navigator.pop(context),
//               child: const Text('Cancel')),
//           ElevatedButton(
//               onPressed: () {
//                 setState(() {
//                   _activityGoal = goalController.text;
//                 });
//                 Navigator.pop(context);
//               },
//               child: const Text('Save')),
//         ],
//       ),
//     );
//   }

//   void _showWorkoutGoalDialog() {
//     TextEditingController goalController =
//         TextEditingController(text: _workoutGoal);
//     showDialog(
//       context: context,
//       builder: (context) => AlertDialog(
//         title: const Text('Set Workout Goal'),
//         content: TextField(
//           controller: goalController,
//           decoration: const InputDecoration(labelText: 'Workout Goal'),
//         ),
//         actions: [
//           TextButton(
//               onPressed: () => Navigator.pop(context),
//               child: const Text('Cancel')),
//           ElevatedButton(
//               onPressed: () {
//                 setState(() {
//                   _workoutGoal = goalController.text;
//                 });
//                 Navigator.pop(context);
//               },
//               child: const Text('Save')),
//         ],
//       ),
//     );
//   }

//   @override
//   void dispose() {
//     _ageController.dispose();
//     _weightController.dispose();
//     _heightController.dispose();
//     super.dispose();
//   }
// }
