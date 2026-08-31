// lib/screens/ai_plate_estimator_dialog.dart

import 'package:flutter/material.dart';
import '../core/theme/app_theme.dart';
import '../models/nutrition.dart';
import '../services/api_service.dart';
import '../widgets/ai_pulse_avatar.dart';

class AiPlateEstimatorDialog extends StatefulWidget {
  final String? initialMealType;
  final VoidCallback onMealSaved;

  const AiPlateEstimatorDialog({super.key, this.initialMealType, required this.onMealSaved});

  @override
  State<AiPlateEstimatorDialog> createState() => _AiPlateEstimatorDialogState();
}

class _AiPlateEstimatorDialogState extends State<AiPlateEstimatorDialog> {
  final ApiService _api = ApiService();
  final TextEditingController _textController = TextEditingController();

  String _mealType = 'lunch';
  bool _isEstimating = false;
  bool _isSaving = false;
  String _errorMessage = '';

  List<Map<String, dynamic>> _items = [];
  Map<String, dynamic> _total = {'kcal': 0, 'protein': 0, 'carbs': 0, 'fat': 0};

  final List<String> _quickPhrases = [
    '2 fatias de pão integral com 3 ovos mexidos e 1 banana',
    '150g de peito de frango, 4 colheres de arroz e 1 concha de feijão',
    '1 dose de whey protein com 200ml de leite desnatado e 30g de aveia',
    '150g de batata doce cozida com 120g de carne moída e brócolis',
  ];

  @override
  void initState() {
    super.initState();
    _mealType = widget.initialMealType ?? 'lunch';
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  Future<void> _estimate() async {
    final text = _textController.text.trim();
    if (text.length < 3) {
      setState(() => _errorMessage = 'Digite o que você comeu (ex: 2 ovos com arroz e frango).');
      return;
    }

    setState(() {
      _isEstimating = true;
      _errorMessage = '';
    });

    try {
      final res = await _api.estimateMealFromText(text);
      if (!mounted) return;
      setState(() {
        _items = (res['items'] as List<dynamic>? ?? []).cast<Map<String, dynamic>>();
        _total = res['total'] as Map<String, dynamic>? ?? {'kcal': 0, 'protein': 0, 'carbs': 0, 'fat': 0};
        _isEstimating = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isEstimating = false;
        _errorMessage = 'Erro ao processar refeição com IA. Tente novamente.';
      });
    }
  }

  Future<void> _saveMeal() async {
    if (_items.isEmpty) return;

    setState(() => _isSaving = true);
    try {
      final description = _items.map((i) => '${i['name']} (${i['portionLabel'] ?? '${i['portionG']}g'})').join(' + ');

      await _api.logMeal({
        'meal_type': _mealType,
        'description': description.length > 200 ? '${_textController.text.trim()}' : description,
        'calories_kcal': (_total['kcal'] as num?)?.toDouble() ?? 0,
        'protein_g': (_total['protein'] as num?)?.toDouble() ?? 0,
        'carbs_g': (_total['carbs'] as num?)?.toDouble() ?? 0,
        'fat_g': (_total['fat'] as num?)?.toDouble() ?? 0,
      });

      if (!mounted) return;
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('✨ Refeição calculada e adicionada ao ${mealTypeLabel(_mealType)}!'),
          backgroundColor: AppTheme.primaryDark,
          duration: const Duration(seconds: 3),
        ),
      );
      widget.onMealSaved();
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isSaving = false;
        _errorMessage = 'Erro ao salvar refeição no diário.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: AppTheme.cardDarkBackground,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Cabeçalho
              Row(
                children: [
                  const AiPulseAvatar(size: 38, glowColor: AppTheme.primaryColor),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Visão do Prato com IA', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                        Text('Descreva em texto livre o que comeu', style: TextStyle(color: Colors.grey, fontSize: 11)),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              const Divider(color: Colors.white10),
              const SizedBox(height: 8),

              // Tipo de Refeição
              DropdownButtonFormField<String>(
                value: _mealType,
                decoration: InputDecoration(
                  labelText: 'Destino da Refeição',
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
                ],
                onChanged: (val) => setState(() => _mealType = val ?? 'lunch'),
              ),
              const SizedBox(height: 12),

              // Campo de Texto Livre
              TextField(
                controller: _textController,
                maxLines: 3,
                decoration: InputDecoration(
                  hintText: 'Ex: 2 colheres de arroz, 1 concha de feijão, 1 bife de frango e salada de alface...',
                  filled: true,
                  fillColor: AppTheme.darkBackground,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                ),
              ),
              const SizedBox(height: 8),

              // Exemplos Rápidos
              const Text('Exemplos rápidos:', style: TextStyle(color: Colors.grey, fontSize: 11)),
              const SizedBox(height: 4),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: _quickPhrases.map((phrase) {
                    return Padding(
                      padding: const EdgeInsets.only(right: 6),
                      child: ActionChip(
                        backgroundColor: AppTheme.darkBackground,
                        label: Text(phrase, style: const TextStyle(color: Colors.white70, fontSize: 10)),
                        onPressed: () {
                          _textController.text = phrase;
                          _estimate();
                        },
                      ),
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(height: 12),

              // Botão Calcular
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryColor,
                  foregroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                icon: _isEstimating
                    ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.black))
                    : const Icon(Icons.auto_awesome, size: 18),
                label: Text(_isEstimating ? 'Calculando Prato com IA...' : 'Calcular Alimentos', style: const TextStyle(fontWeight: FontWeight.bold)),
                onPressed: _isEstimating ? null : _estimate,
              ),

              if (_errorMessage.isNotEmpty) ...[
                const SizedBox(height: 8),
                Text(_errorMessage, style: const TextStyle(color: Colors.redAccent, fontSize: 12)),
              ],

              // Resultados Decompostos
              if (_items.isNotEmpty) ...[
                const SizedBox(height: 16),
                const Divider(color: Colors.white10),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Alimentos Reconhecidos:', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
                    Text('${_items.length} itens', style: const TextStyle(color: AppTheme.primaryColor, fontWeight: FontWeight.bold, fontSize: 12)),
                  ],
                ),
                const SizedBox(height: 8),

                // Lista de itens
                ..._items.map((item) {
                  return Container(
                    margin: const EdgeInsets.only(bottom: 6),
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                    decoration: BoxDecoration(
                      color: AppTheme.darkBackground,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(item['name'] ?? '', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
                              Text(item['portionLabel'] ?? '${item['portionG']}g', style: TextStyle(color: Colors.grey[400], fontSize: 10)),
                            ],
                          ),
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text('${item['kcal']} kcal', style: const TextStyle(color: AppTheme.primaryColor, fontWeight: FontWeight.bold, fontSize: 12)),
                            Text('P: ${item['protein']}g • C: ${item['carbs']}g • G: ${item['fat']}g', style: TextStyle(color: Colors.grey[400], fontSize: 9)),
                          ],
                        ),
                      ],
                    ),
                  );
                }),
                const SizedBox(height: 10),

                // Card Total
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryColor.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppTheme.primaryColor.withOpacity(0.3)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildSummaryMetric('Total Kcal', '${_total['kcal']} kcal', AppTheme.primaryColor),
                      _buildSummaryMetric('Proteínas', '${_total['protein']}g', Colors.blueAccent),
                      _buildSummaryMetric('Carboidratos', '${_total['carbs']}g', Colors.orangeAccent),
                      _buildSummaryMetric('Gorduras', '${_total['fat']}g', Colors.pinkAccent),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Botão de Salvar Refeição
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.greenAccent[700],
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  icon: _isSaving
                      ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                      : const Icon(Icons.check_circle_rounded, size: 20),
                  label: const Text('Lançar Refeição Completa no Diário', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                  onPressed: _isSaving ? null : _saveMeal,
                ),
              ],

              const SizedBox(height: 6),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Fechar', style: TextStyle(color: Colors.grey)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSummaryMetric(String label, String value, Color color) {
    return Column(
      children: [
        Text(label, style: TextStyle(color: Colors.grey[400], fontSize: 10)),
        const SizedBox(height: 2),
        Text(value, style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 13)),
      ],
    );
  }
}

