const { Router } = require('express');
const WorkoutLogController = require('../controllers/workout-log.controller');
const authMiddleware = require('../middlewares/auth.middleware');

const router = Router();

router.use(authMiddleware);

router.post('/', WorkoutLogController.start);
router.post('/:id/sets', WorkoutLogController.addSet);
router.patch('/:id/finish', WorkoutLogController.finish);
router.put('/:id/finish', WorkoutLogController.finish);
router.get('/', WorkoutLogController.getHistory);
router.get('/exercise/:exerciseId/progress', WorkoutLogController.getExerciseProgress);
router.get('/:id', WorkoutLogController.getById);

module.exports = router;

