// lib/core/database/local_schema.dart
//
// DDL das tabelas SQLite locais.
// Espelha o schema PostgreSQL do backend, adaptado para
// funcionamento offline no dispositivo.

/// Versão atual do banco local. Incrementar ao adicionar tabelas/colunas.
const int kDatabaseVersion = 2;

/// SQL de criação de todas as tabelas locais.
/// Executado na primeira abertura do app ou em upgrades de versão.
const String kCreateTablesSQL = '''
  -- Usuário logado (apenas o perfil local)
  CREATE TABLE IF NOT EXISTS users (
    id              INTEGER PRIMARY KEY,
    name            TEXT    NOT NULL,
    email           TEXT    NOT NULL UNIQUE,
    age             INTEGER,
    sex             TEXT,
    weight_kg       REAL,
    height_cm       REAL,
    goal            TEXT,
    activity_level  TEXT,
    updated_at      TEXT
  );

  -- Catálogo de exercícios (sincronizado do servidor)
  CREATE TABLE IF NOT EXISTS exercises (
    id            INTEGER PRIMARY KEY,
    name          TEXT    NOT NULL,
    muscle_group  TEXT    NOT NULL,
    description   TEXT,
    instructions  TEXT,
    is_custom     INTEGER NOT NULL DEFAULT 0,
    created_by    INTEGER,
    synced_at     TEXT
  );

  -- Fichas de treino do usuário
  CREATE TABLE IF NOT EXISTS workouts (
    id              INTEGER PRIMARY KEY AUTOINCREMENT,
    server_id       INTEGER,          -- ID no PostgreSQL (NULL = não sincronizado)
    user_id         INTEGER NOT NULL,
    name            TEXT    NOT NULL,
    description     TEXT,
    is_dirty        INTEGER NOT NULL DEFAULT 1,  -- 1 = precisa sincronizar
    created_at      TEXT    NOT NULL DEFAULT (datetime('now')),
    updated_at      TEXT    NOT NULL DEFAULT (datetime('now'))
  );

  -- Exercícios planejados dentro de uma ficha
  CREATE TABLE IF NOT EXISTS workout_exercises (
    id          INTEGER PRIMARY KEY AUTOINCREMENT,
    server_id   INTEGER,
    workout_id  INTEGER NOT NULL REFERENCES workouts(id) ON DELETE CASCADE,
    exercise_id INTEGER NOT NULL,
    sets        INTEGER NOT NULL,
    reps        INTEGER NOT NULL,
    weight_kg   REAL,
    rest_secs   INTEGER,
    notes       TEXT,
    order_index INTEGER NOT NULL DEFAULT 0,
    is_dirty    INTEGER NOT NULL DEFAULT 1
  );

  -- Sessões de treino realizadas (histórico local)
  CREATE TABLE IF NOT EXISTS workout_logs (
    id           INTEGER PRIMARY KEY AUTOINCREMENT,
    server_id    INTEGER,
    workout_id   INTEGER REFERENCES workouts(id) ON DELETE SET NULL,
    started_at   TEXT    NOT NULL DEFAULT (datetime('now')),
    finished_at  TEXT,
    duration_min INTEGER,
    notes        TEXT,
    rating       INTEGER,
    is_dirty     INTEGER NOT NULL DEFAULT 1
  );

  -- Séries executadas dentro de uma sessão
  CREATE TABLE IF NOT EXISTS set_logs (
    id              INTEGER PRIMARY KEY AUTOINCREMENT,
    server_id       INTEGER,
    workout_log_id  INTEGER NOT NULL REFERENCES workout_logs(id) ON DELETE CASCADE,
    exercise_id     INTEGER NOT NULL,
    set_number      INTEGER NOT NULL,
    reps_done       INTEGER,
    weight_kg       REAL,
    duration_secs   INTEGER,
    is_warmup       INTEGER NOT NULL DEFAULT 0,
    notes           TEXT,
    logged_at       TEXT    NOT NULL DEFAULT (datetime('now')),
    is_dirty        INTEGER NOT NULL DEFAULT 1
  );

  -- Registros de nutrição e refeições
  CREATE TABLE IF NOT EXISTS nutrition_logs (
    id            INTEGER PRIMARY KEY AUTOINCREMENT,
    server_id     INTEGER,
    user_id       INTEGER NOT NULL,
    meal_type     TEXT    NOT NULL,
    description   TEXT,
    calories_kcal REAL    NOT NULL DEFAULT 0,
    protein_g     REAL    NOT NULL DEFAULT 0,
    carbs_g       REAL    NOT NULL DEFAULT 0,
    fat_g         REAL    NOT NULL DEFAULT 0,
    logged_date   TEXT    NOT NULL,
    is_dirty      INTEGER NOT NULL DEFAULT 1
  );

  -- Medidas corporais e evolução
  CREATE TABLE IF NOT EXISTS body_measurements (
    id             INTEGER PRIMARY KEY AUTOINCREMENT,
    server_id      INTEGER,
    user_id        INTEGER NOT NULL,
    measured_at    TEXT    NOT NULL,
    weight_kg      REAL,
    body_fat_pct   REAL,
    muscle_mass_kg REAL,
    chest_cm       REAL,
    waist_cm       REAL,
    hip_cm         REAL,
    arm_cm         REAL,
    thigh_cm       REAL,
    notes          TEXT,
    is_dirty       INTEGER NOT NULL DEFAULT 1
  );

  -- Índices para performance
  CREATE INDEX IF NOT EXISTS idx_local_workouts_user ON workouts(user_id);
  CREATE INDEX IF NOT EXISTS idx_local_workout_exs   ON workout_exercises(workout_id);
  CREATE INDEX IF NOT EXISTS idx_local_wlogs_started ON workout_logs(started_at DESC);
  CREATE INDEX IF NOT EXISTS idx_local_set_logs_log  ON set_logs(workout_log_id);
  CREATE INDEX IF NOT EXISTS idx_local_exercises_mg  ON exercises(muscle_group);
  CREATE INDEX IF NOT EXISTS idx_local_nutrition_dt  ON nutrition_logs(user_id, logged_date);
  CREATE INDEX IF NOT EXISTS idx_local_measure_dt    ON body_measurements(user_id, measured_at);
''';
