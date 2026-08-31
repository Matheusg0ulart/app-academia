const NutritionModel = require('../models/nutrition.model');
const UserModel = require('../models/user.model');
const CalculatorService = require('./calculator.service');

const NutritionService = {
  async logMeal(userId, data) {
    const { meal_type, mealType, description, calories_kcal, caloriesKcal, protein_g, proteinG, carbs_g, carbsG, fat_g, fatG, logged_date, loggedDate } = data;
    const targetMealType = meal_type || mealType || 'lunch';

    return NutritionModel.create({
      userId,
      mealType: targetMealType,
      description,
      caloriesKcal: calories_kcal != null ? calories_kcal : caloriesKcal,
      proteinG: protein_g != null ? protein_g : proteinG,
      carbsG: carbs_g != null ? carbs_g : carbsG,
      fatG: fat_g != null ? fat_g : fatG,
      loggedDate: logged_date || loggedDate,
    });
  },

  async getDailySummary(userId, date) {
    const targetDate = date || new Date().toISOString().split('T')[0];
    const summary = await NutritionModel.getDailySummary(userId, targetDate);

    // Busca metas do usuário
    const user = await UserModel.findById(userId);
    let targetCalories = 2200;
    let targetProtein = 140;
    let targetCarbs = 250;
    let targetFat = 65;

    if (user && user.weight_kg && user.height_cm && user.age && user.sex) {
      const calc = CalculatorService.calculateTmbAndTdee({
        age: user.age,
        sex: user.sex,
        weight_kg: user.weight_kg,
        height_cm: user.height_cm,
        goal: user.goal,
        activity_level: user.activity_level,
      });
      targetCalories = calc.recommendedCalories;
      targetProtein = calc.macros.proteinG;
      targetCarbs = calc.macros.carbsG;
      targetFat = calc.macros.fatG;
    }

    const remainingCalories = Math.max(0, Math.round(targetCalories - summary.totalCalories));

    return {
      ...summary,
      targets: {
        calories: targetCalories,
        protein: targetProtein,
        carbs: targetCarbs,
        fat: targetFat,
      },
      remainingCalories,
      progressPercentage: Math.min(100, Math.round((summary.totalCalories / (targetCalories || 1)) * 100)),
    };
  },

  async getHistory(userId, days = 7) {
    return NutritionModel.getHistory(userId, Number(days));
  },

  async deleteMeal(id, userId) {
    const deleted = await NutritionModel.delete(id, userId);
    if (!deleted) {
      const error = new Error('Refeição não encontrada.');
      error.statusCode = 404;
      throw error;
    }
    return true;
  },
};

module.exports = NutritionService;

