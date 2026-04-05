import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_theme.dart';
import '../../data/models/fruit_model.dart';
import '../providers/fruit_providers.dart';

class FruitDetailPage extends ConsumerWidget {
  final FruitModel fruit;

  const FruitDetailPage({super.key, required this.fruit});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final favorites = ref.watch(userFavoritesProvider);
    final isFavorite = favorites.contains(fruit.id);

    return Scaffold(
      backgroundColor: AppTheme.background,
      body: CustomScrollView(
        slivers: [
          // 头部
          SliverAppBar(
            expandedHeight: 220,
            pinned: true,
            backgroundColor: AppTheme.primaryGreen,
            foregroundColor: Colors.white,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color(0xFF4CAF50), Color(0xFF8BC34A)],
                  ),
                ),
                child: SafeArea(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(height: 20),
                      Text(fruit.emoji, style: const TextStyle(fontSize: 80)),
                      const SizedBox(height: 12),
                      Text(
                        fruit.name,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      if (fruit.alias != null)
                        Text(
                          fruit.alias!,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.white.withValues(alpha: 0.8),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
            actions: [
              IconButton(
                icon: Icon(
                  isFavorite ? Icons.favorite : Icons.favorite_border,
                  color: isFavorite ? Colors.red : Colors.white,
                ),
                onPressed: () {
                  ref.read(userFavoritesProvider.notifier).toggleFavorite(fruit.id);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        isFavorite ? '已取消收藏' : '已收藏到我的果园',
                      ),
                      duration: const Duration(seconds: 1),
                      backgroundColor: AppTheme.primaryGreen,
                    ),
                  );
                },
              ),
            ],
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 分类标签
                  _buildTag(fruit.category.label, Colors.green),
                  const SizedBox(height: 16),
                  // 成熟月份
                  _buildSection(
                    title: '🍎 成熟月份',
                    child: _buildMonthBadges(fruit.ripeningMonths),
                  ),
                  const SizedBox(height: 16),
                  // 种植信息
                  _buildSection(
                    title: '🌱 种植信息',
                    child: _buildPlantingInfo(),
                  ),
                  const SizedBox(height: 16),
                  // 营养价值
                  if (fruit.nutritionalValue.isNotEmpty)
                    _buildSection(
                      title: '💪 营养价值（每100g）',
                      child: _buildNutritionalValue(),
                    ),
                  if (fruit.nutritionalValue.isNotEmpty) const SizedBox(height: 16),
                  // 功效与禁忌
                  if (fruit.benefits.isNotEmpty)
                    _buildSection(
                      title: '✨ 功效',
                      child: Text(
                        fruit.benefits,
                        style: const TextStyle(
                          fontSize: 14,
                          color: AppTheme.textSecondary,
                          height: 1.6,
                        ),
                      ),
                    ),
                  if (fruit.benefits.isNotEmpty) const SizedBox(height: 16),
                  if (fruit.contraindications.isNotEmpty)
                    _buildSection(
                      title: '⚠️ 禁忌',
                      child: Text(
                        fruit.contraindications,
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.orange,
                          height: 1.6,
                        ),
                      ),
                    ),
                  if (fruit.contraindications.isNotEmpty) const SizedBox(height: 16),
                  // 口感风味
                  if (fruit.taste.isNotEmpty)
                    _buildSection(
                      title: '😋 口感风味',
                      child: Text(
                        fruit.taste,
                        style: const TextStyle(
                          fontSize: 14,
                          color: AppTheme.textSecondary,
                          height: 1.6,
                        ),
                      ),
                    ),
                  if (fruit.taste.isNotEmpty) const SizedBox(height: 16),
                  // 价格区间
                  if (fruit.priceRange.isNotEmpty)
                    _buildSection(
                      title: '💰 价格区间',
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 10,
                        ),
                        decoration: BoxDecoration(
                          color: AppTheme.primaryGreen.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          fruit.priceRange,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.primaryGreen,
                          ),
                        ),
                      ),
                    ),
                  const SizedBox(height: 30),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTag(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 13,
          color: color,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildSection({required String title, required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }

  Widget _buildMonthBadges(List<int> months) {
    final monthLabels = ['', '1月', '2月', '3月', '4月', '5月', '6月',
      '7月', '8月', '9月', '10月', '11月', '12月'];
    final currentMonth = DateTime.now().month;
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: List.generate(12, (i) {
        final month = i + 1;
        final isRipening = months.contains(month);
        final isCurrentMonth = month == currentMonth;
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: isRipening
                ? (isCurrentMonth
                    ? AppTheme.primaryGreen
                    : AppTheme.primaryGreen.withValues(alpha: 0.7))
                : Colors.grey.shade200,
            borderRadius: BorderRadius.circular(20),
            border: isCurrentMonth
                ? Border.all(color: AppTheme.primaryGreen, width: 2)
                : null,
          ),
          child: Text(
            monthLabels[month],
            style: TextStyle(
              fontSize: 12,
              color: isRipening ? Colors.white : Colors.grey,
              fontWeight: isCurrentMonth || isRipening
                  ? FontWeight.w600
                  : FontWeight.normal,
            ),
          ),
        );
      }),
    );
  }

  Widget _buildPlantingInfo() {
    return Column(
      children: [
        _buildInfoRow('成熟周期', '${fruit.maturityDays}天'),
        _buildInfoRow('最适温度', '${fruit.optimalTempMin}-${fruit.optimalTempMax}°C'),
        _buildInfoRow('最低耐温', '${fruit.minTemp}°C'),
        _buildInfoRow('最高耐温', '${fruit.maxTemp}°C'),
        _buildInfoRow('土壤类型', fruit.soilType),
        _buildInfoRow('pH范围', '${fruit.phMin} - ${fruit.phMax}'),
        _buildInfoRow('光照需求', fruit.sunlight.label),
        _buildInfoRow('排水要求', fruit.drainage.label),
      ],
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        children: [
          SizedBox(
            width: 90,
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 13,
                color: AppTheme.textSecondary,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppTheme.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNutritionalValue() {
    final labels = {
      'calories': '热量',
      'vitamin_c': '维生素C',
      'fiber': '膳食纤维',
      'sugar': '糖分',
      'potassium': '钾',
    };
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: fruit.nutritionalValue.entries.map((e) {
        final label = labels[e.key] ?? e.key;
        final val = e.value;
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: AppTheme.primaryGreen.withValues(alpha: 0.06),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: [
              Text(
                val.toString(),
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.primaryGreen,
                ),
              ),
              Text(
                label,
                style: const TextStyle(
                  fontSize: 11,
                  color: AppTheme.textSecondary,
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}
