/// 用户果园记录模型（本地SQLite）
class UserGardenModel {
  final int? id;
  final String fruitId;
  final String fruitName;
  final String fruitEmoji;
  final String status; // planted/harvested/removed
  final DateTime plantedDate;
  final DateTime? harvestedDate;
  final double? harvestWeightKg;
  final int? rating; // 1-5星
  final String? note;

  const UserGardenModel({
    this.id,
    required this.fruitId,
    required this.fruitName,
    required this.fruitEmoji,
    required this.status,
    required this.plantedDate,
    this.harvestedDate,
    this.harvestWeightKg,
    this.rating,
    this.note,
  });

  factory UserGardenModel.fromMap(Map<String, dynamic> map) {
    return UserGardenModel(
      id: map['id'] as int?,
      fruitId: map['fruit_id'] as String,
      fruitName: map['fruit_name'] as String,
      fruitEmoji: map['fruit_emoji'] as String? ?? '',
      status: map['status'] as String,
      plantedDate: DateTime.fromMillisecondsSinceEpoch(map['planted_date'] as int),
      harvestedDate: map['harvested_date'] != null
          ? DateTime.fromMillisecondsSinceEpoch(map['harvested_date'] as int)
          : null,
      harvestWeightKg: map['harvest_weight_kg'] != null
          ? (map['harvest_weight_kg'] as num).toDouble()
          : null,
      rating: map['rating'] as int?,
      note: map['note'] as String?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'fruit_id': fruitId,
      'fruit_name': fruitName,
      'fruit_emoji': fruitEmoji,
      'status': status,
      'planted_date': plantedDate.millisecondsSinceEpoch,
      'harvested_date': harvestedDate?.millisecondsSinceEpoch,
      'harvest_weight_kg': harvestWeightKg,
      'rating': rating,
      'note': note,
    };
  }

  UserGardenModel copyWith({
    int? id,
    String? fruitId,
    String? fruitName,
    String? fruitEmoji,
    String? status,
    DateTime? plantedDate,
    DateTime? harvestedDate,
    double? harvestWeightKg,
    int? rating,
    String? note,
  }) {
    return UserGardenModel(
      id: id ?? this.id,
      fruitId: fruitId ?? this.fruitId,
      fruitName: fruitName ?? this.fruitName,
      fruitEmoji: fruitEmoji ?? this.fruitEmoji,
      status: status ?? this.status,
      plantedDate: plantedDate ?? this.plantedDate,
      harvestedDate: harvestedDate ?? this.harvestedDate,
      harvestWeightKg: harvestWeightKg ?? this.harvestWeightKg,
      rating: rating ?? this.rating,
      note: note ?? this.note,
    );
  }
}
