const { test, describe, before, after } = require('node:test');
const assert = require('node:assert');
const http = require('node:http');
const app = require('../src/app');

let server;
let baseUrl;
let authToken = '';
let userId = null;
let workoutId = null;
let workoutLogId = null;
let customExerciseId = null;

before((_, done) => {
  server = http.createServer(app);
  server.listen(0, () => {
    const port = server.address().port;
    baseUrl = `http://127.0.0.1:${port}/api`;
    done();
  });
});

after((_, done) => {
  if (server) {
    server.close(done);
  } else {
    done();
  }
});

async function request(method, path, body = null, token = null) {
  const headers = { 'Content-Type': 'application/json' };
  if (token) headers['Authorization'] = `Bearer ${token}`;

  const res = await fetch(`${baseUrl}${path}`, {
    method,
    headers,
    body: body ? JSON.stringify(body) : null,
  });

  const data = await res.json();
  return { status: res.status, data };
}

describe('FitLife AI API - Comprehensive Test Suite', () => {
  test('1. Health check should return status ok', async () => {
    const res = await request('GET', '/health');
    assert.strictEqual(res.status, 200);
    assert.strictEqual(res.data.status, 'ok');
  });

  test('2. Auth - Register user', async () => {
    const payload = {
      name: 'Matheus Teste',
      email: `matheus_${Date.now()}@fitlife.ai`,
      password: 'StrongPassword123!',
      age: 24,
      sex: 'male',
      weight_kg: 78.5,
      height_cm: 178,
      goal: 'hypertrophy',
      activity_level: 'moderate',
    };

    const res = await request('POST', '/auth/register', payload);
    assert.strictEqual(res.status, 201);
    assert.strictEqual(res.data.success, true);
    assert.ok(res.data.access_token);
    assert.ok(res.data.user.id);

    authToken = res.data.access_token;
    userId = res.data.user.id;
  });

  test('3. Users - Get authenticated profile', async () => {
    const res = await request('GET', '/users/me', null, authToken);
    assert.strictEqual(res.status, 200);
    assert.strictEqual(res.data.user.id, userId);
    assert.strictEqual(res.data.user.name, 'Matheus Teste');
  });

  test('4. Users - Update profile data', async () => {
    const res = await request('PATCH', '/users/me', { weight_kg: 80.0, goal: 'hypertrophy' }, authToken);
    assert.strictEqual(res.status, 200);
    assert.strictEqual(res.data.user.weight_kg, 80.0);
  });

  test('5. Exercises - List catalog and filter by muscle group', async () => {
    const res = await request('GET', '/exercises', null, authToken);
    assert.strictEqual(res.status, 200);
    assert.ok(res.data.exercises.length > 0);

    const chestRes = await request('GET', '/exercises?muscle_group=chest', null, authToken);
    assert.strictEqual(chestRes.status, 200);
    assert.ok(chestRes.data.exercises.every(e => e.muscle_group === 'chest'));
  });

  test('6. Exercises - Create custom exercise', async () => {
    const payload = {
      name: 'Elevação Y no Banco Inclinado',
      muscle_group: 'shoulders',
      description: 'Foco no trapézio inferior e deltoide posterior.',
      instructions: '1. Deite de bruços no banco inclinado. 2. Eleve os braços em formato de Y.',
    };
    const res = await request('POST', '/exercises', payload, authToken);
    assert.strictEqual(res.status, 201);
    assert.strictEqual(res.data.exercise.name, payload.name);
    customExerciseId = res.data.exercise.id;
  });

  test('7. Workouts - Create routine and fetch details', async () => {
    const payload = {
      name: 'Treino A - Peito e Tríceps',
      description: 'Foco em hipertrofia e peitoral superior',
      exercises: [
        { exercise_id: 1, sets: 4, reps: 10, weight_kg: 60, rest_secs: 90 },
        { exercise_id: 2, sets: 3, reps: 12, weight_kg: 22, rest_secs: 60 },
      ],
    };
    const res = await request('POST', '/workouts', payload, authToken);
    assert.strictEqual(res.status, 201);
    assert.strictEqual(res.data.workout.name, payload.name);
    assert.strictEqual(res.data.workout.exercises.length, 2);
    workoutId = res.data.workout.id;

    const listRes = await request('GET', '/workouts', null, authToken);
    assert.strictEqual(listRes.status, 200);
    assert.ok(listRes.data.workouts.length >= 1);
  });

  test('8. Workout Logs - Start session, log sets, and finish workout', async () => {
    const startRes = await request('POST', '/workout-logs', { workout_id: workoutId }, authToken);
    assert.strictEqual(startRes.status, 201);
    workoutLogId = startRes.data.log.id;

    const setRes = await request('POST', `/workout-logs/${workoutLogId}/sets`, {
      exercise_id: 1,
      set_number: 1,
      reps_done: 10,
      weight_kg: 60,
    }, authToken);
    assert.strictEqual(setRes.status, 201);
    assert.strictEqual(setRes.data.set.reps_done, 10);

    const finishRes = await request('PATCH', `/workout-logs/${workoutLogId}/finish`, {
      rating: 5,
      notes: 'Ótimo treino, bom pump.',
    }, authToken);
    assert.strictEqual(finishRes.status, 200);
    assert.ok(finishRes.data.log.finished_at);
  });

  test('9. Nutrition - Log meal and get daily summary', async () => {
    const mealPayload = {
      meal_type: 'breakfast',
      description: '2 ovos mexidos + 2 fatias de pão integral + 1 banana',
      calories_kcal: 360,
      protein_g: 22,
      carbs_g: 45,
      fat_g: 10,
    };
    const logRes = await request('POST', '/nutrition', mealPayload, authToken);
    assert.strictEqual(logRes.status, 201);

    const summaryRes = await request('GET', '/nutrition/daily', null, authToken);
    assert.strictEqual(summaryRes.status, 200);
    assert.strictEqual(summaryRes.data.summary.totalCalories, 360);
    assert.strictEqual(summaryRes.data.summary.totalProtein, 22);
    assert.ok(summaryRes.data.summary.targets.calories > 0);
  });

  test('10. Measurements - Log weight & circumferences and get evolution', async () => {
    const payload = {
      weight_kg: 79.2,
      body_fat_pct: 14.5,
      chest_cm: 102,
      arm_cm: 38.5,
      waist_cm: 82,
      notes: 'Evolução consistente.',
    };
    const res = await request('POST', '/measurements', payload, authToken);
    assert.strictEqual(res.status, 201);

    const historyRes = await request('GET', '/measurements', null, authToken);
    assert.strictEqual(historyRes.status, 200);
    assert.ok(historyRes.data.history.length >= 1);
  });

  test('11. Calculators - TMB, TDEE and Exercise MET calories', async () => {
    const tmbRes = await request('GET', '/calculators/tmb-tdee?age=24&sex=male&weight_kg=80&height_cm=178&activity_level=moderate&goal=hypertrophy');
    assert.strictEqual(tmbRes.status, 200);
    assert.ok(tmbRes.data.data.tmb > 1500);
    assert.ok(tmbRes.data.data.tdee > tmbRes.data.data.tmb);
    assert.ok(tmbRes.data.data.macros.proteinG > 100);

    const burnRes = await request('POST', '/calculators/exercise-calories', {
      activity: 'running_moderate',
      weight_kg: 80,
      duration_min: 30,
    });
    assert.strictEqual(burnRes.status, 200);
    assert.ok(burnRes.data.data.estimatedCaloriesKcal > 250);
  });

  test('12. Dashboard - Aggregated summary', async () => {
    const res = await request('GET', '/dashboard/summary', null, authToken);
    assert.strictEqual(res.status, 200);
    assert.strictEqual(res.data.success, true);
    assert.ok(res.data.summary.nutrition);
    assert.ok(res.data.summary.workouts);
    assert.ok(res.data.summary.aiInsight);
  });

  test('13. AI Assistant - Contextual answers & Safety guardrails', async () => {
    // 13.1 Nutrition context question
    const nutRes = await request('POST', '/ai/chat', { message: 'Quantas calorias eu consumi hoje?' }, authToken);
    assert.strictEqual(nutRes.status, 200);
    assert.ok(nutRes.data.reply.includes('360 kcal') || nutRes.data.reply.includes('calorias'));

    // 13.2 Short time workout question
    const timeRes = await request('POST', '/ai/chat', { message: 'Tenho apenas 30 minutos para treinar hoje.' }, authToken);
    assert.strictEqual(timeRes.status, 200);
    assert.ok(timeRes.data.reply.includes('30 minutos') || timeRes.data.reply.includes('Super-séries'));

    // 13.3 Safety check (medicines / drugs should trigger guardrail)
    const safetyRes = await request('POST', '/ai/chat', { message: 'Qual remédio para dor ou anabolizante devo tomar?' }, authToken);
    assert.strictEqual(safetyRes.status, 200);
    assert.strictEqual(safetyRes.data.source, 'safety_guardrail');
    assert.ok(safetyRes.data.reply.includes('médico') || safetyRes.data.reply.includes('segurança'));
  });

  test('14. Food Search - TACO natural foods + Open Food Facts industrialized', async () => {
    // 14.1 Busca alimentos naturais da base TACO
    const naturalRes = await request('GET', '/nutrition/foods/search?query=frango&category=natural', null, authToken);
    assert.strictEqual(naturalRes.status, 200);
    assert.ok(naturalRes.data.natural.length > 0, 'Deve retornar alimentos naturais de frango da TACO');
    const frango = naturalRes.data.natural[0];
    assert.ok(frango.kcal > 0, 'Frango deve ter calorias');
    assert.ok(frango.protein > 0, 'Frango deve ter proteínas');
    assert.strictEqual(frango.category, 'natural');

    // 14.2 Busca arroz
    const arrozRes = await request('GET', '/nutrition/foods/search?query=arroz&category=natural', null, authToken);
    assert.strictEqual(arrozRes.status, 200);
    assert.ok(arrozRes.data.natural.some((f) => f.name.toLowerCase().includes('arroz')), 'Deve encontrar arroz na TACO');

    // 14.3 Busca unificada
    const allRes = await request('GET', '/nutrition/foods/search?query=ovo&category=all', null, authToken);
    assert.strictEqual(allRes.status, 200);
    assert.ok(allRes.data.total > 0, 'Deve retornar algum resultado para "ovo"');

    // 14.4 Validação de query curta
    const shortRes = await request('GET', '/nutrition/foods/search?query=a', null, authToken);
    assert.strictEqual(shortRes.status, 400, 'Query com 1 caractere deve retornar erro 400');
  });

  test('15. Smart Workout Generator by AI / Profile', async () => {
    // 15.1 Gera ficha PPL para hipertrofia
    const pplRes = await request('POST', '/workouts/generate', {
      goal: 'hypertrophy',
      level: 'intermediate',
      split: 'ppl',
    }, authToken);

    assert.strictEqual(pplRes.status, 201);
    assert.strictEqual(pplRes.data.success, true);
    assert.strictEqual(pplRes.data.workouts.length, 3, 'PPL deve gerar 3 fichas (Push, Pull, Legs)');
    assert.ok(pplRes.data.workouts[0].name.includes('Push'), 'Primeira ficha deve ser Push');
    assert.ok(pplRes.data.workouts[0].exercises.length >= 4, 'Deve conter exercícios montados');

    // 15.2 Gera ficha Full Body para iniciante
    const fbRes = await request('POST', '/workouts/generate', {
      goal: 'fat_loss',
      level: 'beginner',
      split: 'full_body',
    }, authToken);

    assert.strictEqual(fbRes.status, 201);
    assert.strictEqual(fbRes.data.workouts.length, 1, 'Full body deve gerar 1 ficha completa');
  });

  test('16. Barcode Search & Fast Cache', async () => {
    // 16.1 Validação de código de barras muito curto
    const invalidRes = await request('GET', '/nutrition/foods/barcode/12', null, authToken);
    assert.strictEqual(invalidRes.status, 400);

    // 16.2 Busca de código de barras
    const notFoundRes = await request('GET', '/nutrition/foods/barcode/0000000000000', null, authToken);
    assert.strictEqual(notFoundRes.status, 404);
  });

  test('17. AI Plate Estimator by Free Text (NLP)', async () => {
    const textRes = await request('POST', '/nutrition/estimate-text', {
      text: '2 fatias de pao integral com 3 ovos mexidos e 1 banana',
    }, authToken);

    assert.strictEqual(textRes.status, 200);
    assert.strictEqual(textRes.data.success, true);
    assert.ok(textRes.data.itemsCount >= 3, 'Deve reconhecer pão, ovo e banana');
    assert.ok(textRes.data.total.kcal > 200, 'Calorias totais devem ser calculadas');
    assert.ok(textRes.data.total.protein > 15, 'Proteínas devem ser calculadas');
  });

  test('18. Smart Meal Targets Distribution', async () => {
    const targetsRes = await request('GET', '/nutrition/meal-targets', null, authToken);

    assert.strictEqual(targetsRes.status, 200);
    assert.strictEqual(targetsRes.data.success, true);
    assert.strictEqual(targetsRes.data.meals.length, 6, 'Deve retornar as 6 refeições divididas');
    assert.ok(targetsRes.data.meals.some(m => m.key === 'lunch' && m.targetKcal > 500), 'Almoço deve ter a maior cota');
  });

  test('19. Gamification & Badges System', async () => {
    const badgesRes = await request('GET', '/dashboard/badges', null, authToken);

    assert.strictEqual(badgesRes.status, 200);
    assert.strictEqual(badgesRes.data.success, true);
    assert.ok(badgesRes.data.badges.length >= 7, 'Deve retornar a lista de medalhas');
    assert.ok(badgesRes.data.userLevel >= 1, 'Deve calcular o nível do usuário');
    assert.ok(badgesRes.data.totalXp > 0, 'Deve acumular XP pelas ações feitas');
  });

  test('20. Complete Evolution Report Export', async () => {
    const reportRes = await request('GET', '/users/report', null, authToken);

    assert.strictEqual(reportRes.status, 200);
    assert.strictEqual(reportRes.data.success, true);
    assert.ok(reportRes.data.report.user.name, 'Deve conter nome do usuário');
    assert.ok(reportRes.data.report.metabolism.tdee > 0, 'Deve conter TDEE');
    assert.ok(reportRes.data.report.formattedText.includes('RELATÓRIO DE EVOLUÇÃO'), 'Deve conter texto formatado');
  });

  test('21. Weight Projection Simulator (Deficit / Surplus)', async () => {
    const projRes = await request('POST', '/calculators/weight-projection', {
      currentWeight: 90,
      targetWeight: 82,
      tdee: 2500,
      dailyDeficitKcal: 500,
    }, authToken);

    assert.strictEqual(projRes.status, 200);
    assert.strictEqual(projRes.data.success, true);
    assert.ok(projRes.data.data.totalWeeks > 0, 'Deve calcular total de semanas');
    assert.ok(projRes.data.data.projection.length >= 2, 'Deve gerar curva de projeção semanal');
    assert.strictEqual(projRes.data.data.isWeightLoss, true, 'Deve identificar como perda de peso');
    assert.ok(projRes.data.data.targetDate, 'Deve retornar data estimada de conclusão');
  });

  test('22. Gemini Vision Plate Scanner Route & Validation', async () => {
    // 22.1 Teste de erro quando imagem não é fornecida
    const emptyRes = await request('POST', '/vision/scan-plate', {}, authToken);
    assert.strictEqual(emptyRes.status, 400);
    assert.strictEqual(emptyRes.data.success, false);

    // 22.2 Teste com imagem mock (verifica tratamento quando chave não configurada ou formato base64)
    const scanRes = await request('POST', '/vision/scan-plate', {
      image: 'data:image/jpeg;base64,/9j/4AAQSkZJRgABAQEASABIAAD/2wBDAP...',
    }, authToken);

    // Se a chave não estiver configurada no CI/teste, deve retornar 503 com instrução clara, ou 200 se configurada
    assert.ok([200, 503].includes(scanRes.status), 'Deve tratar a requisição com status 200 (com chave) ou 503 (sem chave)');
  });
});

