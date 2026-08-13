const express = require('express');
const cors = require('cors');
const routes = require('./routes');
const errorMiddleware = require('./middlewares/error.middleware');

const app = express();

// Middlewares Globais
app.use(cors());
app.use(express.json());
app.use(express.urlencoded({ extended: true }));

// Prefixo das rotas da API
app.use('/api', routes);

// Middleware de tratamento de erros
app.use(errorMiddleware);

module.exports = app;
