// lib/routes/app_routes.dart

import 'package:flutter/material.dart';
import '../screens/auth_screen.dart';
import '../screens/main_navigation_screen.dart';
import '../screens/exercises_screen.dart';
import '../screens/calculators_screen.dart';
import '../screens/profile_screen.dart';
import '../screens/food_search_screen.dart';
import '../screens/workout_history_screen.dart';
import '../screens/hiit_timer_screen.dart';
import '../screens/badges_screen.dart';
import '../screens/evolution_report_screen.dart';
import '../screens/weight_projection_screen.dart';
import '../screens/food_comparison_screen.dart';
import '../screens/camera_food_scanner_screen.dart';

class AppRoutes {
  static const String auth = '/auth';
  static const String home = '/home';
  static const String exercises = '/exercises';
  static const String calculators = '/calculators';
  static const String profile = '/profile';
  static const String foodSearch = '/food-search';
  static const String workoutHistory = '/workout-history';
  static const String hiitTimer = '/hiit-timer';
  static const String badges = '/badges';
  static const String evolutionReport = '/evolution-report';
  static const String weightProjection = '/weight-projection';
  static const String foodComparison = '/food-comparison';
  static const String cameraScanner = '/camera-scanner';

  static Map<String, WidgetBuilder> get routes {
    return {
      auth:             (context) => const AuthScreen(),
      home:             (context) => const MainNavigationScreen(),
      exercises:        (context) => const ExercisesScreen(),
      calculators:      (context) => const CalculatorsScreen(),
      profile:          (context) => const ProfileScreen(),
      foodSearch:       (context) => const FoodSearchScreen(),
      workoutHistory:   (context) => const WorkoutHistoryScreen(),
      hiitTimer:        (context) => const HiitTimerScreen(),
      badges:           (context) => const BadgesScreen(),
      evolutionReport:  (context) => const EvolutionReportScreen(),
      weightProjection: (context) => const WeightProjectionScreen(),
      foodComparison:   (context) => const FoodComparisonScreen(),
      cameraScanner:    (context) => const CameraFoodScannerScreen(),
    };
  }
}
