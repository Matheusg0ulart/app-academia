const { Router } = require('express');
const CalculatorController = require('../controllers/calculator.controller');

const router = Router();

// As calculadoras podem ser usadas com ou sem autenticação
router.get('/tmb-tdee', CalculatorController.calculateTmbAndTdee);
router.post('/tmb-tdee', CalculatorController.calculateTmbAndTdee);
router.post('/exercise-calories', CalculatorController.calculateExerciseBurn);
router.get('/activities', CalculatorController.getActivities);
router.post('/weight-projection', CalculatorController.simulateWeightProjection);

module.exports = router;
