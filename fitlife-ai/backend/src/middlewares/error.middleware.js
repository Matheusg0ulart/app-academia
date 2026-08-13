/**
 * Middleware para tratamento centralizado de erros da API REST.
 */
const errorMiddleware = (err, req, res, next) => {
  console.error('💥 Erro não tratado:', err);

  const statusCode = err.statusCode || 500;
  const message = err.message || 'Erro interno do servidor';

  return res.status(statusCode).json({
    status: 'error',
    statusCode,
    message,
  });
};

module.exports = errorMiddleware;
