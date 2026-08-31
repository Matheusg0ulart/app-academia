const MeasurementService = require('../services/measurement.service');

const MeasurementController = {
  async log(req, res, next) {
    try {
      const measurement = await MeasurementService.logMeasurement(req.userId, req.body);
      return res.status(201).json({
        success: true,
        message: 'Medidas registradas com sucesso!',
        measurement,
      });
    } catch (error) {
      next(error);
    }
  },

  async getHistory(req, res, next) {
    try {
      const history = await MeasurementService.getHistory(req.userId, req.query.limit);
      return res.status(200).json({
        success: true,
        count: history.length,
        history,
      });
    } catch (error) {
      next(error);
    }
  },

  async getLatest(req, res, next) {
    try {
      const measurement = await MeasurementService.getLatest(req.userId);
      return res.status(200).json({
        success: true,
        measurement,
      });
    } catch (error) {
      next(error);
    }
  },

  async delete(req, res, next) {
    try {
      await MeasurementService.deleteMeasurement(Number(req.params.id), req.userId);
      return res.status(200).json({
        success: true,
        message: 'Medição removida com sucesso.',
      });
    } catch (error) {
      next(error);
    }
  },
};

module.exports = MeasurementController;

