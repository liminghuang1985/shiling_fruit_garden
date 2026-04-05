import 'package:flutter/material.dart';
import 'core/theme/app_theme.dart';
import 'presentation/pages/home_page.dart';

class ShilingFruitGardenApp extends StatelessWidget {
  const ShilingFruitGardenApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '时令果园',
      theme: AppTheme.lightTheme,
      debugShowCheckedModeBanner: false,
      home: const HomePage(),
    );
  }
}
