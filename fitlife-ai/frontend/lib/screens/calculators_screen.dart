// lib/screens/calculators_screen.dart

import 'package:flutter/material.dart';
import '../core/theme/app_theme.dart';
import '../services/api_service.dart';
import '../widgets/glass_card.dart';
import '../widgets/plate_calculator_dialog.dart';

class CalculatorsScreen extends StatefulWidget {
  const CalculatorsScreen({super.key});

  @override
  State<CalculatorsScreen> createState() => _CalculatorsScreenState();
}

class _CalculatorsScreenState extends State<CalculatorsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final ApiService _api = ApiService();

  // Tab 1: TMB & TDEE State
  final _ageController = TextEditingController(text: '24');
  final _weightController = TextEditingController(text: '75');
  final _heightController = TextEditingController(text: '175');
  String _sex = 'male';
  String _activityLevel = 'moderate';
  String _goal = 'hypertrophy';
  Map<String, dynamic>? _tmbResult;
  bool _isTmbLoading = false;

  // Tab 2: Exercise Calorie Burn State
  String _selectedActivity = 'running_moderate';
  final _exerciseWeightController = TextEditingController(text: '75');
  final _durationController = TextEditingController(text: '30');
  double _intensityMultiplier = 1.0;
  Map<String, dynamic>? _burnResult;
  bool _isBurnLoading = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _calculateTmb();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _ageController.dispose();
    _weightController.dispose();
    _heightController.dispose();
    _exerciseWeightController.dispose();
    _durationController.dispose();
    super.dispose();
  }

  Future<void> _calculateTmb() async {
    setState(() => _isTmbLoading = true);
    try {
      final res = await _api.calculateTmbAndTdee({
        'age': int.tryParse(_ageController.text) ?? 24,
        'sex': _sex,
        'weight_kg': double.tryParse(_weightController.text.replaceAll(',', '.')) ?? 75.0,
        'height_cm': double.tryParse(_heightController.text.replaceAll(',', '.')) ?? 175.0,
        'activity_level': _activityLevel,
        'goal': _goal,
      });
      if (!mounted) return;
      setState(() {
        _tmbResult = res;
        _isTmbLoading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _isTmbLoading = false);
    }
  }

  Future<void> _calculateBurn() async {
    setState(() => _isBurnLoading = true);
    try {
      final res = await _api.calculateExerciseCalories({
        'activity': _selectedActivity,
        'weight_kg': double.tryParse(_exerciseWeightController.text.replaceAll(',', '.')) ?? 75.0,
        'duration_min': int.tryParse(_durationController.text) ?? 30,
        'intensity': _intensityMultiplier,
      });
      if (!mounted) return;
      setState(() {
        _burnResult = res;
        _isBurnLoading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _isBurnLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Calculadoras Fitness'),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppTheme.primaryColor,
          labelColor: AppTheme.primaryColor,
          unselectedLabelColor: Colors.grey,
          tabs: const [
            Tab(text: 'TMB & Metabolismo', icon: Icon(Icons.bolt_rounded)),
            Tab(text: 'Queima por Exercício', icon: Icon(Icons.local_fire_department_rounded)),
          ],
        ),
      ),
      body: Column(
        children: [
          // Banners de Ferramentas Avançadas
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            color: AppTheme.darkBackground,
            child: Row(
              children: [
                _buildToolBanner(
                  '🎯 Projeção de Peso',
                  Icons.show_chart_rounded,
                  Colors.cyanAccent,
                  () => Navigator.pushNamed(context, '/weight-projection'),
                ),
                const SizedBox(width: 8),
                _buildToolBanner(
                  '🏋️ Anilhas na Barra',
                  Icons.fitness_center_rounded,
                  Colors.amberAccent,
                  () => PlateCalculatorDialog.show(context),
                ),
                const SizedBox(width: 8),
                _buildToolBanner(
                  '🔍 Comparar Alimentos',
                  Icons.compare_arrows_rounded,
                  Colors.pinkAccent,
                  () => Navigator.pushNamed(context, '/food-comparison'),
                ),
              ],
            ),
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildTmbTab(),
                _buildBurnTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildToolBanner(String label, IconData icon, Color color, VoidCallback onTap) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.12),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: color.withOpacity(0.35)),
          ),
          child: Column(
            children: [
              Icon(icon, color: color, size: 18),
              const SizedBox(height: 3),
              Text(label, style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 9), textAlign: TextAlign.center),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTmbTab() {
    final weightVal = double.tryParse(_weightController.text.replaceAll(',', '.')) ?? 75.0;
    final recommendedWaterMl = (weightVal * 35).toInt();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          GlassCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Seus Dados Fisiológicos', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                const SizedBox(height: 14),
                Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        value: _sex,
                        decoration: InputDecoration(
                          labelText: 'Sexo',
                          filled: true,
                          fillColor: AppTheme.darkBackground,
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
                        ),
                        dropdownColor: AppTheme.cardDarkBackground,
                        items: const [
                          DropdownMenuItem(value: 'male', child: Text('Masculino')),
                          DropdownMenuItem(value: 'female', child: Text('Feminino')),
                        ],
                        onChanged: (val) => setState(() => _sex = val ?? 'male'),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: TextField(
                        controller: _ageController,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          labelText: 'Idade',
                          filled: true,
                          fillColor: AppTheme.darkBackground,
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _weightController,
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        decoration: InputDecoration(
                          labelText: 'Peso (kg)',
                          filled: true,
                          fillColor: AppTheme.darkBackground,
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: TextField(
                        controller: _heightController,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          labelText: 'Altura (cm)',
                          filled: true,
                          fillColor: AppTheme.darkBackground,
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                DropdownButtonFormField<String>(
                  value: _activityLevel,
                  decoration: InputDecoration(
                    labelText: 'Nível de Atividade',
                    filled: true,
                    fillColor: AppTheme.darkBackground,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
                  ),
                  dropdownColor: AppTheme.cardDarkBackground,
                  items: const [
                    DropdownMenuItem(value: 'sedentary', child: Text('Sedentário (pouco/nenhum)')),
                    DropdownMenuItem(value: 'light', child: Text('Leve (1-2x semana)')),
                    DropdownMenuItem(value: 'moderate', child: Text('Moderado (3-5x semana)')),
                    DropdownMenuItem(value: 'very_active', child: Text('Muito Ativo (6-7x semana)')),
                    DropdownMenuItem(value: 'extra_active', child: Text('Extremamente Ativo (atleta)')),
                  ],
                  onChanged: (val) => setState(() => _activityLevel = val ?? 'moderate'),
                ),
                const SizedBox(height: 10),
                DropdownButtonFormField<String>(
                  value: _goal,
                  decoration: InputDecoration(
                    labelText: 'Objetivo',
                    filled: true,
                    fillColor: AppTheme.darkBackground,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
                  ),
                  dropdownColor: AppTheme.cardDarkBackground,
                  items: const [
                    DropdownMenuItem(value: 'hypertrophy', child: Text('Hipertrofia (+350 kcal)')),
                    DropdownMenuItem(value: 'weight_loss', child: Text('Emagrecimento (-450 kcal)')),
                    DropdownMenuItem(value: 'maintenance', child: Text('Manutenção de Peso')),
                  ],
                  onChanged: (val) => setState(() => _goal = val ?? 'hypertrophy'),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryColor,
                      foregroundColor: Colors.black,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    onPressed: _calculateTmb,
                    child: const Text('Calcular Metabolismo', style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),

          if (_tmbResult != null) ...[
            GlassCard(
              borderColor: AppTheme.primaryColor.withOpacity(0.3),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Resultados do Seu Metabolismo', style: TextStyle(color: AppTheme.primaryColor, fontWeight: FontWeight.bold, fontSize: 16)),
                  const SizedBox(height: 14),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildMetricBox('TMB (Basal)', '${_tmbResult!['tmb']} kcal', 'Energia em repouso'),
                      _buildMetricBox('TDEE (Total)', '${_tmbResult!['tdee']} kcal', 'Gasto diário real'),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppTheme.darkBackground,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Meta Calórica Recomendada:', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
                        Text(
                          '${_tmbResult!['recommendedCalories']} kcal/dia',
                          style: const TextStyle(color: AppTheme.primaryColor, fontWeight: FontWeight.extrabold, fontSize: 15),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),
                  Text('Divisão Sugerida de Macronutrientes:', style: TextStyle(color: Colors.grey[300], fontSize: 12, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      _buildMacroBadge('Proteína', '${_tmbResult!['macros']['proteinG']}g', Colors.blueAccent),
                      const SizedBox(width: 8),
                      _buildMacroBadge('Carboidrato', '${_tmbResult!['macros']['carbsG']}g', Colors.orangeAccent),
                      const SizedBox(width: 8),
                      _buildMacroBadge('Gordura', '${_tmbResult!['macros']['fatG']}g', Colors.pinkAccent),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Espectro Visual de IMC
                  Text('Índice de Massa Corporal (IMC): ${_tmbResult!['bmi']} — ${_tmbResult!['bmiClassification']}', style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 6),
                  _buildBmiSpectrumBar(_tmbResult!['bmi'] as num),
                  const SizedBox(height: 16),

                  // Ingestão Hídrica Recomendada
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.cyanAccent.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.cyanAccent.withOpacity(0.3)),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.water_drop_rounded, color: Colors.cyanAccent, size: 20),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Ingestão hídrica recomendada: ${(recommendedWaterMl / 1000).toStringAsFixed(1)}L de água por dia ($recommendedWaterMl ml)',
                            style: const TextStyle(color: Colors.white, fontSize: 12),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildBmiSpectrumBar(num bmi) {
    return Column(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: Row(
            children: [
              Expanded(flex: 18, child: Container(height: 8, color: Colors.blueAccent)),
              Expanded(flex: 6, child: Container(height: 8, color: Colors.greenAccent)),
              Expanded(flex: 5, child: Container(height: 8, color: Colors.orangeAccent)),
              Expanded(flex: 10, child: Container(height: 8, color: Colors.redAccent)),
            ],
          ),
        ),
        const SizedBox(height: 4),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: const [
            Text('< 18.5 Baixo', style: TextStyle(color: Colors.grey, fontSize: 9)),
            Text('18.5 - 24.9 Normal', style: TextStyle(color: Colors.grey, fontSize: 9)),
            Text('25 - 29.9 Sobrepeso', style: TextStyle(color: Colors.grey, fontSize: 9)),
            Text('> 30 Obesidade', style: TextStyle(color: Colors.grey, fontSize: 9)),
          ],
        ),
      ],
    );
  }

  Widget _buildBurnTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          GlassCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Calcular Queima Calórica por Exercício', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                const SizedBox(height: 14),
                DropdownButtonFormField<String>(
                  value: _selectedActivity,
                  decoration: InputDecoration(
                    labelText: 'Atividade Física',
                    filled: true,
                    fillColor: AppTheme.darkBackground,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
                  ),
                  dropdownColor: AppTheme.cardDarkBackground,
                  items: const [
                    DropdownMenuItem(value: 'running_moderate', child: Text('Corrida Moderada (8-10 km/h)')),
                    DropdownMenuItem(value: 'running_fast', child: Text('Corrida Intensa (>10 km/h)')),
                    DropdownMenuItem(value: 'walking_light', child: Text('Caminhada Leve')),
                    DropdownMenuItem(value: 'walking_fast', child: Text('Caminhada Rápida')),
                    DropdownMenuItem(value: 'weightlifting_moderate', child: Text('Musculação Moderada')),
                    DropdownMenuItem(value: 'weightlifting_heavy', child: Text('Musculação Intensa')),
                    DropdownMenuItem(value: 'cycling_moderate', child: Text('Bicicleta Moderada')),
                    DropdownMenuItem(value: 'cycling_fast', child: Text('Bicicleta Intensa / Spinning')),
                    DropdownMenuItem(value: 'elliptical', child: Text('Elíptico')),
                    DropdownMenuItem(value: 'jump_rope', child: Text('Pular Corda')),
                    DropdownMenuItem(value: 'swimming', child: Text('Natação')),
                    DropdownMenuItem(value: 'hiit', child: Text('Treino Funcional / HIIT')),
                  ],
                  onChanged: (val) => setState(() => _selectedActivity = val ?? 'running_moderate'),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _durationController,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          labelText: 'Duração (min)',
                          filled: true,
                          fillColor: AppTheme.darkBackground,
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: TextField(
                        controller: _exerciseWeightController,
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        decoration: InputDecoration(
                          labelText: 'Seu Peso (kg)',
                          filled: true,
                          fillColor: AppTheme.darkBackground,
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryColor,
                      foregroundColor: Colors.black,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    icon: const Icon(Icons.local_fire_department_rounded),
                    label: const Text('Estimar Queima de Calorias', style: TextStyle(fontWeight: FontWeight.bold)),
                    onPressed: _calculateBurn,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),

          if (_burnResult != null) ...[
            GlassCard(
              borderColor: Colors.orangeAccent.withOpacity(0.4),
              child: Column(
                children: [
                  const Icon(Icons.local_fire_department_rounded, color: Colors.orangeAccent, size: 36),
                  const SizedBox(height: 8),
                  Text(
                    '${_burnResult!['estimatedCaloriesKcal']} kcal',
                    style: const TextStyle(fontSize: 32, fontWeight: FontWeight.extrabold, color: Colors.white),
                  ),
                  Text(
                    'Gasto estimado em ${_burnResult!['durationMin']} min de ${_burnResult!['activityName']}',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey[300], fontSize: 13),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    _burnResult!['disclaimer'] ?? '',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey[500], fontSize: 11, fontStyle: FontStyle.italic),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildMetricBox(String title, String value, String desc) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        margin: const EdgeInsets.symmetric(horizontal: 4),
        decoration: BoxDecoration(
          color: AppTheme.darkBackground,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(color: Colors.grey, fontSize: 11, fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Text(value, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 2),
            Text(desc, style: TextStyle(color: Colors.grey[500], fontSize: 10)),
          ],
        ),
      ),
    );
  }

  Widget _buildMacroBadge(String name, String value, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
        decoration: BoxDecoration(
          color: AppTheme.darkBackground,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(name, style: TextStyle(color: Colors.grey[400], fontSize: 10)),
            const SizedBox(height: 2),
            Text(value, style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 13)),
          ],
        ),
      ),
    );
  }
}
