import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:sqflite/sqflite.dart';
import 'database_helper.dart';

/// 数据 seed 版本管理
///
/// 所有预置数据（fruits.json, cities.json, climate_zones.json）的版本
/// 统一记录在 seed_info 表中，启动时只对版本变化的表重新 seed。
///
/// 使用 INSERT OR IGNORE 保证幂等：已存在的记录不会被覆盖。
class SeedManager {
  /// 已在本次会话中执行过 seed，跳过后续调用
  static bool _seeded = false;

  /// 各数据文件的版本号（修改此值将触发对应表的重新 seed）
  static const int _fruitsVersion = 1;
  static const int _citiesVersion  = 1;
  static const int _zonesVersion  = 1; // climate_zones 与 cities 同版本

  /// seed_info 表中的 key 名
  static const String _keyFruits = 'fruits';
  static const String _keyZones  = 'climate_zones';
  static const String _keyCities = 'cities';

  /// 主入口：启动时调用一次即可完成所有数据的 seed
  static Future<void> seedIfNeeded() async {
    if (_seeded) return;
    _seeded = true;

    final db = await DatabaseHelper.database;

    // fruits
    await _seedFruits(db);
    // climate_zones
    await _seedClimateZones(db);
    // cities
    await _seedCities(db);
  }

  // ────────────────────────────────────────────
  //  fruits
  // ────────────────────────────────────────────
  static Future<void> _seedFruits(Database db) async {
    final stored = await _getStoredVersion(db, _keyFruits);
    if (stored >= _fruitsVersion) return;

    final fruitsJson = await rootBundle.loadString('assets/data/fruits.json');
    final List<dynamic> fruitsData = json.decode(fruitsJson);
    final now = DateTime.now().millisecondsSinceEpoch;

    final batch = db.batch();
    for (final fruit in fruitsData) {
      final f = fruit as Map<String, dynamic>;
      batch.insert(
        'fruits',
        {
          'id':                    f['id'],
          'name':                  f['name'],
          'emoji':                  f['emoji'],
          'alias':                  f['alias'],
          'category':              f['category'],
          'origin_type':           f['origin_type'],
          'maturity_days':         f['maturity_days'],
          'sunlight':              f['sunlight'],
          'min_temp':               f['min_temp'],
          'max_temp':               f['max_temp'],
          'optimal_temp_min':       f['optimal_temp_min'],
          'optimal_temp_max':       f['optimal_temp_max'],
          'soil_type':             f['soil_type'],
          'ph_min':                f['ph_min'],
          'ph_max':                f['ph_max'],
          'drainage':              f['drainage'],
          'fertilizer':            jsonEncode(f['fertilizer']),
          'planting_notes':        jsonEncode(f['planting_notes']),
          'nutritional_value':      jsonEncode(f['nutritional_value']),
          'benefits':              f['benefits'],
          'contraindications':     f['contraindications'],
          'taste':                 f['taste'],
          'price_range':           f['price_range'],
          'created_at':            now,
          'updated_at':            now,
        },
        conflictAlgorithm: ConflictAlgorithm.ignore,
      );
    }
    await batch.commit(noResult: true);
    await _setVersion(db, _keyFruits, _fruitsVersion);
  }

  // ────────────────────────────────────────────
  //  climate_zones
  // ────────────────────────────────────────────
  static Future<void> _seedClimateZones(Database db) async {
    final stored = await _getStoredVersion(db, _keyZones);
    if (stored >= _zonesVersion) return;

    final zonesJson = await rootBundle.loadString('assets/data/climate_zones.json');
    final List<dynamic> zonesData = json.decode(zonesJson);

    final batch = db.batch();
    for (final zone in zonesData) {
      final z = zone as Map<String, dynamic>;
      batch.insert(
        'climate_zones',
        {
          'code':        z['code'],
          'name':        z['name'],
          'name_short':  z['name_short'],
          'provinces':   jsonEncode(z['provinces']),
          'description': z['description'],
        },
        conflictAlgorithm: ConflictAlgorithm.ignore,
      );
    }
    await batch.commit(noResult: true);
    await _setVersion(db, _keyZones, _zonesVersion);
  }

  // ────────────────────────────────────────────
  //  cities
  // ────────────────────────────────────────────
  static Future<void> _seedCities(Database db) async {
    final stored = await _getStoredVersion(db, _keyCities);
    if (stored >= _citiesVersion) return;

    final citiesJson = await rootBundle.loadString('assets/data/cities.json');
    final List<dynamic> citiesData = json.decode(citiesJson);

    final batch = db.batch();
    for (final city in citiesData) {
      final c = city as Map<String, dynamic>;
      batch.insert(
        'cities',
        {
          'id':                c['id'],
          'name':              c['name'],
          'name_short':        c['name_short'],
          'province':          c['province'],
          'climate_zone_code':c['climate_zone_code'],
        },
        conflictAlgorithm: ConflictAlgorithm.ignore,
      );
    }
    await batch.commit(noResult: true);
    await _setVersion(db, _keyCities, _citiesVersion);
  }

  // ────────────────────────────────────────────
  //  helpers
  // ────────────────────────────────────────────
  static Future<int> _getStoredVersion(Database db, String key) async {
    final result = await db.query(
      'seed_info',
      columns: ['version'],
      where: 'key = ?',
      whereArgs: [key],
    );
    if (result.isEmpty) return 0;
    return result.first['version'] as int;
  }

  static Future<void> _setVersion(Database db, String key, int version) async {
    await db.insert(
      'seed_info',
      {'key': key, 'version': version},
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }
}
