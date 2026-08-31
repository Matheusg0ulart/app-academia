const CalculatorService = require('../services/calculator.service');
const UserModel = require('../models/user.model');

const CalculatorController = {
  async calculateTmbAndTdee(req, res, next) {
    try {
      let params = { ...req.body, ...req.query };

      if (req.userId && (!params.weight_kg || !params.height_cm)) {
        const user = await UserModel.findById(req.userId);
        if (user) {
          params = {
            age: params.age || user.age || 25,
            sex: params.sex || user.sex || 'male',
            weight_kg: params.weight_kg || user.weight_kg || 70,
            height_cm: params.height_cm || user.height_cm || 170,
            goal: params.goal || user.goal || 'hypertrophy',
            activity_level: params.activity_level || user.activity_level || 'moderate',
          };
        }
      }

      const result = CalculatorService.calculateTmbAndTdee(params);
      return res.status(200).json({
        success: true,
        data: result,
      });
    } catch (error) {
      next(error);
    }
  },

  async calculateExerciseBurn(req, res, next) {
    try {
      const { activity, activityKey, weight_kg, weightKg, duration_min, durationMin, intensity } = req.body;
      const result = CalculatorService.calculateExerciseCalories({
        activityKey: activity || activityKey || 'running_moderate',
        weightKg: weight_kg || weightKg || 70,
        durationMin: duration_min || durationMin || 30,
        intensityMultiplier: intensity || 1.0,
      });
      return res.status(200).json({
        success: true,
        data: result,
      });
    } catch (error) {
      next(error);
    }
  },

  async getActivities(req, res) {
    const activities = CalculatorService.getAvailableActivities();
    return res.status(200).json({
      success: true,
      activities,
    });
  },

  async simulateWeightProjection(req, res, next) {
    try {
      const result = CalculatorService.simulateWeightProjection(req.body);
      return res.status(200).json({
        success: true,
        data: result,
      });
    } catch (error) {
      next(error);
    }
  },
};

module.exports = CalculatorController;
