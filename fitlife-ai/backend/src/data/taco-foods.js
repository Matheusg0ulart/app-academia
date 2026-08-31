// backend/src/data/taco-foods.js
// Tabela Brasileira de Composição de Alimentos (TACO) — Valores por 100g

const tacoFoods = [
  // ═══════════════════════════════════════════════════════════
  // CARNES E AVES
  // ═══════════════════════════════════════════════════════════
  { id: 't001', name: 'Frango (peito grelhado)', category: 'natural', kcal: 163, protein: 30.5, carbs: 0, fat: 4.2, fiber: 0, brand: 'TACO' },
  { id: 't002', name: 'Frango (coxa e sobrecoxa assada)', category: 'natural', kcal: 209, protein: 24.3, carbs: 0, fat: 12.1, fiber: 0, brand: 'TACO' },
  { id: 't003', name: 'Carne bovina (patinho cozido)', category: 'natural', kcal: 219, protein: 31.8, carbs: 0, fat: 10.1, fiber: 0, brand: 'TACO' },
  { id: 't004', name: 'Carne bovina (alcatra grelhada)', category: 'natural', kcal: 183, protein: 29.3, carbs: 0, fat: 7.4, fiber: 0, brand: 'TACO' },
  { id: 't005', name: 'Carne bovina (picanha grelhada)', category: 'natural', kcal: 285, protein: 23.5, carbs: 0, fat: 21.0, fiber: 0, brand: 'TACO' },
  { id: 't006', name: 'Carne bovina (coxão mole cozido)', category: 'natural', kcal: 173, protein: 29.8, carbs: 0, fat: 5.8, fiber: 0, brand: 'TACO' },
  { id: 't007', name: 'Carne bovina moída refogada', category: 'natural', kcal: 270, protein: 24.6, carbs: 1.2, fat: 18.2, fiber: 0, brand: 'TACO' },
  { id: 't008', name: 'Tilápia grelhada', category: 'natural', kcal: 128, protein: 26.4, carbs: 0, fat: 2.7, fiber: 0, brand: 'TACO' },
  { id: 't009', name: 'Salmão grelhado', category: 'natural', kcal: 180, protein: 24.0, carbs: 0, fat: 9.2, fiber: 0, brand: 'TACO' },
  { id: 't010', name: 'Atum (em água, enlatado)', category: 'natural', kcal: 119, protein: 26.4, carbs: 0, fat: 1.0, fiber: 0, brand: 'TACO' },
  { id: 't011', name: 'Sardinha grelhada', category: 'natural', kcal: 165, protein: 21.9, carbs: 0, fat: 8.5, fiber: 0, brand: 'TACO' },
  { id: 't012', name: 'Filé de merluza cozido', category: 'natural', kcal: 92, protein: 18.9, carbs: 0, fat: 1.6, fiber: 0, brand: 'TACO' },
  { id: 't013', name: 'Camarão cozido', category: 'natural', kcal: 99, protein: 20.9, carbs: 0, fat: 1.5, fiber: 0, brand: 'TACO' },
  { id: 't014', name: 'Peito de peru cozido', category: 'natural', kcal: 139, protein: 28.2, carbs: 0, fat: 2.7, fiber: 0, brand: 'TACO' },

  // ═══════════════════════════════════════════════════════════
  // OVOS E LATICÍNIOS
  // ═══════════════════════════════════════════════════════════
  { id: 't020', name: 'Ovo de galinha (inteiro cozido)', category: 'natural', kcal: 146, protein: 13.3, carbs: 0.6, fat: 9.5, fiber: 0, brand: 'TACO' },
  { id: 't021', name: 'Clara de ovo cozida', category: 'natural', kcal: 52, protein: 10.9, carbs: 0.8, fat: 0.2, fiber: 0, brand: 'TACO' },
  { id: 't022', name: 'Leite integral', category: 'natural', kcal: 61, protein: 3.2, carbs: 4.7, fat: 3.3, fiber: 0, brand: 'TACO' },
  { id: 't023', name: 'Leite desnatado', category: 'natural', kcal: 35, protein: 3.4, carbs: 5.1, fat: 0.2, fiber: 0, brand: 'TACO' },
  { id: 't024', name: 'Iogurte natural integral', category: 'natural', kcal: 66, protein: 3.5, carbs: 5.3, fat: 3.3, fiber: 0, brand: 'TACO' },
  { id: 't025', name: 'Iogurte natural desnatado', category: 'natural', kcal: 46, protein: 4.4, carbs: 6.5, fat: 0.2, fiber: 0, brand: 'TACO' },
  { id: 't026', name: 'Queijo minas frescal', category: 'natural', kcal: 264, protein: 17.4, carbs: 3.2, fat: 20.2, fiber: 0, brand: 'TACO' },
  { id: 't027', name: 'Queijo prato', category: 'natural', kcal: 358, protein: 26.0, carbs: 1.8, fat: 27.8, fiber: 0, brand: 'TACO' },
  { id: 't028', name: 'Requeijão cremoso', category: 'natural', kcal: 244, protein: 13.1, carbs: 3.0, fat: 20.3, fiber: 0, brand: 'TACO' },
  { id: 't029', name: 'Manteiga sem sal', category: 'natural', kcal: 726, protein: 0.9, carbs: 0, fat: 80.8, fiber: 0, brand: 'TACO' },
  { id: 't030', name: 'Coalhada seca', category: 'natural', kcal: 142, protein: 8.5, carbs: 6.0, fat: 9.2, fiber: 0, brand: 'TACO' },

  // ═══════════════════════════════════════════════════════════
  // CEREAIS E GRÃOS
  // ═══════════════════════════════════════════════════════════
  { id: 't040', name: 'Arroz branco cozido', category: 'natural', kcal: 128, protein: 2.5, carbs: 28.1, fat: 0.2, fiber: 1.6, brand: 'TACO' },
  { id: 't041', name: 'Arroz integral cozido', category: 'natural', kcal: 124, protein: 2.6, carbs: 25.8, fat: 1.0, fiber: 2.7, brand: 'TACO' },
  { id: 't042', name: 'Macarrão cozido (sem molho)', category: 'natural', kcal: 135, protein: 4.7, carbs: 27.1, fat: 0.6, fiber: 1.8, brand: 'TACO' },
  { id: 't043', name: 'Feijão preto cozido', category: 'natural', kcal: 77, protein: 5.0, carbs: 14.0, fat: 0.5, fiber: 8.4, brand: 'TACO' },
  { id: 't044', name: 'Feijão carioca cozido', category: 'natural', kcal: 76, protein: 4.8, carbs: 13.6, fat: 0.5, fiber: 8.5, brand: 'TACO' },
  { id: 't045', name: 'Lentilha cozida', category: 'natural', kcal: 93, protein: 7.8, carbs: 16.1, fat: 0.5, fiber: 7.9, brand: 'TACO' },
  { id: 't046', name: 'Grão-de-bico cozido', category: 'natural', kcal: 129, protein: 7.4, carbs: 22.4, fat: 2.0, fiber: 5.3, brand: 'TACO' },
  { id: 't047', name: 'Aveia em flocos', category: 'natural', kcal: 394, protein: 13.9, carbs: 66.6, fat: 8.5, fiber: 9.1, brand: 'TACO' },
  { id: 't048', name: 'Batata doce cozida', category: 'natural', kcal: 77, protein: 1.4, carbs: 18.4, fat: 0.1, fiber: 2.2, brand: 'TACO' },
  { id: 't049', name: 'Batata inglesa cozida', category: 'natural', kcal: 52, protein: 1.2, carbs: 11.9, fat: 0.1, fiber: 1.8, brand: 'TACO' },
  { id: 't050', name: 'Mandioca cozida', category: 'natural', kcal: 125, protein: 0.6, carbs: 30.1, fat: 0.3, fiber: 1.9, brand: 'TACO' },
  { id: 't051', name: 'Milho cozido', category: 'natural', kcal: 76, protein: 2.4, carbs: 16.1, fat: 1.0, fiber: 1.6, brand: 'TACO' },
  { id: 't052', name: 'Pão francês', category: 'natural', kcal: 300, protein: 8.0, carbs: 58.6, fat: 3.1, fiber: 2.3, brand: 'TACO' },
  { id: 't053', name: 'Pão integral', category: 'natural', kcal: 253, protein: 8.9, carbs: 48.1, fat: 3.5, fiber: 7.0, brand: 'TACO' },
  { id: 't054', name: 'Tapioca (goma crua)', category: 'natural', kcal: 342, protein: 0.5, carbs: 84.5, fat: 0.3, fiber: 0, brand: 'TACO' },
  { id: 't055', name: 'Granola tradicional', category: 'natural', kcal: 441, protein: 10.6, carbs: 64.7, fat: 16.5, fiber: 6.2, brand: 'TACO' },

  // ═══════════════════════════════════════════════════════════
  // FRUTAS
  // ═══════════════════════════════════════════════════════════
  { id: 't060', name: 'Banana prata', category: 'natural', kcal: 98, protein: 1.3, carbs: 26.0, fat: 0.1, fiber: 2.0, brand: 'TACO' },
  { id: 't061', name: 'Maçã com casca', category: 'natural', kcal: 56, protein: 0.3, carbs: 15.2, fat: 0.1, fiber: 2.0, brand: 'TACO' },
  { id: 't062', name: 'Laranja pera', category: 'natural', kcal: 46, protein: 1.0, carbs: 11.8, fat: 0.1, fiber: 2.4, brand: 'TACO' },
  { id: 't063', name: 'Mamão formosa', category: 'natural', kcal: 45, protein: 0.5, carbs: 11.8, fat: 0.1, fiber: 1.8, brand: 'TACO' },
  { id: 't064', name: 'Manga tommy', category: 'natural', kcal: 64, protein: 0.4, carbs: 16.8, fat: 0.3, fiber: 1.6, brand: 'TACO' },
  { id: 't065', name: 'Melancia', category: 'natural', kcal: 33, protein: 0.6, carbs: 8.1, fat: 0.2, fiber: 0.4, brand: 'TACO' },
  { id: 't066', name: 'Uva niagara', category: 'natural', kcal: 69, protein: 0.9, carbs: 17.8, fat: 0.2, fiber: 0.9, brand: 'TACO' },
  { id: 't067', name: 'Morango', category: 'natural', kcal: 30, protein: 0.8, carbs: 7.1, fat: 0.3, fiber: 2.0, brand: 'TACO' },
  { id: 't068', name: 'Abacate', category: 'natural', kcal: 96, protein: 1.2, carbs: 6.0, fat: 8.4, fiber: 6.3, brand: 'TACO' },
  { id: 't069', name: 'Kiwi', category: 'natural', kcal: 61, protein: 0.9, carbs: 14.7, fat: 0.6, fiber: 3.0, brand: 'TACO' },
  { id: 't070', name: 'Abacaxi', category: 'natural', kcal: 48, protein: 0.9, carbs: 11.9, fat: 0.1, fiber: 1.0, brand: 'TACO' },
  { id: 't071', name: 'Goiaba vermelha', category: 'natural', kcal: 54, protein: 2.6, carbs: 9.9, fat: 1.0, fiber: 6.3, brand: 'TACO' },
  { id: 't072', name: 'Pêra', category: 'natural', kcal: 55, protein: 0.4, carbs: 14.9, fat: 0.1, fiber: 3.0, brand: 'TACO' },

  // ═══════════════════════════════════════════════════════════
  // VEGETAIS E LEGUMES
  // ═══════════════════════════════════════════════════════════
  { id: 't080', name: 'Brócolis cozido', category: 'natural', kcal: 29, protein: 3.0, carbs: 5.1, fat: 0.4, fiber: 3.1, brand: 'TACO' },
  { id: 't081', name: 'Espinafre cru', category: 'natural', kcal: 22, protein: 2.9, carbs: 3.3, fat: 0.4, fiber: 2.2, brand: 'TACO' },
  { id: 't082', name: 'Alface crespa crua', category: 'natural', kcal: 11, protein: 1.3, carbs: 1.4, fat: 0.2, fiber: 1.7, brand: 'TACO' },
  { id: 't083', name: 'Cenoura crua', category: 'natural', kcal: 34, protein: 0.6, carbs: 7.7, fat: 0.2, fiber: 3.2, brand: 'TACO' },
  { id: 't084', name: 'Tomate cru', category: 'natural', kcal: 15, protein: 0.9, carbs: 3.1, fat: 0.2, fiber: 1.2, brand: 'TACO' },
  { id: 't085', name: 'Abobrinha cozida', category: 'natural', kcal: 19, protein: 1.2, carbs: 4.0, fat: 0.2, fiber: 1.8, brand: 'TACO' },
  { id: 't086', name: 'Couve-flor cozida', category: 'natural', kcal: 25, protein: 2.4, carbs: 4.7, fat: 0.3, fiber: 2.4, brand: 'TACO' },
  { id: 't087', name: 'Chuchu cozido', category: 'natural', kcal: 22, protein: 0.7, carbs: 5.1, fat: 0.1, fiber: 1.5, brand: 'TACO' },
  { id: 't088', name: 'Pepino cru', category: 'natural', kcal: 12, protein: 0.6, carbs: 2.4, fat: 0.1, fiber: 0.6, brand: 'TACO' },

  // ═══════════════════════════════════════════════════════════
  // OLEAGINOSAS E GORDURAS SAUDÁVEIS
  // ═══════════════════════════════════════════════════════════
  { id: 't090', name: 'Castanha do Pará', category: 'natural', kcal: 656, protein: 14.3, carbs: 15.1, fat: 63.5, fiber: 7.9, brand: 'TACO' },
  { id: 't091', name: 'Amendoim cru', category: 'natural', kcal: 567, protein: 25.8, carbs: 16.1, fat: 49.2, fiber: 8.5, brand: 'TACO' },
  { id: 't092', name: 'Pasta de amendoim', category: 'natural', kcal: 596, protein: 25.1, carbs: 20.1, fat: 49.9, fiber: 5.9, brand: 'TACO' },
  { id: 't093', name: 'Azeite de oliva extra virgem', category: 'natural', kcal: 884, protein: 0, carbs: 0, fat: 100.0, fiber: 0, brand: 'TACO' },
  { id: 't094', name: 'Sementes de chia', category: 'natural', kcal: 490, protein: 16.5, carbs: 42.1, fat: 30.7, fiber: 34.4, brand: 'TACO' },
  { id: 't095', name: 'Linhaça dourada', category: 'natural', kcal: 495, protein: 17.3, carbs: 28.9, fat: 34.0, fiber: 27.3, brand: 'TACO' },

  // ═══════════════════════════════════════════════════════════
  // SUPLEMENTOS FITNESS (valores típicos de mercado)
  // ═══════════════════════════════════════════════════════════
  { id: 't100', name: 'Whey Protein Concentrado', category: 'natural', kcal: 380, protein: 76.0, carbs: 6.0, fat: 6.0, fiber: 0, brand: 'Genérico' },
  { id: 't101', name: 'Whey Protein Isolado', category: 'natural', kcal: 355, protein: 86.0, carbs: 2.0, fat: 1.5, fiber: 0, brand: 'Genérico' },
  { id: 't102', name: 'Creatina monoidratada', category: 'natural', kcal: 0, protein: 0, carbs: 0, fat: 0, fiber: 0, brand: 'Genérico' },
  { id: 't103', name: 'BCAA pó', category: 'natural', kcal: 200, protein: 50.0, carbs: 0, fat: 0, fiber: 0, brand: 'Genérico' },
];

module.exports = tacoFoods;
