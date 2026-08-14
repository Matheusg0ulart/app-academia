// lib/models/user.dart

class User {
  final int id;
  final String name;
  final String email;
  final int? age;
  final String? sex;
  final double? weightKg;
  final double? heightCm;
  final String? goal;
  final String? activityLevel;
  final DateTime? updatedAt;

  const User({
    required this.id,
    required this.name,
    required this.email,
    this.age,
    this.sex,
    this.weightKg,
    this.heightCm,
    this.goal,
    this.activityLevel,
    this.updatedAt,
  });

  // ── JSON (API) ───────────────────────────────────────────────
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id:            json['id'] as int,
      name:          json['name'] as String,
      email:         json['email'] as String,
      age:           json['age'] as int?,
      sex:           json['sex'] as String?,
      weightKg:      (json['weight_kg'] as num?)?.toDouble(),
      heightCm:      (json['height_cm'] as num?)?.toDouble(),
      goal:          json['goal'] as String?,
      activityLevel: json['activity_level'] as String?,
      updatedAt:     json['updated_at'] != null ? DateTime.tryParse(json['updated_at']) : null,
    );
  }

  Map<String, dynamic> toJson() => {
    'id':             id,
    'name':           name,
    'email':          email,
    'age':            age,
    'sex':            sex,
    'weight_kg':      weightKg,
    'height_cm':      heightCm,
    'goal':           goal,
    'activity_level': activityLevel,
  };

  // ── SQLite ───────────────────────────────────────────────────
  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      id:            map['id'] as int,
      name:          map['name'] as String,
      email:         map['email'] as String,
      age:           map['age'] as int?,
      sex:           map['sex'] as String?,
      weightKg:      (map['weight_kg'] as num?)?.toDouble(),
      heightCm:      (map['height_cm'] as num?)?.toDouble(),
      goal:          map['goal'] as String?,
      activityLevel: map['activity_level'] as String?,
      updatedAt:     map['updated_at'] != null ? DateTime.tryParse(map['updated_at']) : null,
    );
  }

  Map<String, dynamic> toMap() => {
    'id':             id,
    'name':           name,
    'email':          email,
    'age':            age,
    'sex':            sex,
    'weight_kg':      weightKg,
    'height_cm':      heightCm,
    'goal':           goal,
    'activity_level': activityLevel,
    'updated_at':     updatedAt?.toIso8601String(),
  };

  /// IMC calculado localmente
  double? get bmi {
    if (weightKg == null || heightCm == null || heightCm == 0) return null;
    final heightM = heightCm! / 100;
    return weightKg! / (heightM * heightM);
  }

  User copyWith({
    String? name,
    int? age,
    String? sex,
    double? weightKg,
    double? heightCm,
    String? goal,
    String? activityLevel,
  }) {
    return User(
      id:            id,
      name:          name          ?? this.name,
      email:         email,
      age:           age           ?? this.age,
      sex:           sex           ?? this.sex,
      weightKg:      weightKg      ?? this.weightKg,
      heightCm:      heightCm      ?? this.heightCm,
      goal:          goal          ?? this.goal,
      activityLevel: activityLevel ?? this.activityLevel,
      updatedAt:     DateTime.now(),
    );
  }

  @override
  String toString() => 'User(id: $id, name: $name, email: $email)';
}
