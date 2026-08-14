// lib/models/workout_log.dart

class SetLog {
  final int id;
  final int? serverId;
  final int workoutLogId;
  final int exerciseId;
  final String? exerciseName;
  final int setNumber;
  final int? repsDone;
  final double? weightKg;
  final int? durationSecs;
  final bool isWarmup;
  final String? notes;
  final DateTime loggedAt;

  const SetLog({
    required this.id,
    this.serverId,
    required this.workoutLogId,
    required this.exerciseId,
    this.exerciseName,
    required this.setNumber,
    this.repsDone,
    this.weightKg,
    this.durationSecs,
    this.isWarmup = false,
    this.notes,
    required this.loggedAt,
  });

  factory SetLog.fromJson(Map<String, dynamic> json) {
    return SetLog(
      id:           json['id'] as int,
      workoutLogId: json['workout_log_id'] as int,
      exerciseId:   json['exercise_id'] as int,
      exerciseName: json['exercise_name'] as String?,
      setNumber:    json['set_number'] as int,
      repsDone:     json['reps_done'] as int?,
      weightKg:     (json['weight_kg'] as num?)?.toDouble(),
      durationSecs: json['duration_secs'] as int?,
      isWarmup:     (json['is_warmup'] as bool?) ?? false,
      notes:        json['notes'] as String?,
      loggedAt:     DateTime.parse(json['logged_at'] as String),
    );
  }

  factory SetLog.fromMap(Map<String, dynamic> map) {
    return SetLog(
      id:           map['id'] as int,
      serverId:     map['server_id'] as int?,
      workoutLogId: map['workout_log_id'] as int,
      exerciseId:   map['exercise_id'] as int,
      setNumber:    map['set_number'] as int,
      repsDone:     map['reps_done'] as int?,
      weightKg:     (map['weight_kg'] as num?)?.toDouble(),
      durationSecs: map['duration_secs'] as int?,
      isWarmup:     (map['is_warmup'] as int?) == 1,
      notes:        map['notes'] as String?,
      loggedAt:     map['logged_at'] != null
          ? DateTime.tryParse(map['logged_at']) ?? DateTime.now()
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() => {
    if (serverId != null) 'server_id': serverId,
    'workout_log_id': workoutLogId,
    'exercise_id':    exerciseId,
    'set_number':     setNumber,
    'reps_done':      repsDone,
    'weight_kg':      weightKg,
    'duration_secs':  durationSecs,
    'is_warmup':      isWarmup ? 1 : 0,
    'notes':          notes,
    'logged_at':      loggedAt.toIso8601String(),
    'is_dirty':       1,
  };

  /// Volume total desta série (peso × reps)
  double? get volume {
    if (weightKg == null || repsDone == null) return null;
    return weightKg! * repsDone!;
  }
}

// ─────────────────────────────────────────────────────────────────
class WorkoutLog {
  final int id;
  final int? serverId;
  final int? workoutId;
  final String? workoutName;
  final DateTime startedAt;
  final DateTime? finishedAt;
  final int? durationMin;
  final String? notes;
  final int? rating;
  final List<SetLog> sets;
  final bool isDirty;

  const WorkoutLog({
    required this.id,
    this.serverId,
    this.workoutId,
    this.workoutName,
    required this.startedAt,
    this.finishedAt,
    this.durationMin,
    this.notes,
    this.rating,
    this.sets = const [],
    this.isDirty = true,
  });

  factory WorkoutLog.fromJson(Map<String, dynamic> json) {
    return WorkoutLog(
      id:          json['id'] as int,
      workoutId:   json['workout_id'] as int?,
      workoutName: json['workout_name'] as String?,
      startedAt:   DateTime.parse(json['started_at'] as String),
      finishedAt:  json['finished_at'] != null ? DateTime.tryParse(json['finished_at']) : null,
      durationMin: json['duration_min'] as int?,
      notes:       json['notes'] as String?,
      rating:      json['rating'] as int?,
      sets:        (json['sets'] as List<dynamic>?)
          ?.map((s) => SetLog.fromJson(s as Map<String, dynamic>))
          .toList() ?? [],
    );
  }

  factory WorkoutLog.fromMap(Map<String, dynamic> map) {
    return WorkoutLog(
      id:          map['id'] as int,
      serverId:    map['server_id'] as int?,
      workoutId:   map['workout_id'] as int?,
      startedAt:   map['started_at'] != null
          ? DateTime.tryParse(map['started_at']) ?? DateTime.now()
          : DateTime.now(),
      finishedAt:  map['finished_at'] != null ? DateTime.tryParse(map['finished_at']) : null,
      durationMin: map['duration_min'] as int?,
      notes:       map['notes'] as String?,
      rating:      map['rating'] as int?,
      isDirty:     (map['is_dirty'] as int?) == 1,
    );
  }

  Map<String, dynamic> toMap() => {
    if (serverId != null) 'server_id': serverId,
    if (workoutId != null) 'workout_id': workoutId,
    'started_at':   startedAt.toIso8601String(),
    'finished_at':  finishedAt?.toIso8601String(),
    'duration_min': durationMin,
    'notes':        notes,
    'rating':       rating,
    'is_dirty':     isDirty ? 1 : 0,
  };

  bool get isFinished => finishedAt != null;

  /// Volume total do treino (soma de todas as séries)
  double get totalVolume => sets.fold(0.0, (sum, s) => sum + (s.volume ?? 0.0));

  WorkoutLog copyWith({
    DateTime? finishedAt,
    int? durationMin,
    String? notes,
    int? rating,
    List<SetLog>? sets,
    bool? isDirty,
    int? serverId,
  }) {
    return WorkoutLog(
      id:          id,
      serverId:    serverId    ?? this.serverId,
      workoutId:   workoutId,
      workoutName: workoutName,
      startedAt:   startedAt,
      finishedAt:  finishedAt  ?? this.finishedAt,
      durationMin: durationMin ?? this.durationMin,
      notes:       notes       ?? this.notes,
      rating:      rating      ?? this.rating,
      sets:        sets        ?? this.sets,
      isDirty:     isDirty     ?? this.isDirty,
    );
  }
}
