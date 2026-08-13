# FitLife AI 🏋️‍♂️🤖

O **FitLife AI** é uma plataforma mobile moderna voltada para acompanhamento físico, treinos, controle nutricional, cálculo de calorias e evolução pessoal. O projeto foi projetado com uma arquitetura modular, limpa e escalável, preparada para receber integração com Inteligência Artificial no futuro através do backend.

---

## 🛠️ Tecnologias Utilizadas

### Frontend (Mobile)
- **Flutter** (Framework UI multiplataforma)
- **Dart** (Linguagem de programação)
- **Material 3** (Design System moderno da Google)

### Backend (API REST)
- **Node.js** (Ambiente de execução JavaScript)
- **Express.js** (Framework web minimalista para Node.js)
- **CORS & Dotenv** (Segurança e variáveis de ambiente)

### Banco de Dados
- **PostgreSQL** (Sistema Gerenciador de Banco de Dados Relacional)
- **Driver `pg` (node-postgres)** (Comunicação entre Node.js e PostgreSQL)

---

## 📁 Estrutura do Projeto

```text
fitlife-ai/
│
├── frontend/                     # Aplicativo Mobile em Flutter
│   ├── lib/
│   │   ├── core/                 # Configurações globais, tema e constantes
│   │   │   ├── constants/        # Constantes do aplicativo (AppConstants)
│   │   │   └── theme/            # Tema personalizado Material 3 (AppTheme)
│   │   ├── models/               # Modelos de dados (ex: UserModel)
│   │   ├── routes/               # Sistema de rotas e navegação (AppRoutes)
│   │   ├── screens/              # Telas da aplicação (ex: HomeScreen)
│   │   ├── services/             # Serviços de API e comunicação (ApiService)
│   │   ├── widgets/              # Componentes de UI reutilizáveis (CustomButton)
│   │   └── main.dart             # Ponto de entrada do aplicativo Flutter
│   └── pubspec.yaml              # Dependências e assets do Flutter
│
├── backend/                      # API REST em Node.js + Express
│   ├── src/
│   │   ├── config/               # Configuração da conexão PostgreSQL (db.js)
│   │   ├── controllers/          # Controladores das requisições (health.controller.js)
│   │   ├── middlewares/          # Middlewares (error.middleware.js)
│   │   ├── models/               # Camada de persistência/banco
│   │   ├── routes/               # Definição de endpoints (health.routes.js, index.js)
│   │   ├── services/             # Regras de negócio (health.service.js)
│   │   └── app.js                # Configuração principal do servidor Express
│   ├── .env                      # Variáveis de ambiente (Porta, DB)
│   ├── .env.example              # Exemplo de .env sem credenciais reais
│   ├── server.js                 # Ponto de entrada do servidor Node
│   └── package.json              # Dependências e scripts do backend
│
├── database/                     # Estrutura do Banco de Dados
│   ├── migrations/               # Arquivos para criação/alteração de tabelas
│   └── seeds/                    # Dados iniciais para população do banco
│
└── README.md                     # Documentação completa do projeto
```

---

## 🚀 Como Executar o Backend (Node.js + Express)

### Pré-requisitos
- Node.js (v18+ recomendado)
- npm (v9+ recomendado)

### Passo a Passo:
1. Abra o terminal na pasta do backend:
   ```bash
   cd backend
   ```
2. Instale as dependências:
   ```bash
   npm install
   ```
3. Crie ou verifique o arquivo `.env` (já incluído com configurações padrão).
4. Inicie o servidor em modo de desenvolvimento:
   ```bash
   npm run dev
   ```
   *(Ou `npm start` para modo produção)*

5. O servidor estará rodando em: `http://localhost:3000`

---

## 🧪 Como Testar a Rota `/api/health`

Com o backend rodando, acesse a rota de verificação de saúde da API:

- **Via Navegador**:
  Abra a URL: [http://localhost:3000/api/health](http://localhost:3000/api/health)

- **Via cURL (Terminal)**:
  ```bash
  curl http://localhost:3000/api/health
  ```

- **Resposta esperada (JSON)**:
  ```json
  {
    "status": "ok",
    "message": "FitLife AI API funcionando"
  }
  ```

---

## 📱 Como Executar o Frontend (Flutter)

### Pré-requisitos
- Flutter SDK instalado
- Emulador Android/iOS ou dispositivo físico/navegador Web

### Passo a Passo:
1. Abra o terminal na pasta do frontend:
   ```bash
   cd frontend
   ```
2. Obtenha as dependências do Flutter:
   ```bash
   flutter pub get
   ```
3. Execute o aplicativo:
   ```bash
   flutter run
   ```
   *(Escolha o dispositivo desejado: Chrome, Android, Edge, etc.)*

---

## 🛡️ Segurança e Boas Práticas

- Nenhuma chave de API ou credencial sensível está commitada no repositório.
- A comunicação com a futura IA será intermediada exclusivamente pelo backend.
- A estrutura de pastas segue os princípios de separação de responsabilidades (Clean Code).
