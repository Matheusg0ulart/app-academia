// lib/screens/auth_screen.dart

import 'package:flutter/material.dart';
import '../core/constants/app_constants.dart';
import '../core/theme/app_theme.dart';
import '../services/api_service.dart';
import '../widgets/custom_button.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final ApiService _api = ApiService();

  // Login Controllers
  final _loginEmailController = TextEditingController();
  final _loginPasswordController = TextEditingController();
  bool _loginLoading = false;
  String? _loginError;

  // Register Controllers
  final _regNameController = TextEditingController();
  final _regEmailController = TextEditingController();
  final _regPasswordController = TextEditingController();
  final _regAgeController = TextEditingController();
  final _regWeightController = TextEditingController();
  final _regHeightController = TextEditingController();
  String _regSex = 'male';
  String _regGoal = 'hypertrophy';
  String _regActivity = 'moderate';
  bool _regLoading = false;
  String? _regError;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _loginEmailController.dispose();
    _loginPasswordController.dispose();
    _regNameController.dispose();
    _regEmailController.dispose();
    _regPasswordController.dispose();
    _regAgeController.dispose();
    _regWeightController.dispose();
    _regHeightController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    final email = _loginEmailController.text.trim();
    final password = _loginPasswordController.text;

    if (email.isEmpty || password.isEmpty) {
      setState(() => _loginError = 'Preencha o e-mail e a senha.');
      return;
    }

    setState(() {
      _loginLoading = true;
      _loginError = null;
    });

    try {
      await _api.login(email: email, password: password);
      if (!mounted) return;
      Navigator.of(context).pushReplacementNamed('/home');
    } catch (e) {
      setState(() => _loginError = e.toString().replaceAll('ApiException', ''));
    } finally {
      if (mounted) setState(() => _loginLoading = false);
    }
  }

  Future<void> _handleRegister() async {
    final name = _regNameController.text.trim();
    final email = _regEmailController.text.trim();
    final password = _regPasswordController.text;

    if (name.isEmpty || email.isEmpty || password.isEmpty) {
      setState(() => _regError = 'Nome, e-mail e senha são obrigatórios.');
      return;
    }

    final age = int.tryParse(_regAgeController.text.trim());
    final weight = double.tryParse(_regWeightController.text.trim().replaceAll(',', '.'));
    final height = double.tryParse(_regHeightController.text.trim().replaceAll(',', '.'));

    setState(() {
      _regLoading = true;
      _regError = null;
    });

    try {
      await _api.register(
        name: name,
        email: email,
        password: password,
        age: age,
        sex: _regSex,
        weightKg: weight,
        heightCm: height,
        goal: _regGoal,
        activityLevel: _regActivity,
      );
      if (!mounted) return;
      Navigator.of(context).pushReplacementNamed('/home');
    } catch (e) {
      setState(() => _regError = e.toString().replaceAll('ApiException', ''));
    } finally {
      if (mounted) setState(() => _regLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Column(
            children: [
              const SizedBox(height: 24),
              // App Logo & Header
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryColor.withOpacity(0.15),
                      shape: BoxShape.circle,
                      border: Border.all(color: AppTheme.primaryColor, width: 1.5),
                    ),
                    child: const Icon(Icons.fitness_center_rounded, color: AppTheme.primaryColor, size: 28),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    AppConstants.appName,
                    style: theme.textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                'Treinos, Nutrição e Assistente Inteligente',
                style: theme.textTheme.bodyMedium?.copyWith(color: Colors.grey[400]),
              ),
              const SizedBox(height: 28),

              // TabBar (Entrar / Cadastrar)
              Container(
                decoration: BoxDecoration(
                  color: AppTheme.cardDarkBackground,
                  borderRadius: BorderRadius.circular(25),
                ),
                child: TabBar(
                  controller: _tabController,
                  indicator: BoxDecoration(
                    color: AppTheme.primaryColor,
                    borderRadius: BorderRadius.circular(25),
                  ),
                  labelColor: Colors.black,
                  unselectedLabelColor: Colors.grey[400],
                  labelStyle: const TextStyle(fontWeight: FontWeight.bold),
                  indicatorSize: TabBarIndicatorSize.tab,
                  tabs: const [
                    Tab(text: 'Entrar'),
                    Tab(text: 'Cadastrar'),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // TabBar View Container
              SizedBox(
                height: 480,
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _buildLoginForm(),
                    _buildRegisterForm(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLoginForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (_loginError != null) ...[
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.red.withOpacity(0.15),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.redAccent.withOpacity(0.5)),
            ),
            child: Text(
              _loginError!,
              style: const TextStyle(color: Colors.redAccent, fontSize: 13),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 16),
        ],
        TextField(
          controller: _loginEmailController,
          keyboardType: TextInputType.emailAddress,
          decoration: InputDecoration(
            labelText: 'E-mail',
            prefixIcon: const Icon(Icons.email_outlined, color: AppTheme.primaryColor),
            filled: true,
            fillColor: AppTheme.cardDarkBackground,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
          ),
        ),
        const SizedBox(height: 16),
        TextField(
          controller: _loginPasswordController,
          obscureText: true,
          decoration: InputDecoration(
            labelText: 'Senha',
            prefixIcon: const Icon(Icons.lock_outline, color: AppTheme.primaryColor),
            filled: true,
            fillColor: AppTheme.cardDarkBackground,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
          ),
        ),
        const SizedBox(height: 24),
        CustomButton(
          text: _loginLoading ? 'Entrando...' : 'Entrar no FitLife AI',
          icon: Icons.login_rounded,
          isLoading: _loginLoading,
          onPressed: _loginLoading ? () {} : _handleLogin,
        ),
        const Spacer(),
        Center(
          child: TextButton(
            onPressed: () => _tabController.animateTo(1),
            child: const Text('Não tem uma conta? Cadastre-se gratuitamente', style: TextStyle(color: AppTheme.primaryColor)),
          ),
        ),
      ],
    );
  }

  Widget _buildRegisterForm() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (_regError != null) ...[
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.15),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.redAccent.withOpacity(0.5)),
              ),
              child: Text(
                _regError!,
                style: const TextStyle(color: Colors.redAccent, fontSize: 13),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 12),
          ],
          TextField(
            controller: _regNameController,
            decoration: InputDecoration(
              labelText: 'Nome Completo *',
              prefixIcon: const Icon(Icons.person_outline, color: AppTheme.primaryColor),
              filled: true,
              fillColor: AppTheme.cardDarkBackground,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _regEmailController,
            keyboardType: TextInputType.emailAddress,
            decoration: InputDecoration(
              labelText: 'E-mail *',
              prefixIcon: const Icon(Icons.email_outlined, color: AppTheme.primaryColor),
              filled: true,
              fillColor: AppTheme.cardDarkBackground,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _regPasswordController,
            obscureText: true,
            decoration: InputDecoration(
              labelText: 'Senha (mínimo 6 caracteres) *',
              prefixIcon: const Icon(Icons.lock_outline, color: AppTheme.primaryColor),
              filled: true,
              fillColor: AppTheme.cardDarkBackground,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _regAgeController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: 'Idade',
                    filled: true,
                    fillColor: AppTheme.cardDarkBackground,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: TextField(
                  controller: _regWeightController,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  decoration: InputDecoration(
                    labelText: 'Peso (kg)',
                    filled: true,
                    fillColor: AppTheme.cardDarkBackground,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: TextField(
                  controller: _regHeightController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: 'Altura (cm)',
                    filled: true,
                    fillColor: AppTheme.cardDarkBackground,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<String>(
            value: _regGoal,
            decoration: InputDecoration(
              labelText: 'Objetivo Principal',
              filled: true,
              fillColor: AppTheme.cardDarkBackground,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
            ),
            dropdownColor: AppTheme.cardDarkBackground,
            items: const [
              DropdownMenuItem(value: 'hypertrophy', child: Text('Hipertrofia / Ganho de Massa')),
              DropdownMenuItem(value: 'weight_loss', child: Text('Emagrecimento / Definição')),
              DropdownMenuItem(value: 'maintenance', child: Text('Saúde / Condicionamento')),
            ],
            onChanged: (val) => setState(() => _regGoal = val ?? 'hypertrophy'),
          ),
          const SizedBox(height: 16),
          CustomButton(
            text: _regLoading ? 'Criando Conta...' : 'Criar Minha Conta',
            icon: Icons.check_circle_outline,
            isLoading: _regLoading,
            onPressed: _regLoading ? () {} : _handleRegister,
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}

