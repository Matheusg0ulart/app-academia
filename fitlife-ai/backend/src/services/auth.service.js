const bcrypt = require('bcryptjs');
const jwt = require('jsonwebtoken');
const UserModel = require('../models/user.model');

const JWT_SECRET = process.env.JWT_SECRET || 'fitlife_ai_super_secret_jwt_key_2026_production_ready';
const JWT_EXPIRES_IN = process.env.JWT_EXPIRES_IN || '7d';
const JWT_REFRESH_EXPIRES_IN = process.env.JWT_REFRESH_EXPIRES_IN || '30d';

const AuthService = {
  /**
   * Registra um novo usuário.
   */
  async register(data) {
    const { name, email, password, age, sex, weight_kg, height_cm, goal, activity_level } = data;

    if (!name || !email || !password) {
      const error = new Error('Nome, e-mail e senha são obrigatórios.');
      error.statusCode = 400;
      throw error;
    }

    const emailNormalized = email.trim().toLowerCase();
    const existing = await UserModel.findByEmail(emailNormalized);
    if (existing) {
      const error = new Error('Este e-mail já está cadastrado.');
      error.statusCode = 409;
      throw error;
    }

    const password_hash = await bcrypt.hash(password, 10);

    const user = await UserModel.create({
      name: name.trim(),
      email: emailNormalized,
      password_hash,
      age: age ? Number(age) : null,
      sex: sex || null,
      weight_kg: weight_kg ? Number(weight_kg) : null,
      height_cm: height_cm ? Number(height_cm) : null,
      goal: goal || 'hypertrophy',
      activity_level: activity_level || 'moderate',
    });

    const tokens = this.generateTokens(user);

    return {
      user: {
        id: user.id,
        name: user.name,
        email: user.email,
        age: user.age,
        sex: user.sex,
        weight_kg: user.weight_kg,
        height_cm: user.height_cm,
        goal: user.goal,
        activity_level: user.activity_level,
      },
      ...tokens,
    };
  },

  /**
   * Realiza login por email e senha.
   */
  async login(email, password) {
    if (!email || !password) {
      const error = new Error('E-mail e senha são obrigatórios.');
      error.statusCode = 400;
      throw error;
    }

    const emailNormalized = email.trim().toLowerCase();
    const user = await UserModel.findByEmail(emailNormalized);
    if (!user) {
      const error = new Error('Credenciais inválidas.');
      error.statusCode = 401;
      throw error;
    }

    const isMatch = await bcrypt.compare(password, user.password_hash);
    if (!isMatch) {
      const error = new Error('Credenciais inválidas.');
      error.statusCode = 401;
      throw error;
    }

    const tokens = this.generateTokens(user);

    return {
      user: {
        id: user.id,
        name: user.name,
        email: user.email,
        age: user.age,
        sex: user.sex,
        weight_kg: user.weight_kg,
        height_cm: user.height_cm,
        goal: user.goal,
        activity_level: user.activity_level,
      },
      ...tokens,
    };
  },

  /**
   * Gera Access Token e Refresh Token.
   */
  generateTokens(user) {
    const payload = {
      id: user.id,
      email: user.email,
      name: user.name,
    };

    const accessToken = jwt.sign(payload, JWT_SECRET, { expiresIn: JWT_EXPIRES_IN });
    const refreshToken = jwt.sign(payload, JWT_SECRET, { expiresIn: JWT_REFRESH_EXPIRES_IN });

    return {
      access_token: accessToken,
      refresh_token: refreshToken,
    };
  },
};

module.exports = AuthService;

