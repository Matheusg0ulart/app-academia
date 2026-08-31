// lib/screens/food_comparison_screen.dart

import 'package:flutter/material.dart';
import '../core/theme/app_theme.dart';
import '../models/food_item.dart';
import '../services/api_service.dart';
import '../widgets/glass_card.dart';

class FoodComparisonScreen extends StatefulWidget {
  const FoodComparisonScreen({super.key});

  @override
  State<FoodComparisonScreen> createState() => _FoodComparisonScreenState();
}

class _FoodComparisonScreenState extends State<FoodComparisonScreen> {
  final ApiService _api = ApiService();

  FoodItem? _foodA;
  FoodItem? _foodB;

  final TextEditingController _searchAController = TextEditingController();
  final TextEditingController _searchBController = TextEditingController();

  List<FoodItem> _resultsA = [];
  List<FoodItem> _resultsB = [];

  bool _searchingA = false;
  bool _searchingB = false;

  @override
  void dispose() {
    _searchAController.dispose();
    _searchBController.dispose();
    super.dispose();
  }

  Future<void> _search(String query, bool isA) async {
    if (query.length < 2) return;
    if (isA) setState(() => _searchingA = true);
    else setState(() => _searchingB = true);

    try {
      final items = await _api.searchFoods(query);
      if (!mounted) return;
      if (isA) setState(() { _resultsA = items; _searchingA = false; });
      else setState(() { _resultsB = items; _searchingB = false; });
    } catch (_) {
      if (!mounted) return;
      if (isA) setState(() => _searchingA = false);
      else setState(() => _searchingB = false);
    }
  }

  String _verdict() {
    final a = _foodA;
    final b = _foodB;
    if (a == null || b == null) return '';

    final protDensityA = a.calories100g > 0 ? (a.protein100g / a.calories100g) * 100 : 0;
    final protDensityB = b.calories100g > 0 ? (b.protein100g / b.calories100g) * 100 : 0;

    if (protDensityA > protDensityB * 1.2) {
      return '🏆 ${a.name} tem ${((protDensityA - protDensityB) / protDensityB * 100).abs().toStringAsFixed(0)}% mais proteína por caloria — melhor para ganho magro e hipertrofia.';
    } else if (protDensityB > protDensityA * 1.2) {
      return '🏆 ${b.name} tem ${((protDensityB - protDensityA) / protDensityA * 100).abs().toStringAsFixed(0)}% mais proteína por caloria — melhor para ganho magro e hipertrofia.';
    } else if (a.calories100g < b.calories100g) {
      return '🎯 ${a.name} é mais leve em calorias por 100g. Preferível para controle de peso com manutenção muscular.';
    } else if (b.calories100g < a.calories100g) {
      return '🎯 ${b.name} é mais leve em calorias por 100g. Preferível para controle de peso com manutenção muscular.';
    }
    return '✅ Os dois alimentos são nutricionalmente equivalentes para seu objetivo.';
  }

  @override
  Widget build(BuildContext context) {
    final a = _foodA;
    final b = _foodB;
    final canCompare = a != null && b != null;

    return Scaffold(
      appBar: AppBar(title: const Text('Comparador de Alimentos')),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        children: [
          // Seletor Alimento A & B
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: _buildFoodSelector(label: 'Alimento A', controller: _searchAController, selected: _foodA, results: _resultsA, isSearching: _searchingA, isA: true)),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 30),
                child: Column(children: [
                  const Icon(Icons.compare_arrows_rounded, color: AppTheme.primaryColor, size: 28),
                  const SizedBox(height: 2),
                  const Text('VS', style: TextStyle(color: AppTheme.primaryColor, fontWeight: FontWeight.extrabold, fontSize: 13)),
                ]),
              ),
              Expanded(child: _buildFoodSelector(label: 'Alimento B', controller: _searchBController, selected: _foodB, results: _resultsB, isSearching: _searchingB, isA: false)),
            ],
          ),
          const SizedBox(height: 20),

          if (canCompare) ...[
            // Cabeçalho Comparativo
            Row(
              children: [
                Expanded(child: _buildFoodHeader(a, Colors.cyanAccent)),
                const SizedBox(width: 6),
                Expanded(child: _buildFoodHeader(b, Colors.pinkAccent)),
              ],
            ),
            const SizedBox(height: 14),

            // Linha de Métricas
            _buildComparisonRow('Calorias (por 100g)', a.calories100g, b.calories100g, 'kcal', lowerIsBetter: true),
            _buildComparisonRow('Proteínas', a.protein100g, b.protein100g, 'g', lowerIsBetter: false),
            _buildComparisonRow('Carboidratos', a.carbs100g, b.carbs100g, 'g', lowerIsBetter: true),
            _buildComparisonRow('Gorduras', a.fat100g, b.fat100g, 'g', lowerIsBetter: true),
            _buildComparisonRow(
              'Dens. Proteica (g/100kcal)',
              a.calories100g > 0 ? (a.protein100g / a.calories100g) * 100 : 0,
              b.calories100g > 0 ? (b.protein100g / b.calories100g) * 100 : 0,
              'g/100kcal',
              lowerIsBetter: false,
              isHighlight: true,
            ),
            const SizedBox(height: 16),

            // Veredito IA
            GlassCard(
              borderColor: AppTheme.primaryColor.withOpacity(0.35),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: const [
                      Icon(Icons.auto_awesome, color: AppTheme.primaryColor, size: 18),
                      SizedBox(width: 8),
                      Text('Veredito da IA', style: TextStyle(color: AppTheme.primaryColor, fontWeight: FontWeight.bold, fontSize: 14)),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(_verdict(), style: const TextStyle(color: Colors.white, fontSize: 13, height: 1.5)),
                ],
              ),
            ),
            const SizedBox(height: 60),
          ] else ...[
            GlassCard(
              padding: const EdgeInsets.all(30),
              child: Column(
                children: const [
                  Icon(Icons.compare_rounded, color: Colors.grey, size: 40),
                  SizedBox(height: 10),
                  Text('Busque e selecione 2 alimentos para compará-los lado a lado.', textAlign: TextAlign.center, style: TextStyle(color: Colors.white70, fontSize: 13)),
                  SizedBox(height: 6),
                  Text('Ex: "Frango" vs "Atum" ou "Aveia" vs "Arroz"', textAlign: TextAlign.center, style: TextStyle(color: Colors.grey, fontSize: 11)),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildFoodSelector({
    required String label,
    required TextEditingController controller,
    required FoodItem? selected,
    required List<FoodItem> results,
    required bool isSearching,
    required bool isA,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(color: Colors.grey[300], fontWeight: FontWeight.bold, fontSize: 13)),
        const SizedBox(height: 6),

        if (selected != null) ...[
          // Chip do alimento selecionado
          GestureDetector(
            onTap: () {
              setState(() {
                if (isA) { _foodA = null; _resultsA = []; } else { _foodB = null; _resultsB = []; }
                controller.clear();
              });
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              decoration: BoxDecoration(
                color: isA ? Colors.cyanAccent.withOpacity(0.15) : Colors.pinkAccent.withOpacity(0.15),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: isA ? Colors.cyanAccent.withOpacity(0.5) : Colors.pinkAccent.withOpacity(0.5)),
              ),
              child: Row(
                children: [
                  Expanded(child: Text(selected.name, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12), maxLines: 2, overflow: TextOverflow.ellipsis)),
                  const Icon(Icons.close, color: Colors.white54, size: 14),
                ],
              ),
            ),
          ),
        ] else ...[
          TextField(
            controller: controller,
            style: const TextStyle(color: Colors.white, fontSize: 13),
            decoration: InputDecoration(
              hintText: 'Buscar alimento...',
              hintStyle: TextStyle(color: Colors.grey[500], fontSize: 12),
              filled: true,
              fillColor: AppTheme.darkBackground,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
              contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
              suffixIcon: isSearching ? const Padding(padding: EdgeInsets.all(10), child: SizedBox(width: 14, height: 14, child: CircularProgressIndicator(color: AppTheme.primaryColor, strokeWidth: 2))) : const Icon(Icons.search, color: Colors.grey, size: 18),
            ),
            onChanged: (q) => _search(q, isA),
          ),
          if (results.isNotEmpty) ...[
            const SizedBox(height: 4),
            Container(
              decoration: BoxDecoration(
                color: AppTheme.cardDarkBackground,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.white12),
              ),
              constraints: const BoxConstraints(maxHeight: 160),
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: results.length,
                itemBuilder: (_, i) {
                  final item = results[i];
                  return ListTile(
                    dense: true,
                    title: Text(item.name, style: const TextStyle(color: Colors.white, fontSize: 11)),
                    subtitle: Text('${item.calories100g.toInt()} kcal • ${item.protein100g.toStringAsFixed(1)}g prot', style: TextStyle(color: Colors.grey[400], fontSize: 10)),
                    onTap: () {
                      setState(() {
                        if (isA) { _foodA = item; _resultsA = []; } else { _foodB = item; _resultsB = []; }
                        controller.clear();
                      });
                    },
                  );
                },
              ),
            ),
          ],
        ],
      ],
    );
  }

  Widget _buildFoodHeader(FoodItem food, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(food.name, style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 12), maxLines: 2, overflow: TextOverflow.ellipsis),
          const SizedBox(height: 4),
          Text('por 100g', style: TextStyle(color: Colors.grey[400], fontSize: 10)),
        ],
      ),
    );
  }

  Widget _buildComparisonRow(String metric, double valA, double valB, String unit, {bool lowerIsBetter = false, bool isHighlight = false}) {
    final aWins = lowerIsBetter ? valA < valB : valA > valB;
    final bWins = lowerIsBetter ? valB < valA : valB > valA;

    return GlassCard(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(metric, style: TextStyle(color: isHighlight ? AppTheme.primaryColor : Colors.grey[400], fontSize: 11, fontWeight: isHighlight ? FontWeight.bold : FontWeight.normal)),
          const SizedBox(height: 6),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(children: [
                if (aWins) const Icon(Icons.star_rounded, color: Colors.amberAccent, size: 13),
                const SizedBox(width: 4),
                Text('${valA.toStringAsFixed(1)} $unit', style: TextStyle(color: aWins ? Colors.cyanAccent : Colors.white70, fontWeight: aWins ? FontWeight.bold : FontWeight.normal, fontSize: 15)),
              ]),
              Container(width: 1, height: 20, color: Colors.white12),
              Row(children: [
                Text('${valB.toStringAsFixed(1)} $unit', style: TextStyle(color: bWins ? Colors.pinkAccent : Colors.white70, fontWeight: bWins ? FontWeight.bold : FontWeight.normal, fontSize: 15)),
                const SizedBox(width: 4),
                if (bWins) const Icon(Icons.star_rounded, color: Colors.amberAccent, size: 13),
              ]),
            ],
          ),
        ],
      ),
    );
  }
}

