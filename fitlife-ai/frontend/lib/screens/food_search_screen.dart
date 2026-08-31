// lib/screens/food_search_screen.dart
//
// Modal / Tela de busca inteligente de alimentos:
//   - Busca em tempo real com debounce de 500ms
//   - Abas: Todos | Naturais (TACO) | Industrializados
//   - Calculadora de porção em gramas com cálculo proporcional de macros
//   - Seleção de tipo de refeição antes de registrar

import 'dart:async';
import 'package:flutter/material.dart';
import '../core/theme/app_theme.dart';
import '../models/food_item.dart';
import '../models/nutrition.dart';
import '../services/api_service.dart';
import '../widgets/glass_card.dart';

class FoodSearchScreen extends StatefulWidget {
  /// Tipo de refeição pré-selecionado (ex: 'lunch', 'breakfast')
  final String? initialMealType;
  /// Callback chamado após adicionar a refeição com sucesso
  final VoidCallback? onMealAdded;

  const FoodSearchScreen({super.key, this.initialMealType, this.onMealAdded});

  @override
  State<FoodSearchScreen> createState() => _FoodSearchScreenState();
}

class _FoodSearchScreenState extends State<FoodSearchScreen> with SingleTickerProviderStateMixin {
  final ApiService _api = ApiService();
  final TextEditingController _searchController = TextEditingController();
  late TabController _tabController;

  Timer? _debounce;
  bool _isLoading = false;
  String _errorMessage = '';

  List<FoodItem> _naturalResults = [];
  List<FoodItem> _industrializedResults = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  void _onSearchChanged(String value) {
    _debounce?.cancel();
    if (value.trim().length < 2) {
      setState(() {
        _naturalResults = [];
        _industrializedResults = [];
        _errorMessage = '';
      });
      return;
    }

    _debounce = Timer(const Duration(milliseconds: 500), () => _doSearch(value.trim()));
  }

  Future<void> _doSearch(String query) async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      final results = await _api.searchFoods(query);
      if (!mounted) return;
      setState(() {
        _naturalResults = results['natural'] ?? [];
        _industrializedResults = results['industrialized'] ?? [];
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = 'Erro ao buscar alimentos. Verifique a conexão.';
        _isLoading = false;
      });
    }
  }

  void _showPortionCalculator(FoodItem food) {
    double portionGrams = 100;
    String mealType = widget.initialMealType ?? 'lunch';
    FoodItem calculated = food.forPortion(portionGrams);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppTheme.cardDarkBackground,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            calculated = food.forPortion(portionGrams);

            return Padding(
              padding: EdgeInsets.only(
                left: 20,
                right: 20,
                top: 20,
                bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Nome e Badge
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: food.isNatural ? Colors.greenAccent.withOpacity(0.18) : Colors.orangeAccent.withOpacity(0.18),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          food.isNatural ? '🌿 Natural' : '🏭 Industrializado',
                          style: TextStyle(
                            color: food.isNatural ? Colors.greenAccent : Colors.orangeAccent,
                            fontWeight: FontWeight.bold,
                            fontSize: 11,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      if (food.source.isNotEmpty)
                        Text(food.source, style: TextStyle(color: Colors.grey[500], fontSize: 10)),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(food.name, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
                  if (food.brand.isNotEmpty && food.brand != 'TACO' && food.brand != 'Genérico')
                    Text(food.brand, style: TextStyle(color: Colors.grey[400], fontSize: 12)),
                  const SizedBox(height: 20),

                  // Calculadora de Porção
                  Row(
                    children: [
                      const Text('Porção (g):', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
                      const Spacer(),
                      GestureDetector(
                        onTap: () => setModalState(() => portionGrams = (portionGrams - 25).clamp(25, 2000)),
                        child: Container(
                          width: 32, height: 32,
                          decoration: BoxDecoration(color: AppTheme.darkBackground, shape: BoxShape.circle),
                          child: const Icon(Icons.remove, color: Colors.white, size: 16),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        '${portionGrams.toInt()} g',
                        style: const TextStyle(color: AppTheme.primaryColor, fontWeight: FontWeight.extrabold, fontSize: 20),
                      ),
                      const SizedBox(width: 12),
                      GestureDetector(
                        onTap: () => setModalState(() => portionGrams = (portionGrams + 25).clamp(25, 2000)),
                        child: Container(
                          width: 32, height: 32,
                          decoration: BoxDecoration(color: AppTheme.darkBackground, shape: BoxShape.circle),
                          child: const Icon(Icons.add, color: Colors.white, size: 16),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  // Presets de porção rápida
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [50, 100, 150, 200, 250, 300, 500].map((g) {
                        final isSelected = portionGrams.toInt() == g;
                        return Padding(
                          padding: const EdgeInsets.only(right: 6),
                          child: ChoiceChip(
                            label: Text('${g}g'),
                            selected: isSelected,
                            selectedColor: AppTheme.primaryColor,
                            backgroundColor: AppTheme.darkBackground,
                            labelStyle: TextStyle(
                              color: isSelected ? Colors.black : Colors.white70,
                              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                              fontSize: 12,
                            ),
                            onSelected: (_) => setModalState(() => portionGrams = g.toDouble()),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Card de Macros calculados
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: AppTheme.darkBackground,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildMacroColumn('Calorias', '${calculated.kcal.toInt()} kcal', Colors.white),
                        _buildMacroColumn('Proteína', '${calculated.protein.toStringAsFixed(1)}g', Colors.blueAccent),
                        _buildMacroColumn('Carb', '${calculated.carbs.toStringAsFixed(1)}g', Colors.orangeAccent),
                        _buildMacroColumn('Gordura', '${calculated.fat.toStringAsFixed(1)}g', Colors.pinkAccent),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Tipo de Refeição
                  DropdownButtonFormField<String>(
                    value: mealType,
                    decoration: InputDecoration(
                      labelText: 'Adicionar em qual refeição?',
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
                    onChanged: (val) => setModalState(() => mealType = val ?? 'lunch'),
                  ),
                  const SizedBox(height: 20),

                  // Botão Adicionar
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryColor,
                      foregroundColor: Colors.black,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    icon: const Icon(Icons.add_circle_rounded),
                    label: Text(
                      'Adicionar ${portionGrams.toInt()}g de ${food.name.split(' ').take(3).join(' ')} (${calculated.kcal.toInt()} kcal)',
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    onPressed: () async {
                      Navigator.pop(ctx);
                      try {
                        await _api.logMeal({
                          'meal_type': mealType,
                          'description': '${food.name} (${portionGrams.toInt()}g)',
                          'calories_kcal': calculated.kcal,
                          'protein_g': calculated.protein,
                          'carbs_g': calculated.carbs,
                          'fat_g': calculated.fat,
                        });

                        if (!mounted) return;
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('${food.name} adicionado ao ${mealTypeLabel(mealType)}!'),
                            backgroundColor: AppTheme.primaryDark,
                            duration: const Duration(seconds: 2),
                          ),
                        );
                        widget.onMealAdded?.call();
                        Navigator.of(context).pop();
                      } catch (e) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Erro ao registrar refeição.')),
                        );
                      }
                    },
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildMacroColumn(String label, String value, Color color) {
    return Column(
      children: [
        Text(label, style: TextStyle(color: Colors.grey[400], fontSize: 10)),
        const SizedBox(height: 3),
        Text(value, style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 13)),
      ],
    );
  }

  Future<void> _searchByBarcode(String barcode) async {
    if (barcode.trim().isEmpty) return;
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      final food = await _api.getFoodByBarcode(barcode.trim());
      if (!mounted) return;
      setState(() => _isLoading = false);

      if (food != null) {
        _showPortionCalculator(food);
      } else {
        setState(() => _errorMessage = 'Nenhum produto encontrado com o código de barras informado.');
      }
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _errorMessage = 'Erro ao buscar código de barras.';
      });
    }
  }

  void _showBarcodeDialog() {
    final barcodeController = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.cardDarkBackground,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: const [
            Icon(Icons.qr_code_scanner_rounded, color: AppTheme.primaryColor),
            SizedBox(width: 8),
            Text('Código de Barras (EAN)', style: TextStyle(color: Colors.white, fontSize: 16)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Digite os números do código de barras da embalagem do produto:',
              style: TextStyle(color: Colors.white70, fontSize: 12),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: barcodeController,
              keyboardType: TextInputType.number,
              autofocus: true,
              decoration: InputDecoration(
                hintText: 'Ex: 7891000100103',
                filled: true,
                fillColor: AppTheme.darkBackground,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancelar', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryColor,
              foregroundColor: Colors.black,
            ),
            onPressed: () {
              Navigator.pop(ctx);
              _searchByBarcode(barcodeController.text);
            },
            child: const Text('Buscar Produto'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final allResults = [..._naturalResults, ..._industrializedResults];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Buscar Alimento'),
        actions: [
          IconButton(
            icon: const Icon(Icons.qr_code_scanner_rounded, color: AppTheme.primaryColor),
            tooltip: 'Buscar por Código de Barras (EAN)',
            onPressed: _showBarcodeDialog,
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppTheme.primaryColor,
          labelColor: AppTheme.primaryColor,
          unselectedLabelColor: Colors.grey,
          tabs: [
            Tab(text: 'Todos (${allResults.length})'),
            Tab(text: '🌿 Naturais (${_naturalResults.length})'),
            Tab(text: '🏭 Marcas (${_industrializedResults.length})'),
          ],
        ),
      ),
      body: Column(
        children: [
          // Campo de Busca com debounce
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: TextField(
              controller: _searchController,
              autofocus: true,
              decoration: InputDecoration(
                hintText: 'Ex: frango, arroz, activia, whey, ovo...',
                prefixIcon: const Icon(Icons.search, color: AppTheme.primaryColor),
                suffixIcon: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (_searchController.text.isNotEmpty)
                      IconButton(
                        icon: const Icon(Icons.clear, color: Colors.grey),
                        onPressed: () {
                          _searchController.clear();
                          setState(() {
                            _naturalResults = [];
                            _industrializedResults = [];
                          });
                        },
                      ),
                    IconButton(
                      icon: const Icon(Icons.qr_code_scanner_rounded, color: AppTheme.primaryColor, size: 20),
                      tooltip: 'Código de Barras',
                      onPressed: _showBarcodeDialog,
                    ),
                  ],
                ),
                filled: true,
                fillColor: AppTheme.cardDarkBackground,
                contentPadding: const EdgeInsets.symmetric(vertical: 14),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
              ),
              onChanged: _onSearchChanged,
            ),
          ),

          // Indicador de carregamento ou dica inicial
          if (_isLoading)
            const LinearProgressIndicator(color: AppTheme.primaryColor, backgroundColor: Colors.transparent)
          else if (_errorMessage.isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              child: Text(_errorMessage, style: const TextStyle(color: Colors.redAccent, fontSize: 12)),
            ),

          // Dica inicial quando não há busca
          if (allResults.isEmpty && !_isLoading && _searchController.text.isEmpty)
            Expanded(
              child: Center(
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.restaurant_menu_rounded, size: 60, color: Colors.grey),
                      const SizedBox(height: 12),
                      const Text('Busque qualquer alimento', style: TextStyle(color: Colors.white70, fontWeight: FontWeight.bold, fontSize: 16)),
                      const SizedBox(height: 6),
                      Text(
                        'Alimentos naturais TACO + milhões de\nprodutos industrializados do Open Food Facts',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.grey[500], fontSize: 12),
                      ),
                      const SizedBox(height: 20),
                      OutlinedButton.icon(
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppTheme.primaryColor,
                          side: const BorderSide(color: AppTheme.primaryColor),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        icon: const Icon(Icons.qr_code_scanner_rounded, size: 18),
                        label: const Text('Digitar Código de Barras (EAN)'),
                        onPressed: _showBarcodeDialog,
                      ),
                    ],
                  ),
                ),
              ),
            )
          else if (allResults.isEmpty && !_isLoading && _searchController.text.length >= 2)
            Expanded(
              child: Center(
                child: Text('Nenhum resultado para "${_searchController.text}"', style: const TextStyle(color: Colors.grey)),
              ),
            )
          else
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildFoodList(allResults),
                  _buildFoodList(_naturalResults),
                  _buildFoodList(_industrializedResults),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildFoodList(List<FoodItem> items) {
    if (items.isEmpty) {
      return const Center(child: Text('Nenhum resultado nesta categoria.', style: TextStyle(color: Colors.grey)));
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final food = items[index];
        return GlassCard(
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.all(12),
          onTap: () => _showPortionCalculator(food),
          child: Row(
            children: [
              // Ícone e Badge de tipo
              Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: food.isNatural ? Colors.greenAccent.withOpacity(0.12) : Colors.orangeAccent.withOpacity(0.12),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      food.isNatural ? Icons.eco_rounded : Icons.inventory_2_rounded,
                      color: food.isNatural ? Colors.greenAccent : Colors.orangeAccent,
                      size: 20,
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 12),

              // Nome, Marca e Macros
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      food.name,
                      style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 13),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (food.brand.isNotEmpty && food.brand != 'TACO' && food.brand != 'Genérico')
                      Text(food.brand, style: TextStyle(color: Colors.grey[400], fontSize: 11)),
                    const SizedBox(height: 4),
                    Wrap(
                      spacing: 8,
                      children: [
                        Text('${food.kcal.toInt()} kcal', style: const TextStyle(color: AppTheme.primaryColor, fontWeight: FontWeight.bold, fontSize: 12)),
                        Text('P: ${food.protein.toStringAsFixed(1)}g', style: const TextStyle(color: Colors.blueAccent, fontSize: 11)),
                        Text('C: ${food.carbs.toStringAsFixed(1)}g', style: const TextStyle(color: Colors.orangeAccent, fontSize: 11)),
                        Text('G: ${food.fat.toStringAsFixed(1)}g', style: const TextStyle(color: Colors.pinkAccent, fontSize: 11)),
                      ],
                    ),
                    Text('por 100g • ${food.source}', style: TextStyle(color: Colors.grey[500], fontSize: 10)),
                  ],
                ),
              ),

              // Botão Adicionar
              Icon(Icons.add_circle_rounded, color: AppTheme.primaryColor, size: 24),
            ],
          ),
        );
      },
    );
  }
}
