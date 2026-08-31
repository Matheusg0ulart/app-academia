// backend/src/routes/food.routes.js

const { Router } = require('express');
const { searchFoodsHandler, getByBarcodeHandler } = require('../controllers/food.controller');
const authMiddleware = require('../middlewares/auth.middleware');

const router = Router();

// Todas as rotas de alimentos requerem autenticação
router.use(authMiddleware);

// GET /api/nutrition/foods/search?query=frango&category=all
router.get('/search', searchFoodsHandler);

// GET /api/nutrition/foods/barcode/:barcode
router.get('/barcode/:barcode', getByBarcodeHandler);

module.exports = router;
