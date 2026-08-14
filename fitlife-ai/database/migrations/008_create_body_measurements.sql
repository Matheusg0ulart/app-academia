-- ============================================================
-- Migration 008: Medidas corporais
-- ============================================================
-- Registra a evolução física do usuário ao longo do tempo:
-- peso, % gordura, circunferências e composição corporal.
-- ============================================================

CREATE TABLE IF NOT EXISTS body_measurements (
  id              SERIAL        PRIMARY KEY,
  user_id         INTEGER       NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  measured_at     DATE          NOT NULL DEFAULT CURRENT_DATE,
  weight_kg       DECIMAL(5, 2) CHECK (weight_kg > 0 AND weight_kg < 500),
  body_fat_pct    DECIMAL(4, 2) CHECK (body_fat_pct >= 0 AND body_fat_pct <= 100),
  muscle_mass_kg  DECIMAL(5, 2) CHECK (muscle_mass_kg >= 0),
  chest_cm        DECIMAL(5, 2) CHECK (chest_cm > 0),
  waist_cm        DECIMAL(5, 2) CHECK (waist_cm > 0),
  hip_cm          DECIMAL(5, 2) CHECK (hip_cm > 0),
  arm_cm          DECIMAL(5, 2) CHECK (arm_cm > 0),
  thigh_cm        DECIMAL(5, 2) CHECK (thigh_cm > 0),
  notes           TEXT,
  created_at      TIMESTAMPTZ   NOT NULL DEFAULT NOW()
);

-- Índice para buscar medidas de um usuário ordenadas por data
CREATE INDEX IF NOT EXISTS idx_body_measurements_user_date
  ON body_measurements (user_id, measured_at DESC);

-- Garante apenas uma medição por dia por usuário
CREATE UNIQUE INDEX IF NOT EXISTS idx_body_measurements_unique_day
  ON body_measurements (user_id, measured_at);
