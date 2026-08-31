// lib/models/nutrition.dart

class NutritionLog {
  final int id;
  final int? serverId;
  final int userId;
  final String mealType;
  final String? description;
  final double caloriesKcal;
  final double proteinG;
  final double carbsG;
  final double fatG;
  final String loggedDate;
  final DateTime? createdAt;

  const NutritionLog({
    required this.id,
    this.serverId,
    required this.userId,
    required this.mealType,
    this.description,
    required this.caloriesKcal,
    required this.proteinG,
    required this.carbsG,
    required this.fatG,
    required this.loggedDate,
    this.createdAt,
  });

  factory NutritionLog.fromJson(Map<String, dynamic> json) {
    return NutritionLog(
      id:           json['id'] as int,
      userId:       (json['user_id'] as int?) ?? 0,
      mealType:     json['meal_type'] as String? ?? 'lunch',
      description:  json['description'] as String?,
      caloriesKcal: (json['calories_kcal'] as num?)?.toDouble() ?? 0.0,
      proteinG:     (json['protein_g'] as num?)?.toDouble() ?? 0.0,
      carbsG:       (json['carbs_g'] as num?)?.toDouble() ?? 0.0,
      fatG:         (json['fat_g'] as num?)?.toDouble() ?? 0.0,
      loggedDate:   json['logged_date'] as String? ?? DateTime.now().toIso8601String().split('T')[0],
      createdAt:    json['created_at'] != null ? DateTime.tryParse(json['created_at']) : null,
    );
  }

  factory NutritionLog.fromMap(Map<String, dynamic> map) {
    return NutritionLog(
      id:           map['id'] as int,
      serverId:     map['server_id'] as int?,
      userId:       (map['user_id'] as int?) ?? 0,
      mealType:     map['meal_type'] as String? ?? 'lunch',
      description:  map['description'] as String?,
      caloriesKcal: (map['calories_kcal'] as num?)?.toDouble() ?? 0.0,
      proteinG:     (map['protein_g'] as num?)?.toDouble() ?? 0.0,
      carbsG:       (map['carbs_g'] as num?)?.toDouble() ?? 0.0,
      fatG:         (map['fat_g'] as num?)?.toDouble() ?? 0.0,
      loggedDate:   map['logged_date'] as String? ?? DateTime.now().toIso8601String().split('T')[0],
    );
  }

  Map<String, dynamic> toMap() => {
    if (serverId != null) 'server_id': serverId,
    'user_id':       userId,
    'meal_type':     mealType,
    'description':   description,
    'calories_kcal': caloriesKcal,
    'protein_g':     proteinG,
    'carbs_g':       carbsG,
    'fat_g':         fatG,
    'logged_date':   loggedDate,
  };

  Map<String, dynamic> toJson() => toMap();

  String get mealTypeLabel {
    switch (mealType) {
      case 'breakfast':
        return 'Café da Manhã';
      case 'morning_snack':
        return 'Lanche da Manhã';
      case 'lunch':
        return 'Almoço';
      case 'afternoon_snack':
        return 'Lanche da Tarde';
      case 'dinner':
        return 'Jantar';
      case 'supper':
        return 'Ceia';
      default:
        return 'Outra Refeição';
    }
  }
}

class DailyNutritionSummary {
  final String date;
  final double totalCalories;
  final double totalProtein;
  final double totalCarbs;
  final double totalFat;
  final int targetCalories;
  final int targetProtein;
  final int targetCarbs;
  final int targetFat;
  final int remainingCalories;
  final int progressPercentage;
  final List<NutritionLog> meals;

  const DailyNutritionSummary({
    required this.date,
    required this.totalCalories,
    required this.totalProtein,
    required this.totalCarbs,
    required this.totalFat,
    required this.targetCalories,
    required this.targetProtein,
    required this.targetCarbs,
    required this.targetFat,
    required this.remainingCalories,
    required this.progressPercentage,
    required this.meals,
  });

  factory DailyNutritionSummary.fromJson(Map<String, dynamic> json) {
    final targets = (json['targets'] as Map<String, dynamic>?) ?? {};
    final mealsList = (json['meals'] as List<dynamic>?) ?? [];

    return DailyNutritionSummary(
      date:               json['date'] as String? ?? '',
      totalCalories:      (json['totalCalories'] as num?)?.toDouble() ?? 0.0,
      totalProtein:       (json['totalProtein'] as num?)?.toDouble() ?? 0.0,
      totalCarbs:         (json['totalCarbs'] as num?)?.toDouble() ?? 0.0,
      totalFat:           (json['totalFat'] as num?)?.toDouble() ?? 0.0,
      targetCalories:     (targets['calories'] as num?)?.toInt() ?? 2200,
      targetProtein:      (targets['protein'] as num?)?.toInt() ?? 140,
      targetCarbs:        (targets['carbs'] as num?)?.toInt() ?? 250,
      targetFat:          (targets['fat'] as num?)?.toInt() ?? 65,
      remainingCalories:  (json['remainingCalories'] as num?)?.toInt() ?? 0,
      progressPercentage: (json['progressPercentage'] as num?)?.toInt() ?? 0,
      meals:              mealsList.map((m) => NutritionLog.fromJson(m as Map<String, dynamic>)).toList(),
    );
  }
}

