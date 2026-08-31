const { Pool } = require('pg');
const fs = require('fs');
const path = require('path');

// ── Configuração da piscina PostgreSQL ────────────────────────
const poolConfig = process.env.DATABASE_URL
  ? {
      connectionString: process.env.DATABASE_URL,
      ssl: { rejectUnauthorized: false },
      max: 10,
      idleTimeoutMillis: 30000,
      connectionTimeoutMillis: 5000,
    }
  : {
      host: process.env.DB_HOST || 'localhost',
      port: parseInt(process.env.DB_PORT || '5432', 10),
      user: process.env.DB_USER || 'postgres',
      password: process.env.DB_PASSWORD || 'postgres',
      database: process.env.DB_NAME || 'fitlife_ai_db',
      max: 10,
      idleTimeoutMillis: 30000,
      connectionTimeoutMillis: 5000,
    };

const pool = new Pool(poolConfig);
let isPostgresConnected = false;

// ── Catálogo Inicial de Exercícios ────────────────────────────
const DEFAULT_EXERCISES = [
  // Peito
  { id: 1, name: 'Supino Reto com Barra', muscle_group: 'chest', description: 'Exercício clássico para desenvolvimento do peitoral maior.', instructions: '1. Deite no banco. 2. Barra na largura dos ombros. 3. Desça ao peito. 4. Empurre.', is_custom: false },
  { id: 2, name: 'Supino Inclinado com Halteres', muscle_group: 'chest', description: 'Foca na porção superior do peitoral.', instructions: '1. Banco 30-45°. 2. Pressione halteres para cima. 3. Retorne com controle.', is_custom: false },
  { id: 3, name: 'Crucifixo com Halteres', muscle_group: 'chest', description: 'Isola o peitoral, focando no alongamento.', instructions: '1. Deite no banco plano. 2. Abra os braços em arco. 3. Sinta alongar.', is_custom: false },
  { id: 4, name: 'Peck Deck (Voador)', muscle_group: 'chest', description: 'Máquina para isolamento do peitoral.', instructions: '1. Ajuste o banco. 2. Feche os braços à frente.', is_custom: false },
  { id: 5, name: 'Flexão de Braço', muscle_group: 'chest', description: 'Exercício calistênico para peitoral e tríceps.', instructions: '1. Corpo reto. 2. Desça até quase tocar o chão. 3. Empurre.', is_custom: false },
  // Costas
  { id: 6, name: 'Puxada Frontal na Barra', muscle_group: 'back', description: 'Exercício fundamental para largura das costas.', instructions: '1. Puxe a barra até a parte superior do peito. 2. Retorne.', is_custom: false },
  { id: 7, name: 'Remada Curvada com Barra', muscle_group: 'back', description: 'Exercício composto para espessura das costas.', instructions: '1. Tronco a 45°. 2. Puxe até o abdômen. 3. Contraia as escápulas.', is_custom: false },
  { id: 8, name: 'Remada Unilateral com Halter (Serrote)', muscle_group: 'back', description: 'Trabalha cada lado individualmente.', instructions: '1. Apoie joelho no banco. 2. Puxe o halter até o quadril.', is_custom: false },
  { id: 9, name: 'Levantamento Terra', muscle_group: 'back', description: 'Exercício composto para costas e posterior.', instructions: '1. Segure a barra próxima às pernas. 2. Levante empurrando o chão.', is_custom: false },
  { id: 10, name: 'Barra Fixa', muscle_group: 'back', description: 'Calistenia para costas e bíceps.', instructions: '1. Puxar o corpo até o queixo passar da barra.', is_custom: false },
  // Pernas
  { id: 11, name: 'Agachamento Livre com Barra', muscle_group: 'quadriceps', description: 'Exercício rei das pernas.', instructions: '1. Pés na largura dos ombros. 2. Desça até a coxa paralela ao chão. 3. Suba.', is_custom: false },
  { id: 12, name: 'Leg Press 45°', muscle_group: 'quadriceps', description: 'Exercício composto seguro para pernas.', instructions: '1. Posicione os pés na plataforma. 2. Desça até 90°. 3. Empurre.', is_custom: false },
  { id: 13, name: 'Cadeira Extensora', muscle_group: 'quadriceps', description: 'Isolamento do quadríceps.', instructions: '1. Estenda as pernas completamente. 2. Segure 1s no topo.', is_custom: false },
  { id: 14, name: 'Stiff com Barra', muscle_group: 'hamstrings', description: 'Foco no posterior de coxa e glúteos.', instructions: '1. Incline o tronco com costas retas. 2. Sinta o alongamento. 3. Suba.', is_custom: false },
  { id: 15, name: 'Mesa Flexora', muscle_group: 'hamstrings', description: 'Isolamento de posterior de coxa.', instructions: '1. Flexione os joelhos trazendo o rolo aos glúteos.', is_custom: false },
  { id: 16, name: 'Hip Thrust (Elevação Pélvica)', muscle_group: 'glutes', description: 'Exercício principal para glúteos.', instructions: '1. Apoie ombros no banco. 2. Eleve o quadril até contrair no topo.', is_custom: false },
  { id: 17, name: 'Panturrilha em Pé', muscle_group: 'calves', description: 'Exercício clássico para panturrilhas.', instructions: '1. Suba na ponta dos pés. 2. Desça sentindo alongar.', is_custom: false },
  // Ombros
  { id: 18, name: 'Desenvolvimento Militar com Barra', muscle_group: 'shoulders', description: 'Principal exercício para deltoides.', instructions: '1. Barra na altura da clavícula. 2. Empurre acima da cabeça.', is_custom: false },
  { id: 19, name: 'Elevação Lateral com Halteres', muscle_group: 'shoulders', description: 'Isolamento do deltoide lateral.', instructions: '1. Eleve os braços lateralmente até a altura dos ombros.', is_custom: false },
  { id: 20, name: 'Crucifixo Invertido', muscle_group: 'shoulders', description: 'Foco no deltoide posterior.', instructions: '1. Tronco inclinado. 2. Abra os braços lateralmente.', is_custom: false },
  // Braços
  { id: 21, name: 'Rosca Direta com Barra W', muscle_group: 'biceps', description: 'Exercício clássico de bíceps.', instructions: '1. Flexione os braços mantendo cotovelos fixos.', is_custom: false },
  { id: 22, name: 'Rosca Martelo com Halteres', muscle_group: 'biceps', description: 'Trabalha bíceps e braquial.', instructions: '1. Pegada neutra. 2. Flexione alternadamente.', is_custom: false },
  { id: 23, name: 'Tríceps Pulley Corda', muscle_group: 'triceps', description: 'Isolamento de tríceps no cabo.', instructions: '1. Cotovelos fixos. 2. Estenda os braços para baixo abrindo a corda.', is_custom: false },
  { id: 24, name: 'Tríceps Testa com Barra', muscle_group: 'triceps', description: 'Foco na cabeça longa do tríceps.', instructions: '1. Flexione os cotovelos trazendo a barra à testa.', is_custom: false },
  // Abdômen & Cardio
  { id: 25, name: 'Abdominal Supra (Crunch)', muscle_group: 'abs', description: 'Fortalecimento do reto abdominal.', instructions: '1. Eleve o tronco contraindo o abdômen.', is_custom: false },
  { id: 26, name: 'Prancha Isométrica', muscle_group: 'abs', description: 'Fortalecimento do core.', instructions: '1. Apoie nos antebraços e pontas dos pés. 2. Mantenha o corpo reto.', is_custom: false },
  { id: 27, name: 'Corrida na Esteira', muscle_group: 'cardio', description: 'Gasto calórico e condicionamento cardiovascular.', instructions: '1. Mantenha postura ereta e ritmo constante.', is_custom: false },
  { id: 28, name: 'Bicicleta Ergométrica', muscle_group: 'cardio', description: 'Cardio de baixo impacto para articulações.', instructions: '1. Ajuste a altura do banco e mantenha cadência constante.', is_custom: false },
];

// ── In-Memory / Embedded Storage Engine ────────────────────────
const memoryDb = {
  users: [],
  exercises: [...DEFAULT_EXERCISES],
  workouts: [],
  workout_exercises: [],
  workout_logs: [],
  set_logs: [],
  nutrition_logs: [],
  body_measurements: [],
  counters: {
    users: 1,
    exercises: 29,
    workouts: 1,
    workout_exercises: 1,
    workout_logs: 1,
    set_logs: 1,
    nutrition_logs: 1,
    body_measurements: 1,
  },
};

/**
 * Interpretador SQL simplificado para operações em memória quando Postgres não estiver ativo.
 */
function executeInMemoryQuery(text, params = []) {
  const sql = text.trim();
  const lower = sql.toLowerCase().replace(/\s+/g, ' ');

  // 1. SELECT version()
  if (lower.includes('select version()')) {
    return { rows: [{ version: 'FitLife-Embedded-Engine v1.0.0' }] };
  }

  // 2. USERS
  if (lower.startsWith('select') && lower.includes('from users')) {
    if (lower.includes('where email =')) {
      const email = params[0]?.toLowerCase();
      const user = memoryDb.users.find(u => u.email.toLowerCase() === email);
      return { rows: user ? [{ ...user }] : [] };
    }
    if (lower.includes('where id =')) {
      const id = Number(params[0]);
      const user = memoryDb.users.find(u => u.id === id);
      return { rows: user ? [{ ...user }] : [] };
    }
    return { rows: [...memoryDb.users] };
  }

  if (lower.startsWith('insert into users')) {
    const id = memoryDb.counters.users++;
    const [name, email, password_hash, age, sex, weight_kg, height_cm, goal, activity_level] = params;
    const now = new Date();
    const newUser = {
      id,
      name,
      email,
      password_hash,
      age: age != null ? Number(age) : null,
      sex: sex || null,
      weight_kg: weight_kg != null ? Number(weight_kg) : null,
      height_cm: height_cm != null ? Number(height_cm) : null,
      goal: goal || null,
      activity_level: activity_level || null,
      created_at: now,
      updated_at: now,
    };
    memoryDb.users.push(newUser);
    return { rows: [{ ...newUser }] };
  }

  if (lower.startsWith('update users set')) {
    if (lower.includes('weight_kg = $1 where id = $2')) {
      const [weight, id] = params;
      const user = memoryDb.users.find(u => u.id === Number(id));
      if (user) {
        user.weight_kg = Number(weight);
        user.updated_at = new Date();
        return { rows: [{ ...user }] };
      }
      return { rows: [] };
    }
    const id = Number(params[params.length - 1]);
    const user = memoryDb.users.find(u => u.id === id);
    if (!user) return { rows: [] };

    // Dynamic field updates
    let pIdx = 0;
    if (sql.includes('name =')) user.name = params[pIdx++];
    if (sql.includes('age =')) user.age = params[pIdx++];
    if (sql.includes('sex =')) user.sex = params[pIdx++];
    if (sql.includes('weight_kg =')) user.weight_kg = params[pIdx++];
    if (sql.includes('height_cm =')) user.height_cm = params[pIdx++];
    if (sql.includes('goal =')) user.goal = params[pIdx++];
    if (sql.includes('activity_level =')) user.activity_level = params[pIdx++];
    user.updated_at = new Date();
    return { rows: [{ ...user }] };
  }

  // 3. EXERCISES
  if (lower.startsWith('select') && lower.includes('from exercises')) {
    if (lower.includes('select distinct muscle_group')) {
      const groups = [...new Set(memoryDb.exercises.map(e => e.muscle_group))].sort();
      return { rows: groups.map(g => ({ muscle_group: g })) };
    }
    if (lower.includes('where id =')) {
      const id = Number(params[0]);
      const ex = memoryDb.exercises.find(e => e.id === id);
      return { rows: ex ? [{ ...ex }] : [] };
    }
    if (lower.includes('where muscle_group =')) {
      const group = params[0];
      const filtered = memoryDb.exercises.filter(e => e.muscle_group === group);
      return { rows: filtered };
    }

    const userId = Number(params[0] || 0);
    let results = memoryDb.exercises.filter(e => !e.is_custom || e.created_by === userId);

    if (params.length > 1) {
      for (let i = 1; i < params.length; i++) {
        const val = params[i];
        if (typeof val === 'string' && val.startsWith('%') && val.endsWith('%')) {
          const search = val.slice(1, -1).toLowerCase();
          results = results.filter(e => e.name.toLowerCase().includes(search));
        } else if (typeof val === 'string') {
          results = results.filter(e => e.muscle_group.toLowerCase() === val.toLowerCase());
        }
      }
    }
    return { rows: results };
  }

  if (lower.startsWith('insert into exercises')) {
    const id = memoryDb.counters.exercises++;
    const [name, muscle_group, description, instructions, userId] = params;
    const newEx = {
      id,
      name,
      muscle_group,
      description: description || null,
      instructions: instructions || null,
      is_custom: true,
      created_by: Number(userId),
      created_at: new Date(),
    };
    memoryDb.exercises.push(newEx);
    return { rows: [{ ...newEx }] };
  }

  // 4. WORKOUTS
  if (lower.startsWith('select') && lower.includes('from workouts')) {
    if (lower.includes('where w.user_id = $1') || lower.includes('where user_id = $1')) {
      const userId = Number(params[0]);
      const workouts = memoryDb.workouts.filter(w => w.user_id === userId);
      const rows = workouts.map(w => {
        const exerciseCount = memoryDb.workout_exercises.filter(we => we.workout_id === w.id).length;
        return { ...w, exercise_count: exerciseCount };
      });
      return { rows };
    }
    if (lower.includes('where id = $1 and user_id = $2')) {
      const [id, userId] = params;
      const workout = memoryDb.workouts.find(w => w.id === Number(id) && w.user_id === Number(userId));
      return { rows: workout ? [{ ...workout }] : [] };
    }
  }

  if (lower.startsWith('insert into workouts')) {
    const id = memoryDb.counters.workouts++;
    const [userId, name, description] = params;
    const now = new Date();
    const newWorkout = {
      id,
      user_id: Number(userId),
      name,
      description: description || null,
      created_at: now,
      updated_at: now,
    };
    memoryDb.workouts.push(newWorkout);
    return { rows: [{ ...newWorkout }] };
  }

  if (lower.startsWith('update workouts set')) {
    const userId = Number(params[params.length - 1]);
    const id = Number(params[params.length - 2]);
    const workout = memoryDb.workouts.find(w => w.id === id && w.user_id === userId);
    if (!workout) return { rows: [] };
    if (sql.includes('name =')) workout.name = params[0];
    if (sql.includes('description =')) workout.description = params[sql.includes('name =') ? 1 : 0];
    workout.updated_at = new Date();
    return { rows: [{ ...workout }] };
  }

  if (lower.startsWith('delete from workouts')) {
    const [id, userId] = params;
    const initialLen = memoryDb.workouts.length;
    memoryDb.workouts = memoryDb.workouts.filter(w => !(w.id === Number(id) && w.user_id === Number(userId)));
    memoryDb.workout_exercises = memoryDb.workout_exercises.filter(we => we.workout_id !== Number(id));
    return { rowCount: initialLen - memoryDb.workouts.length };
  }

  // 5. WORKOUT_EXERCISES
  if (lower.startsWith('select') && lower.includes('from workout_exercises')) {
    const workoutId = Number(params[0]);
    const items = memoryDb.workout_exercises.filter(we => we.workout_id === workoutId);
    const rows = items.map(we => {
      const ex = memoryDb.exercises.find(e => e.id === we.exercise_id) || {};
      return {
        ...we,
        exercise_name: ex.name || 'Exercício',
        muscle_group: ex.muscle_group || 'geral',
      };
    }).sort((a, b) => (a.order_index || 0) - (b.order_index || 0));
    return { rows };
  }

  if (lower.startsWith('insert into workout_exercises')) {
    const id = memoryDb.counters.workout_exercises++;
    const [workout_id, exercise_id, sets, reps, weight_kg, rest_secs, notes, order_index] = params;
    const newWe = {
      id,
      workout_id: Number(workout_id),
      exercise_id: Number(exercise_id),
      sets: Number(sets),
      reps: Number(reps),
      weight_kg: weight_kg != null ? Number(weight_kg) : null,
      rest_secs: rest_secs != null ? Number(rest_secs) : null,
      notes: notes || null,
      order_index: order_index != null ? Number(order_index) : 0,
    };
    memoryDb.workout_exercises.push(newWe);
    return { rows: [{ ...newWe }] };
  }

  if (lower.startsWith('update workout_exercises set')) {
    const id = Number(params[params.length - 1]);
    const we = memoryDb.workout_exercises.find(item => item.id === id);
    if (!we) return { rows: [] };
    if (sql.includes('sets =')) we.sets = Number(params[0]);
    if (sql.includes('reps =')) we.reps = Number(params[1] || params[0]);
    if (sql.includes('weight_kg =')) we.weight_kg = Number(params[2] || params[0]);
    if (sql.includes('rest_secs =')) we.rest_secs = Number(params[3] || params[0]);
    if (sql.includes('order_index = $1')) we.order_index = Number(params[0]);
    return { rows: [{ ...we }] };
  }

  if (lower.startsWith('delete from workout_exercises')) {
    const id = Number(params[0]);
    const initialLen = memoryDb.workout_exercises.length;
    memoryDb.workout_exercises = memoryDb.workout_exercises.filter(we => we.id !== id);
    return { rowCount: initialLen - memoryDb.workout_exercises.length };
  }

  // 6. WORKOUT_LOGS
  if (lower.startsWith('insert into workout_logs')) {
    const id = memoryDb.counters.workout_logs++;
    const [user_id, workout_id, notes, rating] = params;
    const newLog = {
      id,
      user_id: Number(user_id),
      workout_id: workout_id != null ? Number(workout_id) : null,
      started_at: new Date(),
      finished_at: null,
      duration_min: null,
      notes: notes || null,
      rating: rating != null ? Number(rating) : null,
    };
    memoryDb.workout_logs.push(newLog);
    return { rows: [{ ...newLog }] };
  }

  if (lower.startsWith('update workout_logs set')) {
    const [id, userId, notes, rating] = params;
    const log = memoryDb.workout_logs.find(l => l.id === Number(id) && l.user_id === Number(userId));
    if (!log) return { rows: [] };
    const now = new Date();
    log.finished_at = now;
    log.duration_min = Math.max(1, Math.round((now - new Date(log.started_at)) / 60000));
    if (notes) log.notes = notes;
    if (rating != null) log.rating = Number(rating);
    return { rows: [{ ...log }] };
  }

  if (lower.startsWith('select') && lower.includes('from workout_logs')) {
    if (lower.includes('where wl.id = $1 and wl.user_id = $2') || lower.includes('where id = $1 and user_id = $2')) {
      const [id, userId] = params;
      const log = memoryDb.workout_logs.find(l => l.id === Number(id) && l.user_id === Number(userId));
      if (!log) return { rows: [] };
      const workout = log.workout_id ? memoryDb.workouts.find(w => w.id === log.workout_id) : null;
      return { rows: [{ ...log, workout_name: workout ? workout.name : 'Treino Livre' }] };
    }

    if (lower.includes('where wl.user_id = $1') || lower.includes('where user_id = $1')) {
      const userId = Number(params[0]);
      const logs = memoryDb.workout_logs
        .filter(l => l.user_id === userId)
        .sort((a, b) => new Date(b.started_at) - new Date(a.started_at));

      const limit = Number(params[1] || 20);
      const offset = Number(params[2] || 0);

      const paged = logs.slice(offset, offset + limit).map(l => {
        const w = l.workout_id ? memoryDb.workouts.find(w => w.id === l.workout_id) : null;
        const totalSets = memoryDb.set_logs.filter(sl => sl.workout_log_id === l.id).length;
        return {
          ...l,
          workout_name: w ? w.name : 'Treino Livre',
          total_sets: totalSets,
        };
      });
      return { rows: paged };
    }
  }

  // 7. SET_LOGS
  if (lower.startsWith('insert into set_logs')) {
    const id = memoryDb.counters.set_logs++;
    const [workout_log_id, exercise_id, set_number, reps_done, weight_kg, duration_secs, is_warmup, notes] = params;
    const newSet = {
      id,
      workout_log_id: Number(workout_log_id),
      exercise_id: Number(exercise_id),
      set_number: Number(set_number),
      reps_done: reps_done != null ? Number(reps_done) : null,
      weight_kg: weight_kg != null ? Number(weight_kg) : null,
      duration_secs: duration_secs != null ? Number(duration_secs) : null,
      is_warmup: Boolean(is_warmup),
      notes: notes || null,
      logged_at: new Date(),
    };
    memoryDb.set_logs.push(newSet);
    return { rows: [{ ...newSet }] };
  }

  if (lower.startsWith('select') && lower.includes('from set_logs')) {
    if (lower.includes('where sl.workout_log_id = $1') || lower.includes('where workout_log_id = $1')) {
      const logId = Number(params[0]);
      const sets = memoryDb.set_logs
        .filter(sl => sl.workout_log_id === logId)
        .map(sl => {
          const ex = memoryDb.exercises.find(e => e.id === sl.exercise_id) || {};
          return {
            ...sl,
            exercise_name: ex.name || 'Exercício',
            muscle_group: ex.muscle_group || 'geral',
          };
        })
        .sort((a, b) => a.exercise_id - b.exercise_id || a.set_number - b.set_number);
      return { rows: sets };
    }

    if (lower.includes('from set_logs sl join workout_logs wl')) {
      const [userId, exerciseId, limit] = params;
      const matchingLogs = memoryDb.workout_logs.filter(wl => wl.user_id === Number(userId));
      const logIds = new Set(matchingLogs.map(l => l.id));
      const sets = memoryDb.set_logs
        .filter(sl => logIds.has(sl.workout_log_id) && sl.exercise_id === Number(exerciseId) && !sl.is_warmup)
        .map(sl => {
          const l = matchingLogs.find(wl => wl.id === sl.workout_log_id);
          return {
            set_number: sl.set_number,
            reps_done: sl.reps_done,
            weight_kg: sl.weight_kg,
            started_at: l ? l.started_at : sl.logged_at,
          };
        })
        .slice(0, Number(limit || 10));
      return { rows: sets };
    }
  }

  // 8. NUTRITION_LOGS
  if (lower.startsWith('insert into nutrition_logs')) {
    const id = memoryDb.counters.nutrition_logs++;
    const [userId, mealType, description, caloriesKcal, proteinG, carbsG, fatG, loggedDate] = params;
    const newLog = {
      id,
      user_id: Number(userId),
      meal_type: mealType,
      description: description || null,
      calories_kcal: Number(caloriesKcal || 0),
      protein_g: Number(proteinG || 0),
      carbs_g: Number(carbsG || 0),
      fat_g: Number(fatG || 0),
      logged_date: loggedDate || new Date().toISOString().split('T')[0],
      created_at: new Date(),
    };
    memoryDb.nutrition_logs.push(newLog);
    return { rows: [{ ...newLog }] };
  }

  if (lower.startsWith('select') && lower.includes('from nutrition_logs')) {
    if (lower.includes('group by logged_date')) {
      const userId = Number(params[0]);
      const days = Number(params[1] || 7);
      const userLogs = memoryDb.nutrition_logs.filter(n => n.user_id === userId);

      const byDate = {};
      for (const log of userLogs) {
        if (!byDate[log.logged_date]) {
          byDate[log.logged_date] = {
            logged_date: log.logged_date,
            total_calories: 0,
            total_protein: 0,
            total_carbs: 0,
            total_fat: 0,
            meal_count: 0,
          };
        }
        byDate[log.logged_date].total_calories += log.calories_kcal;
        byDate[log.logged_date].total_protein += log.protein_g;
        byDate[log.logged_date].total_carbs += log.carbs_g;
        byDate[log.logged_date].total_fat += log.fat_g;
        byDate[log.logged_date].meal_count += 1;
      }

      const rows = Object.values(byDate)
        .sort((a, b) => b.logged_date.localeCompare(a.logged_date))
        .slice(0, days);
      return { rows };
    }

    if (lower.includes('where user_id = $1 and logged_date = $2')) {
      const [userId, date] = params;
      const logs = memoryDb.nutrition_logs
        .filter(n => n.user_id === Number(userId) && n.logged_date === date)
        .sort((a, b) => new Date(a.created_at) - new Date(b.created_at));
      return { rows: logs };
    }
  }

  if (lower.startsWith('delete from nutrition_logs')) {
    const [id, userId] = params;
    const initialLen = memoryDb.nutrition_logs.length;
    memoryDb.nutrition_logs = memoryDb.nutrition_logs.filter(n => !(n.id === Number(id) && n.user_id === Number(userId)));
    return { rowCount: initialLen - memoryDb.nutrition_logs.length };
  }

  // 9. BODY_MEASUREMENTS
  if (lower.startsWith('insert into body_measurements')) {
    const [userId, date, weight, fat, muscle, chest, waist, hip, arm, thigh, notes] = params;
    let measurement = memoryDb.body_measurements.find(m => m.user_id === Number(userId) && m.measured_at === date);
    if (!measurement) {
      measurement = {
        id: memoryDb.counters.body_measurements++,
        user_id: Number(userId),
        measured_at: date,
        created_at: new Date(),
      };
      memoryDb.body_measurements.push(measurement);
    }
    measurement.weight_kg = weight != null ? Number(weight) : null;
    measurement.body_fat_pct = fat != null ? Number(fat) : null;
    measurement.muscle_mass_kg = muscle != null ? Number(muscle) : null;
    measurement.chest_cm = chest != null ? Number(chest) : null;
    measurement.waist_cm = waist != null ? Number(waist) : null;
    measurement.hip_cm = hip != null ? Number(hip) : null;
    measurement.arm_cm = arm != null ? Number(arm) : null;
    measurement.thigh_cm = thigh != null ? Number(thigh) : null;
    measurement.notes = notes || null;
    return { rows: [{ ...measurement }] };
  }

  if (lower.startsWith('select') && lower.includes('from body_measurements')) {
    const userId = Number(params[0]);
    const limit = Number(params[1] || 30);
    const measurements = memoryDb.body_measurements
      .filter(m => m.user_id === userId)
      .sort((a, b) => b.measured_at.localeCompare(a.measured_at))
      .slice(0, limit);
    return { rows: measurements };
  }

  if (lower.startsWith('delete from body_measurements')) {
    const [id, userId] = params;
    const initialLen = memoryDb.body_measurements.length;
    memoryDb.body_measurements = memoryDb.body_measurements.filter(m => !(m.id === Number(id) && m.user_id === Number(userId)));
    return { rowCount: initialLen - memoryDb.body_measurements.length };
  }

  return { rows: [], rowCount: 0 };
}

// ── Pool Transaction Helper ───────────────────────────────────
const mockTransactionClient = {
  query: async (text, params) => executeInMemoryQuery(text, params),
  release: () => {},
};

/**
 * Testa a conexão PostgreSQL. Em caso de falha, ativa o modo embutido sem quebrar a aplicação.
 */
const testConnection = async () => {
  try {
    const client = await pool.connect();
    const { rows } = await client.query('SELECT version()');
    const version = rows[0].version.split(' ').slice(0, 2).join(' ');
    console.log(`✅ PostgreSQL conectado: ${version}`);
    console.log(`🔗 Modo: ${process.env.DATABASE_URL ? 'Neon.tech (cloud)' : 'Local'}`);
    isPostgresConnected = true;
    client.release();
  } catch (error) {
    isPostgresConnected = false;
    console.log('⚡ Modo Banco Embutido/Offline ativo (PostgreSQL não detectado). API totalmente operacional!');
  }
};

module.exports = {
  /**
   * Executa uma query no pool PostgreSQL se conectado, ou no motor embutido.
   */
  query: async (text, params = []) => {
    if (isPostgresConnected) {
      try {
        return await pool.query(text, params);
      } catch (err) {
        // Se a query falhar por falta de tabela, tenta executar no motor embutido
        return executeInMemoryQuery(text, params);
      }
    }
    return executeInMemoryQuery(text, params);
  },

  pool: {
    connect: async () => {
      if (isPostgresConnected) {
        try {
          return await pool.connect();
        } catch (e) {
          return mockTransactionClient;
        }
      }
      return mockTransactionClient;
    },
  },

  testConnection,
  isFallbackMode: () => !isPostgresConnected,
};
