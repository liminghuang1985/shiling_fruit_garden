import 'package:flutter/foundation.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';

/// 数据库初始化与 Schema 管理
class DatabaseHelper {
  static Database? _database;
  static const String _dbName = 'shiling_fruit_garden.db';
  static const int _dbVersion = 2;

  /// 获取数据库实例（移动端用 sqflite，桌面端用 ffi）
  static Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  static Future<Database> _initDatabase() async {
    if (kIsWeb) {
      // Web 平台暂不支持本地 SQLite
      throw UnsupportedError('Web 平台暂不支持本地数据库');
    }

    // 桌面端使用 FFI
    if (defaultTargetPlatform == TargetPlatform.windows ||
        defaultTargetPlatform == TargetPlatform.macOS ||
        defaultTargetPlatform == TargetPlatform.linux) {
      sqfliteFfiInit();
      databaseFactory = databaseFactoryFfi;
    }

    final docsDir = await getApplicationDocumentsDirectory();
    final path = join(docsDir.path, _dbName);

    return await databaseFactory.openDatabase(
      path,
      options: OpenDatabaseOptions(
        version: _dbVersion,
        onCreate: _onCreate,
        onUpgrade: _onUpgrade,
      ),
    );
  }

  static Future<void> _onCreate(Database db, int version) async {
    // 气候区表
    await db.execute('''
      CREATE TABLE climate_zones (
        code TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        name_short TEXT,
        provinces TEXT,
        description TEXT
      )
    ''');

    // 水果主数据表
    await db.execute('''
      CREATE TABLE fruits (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        emoji TEXT,
        alias TEXT,
        category TEXT,
        origin_type TEXT,
        maturity_days INTEGER,
        sunlight TEXT,
        min_temp INTEGER,
        max_temp INTEGER,
        optimal_temp_min INTEGER,
        optimal_temp_max INTEGER,
        soil_type TEXT,
        ph_min REAL,
        ph_max REAL,
        drainage TEXT,
        fertilizer TEXT,
        planting_notes TEXT,
        nutritional_value TEXT,
        benefits TEXT,
        contraindications TEXT,
        taste TEXT,
        price_range TEXT,
        climate_zones TEXT DEFAULT '[]',
        ripening_months TEXT DEFAULT '[]',
        planting_months TEXT DEFAULT '[]',
        created_at INTEGER,
        updated_at INTEGER
      )
    ''');

    // 水果-气候区适配表
    await db.execute('''
      CREATE TABLE fruit_climate_zones (
        fruit_id TEXT,
        climate_zone_code TEXT,
        planting_note TEXT,
        PRIMARY KEY (fruit_id, climate_zone_code),
        FOREIGN KEY (fruit_id) REFERENCES fruits(id),
        FOREIGN KEY (climate_zone_code) REFERENCES climate_zones(code)
      )
    ''');

    // 水果成熟月份表
    await db.execute('''
      CREATE TABLE fruit_ripening_months (
        fruit_id TEXT,
        month INTEGER,
        is_peak INTEGER DEFAULT 0,
        description TEXT,
        PRIMARY KEY (fruit_id, month),
        FOREIGN KEY (fruit_id) REFERENCES fruits(id)
      )
    ''');

    // 水果种植月份表
    await db.execute('''
      CREATE TABLE fruit_planting_months (
        fruit_id TEXT,
        month INTEGER,
        climate_zone_code TEXT,
        method TEXT,
        note TEXT,
        PRIMARY KEY (fruit_id, month, climate_zone_code),
        FOREIGN KEY (fruit_id) REFERENCES fruits(id)
      )
    ''');

    // 城市-气候区映射表
    await db.execute('''
      CREATE TABLE cities (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        name_short TEXT,
        province TEXT,
        climate_zone_code TEXT,
        FOREIGN KEY (climate_zone_code) REFERENCES climate_zones(code)
      )
    ''');

    // 月度时令日历表
    await db.execute('''
      CREATE TABLE seasonal_calendar (
        month INTEGER,
        climate_zone_code TEXT,
        ripening_fruit_ids TEXT,
        planting_fruit_ids TEXT,
        solar_terms TEXT,
        PRIMARY KEY (month, climate_zone_code),
        FOREIGN KEY (climate_zone_code) REFERENCES climate_zones(code)
      )
    ''');

    // 用户果园表（本地）
    await db.execute('''
      CREATE TABLE user_garden (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        fruit_id TEXT,
        fruit_name TEXT,
        fruit_emoji TEXT,
        status TEXT DEFAULT 'planted',
        planted_date INTEGER,
        harvested_date INTEGER,
        harvest_weight_kg REAL,
        rating INTEGER,
        note TEXT,
        created_at INTEGER,
        updated_at INTEGER
      )
    ''');

    // 用户收藏表
    await db.execute('''
      CREATE TABLE user_favorites (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        fruit_id TEXT UNIQUE,
        created_at INTEGER
      )
    ''');

    // Seed 版本信息表（统一管理各 JSON 数据版本）
    await db.execute('''
      CREATE TABLE seed_info (
        key TEXT PRIMARY KEY,
        version INTEGER NOT NULL
      )
    ''');

    // 创建索引
    await db.execute(
        'CREATE INDEX idx_fruits_category ON fruits(category)');
    await db.execute(
        'CREATE INDEX idx_cities_climate ON cities(climate_zone_code)');
    await db.execute(
        'CREATE INDEX idx_cities_province ON cities(province)');
    await db.execute(
        'CREATE INDEX idx_user_garden_status ON user_garden(status)');
  }

  static Future<void> _onUpgrade(
      Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      // v2: 给 fruits 表新增气候区、成熟月份、种植月份三个字段
      await db.execute(
          "ALTER TABLE fruits ADD COLUMN climate_zones TEXT DEFAULT '[]'");
      await db.execute(
          "ALTER TABLE fruits ADD COLUMN ripening_months TEXT DEFAULT '[]'");
      await db.execute(
          "ALTER TABLE fruits ADD COLUMN planting_months TEXT DEFAULT '[]'");
    }
  }

  /// 关闭数据库
  static Future<void> close() async {
    if (_database != null) {
      await _database!.close();
      _database = null;
    }
  }
}
