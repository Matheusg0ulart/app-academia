const { Pool } = require('pg');

/**
 * Configuração da piscina de conexões (Pool) do PostgreSQL.
 *
 * Prioridade de conexão:
 *  1. DATABASE_URL  → Neon.tech (produção) ou qualquer connection string
 *  2. Variáveis individuais (DB_HOST, DB_PORT, ...) → PostgreSQL local
 *
 * O SSL com rejectUnauthorized: false é necessário para o Neon.tech.
 */
const poolConfig = process.env.DATABASE_URL
  ? {
      connectionString: process.env.DATABASE_URL,
      ssl: { rejectUnauthorized: false },
      max: 10,                // máximo de conexões simultâneas
      idleTimeoutMillis: 30000,
      connectionTimeoutMillis: 5000,
    }
  : {
      host:     process.env.DB_HOST     || 'localhost',
      port:     parseInt(process.env.DB_PORT || '5432', 10),
      user:     process.env.DB_USER     || 'postgres',
      password: process.env.DB_PASSWORD || 'postgres',
      database: process.env.DB_NAME     || 'fitlife_ai_db',
      max: 10,
      idleTimeoutMillis: 30000,
      connectionTimeoutMillis: 5000,
    };

const pool = new Pool(poolConfig);

// Log de erros não capturados no pool
pool.on('error', (err) => {
  console.error('❌ Erro inesperado no pool PostgreSQL:', err.message);
});

/**
 * Testa a conexão de forma não bloqueante na inicialização da API.
 */
const testConnection = async () => {
  try {
    const client = await pool.connect();
    const { rows } = await client.query('SELECT version()');
    const version = rows[0].version.split(' ').slice(0, 2).join(' ');
    console.log(`✅ PostgreSQL conectado: ${version}`);
    console.log(`🔗 Modo: ${process.env.DATABASE_URL ? 'Neon.tech (cloud)' : 'Local'}`);
    client.release();
  } catch (error) {
    console.warn('⚠️  PostgreSQL não conectado:', error.message);
    console.warn('💡 Configure DATABASE_URL (Neon) ou DB_HOST/DB_USER/... no .env');
  }
};

module.exports = {
  /** Executa uma query no pool. Uso: db.query('SELECT ...', [params]) */
  query: (text, params) => pool.query(text, params),

  /** Pool bruto para transações manuais (BEGIN/COMMIT/ROLLBACK). */
  pool,

  testConnection,
};
