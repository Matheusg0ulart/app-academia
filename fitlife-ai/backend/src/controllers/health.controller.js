const healthService = require('../services/health.service');

/**
 * Controller responsável por responder à rota GET /api/health
 */
const getHealthStatus = (req, res, next) => {
  try {
    const healthStatus = healthService.checkHealth();
    return res.status(200).json(healthStatus);
  } catch (error) {
    next(error);
  }
};

module.exports = {
  getHealthStatus,
};
