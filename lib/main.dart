import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'app.dart';
import 'data/datasources/fruit_local_datasource.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 预加载水果数据
  await FruitLocalDatasource.seedDatabase();

  runApp(const ProviderScope(child: ShilingFruitGardenApp()));
}
