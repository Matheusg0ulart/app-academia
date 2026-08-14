// lib/models/exercise.dart

class Exercise {
  final int id;
  final String name;
  final String muscleGroup;
  final String? description;
  final String? instructions;
  final bool isCustom;
  final int? createdBy;

  const Exercise({
    required this.id,
    required this.name,
    required this.muscleGroup,
    this.description,
    this.instructions,
    this.isCustom = false,
    this.createdBy,
  });

  // ── JSON (API) ───────────────────────────────────────────────
  factory Exercise.fromJson(Map<String, dynamic> json) {
    return Exercise(
      id:           json['id'] as int,
      name:         json['name'] as String,
      muscleGroup:  json['muscle_group'] as String,
      description:  json['description'] as String?,
      instructions: json['instructions'] as String?,
      isCustom:     (json['is_custom'] as bool?) ?? false,
      createdBy:    json['created_by'] as int?,
    );
  }

  Map<String, dynamic> toJson() => {
    'id':           id,
    'name':         name,
    'muscle_group': muscleGroup,
    'description':  description,
    'instructions': instructions,
    'is_custom':    isCustom,
    'created_by':   createdBy,
  };

  // ── SQLite (mapa de colunas) ─────────────────────────────────
  factory Exercise.fromMap(Map<String, dynamic> map) {
    return Exercise(
      id:           map['id'] as int,
      name:         map['name'] as String,
      muscleGroup:  map['muscle_group'] as String,
      description:  map['description'] as String?,
      instructions: map['instructions'] as String?,
      isCustom:     (map['is_custom'] as int?) == 1,
      createdBy:    map['created_by'] as int?,
    );
  }

  Map<String, dynamic> toMap() => {
    'id':           id,
    'name':         name,
    'muscle_group': muscleGroup,
    'description':  description,
    'instructions': instructions,
    'is_custom':    isCustom ? 1 : 0,
    'created_by':   createdBy,
    'synced_at':    DateTime.now().toIso8601String(),
  };

  Exercise copyWith({
    String? name,
    String? muscleGroup,
    String? description,
    String? instructions,
  }) {
    return Exercise(
      id:           id,
      name:         name          ?? this.name,
      muscleGroup:  muscleGroup   ?? this.muscleGroup,
      description:  description   ?? this.description,
      instructions: instructions  ?? this.instructions,
      isCustom:     isCustom,
      createdBy:    createdBy,
    );
  }

  @override
  String toString() => 'Exercise(id: $id, name: $name, muscleGroup: $muscleGroup)';

  @override
  bool operator ==(Object other) => other is Exercise && other.id == id;

  @override
  int get hashCode => id.hashCode;
}
