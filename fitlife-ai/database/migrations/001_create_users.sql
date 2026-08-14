-- ============================================================
-- Migration 001: Tabela de usuários
-- ============================================================
-- Cria também a função compartilhada update_updated_at_column(),
-- reutilizada por triggers de outras tabelas.
-- ============================================================

-- Função compartilhada para atualizar o campo updated_at automaticamente
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Tabela principal de usuários
CREATE TABLE IF NOT EXISTS users (
  id              SERIAL        PRIMARY KEY,
  name            VARCHAR(100)  NOT NULL,
  email           VARCHAR(255)  NOT NULL UNIQUE,
  password_hash   VARCHAR(255)  NOT NULL,
  age             SMALLINT      CHECK (age > 0 AND age <= 120),
  sex             VARCHAR(10)   CHECK (sex IN ('male', 'female', 'other')),
  weight_kg       DECIMAL(5, 2) CHECK (weight_kg > 0 AND weight_kg < 500),
  height_cm       DECIMAL(5, 2) CHECK (height_cm > 0 AND height_cm < 300),
  goal            VARCHAR(20)   CHECK (goal IN ('lose_weight', 'gain_muscle', 'maintain', 'gain_weight')),
  activity_level  VARCHAR(20)   CHECK (activity_level IN ('sedentary', 'light', 'moderate', 'active', 'very_active')),
  created_at      TIMESTAMPTZ   NOT NULL DEFAULT NOW(),
  updated_at      TIMESTAMPTZ   NOT NULL DEFAULT NOW()
);

-- Índice no email (usado nas queries de login)
CREATE INDEX IF NOT EXISTS idx_users_email ON users (email);

-- Trigger: atualiza updated_at automaticamente a cada UPDATE
CREATE TRIGGER trg_users_updated_at
  BEFORE UPDATE ON users
  FOR EACH ROW
  EXECUTE FUNCTION update_updated_at_column();
