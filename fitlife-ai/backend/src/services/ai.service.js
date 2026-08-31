const UserModel = require('../models/user.model');
const WorkoutModel = require('../models/workout.model');
const WorkoutLogModel = require('../models/workout-log.model');
const NutritionService = require('./nutrition.service');
const MeasurementModel = require('../models/measurement.model');
const ExerciseModel = require('../models/exercise.model');
const CalculatorService = require('./calculator.service');

const SAFETY_DISCLAIMER = '\n\n💡 *Lembrete: O FitLife AI fornece orientações educativas e informativas. Para prescrições médicas ou dietas clínicas personalizadas, consulte sempre um médico, nutricionista ou educador físico.*';

const AiService = {
  /**
   * Coleta o contexto relevante do usuário para alimentar a IA.
   */
  async getUserContext(userId) {
    const today = new Date().toISOString().split('T')[0];

    const [user, nutrition, workouts, logs, measurements] = await Promise.all([
      UserModel.findById(userId),
      NutritionService.getDailySummary(userId, today),
      WorkoutModel.findByUser(userId),
      WorkoutLogModel.findByUser(userId, { limit: 5 }),
      MeasurementModel.findByUser(userId, 5),
    ]);

    let tmbAndTdee = null;
    if (user?.weight_kg && user?.height_cm && user?.age) {
      tmbAndTdee = CalculatorService.calculateTmbAndTdee({
        age: user.age,
        sex: user.sex,
        weight_kg: user.weight_kg,
        height_cm: user.height_cm,
        goal: user.goal,
        activity_level: user.activity_level,
      });
    }

    return {
      user: {
        name: user?.name || 'Usuário',
        age: user?.age,
        sex: user?.sex,
        weight_kg: user?.weight_kg,
        height_cm: user?.height_cm,
        goal: user?.goal,
        activity_level: user?.activity_level,
      },
      nutritionToday: {
        date: today,
        consumedCalories: nutrition.totalCalories,
        targetCalories: nutrition.targets.calories,
        remainingCalories: nutrition.remainingCalories,
        proteinG: nutrition.totalProtein,
        targetProteinG: nutrition.targets.protein,
        carbsG: nutrition.totalCarbs,
        targetCarbsG: nutrition.targets.carbs,
        fatG: nutrition.totalFat,
        targetFatG: nutrition.targets.fat,
        mealCount: nutrition.mealCount,
        meals: nutrition.meals.map(m => `${m.meal_type}: ${m.description || 'Refeição'} (${m.calories_kcal} kcal)`),
      },
      workouts: {
        registeredCount: workouts.length,
        routines: workouts.map(w => w.name),
        recentLogsCount: logs.length,
        recentSessions: logs.map(l => ({
          name: l.workout_name,
          date: l.started_at,
          duration: l.duration_min,
        })),
      },
      measurements: {
        latestWeight: measurements[0]?.weight_kg || user?.weight_kg,
        history: measurements.map(m => ({ date: m.measured_at, weight: m.weight_kg })),
      },
      calculations: tmbAndTdee,
    };
  },

  /**
   * Processa a mensagem do usuário com base no contexto real e gera resposta inteligente.
   */
  async processChat(userId, message) {
    if (!message || !message.trim()) {
      const error = new Error('A mensagem não pode estar vazia.');
      error.statusCode = 400;
      throw error;
    }

    const context = await this.getUserContext(userId);
    const query = message.trim();
    const queryLower = query.toLowerCase();

    // 1. Verificação de segurança médica / situações proibidas
    const medicalKeywords = ['remédio', 'anabolizante', 'esteroide', 'lesão grave', 'dor no peito', 'cirurgia', 'fratura', 'medicamento'];
    if (medicalKeywords.some(kw => queryLower.includes(kw))) {
      return {
        reply: `Identifiquei uma dúvida relacionada à saúde clínica ou medicamentos. Por motivos de segurança e responsabilidade ética, o FitLife AI não realiza diagnósticos, prescrições de remédios ou tratamentos para lesões. Recomendo fortemente consultar um médico ou profissional de saúde habilitado para avaliar o seu caso.${SAFETY_DISCLAIMER}`,
        source: 'safety_guardrail',
      };
    }

    // 2. Pergunta sobre calorias / nutrição do dia
    if (queryLower.includes('quantas calorias') || queryLower.includes('consumi hoje') || queryLower.includes('minha alimentação') || queryLower.includes('meus macros')) {
      const n = context.nutritionToday;
      let reply = `Olá, ${context.user.name}! Hoje (${n.date}), você registrou **${n.consumedCalories} kcal** de uma meta estimada de **${n.targetCalories} kcal**.\n\n`;
      reply += `📊 **Divisão de Macronutrientes:**\n`;
      reply += `• Proteínas: **${n.proteinG}g** / meta ${n.targetProteinG}g\n`;
      reply += `• Carboidratos: **${n.carbsG}g** / meta ${n.targetCarbsG}g\n`;
      reply += `• Gorduras: **${n.fatG}g** / meta ${n.targetFatG}g\n\n`;

      if (n.remainingCalories > 0) {
        reply += `Ainda restam **${n.remainingCalories} kcal** para atingir sua meta do dia. Você já registrou ${n.mealCount} refeição(ões).`;
      } else {
        reply += `Você já atingiu sua meta calórica estipulada para hoje. Excelente controle!`;
      }

      return {
        reply: reply + SAFETY_DISCLAIMER,
        source: 'contextual_nutrition',
      };
    }

    // 3. Pergunta sobre tempo reduzido / treino rápido (ex: 30 minutos)
    if (queryLower.includes('30 minutos') || queryLower.includes('pouco tempo') || queryLower.includes('treino rapido') || queryLower.includes('treino rápido') || queryLower.includes('tempo curto')) {
      return {
        reply: `Para um treino eficiente de **30 minutos**, a melhor estratégia é focar em exercícios compostos e técnicas de alta densidade:\n\n` +
          `1. **Aquecimento Dinâmico (3 a 5 min):** Rotações articulares e 1 série leve do primeiro exercício.\n` +
          `2. **Exercícios Compostos (20 min):** Realize de 2 a 3 exercícios principais (ex: Supino, Agachamento ou Remada) em formato de *Super-séries* (alternando grupos musculares opostos) com descanso de 45 a 60 segundos.\n` +
          `3. **Finalizador (5 min):** 1 exercício de isolamento ou circuito metabólico.\n\n` +
          `Essa estrutura mantém o volume e a intensidade altos mesmo em uma janela de tempo reduzida!${SAFETY_DISCLAIMER}`,
        source: 'expert_knowledge',
      };
    }

    // 4. Pergunta sobre evolução / resumo da semana ou do mês
    if (queryLower.includes('como foi meu mês') || queryLower.includes('minha semana') || queryLower.includes('minha evolução') || queryLower.includes('meu progresso')) {
      const w = context.workouts;
      const m = context.measurements;
      let reply = `Aqui está o resumo do seu progresso, ${context.user.name}:\n\n`;
      reply += `🏋️‍♂️ **Frequência de Treino:**\n`;
      reply += `• Você possui **${w.registeredCount}** ficha(s) de treino cadastrada(s).\n`;
      reply += `• Registrou **${w.recentLogsCount}** sessão(ões) recente(s) no aplicativo.\n\n`;

      reply += `⚖️ **Evolução Corporal:**\n`;
      if (m.latestWeight) {
        reply += `• Peso mais recente registrado: **${m.latestWeight} kg**.\n`;
        if (m.history.length > 1) {
          const first = m.history[m.history.length - 1];
          const diff = (m.latestWeight - first.weight).toFixed(1);
          reply += `• Variação registrada no histórico: **${diff > 0 ? '+' : ''}${diff} kg**.\n`;
        }
      } else {
        reply += `• Registre seu peso e medidas na aba *Evolução* para acompanhar gráficos detalhados.\n`;
      }

      reply += `\n🎯 **Objetivo atual:** ${context.user.goal === 'hypertrophy' ? 'Hipertrofia e ganho de massa' : context.user.goal === 'weight_loss' ? 'Emagrecimento e definição' : 'Condicionamento e saúde'}.\n`;
      reply += `Continue consistente nos registros e treinos!`;

      return {
        reply: reply + SAFETY_DISCLAIMER,
        source: 'contextual_progress',
      };
    }

    // 5. Pergunta sobre execução de exercícios (ex: Supino, Agachamento, etc.)
    const exercises = await ExerciseModel.findAll(userId);
    const matchedEx = exercises.find(e => queryLower.includes(e.name.toLowerCase()) || queryLower.includes(e.muscle_group.toLowerCase()));
    if (matchedEx) {
      return {
        reply: `**Dicas de Execução: ${matchedEx.name}**\n\n` +
          `📌 **Grupo Muscular:** ${matchedEx.muscle_group.toUpperCase()}\n` +
          `📝 **Descrição:** ${matchedEx.description || 'Exercício fundamental para desenvolvimento muscular.'}\n\n` +
          `⚙️ **Passo a passo correto:**\n${matchedEx.instructions || 'Mantenha a postura alinhada, execute a fase excêntrica com controle e respire ritmicamente.'}\n\n` +
          `💡 **Dica de ouro:** Priorize sempre a amplitude e a técnica antes de aumentar as cargas para prevenir lesões.${SAFETY_DISCLAIMER}`,
        source: 'exercise_catalog',
      };
    }

    // 6. Resposta Geral Inteligente e Motivacional
    return {
      reply: `Olá, ${context.user.name}! Sou o **FitLife AI**, seu assistente inteligente de treinos, nutrição e saúde.\n\n` +
        `Posso te ajudar com:\n` +
        `• **Treinos:** Organização de fichas, sugestões para pouco tempo, técnicas de execução.\n` +
        `• **Nutrição:** Consulta de calorias consumidas hoje (${context.nutritionToday.consumedCalories} kcal consumidas), distribuição de proteínas, carboidratos e gorduras.\n` +
        `• **Metabolismo:** Cálculo de Taxa Metabólica Basal (sua TMB estimada é de ~${context.calculations?.tmb || 1700} kcal) e TDEE.\n` +
        `• **Evolução:** Acompanhamento de cargas e peso corporal.\n\n` +
        `Qual orientação você gostaria de ver agora?${SAFETY_DISCLAIMER}`,
      source: 'general_assistant',
    };
  },
};

module.exports = AiService;

