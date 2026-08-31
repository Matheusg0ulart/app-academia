const WorkoutService = require('../services/workout.service');

const WorkoutController = {
  async list(req, res, next) {
    try {
      const workouts = await WorkoutService.listUserWorkouts(req.userId);
      return res.status(200).json({
        success: true,
        count: workouts.length,
        workouts,
      });
    } catch (error) {
      next(error);
    }
  },

  async getById(req, res, next) {
    try {
      const workout = await WorkoutService.getWorkoutById(Number(req.params.id), req.userId);
      return res.status(200).json({
        success: true,
        workout,
      });
    } catch (error) {
      next(error);
    }
  },

  async create(req, res, next) {
    try {
      const workout = await WorkoutService.createWorkout(req.userId, req.body);
      return res.status(201).json({
        success: true,
        message: 'Ficha de treino criada com sucesso!',
        workout,
      });
    } catch (error) {
      next(error);
    }
  },

  async update(req, res, next) {
    try {
      const workout = await WorkoutService.updateWorkout(Number(req.params.id), req.userId, req.body);
      return res.status(200).json({
        success: true,
        message: 'Ficha de treino atualizada com sucesso!',
        workout,
      });
    } catch (error) {
      next(error);
    }
  },

  async delete(req, res, next) {
    try {
      await WorkoutService.deleteWorkout(Number(req.params.id), req.userId);
      return res.status(200).json({
        success: true,
        message: 'Ficha de treino removida com sucesso.',
      });
    } catch (error) {
      next(error);
    }
  },

  async addExercise(req, res, next) {
    try {
      const exercise = await WorkoutService.addExercise(Number(req.params.id), req.userId, req.body);
      return res.status(201).json({
        success: true,
        message: 'Exercício adicionado à ficha com sucesso!',
        exercise,
      });
    } catch (error) {
      next(error);
    }
  },

  async removeExercise(req, res, next) {
    try {
      await WorkoutService.removeExercise(Number(req.params.id), req.userId, Number(req.params.exerciseId));
      return res.status(200).json({
        success: true,
        message: 'Exercício removido da ficha com sucesso.',
      });
    } catch (error) {
      next(error);
    }
  },

  async generate(req, res, next) {
    try {
      const workouts = await WorkoutService.generateSmartWorkout(req.userId, req.body);
      return res.status(201).json({
        success: true,
        message: `${workouts.length} ficha(s) de treino gerada(s) com IA com sucesso!`,
        workouts,
      });
    } catch (error) {
      next(error);
    }
  },
};

module.exports = WorkoutController;
