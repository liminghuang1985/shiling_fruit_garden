import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/theme/app_theme.dart';
import '../../data/models/city_model.dart';
import '../providers/fruit_providers.dart';

class CitySelectPage extends ConsumerStatefulWidget {
  const CitySelectPage({super.key});

  @override
  ConsumerState<CitySelectPage> createState() => _CitySelectPageState();
}

class _CitySelectPageState extends ConsumerState<CitySelectPage> {
  List<CityModel> _allCities = [];
  List<CityModel> _filteredCities = [];
  String? _selectedProvince;
  final TextEditingController _searchController = TextEditingController();
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadCities();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadCities() async {
    try {
      final jsonString = await rootBundle.loadString('assets/data/cities.json');
      final List<dynamic> jsonList = json.decode(jsonString);
      final cities = jsonList.map((e) => CityModel.fromJson(e)).toList();
      setState(() {
        _allCities = cities;
        _filteredCities = cities;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  List<String> get _provinces {
    final provinces = _allCities.map((c) => c.province).toSet().toList();
    provinces.sort();
    return provinces;
  }

  List<CityModel> _citiesForProvince(String province) {
    return _allCities.where((c) => c.province == province).toList();
  }

  void _search(String query) {
    setState(() {
      if (query.isEmpty) {
        _filteredCities = _allCities;
        _selectedProvince = null;
      } else {
        final q = query.toLowerCase();
        _filteredCities = _allCities
            .where((c) => c.name.toLowerCase().contains(q) ||
                c.province.toLowerCase().contains(q))
            .toList();
        _selectedProvince = null;
      }
    });
  }

  Future<void> _selectCity(CityModel city) async {
    // Save to SharedPreferences
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('selected_city_name', city.name);
    await prefs.setString('selected_city_id', city.id);
    await prefs.setString('selected_climate_zone', city.climateZoneCode);

    // Update provider
    ref.read(selectedCityProvider.notifier).setCity(city);

    if (!mounted) return;
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('已切换到${city.name}'),
        backgroundColor: AppTheme.primaryGreen,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        duration: const Duration(seconds: 1),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        backgroundColor: AppTheme.primaryGreen,
        foregroundColor: Colors.white,
        title: const Text('选择城市'),
        elevation: 0,
      ),
      body: Column(
        children: [
          // 搜索框
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              onChanged: _search,
              decoration: InputDecoration(
                hintText: '搜索城市名称...',
                hintStyle: TextStyle(color: AppTheme.textLight),
                prefixIcon:
                    Icon(Icons.search, color: AppTheme.textSecondary),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear, size: 20),
                        onPressed: () {
                          _searchController.clear();
                          _search('');
                        },
                      )
                    : null,
                filled: true,
                fillColor: Colors.white,
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey.shade200),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide:
                      const BorderSide(color: AppTheme.primaryGreen, width: 1.5),
                ),
              ),
            ),
          ),
          // 内容
          Expanded(
            child: _isLoading
                ? const Center(
                    child: CircularProgressIndicator(color: AppTheme.primaryGreen))
                : _searchController.text.isNotEmpty
                    ? _buildSearchResults()
                    : _buildProvinceList(),
          ),
        ],
      ),
    );
  }

  Widget _buildProvinceList() {
    final provinces = _provinces;
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: provinces.length,
      itemBuilder: (context, index) {
        final province = provinces[index];
        return _ProvinceCard(
          province: province,
          cityCount: _citiesForProvince(province).length,
          isExpanded: _selectedProvince == province,
          onTap: () {
            setState(() {
              _selectedProvince =
                  _selectedProvince == province ? null : province;
            });
          },
          onCityTap: _selectCity,
          cities: _citiesForProvince(province),
        );
      },
    );
  }

  Widget _buildSearchResults() {
    if (_filteredCities.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.location_off, size: 48, color: AppTheme.textSecondary),
            SizedBox(height: 12),
            Text('未找到匹配的城市',
                style: TextStyle(color: AppTheme.textSecondary)),
          ],
        ),
      );
    }

    // Group by province
    final Map<String, List<CityModel>> grouped = {};
    for (final city in _filteredCities) {
      grouped.putIfAbsent(city.province, () => []).add(city);
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: grouped.length,
      itemBuilder: (context, index) {
        final province = grouped.keys.elementAt(index);
        final cities = grouped[province]!;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Row(
                children: [
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryGreen.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      province,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.primaryGreen,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: cities.map((city) => _buildCityChip(city)).toList(),
            ),
          ],
        );
      },
    );
  }

  Widget _buildCityChip(CityModel city) {
    return InkWell(
      onTap: () => _selectCity(city),
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Text(
          city.name,
          style: const TextStyle(
            fontSize: 13,
            color: AppTheme.textPrimary,
          ),
        ),
      ),
    );
  }
}

class _ProvinceCard extends StatelessWidget {
  final String province;
  final int cityCount;
  final bool isExpanded;
  final VoidCallback onTap;
  final Function(CityModel) onCityTap;
  final List<CityModel> cities;

  const _ProvinceCard({
    required this.province,
    required this.cityCount,
    required this.isExpanded,
    required this.onTap,
    required this.onCityTap,
    required this.cities,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(14),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      province,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                  ),
                  Text(
                    '$cityCount个城市',
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppTheme.textSecondary,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Icon(
                    isExpanded
                        ? Icons.keyboard_arrow_up
                        : Icons.keyboard_arrow_down,
                    color: AppTheme.textSecondary,
                  ),
                ],
              ),
            ),
          ),
          if (isExpanded)
            Container(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                children: cities.map((city) {
                  return InkWell(
                    onTap: () => onCityTap(city),
                    borderRadius: BorderRadius.circular(20),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(
                        color: AppTheme.primaryGreen.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        city.name,
                        style: const TextStyle(
                          fontSize: 13,
                          color: AppTheme.primaryGreen,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
        ],
      ),
    );
  }
}
