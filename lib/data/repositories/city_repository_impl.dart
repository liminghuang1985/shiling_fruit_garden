import '../models/city_model.dart';
import '../models/climate_zone_model.dart';
import '../../domain/entities/city_entity.dart';
import '../../domain/entities/climate_zone_entity.dart';
import '../../domain/repositories/city_repository.dart';
import '../datasources/city_local_datasource.dart';

/// 城市仓储实现（基于本地 SQLite 数据源）
class CityRepositoryImpl implements CityRepository {
  final CityLocalDatasource _datasource;

  CityRepositoryImpl(this._datasource);

  CityEntity _toCityEntity(CityModel model) {
    return CityEntity(
      id: model.id,
      name: model.name,
      nameShort: model.nameShort,
      province: model.province,
      climateZoneCode: model.climateZoneCode,
      pinyinStart: model.pinyinStart,
    );
  }

  ClimateZoneEntity _toClimateEntity(ClimateZoneModel model) {
    return ClimateZoneEntity(
      code: model.code,
      name: model.name,
      nameShort: model.nameShort,
      provinces: model.provinces,
      description: model.description,
    );
  }

  @override
  Future<List<CityEntity>> getAllCities() async {
    final models = await _datasource.getAllCities();
    return models.map(_toCityEntity).toList();
  }

  @override
  Future<List<ClimateZoneEntity>> getAllClimateZones() async {
    final models = await _datasource.getAllClimateZones();
    return models.map(_toClimateEntity).toList();
  }

  @override
  Future<CityEntity?> getCityById(String id) async {
    final model = await _datasource.getCityById(id);
    return model != null ? _toCityEntity(model) : null;
  }

  @override
  Future<ClimateZoneEntity?> getClimateZoneByCode(String code) async {
    final model = await _datasource.getClimateZoneByCode(code);
    return model != null ? _toClimateEntity(model) : null;
  }

  @override
  Future<List<CityEntity>> getCitiesByProvince(String province) async {
    final models = await _datasource.getCitiesByProvince(province);
    return models.map(_toCityEntity).toList();
  }

  @override
  Future<List<String>> getAllProvinces() async {
    return _datasource.getAllProvinces();
  }

  @override
  Future<List<CityEntity>> searchCities(String query) async {
    final models = await _datasource.searchCities(query);
    return models.map(_toCityEntity).toList();
  }
}
