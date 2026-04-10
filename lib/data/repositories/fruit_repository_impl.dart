import '../models/fruit_model.dart';
import '../../domain/entities/fruit_entity.dart';
import '../../domain/repositories/fruit_repository.dart';
import '../datasources/fruit_local_datasource.dart';

/// 水果仓储实现（基于本地 SQLite 数据源）
class FruitRepositoryImpl implements FruitRepository {
  final FruitLocalDatasource _datasource;

  FruitRepositoryImpl(this._datasource);

  FruitEntity _toEntity(FruitModel model) {
    return FruitEntity(
      id: model.id,
      name: model.name,
      emoji: model.emoji,
      alias: model.alias,
      category: model.category,
      originType: model.originType,
      maturityDays: model.maturityDays,
      sunlight: model.sunlight,
      minTemp: model.minTemp,
      maxTemp: model.maxTemp,
      optimalTempMin: model.optimalTempMin,
      optimalTempMax: model.optimalTempMax,
      soilType: model.soilType,
      phMin: model.phMin,
      phMax: model.phMax,
      drainage: model.drainage,
      fertilizer: model.fertilizer,
      plantingNotes: model.plantingNotes,
      nutritionalValue: model.nutritionalValue,
      benefits: model.benefits,
      contraindications: model.contraindications,
      taste: model.taste,
      priceRange: model.priceRange,
      climateZones: model.climateZones,
      ripeningMonths: model.ripeningMonths,
      plantingMonths: model.plantingMonths,
    );
  }

  @override
  Future<List<FruitEntity>> getAllFruits() async {
    final models = await _datasource.getAllFruits();
    return models.map(_toEntity).toList();
  }

  @override
  Future<FruitEntity?> getFruitById(String id) async {
    final model = await _datasource.getFruitById(id);
    return model != null ? _toEntity(model) : null;
  }

  @override
  Future<List<FruitEntity>> getFruitsByCategory(String category) async {
    final models = await _datasource.getFruitsByCategory(category);
    return models.map(_toEntity).toList();
  }

  @override
  Future<List<FruitEntity>> getFruitsByClimateZone(String zoneCode) async {
    final models = await _datasource.getFruitsByClimateZone(zoneCode);
    return models.map(_toEntity).toList();
  }

  @override
  Future<List<FruitEntity>> getFruitsRipeningInMonth(int month, String? climateZone) async {
    final models = await _datasource.getFruitsRipeningInMonth(month, climateZone);
    return models.map(_toEntity).toList();
  }

  @override
  Future<List<FruitEntity>> getFruitsPlantingInMonth(int month, String? climateZone) async {
    final models = await _datasource.getFruitsPlantingInMonth(month, climateZone);
    return models.map(_toEntity).toList();
  }

  @override
  Future<List<FruitEntity>> searchFruits(String query) async {
    final models = await _datasource.searchFruits(query);
    return models.map(_toEntity).toList();
  }
}
