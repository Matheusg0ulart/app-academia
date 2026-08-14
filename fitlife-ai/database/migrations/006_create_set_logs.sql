-- ============================================================
-- Migration 006: Séries executadas dentro de uma sessão
-- ============================================================
-- Detalha cada série realizada durante um treino (workout_log).
-- Permite rastrear evolução de carga e volume por exercício.
-- ============================================================

CREATE TABLE IF NOT EXISTS set_logs (
  id              SERIAL        PRIMARY KEY,
  workout_log_id  INTEGER       NOT NULL REFERENCES workout_logs(id) ON DELETE CASCADE,
  exercise_id     INTEGER       NOT NULL REFERENCES exercises(id)    ON DELETE RESTRICT,
  set_number      SMALLINT      NOT NULL CHECK (set_number > 0),
  reps_done       SMALLINT      CHECK (reps_done >= 0),
  weight_kg       DECIMAL(6, 2) CHECK (weight_kg >= 0),
  duration_secs   SMALLINT      CHECK (duration_secs >= 0),  -- para exercícios por tempo (prancha, etc.)
  is_warmup       BOOLEAN       NOT NULL DEFAULT FALSE,
  notes           TEXT,
  logged_at       TIMESTAMPTZ   NOT NULL DEFAULT NOW()
);

-- Índice para buscar todas as séries de uma sessão
CREATE INDEX IF NOT EXISTS idx_set_logs_workout_log_id
  ON set_logs (workout_log_id);

-- Índice para evolução de um exercício específico
CREATE INDEX IF NOT EXISTS idx_set_logs_exercise_id
  ON set_logs (exercise_id);
