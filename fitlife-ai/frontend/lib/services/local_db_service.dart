// lib/services/local_db_service.dart
//
// Camada de acesso ao SQLite local.
// Todas as operações de leitura e escrita offline passam por aqui.

import 'package:sqflite/sqflite.dart' show ConflictAlgorithm;
import '../core/database/database_helper.dart';
import '../models/exercise.dart';
import '../models/workout.dart';
import '../models/workout_log.dart';
import '../models/user.dart';
import '../models/nutrition.dart';
import '../models/measurement.dart';

class LocalDbService {
  final DatabaseHelper _db = DatabaseHelper.instance;

  // ═══════════════════════════════════════════════════════════
  // USUÁRIO
  // ═══════════════════════════════════════════════════════════

  Future<User?> getLocalUser() async {
    final rows = await _db.query('users', limit: 1);
    if (rows.isEmpty) return null;
    return User.fromMap(rows.first);
  }

  Future<void> saveLocalUser(User user) async {
    await _db.insert('users', user.toMap());
  }

  Future<void> updateLocalUser(User user) async {
    await _db.update(
      'users',
      user.toMap(),
      where: 'id = ?',
      whereArgs: [user.id],
    );
  }

  // ═══════════════════════════════════════════════════════════
  // EXERCÍCIOS
  // ═══════════════════════════════════════════════════════════

  Future<List<Exercise>> getExercises({String? muscleGroup}) async {
    final rows = await _db.query(
      'exercises',
      where:     muscleGroup != null ? 'muscle_group = ?' : null,
      whereArgs: muscleGroup != null ? [muscleGroup] : null,
      orderBy:   'name ASC',
    );
    return rows.map(Exercise.fromMap).toList();
  }

  Future<Exercise?> getExerciseById(int id) async {
    final rows = await _db.query(
      'exercises',
      where:     'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    if (rows.isEmpty) return null;
    return Exercise.fromMap(rows.first);
  }

  /// Salva (upsert) lista de exercícios sincronizados do servidor.
  Future<void> saveExercises(List<Exercise> exercises) async {
    await _db.transaction((txn) async {
      for (final ex in exercises) {
        await txn.insert(
          'exercises',
          ex.toMap(),
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      }
    });
  }

  Future<List<String>> getMuscleGroups() async {
    final rows = await _db.rawQuery(
      'SELECT DISTINCT muscle_group FROM exercises ORDER BY muscle_group ASC',
    );
    return rows.map((r) => r['muscle_group'] as String).toList();
  }

  // ═══════════════════════════════════════════════════════════
  // FICHAS DE TREINO
  // ═══════════════════════════════════════════════════════════

  Future<List<Workout>> getWorkouts(int userId) async {
    final rows = await _db.query(
      'workouts',
      where:   'user_id = ?',
      whereArgs: [userId],
      orderBy: 'updated_at DESC',
    );
    final workouts = <Workout>[];
    for (final row in rows) {
      final workout = Workout.fromMap(row);
      final exercises = await _getWorkoutExercises(workout.id);
      workouts.add(workout.copyWith(exercises: exercises));
    }
    return workouts;
  }

  Future<Workout?> getWorkoutById(int id) async {
    final rows = await _db.query(
      'workouts',
      where:     'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    if (rows.isEmpty) return null;
    final workout = Workout.fromMap(rows.first);
    final exercises = await _getWorkoutExercises(id);
    return workout.copyWith(exercises: exercises);
  }

  Future<List<WorkoutExercise>> _getWorkoutExercises(int workoutId) async {
    final rows = await _db.query(
      'workout_exercises',
      where:     'workout_id = ?',
      whereArgs: [workoutId],
      orderBy:   'order_index ASC',
    );
    return rows.map(WorkoutExercise.fromMap).toList();
  }

  Future<int> createWorkout(Workout workout) async {
    return _db.insert('workouts', workout.toMap());
  }

  Future<void> updateWorkout(Workout workout) async {
    await _db.update(
      'workouts',
      workout.toMap(),
      where:     'id = ?',
      whereArgs: [workout.id],
    );
  }

  Future<void> deleteWorkout(int id) async {
    await _db.delete('workouts', where: 'id = ?', whereArgs: [id]);
  }

  Future<int> addExerciseToWorkout(WorkoutExercise we) async {
    return _db.insert('workout_exercises', we.toMap());
  }

  Future<void> removeExerciseFromWorkout(int id) async {
    await _db.delete('workout_exercises', where: 'id = ?', whereArgs: [id]);
  }

  // ═══════════════════════════════════════════════════════════
  // SESSÕES DE TREINO (LOGS)
  // ═══════════════════════════════════════════════════════════

  Future<int> createWorkoutLog(WorkoutLog log) async {
    return _db.insert('workout_logs', log.toMap());
  }

  Future<void> finishWorkoutLog(int id) async {
    final finishedAt = DateTime.now();
    final rows = await _db.query(
      'workout_logs',
      where:     'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    if (rows.isEmpty) return;

    final startedAt = DateTime.tryParse(rows.first['started_at'] as String) ?? finishedAt;
    final durationMin = finishedAt.difference(startedAt).inMinutes;

    await _db.update(
      'workout_logs',
      {
        'finished_at':  finishedAt.toIso8601String(),
        'duration_min': durationMin,
        'is_dirty':     1,
      },
      where:     'id = ?',
      whereArgs: [id],
    );
  }

  Future<List<WorkoutLog>> getWorkoutHistory({int limit = 20, int offset = 0}) async {
    final rows = await _db.query(
      'workout_logs',
      orderBy: 'started_at DESC',
      limit:   limit,
      offset:  offset,
    );
    return rows.map(WorkoutLog.fromMap).toList();
  }

  Future<WorkoutLog?> getWorkoutLogById(int id) async {
    final rows = await _db.query(
      'workout_logs',
      where:     'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    if (rows.isEmpty) return null;
    final log = WorkoutLog.fromMap(rows.first);
    final sets = await _getSetLogs(id);
    return log.copyWith(sets: sets);
  }

  Future<List<SetLog>> _getSetLogs(int workoutLogId) async {
    final rows = await _db.query(
      'set_logs',
      where:     'workout_log_id = ?',
      whereArgs: [workoutLogId],
      orderBy:   'exercise_id ASC, set_number ASC',
    );
    return rows.map(SetLog.fromMap).toList();
  }

  Future<int> addSetLog(SetLog setLog) async {
    return _db.insert('set_logs', setLog.toMap());
  }

  // ═══════════════════════════════════════════════════════════
  // NUTRIÇÃO & REFEIÇÕES
  // ═══════════════════════════════════════════════════════════

  Future<int> createNutritionLog(NutritionLog log) async {
    return _db.insert('nutrition_logs', log.toMap());
  }

  Future<List<NutritionLog>> getNutritionLogsByDate(int userId, String date) async {
    final rows = await _db.query(
      'nutrition_logs',
      where:     'user_id = ? AND logged_date = ?',
      whereArgs: [userId, date],
    );
    return rows.map(NutritionLog.fromMap).toList();
  }

  // ═══════════════════════════════════════════════════════════
  // MEDIDAS CORPORAIS
  // ═══════════════════════════════════════════════════════════

  Future<int> createMeasurement(BodyMeasurement measurement) async {
    return _db.insert('body_measurements', measurement.toMap());
  }

  Future<List<BodyMeasurement>> getMeasurements(int userId, {int limit = 30}) async {
    final rows = await _db.query(
      'body_measurements',
      where:     'user_id = ?',
      whereArgs: [userId],
      orderBy:   'measured_at DESC',
      limit:     limit,
    );
    return rows.map(BodyMeasurement.fromMap).toList();
  }

  // ═══════════════════════════════════════════════════════════
  // SINCRONIZAÇÃO — retorna registros pendentes
  // ═══════════════════════════════════════════════════════════

  Future<List<Workout>> getDirtyWorkouts() async {
    final rows = await _db.query(
      'workouts',
      where:     'is_dirty = 1',
      whereArgs: [],
    );
    return rows.map(Workout.fromMap).toList();
  }

  Future<List<WorkoutLog>> getDirtyWorkoutLogs() async {
    final rows = await _db.query(
      'workout_logs',
      where:     'is_dirty = 1 AND finished_at IS NOT NULL',
      whereArgs: [],
    );
    return rows.map(WorkoutLog.fromMap).toList();
  }

  Future<void> markWorkoutSynced(int localId, int serverId) async {
    await _db.update(
      'workouts',
      {'server_id': serverId, 'is_dirty': 0},
      where:     'id = ?',
      whereArgs: [localId],
    );
  }

  Future<void> markWorkoutLogSynced(int localId, int serverId) async {
    await _db.update(
      'workout_logs',
      {'server_id': serverId, 'is_dirty': 0},
      where:     'id = ?',
      whereArgs: [localId],
    );
  }
}
