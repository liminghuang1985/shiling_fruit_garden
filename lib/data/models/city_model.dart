/// 城市数据模型
class CityModel {
  final String id;
  final String name;
  final String nameShort;
  final String province;
  final String climateZoneCode;
  final String? pinyinStart;

  const CityModel({
    required this.id,
    required this.name,
    required this.nameShort,
    required this.province,
    required this.climateZoneCode,
    this.pinyinStart,
  });

  factory CityModel.fromJson(Map<String, dynamic> json) {
    return CityModel(
      id: json['id'] as String,
      name: json['name'] as String,
      nameShort: json['name_short'] as String? ?? '${json['name']}市',
      province: json['province'] as String,
      climateZoneCode: json['climate_zone_code'] as String,
      pinyinStart: json['pinyin_start'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'name_short': nameShort,
      'province': province,
      'climate_zone_code': climateZoneCode,
      'pinyin_start': pinyinStart,
    };
  }
}
