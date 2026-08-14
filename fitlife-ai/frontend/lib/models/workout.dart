// lib/models/workout.dart

import 'exercise.dart';

class WorkoutExercise {
  final int id;
  final int? serverId;
  final int workoutId;
  final int exerciseId;
  final String? exerciseName;
  final String? muscleGroup;
  final int sets;
  final int reps;
  final double? weightKg;
  final int? restSecs;
  final String? notes;
  final int orderIndex;

  const WorkoutExercise({
    required this.id,
    this.serverId,
    required this.workoutId,
    required this.exerciseId,
    this.exerciseName,
    this.muscleGroup,
    required this.sets,
    required this.reps,
    this.weightKg,
    this.restSecs,
    this.notes,
    this.orderIndex = 0,
  });

  factory WorkoutExercise.fromJson(Map<String, dynamic> json) {
    return WorkoutExercise(
      id:           json['id'] as int,
      workoutId:    json['workout_id'] as int,
      exerciseId:   json['exercise_id'] as int,
      exerciseName: json['exercise_name'] as String?,
      muscleGroup:  json['muscle_group'] as String?,
      sets:         json['sets'] as int,
      reps:         json['reps'] as int,
      weightKg:     (json['weight_kg'] as num?)?.toDouble(),
      restSecs:     json['rest_secs'] as int?,
      notes:        json['notes'] as String?,
      orderIndex:   (json['order_index'] as int?) ?? 0,
    );
  }

  factory WorkoutExercise.fromMap(Map<String, dynamic> map) {
    return WorkoutExercise(
      id:          map['id'] as int,
      serverId:    map['server_id'] as int?,
      workoutId:   map['workout_id'] as int,
      exerciseId:  map['exercise_id'] as int,
      sets:        map['sets'] as int,
      reps:        map['reps'] as int,
      weightKg:    (map['weight_kg'] as num?)?.toDouble(),
      restSecs:    map['rest_secs'] as int?,
      notes:       map['notes'] as String?,
      orderIndex:  (map['order_index'] as int?) ?? 0,
    );
  }

  Map<String, dynamic> toMap() => {
    if (serverId != null) 'server_id': serverId,
    'workout_id':  workoutId,
    'exercise_id': exerciseId,
    'sets':        sets,
    'reps':        reps,
    'weight_kg':   weightKg,
    'rest_secs':   restSecs,
    'notes':       notes,
    'order_index': orderIndex,
    'is_dirty':    1,
  };
}

// ─────────────────────────────────────────────────────────────────
class Workout {
  final int id;
  final int? serverId;
  final int userId;
  final String name;
  final String? description;
  final List<WorkoutExercise> exercises;
  final bool isDirty;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const Workout({
    required this.id,
    this.serverId,
    required this.userId,
    required this.name,
    this.description,
    this.exercises = const [],
    this.isDirty = true,
    this.createdAt,
    this.updatedAt,
  });

  factory Workout.fromJson(Map<String, dynamic> json) {
    return Workout(
      id:          json['id'] as int,
      userId:      json['user_id'] as int,
      name:        json['name'] as String,
      description: json['description'] as String?,
      exercises:   (json['exercises'] as List<dynamic>?)
          ?.map((e) => WorkoutExercise.fromJson(e as Map<String, dynamic>))
          .toList() ?? [],
      createdAt:   json['created_at'] != null ? DateTime.tryParse(json['created_at']) : null,
      updatedAt:   json['updated_at'] != null ? DateTime.tryParse(json['updated_at']) : null,
    );
  }

  factory Workout.fromMap(Map<String, dynamic> map) {
    return Workout(
      id:          map['id'] as int,
      serverId:    map['server_id'] as int?,
      userId:      map['user_id'] as int,
      name:        map['name'] as String,
      description: map['description'] as String?,
      isDirty:     (map['is_dirty'] as int?) == 1,
      createdAt:   map['created_at'] != null ? DateTime.tryParse(map['created_at']) : null,
      updatedAt:   map['updated_at'] != null ? DateTime.tryParse(map['updated_at']) : null,
    );
  }

  Map<String, dynamic> toMap() => {
    if (serverId != null) 'server_id': serverId,
    'user_id':     userId,
    'name':        name,
    'description': description,
    'is_dirty':    isDirty ? 1 : 0,
    'updated_at':  DateTime.now().toIso8601String(),
  };

  Workout copyWith({
    String? name,
    String? description,
    List<WorkoutExercise>? exercises,
    bool? isDirty,
    int? serverId,
  }) {
    return Workout(
      id:          id,
      serverId:    serverId    ?? this.serverId,
      userId:      userId,
      name:        name        ?? this.name,
      description: description ?? this.description,
      exercises:   exercises   ?? this.exercises,
      isDirty:     isDirty     ?? this.isDirty,
      createdAt:   createdAt,
      updatedAt:   updatedAt,
    );
  }

  @override
  String toString() => 'Workout(id: $id, name: $name)';
}
