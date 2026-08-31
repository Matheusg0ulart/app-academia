const AiService = require('../services/ai.service');

const AiController = {
  async chat(req, res, next) {
    try {
      const { message } = req.body;
      const result = await AiService.processChat(req.userId, message);
      return res.status(200).json({
        success: true,
        reply: result.reply,
        source: result.source,
      });
    } catch (error) {
      next(error);
    }
  },

  async getContext(req, res, next) {
    try {
      const context = await AiService.getUserContext(req.userId);
      return res.status(200).json({
        success: true,
        context,
      });
    } catch (error) {
      next(error);
    }
  },
};

module.exports = AiController;

