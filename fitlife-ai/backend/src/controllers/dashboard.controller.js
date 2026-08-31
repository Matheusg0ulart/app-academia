const DashboardService = require('../services/dashboard.service');
const BadgeService = require('../services/badge.service');

const DashboardController = {
  async getSummary(req, res, next) {
    try {
      const summary = await DashboardService.getSummary(req.userId);
      return res.status(200).json({
        success: true,
        summary,
      });
    } catch (error) {
      next(error);
    }
  },

  async getBadges(req, res, next) {
    try {
      const data = await BadgeService.getUserBadges(req.userId);
      return res.status(200).json({
        success: true,
        ...data,
      });
    } catch (error) {
      next(error);
    }
  },
};

module.exports = DashboardController;
