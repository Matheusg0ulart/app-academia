const { Router } = require('express');
const NutritionController = require('../controllers/nutrition.controller');
const authMiddleware = require('../middlewares/auth.middleware');

const router = Router();

// Todas as rotas requerem autenticação
router.use(authMiddleware);

router.post('/', NutritionController.logMeal);
router.post('/estimate-text', NutritionController.estimateFromText);
router.get('/summary', NutritionController.getDailySummary);
router.get('/daily', NutritionController.getDailySummary);
router.get('/meal-targets', NutritionController.getMealTargets);
router.get('/history', NutritionController.getHistory);
router.delete('/:id', NutritionController.deleteMeal);

module.exports = router;
