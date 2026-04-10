import '../entities/city_entity.dart';
import '../entities/climate_zone_entity.dart';

/// 城市仓储抽象接口
abstract class CityRepository {
  Future<List<CityEntity>> getAllCities();
  Future<List<ClimateZoneEntity>> getAllClimateZones();
  Future<CityEntity?> getCityById(String id);
  Future<ClimateZoneEntity?> getClimateZoneByCode(String code);
  Future<List<CityEntity>> getCitiesByProvince(String province);
  Future<List<String>> getAllProvinces();
  Future<List<CityEntity>> searchCities(String query);
}
