const db = require('../config/db');

/**
 * Repository de exercícios.
 * Acesso à tabela `exercises` — sistema e customizados.
 */
const ExerciseModel = {
  /**
   * Lista todos os exercícios do sistema + os criados pelo usuário.
   * @param {number} userId - ID do usuário logado
   * @param {{ muscleGroup?: string, search?: string }} filters
   */
  async findAll(userId, filters = {}) {
    const conditions = ['(is_custom = FALSE OR created_by = $1)'];
    const values = [userId];
    let idx = 2;

    if (filters.muscleGroup) {
      conditions.push(`muscle_group = $${idx++}`);
      values.push(filters.muscleGroup);
    }

    if (filters.search) {
      conditions.push(`name ILIKE $${idx++}`);
      values.push(`%${filters.search}%`);
    }

    const { rows } = await db.query(
      `SELECT id, name, muscle_group, description, instructions, is_custom, created_by, created_at
         FROM exercises
        WHERE ${conditions.join(' AND ')}
        ORDER BY is_custom ASC, name ASC`,
      values
    );
    return rows;
  },

  /**
   * Busca exercícios por grupo muscular.
   * @param {string} muscleGroup
   */
  async findByMuscleGroup(muscleGroup) {
    const { rows } = await db.query(
      `SELECT id, name, muscle_group, description, instructions, is_custom
         FROM exercises
        WHERE muscle_group = $1 AND is_custom = FALSE
        ORDER BY name ASC`,
      [muscleGroup]
    );
    return rows;
  },

  /**
   * Busca um exercício pelo ID.
   * @param {number} id
   */
  async findById(id) {
    const { rows } = await db.query(
      `SELECT id, name, muscle_group, description, instructions, is_custom, created_by, created_at
         FROM exercises
        WHERE id = $1
        LIMIT 1`,
      [id]
    );
    return rows[0] || null;
  },

  /**
   * Cria um exercício customizado vinculado ao usuário.
   * @param {{ name, muscle_group, description?, instructions?, userId }} data
   */
  async create(data) {
    const { name, muscle_group, description, instructions, userId } = data;
    const { rows } = await db.query(
      `INSERT INTO exercises (name, muscle_group, description, instructions, is_custom, created_by)
       VALUES ($1, $2, $3, $4, TRUE, $5)
       RETURNING id, name, muscle_group, description, instructions, is_custom, created_by, created_at`,
      [name, muscle_group, description ?? null, instructions ?? null, userId]
    );
    return rows[0];
  },

  /**
   * Retorna a lista de grupos musculares disponíveis.
   */
  async getMusclGroups() {
    const { rows } = await db.query(
      `SELECT DISTINCT muscle_group
         FROM exercises
        WHERE is_custom = FALSE
        ORDER BY muscle_group ASC`
    );
    return rows.map(r => r.muscle_group);
  },
};

module.exports = ExerciseModel;
