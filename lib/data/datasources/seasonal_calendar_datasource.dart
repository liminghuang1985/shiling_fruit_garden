import 'dart:convert';
import 'database_helper.dart';
import 'seed_manager.dart';

/// 节气数据源（从 DB 查询，SeedManager 负责初始化 DB 数据）
class SeasonalCalendarLocalDatasource {
  /// 确保 DB 数据已初始化
  static Future<void> seedIfNeeded() async {
    await SeedManager.seedIfNeeded();
  }

  /// 从 DB 获取指定月份和气候区的节气列表
  Future<List<String>> getSolarTerms(int month, String climateZoneCode) async {
    await seedIfNeeded();
    final db = await DatabaseHelper.database;
    final result = await db.query(
      'seasonal_calendar',
      where: 'month = ? AND climate_zone_code = ?',
      whereArgs: [month, climateZoneCode],
      limit: 1,
    );
    if (result.isEmpty) return [];
    final terms = result.first['solar_terms'];
    if (terms == null) return [];
    try {
      final decoded = jsonDecode(terms as String);
      if (decoded is List) return List<String>.from(decoded);
    } catch (_) {}
    return [];
  }

  /// 获取指定月份的所有节气（不区分气候区，默认用 temperate）
  Future<List<String>> getSolarTermsForMonth(int month) async {
    return getSolarTerms(month, 'temperate');
  }

  void clearCache() {}
}
