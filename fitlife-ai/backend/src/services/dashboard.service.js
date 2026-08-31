const UserModel = require('../models/user.model');
const WorkoutModel = require('../models/workout.model');
const WorkoutLogModel = require('../models/workout-log.model');
const NutritionService = require('./nutrition.service');
const MeasurementModel = require('../models/measurement.model');
const CalculatorService = require('./calculator.service');

const DashboardService = {
  async getSummary(userId) {
    const today = new Date().toISOString().split('T')[0];

    // 1. Dados do usuário
    const user = await UserModel.findById(userId);

    // 2. Nutrição do dia
    const nutrition = await NutritionService.getDailySummary(userId, today);

    // 3. Fichas de treino disponíveis
    const workouts = await WorkoutModel.findByUser(userId);
    const nextWorkout = workouts.length > 0 ? workouts[0] : null;

    // 4. Histórico recente de treinos
    const recentLogs = await WorkoutLogModel.findByUser(userId, { limit: 10, offset: 0 });

    // Contagem de treinos nos últimos 7 dias
    const oneWeekAgo = new Date();
    oneWeekAgo.setDate(oneWeekAgo.getDate() - 7);
    const workoutsThisWeek = recentLogs.filter(
      log => new Date(log.started_at) >= oneWeekAgo && log.finished_at
    ).length;

    // 5. Última medição de peso
    const latestMeasurement = await MeasurementModel.getLatest(userId);
    const currentWeight = latestMeasurement?.weight_kg || user?.weight_kg || null;

    // 6. Resumo inteligente da IA / Dica do dia
    let aiInsight = 'Mantenha o foco na consistência! Treino e boa nutrição são a chave para sua evolução.';
    if (workoutsThisWeek >= 4) {
      aiInsight = `Excelente ritmo! Você já completou ${workoutsThisWeek} treinos esta semana. Continue assim!`;
    } else if (workoutsThisWeek === 0) {
      aiInsight = 'Nova semana, novas metas! Que tal realizar seu primeiro treino hoje?';
    } else {
      aiInsight = `Você já realizou ${workoutsThisWeek} treino(s) nesta semana. Seu próximo treino está programado.`;
    }

    return {
      user: {
        id: user?.id,
        name: user?.name,
        goal: user?.goal,
        currentWeight,
        heightCm: user?.height_cm,
      },
      today,
      nutrition: {
        consumedCalories: nutrition.totalCalories,
        targetCalories: nutrition.targets.calories,
        remainingCalories: nutrition.remainingCalories,
        progressPercentage: nutrition.progressPercentage,
        proteinG: nutrition.totalProtein,
        targetProteinG: nutrition.targets.protein,
        carbsG: nutrition.totalCarbs,
        targetCarbsG: nutrition.targets.carbs,
        fatG: nutrition.totalFat,
        targetFatG: nutrition.targets.fat,
      },
      workouts: {
        thisWeekCount: workoutsThisWeek,
        totalCreated: workouts.length,
        nextWorkout: nextWorkout ? { id: nextWorkout.id, name: nextWorkout.name, exerciseCount: nextWorkout.exercise_count } : null,
      },
      aiInsight,
    };
  },
};

module.exports = DashboardService;

