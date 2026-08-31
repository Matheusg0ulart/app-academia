// lib/models/dashboard_summary.dart

class DashboardSummary {
  final String today;
  final String userName;
  final String goal;
  final double? currentWeight;
  final double? heightCm;

  final double consumedCalories;
  final int targetCalories;
  final int remainingCalories;
  final int progressPercentage;

  final double proteinG;
  final int targetProteinG;
  final double carbsG;
  final int targetCarbsG;
  final double fatG;
  final int targetFatG;

  final int workoutsThisWeek;
  final int totalWorkoutsCreated;
  final String? nextWorkoutName;
  final int? nextWorkoutExerciseCount;

  final String aiInsight;

  const DashboardSummary({
    required this.today,
    required this.userName,
    required this.goal,
    this.currentWeight,
    this.heightCm,
    required this.consumedCalories,
    required this.targetCalories,
    required this.remainingCalories,
    required this.progressPercentage,
    required this.proteinG,
    required this.targetProteinG,
    required this.carbsG,
    required this.targetCarbsG,
    required this.fatG,
    required this.targetFatG,
    required this.workoutsThisWeek,
    required this.totalWorkoutsCreated,
    this.nextWorkoutName,
    this.nextWorkoutExerciseCount,
    required this.aiInsight,
  });

  factory DashboardSummary.fromJson(Map<String, dynamic> json) {
    final user = (json['user'] as Map<String, dynamic>?) ?? {};
    final nutrition = (json['nutrition'] as Map<String, dynamic>?) ?? {};
    final workouts = (json['workouts'] as Map<String, dynamic>?) ?? {};
    final nextWorkout = workouts['nextWorkout'] as Map<String, dynamic>?;

    return DashboardSummary(
      today:                     json['today'] as String? ?? '',
      userName:                  user['name'] as String? ?? 'Atleta',
      goal:                      user['goal'] as String? ?? 'hypertrophy',
      currentWeight:             (user['currentWeight'] as num?)?.toDouble(),
      heightCm:                  (user['heightCm'] as num?)?.toDouble(),
      consumedCalories:          (nutrition['consumedCalories'] as num?)?.toDouble() ?? 0.0,
      targetCalories:            (nutrition['targetCalories'] as num?)?.toInt() ?? 2200,
      remainingCalories:         (nutrition['remainingCalories'] as num?)?.toInt() ?? 0,
      progressPercentage:        (nutrition['progressPercentage'] as num?)?.toInt() ?? 0,
      proteinG:                  (nutrition['proteinG'] as num?)?.toDouble() ?? 0.0,
      targetProteinG:            (nutrition['targetProteinG'] as num?)?.toInt() ?? 140,
      carbsG:                    (nutrition['carbsG'] as num?)?.toDouble() ?? 0.0,
      targetCarbsG:              (nutrition['targetCarbsG'] as num?)?.toInt() ?? 250,
      fatG:                      (nutrition['fatG'] as num?)?.toDouble() ?? 0.0,
      targetFatG:                (nutrition['targetFatG'] as num?)?.toInt() ?? 65,
      workoutsThisWeek:          (workouts['thisWeekCount'] as num?)?.toInt() ?? 0,
      totalWorkoutsCreated:      (workouts['totalCreated'] as num?)?.toInt() ?? 0,
      nextWorkoutName:           nextWorkout?['name'] as String?,
      nextWorkoutExerciseCount:  (nextWorkout?['exerciseCount'] as num?)?.toInt(),
      aiInsight:                 json['aiInsight'] as String? ?? 'Foco na consistência!',
    );
  }
}

