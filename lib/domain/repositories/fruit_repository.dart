import '../entities/fruit_entity.dart';

/// 水果仓储抽象接口
abstract class FruitRepository {
  Future<List<FruitEntity>> getAllFruits();
  Future<FruitEntity?> getFruitById(String id);
  Future<List<FruitEntity>> getFruitsByCategory(String category);
  Future<List<FruitEntity>> getFruitsByClimateZone(String zoneCode);
  Future<List<FruitEntity>> getFruitsRipeningInMonth(int month, String? climateZone);
  Future<List<FruitEntity>> getFruitsPlantingInMonth(int month, String? climateZone);
  Future<List<FruitEntity>> searchFruits(String query);
}
