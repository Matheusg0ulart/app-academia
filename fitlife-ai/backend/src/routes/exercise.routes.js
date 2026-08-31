const { Router } = require('express');
const ExerciseController = require('../controllers/exercise.controller');
const authMiddleware = require('../middlewares/auth.middleware');

const router = Router();

router.use(authMiddleware);

router.get('/', ExerciseController.list);
router.get('/muscle-groups', ExerciseController.getMuscleGroups);
router.get('/:id', ExerciseController.getById);
router.post('/', ExerciseController.create);

module.exports = router;

