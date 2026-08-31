// lib/screens/weight_projection_screen.dart

import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../core/theme/app_theme.dart';
import '../services/api_service.dart';
import '../widgets/glass_card.dart';
import '../widgets/evolution_line_chart.dart';

class WeightProjectionScreen extends StatefulWidget {
  const WeightProjectionScreen({super.key});

  @override
  State<WeightProjectionScreen> createState() => _WeightProjectionScreenState();
}

class _WeightProjectionScreenState extends State<WeightProjectionScreen> {
  final ApiService _api = ApiService();

  double _currentWeight = 80.0;
  double _targetWeight = 74.0;
  int _dailyDeficit = 500; // kcal
  bool _isLoading = false;
  Map<String, dynamic>? _result;

  final List<Map<String, dynamic>> _deficitOptions = [
    {'label': 'Leve', 'kcal': 300, 'rate': '~0.27 kg/sem', 'color': Colors.greenAccent},
    {'label': 'Moderado', 'kcal': 500, 'rate': '~0.45 kg/sem', 'color': Colors.amberAccent},
    {'label': 'Agressivo', 'kcal': 750, 'rate': '~0.68 kg/sem', 'color': Colors.orangeAccent},
    {'label': 'Intenso', 'kcal': 1000, 'rate': '~0.91 kg/sem', 'color': Colors.redAccent},
  ];

  bool get _isGain => _targetWeight > _currentWeight;

  Future<void> _simulate() async {
    setState(() => _isLoading = true);
    try {
      final data = await _api.simulateWeightProjection(
        currentWeight: _currentWeight,
        targetWeight: _targetWeight,
        dailyDeficitKcal: _dailyDeficit,
      );
      if (!mounted) return;
      setState(() {
        _result = data['data'] as Map<String, dynamic>?;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Erro ao calcular projeção.'), backgroundColor: Colors.redAccent),
      );
    }
  }

  List<ChartDataPoint> _buildChartPoints(List<dynamic> projection) {
    final points = <ChartDataPoint>[];
    for (final p in projection) {
      final mp = p as Map<String, dynamic>;
      final dateStr = mp['date'] as String? ?? '';
      final date = DateTime.tryParse(dateStr) ?? DateTime.now();
      final weight = (mp['projectedWeightKg'] as num?)?.toDouble() ?? 0;
      points.add(ChartDataPoint(date: date, value: weight, label: '${weight.toStringAsFixed(1)} kg'));
    }
    return points;
  }

  @override
  Widget build(BuildContext context) {
    final res = _result;
    final isLoss = res != null ? (res['isWeightLoss'] as bool? ?? true) : _targetWeight < _currentWeight;

    return Scaffold(
      appBar: AppBar(title: const Text('Simulador de Projeção de Peso')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Entradas ───────────────────────────────────────────────
            GlassCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: const [
                      Icon(Icons.tune_rounded, color: AppTheme.primaryColor, size: 20),
                      SizedBox(width: 8),
                      Text('Configuração da Simulação', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15)),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Peso Atual
                  Text('Peso Atual: ${_currentWeight.toStringAsFixed(1)} kg', style: TextStyle(color: Colors.grey[300], fontSize: 13, fontWeight: FontWeight.w600)),
                  Slider(
                    value: _currentWeight,
                    min: 40,
                    max: 180,
                    divisions: 280,
                    activeColor: AppTheme.primaryColor,
                    inactiveColor: AppTheme.darkBackground,
                    onChanged: (v) => setState(() {
                      _currentWeight = (v * 10).roundToDouble() / 10;
                      _result = null;
                    }),
                  ),

                  // Peso Meta
                  Text(
                    'Peso Meta: ${_targetWeight.toStringAsFixed(1)} kg  ${_isGain ? "⬆️ Ganho" : "⬇️ Perda"}',
                    style: TextStyle(color: Colors.grey[300], fontSize: 13, fontWeight: FontWeight.w600),
                  ),
                  Slider(
                    value: _targetWeight,
                    min: 40,
                    max: 180,
                    divisions: 280,
                    activeColor: _isGain ? Colors.greenAccent : Colors.cyanAccent,
                    inactiveColor: AppTheme.darkBackground,
                    onChanged: (v) => setState(() {
                      _targetWeight = (v * 10).roundToDouble() / 10;
                      _result = null;
                    }),
                  ),

                  const SizedBox(height: 8),

                  // Seleção de Intensidade
                  Text('Ritmo de ${_isGain ? "Superávit" : "Déficit"}:', style: TextStyle(color: Colors.grey[300], fontSize: 13, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 10),
                  Row(
                    children: _deficitOptions.map((opt) {
                      final isSelected = _dailyDeficit == opt['kcal'];
                      return Expanded(
                        child: GestureDetector(
                          onTap: () => setState(() {
                            _dailyDeficit = opt['kcal'] as int;
                            _result = null;
                          }),
                          child: Container(
                            margin: const EdgeInsets.only(right: 6),
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            decoration: BoxDecoration(
                              color: isSelected ? (opt['color'] as Color).withOpacity(0.2) : AppTheme.darkBackground,
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: isSelected ? (opt['color'] as Color) : Colors.white12,
                                width: isSelected ? 1.5 : 1,
                              ),
                            ),
                            child: Column(
                              children: [
                                Text(opt['label'] as String, style: TextStyle(color: isSelected ? opt['color'] as Color : Colors.white70, fontWeight: FontWeight.bold, fontSize: 12)),
                                const SizedBox(height: 2),
                                Text('${opt['kcal']} kcal', style: TextStyle(color: isSelected ? opt['color'] as Color : Colors.grey, fontSize: 10)),
                                Text(opt['rate'] as String, style: TextStyle(color: Colors.grey[400], fontSize: 9)),
                              ],
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),

                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primaryColor,
                        foregroundColor: Colors.black,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      icon: _isLoading
                          ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(color: Colors.black, strokeWidth: 2))
                          : const Icon(Icons.calculate_rounded),
                      label: Text(_isLoading ? 'Calculando...' : 'Simular Projeção', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                      onPressed: _isLoading ? null : _simulate,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // ── Resultados ─────────────────────────────────────────────
            if (res != null) ...[
              // Cards de Resumo
              Row(
                children: [
                  _buildResultCard(
                    icon: Icons.calendar_today_rounded,
                    label: 'Semanas Estimadas',
                    value: '${res['totalWeeks']} sem',
                    color: AppTheme.primaryColor,
                  ),
                  const SizedBox(width: 10),
                  _buildResultCard(
                    icon: Icons.flag_rounded,
                    label: 'Data Prevista',
                    value: (res['targetDate'] as String? ?? '---').replaceAllMapped(
                      RegExp(r'(\d{4})-(\d{2})-(\d{2})'),
                      (m) => '${m[3]}/${m[2]}/${m[1]}',
                    ),
                    color: isLoss ? Colors.cyanAccent : Colors.greenAccent,
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  _buildResultCard(
                    icon: Icons.local_fire_department_rounded,
                    label: 'Meta Calórica Diária',
                    value: '${res['recommendedIntakeKcal']} kcal',
                    color: Colors.orangeAccent,
                  ),
                  const SizedBox(width: 10),
                  _buildResultCard(
                    icon: Icons.speed_rounded,
                    label: 'Ritmo Semanal',
                    value: '${res['weeklyRateKg']} kg/sem',
                    color: Colors.amberAccent,
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Gráfico de Projeção
              GlassCard(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.show_chart_rounded, color: AppTheme.primaryColor, size: 20),
                        const SizedBox(width: 8),
                        Text(
                          isLoss ? 'Curva de Perda de Peso' : 'Curva de Ganho de Massa',
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    EvolutionLineChart(
                      points: _buildChartPoints(res['projection'] as List<dynamic>? ?? []),
                      unit: 'kg',
                      targetValue: _targetWeight,
                      height: 200,
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(width: 16, height: 2, color: AppTheme.primaryColor),
                        const SizedBox(width: 4),
                        const Text('Projeção', style: TextStyle(color: Colors.white70, fontSize: 10)),
                        const SizedBox(width: 12),
                        Container(width: 16, height: 2, color: Colors.white30,
                          child: const Row(children: [
                            SizedBox(width: 4),
                            SizedBox(width: 4, height: 2, child: ColoredBox(color: Colors.white30)),
                          ]),
                        ),
                        const SizedBox(width: 4),
                        const Text('Meta', style: TextStyle(color: Colors.white70, fontSize: 10)),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Dicas
              const Text('💡 Dicas para Alcançar sua Meta', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15)),
              const SizedBox(height: 10),
              ...((res['tips'] as List<dynamic>? ?? []).map((tip) {
                return Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppTheme.cardDarkBackground,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.white10),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(Icons.check_circle_rounded, color: AppTheme.primaryColor, size: 16),
                      const SizedBox(width: 8),
                      Expanded(child: Text(tip.toString(), style: TextStyle(color: Colors.grey[300], fontSize: 12))),
                    ],
                  ),
                );
              })),
              const SizedBox(height: 60),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildResultCard({required IconData icon, required String label, required String value, required Color color}) {
    return Expanded(
      child: GlassCard(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color, size: 18),
            const SizedBox(height: 6),
            Text(label, style: TextStyle(color: Colors.grey[400], fontSize: 10)),
            const SizedBox(height: 2),
            Text(value, style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 16)),
          ],
        ),
      ),
    );
  }
}

