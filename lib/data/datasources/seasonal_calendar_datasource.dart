import 'dart:convert';
import 'package:flutter/services.dart';

/// 节气数据源（从 assets JSON 加载）
class SeasonalCalendarLocalDatasource {
  List<Map<String, dynamic>>? _cache;

  static Future<void> seedIfNeeded() async {
    // 节气数据目前通过 Dart 常量提供，无需 DB seed
  }

  Future<List<Map<String, dynamic>>> _loadCalendar() async {
    if (_cache != null) return _cache!;
    final jsonString = await rootBundle.loadString('assets/data/seasonal_calendar.json');
    final List<dynamic> data = json.decode(jsonString);
    _cache = data.cast<Map<String, dynamic>>();
    return _cache!;
  }

  /// 获取指定月份和气候区的节气列表
  Future<List<String>> getSolarTerms(int month, String climateZoneCode) async {
    final calendar = await _loadCalendar();
    try {
      final record = calendar.firstWhere(
        (r) => r['month'] == month && r['climate_zone_code'] == climateZoneCode,
      );
      final terms = record['solar_terms'];
      if (terms is List) return terms.cast<String>();
    } catch (_) {}
    return [];
  }

  /// 获取指定月份的所有节气（不区分气候区）
  Future<List<String>> getSolarTermsForMonth(int month) async {
    final calendar = await _loadCalendar();
    try {
      final record = calendar.firstWhere(
        (r) => r['month'] == month && r['climate_zone_code'] == 'temperate',
      );
      final terms = record['solar_terms'];
      if (terms is List) return terms.cast<String>();
    } catch (_) {}
    return [];
  }

  void clearCache() => _cache = null;
}
