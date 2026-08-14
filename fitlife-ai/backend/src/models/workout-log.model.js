const db = require('../config/db');

/**
 * Repository de sessões de treino realizadas.
 * Acesso às tabelas `workout_logs` e `set_logs`.
 */
const WorkoutLogModel = {
  /**
   * Cria um novo registro de sessão de treino.
   * @param {{ userId, workoutId?, notes?, rating? }} data
   */
  async create(data) {
    const { userId, workoutId, notes, rating } = data;
    const { rows } = await db.query(
      `INSERT INTO workout_logs (user_id, workout_id, notes, rating)
       VALUES ($1, $2, $3, $4)
       RETURNING id, user_id, workout_id, started_at, notes, rating`,
      [userId, workoutId ?? null, notes ?? null, rating ?? null]
    );
    return rows[0];
  },

  /**
   * Finaliza uma sessão de treino (define finished_at e calcula duração).
   * @param {number} id
   * @param {number} userId
   * @param {{ notes?, rating? }} data
   */
  async finish(id, userId, data = {}) {
    const { rows } = await db.query(
      `UPDATE workout_logs
          SET finished_at   = NOW(),
              duration_min  = EXTRACT(EPOCH FROM (NOW() - started_at)) / 60,
              notes         = COALESCE($3, notes),
              rating        = COALESCE($4, rating)
        WHERE id = $1 AND user_id = $2
        RETURNING id, user_id, workout_id, started_at, finished_at, duration_min, notes, rating`,
      [id, userId, data.notes ?? null, data.rating ?? null]
    );
    return rows[0] || null;
  },

  /**
   * Lista o histórico de treinos de um usuário (mais recentes primeiro).
   * @param {number} userId
   * @param {{ limit?, offset? }} pagination
   */
  async findByUser(userId, { limit = 20, offset = 0 } = {}) {
    const { rows } = await db.query(
      `SELECT wl.id, wl.workout_id, wl.started_at, wl.finished_at,
              wl.duration_min, wl.notes, wl.rating,
              w.name AS workout_name,
              COUNT(sl.id)::int AS total_sets
         FROM workout_logs wl
    LEFT JOIN workouts w  ON w.id  = wl.workout_id
    LEFT JOIN set_logs sl ON sl.workout_log_id = wl.id
        WHERE wl.user_id = $1
     GROUP BY wl.id, w.name
     ORDER BY wl.started_at DESC
        LIMIT $2 OFFSET $3`,
      [userId, limit, offset]
    );
    return rows;
  },

  /**
   * Busca uma sessão completa com todas as séries executadas.
   * @param {number} id
   * @param {number} userId
   */
  async findById(id, userId) {
    const { rows: logRows } = await db.query(
      `SELECT wl.id, wl.workout_id, wl.started_at, wl.finished_at,
              wl.duration_min, wl.notes, wl.rating,
              w.name AS workout_name
         FROM workout_logs wl
    LEFT JOIN workouts w ON w.id = wl.workout_id
        WHERE wl.id = $1 AND wl.user_id = $2
        LIMIT 1`,
      [id, userId]
    );

    if (!logRows[0]) return null;

    const log = logRows[0];

    const { rows: sets } = await db.query(
      `SELECT sl.id, sl.exercise_id, sl.set_number, sl.reps_done,
              sl.weight_kg, sl.duration_secs, sl.is_warmup, sl.notes, sl.logged_at,
              e.name AS exercise_name, e.muscle_group
         FROM set_logs sl
         JOIN exercises e ON e.id = sl.exercise_id
        WHERE sl.workout_log_id = $1
        ORDER BY sl.exercise_id ASC, sl.set_number ASC`,
      [id]
    );

    return { ...log, sets };
  },

  /**
   * Adiciona uma série à sessão de treino ativa.
   * @param {{ workoutLogId, exerciseId, setNumber, repsDone?, weightKg?, durationSecs?, isWarmup?, notes? }} data
   */
  async addSet(data) {
    const {
      workoutLogId, exerciseId, setNumber,
      repsDone, weightKg, durationSecs, isWarmup, notes,
    } = data;
    const { rows } = await db.query(
      `INSERT INTO set_logs
         (workout_log_id, exercise_id, set_number, reps_done, weight_kg, duration_secs, is_warmup, notes)
       VALUES ($1, $2, $3, $4, $5, $6, $7, $8)
       RETURNING id, workout_log_id, exercise_id, set_number, reps_done, weight_kg, duration_secs, is_warmup, notes, logged_at`,
      [workoutLogId, exerciseId, setNumber, repsDone ?? null, weightKg ?? null, durationSecs ?? null, isWarmup ?? false, notes ?? null]
    );
    return rows[0];
  },

  /**
   * Resumo de evolução de um exercício específico (últimas N sessões).
   * @param {number} userId
   * @param {number} exerciseId
   * @param {number} limit
   */
  async getExerciseProgress(userId, exerciseId, limit = 10) {
    const { rows } = await db.query(
      `SELECT sl.set_number, sl.reps_done, sl.weight_kg, wl.started_at
         FROM set_logs sl
         JOIN workout_logs wl ON wl.id = sl.workout_log_id
        WHERE wl.user_id = $1 AND sl.exercise_id = $2 AND sl.is_warmup = FALSE
        ORDER BY wl.started_at DESC
        LIMIT $3`,
      [userId, exerciseId, limit]
    );
    return rows;
  },
};

module.exports = WorkoutLogModel;
