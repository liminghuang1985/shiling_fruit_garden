/// 气候区数据模型
class ClimateZoneModel {
  final String code;
  final String name;
  final String nameShort;
  final List<String> provinces;
  final String description;

  const ClimateZoneModel({
    required this.code,
    required this.name,
    required this.nameShort,
    required this.provinces,
    required this.description,
  });

  factory ClimateZoneModel.fromJson(Map<String, dynamic> json) {
    return ClimateZoneModel(
      code: json['code'] as String,
      name: json['name'] as String,
      nameShort: json['name_short'] as String? ?? '',
      provinces: (json['provinces'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      description: json['description'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'code': code,
      'name': name,
      'name_short': nameShort,
      'provinces': provinces,
      'description': description,
    };
  }
}
