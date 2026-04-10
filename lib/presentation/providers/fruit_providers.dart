import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../domain/entities/fruit_entity.dart';
import '../../domain/entities/city_entity.dart';
import '../../domain/entities/harvest_record_entity.dart';
import '../../domain/repositories/fruit_repository.dart';
import '../../domain/repositories/city_repository.dart';
import '../../data/repositories/fruit_repository_impl.dart';
import '../../data/repositories/city_repository_impl.dart';
import '../../data/datasources/fruit_local_datasource.dart';
import '../../data/datasources/city_local_datasource.dart';
import '../../data/models/city_model.dart';
import '../../data/models/harvest_record_model.dart';
import '../../data/datasources/seasonal_calendar_datasource.dart';

// ─── Data Sources ───────────────────────────────────────────────
final fruitLocalDatasourceProvider = Provider((ref) => FruitLocalDatasource());
final cityLocalDatasourceProvider = Provider((ref) => CityLocalDatasource());

// ─── Repositories (接口 + 实现) ──────────────────────────────────
final fruitRepositoryProvider = Provider<FruitRepository>((ref) {
  return FruitRepositoryImpl(ref.watch(fruitLocalDatasourceProvider));
});

final cityRepositoryProvider = Provider<CityRepository>((ref) {
  return CityRepositoryImpl(ref.watch(cityLocalDatasourceProvider));
});

// ─── Current City ───────────────────────────────────────────────
class SelectedCityNotifier extends StateNotifier<CityEntity?> {
  SelectedCityNotifier() : super(null) {
    _loadSavedCity();
  }

  Future<void> _loadSavedCity() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final name = prefs.getString('selected_city_name');
      final id = prefs.getString('selected_city_id');
      final climate = prefs.getString('selected_climate_zone');
      if (name != null && id != null && climate != null) {
        state = CityEntity(
          id: id,
          name: name,
          nameShort: '',
          province: '',
          climateZoneCode: climate,
        );
      }
    } catch (_) {}
  }

  void setCity(CityEntity city) {
    state = city;
  }

  /// 从 CityModel 转换（兼容性方法，供 city_select_page 等直接使用 CityModel 的场景）
  void setCityFromCityModel(CityModel city) {
    state = CityEntity(
      id: city.id,
      name: city.name,
      nameShort: city.nameShort,
      province: city.province,
      climateZoneCode: city.climateZoneCode,
      pinyinStart: city.pinyinStart,
    );
  }

  void clearCity() {
    state = null;
  }
}

final selectedCityProvider = StateNotifierProvider<SelectedCityNotifier, CityEntity?>(
  (ref) => SelectedCityNotifier(),
);

// ─── Fruits ─────────────────────────────────────────────────────
final allFruitsProvider = FutureProvider<List<FruitEntity>>((ref) async {
  final repo = ref.watch(fruitRepositoryProvider);
  return repo.getAllFruits();
});

final currentMonthRipeningFruitsProvider = FutureProvider<List<FruitEntity>>((ref) async {
  final repo = ref.watch(fruitRepositoryProvider);
  final month = DateTime.now().month;
  return repo.getFruitsRipeningInMonth(month, null);
});

final currentMonthPlantingFruitsProvider = FutureProvider<List<FruitEntity>>((ref) async {
  final repo = ref.watch(fruitRepositoryProvider);
  final city = ref.watch(selectedCityProvider);
  final month = DateTime.now().month;
  return repo.getFruitsPlantingInMonth(month, city?.climateZoneCode);
});

final monthRipeningFruitsProvider = FutureProvider.family<List<FruitEntity>, int>((ref, month) async {
  final repo = ref.watch(fruitRepositoryProvider);
  return repo.getFruitsRipeningInMonth(month, null);
});

final monthPlantingFruitsProvider = FutureProvider.family<List<FruitEntity>, int>((ref, month) async {
  final repo = ref.watch(fruitRepositoryProvider);
  return repo.getFruitsPlantingInMonth(month, null);
});

// ─── User Favorites ─────────────────────────────────────────────
class UserFavoritesNotifier extends StateNotifier<Set<String>> {
  UserFavoritesNotifier() : super({}) {
    _loadFavorites();
  }

  Future<void> _loadFavorites() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final ids = prefs.getStringList('favorite_fruit_ids') ?? [];
      state = ids.toSet();
    } catch (_) {}
  }

  Future<void> toggleFavorite(String fruitId) async {
    try {
      final newState = Set<String>.from(state);
      if (newState.contains(fruitId)) {
        newState.remove(fruitId);
      } else {
        newState.add(fruitId);
      }
      state = newState;
      final prefs = await SharedPreferences.getInstance();
      await prefs.setStringList('favorite_fruit_ids', newState.toList());
    } catch (_) {}
  }
}

final userFavoritesProvider = StateNotifierProvider<UserFavoritesNotifier, Set<String>>(
  (ref) => UserFavoritesNotifier(),
);

// ─── Cities ─────────────────────────────────────────────────────
final allCitiesProvider = FutureProvider<List<CityEntity>>((ref) async {
  final repo = ref.watch(cityRepositoryProvider);
  return repo.getAllCities();
});

final allProvincesProvider = FutureProvider<List<String>>((ref) async {
  final repo = ref.watch(cityRepositoryProvider);
  return repo.getAllProvinces();
});

// ─── Seasonal Calendar / Solar Terms ───────────────────────────
final seasonalCalendarDatasourceProvider = Provider(
  (ref) => SeasonalCalendarLocalDatasource(),
);

/// 当前节气列表（按月份，不区分气候区）
final currentSolarTermsProvider = FutureProvider<List<String>>((ref) async {
  final ds = ref.watch(seasonalCalendarDatasourceProvider);
  final month = DateTime.now().month;
  return ds.getSolarTermsForMonth(month);
});

// ─── Garden Harvest Records ─────────────────────────────────────
class GardenRecordsNotifier extends StateNotifier<List<HarvestRecordEntity>> {
  GardenRecordsNotifier() : super([]) {
    _load();
  }

  Future<void> _load() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final json = prefs.getString('garden_records');
      if (json != null) {
        final List<dynamic> list = jsonDecode(json) as List<dynamic>;
        state = list.map((e) => HarvestRecordEntity.fromJson(e as Map<String, dynamic>)).toList();
      }
    } catch (_) {}
  }

  Future<void> _save() async {
    final prefs = await SharedPreferences.getInstance();
    final json = jsonEncode(state.map((r) => r.toJson()).toList());
    await prefs.setString('garden_records', json);
  }

  Future<void> addRecord(String fruitId, DateTime harvestDate, {String? notes}) async {
    final id = '${fruitId}_${harvestDate.millisecondsSinceEpoch}';
    state = [
      ...state,
      HarvestRecordEntity(id: id, fruitId: fruitId, harvestDate: harvestDate, notes: notes),
    ];
    await _save();
  }

  Future<void> removeRecord(String id) async {
    state = state.where((r) => r.id != id).toList();
    await _save();
  }

  List<HarvestRecordEntity> recordsForFruit(String fruitId) {
    return state.where((r) => r.fruitId == fruitId).toList();
  }
}

final gardenRecordsProvider =
    StateNotifierProvider<GardenRecordsNotifier, List<HarvestRecordEntity>>(
  (ref) => GardenRecordsNotifier(),
);
