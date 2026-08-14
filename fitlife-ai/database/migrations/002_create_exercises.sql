-- ============================================================
-- Migration 002: Catálogo de exercícios
-- ============================================================
-- Armazena tanto exercícios do sistema (is_custom = FALSE)
-- quanto exercícios criados pelo próprio usuário (is_custom = TRUE).
-- ============================================================

CREATE TABLE IF NOT EXISTS exercises (
  id            SERIAL       PRIMARY KEY,
  name          VARCHAR(150) NOT NULL,
  muscle_group  VARCHAR(20)  NOT NULL CHECK (muscle_group IN (
                  'chest', 'back', 'shoulders', 'biceps', 'triceps',
                  'forearms', 'abs', 'quadriceps', 'hamstrings',
                  'glutes', 'calves', 'cardio', 'full_body'
                )),
  description   TEXT,
  instructions  TEXT,
  is_custom     BOOLEAN      NOT NULL DEFAULT FALSE,
  created_by    INTEGER      REFERENCES users(id) ON DELETE SET NULL,
  created_at    TIMESTAMPTZ  NOT NULL DEFAULT NOW()
);

-- Índice para filtrar por grupo muscular
CREATE INDEX IF NOT EXISTS idx_exercises_muscle_group
  ON exercises (muscle_group);

-- Índice para exercícios criados por usuários específicos
CREATE INDEX IF NOT EXISTS idx_exercises_created_by
  ON exercises (created_by);

-- Índice único parcial: evita nomes duplicados nos exercícios do sistema.
-- Exercícios customizados (is_custom = TRUE) não são restringidos por este índice.
-- Também é usado pelo ON CONFLICT nos seeds.
CREATE UNIQUE INDEX IF NOT EXISTS idx_exercises_unique_system_name
  ON exercises (LOWER(name)) WHERE is_custom = FALSE;
