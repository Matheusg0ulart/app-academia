/**
 * Serviço de Cálculos Fisiológicos e Metabólicos do FitLife AI.
 * Implementa fórmulas científicas padrão ouro para estimativas energéticas.
 */

const MET_TABLE = {
  walking_light: { name: 'Caminhada leve (4 km/h)', met: 3.0 },
  walking_fast: { name: 'Caminhada rápida (6 km/h)', met: 4.3 },
  running_moderate: { name: 'Corrida moderada (8-10 km/h)', met: 8.0 },
  running_fast: { name: 'Corrida intensa (>10 km/h)', met: 11.5 },
  cycling_moderate: { name: 'Bicicleta moderada', met: 6.0 },
  cycling_fast: { name: 'Bicicleta intensa', met: 8.5 },
  weightlifting_moderate: { name: 'Musculação moderada', met: 4.5 },
  weightlifting_heavy: { name: 'Musculação pesada / alta intensidade', met: 6.0 },
  elliptical: { name: 'Elíptico', met: 5.0 },
  jump_rope: { name: 'Pular corda', met: 10.0 },
  swimming: { name: 'Natação moderada', met: 7.0 },
  hiit: { name: 'Treino Funcional / HIIT', met: 8.5 },
};

const ACTIVITY_MULTIPLIERS = {
  sedentary: 1.2,          // Sedentário (pouco ou nenhum exercício)
  light: 1.375,            // Levemente ativo (exercício 1-3 dias/semana)
  moderate: 1.55,          // Moderadamente ativo (exercício 3-5 dias/semana)
  very_active: 1.725,      // Muito ativo (exercício 6-7 dias/semana)
  extra_active: 1.9,       // Extremamente ativo (atleta / treino 2x dia)
};

const CalculatorService = {
  /**
   * Calcula a Taxa Metabólica Basal (TMB) usando Mifflin-St Jeor e Harris-Benedict.
   * @param {{ age: number, sex: string, weight_kg: number, height_cm: number, goal?: string, activity_level?: string }} params
   */
  calculateTmbAndTdee(params) {
    const age = Number(params.age || 25);
    const isMale = (params.sex || 'male').toLowerCase().startsWith('m') || (params.sex || '').toLowerCase() === 'homem';
    const weight = Number(params.weight_kg || 70);
    const height = Number(params.height_cm || 170);
    const activityLevel = params.activity_level || 'moderate';
    const goal = params.goal || 'hypertrophy';

    // 1. Fórmula Mifflin-St Jeor (Padrão mais preciso atual)
    const tmbMifflin = isMale
      ? 10 * weight + 6.25 * height - 5 * age + 5
      : 10 * weight + 6.25 * height - 5 * age - 161;

    // 2. Fórmula Harris-Benedict revisada
    const tmbHarris = isMale
      ? 88.362 + 13.397 * weight + 4.799 * height - 5.677 * age
      : 447.593 + 9.247 * weight + 3.098 * height - 4.330 * age;

    const tmb = Math.round(tmbMifflin);

    // 3. TDEE (Gasto Energético Total Diário)
    const multiplier = ACTIVITY_MULTIPLIERS[activityLevel] || 1.55;
    const tdee = Math.round(tmb * multiplier);

    // 4. Meta calórica recomendada de acordo com o objetivo
    let recommendedCalories = tdee;
    if (goal === 'weight_loss' || goal === 'emagrecimento') {
      recommendedCalories = Math.max(1200, Math.round(tdee - 450));
    } else if (goal === 'hypertrophy' || goal === 'hipertrofia' || goal === 'ganho_massa') {
      recommendedCalories = Math.round(tdee + 350);
    }

    // 5. Distribuição de Macronutrientes sugerida
    const proteinG = Math.round(weight * 2.0); // 2g por kg
    const fatG = Math.round(weight * 0.9);      // 0.9g por kg
    const caloriesFromProteinAndFat = proteinG * 4 + fatG * 9;
    const carbsG = Math.max(50, Math.round((recommendedCalories - caloriesFromProteinAndFat) / 4));

    // 6. IMC (Índice de Massa Corporal)
    const heightM = height / 100;
    const bmi = Number((weight / (heightM * heightM)).toFixed(1));
    let bmiClassification = 'Normal';
    if (bmi < 18.5) bmiClassification = 'Abaixo do peso';
    else if (bmi < 25.0) bmiClassification = 'Peso normal / Saudável';
    else if (bmi < 30.0) bmiClassification = 'Sobrepeso';
    else if (bmi < 35.0) bmiClassification = 'Obesidade Grau I';
    else bmiClassification = 'Obesidade Grau II+';

    return {
      tmb,
      tmb_harris_benedict: Math.round(tmbHarris),
      tdee,
      recommendedCalories,
      activityLevel,
      goal,
      bmi,
      bmiClassification,
      macros: {
        proteinG,
        carbsG,
        fatG,
        proteinKcal: proteinG * 4,
        carbsKcal: carbsG * 4,
        fatKcal: fatG * 9,
      },
      disclaimer: 'Os valores são estimativas fisiológicas calculadas por fórmulas metabólicas reconhecidas.',
    };
  },

  /**
   * Calcula o gasto calórico de um exercício específico com base no MET.
   * Gasto (kcal) = MET × Peso (kg) × (Duração em minutos / 60)
   * @param {{ activityKey: string, weightKg: number, durationMin: number, intensityMultiplier?: number }} data
   */
  calculateExerciseCalories(data) {
    const { activityKey, weightKg, durationMin, intensityMultiplier } = data;
    const weight = Number(weightKg || 70);
    const duration = Number(durationMin || 30);
    const activity = MET_TABLE[activityKey] || { name: 'Atividade Geral', met: 5.0 };
    const intensity = Number(intensityMultiplier || 1.0);

    const baseMet = activity.met * intensity;
    const durationHours = duration / 60;
    const estimatedCalories = Math.round(baseMet * weight * durationHours);

    return {
      activityName: activity.name,
      met: baseMet,
      durationMin: duration,
      weightKg: weight,
      estimatedCaloriesKcal: estimatedCalories,
      disclaimer: 'O gasto calórico real pode variar conforme fatores individuais e intensidade real.',
    };
  },

  getAvailableActivities() {
    return Object.entries(MET_TABLE).map(([key, value]) => ({
      key,
      name: value.name,
      baseMet: value.met,
    }));
  },

  /**
   * Simula a projeção de tempo e peso semana a semana para perda ou ganho de peso.
   * 1 kg de gordura corporal ≈ 7.700 kcal
   * @param {{ currentWeight: number, targetWeight: number, tdee?: number, dailyDeficitKcal?: number }} params
   */
  simulateWeightProjection(params) {
    const currentWeight = Number(params.currentWeight || params.current_weight || 80.0);
    const targetWeight = Number(params.targetWeight || params.target_weight || 74.0);
    const tdee = Number(params.tdee || 2400);
    const isWeightLoss = targetWeight < currentWeight;

    // Déficit diário padrão (500 kcal/dia = ~0.45kg/semana)
    const dailyDeltaKcal = Math.abs(Number(params.dailyDeficitKcal || params.daily_deficit_kcal || 500));
    const weeklyDeltaKg = (dailyDeltaKcal * 7) / 7700.0;

    const totalWeightToChange = Math.abs(currentWeight - targetWeight);
    const totalWeeks = weeklyDeltaKg > 0 ? Math.ceil(totalWeightToChange / weeklyDeltaKg) : 12;

    const targetDate = new Date();
    targetDate.setDate(targetDate.getDate() + totalWeeks * 7);

    // Geração da curva semana a semana
    const weeklyProjection = [];
    let runningWeight = currentWeight;

    for (let week = 0; week <= totalWeeks; week++) {
      const pointDate = new Date();
      pointDate.setDate(pointDate.getDate() + week * 7);

      weeklyProjection.push({
        week,
        date: pointDate.toISOString().split('T')[0],
        projectedWeightKg: Number(runningWeight.toFixed(2)),
      });

      if (isWeightLoss) {
        runningWeight = Math.max(targetWeight, runningWeight - weeklyDeltaKg);
      } else {
        runningWeight = Math.min(targetWeight, runningWeight + weeklyDeltaKg);
      }
    }

    const recommendedIntakeKcal = isWeightLoss
      ? Math.max(1200, tdee - dailyDeltaKcal)
      : tdee + dailyDeltaKcal;

    return {
      currentWeightKg: currentWeight,
      targetWeightKg: targetWeight,
      isWeightLoss,
      dailyDeltaKcal,
      weeklyRateKg: Number(weeklyDeltaKg.toFixed(2)),
      totalWeeks,
      estimatedDays: totalWeeks * 7,
      targetDate: targetDate.toISOString().split('T')[0],
      recommendedIntakeKcal,
      projection: weeklyProjection,
      tips: isWeightLoss
        ? [
            'Mantenha o consumo de proteínas alto (1.6 a 2.2g/kg) para preservar massa magra.',
            'Beba ao menos 35ml de água por kg de peso corporal.',
            'Combine treino de musculação com 2 a 3 sessões de cardio por semana.',
          ]
        : [
            'Priorize superávit limpo com alimentos de alta densidade nutricional.',
            'Garanta sono de qualidade (7 a 9h) para maximizar a síntese proteica.',
            'Treine com sobrecarga progressiva para converter as calorias extras em massa muscular.',
          ],
    };
  },
};

module.exports = CalculatorService;

