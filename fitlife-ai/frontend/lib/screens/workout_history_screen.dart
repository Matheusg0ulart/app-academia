// lib/screens/workout_history_screen.dart

import 'package:flutter/material.dart';
import '../core/theme/app_theme.dart';
import '../models/workout_log.dart';
import '../services/api_service.dart';
import '../widgets/glass_card.dart';

class WorkoutHistoryScreen extends StatefulWidget {
  const WorkoutHistoryScreen({super.key});

  @override
  State<WorkoutHistoryScreen> createState() => _WorkoutHistoryScreenState();
}

class _WorkoutHistoryScreenState extends State<WorkoutHistoryScreen> {
  final ApiService _api = ApiService();
  List<WorkoutLog> _logs = [];
  bool _isLoading = true;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      final logs = await _api.getWorkoutHistory();
      if (!mounted) return;
      setState(() {
        _logs = logs;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = 'Não foi possível carregar o histórico de treinos.';
        _isLoading = false;
      });
    }
  }

  String _formatDate(DateTime dt) {
    final day = dt.day.toString().padLeft(2, '0');
    final month = dt.month.toString().padLeft(2, '0');
    final year = dt.year;
    final hour = dt.hour.toString().padLeft(2, '0');
    final min = dt.minute.toString().padLeft(2, '0');
    return '$day/$month/$year às $hour:$min';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Histórico de Treinos'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadHistory,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: AppTheme.primaryColor))
          : _errorMessage.isNotEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.error_outline, color: Colors.redAccent, size: 48),
                      const SizedBox(height: 12),
                      Text(_errorMessage, style: const TextStyle(color: Colors.white70)),
                      const SizedBox(height: 12),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primaryColor, foregroundColor: Colors.black),
                        onPressed: _loadHistory,
                        child: const Text('Tentar Novamente'),
                      ),
                    ],
                  ),
                )
              : _logs.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.fitness_center, color: Colors.grey, size: 60),
                          const SizedBox(height: 16),
                          const Text('Nenhum treino concluído ainda', style: TextStyle(color: Colors.white70, fontSize: 16, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 8),
                          Text('Inicie uma ficha de treino para registrar seu progresso!', style: TextStyle(color: Colors.grey[500], fontSize: 12)),
                        ],
                      ),
                    )
                  : RefreshIndicator(
                      color: AppTheme.primaryColor,
                      onRefresh: _loadHistory,
                      child: ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        itemCount: _logs.length,
                        itemBuilder: (context, index) {
                          final log = _logs[index];
                          final totalSets = log.sets.length;
                          final totalVolume = log.sets.fold<double>(
                            0.0,
                            (sum, s) => sum + ((s.weightKg ?? 0) * (s.repsDone ?? 0)),
                          );

                          return GlassCard(
                            margin: const EdgeInsets.only(bottom: 14),
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Cabeçalho do Card
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      child: Text(
                                        log.workoutName ?? 'Treino Realizado',
                                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: AppTheme.primaryColor.withOpacity(0.15),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          const Icon(Icons.timer_outlined, color: AppTheme.primaryColor, size: 14),
                                          const SizedBox(width: 4),
                                          Text(
                                            '${log.durationMin ?? 45} min',
                                            style: const TextStyle(color: AppTheme.primaryColor, fontWeight: FontWeight.bold, fontSize: 12),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  _formatDate(log.startedAt),
                                  style: TextStyle(color: Colors.grey[400], fontSize: 12),
                                ),
                                const Divider(color: Colors.white10, height: 20),

                                // Estatísticas Rápidas
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                                  children: [
                                    _buildMetric('Séries Feitas', '$totalSets', Colors.white),
                                    _buildMetric('Volume Total', '${totalVolume.toInt()} kg', AppTheme.primaryColor),
                                    if (log.rating != null)
                                      _buildMetric('Avaliação (RPE)', '${log.rating}/10 ⭐', Colors.amberAccent)
                                    else
                                      _buildMetric('Status', 'Concluído ✅', Colors.greenAccent),
                                  ],
                                ),

                                // Lista resumida de séries
                                if (log.sets.isNotEmpty) ...[
                                  const SizedBox(height: 12),
                                  Container(
                                    padding: const EdgeInsets.all(10),
                                    decoration: BoxDecoration(
                                      color: AppTheme.darkBackground,
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        const Text('Séries Registradas:', style: TextStyle(color: Colors.white70, fontSize: 11, fontWeight: FontWeight.bold)),
                                        const SizedBox(height: 6),
                                        ...log.sets.take(5).map((s) {
                                          return Padding(
                                            padding: const EdgeInsets.symmetric(vertical: 2),
                                            child: Row(
                                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                              children: [
                                                Text('Série ${s.setNumber}: ${s.repsDone ?? 0} reps', style: TextStyle(color: Colors.grey[400], fontSize: 11)),
                                                Text('${(s.weightKg ?? 0).toStringAsFixed(1)} kg', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 11)),
                                              ],
                                            ),
                                          );
                                        }),
                                        if (log.sets.length > 5)
                                          Padding(
                                            padding: const EdgeInsets.only(top: 4),
                                            child: Text('+ ${log.sets.length - 5} outras séries...', style: TextStyle(color: Colors.grey[500], fontSize: 10)),
                                          ),
                                      ],
                                    ),
                                  ),
                                ],

                                if (log.notes != null && log.notes!.isNotEmpty) ...[
                                  const SizedBox(height: 8),
                                  Text(
                                    '📝 "${log.notes}"',
                                    style: TextStyle(color: Colors.grey[400], fontStyle: FontStyle.italic, fontSize: 11),
                                  ),
                                ],
                              ],
                            ),
                          );
                        },
                      ),
                    ),
    );
  }

  Widget _buildMetric(String label, String value, Color color) {
    return Column(
      children: [
        Text(label, style: TextStyle(color: Colors.grey[400], fontSize: 10)),
        const SizedBox(height: 2),
        Text(value, style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 13)),
      ],
    );
  }
}

