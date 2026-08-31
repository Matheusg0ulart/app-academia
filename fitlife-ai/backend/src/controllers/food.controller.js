// backend/src/controllers/food.controller.js

const { searchFoods, fetchByBarcode } = require('../services/food-api.service');

// GET /api/nutrition/foods/search?query=frango&category=all
async function searchFoodsHandler(req, res) {
  try {
    const { query = '', category = 'all' } = req.query;

    if (!query || query.trim().length < 2) {
      return res.status(400).json({
        error: 'Informe ao menos 2 caracteres para buscar alimentos.',
      });
    }

    const results = await searchFoods(query.trim(), category);

    return res.json({
      query,
      category,
      ...results,
    });
  } catch (err) {
    console.error('[FoodController] Erro na busca:', err.message);
    return res.status(500).json({ error: 'Erro ao buscar alimentos.' });
  }
}

// GET /api/nutrition/foods/barcode/:barcode
async function getByBarcodeHandler(req, res) {
  try {
    const { barcode } = req.params;
    if (!barcode || barcode.trim().length < 4) {
      return res.status(400).json({ error: 'Código de barras inválido.' });
    }

    const product = await fetchByBarcode(barcode.trim());
    if (!product) {
      return res.status(404).json({ error: 'Produto não encontrado pelo código de barras informado.' });
    }

    return res.json({ product });
  } catch (err) {
    console.error('[FoodController] Erro na busca por código de barras:', err.message);
    return res.status(500).json({ error: 'Erro ao buscar por código de barras.' });
  }
}

module.exports = { searchFoodsHandler, getByBarcodeHandler };
