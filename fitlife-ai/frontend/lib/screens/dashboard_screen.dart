import 'package:flutter/material.dart';
import '../core/theme/app_theme.dart';
import '../models/dashboard_summary.dart';
import '../services/api_service.dart';
import '../widgets/glass_card.dart';
import '../widgets/macro_ring_widget.dart';
import '../widgets/weekly_streak_widget.dart';
import '../widgets/hourly_water_tracker_widget.dart';
import '../widgets/ai_pulse_avatar.dart';

class DashboardScreen extends StatefulWidget {
  final Function(int) onTabChange;

  const DashboardScreen({super.key, required this.onTabChange});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final ApiService _api = ApiService();
  DashboardSummary? _summary;
  bool _isLoading = true;

  final List<String> _aiPrompts = [
    'Sugerir treino de hoje',
    'O que comer pós-treino?',
    'Analisar meu consumo',
    'Dicas para hipertrofia',
  ];

  @override
  void initState() {
    super.initState();
    _loadDashboardData();
  }

  Future<void> _loadDashboardData() async {
    setState(() => _isLoading = true);
    try {
      final summary = await _api.getDashboardSummary();
      if (!mounted) return;
      setState(() {
        _summary = summary;
        _isLoading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final s = _summary;

    if (_isLoading) {
      return const Center(child: CircularProgressIndicator(color: AppTheme.primaryColor));
    }

    return RefreshIndicator(
      color: AppTheme.primaryColor,
      onRefresh: _loadDashboardData,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Header Saudação & Badge ───────────────────────────────
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Olá, ${s?.userName ?? "Atleta"}! 👋',
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Visão geral da sua saúde hoje',
                      style: TextStyle(color: Colors.grey[400], fontSize: 13),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryColor.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: AppTheme.primaryColor.withOpacity(0.3)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.bolt_rounded, color: AppTheme.primaryColor, size: 18),
                      const SizedBox(width: 4),
                      Text(
                        '${s?.workoutsThisWeek ?? 0} treinos/sem',
                        style: const TextStyle(
                          color: AppTheme.primaryColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),

            // ── AI Pulse Insight Card ────────────────────────────────
            GlassCard(
              borderColor: AppTheme.primaryColor.withOpacity(0.3),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const AiPulseAvatar(size: 38),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: const [
                            Text(
                              'FitLife AI Insight',
                              style: TextStyle(color: AppTheme.primaryColor, fontWeight: FontWeight.bold, fontSize: 13),
                            ),
                            Text(
                              'Assistente inteligente ativo',
                              style: TextStyle(color: Colors.grey, fontSize: 11),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.arrow_forward_ios_rounded, color: AppTheme.primaryColor, size: 14),
                        onPressed: () => widget.onTabChange(4),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(
                    s?.aiInsight ?? 'Mantenha a consistência nos treinos e registros para atingir seu objetivo!',
                    style: const TextStyle(color: Colors.white, fontSize: 13, height: 1.4),
                  ),
                  const SizedBox(height: 12),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: _aiPrompts.map((prompt) {
                        return Padding(
                          padding: const EdgeInsets.only(right: 6),
                          child: ActionChip(
                            backgroundColor: AppTheme.darkBackground,
                            label: Text(
                              prompt,
                              style: const TextStyle(color: AppTheme.primaryColor, fontSize: 11),
                            ),
                            padding: const EdgeInsets.symmetric(horizontal: 4),
                            onPressed: () => widget.onTabChange(4),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),

            // ── Gráfico em Anel de Calorias e Macros ──────────────────
            GlassCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  MacroRingWidget(
                    consumedCalories: s?.consumedCalories ?? 0,
                    targetCalories: s?.targetCalories ?? 2200,
                    proteinG: s?.proteinG ?? 0,
                    targetProteinG: s?.targetProteinG ?? 140,
                    carbsG: s?.carbsG ?? 0,
                    targetCarbsG: s?.targetCarbsG ?? 250,
                    fatG: s?.fatG ?? 0,
                    targetFatG: s?.targetFatG ?? 65,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),

            // ── Calendário de Sequência da Semana ────────────────────
            WeeklyStreakWidget(
              completedWorkoutsThisWeek: s?.workoutsThisWeek ?? 0,
            ),
            const SizedBox(height: 18),

            // ── Rastreador Horário de Hidratação ────────────────────
            HourlyWaterTrackerWidget(
              targetWaterL: 3.0,
              currentWaterL: 1.5,
              onWaterChanged: (val) {},
            ),
            const SizedBox(height: 18),

            // ── Banner de Conquistas & Gamificação ───────────────────
            GestureDetector(
              onTap: () => Navigator.pushNamed(context, '/badges'),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.amberAccent.withOpacity(0.2),
                      Colors.orangeAccent.withOpacity(0.08),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.amberAccent.withOpacity(0.35)),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.amberAccent.withOpacity(0.2),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.emoji_events_rounded, color: Colors.amberAccent, size: 22),
                    ),
                    const SizedBox(width: 14),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Minhas Conquistas & Nível', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
                          SizedBox(height: 2),
                          Text('Desbloqueie medalhas e suba de nível no app', style: TextStyle(color: Colors.white70, fontSize: 11)),
                        ],
                      ),
                    ),
                    const Icon(Icons.arrow_forward_ios_rounded, color: Colors.amberAccent, size: 14),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 18),

            // ── Card de Treino do Dia ────────────────────────────────
            GlassCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: const [
                          Icon(Icons.fitness_center_rounded, color: AppTheme.primaryColor, size: 20),
                          SizedBox(width: 8),
                          Text('Treino do Dia', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Colors.white)),
                        ],
                      ),
                      GestureDetector(
                        onTap: () => widget.onTabChange(1),
                        child: const Text('Ver todas >', style: TextStyle(color: AppTheme.primaryColor, fontSize: 12, fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(
                    s?.nextWorkoutName ?? 'Treino A - Peito e Tríceps',
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${s?.nextWorkoutExerciseCount ?? 4} exercícios cadastrados nesta ficha',
                    style: TextStyle(color: Colors.grey[400], fontSize: 12),
                  ),
                  const SizedBox(height: 14),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primaryColor,
                        foregroundColor: Colors.black,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      icon: const Icon(Icons.play_arrow_rounded),
                      label: const Text('Iniciar Sessão de Treino', style: TextStyle(fontWeight: FontWeight.bold)),
                      onPressed: () => widget.onTabChange(1),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),

            // ── Ações Rápidas & Ferramentas ──────────────────────────
            Text('Ferramentas & Atalhos', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold, color: Colors.white)),
            const SizedBox(height: 10),
            Row(
              children: [
                _buildQuickActionTile('Scan Prato', Icons.camera_alt_rounded, () => Navigator.pushNamed(context, '/camera-scanner')),
                const SizedBox(width: 8),
                _buildQuickActionTile('Cronômetro', Icons.timer_outlined, () => Navigator.pushNamed(context, '/hiit-timer')),
                const SizedBox(width: 8),
                _buildQuickActionTile('Relatório', Icons.description_outlined, () => Navigator.pushNamed(context, '/evolution-report')),
                const SizedBox(width: 8),
                _buildQuickActionTile('Calculadoras', Icons.calculate_outlined, () => Navigator.pushNamed(context, '/calculators')),
                const SizedBox(width: 8),
                _buildQuickActionTile('FitLife AI', Icons.auto_awesome_rounded, () => widget.onTabChange(4)),
              ],
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActionTile(String label, IconData icon, VoidCallback onTap) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            color: AppTheme.cardDarkBackground,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.white.withOpacity(0.05)),
          ),
          child: Column(
            children: [
              Icon(icon, color: AppTheme.primaryColor, size: 20),
              const SizedBox(height: 6),
              Text(label, style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w600)),
            ],
          ),
        ),
      ),
    );
  }
}
