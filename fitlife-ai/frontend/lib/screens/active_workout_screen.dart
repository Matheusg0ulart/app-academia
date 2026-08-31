// lib/screens/active_workout_screen.dart

import 'dart:async';
import 'package:flutter/material.dart';
import '../core/theme/app_theme.dart';
import '../models/workout.dart';
import '../models/workout_log.dart';
import '../services/api_service.dart';
import '../widgets/glass_card.dart';

class ActiveWorkoutScreen extends StatefulWidget {
  final Workout? workout;

  const ActiveWorkoutScreen({super.key, this.workout});

  @override
  State<ActiveWorkoutScreen> createState() => _ActiveWorkoutScreenState();
}

class _ActiveExerciseItem {
  final int exerciseId;
  final String exerciseName;
  final List<_ActiveSetItem> sets;

  _ActiveExerciseItem({
    required this.exerciseId,
    required this.exerciseName,
    required this.sets,
  });
}

class _ActiveSetItem {
  int setNumber;
  int reps;
  double weightKg;
  bool isDone;

  _ActiveSetItem({
    required this.setNumber,
    required this.reps,
    required this.weightKg,
    this.isDone = false,
  });

  /// Estimativa de 1RM (Fórmula de Epley)
  double get estimatedOneRepMax {
    if (reps <= 0 || weightKg <= 0) return 0;
    if (reps == 1) return weightKg;
    return weightKg * (1 + reps / 30.0);
  }

  /// Volume da série
  double get volume => isDone ? (weightKg * reps) : 0.0;
}

class _ActiveWorkoutScreenState extends State<ActiveWorkoutScreen> {
  final ApiService _api = ApiService();
  late Timer _sessionTimer;
  int _secondsElapsed = 0;
  WorkoutLog? _log;
  bool _isSaving = false;

  // Cronômetro de Descanso
  Timer? _restTimer;
  int _restSecondsRemaining = 0;
  int _totalRestSeconds = 60;

  final List<_ActiveExerciseItem> _exercises = [];

  @override
  void initState() {
    super.initState();
    _startSessionTimer();
    _initWorkoutData();
  }

  @override
  void dispose() {
    _sessionTimer.cancel();
    _restTimer?.cancel();
    super.dispose();
  }

  void _startSessionTimer() {
    _sessionTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) setState(() => _secondsElapsed++);
    });
  }

  void _startRestTimer(int seconds) {
    _restTimer?.cancel();
    setState(() {
      _totalRestSeconds = seconds;
      _restSecondsRemaining = seconds;
    });

    _restTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      if (_restSecondsRemaining > 0) {
        setState(() => _restSecondsRemaining--);
      } else {
        timer.cancel();
      }
    });
  }

  void _addRestTime(int extraSeconds) {
    setState(() {
      _restSecondsRemaining += extraSeconds;
      _totalRestSeconds += extraSeconds;
    });
  }

  Future<void> _initWorkoutData() async {
    try {
      final log = await _api.startWorkoutLog(
        workoutId: widget.workout?.id,
      );
      if (!mounted) return;
      setState(() => _log = log);
    } catch (_) {}

    if (widget.workout != null && widget.workout!.exercises.isNotEmpty) {
      for (final we in widget.workout!.exercises) {
        final sets = <_ActiveSetItem>[];
        for (int s = 1; s <= we.sets; s++) {
          sets.add(_ActiveSetItem(
            setNumber: s,
            reps: we.reps,
            weightKg: we.weightKg ?? 20.0,
          ));
        }
        _exercises.add(_ActiveExerciseItem(
          exerciseId: we.exerciseId,
          exerciseName: we.exerciseName ?? 'Exercício #${we.exerciseId}',
          sets: sets,
        ));
      }
      if (mounted) setState(() {});
    } else {
      _exercises.add(_ActiveExerciseItem(
        exerciseId: 1,
        exerciseName: 'Supino Reto com Barra',
        sets: [
          _ActiveSetItem(setNumber: 1, reps: 10, weightKg: 40),
          _ActiveSetItem(setNumber: 2, reps: 10, weightKg: 40),
          _ActiveSetItem(setNumber: 3, reps: 8, weightKg: 45),
        ],
      ));
      if (mounted) setState(() {});
    }
  }

  String _formatTime(int totalSeconds) {
    final minutes = (totalSeconds ~/ 60).toString().padLeft(2, '0');
    final seconds = (totalSeconds % 60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  double get _totalVolumeTonnage {
    double sum = 0.0;
    for (final ex in _exercises) {
      for (final s in ex.sets) {
        sum += s.volume;
      }
    }
    return sum;
  }

  int get _totalCompletedSets {
    int count = 0;
    for (final ex in _exercises) {
      for (final s in ex.sets) {
        if (s.isDone) count++;
      }
    }
    return count;
  }

  Future<void> _finishWorkout() async {
    int rating = 5;
    final notesController = TextEditingController();
    final totalVol = _totalVolumeTonnage;
    final totalSets = _totalCompletedSets;

    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              backgroundColor: AppTheme.cardDarkBackground,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              title: Row(
                children: const [
                  Icon(Icons.emoji_events_rounded, color: Colors.amber, size: 28),
                  SizedBox(width: 8),
                  Text('Treino Concluído!', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
                ],
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppTheme.darkBackground,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          Column(
                            children: [
                              const Text('TEMPO', style: TextStyle(color: Colors.grey, fontSize: 10, fontWeight: FontWeight.bold)),
                              const SizedBox(height: 2),
                              Text(_formatTime(_secondsElapsed), style: const TextStyle(color: AppTheme.primaryColor, fontWeight: FontWeight.bold, fontSize: 16)),
                            ],
                          ),
                          Column(
                            children: [
                              const Text('VOLUME', style: TextStyle(color: Colors.grey, fontSize: 10, fontWeight: FontWeight.bold)),
                              const SizedBox(height: 2),
                              Text('${totalVol.toInt()} kg', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                            ],
                          ),
                          Column(
                            children: [
                              const Text('SÉRIES', style: TextStyle(color: Colors.grey, fontSize: 10, fontWeight: FontWeight.bold)),
                              const SizedBox(height: 2),
                              Text('$totalSets', style: const TextStyle(color: Colors.cyanAccent, fontWeight: FontWeight.bold, fontSize: 16)),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text('Como foi o esforço da sessão?', style: TextStyle(color: Colors.white70, fontSize: 13)),
                    const SizedBox(height: 6),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(5, (index) {
                        final star = index + 1;
                        return IconButton(
                          icon: Icon(
                            star <= rating ? Icons.star_rounded : Icons.star_outline_rounded,
                            color: Colors.amber,
                            size: 32,
                          ),
                          onPressed: () => setDialogState(() => rating = star),
                        );
                      }),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: notesController,
                      decoration: InputDecoration(
                        labelText: 'Observações / Sensação de treino',
                        filled: true,
                        fillColor: AppTheme.darkBackground,
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  child: const Text('Voltar', style: TextStyle(color: Colors.grey)),
                  onPressed: () => Navigator.pop(ctx),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryColor,
                    foregroundColor: Colors.black,
                  ),
                  child: const Text('Salvar e Encerrar', style: TextStyle(fontWeight: FontWeight.bold)),
                  onPressed: () {
                    Navigator.pop(ctx);
                    _saveAndExit(rating, notesController.text.trim());
                  },
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _saveAndExit(int rating, String notes) async {
    setState(() => _isSaving = true);

    try {
      if (_log != null) {
        for (final ex in _exercises) {
          for (final set in ex.sets) {
            if (set.isDone) {
              await _api.addSet(_log!.id, {
                'exercise_id': ex.exerciseId,
                'set_number': set.setNumber,
                'reps_done': set.reps,
                'weight_kg': set.weightKg,
              });
            }
          }
        }
        await _api.finishWorkoutLog(_log!.id, rating: rating, notes: notes);
      }
    } catch (_) {}

    if (!mounted) return;
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.workout?.name ?? 'Treino em Andamento'),
        actions: [
          IconButton(
            icon: const Icon(Icons.check_circle_rounded, color: AppTheme.primaryColor),
            tooltip: 'Concluir Treino',
            onPressed: _finishWorkout,
          ),
        ],
      ),
      body: _isSaving
          ? const Center(child: CircularProgressIndicator(color: AppTheme.primaryColor))
          : Column(
              children: [
                // Banner Superior com Métricas em Tempo Real
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                  decoration: BoxDecoration(
                    color: AppTheme.cardDarkBackground,
                    border: Border(bottom: BorderSide(color: Colors.white.withOpacity(0.05))),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('TEMPO', style: TextStyle(color: Colors.grey, fontSize: 10, fontWeight: FontWeight.bold)),
                          Text(
                            _formatTime(_secondsElapsed),
                            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.extrabold, color: Colors.white),
                          ),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          const Text('VOLUME TOTAL', style: TextStyle(color: Colors.grey, fontSize: 10, fontWeight: FontWeight.bold)),
                          Text(
                            '${_totalVolumeTonnage.toInt()} kg',
                            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.primaryColor),
                          ),
                        ],
                      ),
                      if (_restSecondsRemaining > 0) ...[
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                              decoration: BoxDecoration(
                                color: Colors.amber.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(color: Colors.amber),
                              ),
                              child: Text(
                                '${_restSecondsRemaining}s',
                                style: const TextStyle(color: Colors.amber, fontWeight: FontWeight.bold, fontSize: 14),
                              ),
                            ),
                            const SizedBox(width: 4),
                            IconButton(
                              icon: const Icon(Icons.add, color: Colors.amber, size: 18),
                              tooltip: '+15s descanso',
                              onPressed: () => _addRestTime(15),
                            ),
                          ],
                        ),
                      ] else ...[
                        OutlinedButton(
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppTheme.primaryColor,
                            side: const BorderSide(color: AppTheme.primaryColor),
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          ),
                          onPressed: () => _startRestTimer(60),
                          child: const Text('Descanso 60s', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                        ),
                      ],
                    ],
                  ),
                ),

                // Lista de Exercícios
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _exercises.length,
                    itemBuilder: (context, exIndex) {
                      final ex = _exercises[exIndex];
                      return GlassCard(
                        margin: const EdgeInsets.only(bottom: 16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Text(
                                    ex.exerciseName,
                                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.add_circle_outline, color: AppTheme.primaryColor, size: 20),
                                  tooltip: 'Adicionar Série',
                                  onPressed: () {
                                    setState(() {
                                      ex.sets.add(_ActiveSetItem(
                                        setNumber: ex.sets.length + 1,
                                        reps: ex.sets.isNotEmpty ? ex.sets.last.reps : 10,
                                        weightKg: ex.sets.isNotEmpty ? ex.sets.last.weightKg : 20.0,
                                      ));
                                    });
                                  },
                                ),
                              ],
                            ),
                            const Divider(color: Colors.white10),
                            ...ex.sets.map((set) {
                              final oneRm = set.estimatedOneRepMax;
                              return Padding(
                                padding: const EdgeInsets.symmetric(vertical: 4),
                                child: Row(
                                  children: [
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Série ${set.setNumber}',
                                          style: TextStyle(
                                            color: set.isDone ? AppTheme.primaryColor : Colors.grey[300],
                                            fontWeight: FontWeight.bold,
                                            fontSize: 13,
                                          ),
                                        ),
                                        if (oneRm > 0)
                                          Text(
                                            '1RM ~${oneRm.toInt()}kg',
                                            style: const TextStyle(color: Colors.grey, fontSize: 9),
                                          ),
                                      ],
                                    ),
                                    const Spacer(),
                                    SizedBox(
                                      width: 72,
                                      child: TextFormField(
                                        initialValue: '${set.weightKg.toInt()}',
                                        keyboardType: TextInputType.number,
                                        textAlign: TextAlign.center,
                                        decoration: InputDecoration(
                                          suffixText: 'kg',
                                          isDense: true,
                                          contentPadding: const EdgeInsets.all(6),
                                          filled: true,
                                          fillColor: AppTheme.darkBackground,
                                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
                                        ),
                                        onChanged: (val) {
                                          set.weightKg = double.tryParse(val) ?? set.weightKg;
                                        },
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    SizedBox(
                                      width: 72,
                                      child: TextFormField(
                                        initialValue: '${set.reps}',
                                        keyboardType: TextInputType.number,
                                        textAlign: TextAlign.center,
                                        decoration: InputDecoration(
                                          suffixText: 'reps',
                                          isDense: true,
                                          contentPadding: const EdgeInsets.all(6),
                                          filled: true,
                                          fillColor: AppTheme.darkBackground,
                                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
                                        ),
                                        onChanged: (val) {
                                          set.reps = int.tryParse(val) ?? set.reps;
                                        },
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Checkbox(
                                      value: set.isDone,
                                      activeColor: AppTheme.primaryColor,
                                      checkColor: Colors.black,
                                      onChanged: (val) {
                                        setState(() => set.isDone = val ?? false);
                                        if (val == true) {
                                          _startRestTimer(60);
                                        }
                                      },
                                    ),
                                  ],
                                ),
                              );
                            }),
                          ],
                        ),
                      );
                    },
                  ),
                ),

                // Botão Inferior Finalizar
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primaryColor,
                        foregroundColor: Colors.black,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      ),
                      icon: const Icon(Icons.check_circle_rounded),
                      label: const Text('Concluir Sessão de Treino', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      onPressed: _finishWorkout,
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}
