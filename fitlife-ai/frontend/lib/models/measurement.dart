// lib/models/measurement.dart

class BodyMeasurement {
  final int id;
  final int? serverId;
  final int userId;
  final String measuredAt;
  final double? weightKg;
  final double? bodyFatPct;
  final double? muscleMassKg;
  final double? chestCm;
  final double? waistCm;
  final double? hipCm;
  final double? armCm;
  final double? thighCm;
  final String? notes;
  final DateTime? createdAt;

  const BodyMeasurement({
    required this.id,
    this.serverId,
    required this.userId,
    required this.measuredAt,
    this.weightKg,
    this.bodyFatPct,
    this.muscleMassKg,
    this.chestCm,
    this.waistCm,
    this.hipCm,
    this.armCm,
    this.thighCm,
    this.notes,
    this.createdAt,
  });

  factory BodyMeasurement.fromJson(Map<String, dynamic> json) {
    return BodyMeasurement(
      id:           json['id'] as int,
      userId:       (json['user_id'] as int?) ?? 0,
      measuredAt:   json['measured_at'] as String? ?? DateTime.now().toIso8601String().split('T')[0],
      weightKg:     (json['weight_kg'] as num?)?.toDouble(),
      bodyFatPct:   (json['body_fat_pct'] as num?)?.toDouble(),
      muscleMassKg: (json['muscle_mass_kg'] as num?)?.toDouble(),
      chestCm:      (json['chest_cm'] as num?)?.toDouble(),
      waistCm:      (json['waist_cm'] as num?)?.toDouble(),
      hipCm:        (json['hip_cm'] as num?)?.toDouble(),
      armCm:        (json['arm_cm'] as num?)?.toDouble(),
      thighCm:      (json['thigh_cm'] as num?)?.toDouble(),
      notes:        json['notes'] as String?,
      createdAt:    json['created_at'] != null ? DateTime.tryParse(json['created_at']) : null,
    );
  }

  factory BodyMeasurement.fromMap(Map<String, dynamic> map) {
    return BodyMeasurement(
      id:           map['id'] as int,
      serverId:     map['server_id'] as int?,
      userId:       (map['user_id'] as int?) ?? 0,
      measuredAt:   map['measured_at'] as String? ?? DateTime.now().toIso8601String().split('T')[0],
      weightKg:     (map['weight_kg'] as num?)?.toDouble(),
      bodyFatPct:   (map['body_fat_pct'] as num?)?.toDouble(),
      muscleMassKg: (map['muscle_mass_kg'] as num?)?.toDouble(),
      chestCm:      (map['chest_cm'] as num?)?.toDouble(),
      waistCm:      (map['waist_cm'] as num?)?.toDouble(),
      hipCm:        (map['hip_cm'] as num?)?.toDouble(),
      armCm:        (map['arm_cm'] as num?)?.toDouble(),
      thighCm:      (map['thigh_cm'] as num?)?.toDouble(),
      notes:        map['notes'] as String?,
    );
  }

  Map<String, dynamic> toMap() => {
    if (serverId != null) 'server_id': serverId,
    'user_id':        userId,
    'measured_at':    measuredAt,
    'weight_kg':      weightKg,
    'body_fat_pct':   bodyFatPct,
    'muscle_mass_kg': muscleMassKg,
    'chest_cm':       chestCm,
    'waist_cm':       waistCm,
    'hip_cm':         hipCm,
    'arm_cm':         armCm,
    'thigh_cm':       thighCm,
    'notes':          notes,
  };

  Map<String, dynamic> toJson() => toMap();
}

