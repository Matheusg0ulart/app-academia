// lib/screens/exercises_screen.dart

import 'package:flutter/material.dart';
import '../core/theme/app_theme.dart';
import '../models/exercise.dart';
import '../services/api_service.dart';

class ExercisesScreen extends StatefulWidget {
  const ExercisesScreen({super.key});

  @override
  State<ExercisesScreen> createState() => _ExercisesScreenState();
}

class _ExercisesScreenState extends State<ExercisesScreen> {
  final ApiService _api = ApiService();
  List<Exercise> _allExercises = [];
  List<Exercise> _filteredExercises = [];
  String _selectedMuscle = 'todos';
  String _searchQuery = '';
  bool _isLoading = true;

  final List<Map<String, String>> _muscleFilters = [
    {'key': 'todos', 'label': 'Todos'},
    {'key': 'chest', 'label': 'Peito'},
    {'key': 'back', 'label': 'Costas'},
    {'key': 'quadriceps', 'label': 'Quadríceps'},
    {'key': 'hamstrings', 'label': 'Posterior'},
    {'key': 'glutes', 'label': 'Glúteos'},
    {'key': 'shoulders', 'label': 'Ombros'},
    {'key': 'biceps', 'label': 'Bíceps'},
    {'key': 'triceps', 'label': 'Tríceps'},
    {'key': 'abs', 'label': 'Abdômen'},
    {'key': 'cardio', 'label': 'Cardio'},
  ];

  @override
  void initState() {
    super.initState();
    _loadExercises();
  }

  Future<void> _loadExercises() async {
    setState(() => _isLoading = true);
    try {
      final exercises = await _api.getExercises();
      if (!mounted) return;
      setState(() {
        _allExercises = exercises;
        _applyFilters();
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
    }
  }

  void _applyFilters() {
    setState(() {
      _filteredExercises = _allExercises.filter((e) {
        final matchesMuscle = _selectedMuscle == 'todos' || e.muscleGroup.toLowerCase() == _selectedMuscle.toLowerCase();
        final matchesSearch = _searchQuery.isEmpty || e.name.toLowerCase().contains(_searchQuery.toLowerCase());
        return matchesMuscle && matchesSearch;
      }).toList();
    });
  }

  void _showExerciseDetail(Exercise exercise) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppTheme.cardDarkBackground,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) {
        return Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      exercise.name,
                      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryColor.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      exercise.muscleGroup.toUpperCase(),
                      style: const TextStyle(color: AppTheme.primaryColor, fontWeight: FontWeight.bold, fontSize: 11),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              const Text('Descrição', style: TextStyle(color: AppTheme.primaryColor, fontWeight: FontWeight.bold, fontSize: 14)),
              const SizedBox(height: 4),
              Text(
                exercise.description ?? 'Sem descrição cadastrada.',
                style: const TextStyle(color: Colors.white70, fontSize: 14, height: 1.4),
              ),
              const SizedBox(height: 16),
              const Text('Instruções e Execução', style: TextStyle(color: AppTheme.primaryColor, fontWeight: FontWeight.bold, fontSize: 14)),
              const SizedBox(height: 4),
              Text(
                exercise.instructions ?? 'Mantenha a postura correta e execute com controle.',
                style: const TextStyle(color: Colors.white, fontSize: 14, height: 1.5),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryColor,
                    foregroundColor: Colors.black,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: () => Navigator.pop(ctx),
                  child: const Text('Fechar', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _showCreateCustomExerciseDialog() async {
    final nameController = TextEditingController();
    final descController = TextEditingController();
    final instController = TextEditingController();
    String muscle = 'chest';

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
                  const Text('Novo Exercício Personalizado', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
                  const SizedBox(height: 16),
                  TextField(
                    controller: nameController,
                    decoration: InputDecoration(
                      labelText: 'Nome do Exercício',
                      filled: true,
                      fillColor: AppTheme.darkBackground,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                    ),
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    value: muscle,
                    decoration: InputDecoration(
                      labelText: 'Grupo Muscular',
                      filled: true,
                      fillColor: AppTheme.darkBackground,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                    ),
                    dropdownColor: AppTheme.cardDarkBackground,
                    items: _muscleFilters
                        .where((m) => m['key'] != 'todos')
                        .map((m) => DropdownMenuItem(value: m['key'], child: Text(m['label']!)))
                        .toList(),
                    onChanged: (val) => setModalState(() => muscle = val ?? 'chest'),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: descController,
                    decoration: InputDecoration(
                      labelText: 'Descrição / Dicas (opcional)',
                      filled: true,
                      fillColor: AppTheme.darkBackground,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: instController,
                    decoration: InputDecoration(
                      labelText: 'Instruções de Execução (opcional)',
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
                        await _api.createExercise({
                          'name': name,
                          'muscle_group': muscle,
                          'description': descController.text.trim(),
                          'instructions': instController.text.trim(),
                        });
                        _loadExercises();
                      } catch (e) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Erro ao salvar exercício: $e')),
                        );
                      }
                    },
                    child: const Text('Salvar Exercício', style: TextStyle(fontWeight: FontWeight.bold)),
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
    return Scaffold(
      appBar: AppBar(
        title: const Text('Catálogo de Exercícios'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_rounded, color: AppTheme.primaryColor),
            onPressed: _showCreateCustomExerciseDialog,
          ),
        ],
      ),
      body: Column(
        children: [
          // Campo de busca
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Buscar exercício...',
                prefixIcon: const Icon(Icons.search, color: AppTheme.primaryColor),
                filled: true,
                fillColor: AppTheme.cardDarkBackground,
                contentPadding: const EdgeInsets.symmetric(vertical: 12),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
              ),
              onChanged: (val) {
                _searchQuery = val;
                _applyFilters();
              },
            ),
          ),

          // Chips de filtro por grupo muscular
          SizedBox(
            height: 48,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: _muscleFilters.length,
              itemBuilder: (context, index) {
                final item = _muscleFilters[index];
                final isSelected = _selectedMuscle == item['key'];
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: FilterChip(
                    label: Text(item['label']!),
                    selected: isSelected,
                    selectedColor: AppTheme.primaryColor,
                    backgroundColor: AppTheme.cardDarkBackground,
                    labelStyle: TextStyle(
                      color: isSelected ? Colors.black : Colors.white70,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      fontSize: 12,
                    ),
                    onSelected: (_) {
                      setState(() {
                        _selectedMuscle = item['key']!;
                        _applyFilters();
                      });
                    },
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 8),

          // Lista de exercícios
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator(color: AppTheme.primaryColor))
                : _filteredExercises.isEmpty
                    ? const Center(child: Text('Nenhum exercício encontrado', style: TextStyle(color: Colors.grey)))
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        itemCount: _filteredExercises.length,
                        itemBuilder: (context, index) {
                          final ex = _filteredExercises[index];
                          return Card(
                            color: AppTheme.cardDarkBackground,
                            margin: const EdgeInsets.only(bottom: 10),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            child: ListTile(
                              leading: Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: AppTheme.primaryColor.withOpacity(0.12),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(Icons.fitness_center_rounded, color: AppTheme.primaryColor, size: 20),
                              ),
                              title: Text(ex.name, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 14)),
                              subtitle: Text(
                                ex.description ?? 'Grupo: ${ex.muscleGroup}',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(color: Colors.grey[400], fontSize: 12),
                              ),
                              trailing: const Icon(Icons.chevron_right_rounded, color: Colors.grey),
                              onTap: () => _showExerciseDetail(ex),
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }
}

extension ListFilter<T> on List<T> {
  List<T> filter(bool Function(T) test) {
    final res = <T>[];
    for (final element in this) {
      if (test(element)) res.add(element);
    }
    return res;
  }
}

