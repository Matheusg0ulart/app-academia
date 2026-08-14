# 🗄️ FitLife AI — Banco de Dados

Documentação completa da camada de dados: schema PostgreSQL (Neon.tech) + SQLite offline (Flutter).

---

## Diagrama de Tabelas (PostgreSQL)

```
users
 ├── workouts (user_id → users.id)
 │    └── workout_exercises (workout_id → workouts.id)
 │         └── exercises (exercise_id → exercises.id)
 ├── workout_logs (user_id → users.id)
 │    └── set_logs (workout_log_id → workout_logs.id)
 ├── nutrition_logs (user_id → users.id)
 ├── body_measurements (user_id → users.id)
 └── user_sessions (user_id → users.id)

exercises (tabela compartilhada: sistema + customizados)
```

| Tabela | Descrição |
|---|---|
| `users` | Perfil do usuário (auth, metas, medidas iniciais) |
| `exercises` | Catálogo de exercícios (sistema + criados pelo usuário) |
| `workouts` | Fichas de treino do usuário |
| `workout_exercises` | Exercícios planejados em cada ficha |
| `workout_logs` | Histórico de sessões realizadas |
| `set_logs` | Séries executadas em cada sessão |
| `nutrition_logs` | Registro nutricional diário |
| `body_measurements` | Evolução de medidas corporais |
| `user_sessions` | Tokens JWT de autenticação |

---

## Como conectar ao Neon.tech

1. Acesse [console.neon.tech](https://console.neon.tech)
2. Crie um projeto → copie a **Connection String**
3. No arquivo `backend/.env`, configure:

```env
DATABASE_URL=postgresql://usuario:senha@ep-xxx.us-east-2.aws.neon.tech/fitlife_ai_db?sslmode=require
```

> O script de migrate detecta automaticamente `DATABASE_URL` e habilita SSL.

---

## Como rodar as migrations

### Pré-requisitos
- Node.js instalado
- Arquivo `backend/.env` configurado (local ou Neon)

### Rodar migrations

```bash
# No diretório backend/
npm run migrate
```

### Rodar migrations + seeds (exercícios)

```bash
npm run migrate:seed
```

### Direto (sem npm)

```bash
# Do diretório raiz do projeto
node database/migrate.js
node database/migrate.js --seed
```

---

## Ordem das migrations

| Arquivo | Tabela | Dependências |
|---|---|---|
| `001_create_users.sql` | `users` | — |
| `002_create_exercises.sql` | `exercises` | `users` |
| `003_create_workouts.sql` | `workouts` | `users` |
| `004_create_workout_exercises.sql` | `workout_exercises` | `workouts`, `exercises` |
| `005_create_workout_logs.sql` | `workout_logs` | `users`, `workouts` |
| `006_create_set_logs.sql` | `set_logs` | `workout_logs`, `exercises` |
| `007_create_nutrition_logs.sql` | `nutrition_logs` | `users` |
| `008_create_body_measurements.sql` | `body_measurements` | `users` |
| `009_create_user_sessions.sql` | `user_sessions` | `users` |

> O script usa a tabela `_migrations` para controle de idempotência.
> É seguro rodar `npm run migrate` múltiplas vezes.

---

## Seeds disponíveis

| Arquivo | Conteúdo |
|---|---|
| `001_exercises.sql` | ~60 exercícios reais cobrindo todos os grupos musculares |

---

## SQLite (Flutter — offline)

O app Flutter usa SQLite via `sqflite` para funcionar sem internet.

### Tabelas locais espelham o backend com campos extras:
- `server_id` — ID no PostgreSQL (NULL = não sincronizado)
- `is_dirty` — 1 = precisa ser enviado ao servidor

### Sync automático
O `SyncService` detecta quando a internet volta e sincroniza automaticamente os dados pendentes.

Localização dos arquivos:
```
frontend/lib/
 ├── core/database/
 │    ├── database_helper.dart   ← Singleton SQLite
 │    └── local_schema.dart      ← DDL das tabelas locais
 ├── models/
 │    ├── user.dart
 │    ├── exercise.dart
 │    ├── workout.dart
 │    └── workout_log.dart
 └── services/
      ├── local_db_service.dart  ← CRUD SQLite
      ├── api_service.dart       ← Cliente HTTP
      └── sync_service.dart      ← Sincronização
```
