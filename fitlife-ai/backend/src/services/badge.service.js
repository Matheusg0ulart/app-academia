// backend/src/services/badge.service.js
//
// Sistema de Gamificação & Conquistas (Badges) do FitLife AI

const WorkoutLogModel = require('../models/workout-log.model');
const MeasurementModel = require('../models/measurement.model');
const NutritionService = require('./nutrition.service');

const ALL_BADGES = [
  {
    id: 'first_workout',
    title: 'Primeiro Passo',
    description: 'Conclua sua primeira sessão de treino.',
    category: 'workout',
    tier: 'bronze',
    icon: 'fitness_center',
    xp: 50,
  },
  {
    id: 'streak_3',
    title: 'Foco de Ferro',
    description: 'Realize pelo menos 3 sessões de treino.',
    category: 'workout',
    tier: 'silver',
    icon: 'local_fire_department',
    xp: 150,
  },
  {
    id: 'streak_10',
    title: 'Hábito Inquebrável',
    description: 'Complete 10 sessões de treino no aplicativo.',
    category: 'workout',
    tier: 'gold',
    icon: 'emoji_events',
    xp: 500,
  },
  {
    id: 'first_measurement',
    title: 'No Caminho da Evolução',
    description: 'Cadastre sua primeira medição de peso ou circunferências.',
    category: 'evolution',
    tier: 'bronze',
    icon: 'monitor_weight',
    xp: 50,
  },
  {
    id: 'first_meal',
    title: 'Nutrição Consciente',
    description: 'Registre sua primeira refeição no diário alimentar.',
    category: 'nutrition',
    tier: 'bronze',
    icon: 'restaurant',
    xp: 50,
  },
  {
    id: 'club_100kg',
    title: 'Clube dos 100 kg',
    description: 'Levante 100 kg ou mais em qualquer exercício.',
    category: 'strength',
    tier: 'gold',
    icon: 'military_tech',
    xp: 300,
  },
  {
    id: 'water_master',
    title: 'Mestre da Hidratação',
    description: 'Acompanhe seu consumo diário de água com consistência.',
    category: 'health',
    tier: 'silver',
    icon: 'water_drop',
    xp: 100,
  },
];

const BadgeService = {
  async getUserBadges(userId) {
    const [workouts, measurements, nutritionSummary] = await Promise.all([
      WorkoutLogModel.findByUser(userId, { limit: 100 }),
      MeasurementModel.findByUser(userId, 50),
      NutritionService.getDailySummary(userId).catch(() => null),
    ]);

    const totalWorkouts = workouts.length;
    const totalMeasurements = measurements.length;
    const hasMeals = nutritionSummary && nutritionSummary.meals && nutritionSummary.meals.length > 0;

    // Verifica carga máxima em qualquer série registrada
    let maxWeightLifted = 0;
    for (const w of workouts) {
      if (Array.isArray(w.sets)) {
        for (const s of w.sets) {
          if (s.weightKg && s.weightKg > maxWeightLifted) {
            maxWeightLifted = s.weightKg;
          }
        }
      }
    }

    const badges = ALL_BADGES.map((b) => {
      let isUnlocked = false;
      let progressPct = 0;
      let currentProgress = '0/1';

      if (b.id === 'first_workout') {
        isUnlocked = totalWorkouts >= 1;
        progressPct = Math.min(100, Math.round((totalWorkouts / 1) * 100));
        currentProgress = `${Math.min(1, totalWorkouts)}/1`;
      } else if (b.id === 'streak_3') {
        isUnlocked = totalWorkouts >= 3;
        progressPct = Math.min(100, Math.round((totalWorkouts / 3) * 100));
        currentProgress = `${Math.min(3, totalWorkouts)}/3`;
      } else if (b.id === 'streak_10') {
        isUnlocked = totalWorkouts >= 10;
        progressPct = Math.min(100, Math.round((totalWorkouts / 10) * 100));
        currentProgress = `${Math.min(10, totalWorkouts)}/10`;
      } else if (b.id === 'first_measurement') {
        isUnlocked = totalMeasurements >= 1;
        progressPct = Math.min(100, Math.round((totalMeasurements / 1) * 100));
        currentProgress = `${Math.min(1, totalMeasurements)}/1`;
      } else if (b.id === 'first_meal') {
        isUnlocked = !!hasMeals;
        progressPct = hasMeals ? 100 : 0;
        currentProgress = hasMeals ? '1/1' : '0/1';
      } else if (b.id === 'club_100kg') {
        isUnlocked = maxWeightLifted >= 100;
        progressPct = Math.min(100, Math.round((maxWeightLifted / 100) * 100));
        currentProgress = `${Math.min(100, Math.round(maxWeightLifted))}kg/100kg`;
      } else if (b.id === 'water_master') {
        isUnlocked = true; // Disponível para tracking
        progressPct = 100;
        currentProgress = 'Ativo';
      }

      return {
        ...b,
        isUnlocked,
        progressPct,
        currentProgress,
      };
    });

    const totalXp = badges.filter((b) => b.isUnlocked).reduce((sum, b) => sum + b.xp, 0);
    const userLevel = Math.floor(totalXp / 200) + 1;
    const nextLevelXp = userLevel * 200;

    return {
      userLevel,
      totalXp,
      nextLevelXp,
      unlockedCount: badges.filter((b) => b.isUnlocked).length,
      totalCount: badges.length,
      badges,
    };
  },
};

module.exports = BadgeService;

