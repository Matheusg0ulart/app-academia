const db = require('../config/db');

/**
 * Repository de fichas de treino.
 * Acesso à tabela `workouts` e join com `workout_exercises`.
 */
const WorkoutModel = {
  /**
   * Lista todas as fichas de um usuário.
   * @param {number} userId
   */
  async findByUser(userId) {
    const { rows } = await db.query(
      `SELECT w.id, w.name, w.description, w.created_at, w.updated_at,
              COUNT(we.id)::int AS exercise_count
         FROM workouts w
    LEFT JOIN workout_exercises we ON we.workout_id = w.id
        WHERE w.user_id = $1
     GROUP BY w.id
     ORDER BY w.updated_at DESC`,
      [userId]
    );
    return rows;
  },

  /**
   * Busca uma ficha completa (com exercícios) por ID.
   * @param {number} id
   * @param {number} userId - garante que a ficha pertence ao usuário
   */
  async findById(id, userId) {
    const { rows: workoutRows } = await db.query(
      `SELECT id, name, description, user_id, created_at, updated_at
         FROM workouts
        WHERE id = $1 AND user_id = $2
        LIMIT 1`,
      [id, userId]
    );

    if (!workoutRows[0]) return null;

    const workout = workoutRows[0];

    const { rows: exercises } = await db.query(
      `SELECT we.id, we.exercise_id, we.sets, we.reps, we.weight_kg,
              we.rest_secs, we.notes, we.order_index,
              e.name AS exercise_name, e.muscle_group
         FROM workout_exercises we
         JOIN exercises e ON e.id = we.exercise_id
        WHERE we.workout_id = $1
        ORDER BY we.order_index ASC`,
      [id]
    );

    return { ...workout, exercises };
  },

  /**
   * Cria uma nova ficha de treino.
   * @param {{ userId, name, description? }} data
   */
  async create(data) {
    const { userId, name, description } = data;
    const { rows } = await db.query(
      `INSERT INTO workouts (user_id, name, description)
       VALUES ($1, $2, $3)
       RETURNING id, name, description, user_id, created_at, updated_at`,
      [userId, name, description ?? null]
    );
    return rows[0];
  },

  /**
   * Atualiza nome ou descrição de uma ficha.
   * @param {number} id
   * @param {number} userId
   * @param {{ name?, description? }} data
   */
  async update(id, userId, data) {
    const fields = [];
    const values = [];
    let idx = 1;

    if (data.name !== undefined) {
      fields.push(`name = $${idx++}`);
      values.push(data.name);
    }
    if (data.description !== undefined) {
      fields.push(`description = $${idx++}`);
      values.push(data.description);
    }

    if (fields.length === 0) return this.findById(id, userId);

    values.push(id, userId);
    const { rows } = await db.query(
      `UPDATE workouts SET ${fields.join(', ')}
       WHERE id = $${idx++} AND user_id = $${idx}
       RETURNING id, name, description, updated_at`,
      values
    );
    return rows[0] || null;
  },

  /**
   * Remove uma ficha e seus exercícios em cascata.
   * @param {number} id
   * @param {number} userId
   */
  async delete(id, userId) {
    const { rowCount } = await db.query(
      'DELETE FROM workouts WHERE id = $1 AND user_id = $2',
      [id, userId]
    );
    return rowCount > 0;
  },
};

module.exports = WorkoutModel;
