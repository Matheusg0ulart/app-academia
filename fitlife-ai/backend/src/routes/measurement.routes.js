const { Router } = require('express');
const MeasurementController = require('../controllers/measurement.controller');
const authMiddleware = require('../middlewares/auth.middleware');

const router = Router();

router.use(authMiddleware);

router.post('/', MeasurementController.log);
router.get('/', MeasurementController.getHistory);
router.get('/latest', MeasurementController.getLatest);
router.delete('/:id', MeasurementController.delete);

module.exports = router;

