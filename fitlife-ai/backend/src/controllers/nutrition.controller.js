const NutritionService = require('../services/nutrition.service');
const { estimateMealFromText, calculateMealTargets } = require('../services/ai-meal-estimator.service');

const NutritionController = {
  async logMeal(req, res, next) {
    try {
      const meal = await NutritionService.logMeal(req.userId, req.body);
      return res.status(201).json({
        success: true,
        message: 'Refeição registrada com sucesso!',
        meal,
      });
    } catch (error) {
      next(error);
    }
  },

  async getDailySummary(req, res, next) {
    try {
      const date = req.query.date;
      const summary = await NutritionService.getDailySummary(req.userId, date);
      return res.status(200).json({
        success: true,
        summary,
      });
    } catch (error) {
      next(error);
    }
  },

  async getHistory(req, res, next) {
    try {
      const days = req.query.days || 7;
      const history = await NutritionService.getHistory(req.userId, days);
      return res.status(200).json({
        success: true,
        history,
      });
    } catch (error) {
      next(error);
    }
  },

  async deleteMeal(req, res, next) {
    try {
      await NutritionService.deleteMeal(Number(req.params.id), req.userId);
      return res.status(200).json({
        success: true,
        message: 'Refeição removida com sucesso.',
      });
    } catch (error) {
      next(error);
    }
  },

  // ═══════════════════════════════════════════════════════════
  // RECURSOS AVANÇADOS DE NUTRIÇÃO
  // ═══════════════════════════════════════════════════════════

  async estimateFromText(req, res, next) {
    try {
      const { text } = req.body;
      if (!text || text.trim().length < 2) {
        return res.status(400).json({ error: 'Informe a descrição do seu prato.' });
      }

      const estimation = estimateMealFromText(text.trim());
      return res.status(200).json({
        success: true,
        ...estimation,
      });
    } catch (error) {
      next(error);
    }
  },

  async getMealTargets(req, res, next) {
    try {
      const summary = await NutritionService.getDailySummary(req.userId);
      const targetCal = summary?.targetCalories || 2200;
      const targetProt = summary?.targetProteinG || 140;
      const targetCarbs = summary?.targetCarbsG || 250;
      const targetFat = summary?.targetFatG || 65;

      const targets = calculateMealTargets(targetCal, targetProt, targetCarbs, targetFat);

      return res.status(200).json({
        success: true,
        dailyTarget: {
          calories: targetCal,
          protein_g: targetProt,
          carbs_g: targetCarbs,
          fat_g: targetFat,
        },
        meals: targets,
      });
    } catch (error) {
      next(error);
    }
  },
};

module.exports = NutritionController;
