const db = require('../config/db');

/**
 * Repository de registros nutricionais e refeições.
 * Acesso à tabela `nutrition_logs`.
 */
const NutritionModel = {
  /**
   * Registra uma refeição do usuário.
   * @param {{ userId, mealType, description, caloriesKcal, proteinG, carbsG, fatG, loggedDate? }} data
   */
  async create(data) {
    const { userId, mealType, description, caloriesKcal, proteinG, carbsG, fatG, loggedDate } = data;
    const date = loggedDate || new Date().toISOString().split('T')[0];
    
    const { rows } = await db.query(
      `INSERT INTO nutrition_logs (user_id, meal_type, description, calories_kcal, protein_g, carbs_g, fat_g, logged_date)
       VALUES ($1, $2, $3, $4, $5, $6, $7, $8)
       RETURNING id, user_id, meal_type, description, calories_kcal, protein_g, carbs_g, fat_g, logged_date, created_at`,
      [
        userId,
        mealType,
        description || null,
        caloriesKcal != null ? Number(caloriesKcal) : 0,
        proteinG != null ? Number(proteinG) : 0,
        carbsG != null ? Number(carbsG) : 0,
        fatG != null ? Number(fatG) : 0,
        date
      ]
    );
    return rows[0];
  },

  /**
   * Busca todas as refeições de um usuário em uma data específica.
   * @param {number} userId
   * @param {string} date - 'YYYY-MM-DD'
   */
  async findByDate(userId, date) {
    const targetDate = date || new Date().toISOString().split('T')[0];
    const { rows } = await db.query(
      `SELECT id, user_id, meal_type, description, calories_kcal, protein_g, carbs_g, fat_g, logged_date, created_at
         FROM nutrition_logs
        WHERE user_id = $1 AND logged_date = $2
        ORDER BY created_at ASC`,
      [userId, targetDate]
    );
    return rows;
  },

  /**
   * Resumo diário de calorias e macronutrientes do usuário.
   * @param {number} userId
   * @param {string} date
   */
  async getDailySummary(userId, date) {
    const targetDate = date || new Date().toISOString().split('T')[0];
    const meals = await this.findByDate(userId, targetDate);

    const summary = meals.reduce(
      (acc, meal) => {
        acc.totalCalories += Number(meal.calories_kcal || 0);
        acc.totalProtein += Number(meal.protein_g || 0);
        acc.totalCarbs += Number(meal.carbs_g || 0);
        acc.totalFat += Number(meal.fat_g || 0);
        return acc;
      },
      {
        date: targetDate,
        totalCalories: 0,
        totalProtein: 0,
        totalCarbs: 0,
        totalFat: 0,
        mealCount: meals.length,
        meals,
      }
    );

    return summary;
  },

  /**
   * Histórico nutricional dos últimos N dias.
   * @param {number} userId
   * @param {number} days
   */
  async getHistory(userId, days = 7) {
    const { rows } = await db.query(
      `SELECT logged_date,
              SUM(calories_kcal)::numeric(7,2) as total_calories,
              SUM(protein_g)::numeric(6,2) as total_protein,
              SUM(carbs_g)::numeric(6,2) as total_carbs,
              SUM(fat_g)::numeric(6,2) as total_fat,
              COUNT(id)::int as meal_count
         FROM nutrition_logs
        WHERE user_id = $1
        GROUP BY logged_date
        ORDER BY logged_date DESC
        LIMIT $2`,
      [userId, days]
    );
    return rows;
  },

  /**
   * Remove uma refeição cadastrada.
   * @param {number} id
   * @param {number} userId
   */
  async delete(id, userId) {
    const { rowCount } = await db.query(
      `DELETE FROM nutrition_logs WHERE id = $1 AND user_id = $2`,
      [id, userId]
    );
    return rowCount > 0;
  }
};

module.exports = NutritionModel;

