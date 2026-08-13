/**
 * Servico responsável por gerar as informações de saúde da aplicação.
 */
const checkHealth = () => {
  return {
    status: 'ok',
    message: 'FitLife AI API funcionando',
    timestamp: new Date().toISOString()
  };
};

module.exports = {
  checkHealth,
};
