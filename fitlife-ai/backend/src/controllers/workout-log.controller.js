const WorkoutLogService = require('../services/workout-log.service');

const WorkoutLogController = {
  async start(req, res, next) {
    try {
      const log = await WorkoutLogService.startWorkout(req.userId, req.body);
      return res.status(201).json({
        success: true,
        message: 'Sessão de treino iniciada!',
        log,
      });
    } catch (error) {
      next(error);
    }
  },

  async addSet(req, res, next) {
    try {
      const set = await WorkoutLogService.addSet(Number(req.params.id), req.userId, req.body);
      return res.status(201).json({
        success: true,
        message: 'Série registrada com sucesso!',
        set,
      });
    } catch (error) {
      next(error);
    }
  },

  async finish(req, res, next) {
    try {
      const log = await WorkoutLogService.finishWorkout(Number(req.params.id), req.userId, req.body);
      return res.status(200).json({
        success: true,
        message: 'Sessão de treino finalizada com sucesso! Parabéns pelo treino!',
        log,
      });
    } catch (error) {
      next(error);
    }
  },

  async getHistory(req, res, next) {
    try {
      const logs = await WorkoutLogService.getHistory(req.userId, req.query);
      return res.status(200).json({
        success: true,
        count: logs.length,
        logs,
      });
    } catch (error) {
      next(error);
    }
  },

  async getById(req, res, next) {
    try {
      const log = await WorkoutLogService.getById(Number(req.params.id), req.userId);
      return res.status(200).json({
        success: true,
        log,
      });
    } catch (error) {
      next(error);
    }
  },

  async getExerciseProgress(req, res, next) {
    try {
      const progress = await WorkoutLogService.getExerciseProgress(
        req.userId,
        Number(req.params.exerciseId),
        Number(req.query.limit || 10)
      );
      return res.status(200).json({
        success: true,
        progress,
      });
    } catch (error) {
      next(error);
    }
  },
};

module.exports = WorkoutLogController;

