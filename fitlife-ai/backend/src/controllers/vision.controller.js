// backend/src/controllers/vision.controller.js
//
// Controller para análise visual de pratos via Gemini Vision API

const GeminiService = require('../services/gemini.service');

const VisionController = {
  /**
   * POST /api/vision/scan-plate
   * Recebe uma imagem em Base64 e retorna análise nutricional via Gemini Vision
   */
  async scanPlate(req, res, next) {
    try {
      const { image, mimeType } = req.body;

      if (!image) {
        return res.status(400).json({
          success: false,
          message: 'Imagem não fornecida. Envie o campo "image" com a imagem em Base64.',
        });
      }

      // Remove o prefixo data:image/...;base64, se presente
      const base64Data = image.includes(',') ? image.split(',')[1] : image;
      const imageMime = mimeType || 'image/jpeg';

      const analysis = await GeminiService.analyzeFoodPlate(base64Data, imageMime);

      return res.status(200).json({
        success: true,
        analysis,
      });
    } catch (error) {
      if (error.statusCode === 503) {
        return res.status(503).json({
          success: false,
          message: error.message,
        });
      }
      next(error);
    }
  },
};

module.exports = VisionController;
