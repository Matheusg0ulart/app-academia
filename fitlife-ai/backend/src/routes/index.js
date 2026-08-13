const { Router } = require('express');
const healthRoutes = require('./health.routes');

const router = Router();

// Rota de Health Check
router.use('/health', healthRoutes);

module.exports = router;
