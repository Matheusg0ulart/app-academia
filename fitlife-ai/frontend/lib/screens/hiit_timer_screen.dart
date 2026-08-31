// lib/screens/hiit_timer_screen.dart

import 'dart:async';
import 'package:flutter/material.dart';
import '../core/theme/app_theme.dart';

enum HiitPhase { ready, work, rest, finished }

class HiitTimerScreen extends StatefulWidget {
  final double userWeightKg;

  const HiitTimerScreen({super.key, this.userWeightKg = 75.0});

  @override
  State<HiitTimerScreen> createState() => _HiitTimerScreenState();
}

class _HiitTimerScreenState extends State<HiitTimerScreen> {
  // Configurações do Treino
  int _prepareSecs = 5;
  int _workSecs = 20;
  int _restSecs = 10;
  int _totalRounds = 8;

  // Estado Atual
  int _currentRound = 1;
  int _secondsLeft = 5;
  HiitPhase _phase = HiitPhase.ready;
  bool _isRunning = false;
  int _totalElapsedSecs = 0;

  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _secondsLeft = _prepareSecs;
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startTimer() {
    setState(() => _isRunning = true);
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) return;

      setState(() {
        _totalElapsedSecs++;

        if (_secondsLeft > 1) {
          _secondsLeft--;
        } else {
          // Transição de Fases
          if (_phase == HiitPhase.ready) {
            _phase = HiitPhase.work;
            _secondsLeft = _workSecs;
          } else if (_phase == HiitPhase.work) {
            if (_currentRound >= _totalRounds) {
              _phase = HiitPhase.finished;
              _isRunning = false;
              _timer?.cancel();
            } else {
              _phase = HiitPhase.rest;
              _secondsLeft = _restSecs;
            }
          } else if (_phase == HiitPhase.rest) {
            _currentRound++;
            _phase = HiitPhase.work;
            _secondsLeft = _workSecs;
          }
        }
      });
    });
  }

  void _pauseTimer() {
    _timer?.cancel();
    setState(() => _isRunning = false);
  }

  void _resetTimer() {
    _timer?.cancel();
    setState(() {
      _isRunning = false;
      _phase = HiitPhase.ready;
      _currentRound = 1;
      _secondsLeft = _prepareSecs;
      _totalElapsedSecs = 0;
    });
  }

  void _selectPreset(String name) {
    _resetTimer();
    setState(() {
      if (name == 'tabata') {
        _prepareSecs = 5;
        _workSecs = 20;
        _restSecs = 10;
        _totalRounds = 8;
      } else if (name == 'hiit30') {
        _prepareSecs = 5;
        _workSecs = 30;
        _restSecs = 30;
        _totalRounds = 10;
      } else if (name == 'emom') {
        _prepareSecs = 5;
        _workSecs = 45;
        _restSecs = 15;
        _totalRounds = 12;
      }
      _secondsLeft = _prepareSecs;
    });
  }

  // Estimativa de Calorias (MET 10 para HIIT)
  double get _estimatedKcal {
    final weight = widget.userWeightKg > 0 ? widget.userWeightKg : 75.0;
    final hours = _totalElapsedSecs / 3600.0;
    return 10.0 * weight * hours;
  }

  Color get _phaseColor {
    switch (_phase) {
      case HiitPhase.ready:
        return Colors.cyanAccent;
      case HiitPhase.work:
        return Colors.redAccent;
      case HiitPhase.rest:
        return Colors.amberAccent;
      case HiitPhase.finished:
        return Colors.greenAccent;
    }
  }

  String get _phaseTitle {
    switch (_phase) {
      case HiitPhase.ready:
        return 'PREPARAR! 🔥';
      case HiitPhase.work:
        return 'TIRO / ESFORÇO MÁXIMO! ⚡';
      case HiitPhase.rest:
        return 'DESCANSO 🫁';
      case HiitPhase.finished:
        return 'TREINO CONCLUÍDO! 🏆';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.darkBackground,
      appBar: AppBar(
        title: const Text('Cronômetro HIIT & Tabata'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _resetTimer,
          ),
        ],
      ),
      body: Column(
        children: [
          // Seletor de Presets
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildPresetChip('Tabata (20/10)', 'tabata', _workSecs == 20 && _totalRounds == 8),
                _buildPresetChip('HIIT 30/30', 'hiit30', _workSecs == 30 && _totalRounds == 10),
                _buildPresetChip('EMOM (45/15)', 'emom', _workSecs == 45 && _totalRounds == 12),
              ],
            ),
          ),

          // Display Central Animado
          Expanded(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Badge de Fase
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
                    decoration: BoxDecoration(
                      color: _phaseColor.withOpacity(0.18),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: _phaseColor.withOpacity(0.5)),
                    ),
                    child: Text(
                      _phaseTitle,
                      style: TextStyle(color: _phaseColor, fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Círculo com Tempo
                  Container(
                    width: 230,
                    height: 230,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppTheme.cardDarkBackground,
                      boxShadow: [
                        BoxShadow(
                          color: _phaseColor.withOpacity(0.25),
                          blurRadius: 30,
                          spreadRadius: 4,
                        ),
                      ],
                      border: Border.all(color: _phaseColor, width: 4),
                    ),
                    alignment: Alignment.center,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          '$_secondsLeft',
                          style: TextStyle(
                            fontSize: 78,
                            fontWeight: FontWeight.extrabold,
                            color: _phaseColor,
                            letterSpacing: -2,
                          ),
                        ),
                        Text(
                          'segundos',
                          style: TextStyle(color: Colors.grey[400], fontSize: 13),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Round e Informações
                  Text(
                    'Round $_currentRound de $_totalRounds',
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 20),
                  ),
                  const SizedBox(height: 12),

                  // Calorias e Tempo Total
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: AppTheme.cardDarkBackground,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.timer_outlined, color: AppTheme.primaryColor, size: 16),
                            const SizedBox(width: 6),
                            Text(
                              '${(_totalElapsedSecs ~/ 60).toString().padLeft(2, '0')}:${(_totalElapsedSecs % 60).toString().padLeft(2, '0')}',
                              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: AppTheme.cardDarkBackground,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.local_fire_department_rounded, color: Colors.orangeAccent, size: 16),
                            const SizedBox(width: 6),
                            Text(
                              '${_estimatedKcal.toInt()} kcal',
                              style: const TextStyle(color: Colors.orangeAccent, fontWeight: FontWeight.bold, fontSize: 14),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // Controles de Play / Pause / Reset
          Padding(
            padding: const EdgeInsets.all(24),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.white70,
                      side: const BorderSide(color: Colors.white24),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                    onPressed: _resetTimer,
                    child: const Text('Reiniciar', style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  flex: 2,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _isRunning ? Colors.amberAccent : AppTheme.primaryColor,
                      foregroundColor: Colors.black,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                    icon: Icon(_isRunning ? Icons.pause_rounded : Icons.play_arrow_rounded, size: 24),
                    label: Text(
                      _isRunning ? 'Pausar' : 'Iniciar Treino',
                      style: const TextStyle(fontWeight: FontWeight.extrabold, fontSize: 16),
                    ),
                    onPressed: _phase == HiitPhase.finished ? _resetTimer : (_isRunning ? _pauseTimer : _startTimer),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPresetChip(String label, String key, bool isSelected) {
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      selectedColor: AppTheme.primaryColor,
      backgroundColor: AppTheme.cardDarkBackground,
      labelStyle: TextStyle(
        color: isSelected ? Colors.black : Colors.white70,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        fontSize: 12,
      ),
      onSelected: (_) => _selectPreset(key),
    );
  }
}

