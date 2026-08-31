// lib/screens/workout_generator_dialog.dart

import 'package:flutter/material.dart';
import '../core/theme/app_theme.dart';
import '../services/api_service.dart';
import '../widgets/ai_pulse_avatar.dart';

class WorkoutGeneratorDialog extends StatefulWidget {
  final VoidCallback onWorkoutsGenerated;

  const WorkoutGeneratorDialog({super.key, required this.onWorkoutsGenerated});

  @override
  State<WorkoutGeneratorDialog> createState() => _WorkoutGeneratorDialogState();
}

class _WorkoutGeneratorDialogState extends State<WorkoutGeneratorDialog> {
  final ApiService _api = ApiService();

  String _selectedGoal = 'hypertrophy';
  String _selectedLevel = 'intermediate';
  String _selectedSplit = 'ppl';

  bool _isGenerating = false;
  String _errorMessage = '';

  final Map<String, String> _goals = {
    'hypertrophy': 'Hipertrofia (Ganho de Massa)',
    'fat_loss': 'Definição & Emagrecimento',
    'strength': 'Força Bruta',
    'conditioning': 'Condicionamento Geral',
  };

  final Map<String, String> _levels = {
    'beginner': 'Iniciante (< 6 meses)',
    'intermediate': 'Intermediário (6m a 2 anos)',
    'advanced': 'Avançado (+ 2 anos)',
  };

  final Map<String, String> _splits = {
    'ppl': 'Push / Pull / Legs (3 a 6 dias) — ABC',
    'upper_lower': 'Upper / Lower (4 dias) — AB',
    'full_body': 'Full Body (2 a 3 dias) — Corpo Todo',
  };

  Future<void> _generate() async {
    setState(() {
      _isGenerating = true;
      _errorMessage = '';
    });

    try {
      final workouts = await _api.generateSmartWorkout(
        goal: _selectedGoal,
        level: _selectedLevel,
        split: _selectedSplit,
      );

      if (!mounted) return;
      Navigator.of(context).pop();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('⚡ ${workouts.length} ficha(s) de treino criada(s) com IA com sucesso!'),
          backgroundColor: AppTheme.primaryDark,
          duration: const Duration(seconds: 3),
        ),
      );

      widget.onWorkoutsGenerated();
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isGenerating = false;
        _errorMessage = 'Erro ao gerar treino com IA. Tente novamente.';
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
              // Cabeçalho com Avatar AI
              Row(
                children: [
                  const AiPulseAvatar(size: 38, glowColor: AppTheme.primaryColor),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Gerador de Treino AI', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                        Text('Montagem personalizada por algoritmo inteligente', style: TextStyle(color: Colors.grey, fontSize: 11)),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              const Divider(color: Colors.white10),

              // Objetivo
              const SizedBox(height: 8),
              const Text('1. Qual é o seu Objetivo?', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
              const SizedBox(height: 6),
              ..._goals.entries.map((entry) {
                final isSelected = _selectedGoal == entry.key;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(10),
                    onTap: () => setState(() => _selectedGoal = entry.key),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: isSelected ? AppTheme.primaryColor.withOpacity(0.15) : AppTheme.darkBackground,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: isSelected ? AppTheme.primaryColor : Colors.transparent),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            isSelected ? Icons.radio_button_checked : Icons.radio_button_off,
                            color: isSelected ? AppTheme.primaryColor : Colors.grey,
                            size: 18,
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              entry.value,
                              style: TextStyle(
                                color: isSelected ? Colors.white : Colors.white70,
                                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }),

              // Nível de Experiência
              const SizedBox(height: 12),
              const Text('2. Nível de Experiência', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
              const SizedBox(height: 6),
              ..._levels.entries.map((entry) {
                final isSelected = _selectedLevel == entry.key;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(10),
                    onTap: () => setState(() => _selectedLevel = entry.key),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: isSelected ? AppTheme.primaryColor.withOpacity(0.15) : AppTheme.darkBackground,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: isSelected ? AppTheme.primaryColor : Colors.transparent),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            isSelected ? Icons.radio_button_checked : Icons.radio_button_off,
                            color: isSelected ? AppTheme.primaryColor : Colors.grey,
                            size: 18,
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              entry.value,
                              style: TextStyle(
                                color: isSelected ? Colors.white : Colors.white70,
                                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }),

              // Divisão de Treino
              const SizedBox(height: 12),
              const Text('3. Divisão de Treino (Split)', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
              const SizedBox(height: 6),
              ..._splits.entries.map((entry) {
                final isSelected = _selectedSplit == entry.key;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(10),
                    onTap: () => setState(() => _selectedSplit = entry.key),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: isSelected ? AppTheme.primaryColor.withOpacity(0.15) : AppTheme.darkBackground,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: isSelected ? AppTheme.primaryColor : Colors.transparent),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            isSelected ? Icons.radio_button_checked : Icons.radio_button_off,
                            color: isSelected ? AppTheme.primaryColor : Colors.grey,
                            size: 18,
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              entry.value,
                              style: TextStyle(
                                color: isSelected ? Colors.white : Colors.white70,
                                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }),

              if (_errorMessage.isNotEmpty) ...[
                const SizedBox(height: 8),
                Text(_errorMessage, style: const TextStyle(color: Colors.redAccent, fontSize: 12)),
              ],

              const SizedBox(height: 18),

              // Botões de Ação
              Row(
                children: [
                  Expanded(
                    child: TextButton(
                      style: TextButton.styleFrom(foregroundColor: Colors.grey),
                      onPressed: _isGenerating ? null : () => Navigator.pop(context),
                      child: const Text('Cancelar'),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    flex: 2,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primaryColor,
                        foregroundColor: Colors.black,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      icon: _isGenerating
                          ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.black))
                          : const Icon(Icons.auto_awesome, size: 18),
                      label: Text(_isGenerating ? 'Gerando...' : 'Gerar Ficha', style: const TextStyle(fontWeight: FontWeight.bold)),
                      onPressed: _isGenerating ? null : _generate,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

