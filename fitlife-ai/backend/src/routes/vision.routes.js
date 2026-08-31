// backend/src/routes/vision.routes.js

const { Router } = require('express');
const VisionController = require('../controllers/vision.controller');
const authMiddleware = require('../middlewares/auth.middleware');

const router = Router();

router.use(authMiddleware);

// POST /api/vision/scan-plate — Análise de prato com Gemini Vision
router.post('/scan-plate', VisionController.scanPlate);

module.exports = router;
