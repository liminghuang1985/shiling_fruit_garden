import '../../core/constants/enums.dart';

/// 水果领域实体（纯 Dart，无 Flutter/SQL 依赖）
class FruitEntity {
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

  const FruitEntity({
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

  bool isRipeningInMonth(int month) => ripeningMonths.contains(month);
  bool isPlantingInMonth(int month) => plantingMonths.contains(month);
  bool isSuitableForClimate(String zoneCode) => climateZones.contains(zoneCode);
}
