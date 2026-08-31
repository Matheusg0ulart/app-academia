const { Router } = require('express');
const UserController = require('../controllers/user.controller');
const authMiddleware = require('../middlewares/auth.middleware');

const router = Router();

router.use(authMiddleware);

router.get('/me', UserController.getMe);
router.put('/me', UserController.updateMe);
router.patch('/me', UserController.updateMe);
router.get('/report', UserController.getReport);

module.exports = router;
