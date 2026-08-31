const AuthService = require('../services/auth.service');

const AuthController = {
  async register(req, res, next) {
    try {
      const result = await AuthService.register(req.body);
      return res.status(201).json({
        success: true,
        message: 'Usuário cadastrado com sucesso!',
        ...result,
      });
    } catch (error) {
      next(error);
    }
  },

  async login(req, res, next) {
    try {
      const { email, password } = req.body;
      const result = await AuthService.login(email, password);
      return res.status(200).json({
        success: true,
        message: 'Login realizado com sucesso!',
        ...result,
      });
    } catch (error) {
      next(error);
    }
  },

  async logout(req, res) {
    return res.status(200).json({
      success: true,
      message: 'Logout realizado com sucesso.',
    });
  },
};

module.exports = AuthController;

