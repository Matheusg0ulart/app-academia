// lib/services/sync_service.dart
//
// Sincronização bidirecional entre SQLite local e backend PostgreSQL.
// Estratégia: offline-first → dados salvos localmente (is_dirty=1)
// são enviados ao servidor quando houver conexão.

import 'package:connectivity_plus/connectivity_plus.dart';
import 'api_service.dart';
import 'local_db_service.dart';
import '../models/exercise.dart';

class SyncService {
  final ApiService      _api   = ApiService();
  final LocalDbService  _local = LocalDbService();

  // ── Verificação de conectividade ─────────────────────────────
  Future<bool> hasInternet() async {
    final result = await Connectivity().checkConnectivity();
    return result != ConnectivityResult.none;
  }

  // ═══════════════════════════════════════════════════════════
  // SINCRONIZAÇÃO COMPLETA
  // Chame este método ao abrir o app ou quando a conexão voltar.
  // ═══════════════════════════════════════════════════════════
  Future<SyncResult> syncAll() async {
    if (!await hasInternet()) {
      return SyncResult(
        success: false,
        message: 'Sem conexão. Dados serão sincronizados quando a internet voltar.',
      );
    }

    final errors = <String>[];
    int synced = 0;

    // 1. Baixa exercícios do servidor → salva local
    try {
      await _pullExercises();
      synced++;
    } catch (e) {
      errors.add('Exercícios: $e');
    }

    // 2. Envia fichas de treino pendentes → servidor
    try {
      synced += await _pushDirtyWorkouts();
    } catch (e) {
      errors.add('Fichas de treino: $e');
    }

    // 3. Envia sessões de treino finalizadas → servidor
    try {
      synced += await _pushDirtyWorkoutLogs();
    } catch (e) {
      errors.add('Sessões de treino: $e');
    }

    return SyncResult(
      success: errors.isEmpty,
      message: errors.isEmpty
          ? '✅ Sincronização concluída. $synced operações realizadas.'
          : '⚠️ Sincronização parcial. Erros: ${errors.join(', ')}',
      errors:  errors,
    );
  }

  // ═══════════════════════════════════════════════════════════
  // PULL — Servidor → Local
  // ═══════════════════════════════════════════════════════════

  /// Baixa o catálogo de exercícios do servidor e salva localmente.
  Future<void> _pullExercises() async {
    final exercises = await _api.getExercises();
    await _local.saveExercises(exercises);
  }

  /// Baixa exercícios manualmente (uso externo).
  Future<List<Exercise>> pullExercises() async {
    final exercises = await _api.getExercises();
    await _local.saveExercises(exercises);
    return exercises;
  }

  // ═══════════════════════════════════════════════════════════
  // PUSH — Local → Servidor
  // ═══════════════════════════════════════════════════════════

  /// Envia fichas de treino com is_dirty=1 para o servidor.
  Future<int> _pushDirtyWorkouts() async {
    final dirtyWorkouts = await _local.getDirtyWorkouts();
    int count = 0;

    for (final workout in dirtyWorkouts) {
      try {
        if (workout.serverId != null) {
          // Já existe no servidor — atualiza
          await _api.updateWorkout(workout.serverId!, {
            'name':        workout.name,
            'description': workout.description,
          });
        } else {
          // Novo — cria no servidor e salva o server_id local
          final created = await _api.createWorkout({
            'name':        workout.name,
            'description': workout.description,
          });
          await _local.markWorkoutSynced(workout.id, created.id);
        }
        count++;
      } catch (e) {
        // Não bloqueia os demais em caso de erro pontual
        continue;
      }
    }

    return count;
  }

  /// Envia sessões de treino finalizadas com is_dirty=1 para o servidor.
  Future<int> _pushDirtyWorkoutLogs() async {
    final dirtyLogs = await _local.getDirtyWorkoutLogs();
    int count = 0;

    for (final log in dirtyLogs) {
      try {
        if (log.serverId != null) {
          // Já sincronizado — apenas atualiza rating/notes se necessário
          continue;
        }

        // Cria a sessão no servidor
        final created = await _api.startWorkoutLog(
          workoutId: log.workoutId,
        );

        // Envia as séries uma a uma
        final fullLog = await _local.getWorkoutLogById(log.id);
        if (fullLog != null) {
          for (final set in fullLog.sets) {
            await _api.addSet(created.id, {
              'exercise_id':   set.exerciseId,
              'set_number':    set.setNumber,
              'reps_done':     set.repsDone,
              'weight_kg':     set.weightKg,
              'duration_secs': set.durationSecs,
              'is_warmup':     set.isWarmup,
              'notes':         set.notes,
            });
          }
        }

        // Finaliza a sessão no servidor
        await _api.finishWorkoutLog(
          created.id,
          notes:  log.notes,
          rating: log.rating,
        );

        await _local.markWorkoutLogSynced(log.id, created.id);
        count++;
      } catch (e) {
        continue;
      }
    }

    return count;
  }

  // ═══════════════════════════════════════════════════════════
  // LISTENER DE CONECTIVIDADE
  // Use no initState de um widget raiz para sync automático.
  // ═══════════════════════════════════════════════════════════

  /// Retorna um Stream que emite true quando a internet volta.
  Stream<bool> get connectivityStream {
    return Connectivity().onConnectivityChanged.map(
      (result) => result != ConnectivityResult.none,
    );
  }
}

/// Resultado de uma operação de sincronização.
class SyncResult {
  final bool success;
  final String message;
  final List<String> errors;

  const SyncResult({
    required this.success,
    required this.message,
    this.errors = const [],
  });

  @override
  String toString() => 'SyncResult(success: $success, message: $message)';
}
