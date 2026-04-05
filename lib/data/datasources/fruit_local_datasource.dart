import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:sqflite/sqflite.dart';
import '../models/fruit_model.dart';
import '../../core/constants/enums.dart';
import 'database_helper.dart';

/// 水果数据源（从 assets JSON 初始化 + SQLite 查询）
class FruitLocalDatasource {
  List<FruitModel>? _cache;

  /// 初始化数据库（从 assets 加载 JSON 写入 SQLite）
  static Future<void> seedDatabase() async {
    final db = await DatabaseHelper.database;
    final count =
        Sqflite.firstIntValue(await db.rawQuery('SELECT COUNT(*) FROM fruits'));
    if (count != null && count > 0) return;

    final fruitsJson = await rootBundle.loadString('assets/data/fruits.json');
    final List<dynamic> fruitsData = json.decode(fruitsJson);

    final batch = db.batch();
    for (final fruit in fruitsData) {
      final model = FruitModel.fromJson(fruit as Map<String, dynamic>);
      batch.insert('fruits', _fruitToMap(model));
    }
    await batch.commit(noResult: true);
  }

  static Map<String, dynamic> _fruitToMap(FruitModel fruit) {
    return {
      'id': fruit.id,
      'name': fruit.name,
      'emoji': fruit.emoji,
      'alias': fruit.alias,
      'category': fruit.category.name,
      'origin_type': fruit.originType.name,
      'maturity_days': fruit.maturityDays,
      'sunlight': fruit.sunlight.name,
      'min_temp': fruit.minTemp,
      'max_temp': fruit.maxTemp,
      'optimal_temp_min': fruit.optimalTempMin,
      'optimal_temp_max': fruit.optimalTempMax,
      'soil_type': fruit.soilType,
      'ph_min': fruit.phMin,
      'ph_max': fruit.phMax,
      'drainage': fruit.drainage.name,
      'fertilizer': jsonEncode(fruit.fertilizer),
      'planting_notes': jsonEncode(fruit.plantingNotes),
      'nutritional_value': jsonEncode(fruit.nutritionalValue),
      'benefits': fruit.benefits,
      'contraindications': fruit.contraindications,
      'taste': fruit.taste,
      'price_range': fruit.priceRange,
      'created_at': DateTime.now().millisecondsSinceEpoch,
      'updated_at': DateTime.now().millisecondsSinceEpoch,
    };
  }

  Future<List<FruitModel>> getAllFruits() async {
    if (_cache != null) return _cache!;
    await seedDatabase();
    final db = await DatabaseHelper.database;
    final maps = await db.query('fruits');
    _cache = maps.map((m) => _mapToFruit(m)).toList();
    return _cache!;
  }

  Future<FruitModel?> getFruitById(String id) async {
    final fruits = await getAllFruits();
    try {
      return fruits.firstWhere((f) => f.id == id);
    } catch (_) {
      return null;
    }
  }

  Future<List<FruitModel>> getFruitsByCategory(String category) async {
    final fruits = await getAllFruits();
    return fruits.where((f) => f.category.name == category).toList();
  }

  Future<List<FruitModel>> getFruitsByClimateZone(String zoneCode) async {
    final fruits = await getAllFruits();
    return fruits.where((f) => f.climateZones.contains(zoneCode)).toList();
  }

  Future<List<FruitModel>> getFruitsRipeningInMonth(
      int month, String? climateZone) async {
    final fruits = await getAllFruits();
    return fruits.where((f) {
      final matchMonth = f.ripeningMonths.contains(month);
      final matchZone =
          climateZone == null || f.climateZones.contains(climateZone);
      return matchMonth && matchZone;
    }).toList();
  }

  Future<List<FruitModel>> getFruitsPlantingInMonth(
      int month, String? climateZone) async {
    final fruits = await getAllFruits();
    return fruits.where((f) {
      final matchMonth = f.plantingMonths.contains(month);
      final matchZone =
          climateZone == null || f.climateZones.contains(climateZone);
      return matchMonth && matchZone;
    }).toList();
  }

  Future<List<FruitModel>> searchFruits(String query) async {
    final fruits = await getAllFruits();
    final q = query.toLowerCase();
    return fruits
        .where((f) =>
            f.name.toLowerCase().contains(q) ||
            (f.alias?.toLowerCase().contains(q) ?? false))
        .toList();
  }

  FruitModel _mapToFruit(Map<String, dynamic> map) {
    return FruitModel(
      id: map['id'] as String,
      name: map['name'] as String,
      emoji: map['emoji'] as String? ?? '🍓',
      alias: map['alias'] as String?,
      category: _fruitCategoryFromName(map['category'] as String?),
      originType: _originTypeFromName(map['origin_type'] as String?),
      maturityDays: map['maturity_days'] as int? ?? 120,
      sunlight: _sunlightFromName(map['sunlight'] as String?),
      minTemp: map['min_temp'] as int? ?? -10,
      maxTemp: map['max_temp'] as int? ?? 40,
      optimalTempMin: map['optimal_temp_min'] as int? ?? 15,
      optimalTempMax: map['optimal_temp_max'] as int? ?? 30,
      soilType: map['soil_type'] as String? ?? '壤土',
      phMin: (map['ph_min'] as num?)?.toDouble() ?? 6.0,
      phMax: (map['ph_max'] as num?)?.toDouble() ?? 7.5,
      drainage: _drainageFromName(map['drainage'] as String?),
      fertilizer: _parseJson(map['fertilizer']),
      plantingNotes: _parseJson(map['planting_notes']),
      nutritionalValue: _parseJson(map['nutritional_value']),
      benefits: map['benefits'] as String? ?? '',
      contraindications: map['contraindications'] as String? ?? '',
      taste: map['taste'] as String? ?? '',
      priceRange: map['price_range'] as String? ?? '',
      climateZones: _parseStringList(map['climate_zones']),
      ripeningMonths: _parseIntList(map['ripening_months']),
      plantingMonths: _parseIntList(map['planting_months']),
    );
  }

  FruitCategory _fruitCategoryFromName(String? name) {
    return FruitCategory.values.firstWhere(
      (e) => e.name == name,
      orElse: () => FruitCategory.deciduous,
    );
  }

  OriginType _originTypeFromName(String? name) {
    return OriginType.values.firstWhere(
      (e) => e.name == name,
      orElse: () => OriginType.nationwide,
    );
  }

  Sunlight _sunlightFromName(String? name) {
    return Sunlight.values.firstWhere(
      (e) => e.name == name,
      orElse: () => Sunlight.fullSun,
    );
  }

  Drainage _drainageFromName(String? name) {
    return Drainage.values.firstWhere(
      (e) => e.name == name,
      orElse: () => Drainage.good,
    );
  }

  Map<String, dynamic> _parseJson(dynamic val) {
    if (val == null) return {};
    if (val is Map) return Map<String, dynamic>.from(val);
    if (val is String) {
      try {
        return Map<String, dynamic>.from(jsonDecode(val));
      } catch (_) {}
    }
    return {};
  }

  List<String> _parseStringList(dynamic val) {
    if (val == null) return [];
    if (val is List) return val.cast<String>();
    if (val is String) {
      try {
        final decoded = jsonDecode(val);
        if (decoded is List) return List<String>.from(decoded);
      } catch (_) {}
    }
    return [];
  }

  List<int> _parseIntList(dynamic val) {
    if (val == null) return [];
    if (val is List) return val.cast<int>();
    if (val is String) {
      try {
        final decoded = jsonDecode(val);
        if (decoded is List) return List<int>.from(decoded);
      } catch (_) {}
    }
    return [];
  }

  void clearCache() => _cache = null;
}
