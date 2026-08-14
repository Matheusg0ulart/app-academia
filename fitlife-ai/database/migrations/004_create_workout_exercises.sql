-- ============================================================
-- Migration 004: Exercícios planejados dentro de uma ficha
-- ============================================================
-- Relaciona quais exercícios compõem cada ficha de treino,
-- com os parâmetros planejados (séries, reps, carga, descanso).
-- ============================================================

CREATE TABLE IF NOT EXISTS workout_exercises (
  id          SERIAL        PRIMARY KEY,
  workout_id  INTEGER       NOT NULL REFERENCES workouts(id)  ON DELETE CASCADE,
  exercise_id INTEGER       NOT NULL REFERENCES exercises(id) ON DELETE RESTRICT,
  sets        SMALLINT      NOT NULL CHECK (sets > 0),
  reps        SMALLINT      NOT NULL CHECK (reps > 0),
  weight_kg   DECIMAL(6, 2)          CHECK (weight_kg >= 0),
  rest_secs   SMALLINT               CHECK (rest_secs >= 0),
  notes       TEXT,
  order_index SMALLINT      NOT NULL DEFAULT 0,
  created_at  TIMESTAMPTZ   NOT NULL DEFAULT NOW()
);

-- Índice para buscar exercícios de uma ficha
CREATE INDEX IF NOT EXISTS idx_workout_exercises_workout_id
  ON workout_exercises (workout_id);

-- Índice para descobrir em quais fichas um exercício aparece
CREATE INDEX IF NOT EXISTS idx_workout_exercises_exercise_id
  ON workout_exercises (exercise_id);
