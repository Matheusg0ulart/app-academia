// lib/services/api_service.dart
//
// Cliente HTTP para comunicação com o backend FitLife AI.
// Gerencia autenticação JWT, refresh de token e tratamento de erros.

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/exercise.dart';
import '../models/workout.dart';
import '../models/workout_log.dart';
import '../models/user.dart';

/// Exceção tipada para erros da API.
class ApiException implements Exception {
  final int statusCode;
  final String message;
  const ApiException(this.statusCode, this.message);

  @override
  String toString() => 'ApiException($statusCode): $message';
}

class ApiService {
  // ── Configuração ─────────────────────────────────────────────
  // Em produção, troque por sua URL do Railway/Render/etc.
  static const String _baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://10.0.2.2:3000/api', // Android emulator → localhost
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

  // ── Request helper ───────────────────────────────────────────
  Future<Map<String, dynamic>> _request(
    String method,
    String path, {
    Map<String, dynamic>? body,
  }) async {
    final uri     = Uri.parse('$_baseUrl$path');
    final headers = await _authHeaders();
    final bodyStr = body != null ? jsonEncode(body) : null;

    http.Response response;

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

    final data = jsonDecode(response.body) as Map<String, dynamic>;

    if (response.statusCode >= 400) {
      throw ApiException(
        response.statusCode,
        data['message'] as String? ?? 'Erro desconhecido',
      );
    }

    return data;
  }

  // ═══════════════════════════════════════════════════════════
  // AUTENTICAÇÃO
  // ═══════════════════════════════════════════════════════════

  Future<User> register({
    required String name,
    required String email,
    required String password,
  }) async {
    final data = await _request('POST', '/auth/register', body: {
      'name':     name,
      'email':    email,
      'password': password,
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
  // PERFIL
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
  // EXERCÍCIOS
  // ═══════════════════════════════════════════════════════════

  Future<List<Exercise>> getExercises({String? muscleGroup}) async {
    final path = muscleGroup != null
        ? '/exercises?muscle_group=$muscleGroup'
        : '/exercises';
    final data = await _request('GET', path);
    final list = data['exercises'] as List<dynamic>;
    return list.map((e) => Exercise.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<Exercise> createExercise(Map<String, dynamic> body) async {
    final data = await _request('POST', '/exercises', body: body);
    return Exercise.fromJson(data['exercise'] as Map<String, dynamic>);
  }

  // ═══════════════════════════════════════════════════════════
  // FICHAS DE TREINO
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

  // ═══════════════════════════════════════════════════════════
  // SESSÕES DE TREINO (LOGS)
  // ═══════════════════════════════════════════════════════════

  Future<WorkoutLog> startWorkoutLog({int? workoutId}) async {
    final data = await _request('POST', '/workout-logs', body: {
      if (workoutId != null) 'workout_id': workoutId,
    });
    return WorkoutLog.fromJson(data['log'] as Map<String, dynamic>);
  }

  Future<WorkoutLog> finishWorkoutLog(
    int id, {
    String? notes,
    int? rating,
  }) async {
    final data = await _request('PATCH', '/workout-logs/$id/finish', body: {
      if (notes  != null) 'notes':  notes,
      if (rating != null) 'rating': rating,
    });
    return WorkoutLog.fromJson(data['log'] as Map<String, dynamic>);
  }

  Future<List<WorkoutLog>> getWorkoutHistory({int page = 1}) async {
    final data = await _request('GET', '/workout-logs?page=$page');
    final list = data['logs'] as List<dynamic>;
    return list.map((l) => WorkoutLog.fromJson(l as Map<String, dynamic>)).toList();
  }

  Future<SetLog> addSet(int workoutLogId, Map<String, dynamic> body) async {
    final data = await _request('POST', '/workout-logs/$workoutLogId/sets', body: body);
    return SetLog.fromJson(data['set'] as Map<String, dynamic>);
  }
}
