import '../../domain/entities/harvest_record_entity.dart';

/// 用户采收记录数据模型（SQLite 行映射）
class HarvestRecord {
  final String id;
  final String fruitId;
  final DateTime harvestDate;
  final String? notes;

  const HarvestRecord({
    required this.id,
    required this.fruitId,
    required this.harvestDate,
    this.notes,
  });

  factory HarvestRecord.fromJson(Map<String, dynamic> json) {
    return HarvestRecord(
      id: json['id'] as String,
      fruitId: json['fruit_id'] as String,
      harvestDate: DateTime.parse(json['harvest_date'] as String),
      notes: json['notes'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'fruit_id': fruitId,
        'harvest_date': harvestDate.toIso8601String(),
        'notes': notes,
      };

  /// 转换为领域实体
  HarvestRecordEntity toEntity() {
    return HarvestRecordEntity(
      id: id,
      fruitId: fruitId,
      harvestDate: harvestDate,
      notes: notes,
    );
  }

  /// 从领域实体创建
  factory HarvestRecord.fromEntity(HarvestRecordEntity entity) {
    return HarvestRecord(
      id: entity.id,
      fruitId: entity.fruitId,
      harvestDate: entity.harvestDate,
      notes: entity.notes,
    );
  }
}
