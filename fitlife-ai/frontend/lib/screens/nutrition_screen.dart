// lib/screens/nutrition_screen.dart

import 'package:flutter/material.dart';
import '../core/theme/app_theme.dart';
import '../models/nutrition.dart';
import '../services/api_service.dart';
import '../widgets/glass_card.dart';
import 'food_search_screen.dart';
import 'ai_plate_estimator_dialog.dart';

class NutritionScreen extends StatefulWidget {
  const NutritionScreen({super.key});

  @override
  State<NutritionScreen> createState() => _NutritionScreenState();
}

class _NutritionScreenState extends State<NutritionScreen> {
  final ApiService _api = ApiService();
  DailyNutritionSummary? _summary;
  Map<String, dynamic> _mealTargetsMap = {};
  bool _isLoading = true;

  final List<Map<String, dynamic>> _foodPresets = [
    {'name': 'Frango Grelhado 100g', 'kcal': 163, 'p': 31, 'c': 0, 'f': 4, 'meal': 'lunch'},
    {'name': '2 Ovos Cozidos', 'kcal': 146, 'p': 13, 'c': 1, 'f': 10, 'meal': 'breakfast'},
    {'name': 'Whey Protein 30g', 'kcal': 114, 'p': 23, 'c': 2, 'f': 2, 'meal': 'afternoon_snack'},
    {'name': 'Arroz Branco 100g', 'kcal': 128, 'p': 3, 'c': 28, 'f': 0, 'meal': 'lunch'},
    {'name': 'Banana Prata 1 un', 'kcal': 98, 'p': 1, 'c': 26, 'f': 0, 'meal': 'morning_snack'},
    {'name': 'Aveia em Flocos 30g', 'kcal': 118, 'p': 4, 'c': 20, 'f': 3, 'meal': 'breakfast'},
    {'name': 'Batata Doce 150g', 'kcal': 115, 'p': 2, 'c': 28, 'f': 0, 'meal': 'lunch'},
    {'name': 'Azeite de Oliva 1 colher (13ml)', 'kcal': 108, 'p': 0, 'c': 0, 'f': 12, 'meal': 'lunch'},
  ];

  @override
  void initState() {
    super.initState();
    _loadDailyNutrition();
  }

  Future<void> _loadDailyNutrition() async {
    setState(() => _isLoading = true);
    try {
      final results = await Future.wait([
        _api.getDailyNutritionSummary(),
        _api.getMealTargets(),
      ]);

      if (!mounted) return;
      final summary = results[0] as DailyNutritionSummary;
      final targetsData = results[1] as Map<String, dynamic>;

      final map = <String, Map<String, dynamic>>{};
      for (final m in (targetsData['meals'] as List<dynamic>? ?? [])) {
        map[m['key']] = m as Map<String, dynamic>;
      }

      setState(() {
        _summary = summary;
        _mealTargetsMap = map;
        _isLoading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _isLoading = false);
    }
  }

  void _openFoodSearch({String? mealType}) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => FoodSearchScreen(
          initialMealType: mealType,
          onMealAdded: _loadDailyNutrition,
        ),
      ),
    ).then((_) => _loadDailyNutrition());
  }

  void _openPlateEstimator({String? mealType}) {
    showDialog(
      context: context,
      builder: (_) => AiPlateEstimatorDialog(
        initialMealType: mealType,
        onMealSaved: _loadDailyNutrition,
      ),
    );
  }

  Future<void> _quickAddPreset(Map<String, dynamic> preset) async {
    try {
      await _api.logMeal({
        'meal_type': preset['meal'],
        'description': preset['name'],
        'calories_kcal': (preset['kcal'] as num).toDouble(),
        'protein_g': (preset['p'] as num).toDouble(),
        'carbs_g': (preset['c'] as num).toDouble(),
        'fat_g': (preset['f'] as num).toDouble(),
      });
      _loadDailyNutrition();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${preset['name']} adicionado com sucesso!'),
          backgroundColor: AppTheme.primaryDark,
          duration: const Duration(seconds: 2),
        ),
      );
    } catch (_) {}
  }

  Future<void> _showManualAddMealDialog({String? initialType}) async {
    String mealType = initialType ?? 'lunch';
    final descController = TextEditingController();
    final calController = TextEditingController();
    final proteinController = TextEditingController();
    final carbsController = TextEditingController();
    final fatController = TextEditingController();

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppTheme.cardDarkBackground,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                left: 20,
                right: 20,
                top: 20,
                bottom: MediaQuery.of(ctx).viewInsets.bottom + 20,
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Registro Manual de Refeição', style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: Colors.white)),
                        TextButton.icon(
                          icon: const Icon(Icons.search, size: 16, color: AppTheme.primaryColor),
                          label: const Text('Buscar', style: TextStyle(color: AppTheme.primaryColor, fontSize: 12)),
                          onPressed: () {
                            Navigator.pop(ctx);
                            _openFoodSearch(mealType: mealType);
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      value: mealType,
                      decoration: InputDecoration(
                        labelText: 'Tipo de Refeição',
                        filled: true,
                        fillColor: AppTheme.darkBackground,
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                      ),
                      dropdownColor: AppTheme.cardDarkBackground,
                      items: const [
                        DropdownMenuItem(value: 'breakfast', child: Text('Café da Manhã')),
                        DropdownMenuItem(value: 'morning_snack', child: Text('Lanche da Manhã')),
                        DropdownMenuItem(value: 'lunch', child: Text('Almoço')),
                        DropdownMenuItem(value: 'afternoon_snack', child: Text('Lanche da Tarde')),
                        DropdownMenuItem(value: 'dinner', child: Text('Jantar')),
                        DropdownMenuItem(value: 'supper', child: Text('Ceia')),
                        DropdownMenuItem(value: 'other', child: Text('Outras')),
                      ],
                      onChanged: (val) => setModalState(() => mealType = val ?? 'lunch'),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: descController,
                      decoration: InputDecoration(
                        labelText: 'Descrição (ex: 2 ovos + 2 fatias de pão)',
                        filled: true,
                        fillColor: AppTheme.darkBackground,
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: calController,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      decoration: InputDecoration(
                        labelText: 'Calorias (kcal) *',
                        filled: true,
                        fillColor: AppTheme.darkBackground,
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: proteinController,
                            keyboardType: TextInputType.number,
                            decoration: InputDecoration(
                              labelText: 'Proteína (g)',
                              filled: true,
                              fillColor: AppTheme.darkBackground,
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: TextField(
                            controller: carbsController,
                            keyboardType: TextInputType.number,
                            decoration: InputDecoration(
                              labelText: 'Carboidrato (g)',
                              filled: true,
                              fillColor: AppTheme.darkBackground,
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: TextField(
                            controller: fatController,
                            keyboardType: TextInputType.number,
                            decoration: InputDecoration(
                              labelText: 'Gordura (g)',
                              filled: true,
                              fillColor: AppTheme.darkBackground,
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primaryColor,
                        foregroundColor: Colors.black,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      onPressed: () async {
                        final cal = double.tryParse(calController.text.trim().replaceAll(',', '.')) ?? 0;
                        Navigator.pop(ctx);
                        try {
                          await _api.logMeal({
                            'meal_type': mealType,
                            'description': descController.text.trim().isEmpty ? 'Refeição' : descController.text.trim(),
                            'calories_kcal': cal,
                            'protein_g': double.tryParse(proteinController.text.trim()) ?? 0,
                            'carbs_g': double.tryParse(carbsController.text.trim()) ?? 0,
                            'fat_g': double.tryParse(fatController.text.trim()) ?? 0,
                          });
                          _loadDailyNutrition();
                        } catch (_) {}
                      },
                      child: const Text('Salvar Refeição', style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _deleteMeal(int id) async {
    try {
      await _api.deleteMeal(id);
      _loadDailyNutrition();
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    final s = _summary;
    final progress = ((s?.totalCalories ?? 0) / (s?.targetCalories ?? 2200)).clamp(0.0, 1.0);

    return Scaffold(
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: AppTheme.primaryColor))
          : RefreshIndicator(
              color: AppTheme.primaryColor,
              onRefresh: _loadDailyNutrition,
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                children: [
                  // Card Balanço Calórico Topo
                  GlassCard(
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('CONSUMIDO HOJE', style: TextStyle(color: Colors.grey, fontSize: 11, fontWeight: FontWeight.bold)),
                                const SizedBox(height: 2),
                                Text(
                                  '${s?.totalCalories.toInt() ?? 0} kcal',
                                  style: const TextStyle(fontSize: 28, fontWeight: FontWeight.extrabold, color: Colors.white),
                                ),
                              ],
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                const Text('META DIÁRIA', style: TextStyle(color: Colors.grey, fontSize: 11, fontWeight: FontWeight.bold)),
                                const SizedBox(height: 2),
                                Text(
                                  '${s?.targetCalories ?? 2200} kcal',
                                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppTheme.primaryColor),
                                ),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(6),
                          child: LinearProgressIndicator(
                            value: progress,
                            backgroundColor: AppTheme.darkBackground,
                            valueColor: const AlwaysStoppedAnimation<Color>(AppTheme.primaryColor),
                            minHeight: 10,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Align(
                          alignment: Alignment.centerRight,
                          child: Text(
                            'Restam ${s?.remainingCalories ?? 0} kcal',
                            style: const TextStyle(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.w600),
                          ),
                        ),
                        const Divider(color: Colors.white10, height: 20),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            _buildMacroBadge('Proteína', '${s?.totalProtein.toInt() ?? 0}g', '${s?.targetProteinG ?? 140}g', Colors.blueAccent),
                            _buildMacroBadge('Carboidrato', '${s?.totalCarbs.toInt() ?? 0}g', '${s?.targetCarbsG ?? 250}g', Colors.orangeAccent),
                            _buildMacroBadge('Gordura', '${s?.totalFat.toInt() ?? 0}g', '${s?.targetFatG ?? 65}g', Colors.pinkAccent),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),

                  // Atalhos Inteligentes (Busca na Base + Visão do Prato Texto + Scanner de Câmera)
                  Row(
                    children: [
                      Expanded(
                        child: InkWell(
                          borderRadius: BorderRadius.circular(14),
                          onTap: () => _openFoodSearch(),
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
                            decoration: BoxDecoration(
                              color: AppTheme.cardDarkBackground,
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(color: Colors.white12),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: const [
                                Icon(Icons.search_rounded, color: AppTheme.primaryColor, size: 16),
                                SizedBox(width: 4),
                                Text(
                                  'Base TACO',
                                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 11),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: InkWell(
                          borderRadius: BorderRadius.circular(14),
                          onTap: () => _openPlateEstimator(),
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
                            decoration: BoxDecoration(
                              color: AppTheme.cardDarkBackground,
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(color: Colors.white12),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: const [
                                Icon(Icons.edit_note_rounded, color: Colors.cyanAccent, size: 16),
                                SizedBox(width: 4),
                                Text(
                                  'Texto Livre',
                                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 11),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: InkWell(
                          borderRadius: BorderRadius.circular(14),
                          onTap: () => Navigator.pushNamed(context, '/camera-scanner').then((_) => _loadDailyNutrition()),
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  AppTheme.primaryColor.withOpacity(0.3),
                                  AppTheme.primaryDark.withOpacity(0.15),
                                ],
                              ),
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(color: AppTheme.primaryColor.withOpacity(0.5)),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: const [
                                Icon(Icons.camera_alt_rounded, color: AppTheme.primaryColor, size: 16),
                                SizedBox(width: 4),
                                Text(
                                  'Foto IA 📸',
                                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 11),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),

                  // Atalhos Rápidos de Alimentos (Presets)
                  const Text('Alimentos Rápidos', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
                  const SizedBox(height: 8),
                  SizedBox(
                    height: 38,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: _foodPresets.length,
                      itemBuilder: (context, index) {
                        final item = _foodPresets[index];
                        return Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: ActionChip(
                            backgroundColor: AppTheme.cardDarkBackground,
                            avatar: const Icon(Icons.add, size: 14, color: AppTheme.primaryColor),
                            label: Text('${item['name']} (+${item['kcal']} kcal)', style: const TextStyle(color: Colors.white70, fontSize: 11)),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14), side: BorderSide(color: Colors.white.withOpacity(0.05))),
                            onPressed: () => _quickAddPreset(item),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 18),

                  // Seções de Refeições com Divisão Inteligente de Metas
                  _buildMealCategoryCard('Café da Manhã', 'breakfast', Icons.wb_sunny_outlined),
                  _buildMealCategoryCard('Almoço', 'lunch', Icons.lunch_dining_outlined),
                  _buildMealCategoryCard('Lanches', 'afternoon_snack', Icons.apple_outlined, altTypes: ['morning_snack', 'afternoon_snack']),
                  _buildMealCategoryCard('Jantar & Ceia', 'dinner', Icons.nightlight_round_outlined, altTypes: ['dinner', 'supper', 'other']),
                  const SizedBox(height: 70),
                ],
              ),
            ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.black,
        icon: const Icon(Icons.auto_awesome),
        label: const Text('Visão do Prato IA', style: TextStyle(fontWeight: FontWeight.bold)),
        onPressed: () => _openPlateEstimator(),
      ),
    );
  }

  Widget _buildMacroBadge(String label, String current, String target, Color color) {
    return Column(
      children: [
        Text(label, style: TextStyle(color: Colors.grey[400], fontSize: 11)),
        const SizedBox(height: 3),
        Text(current, style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 15)),
        Text('meta $target', style: TextStyle(color: Colors.grey[500], fontSize: 10)),
      ],
    );
  }

  Widget _buildMealCategoryCard(String title, String typeKey, IconData icon, {List<String>? altTypes}) {
    final types = altTypes ?? [typeKey];
    final meals = _summary?.meals.where((m) => types.contains(m.mealType)).toList() ?? [];
    final categoryCalories = meals.fold(0.0, (sum, m) => sum + m.caloriesKcal);

    // Meta inteligente da refeição
    final targetInfo = _mealTargetsMap[typeKey];
    final targetKcal = (targetInfo?['targetKcal'] as num?)?.toDouble() ?? 500.0;
    final targetProtein = (targetInfo?['targetProteinG'] as num?)?.toDouble() ?? 30.0;
    final progressKcal = (categoryCalories / (targetKcal > 0 ? targetKcal : 500)).clamp(0.0, 1.0);

    return GlassCard(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: AppTheme.primaryColor, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 15)),
                    Text(
                      'Meta: ${targetKcal.toInt()} kcal • ${targetProtein.toInt()}g prot',
                      style: TextStyle(color: Colors.grey[400], fontSize: 10),
                    ),
                  ],
                ),
              ),
              Text(
                '${categoryCalories.toInt()} kcal',
                style: const TextStyle(color: AppTheme.primaryColor, fontWeight: FontWeight.bold, fontSize: 14),
              ),
              const SizedBox(width: 8),
              // Botão Visão do Prato com IA
              IconButton(
                icon: const Icon(Icons.auto_awesome, color: AppTheme.primaryColor, size: 18),
                tooltip: 'Visão do Prato com IA',
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                onPressed: () => _openPlateEstimator(mealType: typeKey),
              ),
              const SizedBox(width: 8),
              // Botão de busca inteligente
              IconButton(
                icon: const Icon(Icons.search_rounded, color: Colors.white70, size: 19),
                tooltip: 'Buscar na base',
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                onPressed: () => _openFoodSearch(mealType: typeKey),
              ),
              const SizedBox(width: 8),
              // Botão de adicionar manual
              IconButton(
                icon: const Icon(Icons.add_circle_outline, color: Colors.white70, size: 19),
                tooltip: 'Registro manual',
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                onPressed: () => _showManualAddMealDialog(initialType: typeKey),
              ),
            ],
          ),
          const SizedBox(height: 8),

          // Mini Barra de Progresso da Refeição
          ClipRRect(
            borderRadius: BorderRadius.circular(3),
            child: LinearProgressIndicator(
              value: progressKcal,
              backgroundColor: AppTheme.darkBackground,
              valueColor: AlwaysStoppedAnimation<Color>(
                progressKcal >= 1.0 ? Colors.greenAccent : AppTheme.primaryColor,
              ),
              minHeight: 4,
            ),
          ),

          if (meals.isNotEmpty) ...[
            const Divider(color: Colors.white10, height: 16),
            ...meals.map((m) {
              return ListTile(
                dense: true,
                contentPadding: EdgeInsets.zero,
                title: Text(m.description ?? 'Refeição', style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w500)),
                subtitle: Text(
                  '${m.caloriesKcal.toInt()} kcal • P: ${m.proteinG.toInt()}g • C: ${m.carbsG.toInt()}g • G: ${m.fatG.toInt()}g',
                  style: TextStyle(color: Colors.grey[400], fontSize: 11),
                ),
                trailing: IconButton(
                  icon: const Icon(Icons.delete_outline, color: Colors.redAccent, size: 18),
                  onPressed: () => _deleteMeal(m.id),
                ),
              );
            }),
          ],
        ],
      ),
    );
  }
}
