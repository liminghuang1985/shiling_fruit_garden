import '../models/city_model.dart';
import '../models/climate_zone_model.dart';
import 'seed_manager.dart';

/// 城市和气候区数据源
class CityLocalDatasource {
  List<CityModel>? _cities;
  List<ClimateZoneModel>? _climateZones;

  /// 触发统一 seed（幂等，由 SeedManager 保证只在必要时执行）
  static Future<void> seedDatabase() async {
    await SeedManager.seedIfNeeded();
  }

  Future<List<CityModel>> getAllCities() async {
    if (_cities != null) return _cities!;
    await seedDatabase();
    final db = await DatabaseHelper.database;
    final maps = await db.query('cities');
    _cities = maps.map((m) => CityModel.fromJson(m)).toList();
    return _cities!;
  }

  Future<List<ClimateZoneModel>> getAllClimateZones() async {
    if (_climateZones != null) return _climateZones!;
    await seedDatabase();
    final db = await DatabaseHelper.database;
    final maps = await db.query('climate_zones');
    _climateZones = maps.map((m) => ClimateZoneModel.fromJson(m)).toList();
    return _climateZones!;
  }

  Future<CityModel?> getCityById(String id) async {
    final cities = await getAllCities();
    try {
      return cities.firstWhere((c) => c.id == id);
    } catch (_) {
      return null;
    }
  }

  Future<ClimateZoneModel?> getClimateZoneByCode(String code) async {
    final zones = await getAllClimateZones();
    try {
      return zones.firstWhere((z) => z.code == code);
    } catch (_) {
      return null;
    }
  }

  /// 按省份获取城市列表
  Future<List<CityModel>> getCitiesByProvince(String province) async {
    final cities = await getAllCities();
    return cities.where((c) => c.province == province).toList();
  }

  /// 获取所有省份列表（去重）
  Future<List<String>> getAllProvinces() async {
    final cities = await getAllCities();
    final provinces = cities.map((c) => c.province).toSet().toList();
    provinces.sort();
    return provinces;
  }

  /// 搜索城市（拼音首字母或名称）
  Future<List<CityModel>> searchCities(String query) async {
    final cities = await getAllCities();
    final q = query.toLowerCase();
    return cities.where((c) {
      return c.name.contains(query) || c.pinyinStart?.toLowerCase().startsWith(q) == true;
    }).toList();
  }

  void clearCache() {
    _cities = null;
    _climateZones = null;
  }
}
