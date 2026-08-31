// lib/models/food_item.dart

class FoodItem {
  final String id;
  final String name;
  final String brand;
  final String category; // 'natural' | 'industrialized'
  final double kcal;
  final double protein;
  final double carbs;
  final double fat;
  final double fiber;
  final String source; // 'TACO (Brasil)' | 'Open Food Facts'
  final int portionG;

  const FoodItem({
    required this.id,
    required this.name,
    required this.brand,
    required this.category,
    required this.kcal,
    required this.protein,
    required this.carbs,
    required this.fat,
    required this.fiber,
    required this.source,
    this.portionG = 100,
  });

  factory FoodItem.fromJson(Map<String, dynamic> json) {
    return FoodItem(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? 'Alimento',
      brand: json['brand']?.toString() ?? '',
      category: json['category']?.toString() ?? 'natural',
      kcal: (json['kcal'] as num?)?.toDouble() ?? 0,
      protein: (json['protein'] as num?)?.toDouble() ?? 0,
      carbs: (json['carbs'] as num?)?.toDouble() ?? 0,
      fat: (json['fat'] as num?)?.toDouble() ?? 0,
      fiber: (json['fiber'] as num?)?.toDouble() ?? 0,
      source: json['source']?.toString() ?? '',
      portionG: (json['portionG'] as num?)?.toInt() ?? 100,
    );
  }

  bool get isNatural => category == 'natural';

  // Getters normalizados por 100g (para comparação nutricional)
  double get calories100g => portionG > 0 ? kcal * 100.0 / portionG : kcal;
  double get protein100g => portionG > 0 ? protein * 100.0 / portionG : protein;
  double get carbs100g => portionG > 0 ? carbs * 100.0 / portionG : carbs;
  double get fat100g => portionG > 0 ? fat * 100.0 / portionG : fat;

  /// Calcula macros e calorias proporcionais para a porção informada em gramas
  FoodItem forPortion(double grams) {
    final ratio = grams / 100.0;
    return FoodItem(
      id: id,
      name: name,
      brand: brand,
      category: category,
      kcal: kcal * ratio,
      protein: protein * ratio,
      carbs: carbs * ratio,
      fat: fat * ratio,
      fiber: fiber * ratio,
      source: source,
      portionG: grams.toInt(),
    );
  }
}
