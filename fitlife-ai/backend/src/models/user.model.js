const db = require('../config/db');

/**
 * Repository de usuários.
 * Todas as queries de acesso a dados da tabela `users`.
 */
const UserModel = {
  /**
   * Busca um usuário pelo e-mail. Usado no login.
   * @param {string} email
   */
  async findByEmail(email) {
    const { rows } = await db.query(
      `SELECT id, name, email, password_hash, age, sex,
              weight_kg, height_cm, goal, activity_level,
              created_at, updated_at
         FROM users
        WHERE email = $1
        LIMIT 1`,
      [email]
    );
    return rows[0] || null;
  },

  /**
   * Busca um usuário pelo ID. Não retorna password_hash.
   * @param {number} id
   */
  async findById(id) {
    const { rows } = await db.query(
      `SELECT id, name, email, age, sex,
              weight_kg, height_cm, goal, activity_level,
              created_at, updated_at
         FROM users
        WHERE id = $1
        LIMIT 1`,
      [id]
    );
    return rows[0] || null;
  },

  /**
   * Cria um novo usuário.
   * @param {{ name, email, password_hash, age?, sex?, weight_kg?, height_cm?, goal?, activity_level? }} data
   */
  async create(data) {
    const { name, email, password_hash, age, sex, weight_kg, height_cm, goal, activity_level } = data;
    const { rows } = await db.query(
      `INSERT INTO users (name, email, password_hash, age, sex, weight_kg, height_cm, goal, activity_level)
       VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9)
       RETURNING id, name, email, age, sex, weight_kg, height_cm, goal, activity_level, created_at`,
      [name, email, password_hash, age ?? null, sex ?? null, weight_kg ?? null, height_cm ?? null, goal ?? null, activity_level ?? null]
    );
    return rows[0];
  },

  /**
   * Atualiza campos do perfil do usuário.
   * @param {number} id
   * @param {{ name?, age?, sex?, weight_kg?, height_cm?, goal?, activity_level? }} data
   */
  async update(id, data) {
    const fields = [];
    const values = [];
    let idx = 1;

    const allowed = ['name', 'age', 'sex', 'weight_kg', 'height_cm', 'goal', 'activity_level'];
    for (const key of allowed) {
      if (data[key] !== undefined) {
        fields.push(`${key} = $${idx++}`);
        values.push(data[key]);
      }
    }

    if (fields.length === 0) return this.findById(id);

    values.push(id);
    const { rows } = await db.query(
      `UPDATE users SET ${fields.join(', ')}
       WHERE id = $${idx}
       RETURNING id, name, email, age, sex, weight_kg, height_cm, goal, activity_level, updated_at`,
      values
    );
    return rows[0] || null;
  },

  /**
   * Verifica se um e-mail já está cadastrado.
   * @param {string} email
   */
  async emailExists(email) {
    const { rows } = await db.query(
      'SELECT 1 FROM users WHERE email = $1 LIMIT 1',
      [email]
    );
    return rows.length > 0;
  },
};

module.exports = UserModel;
