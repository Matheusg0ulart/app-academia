const WorkoutModel = require('../models/workout.model');
const WorkoutExerciseModel = require('../models/workout-exercise.model');

const WorkoutService = {
  async listUserWorkouts(userId) {
    return WorkoutModel.findByUser(userId);
  },

  async getWorkoutById(id, userId) {
    const workout = await WorkoutModel.findById(id, userId);
    if (!workout) {
      const error = new Error('Ficha de treino não encontrada.');
      error.statusCode = 404;
      throw error;
    }
    return workout;
  },

  async createWorkout(userId, data) {
    const { name, description, exercises } = data;
    if (!name) {
      const error = new Error('Nome do treino é obrigatório.');
      error.statusCode = 400;
      throw error;
    }

    const workout = await WorkoutModel.create({
      userId,
      name: name.trim(),
      description,
    });

    if (Array.isArray(exercises) && exercises.length > 0) {
      for (let i = 0; i < exercises.length; i++) {
        const ex = exercises[i];
        await WorkoutExerciseModel.create({
          workoutId: workout.id,
          exerciseId: ex.exercise_id || ex.exerciseId,
          sets: ex.sets || 3,
          reps: ex.reps || 10,
          weight_kg: ex.weight_kg || ex.weightKg,
          rest_secs: ex.rest_secs || ex.restSecs || 60,
          notes: ex.notes,
          order_index: ex.order_index != null ? ex.order_index : i,
        });
      }
    }

    return this.getWorkoutById(workout.id, userId);
  },

  async updateWorkout(id, userId, data) {
    const workout = await WorkoutModel.update(id, userId, data);
    if (!workout) {
      const error = new Error('Ficha de treino não encontrada.');
      error.statusCode = 404;
      throw error;
    }
    return workout;
  },

  async deleteWorkout(id, userId) {
    const deleted = await WorkoutModel.delete(id, userId);
    if (!deleted) {
      const error = new Error('Ficha de treino não encontrada.');
      error.statusCode = 404;
      throw error;
    }
    return true;
  },

  async addExercise(workoutId, userId, data) {
    await this.getWorkoutById(workoutId, userId);

    const { exercise_id, exerciseId, sets, reps, weight_kg, weightKg, rest_secs, restSecs, notes, order_index } = data;
    const targetExerciseId = exercise_id || exerciseId;

    if (!targetExerciseId || !sets || !reps) {
      const error = new Error('ID do exercício, séries e repetições são obrigatórios.');
      error.statusCode = 400;
      throw error;
    }

    return WorkoutExerciseModel.create({
      workoutId,
      exerciseId: targetExerciseId,
      sets: Number(sets),
      reps: Number(reps),
      weight_kg: weight_kg || weightKg,
      rest_secs: rest_secs || restSecs || 60,
      notes,
      order_index,
    });
  },

  async removeExercise(workoutId, userId, exerciseItemId) {
    await this.getWorkoutById(workoutId, userId);
    const deleted = await WorkoutExerciseModel.delete(exerciseItemId);
    if (!deleted) {
      const error = new Error('Exercício do treino não encontrado.');
      error.statusCode = 404;
      throw error;
    }
    return true;
  },

  // ═══════════════════════════════════════════════════════════
  // GERADOR INTELIGENTE DE FICHAS DE TREINO (IA / Algoritmo)
  // ═══════════════════════════════════════════════════════════
  async generateSmartWorkout(userId, options = {}) {
    const {
      goal = 'hypertrophy', // 'hypertrophy' | 'fat_loss' | 'strength' | 'conditioning'
      level = 'intermediate', // 'beginner' | 'intermediate' | 'advanced'
      split = 'ppl', // 'full_body' | 'upper_lower' | 'ppl'
    } = options;

    let sets = 3;
    let reps = 10;
    let restSecs = 60;

    if (goal === 'strength') {
      sets = level === 'advanced' ? 5 : 4;
      reps = 6;
      restSecs = 120;
    } else if (goal === 'hypertrophy') {
      sets = level === 'advanced' ? 4 : 3;
      reps = level === 'beginner' ? 10 : 12;
      restSecs = 75;
    } else if (goal === 'fat_loss' || goal === 'conditioning') {
      sets = 3;
      reps = 15;
      restSecs = 45;
    }

    const createdWorkouts = [];

    if (split === 'full_body') {
      const workoutA = await this.createWorkout(userId, {
        name: 'Full Body AI — Corpo Inteiro',
        description: `Treino completo balanceado para ${goal} (${level}).`,
        exercises: [
          { exercise_id: 11, sets, reps, rest_secs: restSecs, notes: 'Agachamento Livre com Barra' },
          { exercise_id: 1, sets, reps, rest_secs: restSecs, notes: 'Supino Reto com Barra' },
          { exercise_id: 6, sets, reps, rest_secs: restSecs, notes: 'Puxada Frontal' },
          { exercise_id: 18, sets, reps, rest_secs: restSecs, notes: 'Desenvolvimento Militar' },
          { exercise_id: 14, sets, reps, rest_secs: restSecs, notes: 'Stiff com Barra' },
          { exercise_id: 25, sets: 3, reps: 20, rest_secs: 45, notes: 'Abdominal Supra' },
        ],
      });
      createdWorkouts.push(workoutA);
    } else if (split === 'upper_lower') {
      const workoutUpper = await this.createWorkout(userId, {
        name: 'Treino A — Upper (Superiores)',
        description: `Membros superiores para ${goal} (${level}).`,
        exercises: [
          { exercise_id: 1, sets, reps, rest_secs: restSecs, notes: 'Supino Reto' },
          { exercise_id: 6, sets, reps, rest_secs: restSecs, notes: 'Puxada Frontal' },
          { exercise_id: 2, sets, reps, rest_secs: restSecs, notes: 'Supino Inclinado' },
          { exercise_id: 7, sets, reps, rest_secs: restSecs, notes: 'Remada Curvada' },
          { exercise_id: 19, sets, reps, rest_secs: restSecs, notes: 'Elevação Lateral' },
          { exercise_id: 21, sets, reps, rest_secs: restSecs, notes: 'Rosca Direta' },
          { exercise_id: 23, sets, reps, rest_secs: restSecs, notes: 'Tríceps Corda' },
        ],
      });

      const workoutLower = await this.createWorkout(userId, {
        name: 'Treino B — Lower (Inferiores & Core)',
        description: `Membros inferiores e abdômen para ${goal} (${level}).`,
        exercises: [
          { exercise_id: 11, sets, reps, rest_secs: restSecs, notes: 'Agachamento Livre' },
          { exercise_id: 12, sets, reps, rest_secs: restSecs, notes: 'Leg Press 45°' },
          { exercise_id: 14, sets, reps, rest_secs: restSecs, notes: 'Stiff com Barra' },
          { exercise_id: 15, sets, reps, rest_secs: restSecs, notes: 'Mesa Flexora' },
          { exercise_id: 17, sets: 4, reps: 15, rest_secs: 45, notes: 'Panturrilha em Pé' },
          { exercise_id: 25, sets: 3, reps: 20, rest_secs: 45, notes: 'Abdominal Crunch' },
        ],
      });

      createdWorkouts.push(workoutUpper, workoutLower);
    } else {
      // PUSH / PULL / LEGS (PPL) - Padrão Ouro
      const push = await this.createWorkout(userId, {
        name: 'Treino A — Push (Peito, Ombros, Tríceps)',
        description: `Foco em empurrar com ênfase em ${goal} (${level}).`,
        exercises: [
          { exercise_id: 1, sets, reps, rest_secs: restSecs, notes: 'Supino Reto com Barra' },
          { exercise_id: 2, sets, reps, rest_secs: restSecs, notes: 'Supino Inclinado com Halteres' },
          { exercise_id: 18, sets, reps, rest_secs: restSecs, notes: 'Desenvolvimento Militar' },
          { exercise_id: 19, sets, reps: reps + 2, rest_secs: 60, notes: 'Elevação Lateral' },
          { exercise_id: 23, sets, reps, rest_secs: 60, notes: 'Tríceps Pulley Corda' },
          { exercise_id: 24, sets, reps, rest_secs: 60, notes: 'Tríceps Testa' },
        ],
      });

      const pull = await this.createWorkout(userId, {
        name: 'Treino B — Pull (Costas, Deltoide Post., Bíceps)',
        description: `Foco em puxar com ênfase em ${goal} (${level}).`,
        exercises: [
          { exercise_id: 6, sets, reps, rest_secs: restSecs, notes: 'Puxada Frontal' },
          { exercise_id: 7, sets, reps, rest_secs: restSecs, notes: 'Remada Curvada com Barra' },
          { exercise_id: 8, sets, reps, rest_secs: restSecs, notes: 'Remada Unilateral Serrote' },
          { exercise_id: 20, sets, reps: reps + 2, rest_secs: 60, notes: 'Crucifixo Invertido' },
          { exercise_id: 21, sets, reps, rest_secs: 60, notes: 'Rosca Direta com Barra W' },
          { exercise_id: 22, sets, reps, rest_secs: 60, notes: 'Rosca Martelo' },
        ],
      });

      const legs = await this.createWorkout(userId, {
        name: 'Treino C — Legs (Pernas & Abdômen)',
        description: `Membros inferiores e abdômen balanceados para ${goal} (${level}).`,
        exercises: [
          { exercise_id: 11, sets, reps, rest_secs: restSecs, notes: 'Agachamento Livre' },
          { exercise_id: 12, sets, reps, rest_secs: restSecs, notes: 'Leg Press 45°' },
          { exercise_id: 13, sets, reps, rest_secs: 60, notes: 'Cadeira Extensora' },
          { exercise_id: 14, sets, reps, rest_secs: restSecs, notes: 'Stiff com Barra' },
          { exercise_id: 15, sets, reps, rest_secs: 60, notes: 'Mesa Flexora' },
          { exercise_id: 17, sets: 4, reps: 15, rest_secs: 45, notes: 'Panturrilha em Pé' },
          { exercise_id: 25, sets: 3, reps: 20, rest_secs: 45, notes: 'Abdominal Crunch' },
        ],
      });

      createdWorkouts.push(push, pull, legs);
    }

    return createdWorkouts;
  },
};

module.exports = WorkoutService;
