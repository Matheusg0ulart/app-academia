-- ============================================================
-- Migration 009: Sessões de autenticação (Refresh Tokens)
-- ============================================================
-- Armazena refresh tokens para autenticação JWT stateful.
-- Permite revogar sessões individuais ou todas de um usuário.
-- ============================================================

CREATE TABLE IF NOT EXISTS user_sessions (
  id            SERIAL        PRIMARY KEY,
  user_id       INTEGER       NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  refresh_token VARCHAR(512)  NOT NULL UNIQUE,
  device_info   VARCHAR(255),
  ip_address    INET,
  expires_at    TIMESTAMPTZ   NOT NULL,
  revoked       BOOLEAN       NOT NULL DEFAULT FALSE,
  revoked_at    TIMESTAMPTZ,
  created_at    TIMESTAMPTZ   NOT NULL DEFAULT NOW()
);

-- Índice para buscar sessões ativas de um usuário
CREATE INDEX IF NOT EXISTS idx_user_sessions_user_id
  ON user_sessions (user_id, revoked, expires_at);

-- Índice para lookup rápido do token (usado na validação JWT)
CREATE INDEX IF NOT EXISTS idx_user_sessions_token
  ON user_sessions (refresh_token) WHERE revoked = FALSE;
