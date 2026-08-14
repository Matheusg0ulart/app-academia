-- ============================================================
-- Migration 003: Fichas de treino
-- ============================================================
-- Cada ficha pertence a um usuário e agrupa os exercícios
-- planejados. Ex: "Treino A – Peito e Tríceps".
-- ============================================================

CREATE TABLE IF NOT EXISTS workouts (
  id          SERIAL        PRIMARY KEY,
  user_id     INTEGER       NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  name        VARCHAR(150)  NOT NULL,
  description TEXT,
  created_at  TIMESTAMPTZ   NOT NULL DEFAULT NOW(),
  updated_at  TIMESTAMPTZ   NOT NULL DEFAULT NOW()
);

-- Índice para buscar fichas de um usuário específico
CREATE INDEX IF NOT EXISTS idx_workouts_user_id
  ON workouts (user_id);

-- Trigger: atualiza updated_at automaticamente a cada UPDATE
CREATE TRIGGER trg_workouts_updated_at
  BEFORE UPDATE ON workouts
  FOR EACH ROW
  EXECUTE FUNCTION update_updated_at_column();
