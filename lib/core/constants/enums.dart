/// 水果分类
enum FruitCategory {
  deciduous('落叶果树'),
  evergreen('常绿果树'),
  tropical('热带果树'),
  melon('瓜果类'),
  berry('浆果类');

  final String label;
  const FruitCategory(this.label);
}

/// 光照需求
enum Sunlight {
  fullSun('喜阳'),
  shadeTolerant('耐阴'),
  halfShade('喜半阴');

  final String label;
  const Sunlight(this.label);
}

/// 土壤排水要求
enum Drainage {
  good('良好'),
  average('一般'),
  tolerant('耐涝');

  final String label;
  const Drainage(this.label);
}

/// 气候区代码
enum ClimateZone {
  coldTemperate('cold_temperate', '寒温带', '东北北部'),
  temperate('temperate', '温带', '华北/西北'),
  subtropical('subtropical', '亚热带', '华中/华东'),
  tropical('tropical', '热带', '华南/海南'),
  plateau('plateau', '高原', '西南/西藏'),
  arid('arid', '干旱区', '新疆');

  final String code;
  final String name;
  final String region;
  const ClimateZone(this.code, this.name, this.region);
}

/// 产地类型
enum OriginType {
  north('北方'),
  south('南方'),
  nationwide('全国');

  final String label;
  const OriginType(this.label);
}
