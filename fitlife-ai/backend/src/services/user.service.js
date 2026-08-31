const UserModel = require('../models/user.model');
const WorkoutLogModel = require('../models/workout-log.model');
const MeasurementModel = require('../models/measurement.model');
const NutritionService = require('./nutrition.service');
const CalculatorService = require('./calculator.service');

const UserService = {
  async getProfile(userId) {
    const user = await UserModel.findById(userId);
    if (!user) {
      const error = new Error('Usuário não encontrado.');
      error.statusCode = 404;
      throw error;
    }
    return user;
  },

  async updateProfile(userId, data) {
    const user = await UserModel.update(userId, data);
    if (!user) {
      const error = new Error('Usuário não encontrado.');
      error.statusCode = 404;
      throw error;
    }
    return user;
  },

  async getEvolutionReport(userId) {
    const [user, workouts, measurements, nutrition] = await Promise.all([
      this.getProfile(userId),
      WorkoutLogModel.findByUser(userId, { limit: 50 }),
      MeasurementModel.findByUser(userId, 50),
      NutritionService.getDailySummary(userId).catch(() => null),
    ]);

    // Métricas Fisiológicas
    const weight = user.weight_kg || 75;
    const height = user.height_cm || 175;
    const age = user.age || 25;
    const sex = user.sex || 'M';

    const heightM = height / 100.0;
    const bmiVal = Number((weight / (heightM * heightM)).toFixed(1));
    let bmiClass = 'Peso Normal';
    if (bmiVal < 18.5) bmiClass = 'Abaixo do peso';
    else if (bmiVal >= 25 && bmiVal < 30) bmiClass = 'Sobrepeso';
    else if (bmiVal >= 30) bmiClass = 'Obesidade';

    const tmbTdeeCalc = CalculatorService.calculateTmbAndTdee({
      age,
      sex,
      weight_kg: weight,
      height_cm: height,
      activity_level: user.activity_level || 'moderate',
      goal: user.goal || 'hypertrophy',
    });

    const tmb = tmbTdeeCalc.tmb;
    const tdee = tmbTdeeCalc.tdee;

    // Estatísticas de Treino
    const totalWorkouts = workouts.length;
    let totalVolumeKg = 0;
    let totalMinutes = 0;

    for (const w of workouts) {
      totalMinutes += w.durationMin || 45;
      if (Array.isArray(w.sets)) {
        for (const s of w.sets) {
          totalVolumeKg += (s.weightKg || 0) * (s.repsDone || 0);
        }
      }
    }

    // Evolução de Peso
    const firstWeight = measurements.length > 1 ? measurements[measurements.length - 1].weightKg : weight;
    const currentWeight = measurements.length > 0 ? measurements[0].weightKg : weight;
    const weightDelta = currentWeight && firstWeight ? currentWeight - firstWeight : 0;

    // Texto formatado para WhatsApp / Impressão
    const formattedText = `📊 *RELATÓRIO DE EVOLUÇÃO — FITLIFE AI*
👤 *Aluno(a):* ${user.name}
🎯 *Objetivo:* ${user.goal || 'Hipertrofia e Saúde'}
📅 *Gerado em:* ${new Date().toLocaleDateString('pt-BR')}

⚖️ *ANTROPOMETRIA & METABOLISMO*
• Peso Inicial: ${firstWeight} kg ➔ Peso Atual: ${currentWeight} kg (${weightDelta >= 0 ? '+' : ''}${weightDelta.toFixed(1)} kg)
• IMC: ${bmiVal} (${bmiClass})
• Taxa Metabólica Basal (TMB): ${tmb} kcal
• Gasto Calórico Diário (TDEE): ${tdee} kcal

🏋️ *TREINOS & DESEMPENHO*
• Sessões Realizadas: ${totalWorkouts} treinos
• Tempo Total de Treino: ${Math.round(totalMinutes / 60)} horas (${totalMinutes} min)
• Volume Total Levantado: ${Math.round(totalVolumeKg).toLocaleString('pt-BR')} kg

🥗 *NUTRIÇÃO DIÁRIA (MÉDIA)*
• Meta Calórica: ${nutrition?.targetCalories || 2200} kcal
• Meta Proteica: ${nutrition?.targetProteinG || 140} g
• Consumo Registrado Hoje: ${nutrition?.totalCalories || 0} kcal (${nutrition?.totalProtein || 0}g proteína)

🚀 _Gerado automaticamente pelo aplicativo FitLife AI._`;

    return {
      user: {
        id: user.id,
        name: user.name,
        email: user.email,
        goal: user.goal,
        weight_kg: weight,
        height_cm: height,
        age,
        sex,
      },
      metabolism: {
        bmi: bmiVal,
        bmiClassification: bmiClass,
        bmr: tmb,
        tdee,
      },
      workoutsSummary: {
        totalWorkouts,
        totalMinutes,
        totalVolumeKg: Math.round(totalVolumeKg),
      },
      evolution: {
        firstWeight,
        currentWeight,
        weightDelta: Number(weightDelta.toFixed(1)),
        measurementsCount: measurements.length,
      },
      formattedText,
    };
  },
};

module.exports = UserService;
