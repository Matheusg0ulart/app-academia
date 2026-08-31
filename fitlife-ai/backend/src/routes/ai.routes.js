const { Router } = require('express');
const AiController = require('../controllers/ai.controller');
const authMiddleware = require('../middlewares/auth.middleware');

const router = Router();

router.use(authMiddleware);

router.post('/chat', AiController.chat);
router.get('/context', AiController.getContext);

module.exports = router;

