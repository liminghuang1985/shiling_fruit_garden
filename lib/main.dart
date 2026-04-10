import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'app.dart';
import 'data/datasources/seed_manager.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 预加载所有种子数据（统一版本管理，幂等）
  await SeedManager.seedIfNeeded();

  runApp(const ProviderScope(child: ShilingFruitGardenApp()));
}
