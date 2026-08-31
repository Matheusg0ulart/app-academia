const MeasurementModel = require('../models/measurement.model');

const MeasurementService = {
  async logMeasurement(userId, data) {
    const {
      measured_at,
      measuredAt,
      weight_kg,
      weightKg,
      body_fat_pct,
      bodyFatPct,
      muscle_mass_kg,
      muscleMassKg,
      chest_cm,
      chestCm,
      waist_cm,
      waistCm,
      hip_cm,
      hipCm,
      arm_cm,
      armCm,
      thigh_cm,
      thighCm,
      notes,
    } = data;

    return MeasurementModel.create({
      userId,
      measuredAt: measured_at || measuredAt,
      weightKg: weight_kg != null ? weight_kg : weightKg,
      bodyFatPct: body_fat_pct != null ? body_fat_pct : bodyFatPct,
      muscleMassKg: muscle_mass_kg != null ? muscle_mass_kg : muscleMassKg,
      chestCm: chest_cm != null ? chest_cm : chestCm,
      waistCm: waist_cm != null ? waist_cm : waistCm,
      hipCm: hip_cm != null ? hip_cm : hipCm,
      armCm: arm_cm != null ? arm_cm : armCm,
      thighCm: thigh_cm != null ? thigh_cm : thighCm,
      notes,
    });
  },

  async getHistory(userId, limit = 30) {
    return MeasurementModel.findByUser(userId, Number(limit));
  },

  async getLatest(userId) {
    return MeasurementModel.getLatest(userId);
  },

  async deleteMeasurement(id, userId) {
    const deleted = await MeasurementModel.delete(id, userId);
    if (!deleted) {
      const error = new Error('Medição não encontrada.');
      error.statusCode = 404;
      throw error;
    }
    return true;
  },
};

module.exports = MeasurementService;

