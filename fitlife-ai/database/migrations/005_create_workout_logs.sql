-- ============================================================
-- Migration 005: Histórico de treinos realizados
-- ============================================================
-- Cada registro representa uma sessão de treino executada
-- pelo usuário. Pode ou não estar vinculado a uma ficha.
-- ============================================================

CREATE TABLE IF NOT EXISTS workout_logs (
  id           SERIAL        PRIMARY KEY,
  user_id      INTEGER       NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  workout_id   INTEGER       REFERENCES workouts(id) ON DELETE SET NULL,
  started_at   TIMESTAMPTZ   NOT NULL DEFAULT NOW(),
  finished_at  TIMESTAMPTZ,
  duration_min SMALLINT      CHECK (duration_min >= 0),
  notes        TEXT,
  rating       SMALLINT      CHECK (rating BETWEEN 1 AND 5),
  created_at   TIMESTAMPTZ   NOT NULL DEFAULT NOW()
);

-- Índice para buscar histórico de um usuário (ordenado por data)
CREATE INDEX IF NOT EXISTS idx_workout_logs_user_id
  ON workout_logs (user_id, started_at DESC);

-- Índice para relacionar com ficha
CREATE INDEX IF NOT EXISTS idx_workout_logs_workout_id
  ON workout_logs (workout_id);
