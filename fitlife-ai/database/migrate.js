#!/usr/bin/env node
// ============================================================
// database/migrate.js
// Script de migração automática do FitLife AI
// ============================================================
// Uso:
//   node database/migrate.js           → roda todas as migrations
//   node database/migrate.js --seed    → roda migrations + seeds
// ============================================================

require('dotenv').config({ path: './backend/.env' });

const { Pool } = require('pg');
const fs   = require('fs');
const path = require('path');

// ── Conexão ──────────────────────────────────────────────────
const pool = new Pool(
  process.env.DATABASE_URL
    ? {
        connectionString: process.env.DATABASE_URL,
        ssl: { rejectUnauthorized: false }, // obrigatório no Neon.tech
      }
    : {
        host:     process.env.DB_HOST     || 'localhost',
        port:     parseInt(process.env.DB_PORT || '5432', 10),
        user:     process.env.DB_USER     || 'postgres',
        password: process.env.DB_PASSWORD || 'postgres',
        database: process.env.DB_NAME     || 'fitlife_ai_db',
      }
);

// ── Helpers ───────────────────────────────────────────────────
const MIGRATIONS_DIR = path.join(__dirname, 'migrations');
const SEEDS_DIR      = path.join(__dirname, 'seeds');

/**
 * Executa um arquivo SQL, exibindo nome e status.
 */
async function runSqlFile(filePath) {
  const fileName = path.basename(filePath);
  try {
    const sql = fs.readFileSync(filePath, 'utf8');
    await pool.query(sql);
    console.log(`  ✅ ${fileName}`);
  } catch (err) {
    console.error(`  ❌ ${fileName} — ERRO: ${err.message}`);
    throw err;
  }
}

/**
 * Retorna os arquivos .sql de um diretório em ordem alfabética.
 */
function getSqlFiles(dir) {
  if (!fs.existsSync(dir)) return [];
  return fs
    .readdirSync(dir)
    .filter(f => f.endsWith('.sql') && !f.startsWith('.'))
    .sort()
    .map(f => path.join(dir, f));
}

// ── Tabela de controle de migrations ─────────────────────────
async function ensureMigrationsTable() {
  await pool.query(`
    CREATE TABLE IF NOT EXISTS _migrations (
      id          SERIAL      PRIMARY KEY,
      filename    VARCHAR(255) NOT NULL UNIQUE,
      executed_at TIMESTAMPTZ  NOT NULL DEFAULT NOW()
    );
  `);
}

async function isAlreadyRun(filename) {
  const { rows } = await pool.query(
    'SELECT 1 FROM _migrations WHERE filename = $1',
    [filename]
  );
  return rows.length > 0;
}

async function markAsRun(filename) {
  await pool.query(
    'INSERT INTO _migrations (filename) VALUES ($1) ON CONFLICT DO NOTHING',
    [filename]
  );
}

// ── Funções principais ────────────────────────────────────────
async function runMigrations() {
  console.log('\n📦 Executando migrations...');
  await ensureMigrationsTable();

  const files = getSqlFiles(MIGRATIONS_DIR);
  if (files.length === 0) {
    console.log('  ⚠️  Nenhuma migration encontrada.');
    return;
  }

  let skipped = 0;
  for (const file of files) {
    const name = path.basename(file);
    if (await isAlreadyRun(name)) {
      console.log(`  ⏭️  ${name} (já executada)`);
      skipped++;
      continue;
    }
    await runSqlFile(file);
    await markAsRun(name);
  }

  const ran = files.length - skipped;
  console.log(`\n  📊 Total: ${files.length} | Executadas: ${ran} | Puladas: ${skipped}`);
}

async function runSeeds() {
  console.log('\n🌱 Executando seeds...');
  const files = getSqlFiles(SEEDS_DIR);
  if (files.length === 0) {
    console.log('  ⚠️  Nenhum seed encontrado.');
    return;
  }
  for (const file of files) {
    await runSqlFile(file);
  }
}

// ── Entry point ───────────────────────────────────────────────
(async () => {
  const withSeed = process.argv.includes('--seed');

  console.log('🚀 FitLife AI — Database Migration Tool');
  console.log('─'.repeat(45));
  console.log(`🔗 Modo: ${process.env.DATABASE_URL ? 'Neon.tech (DATABASE_URL)' : 'PostgreSQL local'}`);

  try {
    await runMigrations();
    if (withSeed) await runSeeds();
    console.log('\n✨ Concluído com sucesso!\n');
  } catch (err) {
    console.error('\n💥 Falha na migração:', err.message);
    process.exit(1);
  } finally {
    await pool.end();
  }
})();
