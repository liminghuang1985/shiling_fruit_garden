/// 用户采收记录领域实体（纯 Dart，无 Flutter/SQL 依赖）
class HarvestRecordEntity {
  final String id;
  final String fruitId;
  final DateTime harvestDate;
  final String? notes;

  const HarvestRecordEntity({
    required this.id,
    required this.fruitId,
    required this.harvestDate,
    this.notes,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'fruit_id': fruitId,
        'harvest_date': harvestDate.toIso8601String(),
        'notes': notes,
      };

  factory HarvestRecordEntity.fromJson(Map<String, dynamic> json) {
    return HarvestRecordEntity(
      id: json['id'] as String,
      fruitId: json['fruit_id'] as String,
      harvestDate: DateTime.parse(json['harvest_date'] as String),
      notes: json['notes'] as String?,
    );
  }
}
