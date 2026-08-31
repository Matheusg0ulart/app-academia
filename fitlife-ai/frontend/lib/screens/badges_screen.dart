// lib/screens/badges_screen.dart

import 'package:flutter/material.dart';
import '../core/theme/app_theme.dart';
import '../models/badge.dart';
import '../services/api_service.dart';
import '../widgets/glass_card.dart';

class BadgesScreen extends StatefulWidget {
  const BadgesScreen({super.key});

  @override
  State<BadgesScreen> createState() => _BadgesScreenState();
}

class _BadgesScreenState extends State<BadgesScreen> {
  final ApiService _api = ApiService();
  BadgesSummary? _summary;
  bool _isLoading = true;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _loadBadges();
  }

  Future<void> _loadBadges() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      final summary = await _api.getBadges();
      if (!mounted) return;
      setState(() {
        _summary = summary;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = 'Erro ao carregar conquistas.';
        _isLoading = false;
      });
    }
  }

  Color _getTierColor(String tier) {
    switch (tier) {
      case 'gold':
        return Colors.amberAccent;
      case 'silver':
        return Colors.grey[300]!;
      case 'bronze':
      default:
        return Colors.orangeAccent;
    }
  }

  IconData _getIconData(String iconName) {
    switch (iconName) {
      case 'fitness_center':
        return Icons.fitness_center_rounded;
      case 'local_fire_department':
        return Icons.local_fire_department_rounded;
      case 'emoji_events':
        return Icons.emoji_events_rounded;
      case 'monitor_weight':
        return Icons.monitor_weight_outlined;
      case 'restaurant':
        return Icons.restaurant_rounded;
      case 'military_tech':
        return Icons.military_tech_rounded;
      case 'water_drop':
        return Icons.water_drop_rounded;
      default:
        return Icons.stars_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    final s = _summary;
    final levelProgress = s != null && s.nextLevelXp > 0
        ? ((s.totalXp % 200) / 200.0).clamp(0.0, 1.0)
        : 0.0;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Conquistas & Nível'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadBadges,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: AppTheme.primaryColor))
          : _errorMessage.isNotEmpty
              ? Center(child: Text(_errorMessage, style: const TextStyle(color: Colors.redAccent)))
              : RefreshIndicator(
                  color: AppTheme.primaryColor,
                  onRefresh: _loadBadges,
                  child: ListView(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                    children: [
                      // Card de Nível & XP
                      GlassCard(
                        borderColor: AppTheme.primaryColor.withOpacity(0.4),
                        child: Column(
                          children: [
                            Row(
                              children: [
                                Container(
                                  width: 60,
                                  height: 60,
                                  decoration: BoxDecoration(
                                    gradient: const LinearGradient(
                                      colors: [AppTheme.primaryColor, AppTheme.primaryDark],
                                    ),
                                    shape: BoxShape.circle,
                                    boxShadow: [
                                      BoxShadow(
                                        color: AppTheme.primaryColor.withOpacity(0.4),
                                        blurRadius: 16,
                                      ),
                                    ],
                                  ),
                                  alignment: Alignment.center,
                                  child: Text(
                                    '${s?.userLevel ?? 1}',
                                    style: const TextStyle(fontSize: 26, fontWeight: FontWeight.extrabold, color: Colors.black),
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Nível ${s?.userLevel ?? 1} — Atleta FitLife',
                                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        '${s?.totalXp ?? 0} XP acumulados • ${s?.unlockedCount ?? 0}/${s?.totalCount ?? 0} medalhas',
                                        style: TextStyle(color: Colors.grey[400], fontSize: 12),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 14),

                            // Barra de XP até o próximo nível
                            ClipRRect(
                              borderRadius: BorderRadius.circular(6),
                              child: LinearProgressIndicator(
                                value: levelProgress,
                                backgroundColor: AppTheme.darkBackground,
                                valueColor: const AlwaysStoppedAnimation<Color>(AppTheme.primaryColor),
                                minHeight: 8,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Align(
                              alignment: Alignment.centerRight,
                              child: Text(
                                '${200 - (s?.totalXp ?? 0) % 200} XP para o Nível ${(s?.userLevel ?? 1) + 1}',
                                style: TextStyle(color: Colors.grey[400], fontSize: 11),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),

                      const Text(
                        'Medalhas & Troféus',
                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                      const SizedBox(height: 12),

                      // Lista de Badges
                      if (s != null)
                        ...s.badges.map((badge) {
                          final tierColor = _getTierColor(badge.tier);
                          return GlassCard(
                            margin: const EdgeInsets.only(bottom: 12),
                            padding: const EdgeInsets.all(14),
                            child: Row(
                              children: [
                                // Ícone da Medalha
                                Container(
                                  width: 48,
                                  height: 48,
                                  decoration: BoxDecoration(
                                    color: badge.isUnlocked ? tierColor.withOpacity(0.2) : AppTheme.darkBackground,
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: badge.isUnlocked ? tierColor : Colors.white12,
                                      width: 2,
                                    ),
                                  ),
                                  child: Icon(
                                    _getIconData(badge.icon),
                                    color: badge.isUnlocked ? tierColor : Colors.grey[600],
                                    size: 24,
                                  ),
                                ),
                                const SizedBox(width: 14),

                                // Informações
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            badge.title,
                                            style: TextStyle(
                                              color: badge.isUnlocked ? Colors.white : Colors.grey[400],
                                              fontWeight: FontWeight.bold,
                                              fontSize: 14,
                                            ),
                                          ),
                                          Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                            decoration: BoxDecoration(
                                              color: badge.isUnlocked ? AppTheme.primaryColor.withOpacity(0.15) : AppTheme.darkBackground,
                                              borderRadius: BorderRadius.circular(6),
                                            ),
                                            child: Text(
                                              '+${badge.xp} XP',
                                              style: TextStyle(
                                                color: badge.isUnlocked ? AppTheme.primaryColor : Colors.grey[500],
                                                fontWeight: FontWeight.bold,
                                                fontSize: 10,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 3),
                                      Text(
                                        badge.description,
                                        style: TextStyle(color: Colors.grey[400], fontSize: 11),
                                      ),
                                      const SizedBox(height: 6),

                                      // Barra de Progresso do Badge
                                      if (!badge.isUnlocked) ...[
                                        ClipRRect(
                                          borderRadius: BorderRadius.circular(4),
                                          child: LinearProgressIndicator(
                                            value: badge.progressPct / 100.0,
                                            backgroundColor: AppTheme.darkBackground,
                                            valueColor: AlwaysStoppedAnimation<Color>(tierColor),
                                            minHeight: 4,
                                          ),
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          'Progresso: ${badge.currentProgress}',
                                          style: TextStyle(color: Colors.grey[500], fontSize: 10),
                                        ),
                                      ] else ...[
                                        Row(
                                          children: const [
                                            Icon(Icons.check_circle_rounded, color: Colors.greenAccent, size: 12),
                                            SizedBox(width: 4),
                                            Text('Desbloqueado!', style: TextStyle(color: Colors.greenAccent, fontSize: 10, fontWeight: FontWeight.bold)),
                                          ],
                                        ),
                                      ],
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          );
                        }),
                    ],
                  ),
                ),
    );
  }
}

