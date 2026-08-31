// backend/src/services/ai-meal-estimator.service.js
//
// Serviço de Inteligência para Nutrição:
//   1. Interpretação em linguagem natural de pratos e refeições (Texto Livre -> Alimentos TACO + Gramas + Macros)
//   2. Divisão inteligente de metas calóricas e proteicas por refeição

const tacoFoods = require('../data/taco-foods');

// ── Dicionário de sinônimos e termos comuns da culinária brasileira ──
const FOOD_RULES = [
  // Proteínas
  { keywords: ['frango', 'peito de frango', 'file de frango', 'bife de frango', 'frango grelhado'], tacoId: 't001', defaultPortionG: 120, unitG: { 'bife': 120, 'file': 120, 'pedaco': 100, 'colher': 30 } },
  { keywords: ['carne', 'patinho', 'bife de carne', 'carne moida', 'alcatra', 'picanha'], tacoId: 't003', defaultPortionG: 120, unitG: { 'bife': 120, 'file': 120, 'pedaco': 100, 'colher': 35 } },
  { keywords: ['tilapia', 'peixe', 'file de peixe', 'salmao'], tacoId: 't008', defaultPortionG: 130, unitG: { 'file': 130, 'posta': 150 } },
  { keywords: ['ovo', 'ovos', 'ovo cozido', 'ovo frito', 'ovos mexidos'], tacoId: 't020', defaultPortionG: 50, unitG: { 'un': 50, 'unidade': 50, 'ovo': 50, 'ovos': 50 } },
  { keywords: ['clara', 'claras', 'clara de ovo'], tacoId: 't021', defaultPortionG: 35, unitG: { 'un': 35, 'clara': 35 } },
  { keywords: ['whey', 'whey protein', 'proteina em po'], tacoId: 't100', defaultPortionG: 30, unitG: { 'dose': 30, 'scoop': 30, 'colher': 15 } },

  // Carboidratos & Grãos
  { keywords: ['arroz', 'arroz branco', 'arroz cozido'], tacoId: 't040', defaultPortionG: 100, unitG: { 'colher': 25, 'escumadeira': 100, 'xicara': 150 } },
  { keywords: ['arroz integral'], tacoId: 't041', defaultPortionG: 100, unitG: { 'colher': 25, 'escumadeira': 100, 'xicara': 150 } },
  { keywords: ['feijao', 'feijao preto', 'feijao carioca'], tacoId: 't044', defaultPortionG: 85, unitG: { 'concha': 85, 'colher': 30, 'xicara': 170 } },
  { keywords: ['batata doce', 'batata-doce'], tacoId: 't048', defaultPortionG: 150, unitG: { 'un': 150, 'unidade': 150, 'rodela': 30 } },
  { keywords: ['batata', 'batata inglesa', 'pure de batata'], tacoId: 't049', defaultPortionG: 150, unitG: { 'un': 150, 'colher': 40 } },
  { keywords: ['mandioca', 'aipim', 'macaxeira'], tacoId: 't050', defaultPortionG: 120, unitG: { 'pedaco': 60 } },
  { keywords: ['pao', 'pao frances', 'pao de sal'], tacoId: 't052', defaultPortionG: 50, unitG: { 'un': 50, 'unidade': 50, 'pao': 50 } },
  { keywords: ['pao integral', 'fatia de pao'], tacoId: 't053', defaultPortionG: 25, unitG: { 'fatia': 25, 'fatias': 25 } },
  { keywords: ['aveia', 'aveia em flocos', 'farinha de aveia'], tacoId: 't047', defaultPortionG: 30, unitG: { 'colher': 15, 'xicara': 80 } },
  { keywords: ['tapioca', 'goma de tapioca'], tacoId: 't054', defaultPortionG: 60, unitG: { 'colher': 20 } },
  { keywords: ['macarrao', 'massa', 'espaguete'], tacoId: 't042', defaultPortionG: 140, unitG: { 'pegador': 70, 'prato': 200 } },

  // Frutas & Vegetais
  { keywords: ['banana', 'banana prata'], tacoId: 't060', defaultPortionG: 80, unitG: { 'un': 80, 'unidade': 80, 'banana': 80 } },
  { keywords: ['maca', 'maca fuji'], tacoId: 't061', defaultPortionG: 130, unitG: { 'un': 130, 'unidade': 130, 'maca': 130 } },
  { keywords: ['laranja'], tacoId: 't062', defaultPortionG: 150, unitG: { 'un': 150 } },
  { keywords: ['morango', 'morangos'], tacoId: 't067', defaultPortionG: 100, unitG: { 'un': 15, 'unidade': 15 } },
  { keywords: ['abacate'], tacoId: 't068', defaultPortionG: 100, unitG: { 'colher': 30, 'metade': 100 } },
  { keywords: ['brocolis'], tacoId: 't080', defaultPortionG: 80, unitG: { 'ramo': 40, 'colher': 30 } },
  { keywords: ['alface', 'salada de alface'], tacoId: 't082', defaultPortionG: 30, unitG: { 'folha': 10, 'prato': 50 } },
  { keywords: ['tomate'], tacoId: 't084', defaultPortionG: 80, unitG: { 'un': 80, 'rodela': 20 } },

  // Laticínios e Gorduras
  { keywords: ['leite', 'leite integral'], tacoId: 't022', defaultPortionG: 200, unitG: { 'copo': 200, 'ml': 1, 'xicara': 200 } },
  { keywords: ['leite desnatado'], tacoId: 't023', defaultPortionG: 200, unitG: { 'copo': 200, 'ml': 1 } },
  { keywords: ['queijo', 'queijo minas', 'queijo branco'], tacoId: 't026', defaultPortionG: 30, unitG: { 'fatia': 30 } },
  { keywords: ['azeite', 'azeite de oliva'], tacoId: 't093', defaultPortionG: 10, unitG: { 'colher': 10, 'fio': 5 } },
  { keywords: ['pasta de amendoim'], tacoId: 't092', defaultPortionG: 20, unitG: { 'colher': 20 } },
];

function normalizeText(str) {
  return str
    .toLowerCase()
    .normalize('NFD')
    .replace(/[\u0300-\u036f]/g, '') // remove acentos
    .replace(/[,;+]/g, ' ')
    .trim();
}

/**
 * Interpreta uma frase em linguagem natural e extrai os alimentos reconhecidos.
 * @param {string} text - Ex: "2 fatias de pao integral com 3 ovos mexidos e 1 banana"
 */
function estimateMealFromText(text) {
  if (!text || text.trim().length < 3) {
    return { items: [], total: { kcal: 0, protein: 0, carbs: 0, fat: 0 } };
  }

  const cleanText = normalizeText(text);
  const matchedItems = [];

  for (const rule of FOOD_RULES) {
    for (const keyword of rule.keywords) {
      const normKeyword = normalizeText(keyword);
      const regex = new RegExp(`(?:(\\d+(?:[.,]\\d+)?)\\s*([a-zA-Z]+)?\\s*(?:de\\s*)?)?${normKeyword}`, 'i');
      const match = cleanText.match(regex);

      if (match) {
        const fullMatch = match[0];
        const numStr = match[1];
        const unitStr = match[2] ? normalizeText(match[2]) : null;

        let quantity = numStr ? parseFloat(numStr.replace(',', '.')) : 1;
        let grams = rule.defaultPortionG;

        if (numStr) {
          if (unitStr && rule.unitG && rule.unitG[unitStr]) {
            grams = quantity * rule.unitG[unitStr];
          } else if (unitStr === 'g' || unitStr === 'gramas') {
            grams = quantity;
          } else {
            grams = quantity * rule.defaultPortionG;
          }
        }

        const tacoItem = tacoFoods.find((f) => f.id === rule.tacoId);
        if (tacoItem && !matchedItems.some((m) => m.id === tacoItem.id)) {
          const ratio = grams / 100.0;
          matchedItems.push({
            id: tacoItem.id,
            name: tacoItem.name,
            portionG: Math.round(grams),
            portionLabel: `${Math.round(grams)}g (${fullMatch.trim()})`,
            kcal: Math.round(tacoItem.kcal * ratio),
            protein: Math.round(tacoItem.protein * ratio * 10) / 10,
            carbs: Math.round(tacoItem.carbs * ratio * 10) / 10,
            fat: Math.round(tacoItem.fat * ratio * 10) / 10,
          });
        }
        break; // Match encontrado para este alimento
      }
    }
  }

  const total = matchedItems.reduce(
    (acc, cur) => ({
      kcal: acc.kcal + cur.kcal,
      protein: Math.round((acc.protein + cur.protein) * 10) / 10,
      carbs: Math.round((acc.carbs + cur.carbs) * 10) / 10,
      fat: Math.round((acc.fat + cur.fat) * 10) / 10,
    }),
    { kcal: 0, protein: 0, carbs: 0, fat: 0 }
  );

  return {
    rawText: text,
    itemsCount: matchedItems.length,
    items: matchedItems,
    total,
  };
}

/**
 * Divisão Inteligente de Metas por Refeição
 * @param {number} dailyCalories - Ex: 2200
 * @param {number} dailyProteinG - Ex: 140
 * @param {number} dailyCarbsG - Ex: 250
 * @param {number} dailyFatG - Ex: 65
 */
function calculateMealTargets(dailyCalories = 2200, dailyProteinG = 140, dailyCarbsG = 250, dailyFatG = 65) {
  const distribution = [
    { key: 'breakfast', name: 'Café da Manhã', pctCal: 0.22, pctProt: 0.22, icon: 'wb_sunny' },
    { key: 'morning_snack', name: 'Lanche da Manhã', pctCal: 0.08, pctProt: 0.08, icon: 'apple' },
    { key: 'lunch', name: 'Almoço', pctCal: 0.32, pctProt: 0.32, icon: 'lunch_dining' },
    { key: 'afternoon_snack', name: 'Lanche da Tarde', pctCal: 0.12, pctProt: 0.15, icon: 'cookie' },
    { key: 'dinner', name: 'Jantar', pctCal: 0.20, pctProt: 0.20, icon: 'nightlight_round' },
    { key: 'supper', name: 'Ceia', pctCal: 0.06, pctProt: 0.03, icon: 'bedtime' },
  ];

  return distribution.map((meal) => ({
    key: meal.key,
    name: meal.name,
    targetKcal: Math.round(dailyCalories * meal.pctCal),
    targetProteinG: Math.round(dailyProteinG * meal.pctProt),
    targetCarbsG: Math.round(dailyCarbsG * meal.pctCal),
    targetFatG: Math.round(dailyFatG * meal.pctCal),
    pct: Math.round(meal.pctCal * 100),
  }));
}

module.exports = { estimateMealFromText, calculateMealTargets };

