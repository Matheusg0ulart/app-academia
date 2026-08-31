// lib/screens/evolution_report_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../core/theme/app_theme.dart';
import '../services/api_service.dart';
import '../widgets/glass_card.dart';

class EvolutionReportScreen extends StatefulWidget {
  const EvolutionReportScreen({super.key});

  @override
  State<EvolutionReportScreen> createState() => _EvolutionReportScreenState();
}

class _EvolutionReportScreenState extends State<EvolutionReportScreen> {
  final ApiService _api = ApiService();
  Map<String, dynamic>? _report;
  bool _isLoading = true;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _loadReport();
  }

  Future<void> _loadReport() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      final data = await _api.getExportReport();
      if (!mounted) return;
      setState(() {
        _report = data['report'] as Map<String, dynamic>?;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = 'Erro ao gerar relatório de evolução.';
        _isLoading = false;
      });
    }
  }

  void _copyToClipboard(String text) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('📋 Relatório copiado para a área de transferência!'),
        backgroundColor: AppTheme.primaryDark,
        duration: Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final rep = _report;
    final user = rep?['user'] as Map<String, dynamic>?;
    final meta = rep?['metabolism'] as Map<String, dynamic>?;
    final workouts = rep?['workoutsSummary'] as Map<String, dynamic>?;
    final evol = rep?['evolution'] as Map<String, dynamic>?;
    final formattedText = rep?['formattedText'] as String? ?? '';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Relatório de Evolução'),
        actions: [
          if (formattedText.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.copy_rounded, color: AppTheme.primaryColor),
              tooltip: 'Copiar Relatório',
              onPressed: () => _copyToClipboard(formattedText),
            ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: AppTheme.primaryColor))
          : _errorMessage.isNotEmpty
              ? Center(child: Text(_errorMessage, style: const TextStyle(color: Colors.redAccent)))
              : RefreshIndicator(
                  color: AppTheme.primaryColor,
                  onRefresh: _loadReport,
                  child: ListView(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                    children: [
                      // Cabeçalho do Aluno
                      GlassCard(
                        borderColor: AppTheme.primaryColor.withOpacity(0.35),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: AppTheme.primaryColor.withOpacity(0.2),
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(Icons.person_rounded, color: AppTheme.primaryColor, size: 28),
                                ),
                                const SizedBox(width: 14),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        user?['name'] ?? 'Aluno FitLife',
                                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        'Meta: ${user?['goal'] ?? 'Hipertrofia e Saúde'}',
                                        style: const TextStyle(color: AppTheme.primaryColor, fontWeight: FontWeight.w600, fontSize: 12),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const Divider(color: Colors.white10, height: 20),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                _buildMetric('Peso Atual', '${user?['weight_kg'] ?? 75} kg', Colors.white),
                                _buildMetric('Altura', '${user?['height_cm'] ?? 175} cm', Colors.white),
                                _buildMetric('Idade', '${user?['age'] ?? 25} anos', Colors.white),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),

                      // 1. Antropometria & Metabolismo
                      const Text('1. Metabolismo & Taxa Calórica', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15)),
                      const SizedBox(height: 10),
                      GlassCard(
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                _buildMetric('IMC', '${meta?['bmi'] ?? 24.5}', Colors.cyanAccent),
                                _buildMetric('Taxa Basal (TMB)', '${meta?['bmr'] ?? 1750} kcal', Colors.orangeAccent),
                                _buildMetric('Gasto Total (TDEE)', '${meta?['tdee'] ?? 2400} kcal', AppTheme.primaryColor),
                              ],
                            ),
                            const SizedBox(height: 10),
                            Text('Classificação: ${meta?['bmiClassification'] ?? "Peso Normal"}', style: TextStyle(color: Colors.grey[400], fontSize: 11)),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),

                      // 2. Treinos & Volume Acumulado
                      const Text('2. Histórico de Treino & Cargas', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15)),
                      const SizedBox(height: 10),
                      GlassCard(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            _buildMetric('Sessões Feitas', '${workouts?['totalWorkouts'] ?? 0} treinos', Colors.white),
                            _buildMetric('Tempo Total', '${workouts?['totalMinutes'] ?? 0} min', Colors.amberAccent),
                            _buildMetric('Volume Levantado', '${workouts?['totalVolumeKg'] ?? 0} kg', AppTheme.primaryColor),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),

                      // 3. Variação de Peso
                      const Text('3. Variação de Peso Corporal', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15)),
                      const SizedBox(height: 10),
                      GlassCard(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            _buildMetric('Primeiro Peso', '${evol?['firstWeight'] ?? "--"} kg', Colors.grey[400]!),
                            _buildMetric('Peso Atual', '${evol?['currentWeight'] ?? "--"} kg', Colors.white),
                            _buildMetric(
                              'Variação',
                              '${(evol?['weightDelta'] ?? 0) >= 0 ? "+" : ""}${evol?['weightDelta'] ?? 0} kg',
                              (evol?['weightDelta'] ?? 0) <= 0 ? Colors.greenAccent : Colors.orangeAccent,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Botão de Copiar / Compartilhar
                      ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.primaryColor,
                          foregroundColor: Colors.black,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        ),
                        icon: const Icon(Icons.share_rounded),
                        label: const Text('Copiar Relatório Formatado (WhatsApp / PDF)', style: TextStyle(fontWeight: FontWeight.bold)),
                        onPressed: () => _copyToClipboard(formattedText),
                      ),
                      const SizedBox(height: 60),
                    ],
                  ),
                ),
    );
  }

  Widget _buildMetric(String label, String value, Color color) {
    return Column(
      children: [
        Text(label, style: TextStyle(color: Colors.grey[400], fontSize: 11)),
        const SizedBox(height: 3),
        Text(value, style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 14)),
      ],
    );
  }
}

