const { Pool } = require('pg');

/**
 * Configuração da piscina de conexões (Pool) do PostgreSQL.
 * As credenciais são carregadas do arquivo .env.
 */
const pool = new Pool({
  host: process.env.DB_HOST || 'localhost',
  port: parseInt(process.env.DB_PORT || '5432', 10),
  user: process.env.DB_USER || 'postgres',
  password: process.env.DB_PASSWORD || 'postgres',
  database: process.env.DB_NAME || 'fitlife_ai_db',
});

/**
 * Função utilitária para testar a conexão com o PostgreSQL
 * de forma não bloqueante para a inicialização da API.
 */
const testConnection = async () => {
  try {
    const client = await pool.connect();
    console.log('✅ Conexão com o banco de dados PostgreSQL estabelecida com sucesso!');
    client.release();
  } catch (error) {
    console.warn('⚠️ PostgreSQL não conectado no momento:', error.message);
    console.warn('💡 A API continua funcionando normalmente para endpoints sem persistência.');
  }
};

module.exports = {
  query: (text, params) => pool.query(text, params),
  pool,
  testConnection,
};
