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
final selectedCityProvider = StateProvider<CityModel?>((ref) => null);

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

// ─── Cities ─────────────────────────────────────────────────────
final allCitiesProvider = FutureProvider<List<CityModel>>((ref) async {
  final ds = ref.watch(cityLocalDatasourceProvider);
  return ds.getAllCities();
});

final allProvincesProvider = FutureProvider<List<String>>((ref) async {
  final ds = ref.watch(cityLocalDatasourceProvider);
  return ds.getAllProvinces();
});
