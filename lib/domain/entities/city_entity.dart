/// 城市领域实体（纯 Dart，无 Flutter/SQL 依赖）
class CityEntity {
  final String id;
  final String name;
  final String nameShort;
  final String province;
  final String climateZoneCode;
  final String? pinyinStart;

  const CityEntity({
    required this.id,
    required this.name,
    required this.nameShort,
    required this.province,
    required this.climateZoneCode,
    this.pinyinStart,
  });
}
