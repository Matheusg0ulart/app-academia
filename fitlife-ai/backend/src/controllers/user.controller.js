const UserService = require('../services/user.service');

const UserController = {
  async getMe(req, res, next) {
    try {
      const user = await UserService.getProfile(req.userId);
      return res.status(200).json({
        success: true,
        user,
      });
    } catch (error) {
      next(error);
    }
  },

  async updateMe(req, res, next) {
    try {
      const user = await UserService.updateProfile(req.userId, req.body);
      return res.status(200).json({
        success: true,
        message: 'Perfil atualizado com sucesso!',
        user,
      });
    } catch (error) {
      next(error);
    }
  },

  async getReport(req, res, next) {
    try {
      const report = await UserService.getEvolutionReport(req.userId);
      return res.status(200).json({
        success: true,
        report,
      });
    } catch (error) {
      next(error);
    }
  },
};

module.exports = UserController;
