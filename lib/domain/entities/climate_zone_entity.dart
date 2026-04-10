/// 气候区领域实体（纯 Dart，无 Flutter/SQL 依赖）
class ClimateZoneEntity {
  final String code;
  final String name;
  final String nameShort;
  final List<String> provinces;
  final String description;

  const ClimateZoneEntity({
    required this.code,
    required this.name,
    required this.nameShort,
    required this.provinces,
    required this.description,
  });
}
