const jwt = require('jsonwebtoken');

const JWT_SECRET = process.env.JWT_SECRET || 'fitlife_ai_super_secret_jwt_key_2026_production_ready';

/**
 * Middleware para validar o token JWT de autenticação.
 */
function authMiddleware(req, res, next) {
  const authHeader = req.headers.authorization;

  if (!authHeader) {
    return res.status(401).json({
      success: false,
      message: 'Token de autenticação não fornecido.',
    });
  }

  const parts = authHeader.split(' ');
  if (parts.length !== 2 || parts[0] !== 'Bearer') {
    return res.status(401).json({
      success: false,
      message: 'Formato do cabeçalho de autorização inválido. Use "Bearer <token>".',
    });
  }

  const token = parts[1];

  try {
    const decoded = jwt.verify(token, JWT_SECRET);
    req.userId = decoded.id;
    req.user = decoded;
    next();
  } catch (err) {
    return res.status(401).json({
      success: false,
      message: err.name === 'TokenExpiredError' ? 'Token expirado. Faça login novamente.' : 'Token de autenticação inválido.',
    });
  }
}

module.exports = authMiddleware;

