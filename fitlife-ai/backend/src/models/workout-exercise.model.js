const db = require('../config/db');

/**
 * Repository de exercícios dentro de fichas.
 * Acesso à tabela `workout_exercises`.
 */
const WorkoutExerciseModel = {
  /**
   * Lista todos os exercícios de uma ficha, ordenados por order_index.
   * @param {number} workoutId
   */
  async findByWorkout(workoutId) {
    const { rows } = await db.query(
      `SELECT we.id, we.workout_id, we.exercise_id, we.sets, we.reps,
              we.weight_kg, we.rest_secs, we.notes, we.order_index,
              e.name AS exercise_name, e.muscle_group
         FROM workout_exercises we
         JOIN exercises e ON e.id = we.exercise_id
        WHERE we.workout_id = $1
        ORDER BY we.order_index ASC`,
      [workoutId]
    );
    return rows;
  },

  /**
   * Adiciona um exercício a uma ficha.
   * @param {{ workoutId, exerciseId, sets, reps, weight_kg?, rest_secs?, notes?, order_index? }} data
   */
  async create(data) {
    const { workoutId, exerciseId, sets, reps, weight_kg, rest_secs, notes, order_index } = data;
    const { rows } = await db.query(
      `INSERT INTO workout_exercises
         (workout_id, exercise_id, sets, reps, weight_kg, rest_secs, notes, order_index)
       VALUES ($1, $2, $3, $4, $5, $6, $7, $8)
       RETURNING id, workout_id, exercise_id, sets, reps, weight_kg, rest_secs, notes, order_index`,
      [workoutId, exerciseId, sets, reps, weight_kg ?? null, rest_secs ?? null, notes ?? null, order_index ?? 0]
    );
    return rows[0];
  },

  /**
   * Atualiza parâmetros de um exercício dentro da ficha.
   * @param {number} id
   * @param {{ sets?, reps?, weight_kg?, rest_secs?, notes?, order_index? }} data
   */
  async update(id, data) {
    const allowed = ['sets', 'reps', 'weight_kg', 'rest_secs', 'notes', 'order_index'];
    const fields = [];
    const values = [];
    let idx = 1;

    for (const key of allowed) {
      if (data[key] !== undefined) {
        fields.push(`${key} = $${idx++}`);
        values.push(data[key]);
      }
    }

    if (fields.length === 0) return null;

    values.push(id);
    const { rows } = await db.query(
      `UPDATE workout_exercises SET ${fields.join(', ')}
       WHERE id = $${idx}
       RETURNING id, workout_id, exercise_id, sets, reps, weight_kg, rest_secs, notes, order_index`,
      values
    );
    return rows[0] || null;
  },

  /**
   * Remove um exercício de uma ficha.
   * @param {number} id
   */
  async delete(id) {
    const { rowCount } = await db.query(
      'DELETE FROM workout_exercises WHERE id = $1',
      [id]
    );
    return rowCount > 0;
  },

  /**
   * Reordena exercícios de uma ficha recebendo um array de { id, order_index }.
   * @param {{ id: number, order_index: number }[]} items
   */
  async reorder(items) {
    const client = await db.pool.connect();
    try {
      await client.query('BEGIN');
      for (const item of items) {
        await client.query(
          'UPDATE workout_exercises SET order_index = $1 WHERE id = $2',
          [item.order_index, item.id]
        );
      }
      await client.query('COMMIT');
      return true;
    } catch (err) {
      await client.query('ROLLBACK');
      throw err;
    } finally {
      client.release();
    }
  },
};

module.exports = WorkoutExerciseModel;
