const ExerciseModel = require('../models/exercise.model');

const ExerciseService = {
  async listExercises(userId, filters = {}) {
    return ExerciseModel.findAll(userId, filters);
  },

  async getById(id) {
    const exercise = await ExerciseModel.findById(id);
    if (!exercise) {
      const error = new Error('Exercício não encontrado.');
      error.statusCode = 404;
      throw error;
    }
    return exercise;
  },

  async createCustom(userId, data) {
    const { name, muscle_group, description, instructions } = data;
    if (!name || !muscle_group) {
      const error = new Error('Nome e grupo muscular são obrigatórios.');
      error.statusCode = 400;
      throw error;
    }
    return ExerciseModel.create({
      name: name.trim(),
      muscle_group: muscle_group.trim().toLowerCase(),
      description,
      instructions,
      userId,
    });
  },

  async getMuscleGroups() {
    return ExerciseModel.getMusclGroups();
  },
};

module.exports = ExerciseService;

