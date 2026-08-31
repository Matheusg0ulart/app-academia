const WorkoutLogModel = require('../models/workout-log.model');

const WorkoutLogService = {
  async startWorkout(userId, data = {}) {
    const { workout_id, workoutId, notes, rating } = data;
    return WorkoutLogModel.create({
      userId,
      workoutId: workout_id || workoutId,
      notes,
      rating,
    });
  },

  async addSet(workoutLogId, userId, data) {
    // Garante que o treino pertence ao usuário
    const log = await WorkoutLogModel.findById(workoutLogId, userId);
    if (!log) {
      const error = new Error('Sessão de treino não encontrada.');
      error.statusCode = 404;
      throw error;
    }

    const { exercise_id, exerciseId, set_number, setNumber, reps_done, repsDone, weight_kg, weightKg, duration_secs, durationSecs, is_warmup, isWarmup, notes } = data;
    const targetExerciseId = exercise_id || exerciseId;

    if (!targetExerciseId || (set_number == null && setNumber == null)) {
      const error = new Error('ID do exercício e número da série são obrigatórios.');
      error.statusCode = 400;
      throw error;
    }

    return WorkoutLogModel.addSet({
      workoutLogId,
      exerciseId: targetExerciseId,
      setNumber: set_number != null ? set_number : setNumber,
      repsDone: reps_done != null ? reps_done : repsDone,
      weightKg: weight_kg != null ? weight_kg : weightKg,
      durationSecs: duration_secs != null ? duration_secs : durationSecs,
      isWarmup: is_warmup != null ? is_warmup : isWarmup,
      notes,
    });
  },

  async finishWorkout(id, userId, data = {}) {
    const log = await WorkoutLogModel.finish(id, userId, data);
    if (!log) {
      const error = new Error('Sessão de treino não encontrada.');
      error.statusCode = 404;
      throw error;
    }
    return log;
  },

  async getHistory(userId, pagination = {}) {
    const page = Number(pagination.page || 1);
    const limit = Number(pagination.limit || 20);
    const offset = (page - 1) * limit;
    return WorkoutLogModel.findByUser(userId, { limit, offset });
  },

  async getById(id, userId) {
    const log = await WorkoutLogModel.findById(id, userId);
    if (!log) {
      const error = new Error('Sessão de treino não encontrada.');
      error.statusCode = 404;
      throw error;
    }
    return log;
  },

  async getExerciseProgress(userId, exerciseId, limit = 10) {
    return WorkoutLogModel.getExerciseProgress(userId, exerciseId, limit);
  },
};

module.exports = WorkoutLogService;

