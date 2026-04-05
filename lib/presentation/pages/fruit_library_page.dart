import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_theme.dart';
import '../../core/constants/enums.dart';
import '../../data/models/fruit_model.dart';
import '../providers/fruit_providers.dart';
import 'fruit_detail_page.dart';

class FruitLibraryPage extends ConsumerStatefulWidget {
  const FruitLibraryPage({super.key});

  @override
  ConsumerState<FruitLibraryPage> createState() => _FruitLibraryPageState();
}

class _FruitLibraryPageState extends ConsumerState<FruitLibraryPage> {
  FruitCategory? _selectedCategory;
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final fruitsAsync = ref.watch(allFruitsProvider);

    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            _buildSearchBar(),
            _buildCategoryFilter(),
            Expanded(
              child: fruitsAsync.when(
                data: (allFruits) {
                  var fruits = _filterFruits(allFruits);
                  if (fruits.isEmpty) return _buildEmpty();
                  return _buildFruitGrid(fruits);
                },
                loading: () => const Center(
                  child: CircularProgressIndicator(color: AppTheme.primaryGreen),
                ),
                error: (e, _) => Center(
                  child: Text('加载失败: $e', style: const TextStyle(color: Colors.red)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
      child: const Row(
        children: [
          Text('🍇', style: TextStyle(fontSize: 28)),
          SizedBox(width: 8),
          Text(
            '水果库',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppTheme.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: TextField(
        controller: _searchController,
        onChanged: (value) => setState(() => _searchQuery = value),
        decoration: InputDecoration(
          hintText: '搜索水果名称...',
          hintStyle: TextStyle(color: AppTheme.textLight),
          prefixIcon: const Icon(Icons.search, color: AppTheme.textSecondary),
          suffixIcon: _searchQuery.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear, size: 20),
                  onPressed: () {
                    _searchController.clear();
                    setState(() => _searchQuery = '');
                  },
                )
              : null,
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
            borderSide: const BorderSide(color: AppTheme.primaryGreen, width: 1.5),
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryFilter() {
    return SizedBox(
      height: 44,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        children: [
          _buildCategoryChip(null, '全部'),
          ...FruitCategory.values.map(
            (c) => _buildCategoryChip(c, c.label),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryChip(FruitCategory? category, String label) {
    final isSelected = _selectedCategory == category;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: FilterChip(
        label: Text(label),
        selected: isSelected,
        onSelected: (selected) {
          setState(() => _selectedCategory = selected ? category : null);
        },
        labelStyle: TextStyle(
          fontSize: 13,
          color: isSelected ? Colors.white : AppTheme.textPrimary,
          fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
        ),
        backgroundColor: Colors.white,
        selectedColor: AppTheme.primaryGreen,
        checkmarkColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(
            color: isSelected ? AppTheme.primaryGreen : Colors.grey.shade300,
          ),
        ),
      ),
    );
  }

  List<FruitModel> _filterFruits(List<FruitModel> all) {
    return all.where((f) {
      final matchesCategory =
          _selectedCategory == null || f.category == _selectedCategory;
      final matchesSearch = _searchQuery.isEmpty ||
          f.name.contains(_searchQuery) ||
          (f.alias?.contains(_searchQuery) ?? false);
      return matchesCategory && matchesSearch;
    }).toList();
  }

  Widget _buildEmpty() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('🍇', style: TextStyle(fontSize: 64)),
          const SizedBox(height: 16),
          Text(
            _searchQuery.isNotEmpty || _selectedCategory != null
                ? '没有找到匹配的水果'
                : '暂无水果数据',
            style: const TextStyle(fontSize: 16, color: AppTheme.textSecondary),
          ),
          if (_searchQuery.isNotEmpty || _selectedCategory != null) ...[
            const SizedBox(height: 12),
            TextButton(
              onPressed: () {
                _searchController.clear();
                setState(() {
                  _searchQuery = '';
                  _selectedCategory = null;
                });
              },
              child: const Text('清除筛选'),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildFruitGrid(List<FruitModel> fruits) {
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.9,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: fruits.length,
      itemBuilder: (context, index) => _buildFruitCard(fruits[index]),
    );
  }

  Widget _buildFruitCard(FruitModel fruit) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => FruitDetailPage(fruit: fruit),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(fruit.emoji, style: const TextStyle(fontSize: 48)),
            const SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Text(
                fruit.name,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textPrimary,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              fruit.category.label,
              style: const TextStyle(
                fontSize: 12,
                color: AppTheme.textSecondary,
              ),
            ),
            const SizedBox(height: 6),
            _buildMonthDots(fruit.ripeningMonths),
          ],
        ),
      ),
    );
  }

  Widget _buildMonthDots(List<int> months) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: months.take(5).map((m) {
        final isCurrentMonth = m == DateTime.now().month;
        return Container(
          width: 8,
          height: 8,
          margin: const EdgeInsets.symmetric(horizontal: 2),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isCurrentMonth
                ? AppTheme.primaryGreen
                : AppTheme.primaryGreen.withValues(alpha: 0.3),
            border: isCurrentMonth
                ? Border.all(color: AppTheme.primaryGreen, width: 1.5)
                : null,
          ),
        );
      }).toList(),
    );
  }
}
