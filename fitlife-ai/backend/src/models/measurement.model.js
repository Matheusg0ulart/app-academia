const db = require('../config/db');

/**
 * Repository de medidas corporais e evolução física.
 * Acesso à tabela `body_measurements`.
 */
const MeasurementModel = {
  /**
   * Registra uma nova aferição de medidas corporais.
   * @param {{ userId, measuredAt?, weightKg?, bodyFatPct?, muscleMassKg?, chestCm?, waistCm?, hipCm?, armCm?, thighCm?, notes? }} data
   */
  async create(data) {
    const {
      userId,
      measuredAt,
      weightKg,
      bodyFatPct,
      muscleMassKg,
      chestCm,
      waistCm,
      hipCm,
      armCm,
      thighCm,
      notes,
    } = data;

    const date = measuredAt || new Date().toISOString().split('T')[0];

    const { rows } = await db.query(
      `INSERT INTO body_measurements 
         (user_id, measured_at, weight_kg, body_fat_pct, muscle_mass_kg, chest_cm, waist_cm, hip_cm, arm_cm, thigh_cm, notes)
       VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11)
       ON CONFLICT (user_id, measured_at) 
       DO UPDATE SET 
         weight_kg = EXCLUDED.weight_kg,
         body_fat_pct = EXCLUDED.body_fat_pct,
         muscle_mass_kg = EXCLUDED.muscle_mass_kg,
         chest_cm = EXCLUDED.chest_cm,
         waist_cm = EXCLUDED.waist_cm,
         hip_cm = EXCLUDED.hip_cm,
         arm_cm = EXCLUDED.arm_cm,
         thigh_cm = EXCLUDED.thigh_cm,
         notes = EXCLUDED.notes
       RETURNING id, user_id, measured_at, weight_kg, body_fat_pct, muscle_mass_kg, chest_cm, waist_cm, hip_cm, arm_cm, thigh_cm, notes, created_at`,
      [
        userId,
        date,
        weightKg != null ? Number(weightKg) : null,
        bodyFatPct != null ? Number(bodyFatPct) : null,
        muscleMassKg != null ? Number(muscleMassKg) : null,
        chestCm != null ? Number(chestCm) : null,
        waistCm != null ? Number(waistCm) : null,
        hipCm != null ? Number(hipCm) : null,
        armCm != null ? Number(armCm) : null,
        thighCm != null ? Number(thighCm) : null,
        notes || null,
      ]
    );

    // Se o peso foi atualizado, reflete no perfil do usuário
    if (weightKg != null) {
      await db.query('UPDATE users SET weight_kg = $1 WHERE id = $2', [Number(weightKg), userId]);
    }

    return rows[0];
  },

  /**
   * Lista o histórico de medições do usuário.
   * @param {number} userId
   * @param {number} limit
   */
  async findByUser(userId, limit = 30) {
    const { rows } = await db.query(
      `SELECT id, user_id, measured_at, weight_kg, body_fat_pct, muscle_mass_kg,
              chest_cm, waist_cm, hip_cm, arm_cm, thigh_cm, notes, created_at
         FROM body_measurements
        WHERE user_id = $1
        ORDER BY measured_at DESC
        LIMIT $2`,
      [userId, limit]
    );
    return rows;
  },

  /**
   * Busca a última medição registrada pelo usuário.
   * @param {number} userId
   */
  async getLatest(userId) {
    const { rows } = await db.query(
      `SELECT id, user_id, measured_at, weight_kg, body_fat_pct, muscle_mass_kg,
              chest_cm, waist_cm, hip_cm, arm_cm, thigh_cm, notes, created_at
         FROM body_measurements
        WHERE user_id = $1
        ORDER BY measured_at DESC
        LIMIT 1`,
      [userId]
    );
    return rows[0] || null;
  },

  /**
   * Remove uma medição por ID.
   * @param {number} id
   * @param {number} userId
   */
  async delete(id, userId) {
    const { rowCount } = await db.query(
      `DELETE FROM body_measurements WHERE id = $1 AND user_id = $2`,
      [id, userId]
    );
    return rowCount > 0;
  },
};

module.exports = MeasurementModel;

