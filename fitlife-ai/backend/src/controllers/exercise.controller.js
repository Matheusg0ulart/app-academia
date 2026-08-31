const ExerciseService = require('../services/exercise.service');

const ExerciseController = {
  async list(req, res, next) {
    try {
      const filters = {
        muscleGroup: req.query.muscle_group || req.query.muscleGroup,
        search: req.query.search,
      };
      const exercises = await ExerciseService.listExercises(req.userId, filters);
      return res.status(200).json({
        success: true,
        count: exercises.length,
        exercises,
      });
    } catch (error) {
      next(error);
    }
  },

  async getById(req, res, next) {
    try {
      const exercise = await ExerciseService.getById(Number(req.params.id));
      return res.status(200).json({
        success: true,
        exercise,
      });
    } catch (error) {
      next(error);
    }
  },

  async create(req, res, next) {
    try {
      const exercise = await ExerciseService.createCustom(req.userId, req.body);
      return res.status(201).json({
        success: true,
        message: 'Exercício criado com sucesso!',
        exercise,
      });
    } catch (error) {
      next(error);
    }
  },

  async getMuscleGroups(req, res, next) {
    try {
      const groups = await ExerciseService.getMuscleGroups();
      return res.status(200).json({
        success: true,
        groups,
      });
    } catch (error) {
      next(error);
    }
  },
};

module.exports = ExerciseController;

