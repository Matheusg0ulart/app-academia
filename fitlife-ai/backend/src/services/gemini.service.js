// backend/src/services/gemini.service.js
//
// Serviço de Integração com a API Google Gemini (Vision + Text)
// Usado para: análise visual de pratos, chat inteligente contextual

const { GoogleGenerativeAI } = require('@google/generative-ai');

let _genAI = null;

function getClient() {
  if (!_genAI) {
    const apiKey = process.env.GEMINI_API_KEY;
    if (!apiKey || apiKey === 'YOUR_GEMINI_API_KEY_HERE') {
      const err = new Error(
        'GEMINI_API_KEY não configurada. Acesse https://aistudio.google.com/app/apikey para obter sua chave gratuita e adicione em backend/.env'
      );
      err.statusCode = 503;
      throw err;
    }
    _genAI = new GoogleGenerativeAI(apiKey);
  }
  return _genAI;
}

const GeminiService = {
  /**
   * Analisa uma imagem de prato de comida usando Gemini Vision.
   * @param {string} base64Image - Imagem em Base64 (sem prefixo data:image/...)
   * @param {string} mimeType - Tipo da imagem ('image/jpeg' | 'image/png' | 'image/webp')
   * @returns {Promise<Object>} Análise com lista de alimentos, porções e macros estimados
   */
  async analyzeFoodPlate(base64Image, mimeType = 'image/jpeg') {
    const genAI = getClient();
    const model = genAI.getGenerativeModel({ model: 'gemini-1.5-flash' });

    const prompt = `Você é um nutricionista especializado em análise visual de refeições brasileiras e internacionais.

Analise esta imagem de um prato de comida e forneça uma análise nutricional detalhada.

Responda EXCLUSIVAMENTE em JSON válido, sem nenhum texto adicional fora do JSON, seguindo exatamente este formato:
{
  "plateDescription": "Descrição geral do prato (1-2 frases)",
  "items": [
    {
      "name": "Nome do alimento em português",
      "portionDescription": "Descrição da porção (ex: '2 conchas', '150g', '1 filé médio')",
      "estimatedGrams": 150,
      "calories": 245,
      "protein": 32.0,
      "carbs": 0.0,
      "fat": 12.0,
      "confidence": "alta"
    }
  ],
  "totalCalories": 650,
  "totalProtein": 45.0,
  "totalCarbs": 60.0,
  "totalFat": 18.0,
  "healthScore": 8,
  "observations": "Observações sobre a refeição e sugestões nutricionais",
  "isHealthy": true
}

Importante:
- Liste CADA alimento identificado separadamente
- Estime as porções visualmente com base no tamanho do prato
- Use alimentos comuns da dieta brasileira (arroz, feijão, frango grelhado, etc.) quando aplicável
- Se não conseguir identificar claramente um alimento, estime com base no que parece ser
- healthScore vai de 1 (péssimo) a 10 (excelente)
- confidence pode ser "alta", "média" ou "baixa"`;

    const result = await model.generateContent([
      { text: prompt },
      {
        inlineData: {
          mimeType,
          data: base64Image,
        },
      },
    ]);

    const responseText = result.response.text();

    // Remove blocos de código markdown se presentes
    const cleaned = responseText
      .replace(/```json\n?/g, '')
      .replace(/```\n?/g, '')
      .trim();

    let parsed;
    try {
      parsed = JSON.parse(cleaned);
    } catch {
      // Tenta extrair JSON mesmo se houver texto extra
      const jsonMatch = cleaned.match(/\{[\s\S]*\}/);
      if (jsonMatch) {
        parsed = JSON.parse(jsonMatch[0]);
      } else {
        throw new Error('Resposta da IA não pôde ser processada. Tente novamente com uma imagem mais nítida.');
      }
    }

    return {
      plateDescription: parsed.plateDescription || 'Prato analisado',
      items: (parsed.items || []).map((item) => ({
        name: item.name || 'Alimento não identificado',
        portionDescription: item.portionDescription || 'Porção estimada',
        estimatedGrams: Number(item.estimatedGrams || 100),
        calories: Number(item.calories || 0),
        protein: Number(item.protein || 0),
        carbs: Number(item.carbs || 0),
        fat: Number(item.fat || 0),
        confidence: item.confidence || 'média',
      })),
      totalCalories: Number(parsed.totalCalories || 0),
      totalProtein: Number(parsed.totalProtein || 0),
      totalCarbs: Number(parsed.totalCarbs || 0),
      totalFat: Number(parsed.totalFat || 0),
      healthScore: Number(parsed.healthScore || 5),
      observations: parsed.observations || '',
      isHealthy: parsed.isHealthy ?? true,
    };
  },

  /**
   * Chat contextual com o assistente de saúde/fitness via Gemini Text.
   * @param {string} message - Pergunta do usuário
   * @param {Object} userContext - Dados do usuário para contexto (peso, meta, etc.)
   * @returns {Promise<string>} Resposta do assistente
   */
  async chatWithAssistant(message, userContext = {}) {
    const genAI = getClient();
    const model = genAI.getGenerativeModel({ model: 'gemini-1.5-flash' });

    const systemContext = `Você é o FitLife AI, um assistente especializado em saúde, fitness, nutrição esportiva e bem-estar. 
Você é direto, prático e motivador. Responda sempre em português brasileiro.
Contexto do usuário: peso ${userContext.weight || '--'} kg, meta: ${userContext.goal || 'saúde geral'}, nível: ${userContext.activityLevel || 'moderado'}.
IMPORTANTE: Recuse qualquer pergunta não relacionada a saúde, treino, nutrição ou bem-estar.`;

    const result = await model.generateContent(`${systemContext}\n\nUsuário: ${message}`);
    return result.response.text();
  },
};

module.exports = GeminiService;
