import 'dart:convert';
import '../../core/constants/enums.dart';

/// 水果主数据模型
class FruitModel {
  final String id;
  final String name;
  final String emoji;
  final String? alias;
  final FruitCategory category;
  final OriginType originType;
  final int maturityDays;
  final Sunlight sunlight;
  final int minTemp;
  final int maxTemp;
  final int optimalTempMin;
  final int optimalTempMax;
  final String soilType;
  final double phMin;
  final double phMax;
  final Drainage drainage;
  final Map<String, dynamic> fertilizer;
  final Map<String, dynamic> plantingNotes;
  final Map<String, dynamic> nutritionalValue;
  final String benefits;
  final String contraindications;
  final String taste;
  final String priceRange;
  final List<String> climateZones;
  final List<int> ripeningMonths;
  final List<int> plantingMonths;

  const FruitModel({
    required this.id,
    required this.name,
    required this.emoji,
    this.alias,
    required this.category,
    required this.originType,
    required this.maturityDays,
    required this.sunlight,
    required this.minTemp,
    required this.maxTemp,
    required this.optimalTempMin,
    required this.optimalTempMax,
    required this.soilType,
    required this.phMin,
    required this.phMax,
    required this.drainage,
    required this.fertilizer,
    required this.plantingNotes,
    required this.nutritionalValue,
    required this.benefits,
    required this.contraindications,
    required this.taste,
    required this.priceRange,
    required this.climateZones,
    required this.ripeningMonths,
    required this.plantingMonths,
  });

  factory FruitModel.fromJson(Map<String, dynamic> json) {
    return FruitModel(
      id: json['id'] as String,
      name: json['name'] as String,
      emoji: json['emoji'] as String? ?? '🍓',
      alias: json['alias'] as String?,
      category: FruitCategory.values.firstWhere(
        (e) => e.name == json['category'],
        orElse: () => FruitCategory.deciduous,
      ),
      originType: OriginType.values.firstWhere(
        (e) => e.name == json['origin_type'],
        orElse: () => OriginType.nationwide,
      ),
      maturityDays: json['maturity_days'] as int? ?? 120,
      sunlight: Sunlight.values.firstWhere(
        (e) => e.name == json['sunlight'],
        orElse: () => Sunlight.fullSun,
      ),
      minTemp: json['min_temp'] as int? ?? -10,
      maxTemp: json['max_temp'] as int? ?? 40,
      optimalTempMin: json['optimal_temp_min'] as int? ?? 15,
      optimalTempMax: json['optimal_temp_max'] as int? ?? 30,
      soilType: json['soil_type'] as String? ?? '壤土',
      phMin: (json['ph_min'] as num?)?.toDouble() ?? 6.0,
      phMax: (json['ph_max'] as num?)?.toDouble() ?? 7.5,
      drainage: Drainage.values.firstWhere(
        (e) => e.name == json['drainage'],
        orElse: () => Drainage.good,
      ),
      fertilizer: json['fertilizer'] is String
          ? jsonDecode(json['fertilizer'] as String)
          : (json['fertilizer'] as Map<String, dynamic>?) ?? {},
      plantingNotes: json['planting_notes'] is String
          ? jsonDecode(json['planting_notes'] as String)
          : (json['planting_notes'] as Map<String, dynamic>?) ?? {},
      nutritionalValue: json['nutritional_value'] is String
          ? jsonDecode(json['nutritional_value'] as String)
          : (json['nutritional_value'] as Map<String, dynamic>?) ?? {},
      benefits: json['benefits'] as String? ?? '',
      contraindications: json['contraindications'] as String? ?? '',
      taste: json['taste'] as String? ?? '',
      priceRange: json['price_range'] as String? ?? '',
      climateZones: (json['climate_zones'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      ripeningMonths: (json['ripening_months'] as List<dynamic>?)
              ?.map((e) => e as int)
              .toList() ??
          [],
      plantingMonths: (json['planting_months'] as List<dynamic>?)
              ?.map((e) => e as int)
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'emoji': emoji,
      'alias': alias,
      'category': category.name,
      'origin_type': originType.name,
      'maturity_days': maturityDays,
      'sunlight': sunlight.name,
      'min_temp': minTemp,
      'max_temp': maxTemp,
      'optimal_temp_min': optimalTempMin,
      'optimal_temp_max': optimalTempMax,
      'soil_type': soilType,
      'ph_min': phMin,
      'ph_max': phMax,
      'drainage': drainage.name,
      'fertilizer': jsonEncode(fertilizer),
      'planting_notes': jsonEncode(plantingNotes),
      'nutritional_value': jsonEncode(nutritionalValue),
      'benefits': benefits,
      'contraindications': contraindications,
      'taste': taste,
      'price_range': priceRange,
      'climate_zones': jsonEncode(climateZones),
      'ripening_months': jsonEncode(ripeningMonths),
      'planting_months': jsonEncode(plantingMonths),
    };
  }

  bool isRipeningInMonth(int month) => ripeningMonths.contains(month);
  bool isPlantingInMonth(int month) => plantingMonths.contains(month);
  bool isSuitableForClimate(String zoneCode) => climateZones.contains(zoneCode);
}
