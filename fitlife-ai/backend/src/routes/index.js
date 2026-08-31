const { Router } = require('express');
const healthRoutes = require('./health.routes');
const authRoutes = require('./auth.routes');
const userRoutes = require('./user.routes');
const exerciseRoutes = require('./exercise.routes');
const workoutRoutes = require('./workout.routes');
const workoutLogRoutes = require('./workout-log.routes');
const nutritionRoutes = require('./nutrition.routes');
const measurementRoutes = require('./measurement.routes');
const calculatorRoutes = require('./calculator.routes');
const dashboardRoutes = require('./dashboard.routes');
const aiRoutes = require('./ai.routes');
const foodRoutes = require('./food.routes');
const visionRoutes = require('./vision.routes');

const router = Router();

// ── Registro de todas as rotas da API ─────────────────────────
router.use('/health', healthRoutes);
router.use('/auth', authRoutes);
router.use('/users', userRoutes);
router.use('/exercises', exerciseRoutes);
router.use('/workouts', workoutRoutes);
router.use('/workout-logs', workoutLogRoutes);
router.use('/nutrition', nutritionRoutes);
router.use('/nutrition/foods', foodRoutes);
router.use('/measurements', measurementRoutes);
router.use('/calculators', calculatorRoutes);
router.use('/dashboard', dashboardRoutes);
router.use('/ai', aiRoutes);
router.use('/vision', visionRoutes);

module.exports = router;
