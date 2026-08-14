-- ============================================================
-- Migration 007: Registro nutricional
-- ============================================================
-- Permite registrar refeições e acompanhar macronutrientes
-- e calorias diárias do usuário.
-- ============================================================

CREATE TABLE IF NOT EXISTS nutrition_logs (
  id            SERIAL        PRIMARY KEY,
  user_id       INTEGER       NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  logged_date   DATE          NOT NULL DEFAULT CURRENT_DATE,
  meal_type     VARCHAR(20)   NOT NULL CHECK (meal_type IN (
                  'breakfast', 'morning_snack', 'lunch',
                  'afternoon_snack', 'dinner', 'supper', 'other'
                )),
  description   TEXT,
  calories_kcal DECIMAL(7, 2) CHECK (calories_kcal >= 0),
  protein_g     DECIMAL(6, 2) CHECK (protein_g >= 0),
  carbs_g       DECIMAL(6, 2) CHECK (carbs_g >= 0),
  fat_g         DECIMAL(6, 2) CHECK (fat_g >= 0),
  created_at    TIMESTAMPTZ   NOT NULL DEFAULT NOW(),
  updated_at    TIMESTAMPTZ   NOT NULL DEFAULT NOW()
);

-- Índice para buscar logs por usuário e data
CREATE INDEX IF NOT EXISTS idx_nutrition_logs_user_date
  ON nutrition_logs (user_id, logged_date DESC);

-- Trigger: atualiza updated_at automaticamente a cada UPDATE
CREATE TRIGGER trg_nutrition_logs_updated_at
  BEFORE UPDATE ON nutrition_logs
  FOR EACH ROW
  EXECUTE FUNCTION update_updated_at_column();
