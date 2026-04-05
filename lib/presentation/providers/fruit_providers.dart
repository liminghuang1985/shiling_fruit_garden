import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../data/datasources/fruit_local_datasource.dart';
import '../../data/datasources/city_local_datasource.dart';
import '../../data/models/fruit_model.dart';
import '../../data/models/city_model.dart';

// ─── Data Sources ───────────────────────────────────────────────
final fruitLocalDatasourceProvider = Provider((ref) => FruitLocalDatasource());
final cityLocalDatasourceProvider = Provider((ref) => CityLocalDatasource());

// ─── Current City ───────────────────────────────────────────────
class SelectedCityNotifier extends StateNotifier<CityModel?> {
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
        state = CityModel(
          id: id,
          name: name,
          nameShort: '',
          province: '',
          climateZoneCode: climate,
        );
      }
    } catch (_) {}
  }

  void setCity(CityModel city) {
    state = city;
  }

  void clearCity() {
    state = null;
  }
}

final selectedCityProvider = StateNotifierProvider<SelectedCityNotifier, CityModel?>(
  (ref) => SelectedCityNotifier(),
);

// ─── Fruits ─────────────────────────────────────────────────────
final allFruitsProvider = FutureProvider<List<FruitModel>>((ref) async {
  final ds = ref.watch(fruitLocalDatasourceProvider);
  return ds.getAllFruits();
});

final currentMonthRipeningFruitsProvider = FutureProvider<List<FruitModel>>((ref) async {
  final ds = ref.watch(fruitLocalDatasourceProvider);
  final city = ref.watch(selectedCityProvider);
  final month = DateTime.now().month;
  return ds.getFruitsRipeningInMonth(month, city?.climateZoneCode);
});

final currentMonthPlantingFruitsProvider = FutureProvider<List<FruitModel>>((ref) async {
  final ds = ref.watch(fruitLocalDatasourceProvider);
  final city = ref.watch(selectedCityProvider);
  final month = DateTime.now().month;
  return ds.getFruitsPlantingInMonth(month, city?.climateZoneCode);
});

final monthRipeningFruitsProvider = FutureProvider.family<List<FruitModel>, int>((ref, month) async {
  final ds = ref.watch(fruitLocalDatasourceProvider);
  final city = ref.watch(selectedCityProvider);
  return ds.getFruitsRipeningInMonth(month, city?.climateZoneCode);
});

final monthPlantingFruitsProvider = FutureProvider.family<List<FruitModel>, int>((ref, month) async {
  final ds = ref.watch(fruitLocalDatasourceProvider);
  final city = ref.watch(selectedCityProvider);
  return ds.getFruitsPlantingInMonth(month, city?.climateZoneCode);
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
final allCitiesProvider = FutureProvider<List<CityModel>>((ref) async {
  final ds = ref.watch(cityLocalDatasourceProvider);
  return ds.getAllCities();
});

final allProvincesProvider = FutureProvider<List<String>>((ref) async {
  final ds = ref.watch(cityLocalDatasourceProvider);
  return ds.getAllProvinces();
});

// ─── Garden Harvest Records ────────────────────────────────────
class HarvestRecord {
  final String fruitId;
  final DateTime harvestDate;
  final String? notes;

  const HarvestRecord({
    required this.fruitId,
    required this.harvestDate,
    this.notes,
  });

  factory HarvestRecord.fromJson(Map<String, dynamic> json) {
    return HarvestRecord(
      fruitId: json['fruit_id'] as String,
      harvestDate: DateTime.parse(json['harvest_date'] as String),
      notes: json['notes'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
    'fruit_id': fruitId,
    'harvest_date': harvestDate.toIso8601String(),
    'notes': notes,
  };
}

class GardenRecordsNotifier extends StateNotifier<List<HarvestRecord>> {
  GardenRecordsNotifier() : super([]) {
    _load();
  }

  Future<void> _load() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final json = prefs.getString('garden_records');
      if (json != null) {
        final List<dynamic> list = jsonDecode(json);
        state = list.map((e) => HarvestRecord.fromJson(e)).toList();
      }
    } catch (_) {}
  }

  Future<void> _save() async {
    final prefs = await SharedPreferences.getInstance();
    final json = jsonEncode(state.map((r) => r.toJson()).toList());
    await prefs.setString('garden_records', json);
  }

  Future<void> addRecord(String fruitId, DateTime harvestDate, {String? notes}) async {
    state = [
      ...state,
      HarvestRecord(fruitId: fruitId, harvestDate: harvestDate, notes: notes),
    ];
    await _save();
  }

  Future<void> removeRecord(String fruitId, DateTime harvestDate) async {
    state = state
        .where((r) =>
            !(r.fruitId == fruitId &&
                r.harvestDate.year == harvestDate.year &&
                r.harvestDate.month == harvestDate.month &&
                r.harvestDate.day == harvestDate.day))
        .toList();
    await _save();
  }

  List<HarvestRecord> recordsForFruit(String fruitId) {
    return state.where((r) => r.fruitId == fruitId).toList();
  }
}

final gardenRecordsProvider =
    StateNotifierProvider<GardenRecordsNotifier, List<HarvestRecord>>(
  (ref) => GardenRecordsNotifier(),
);
