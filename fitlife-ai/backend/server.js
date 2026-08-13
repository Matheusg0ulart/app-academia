require('dotenv').config();
const app = require('./src/app');

const PORT = process.env.PORT || 3000;

app.listen(PORT, () => {
  console.log(`=================================`);
  console.log(`🚀 FitLife AI API rodando na porta ${PORT}`);
  console.log(`📍 Endpoint de Health Check: http://localhost:${PORT}/api/health`);
  console.log(`=================================`);
});
