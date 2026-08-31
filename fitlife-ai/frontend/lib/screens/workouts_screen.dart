import 'package:flutter/material.dart';
import '../core/theme/app_theme.dart';
import '../models/workout.dart';
import '../models/exercise.dart';
import '../services/api_service.dart';
import '../widgets/glass_card.dart';
import 'active_workout_screen.dart';
import 'workout_generator_dialog.dart';
import 'workout_history_screen.dart';

class WorkoutsScreen extends StatefulWidget {
  const WorkoutsScreen({super.key});

  @override
  State<WorkoutsScreen> createState() => _WorkoutsScreenState();
}

class _WorkoutsScreenState extends State<WorkoutsScreen> {
  final ApiService _api = ApiService();
  List<Workout> _workouts = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadWorkouts();
  }

  Future<void> _loadWorkouts() async {
    setState(() => _isLoading = true);
    try {
      final workouts = await _api.getWorkouts();
      if (!mounted) return;
      setState(() {
        _workouts = workouts;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
    }
  }

  void _startWorkout(Workout? workout) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ActiveWorkoutScreen(workout: workout),
      ),
    ).then((_) => _loadWorkouts());
  }

  Future<void> _deleteWorkout(int id) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.cardDarkBackground,
        title: const Text('Excluir ficha?', style: TextStyle(color: Colors.white)),
        content: const Text('Esta ação não pode ser desfeita.', style: TextStyle(color: Colors.white70)),
        actions: [
          TextButton(child: const Text('Cancelar'), onPressed: () => Navigator.pop(ctx, false)),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
            child: const Text('Excluir'),
            onPressed: () => Navigator.pop(ctx, true),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await _api.deleteWorkout(id);
        _loadWorkouts();
      } catch (_) {}
    }
  }

  Future<void> _showCreateWorkoutDialog() async {
    final nameController = TextEditingController();
    final descController = TextEditingController();

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
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Criar Nova Ficha de Treino',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: nameController,
                decoration: InputDecoration(
                  labelText: 'Nome do Treino (ex: Treino A - Peito e Tríceps)',
                  filled: true,
                  fillColor: AppTheme.darkBackground,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: descController,
                decoration: InputDecoration(
                  labelText: 'Descrição ou Foco (opcional)',
                  filled: true,
                  fillColor: AppTheme.darkBackground,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
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
                  final name = nameController.text.trim();
                  if (name.isEmpty) return;
                  Navigator.pop(ctx);
                  try {
                    await _api.createWorkout({
                      'name': name,
                      'description': descController.text.trim(),
                    });
                    _loadWorkouts();
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Erro ao criar treino: $e')),
                    );
                  }
                },
                child: const Text('Salvar Ficha', style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _showAddExerciseDialog(Workout workout) async {
    List<Exercise> exercises = [];
    try {
      exercises = await _api.getExercises();
    } catch (_) {}

    if (!mounted || exercises.isEmpty) return;

    Exercise selectedExercise = exercises.first;
    final setsController = TextEditingController(text: '3');
    final repsController = TextEditingController(text: '10');
    final weightController = TextEditingController(text: '20');

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppTheme.cardDarkBackground,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                left: 20,
                right: 20,
                top: 20,
                bottom: MediaQuery.of(ctx).viewInsets.bottom + 20,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'Adicionar Exercício a ${workout.name}',
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<Exercise>(
                    value: selectedExercise,
                    decoration: InputDecoration(
                      labelText: 'Selecione o Exercício',
                      filled: true,
                      fillColor: AppTheme.darkBackground,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                    ),
                    dropdownColor: AppTheme.cardDarkBackground,
                    items: exercises.map((e) {
                      return DropdownMenuItem<Exercise>(
                        value: e,
                        child: Text('${e.name} (${e.muscleGroup})', style: const TextStyle(fontSize: 13)),
                      );
                    }).toList(),
                    onChanged: (val) {
                      if (val != null) setModalState(() => selectedExercise = val);
                    },
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: setsController,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            labelText: 'Séries',
                            filled: true,
                            fillColor: AppTheme.darkBackground,
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: TextField(
                          controller: repsController,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            labelText: 'Reps',
                            filled: true,
                            fillColor: AppTheme.darkBackground,
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: TextField(
                          controller: weightController,
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                          decoration: InputDecoration(
                            labelText: 'Carga (kg)',
                            filled: true,
                            fillColor: AppTheme.darkBackground,
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                          ),
                        ),
                      ),
                    ],
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
                      Navigator.pop(ctx);
                      try {
                        await _api.addExerciseToWorkout(workout.id, {
                          'exercise_id': selectedExercise.id,
                          'sets': int.tryParse(setsController.text) ?? 3,
                          'reps': int.tryParse(repsController.text) ?? 10,
                          'weight_kg': double.tryParse(weightController.text) ?? 20.0,
                          'rest_secs': 60,
                        });
                        _loadWorkouts();
                      } catch (e) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Erro ao adicionar exercício: $e')),
                        );
                      }
                    },
                    child: const Text('Adicionar', style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: AppTheme.primaryColor))
          : RefreshIndicator(
              color: AppTheme.primaryColor,
              onRefresh: _loadWorkouts,
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                children: [
                  // Banner Treino Livre
                  GlassCard(
                    borderColor: AppTheme.primaryColor.withOpacity(0.35),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: AppTheme.primaryColor.withOpacity(0.2),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.timer_outlined, color: AppTheme.primaryColor, size: 28),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: const [
                              Text(
                                'Treino Livre / Avulso',
                                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.white),
                              ),
                              SizedBox(height: 2),
                              Text(
                                'Inicie uma sessão rápida sem rotina fixa.',
                                style: TextStyle(color: Colors.white70, fontSize: 12),
                              ),
                            ],
                          ),
                        ),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.primaryColor,
                            foregroundColor: Colors.black,
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          onPressed: () => _startWorkout(null),
                          child: const Text('Iniciar', style: TextStyle(fontWeight: FontWeight.bold)),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),

                  // Atalhos: Gerar com IA & Histórico
                  Row(
                    children: [
                      Expanded(
                        child: InkWell(
                          borderRadius: BorderRadius.circular(14),
                          onTap: () {
                            showDialog(
                              context: context,
                              builder: (_) => WorkoutGeneratorDialog(
                                onWorkoutsGenerated: _loadWorkouts,
                              ),
                            );
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  AppTheme.primaryColor.withOpacity(0.25),
                                  AppTheme.primaryDark.withOpacity(0.12),
                                ],
                              ),
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(color: AppTheme.primaryColor.withOpacity(0.4)),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: const [
                                Icon(Icons.auto_awesome, color: AppTheme.primaryColor, size: 18),
                                SizedBox(width: 8),
                                Text(
                                  'Gerar com IA',
                                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: InkWell(
                          borderRadius: BorderRadius.circular(14),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => const WorkoutHistoryScreen()),
                            );
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
                            decoration: BoxDecoration(
                              color: AppTheme.cardDarkBackground,
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(color: Colors.white10),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: const [
                                Icon(Icons.history_rounded, color: Colors.white70, size: 18),
                                SizedBox(width: 8),
                                Text(
                                  'Histórico',
                                  style: TextStyle(color: Colors.white70, fontWeight: FontWeight.bold, fontSize: 13),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),

                  // Header Minhas Fichas
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Minhas Fichas (${_workouts.length})',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      TextButton.icon(
                        icon: const Icon(Icons.fitness_center_outlined, size: 18, color: AppTheme.primaryColor),
                        label: const Text('Catálogo', style: TextStyle(color: AppTheme.primaryColor)),
                        onPressed: () => Navigator.pushNamed(context, '/exercises'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  if (_workouts.isEmpty) ...[
                    GlassCard(
                      padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 20),
                      child: Column(
                        children: [
                          const Icon(Icons.fitness_center_rounded, size: 48, color: Colors.grey),
                          const SizedBox(height: 12),
                          const Text('Nenhuma ficha de treino cadastrada', style: TextStyle(color: Colors.white70, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 4),
                          const Text('Toque no botão abaixo para criar seu primeiro treino.', textAlign: TextAlign.center, style: TextStyle(color: Colors.grey, fontSize: 12)),
                          const SizedBox(height: 16),
                          ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppTheme.primaryColor,
                              foregroundColor: Colors.black,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                            ),
                            icon: const Icon(Icons.add),
                            label: const Text('Criar Ficha de Treino'),
                            onPressed: _showCreateWorkoutDialog,
                          ),
                        ],
                      ),
                    ),
                  ] else ...[
                    ..._workouts.map((w) => _buildWorkoutCard(w)),
                  ],
                  const SizedBox(height: 60),
                ],
              ),
            ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.black,
        icon: const Icon(Icons.add_rounded),
        label: const Text('Nova Ficha', style: TextStyle(fontWeight: FontWeight.bold)),
        onPressed: _showCreateWorkoutDialog,
      ),
    );
  }

  Widget _buildWorkoutCard(Workout workout) {
    return GlassCard(
      margin: const EdgeInsets.only(bottom: 14),
      padding: EdgeInsets.zero,
      child: ExpansionTile(
        tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: AppTheme.primaryColor.withOpacity(0.15),
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.fitness_center_rounded, color: AppTheme.primaryColor, size: 20),
        ),
        title: Text(
          workout.name,
          style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 16),
        ),
        subtitle: Text(
          workout.description ?? '${workout.exercises.length} exercícios cadastrados',
          style: TextStyle(color: Colors.grey[400], fontSize: 12),
        ),
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Divider(color: Colors.white10),
                if (workout.exercises.isEmpty) ...[
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 8),
                    child: Text('Nenhum exercício cadastrado nesta ficha ainda.', style: TextStyle(color: Colors.grey, fontSize: 13)),
                  ),
                ] else ...[
                  ...workout.exercises.map((ex) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Row(
                        children: [
                          const Icon(Icons.circle, size: 8, color: AppTheme.primaryColor),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              ex.exerciseName ?? 'Exercício #${ex.exerciseId}',
                              style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w500),
                            ),
                          ),
                          Text(
                            '${ex.sets} × ${ex.reps} (${ex.weightKg ?? 0} kg)',
                            style: const TextStyle(color: Colors.grey, fontSize: 12),
                          ),
                        ],
                      ),
                    );
                  }),
                ],
                const SizedBox(height: 12),
                Row(
                  children: [
                    OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppTheme.primaryColor,
                        side: const BorderSide(color: AppTheme.primaryColor),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      icon: const Icon(Icons.add, size: 16),
                      label: const Text('Exercício', style: TextStyle(fontSize: 12)),
                      onPressed: () => _showAddExerciseDialog(workout),
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      icon: const Icon(Icons.delete_outline, color: Colors.redAccent, size: 20),
                      tooltip: 'Excluir ficha',
                      onPressed: () => _deleteWorkout(workout.id),
                    ),
                    const Spacer(),
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primaryColor,
                        foregroundColor: Colors.black,
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      icon: const Icon(Icons.play_arrow_rounded),
                      label: const Text('Iniciar Treino', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                      onPressed: () => _startWorkout(workout),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
