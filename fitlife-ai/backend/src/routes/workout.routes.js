const { Router } = require('express');
const WorkoutController = require('../controllers/workout.controller');
const authMiddleware = require('../middlewares/auth.middleware');

const router = Router();

// Todas as rotas de treino requerem autenticação
router.use(authMiddleware);

router.get('/', WorkoutController.list);
router.post('/', WorkoutController.create);
router.post('/generate', WorkoutController.generate);
router.get('/:id', WorkoutController.getById);
router.put('/:id', WorkoutController.update);
router.delete('/:id', WorkoutController.delete);

// Exercícios dentro da ficha de treino
router.post('/:id/exercises', WorkoutController.addExercise);
router.delete('/:id/exercises/:exerciseId', WorkoutController.removeExercise);

module.exports = router;
