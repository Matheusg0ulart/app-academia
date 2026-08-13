const { Router } = require('express');
const healthController = require('../controllers/health.controller');

const router = Router();

// GET /api/health
router.get('/', healthController.getHealthStatus);

module.exports = router;
