// lib/services/api_service.dart
//
// Cliente HTTP completo para comunicação com o backend FitLife AI.
// Gerencia autenticação JWT, persistência de tokens e todos os endpoints REST.

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/exercise.dart';
import '../models/workout.dart';
import '../models/workout_log.dart';
import '../models/user.dart';
import '../models/nutrition.dart';
import '../models/measurement.dart';
import '../models/dashboard_summary.dart';
import '../models/food_item.dart';
import '../models/badge.dart';

/// Exceção tipada para erros da API.
class ApiException implements Exception {
  final int statusCode;
  final String message;
  const ApiException(this.statusCode, this.message);

  @override
  String toString() => 'ApiException($statusCode): $message';
}

class ApiService {
  // Singleton
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  ApiService._internal();

  // ── Configuração da URL Base ─────────────────────────────────
  // Em emuladores Android use 'http://10.0.2.2:3000/api'
  // Em web / desktop / localhost use 'http://localhost:3000/api'
  static const String _baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://localhost:3000/api',
  );

  static const String _tokenKey        = 'access_token';
  static const String _refreshTokenKey = 'refresh_token';

  // ── Headers ──────────────────────────────────────────────────
  Future<Map<String, String>> _authHeaders() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString(_tokenKey);
    return {
      'Content-Type':  'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  // ── Persistência de tokens ────────────────────────────────────
  Future<void> saveTokens(String accessToken, String refreshToken) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, accessToken);
    await prefs.setString(_refreshTokenKey, refreshToken);
  }

  Future<void> clearTokens() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
    await prefs.remove(_refreshTokenKey);
  }

  Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_tokenKey) != null;
  }

  // ── Request helper genérico ──────────────────────────────────
  Future<Map<String, dynamic>> _request(
    String method,
    String path, {
    Map<String, dynamic>? body,
  }) async {
    final uri     = Uri.parse('$_baseUrl$path');
    final headers = await _authHeaders();
    final bodyStr = body != null ? jsonEncode(body) : null;

    http.Response response;

    try {
      switch (method) {
        case 'GET':
          response = await http.get(uri, headers: headers);
          break;
        case 'POST':
          response = await http.post(uri, headers: headers, body: bodyStr);
          break;
        case 'PUT':
          response = await http.put(uri, headers: headers, body: bodyStr);
          break;
        case 'PATCH':
          response = await http.patch(uri, headers: headers, body: bodyStr);
          break;
        case 'DELETE':
          response = await http.delete(uri, headers: headers);
          break;
        default:
          throw ApiException(0, 'Método HTTP inválido: $method');
      }
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException(0, 'Falha na conexão com o servidor. Verifique se a API está rodando.');
    }

    final data = jsonDecode(response.body) as Map<String, dynamic>;

    if (response.statusCode >= 400) {
      throw ApiException(
        response.statusCode,
        data['message'] as String? ?? 'Ocorreu um erro no processamento da requisição.',
      );
    }

    return data;
  }

  // ═══════════════════════════════════════════════════════════
  // 1. AUTENTICAÇÃO
  // ═══════════════════════════════════════════════════════════

  Future<User> register({
    required String name,
    required String email,
    required String password,
    int? age,
    String? sex,
    double? weightKg,
    double? heightCm,
    String? goal,
    String? activityLevel,
  }) async {
    final data = await _request('POST', '/auth/register', body: {
      'name':           name,
      'email':          email,
      'password':       password,
      'age':            age,
      'sex':            sex,
      'weight_kg':      weightKg,
      'height_cm':      heightCm,
      'goal':           goal,
      'activity_level': activityLevel,
    });
    await saveTokens(
      data['access_token']  as String,
      data['refresh_token'] as String,
    );
    return User.fromJson(data['user'] as Map<String, dynamic>);
  }

  Future<User> login({
    required String email,
    required String password,
  }) async {
    final data = await _request('POST', '/auth/login', body: {
      'email':    email,
      'password': password,
    });
    await saveTokens(
      data['access_token']  as String,
      data['refresh_token'] as String,
    );
    return User.fromJson(data['user'] as Map<String, dynamic>);
  }

  Future<void> logout() async {
    try {
      await _request('POST', '/auth/logout');
    } finally {
      await clearTokens();
    }
  }

  // ═══════════════════════════════════════════════════════════
  // 2. PERFIL
  // ═══════════════════════════════════════════════════════════

  Future<User> getProfile() async {
    final data = await _request('GET', '/users/me');
    return User.fromJson(data['user'] as Map<String, dynamic>);
  }

  Future<User> updateProfile(Map<String, dynamic> updates) async {
    final data = await _request('PATCH', '/users/me', body: updates);
    return User.fromJson(data['user'] as Map<String, dynamic>);
  }

  // ═══════════════════════════════════════════════════════════
  // 3. EXERCÍCIOS
  // ═══════════════════════════════════════════════════════════

  Future<List<Exercise>> getExercises({String? muscleGroup, String? search}) async {
    final queryParams = <String>[];
    if (muscleGroup != null && muscleGroup.isNotEmpty) queryParams.add('muscle_group=$muscleGroup');
    if (search != null && search.isNotEmpty) queryParams.add('search=$search');
    final queryStr = queryParams.isNotEmpty ? '?${queryParams.join('&')}' : '';

    final data = await _request('GET', '/exercises$queryStr');
    final list = data['exercises'] as List<dynamic>;
    return list.map((e) => Exercise.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<List<String>> getMuscleGroups() async {
    final data = await _request('GET', '/exercises/muscle-groups');
    final list = data['groups'] as List<dynamic>;
    return list.map((g) => g.toString()).toList();
  }

  Future<Exercise> createExercise(Map<String, dynamic> body) async {
    final data = await _request('POST', '/exercises', body: body);
    return Exercise.fromJson(data['exercise'] as Map<String, dynamic>);
  }

  // ═══════════════════════════════════════════════════════════
  // 4. FICHAS DE TREINO
  // ═══════════════════════════════════════════════════════════

  Future<List<Workout>> getWorkouts() async {
    final data = await _request('GET', '/workouts');
    final list = data['workouts'] as List<dynamic>;
    return list.map((w) => Workout.fromJson(w as Map<String, dynamic>)).toList();
  }

  Future<Workout> getWorkoutById(int id) async {
    final data = await _request('GET', '/workouts/$id');
    return Workout.fromJson(data['workout'] as Map<String, dynamic>);
  }

  Future<Workout> createWorkout(Map<String, dynamic> body) async {
    final data = await _request('POST', '/workouts', body: body);
    return Workout.fromJson(data['workout'] as Map<String, dynamic>);
  }

  Future<Workout> updateWorkout(int id, Map<String, dynamic> body) async {
    final data = await _request('PATCH', '/workouts/$id', body: body);
    return Workout.fromJson(data['workout'] as Map<String, dynamic>);
  }

  Future<void> deleteWorkout(int id) async {
    await _request('DELETE', '/workouts/$id');
  }

  Future<WorkoutExercise> addExerciseToWorkout(int workoutId, Map<String, dynamic> body) async {
    final data = await _request('POST', '/workouts/$workoutId/exercises', body: body);
    return WorkoutExercise.fromJson(data['exercise'] as Map<String, dynamic>);
  }

  Future<void> removeExerciseFromWorkout(int workoutId, int exerciseItemId) async {
    await _request('DELETE', '/workouts/$workoutId/exercises/$exerciseItemId');
  }

  // ═══════════════════════════════════════════════════════════
  // 5. SESSÕES DE TREINO (EXECUÇÃO & HISTÓRICO)
  // ═══════════════════════════════════════════════════════════

  Future<WorkoutLog> startWorkoutLog({int? workoutId, String? notes}) async {
    final data = await _request('POST', '/workout-logs', body: {
      if (workoutId != null) 'workout_id': workoutId,
      if (notes != null) 'notes': notes,
    });
    return WorkoutLog.fromJson(data['log'] as Map<String, dynamic>);
  }

  Future<SetLog> addSet(int workoutLogId, Map<String, dynamic> body) async {
    final data = await _request('POST', '/workout-logs/$workoutLogId/sets', body: body);
    return SetLog.fromJson(data['set'] as Map<String, dynamic>);
  }

  Future<WorkoutLog> finishWorkoutLog(int id, {String? notes, int? rating}) async {
    final data = await _request('PATCH', '/workout-logs/$id/finish', body: {
      if (notes != null) 'notes': notes,
      if (rating != null) 'rating': rating,
    });
    return WorkoutLog.fromJson(data['log'] as Map<String, dynamic>);
  }

  Future<List<WorkoutLog>> getWorkoutHistory({int page = 1, int limit = 20}) async {
    final data = await _request('GET', '/workout-logs?page=$page&limit=$limit');
    final list = data['logs'] as List<dynamic>;
    return list.map((l) => WorkoutLog.fromJson(l as Map<String, dynamic>)).toList();
  }

  Future<WorkoutLog> getWorkoutLogById(int id) async {
    final data = await _request('GET', '/workout-logs/$id');
    return WorkoutLog.fromJson(data['log'] as Map<String, dynamic>);
  }

  Future<List<dynamic>> getExerciseProgress(int exerciseId, {int limit = 10}) async {
    final data = await _request('GET', '/workout-logs/exercise/$exerciseId/progress?limit=$limit');
    return data['progress'] as List<dynamic>;
  }

  // ═══════════════════════════════════════════════════════════
  // 6. NUTRIÇÃO E REFEIÇÕES
  // ═══════════════════════════════════════════════════════════

  Future<NutritionLog> logMeal(Map<String, dynamic> body) async {
    final data = await _request('POST', '/nutrition', body: body);
    return NutritionLog.fromJson(data['meal'] as Map<String, dynamic>);
  }

  Future<DailyNutritionSummary> getDailyNutritionSummary({String? date}) async {
    final queryStr = date != null ? '?date=$date' : '';
    final data = await _request('GET', '/nutrition/daily$queryStr');
    return DailyNutritionSummary.fromJson(data['summary'] as Map<String, dynamic>);
  }

  Future<List<dynamic>> getNutritionHistory({int days = 7}) async {
    final data = await _request('GET', '/nutrition/history?days=$days');
    return data['history'] as List<dynamic>;
  }

  Future<void> deleteMeal(int id) async {
    await _request('DELETE', '/nutrition/$id');
  }

  // ═══════════════════════════════════════════════════════════
  // 7. MEDIDAS CORPORAIS E EVOLUÇÃO
  // ═══════════════════════════════════════════════════════════

  Future<BodyMeasurement> logMeasurement(Map<String, dynamic> body) async {
    final data = await _request('POST', '/measurements', body: body);
    return BodyMeasurement.fromJson(data['measurement'] as Map<String, dynamic>);
  }

  Future<List<BodyMeasurement>> getMeasurementHistory({int limit = 30}) async {
    final data = await _request('GET', '/measurements?limit=$limit');
    final list = data['history'] as List<dynamic>;
    return list.map((m) => BodyMeasurement.fromJson(m as Map<String, dynamic>)).toList();
  }

  Future<BodyMeasurement?> getLatestMeasurement() async {
    final data = await _request('GET', '/measurements/latest');
    if (data['measurement'] == null) return null;
    return BodyMeasurement.fromJson(data['measurement'] as Map<String, dynamic>);
  }

  Future<void> deleteMeasurement(int id) async {
    await _request('DELETE', '/measurements/$id');
  }

  // ═══════════════════════════════════════════════════════════
  // 8. CALCULADORAS METABÓLICAS
  // ═══════════════════════════════════════════════════════════

  Future<Map<String, dynamic>> calculateTmbAndTdee(Map<String, dynamic> params) async {
    final data = await _request('POST', '/calculators/tmb-tdee', body: params);
    return data['data'] as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> calculateExerciseCalories(Map<String, dynamic> params) async {
    final data = await _request('POST', '/calculators/exercise-calories', body: params);
    return data['data'] as Map<String, dynamic>;
  }

  Future<List<dynamic>> getAvailableActivities() async {
    final data = await _request('GET', '/calculators/activities');
    return data['activities'] as List<dynamic>;
  }

  // ═══════════════════════════════════════════════════════════
  // 9. DASHBOARD
  // ═══════════════════════════════════════════════════════════

  Future<DashboardSummary> getDashboardSummary() async {
    final data = await _request('GET', '/dashboard/summary');
    return DashboardSummary.fromJson(data['summary'] as Map<String, dynamic>);
  }

  // ═══════════════════════════════════════════════════════════
  // 10. ASSISTENTE DE INTELIGÊNCIA ARTIFICIAL
  // ═══════════════════════════════════════════════════════════

  Future<Map<String, dynamic>> sendChatMessage(String message) async {
    final data = await _request('POST', '/ai/chat', body: {'message': message});
    return {
      'reply':  data['reply'] as String,
      'source': data['source'] as String?,
    };
  }

  Future<Map<String, dynamic>> getAiContext() async {
    final data = await _request('GET', '/ai/context');
    return data['context'] as Map<String, dynamic>;
  }

  // ═══════════════════════════════════════════════════════════
  // FOOD SEARCH (TACO + Open Food Facts)
  // ═══════════════════════════════════════════════════════════

  Future<Map<String, List<FoodItem>>> searchFoods(String query, {String category = 'all'}) async {
    final data = await _request('GET', '/nutrition/foods/search?query=${Uri.encodeComponent(query)}&category=$category');
    final naturalList = (data['natural'] as List<dynamic>? ?? [])
        .map((e) => FoodItem.fromJson(e as Map<String, dynamic>))
        .toList();
    final industrializedList = (data['industrialized'] as List<dynamic>? ?? [])
        .map((e) => FoodItem.fromJson(e as Map<String, dynamic>))
        .toList();
    return {
      'natural': naturalList,
      'industrialized': industrializedList,
    };
  }

  Future<FoodItem?> getFoodByBarcode(String barcode) async {
    try {
      final data = await _request('GET', '/nutrition/foods/barcode/${Uri.encodeComponent(barcode)}');
      if (data['product'] != null) {
        return FoodItem.fromJson(data['product'] as Map<String, dynamic>);
      }
      return null;
    } catch (_) {
      return null;
    }
  }

  // ═══════════════════════════════════════════════════════════
  // WORKOUT GENERATOR & PROGRESS
  // ═══════════════════════════════════════════════════════════

  Future<List<Workout>> generateSmartWorkout({
    required String goal,
    required String level,
    required String split,
  }) async {
    final data = await _request('POST', '/workouts/generate', body: {
      'goal': goal,
      'level': level,
      'split': split,
    });
    final list = data['workouts'] as List<dynamic>? ?? [];
    return list.map((w) => Workout.fromJson(w as Map<String, dynamic>)).toList();
  }

  Future<List<WorkoutLog>> getWorkoutHistory({int page = 1, int limit = 20}) async {
    final data = await _request('GET', '/workout-logs?page=$page&limit=$limit');
    final list = data['logs'] as List<dynamic>? ?? [];
    return list.map((l) => WorkoutLog.fromJson(l as Map<String, dynamic>)).toList();
  }

  Future<List<Map<String, dynamic>>> getExerciseProgress(int exerciseId) async {
    final data = await _request('GET', '/workout-logs/exercise/$exerciseId/progress');
    return (data['progress'] as List<dynamic>? ?? []).cast<Map<String, dynamic>>();
  }

  // ═══════════════════════════════════════════════════════════
  // AI MEAL ESTIMATOR & TARGETS
  // ═══════════════════════════════════════════════════════════

  Future<Map<String, dynamic>> estimateMealFromText(String text) async {
    final data = await _request('POST', '/nutrition/estimate-text', body: {'text': text});
    return data;
  }

  Future<Map<String, dynamic>> getMealTargets() async {
    final data = await _request('GET', '/nutrition/meal-targets');
    return data;
  }

  // ═══════════════════════════════════════════════════════════
  // GAMIFICATION & REPORTS
  // ═══════════════════════════════════════════════════════════

  Future<BadgesSummary> getBadges() async {
    final data = await _request('GET', '/dashboard/badges');
    return BadgesSummary.fromJson(data);
  }

  Future<Map<String, dynamic>> getExportReport() async {
    final data = await _request('GET', '/users/report');
    return data;
  }

  // ═══════════════════════════════════════════════════════════
  // WEIGHT PROJECTION SIMULATOR
  // ═══════════════════════════════════════════════════════════

  Future<Map<String, dynamic>> simulateWeightProjection({
    required double currentWeight,
    required double targetWeight,
    int dailyDeficitKcal = 500,
  }) async {
    final data = await _request('POST', '/calculators/weight-projection', body: {
      'currentWeight': currentWeight,
      'targetWeight': targetWeight,
      'dailyDeficitKcal': dailyDeficitKcal,
    });
    return data;
  }

  // ═══════════════════════════════════════════════════════════
  // GEMINI VISION — SCANNER DE PRATO
  // ═══════════════════════════════════════════════════════════

  Future<Map<String, dynamic>> scanFoodPlate({
    required String base64Image,
    String mimeType = 'image/jpeg',
  }) async {
    final data = await _request('POST', '/vision/scan-plate', body: {
      'image': base64Image,
      'mimeType': mimeType,
    });
    return data;
  }
}
