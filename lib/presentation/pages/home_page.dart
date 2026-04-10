import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_theme.dart';
import '../../domain/entities/fruit_entity.dart';
import '../providers/fruit_providers.dart';
import 'fruit_detail_page.dart';
import 'city_select_page.dart';

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedCity = ref.watch(selectedCityProvider);
    final currentMonth = DateTime.now().month;
    final currentMonthRipening = ref.watch(currentMonthRipeningFruitsProvider);
    final currentMonthPlanting = ref.watch(currentMonthPlantingFruitsProvider);
    final currentSolarTerms = ref.watch(currentSolarTermsProvider);

    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            // 顶部城市选择栏
            SliverToBoxAdapter(
              child: _buildHeader(context, ref, selectedCity),
            ),
            // 当月标题（含节气）
            SliverToBoxAdapter(
              child: currentSolarTerms.when(
                data: (terms) => _buildMonthBanner(currentMonth, terms),
                loading: () => _buildMonthBanner(currentMonth, []),
                error: (_, __) => _buildMonthBanner(currentMonth, []),
              ),
            ),
            // 当月成熟水果
            SliverToBoxAdapter(
              child: _buildSectionTitle('🍎 当月成熟水果', currentMonthRipening),
            ),
            currentMonthRipening.when(
              data: (fruits) => fruits.isEmpty
                  ? SliverToBoxAdapter(child: _buildEmptyCard('暂无当月成熟水果'))
                  : SliverToBoxAdapter(child: _buildFruitHorizontalList(fruits)),
              loading: () => SliverToBoxAdapter(child: _buildLoading()),
              error: (e, s) => SliverToBoxAdapter(child: _buildErrorCard()),
            ),
            // 当月种植水果
            SliverToBoxAdapter(
              child: _buildSectionTitle('🌱 当月适合种植', currentMonthPlanting),
            ),
            currentMonthPlanting.when(
              data: (fruits) => fruits.isEmpty
                  ? SliverToBoxAdapter(child: _buildEmptyCard('暂无当月可种植水果'))
                  : SliverToBoxAdapter(child: _buildFruitHorizontalList(fruits)),
              loading: () => SliverToBoxAdapter(child: _buildLoading()),
              error: (e, s) => SliverToBoxAdapter(child: _buildErrorCard()),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 20)),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, WidgetRef ref, dynamic selectedCity) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const CitySelectPage()),
        );
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(25),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.location_on, color: AppTheme.primaryGreen, size: 20),
                  const SizedBox(width: 6),
                  Text(
                    selectedCity?.name ?? '请选择城市',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: selectedCity != null ? FontWeight.w600 : FontWeight.normal,
                      color: selectedCity != null ? AppTheme.textPrimary : AppTheme.textSecondary,
                    ),
                  ),
                  const SizedBox(width: 4),
                  const Icon(Icons.keyboard_arrow_down, color: AppTheme.textSecondary, size: 18),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMonthBanner(int month, List<String> solarTerms) {
    final monthNames = ['', '一月', '二月', '三月', '四月', '五月', '六月',
      '七月', '八月', '九月', '十月', '十一月', '十二月'];
    final emojis = ['', '🥝', '🍑', '🍓', '🍒', '🍇', '🍉',
      '🍑', '🍎', '🍐', '🍊', '🍋', '🥭'];
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF4CAF50), Color(0xFF8BC34A)],
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                Text(emojis[month], style: const TextStyle(fontSize: 32)),
                Text(
                  '$month月',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '现在是采摘的好时节',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${monthNames[month]}应季水果和种植指南',
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.white.withValues(alpha: 0.9),
                  ),
                ),
                if (solarTerms.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 6,
                    runSpacing: 4,
                    children: solarTerms.map((term) => Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.25),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '🌿 $term',
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.white,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    )).toList(),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title, AsyncValue<List<FruitEntity>> provider) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 12),
      child: Row(
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.bold,
              color: AppTheme.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFruitHorizontalList(List<FruitEntity> fruits) {
    return SizedBox(
      height: 160,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: fruits.length,
        itemBuilder: (context, index) {
          final fruit = fruits[index];
          return _buildFruitCard(context, fruit);
        },
      ),
    );
  }

  Widget _buildFruitCard(BuildContext context, FruitEntity fruit) {
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
        width: 130,
        margin: const EdgeInsets.symmetric(horizontal: 4),
        padding: const EdgeInsets.all(14),
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
            Text(fruit.emoji, style: const TextStyle(fontSize: 40)),
            const SizedBox(height: 10),
            Text(
              fruit.name,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppTheme.textPrimary,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            Text(
              fruit.category.label,
              style: const TextStyle(
                fontSize: 11,
                color: AppTheme.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyCard(String msg) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Center(
        child: Text(msg, style: const TextStyle(color: AppTheme.textSecondary)),
      ),
    );
  }

  Widget _buildLoading() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: const Center(
        child: CircularProgressIndicator(color: AppTheme.primaryGreen),
      ),
    );
  }

  Widget _buildErrorCard() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: const Center(
        child: Text('加载失败', style: TextStyle(color: Colors.red)),
      ),
    );
  }
}
