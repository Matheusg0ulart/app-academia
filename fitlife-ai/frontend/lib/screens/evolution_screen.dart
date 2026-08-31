// lib/screens/evolution_screen.dart

import 'package:flutter/material.dart';
import '../core/theme/app_theme.dart';
import '../models/measurement.dart';
import '../services/api_service.dart';
import '../widgets/glass_card.dart';
import '../widgets/evolution_line_chart.dart';
import '../widgets/measurement_bars_chart.dart';

class EvolutionScreen extends StatefulWidget {
  const EvolutionScreen({super.key});

  @override
  State<EvolutionScreen> createState() => _EvolutionScreenState();
}

class _EvolutionScreenState extends State<EvolutionScreen> with SingleTickerProviderStateMixin {
  final ApiService _api = ApiService();
  List<BodyMeasurement> _history = [];
  bool _isLoading = true;
  int _selectedTab = 0; // 0 = Peso (Gráfico), 1 = Medidas (Barras), 2 = Histórico

  @override
  void initState() {
    super.initState();
    _loadMeasurements();
  }

  Future<void> _loadMeasurements() async {
    setState(() => _isLoading = true);
    try {
      final history = await _api.getMeasurementHistory();
      if (!mounted) return;
      setState(() {
        _history = history;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
    }
  }

  Future<void> _showAddMeasurementDialog() async {
    final weightController = TextEditingController();
    final fatController = TextEditingController();
    final chestController = TextEditingController();
    final waistController = TextEditingController();
    final hipController = TextEditingController();
    final armController = TextEditingController();
    final thighController = TextEditingController();
    final notesController = TextEditingController();

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppTheme.cardDarkBackground,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) {
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
                const Text('Registrar Evolução Corporal', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: weightController,
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        decoration: InputDecoration(
                          labelText: 'Peso Atual (kg) *',
                          filled: true,
                          fillColor: AppTheme.darkBackground,
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: TextField(
                        controller: fatController,
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        decoration: InputDecoration(
                          labelText: '% Gordura Corporal',
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
                        controller: armController,
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        decoration: InputDecoration(
                          labelText: 'Braço (cm)',
                          filled: true,
                          fillColor: AppTheme.darkBackground,
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextField(
                        controller: chestController,
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        decoration: InputDecoration(
                          labelText: 'Peitoral (cm)',
                          filled: true,
                          fillColor: AppTheme.darkBackground,
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextField(
                        controller: waistController,
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        decoration: InputDecoration(
                          labelText: 'Cintura (cm)',
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
                        controller: hipController,
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        decoration: InputDecoration(
                          labelText: 'Quadril (cm)',
                          filled: true,
                          fillColor: AppTheme.darkBackground,
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextField(
                        controller: thighController,
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        decoration: InputDecoration(
                          labelText: 'Coxa (cm)',
                          filled: true,
                          fillColor: AppTheme.darkBackground,
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: notesController,
                  decoration: InputDecoration(
                    labelText: 'Observações (opcional)',
                    filled: true,
                    fillColor: AppTheme.darkBackground,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
                  ),
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
                    final weight = double.tryParse(weightController.text.replaceAll(',', '.'));
                    if (weight == null) return;
                    Navigator.pop(ctx);
                    try {
                      await _api.logMeasurement({
                        'weight_kg': weight,
                        'body_fat_pct': double.tryParse(fatController.text.replaceAll(',', '.')),
                        'arm_cm': double.tryParse(armController.text.replaceAll(',', '.')),
                        'chest_cm': double.tryParse(chestController.text.replaceAll(',', '.')),
                        'waist_cm': double.tryParse(waistController.text.replaceAll(',', '.')),
                        'hip_cm': double.tryParse(hipController.text.replaceAll(',', '.')),
                        'thigh_cm': double.tryParse(thighController.text.replaceAll(',', '.')),
                        'notes': notesController.text.trim(),
                      });
                      _loadMeasurements();
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Erro ao salvar medidas: $e')),
                      );
                    }
                  },
                  child: const Text('Salvar Medidas', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  List<ChartDataPoint> _getWeightPoints() {
    final reversed = _history.reversed.toList();
    final list = <ChartDataPoint>[];
    for (int i = 0; i < reversed.length; i++) {
      final m = reversed[i];
      if (m.weightKg != null) {
        final date = DateTime.tryParse(m.measuredAt) ?? DateTime.now().subtract(Duration(days: (reversed.length - i) * 7));
        list.add(ChartDataPoint(
          date: date,
          value: m.weightKg!,
          label: '${m.weightKg} kg',
        ));
      }
    }
    return list;
  }

  List<MeasurementComparison> _getMeasurementComparisons() {
    if (_history.length < 2) return [];
    final latest = _history.first;
    final oldest = _history.last;

    final comps = <MeasurementComparison>[];
    if (latest.armCm != null && oldest.armCm != null) {
      comps.add(MeasurementComparison(label: 'Braço', initialValue: oldest.armCm!, currentValue: latest.armCm!));
    }
    if (latest.chestCm != null && oldest.chestCm != null) {
      comps.add(MeasurementComparison(label: 'Peitoral / Tórax', initialValue: oldest.chestCm!, currentValue: latest.chestCm!));
    }
    if (latest.waistCm != null && oldest.waistCm != null) {
      comps.add(MeasurementComparison(label: 'Cintura', initialValue: oldest.waistCm!, currentValue: latest.waistCm!));
    }
    if (latest.hipCm != null && oldest.hipCm != null) {
      comps.add(MeasurementComparison(label: 'Quadril', initialValue: oldest.hipCm!, currentValue: latest.hipCm!));
    }
    if (latest.thighCm != null && oldest.thighCm != null) {
      comps.add(MeasurementComparison(label: 'Coxa', initialValue: oldest.thighCm!, currentValue: latest.thighCm!));
    }
    if (latest.bodyFatPct != null && oldest.bodyFatPct != null) {
      comps.add(MeasurementComparison(label: '% Gordura Corporal', initialValue: oldest.bodyFatPct!, currentValue: latest.bodyFatPct!, unit: '%'));
    }
    return comps;
  }

  @override
  Widget build(BuildContext context) {
    final latest = _history.isNotEmpty ? _history.first : null;
    final oldest = _history.length > 1 ? _history.last : null;
    final weightDiff = (latest?.weightKg != null && oldest?.weightKg != null)
        ? (latest!.weightKg! - oldest!.weightKg!)
        : null;

    final chartPoints = _getWeightPoints();
    final comparisons = _getMeasurementComparisons();

    return Scaffold(
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: AppTheme.primaryColor))
          : RefreshIndicator(
              color: AppTheme.primaryColor,
              onRefresh: _loadMeasurements,
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                children: [
                  // Card Destaque Peso Atual
                  GlassCard(
                    borderColor: AppTheme.primaryColor.withOpacity(0.3),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('PESO ATUAL REGISTRADO', style: TextStyle(color: Colors.grey, fontSize: 11, fontWeight: FontWeight.bold)),
                            const SizedBox(height: 4),
                            Text(
                              latest?.weightKg != null ? '${latest!.weightKg} kg' : '-- kg',
                              style: const TextStyle(fontSize: 30, fontWeight: FontWeight.extrabold, color: Colors.white),
                            ),
                            if (latest?.measuredAt != null)
                              Text('Última medição: ${latest!.measuredAt}', style: TextStyle(color: Colors.grey[400], fontSize: 11)),
                          ],
                        ),
                        if (weightDiff != null) ...[
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: AppTheme.darkBackground,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  weightDiff < 0 ? Icons.arrow_downward_rounded : Icons.arrow_upward_rounded,
                                  color: weightDiff < 0 ? Colors.greenAccent : Colors.orangeAccent,
                                  size: 16,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  '${weightDiff > 0 ? "+" : ""}${weightDiff.toStringAsFixed(1)} kg',
                                  style: TextStyle(
                                    color: weightDiff < 0 ? Colors.greenAccent : Colors.orangeAccent,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 13,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Segmented Tabs para Alternar Visualização
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: AppTheme.cardDarkBackground,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Row(
                      children: [
                        _buildTabButton(0, '⚖️ Gráfico de Peso'),
                        _buildTabButton(1, '📏 Medidas'),
                        _buildTabButton(2, '📋 Histórico'),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // ── ABA 0: GRÁFICO DE PESO ────────────────────
                  if (_selectedTab == 0) ...[
                    GlassCard(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: const [
                              Text(
                                'Curva de Evolução do Peso',
                                style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 15),
                              ),
                              Icon(Icons.show_chart_rounded, color: AppTheme.primaryColor, size: 20),
                            ],
                          ),
                          const SizedBox(height: 14),
                          EvolutionLineChart(
                            points: chartPoints,
                            unit: 'kg',
                            targetValue: 75.0, // Exemplo de meta de peso
                            height: 190,
                          ),
                        ],
                      ),
                    ),
                  ],

                  // ── ABA 1: COMPARAÇÃO DE MEDIDAS ─────────────
                  if (_selectedTab == 1) ...[
                    GlassCard(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: const [
                              Text(
                                'Comparativo de Circunferências',
                                style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 15),
                              ),
                              Icon(Icons.straighten_rounded, color: AppTheme.primaryColor, size: 20),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Text('Evolução do primeiro registro até a medição atual:', style: TextStyle(color: Colors.grey[400], fontSize: 11)),
                          const SizedBox(height: 16),
                          MeasurementBarsChart(items: comparisons),
                        ],
                      ),
                    ),
                  ],

                  // ── ABA 2: LISTA DE HISTÓRICO ─────────────────
                  if (_selectedTab == 2 || _history.isEmpty) ...[
                    if (_history.isEmpty) ...[
                      GlassCard(
                        padding: const EdgeInsets.all(30),
                        child: Column(
                          children: const [
                            Icon(Icons.monitor_weight_outlined, color: Colors.grey, size: 40),
                            SizedBox(height: 8),
                            Text('Nenhuma medição registrada ainda.', style: TextStyle(color: Colors.white70)),
                            SizedBox(height: 4),
                            Text('Registre seu peso e medidas corporais para acompanhar sua evolução.', textAlign: TextAlign.center, style: TextStyle(color: Colors.grey, fontSize: 12)),
                          ],
                        ),
                      ),
                    ] else ...[
                      ..._history.map((m) {
                        return GlassCard(
                          margin: const EdgeInsets.only(bottom: 12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    '📅 Data: ${m.measuredAt}',
                                    style: const TextStyle(color: AppTheme.primaryColor, fontWeight: FontWeight.bold, fontSize: 13),
                                  ),
                                  Text(
                                    '${m.weightKg ?? "--"} kg',
                                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                                  ),
                                ],
                              ),
                              const Divider(color: Colors.white10, height: 16),
                              Wrap(
                                spacing: 8,
                                runSpacing: 6,
                                children: [
                                  if (m.bodyFatPct != null) _buildMeasureChip('Gordura', '${m.bodyFatPct}%'),
                                  if (m.armCm != null) _buildMeasureChip('Braço', '${m.armCm} cm'),
                                  if (m.chestCm != null) _buildMeasureChip('Peitoral', '${m.chestCm} cm'),
                                  if (m.waistCm != null) _buildMeasureChip('Cintura', '${m.waistCm} cm'),
                                  if (m.hipCm != null) _buildMeasureChip('Quadril', '${m.hipCm} cm'),
                                  if (m.thighCm != null) _buildMeasureChip('Coxa', '${m.thighCm} cm'),
                                ],
                              ),
                              if (m.notes != null && m.notes!.isNotEmpty) ...[
                                const SizedBox(height: 8),
                                Text(
                                  'Nota: ${m.notes}',
                                  style: TextStyle(color: Colors.grey[400], fontSize: 11, fontStyle: FontStyle.italic),
                                ),
                              ],
                            ],
                          ),
                        );
                      }),
                    ],
                  ],

                  const SizedBox(height: 70),
                ],
              ),
            ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.black,
        icon: const Icon(Icons.add_rounded),
        label: const Text('Registrar Medidas', style: TextStyle(fontWeight: FontWeight.bold)),
        onPressed: _showAddMeasurementDialog,
      ),
    );
  }

  Widget _buildTabButton(int index, String label) {
    final isSelected = _selectedTab == index;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedTab = index),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: isSelected ? AppTheme.primaryColor : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: isSelected ? Colors.black : Colors.white70,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              fontSize: 11,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMeasureChip(String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppTheme.darkBackground,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        '$label: $value',
        style: const TextStyle(color: Colors.white70, fontSize: 11),
      ),
    );
  }
}
