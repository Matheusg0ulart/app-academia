require('dotenv').config();
const app = require('./src/app');
const { testConnection } = require('./src/config/db');

const PORT = process.env.PORT || 3000;

app.listen(PORT, async () => {
  console.log(`=================================`);
  console.log(`🚀 FitLife AI API rodando na porta ${PORT}`);
  console.log(`📍 Endpoint de Health Check: http://localhost:${PORT}/api/health`);
  console.log(`=================================`);
  await testConnection();
});
