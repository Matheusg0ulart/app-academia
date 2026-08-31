// backend/src/services/food-api.service.js
//
// Serviço de busca de alimentos:
//   1. Busca na base TACO local (naturais/in-natura)
//   2. Busca na API Open Food Facts (industrializados, marcas, código de barras)
//   3. Cache em memória com TTL para altíssima performance (< 5ms em hits)

const https = require('https');
const tacoFoods = require('../data/taco-foods');

// ── Cache em Memória com TTL (10 minutos) ───────────────────
const cache = new Map();
const CACHE_TTL_MS = 10 * 60 * 1000;

function getCached(key) {
  const item = cache.get(key);
  if (!item) return null;
  if (Date.now() > item.expiresAt) {
    cache.delete(key);
    return null;
  }
  return item.data;
}

function setCached(key, data) {
  if (cache.size > 500) {
    // Limpeza simples de cache antigo se passar de 500 itens
    const firstKey = cache.keys().next().value;
    cache.delete(firstKey);
  }
  cache.set(key, { data, expiresAt: Date.now() + CACHE_TTL_MS });
}

// ── Normaliza item Open Food Facts para o nosso formato ──────
function normalizeOpenFoodItem(product) {
  if (!product) return null;
  const nutriments = product.nutriments || {};

  const kcal = nutriments['energy-kcal_100g'] || (nutriments['energy_100g'] ? nutriments['energy_100g'] / 4.184 : 0);
  const protein = nutriments['proteins_100g'] || 0;
  const carbs = nutriments['carbohydrates_100g'] || 0;
  const fat = nutriments['fat_100g'] || 0;
  const fiber = nutriments['fiber_100g'] || 0;

  // Só retorna item com ao menos calorias ou proteína
  if (kcal === 0 && protein === 0) return null;

  return {
    id: `off_${product.code || product._id || Math.random().toString(36).substr(2, 9)}`,
    name: (product.product_name_pt || product.product_name || 'Produto sem nome').trim(),
    brand: (product.brands || '').split(',')[0].trim() || 'Desconhecida',
    category: 'industrialized',
    kcal: Math.round(kcal),
    protein: Math.round(protein * 10) / 10,
    carbs: Math.round(carbs * 10) / 10,
    fat: Math.round(fat * 10) / 10,
    fiber: Math.round(fiber * 10) / 10,
    portionG: 100,
    source: 'Open Food Facts',
  };
}

// ── Busca na Open Food Facts API por texto ───────────────────
function fetchOpenFoodFacts(query) {
  const cacheKey = `search_${query.toLowerCase()}`;
  const cached = getCached(cacheKey);
  if (cached) return Promise.resolve(cached);

  return new Promise((resolve) => {
    const encodedQuery = encodeURIComponent(query);
    const url = `https://world.openfoodfacts.org/cgi/search.pl?search_terms=${encodedQuery}&search_simple=1&action=process&json=1&page_size=12&fields=code,product_name,product_name_pt,brands,nutriments,_id&country_tags=brasil&sort_by=popularity_key`;

    const req = https.get(url, { timeout: 8000 }, (res) => {
      let data = '';
      res.on('data', (chunk) => (data += chunk));
      res.on('end', () => {
        try {
          const json = JSON.parse(data);
          const products = (json.products || [])
            .map(normalizeOpenFoodItem)
            .filter((p) => p !== null)
            .slice(0, 10);
          setCached(cacheKey, products);
          resolve(products);
        } catch {
          resolve([]);
        }
      });
    });

    req.on('error', () => resolve([]));
    req.on('timeout', () => {
      req.destroy();
      resolve([]);
    });
  });
}

// ── Busca por Código de Barras (EAN / Barcode) ───────────────
function fetchByBarcode(barcode) {
  const cleanBarcode = barcode.replace(/\D/g, '').trim();
  if (!cleanBarcode) return Promise.resolve(null);

  const cacheKey = `barcode_${cleanBarcode}`;
  const cached = getCached(cacheKey);
  if (cached) return Promise.resolve(cached);

  return new Promise((resolve) => {
    const url = `https://world.openfoodfacts.org/api/v2/product/${cleanBarcode}.json`;

    const req = https.get(url, { timeout: 8000 }, (res) => {
      let data = '';
      res.on('data', (chunk) => (data += chunk));
      res.on('end', () => {
        try {
          const json = JSON.parse(data);
          if (json.status === 1 && json.product) {
            const normalized = normalizeOpenFoodItem(json.product);
            if (normalized) {
              setCached(cacheKey, normalized);
              return resolve(normalized);
            }
          }
          resolve(null);
        } catch {
          resolve(null);
        }
      });
    });

    req.on('error', () => resolve(null));
    req.on('timeout', () => {
      req.destroy();
      resolve(null);
    });
  });
}

// ── Busca na base TACO local ─────────────────────────────────
function searchTaco(query) {
  const q = query.toLowerCase().trim();
  return tacoFoods
    .filter((f) => f.name.toLowerCase().includes(q))
    .map((f) => ({
      ...f,
      portionG: 100,
      source: 'TACO (Brasil)',
    }))
    .slice(0, 15);
}

// ═══════════════════════════════════════════════════════════
// BUSCA UNIFICADA
// ═══════════════════════════════════════════════════════════
async function searchFoods(query, category = 'all') {
  if (!query || query.trim().length < 2) {
    return { natural: [], industrialized: [], total: 0 };
  }

  let naturalResults = [];
  let industrializedResults = [];

  if (category === 'all' || category === 'natural') {
    naturalResults = searchTaco(query);
  }

  if (category === 'all' || category === 'industrialized') {
    industrializedResults = await fetchOpenFoodFacts(query);
  }

  const combined = [...naturalResults, ...industrializedResults];

  return {
    natural: naturalResults,
    industrialized: industrializedResults,
    total: combined.length,
  };
}

module.exports = { searchFoods, searchTaco, fetchByBarcode };
