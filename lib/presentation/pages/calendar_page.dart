import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_theme.dart';
import '../../domain/entities/fruit_entity.dart';
import '../providers/fruit_providers.dart';
import 'fruit_detail_page.dart';

class CalendarPage extends ConsumerStatefulWidget {
  const CalendarPage({super.key});

  @override
  ConsumerState<CalendarPage> createState() => _CalendarPageState();
}

class _CalendarPageState extends ConsumerState<CalendarPage> {
  int _selectedMonth = DateTime.now().month;

  @override
  Widget build(BuildContext context) {
    final ripening = ref.watch(monthRipeningFruitsProvider(_selectedMonth));
    final planting = ref.watch(monthPlantingFruitsProvider(_selectedMonth));


    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            _buildMonthSelector(),
            Expanded(
              child: DefaultTabController(
                length: 2,
                child: Column(
                  children: [
                    Container(
                      margin: const EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const TabBar(
                        labelColor: Colors.white,
                        unselectedLabelColor: AppTheme.textSecondary,
                        indicator: BoxDecoration(
                          color: AppTheme.primaryGreen,
                          borderRadius: BorderRadius.all(Radius.circular(10)),
                        ),
                        indicatorSize: TabBarIndicatorSize.tab,
                        dividerColor: Colors.transparent,
                        padding: EdgeInsets.all(4),
                        tabs: [
                          Tab(text: '🍎 成熟水果'),
                          Tab(text: '🌱 种植水果'),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Expanded(
                      child: TabBarView(
                        children: [
                          _buildRipeningList(ripening),
                          _buildPlantingList(planting),
                        ],
                      ),
                    ),
                  ],
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
          Text('📅', style: TextStyle(fontSize: 28)),
          SizedBox(width: 8),
          Text(
            '采摘日历',
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

  Widget _buildMonthSelector() {
    final months = ['一月', '二月', '三月', '四月', '五月', '六月',
      '七月', '八月', '九月', '十月', '十一月', '十二月'];
    final emojis = ['🥝', '🍑', '🍓', '🍒', '🍇', '🍉',
      '🍑', '🍎', '🍐', '🍊', '🍋', '🥭'];

    return SizedBox(
      height: 100,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        itemCount: 12,
        itemBuilder: (context, index) {
          final month = index + 1;
          final isSelected = _selectedMonth == month;
          return GestureDetector(
            onTap: () => setState(() => _selectedMonth = month),
            child: Container(
              width: 70,
              margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
              decoration: BoxDecoration(
                color: isSelected
                    ? AppTheme.primaryGreen
                    : Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: isSelected ? 0.1 : 0.05),
                    blurRadius: isSelected ? 8 : 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    emojis[index],
                    style: TextStyle(
                      fontSize: 22,
                      color: isSelected ? Colors.white : AppTheme.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    months[index],
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      color: isSelected ? Colors.white : AppTheme.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildRipeningList(AsyncValue<List<FruitEntity>> ripening) {
    return ripening.when(
      data: (fruits) {
        if (fruits.isEmpty) {
          return _buildEmpty('🍎', '本月无成熟水果');
        }
        return _buildFruitList(fruits);
      },
      loading: () => const Center(
        child: CircularProgressIndicator(color: AppTheme.primaryGreen),
      ),
      error: (e, _) => _buildError('加载失败: $e'),
    );
  }

  Widget _buildPlantingList(AsyncValue<List<FruitEntity>> planting) {
    return planting.when(
      data: (fruits) {
        if (fruits.isEmpty) {
          return _buildEmpty('🌱', '本月无适合种植的水果');
        }
        return _buildFruitList(fruits);
      },
      loading: () => const Center(
        child: CircularProgressIndicator(color: AppTheme.primaryGreen),
      ),
      error: (e, _) => _buildError('加载失败: $e'),
    );
  }

  Widget _buildFruitList(List<FruitEntity> fruits) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: fruits.length,
      itemBuilder: (context, index) {
        final fruit = fruits[index];
        return _buildFruitTile(fruit);
      },
    );
  }

  Widget _buildFruitTile(FruitEntity fruit) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => FruitDetailPage(fruit: fruit),
            ),
          );
        },
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        leading: Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: AppTheme.primaryGreen.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Center(
            child: Text(fruit.emoji, style: const TextStyle(fontSize: 28)),
          ),
        ),
        title: Text(
          fruit.name,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: AppTheme.textPrimary,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${fruit.category.label} · 成熟${fruit.maturityDays}天',
              style: const TextStyle(
                fontSize: 12,
                color: AppTheme.textSecondary,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '适温: ${fruit.optimalTempMin}-${fruit.optimalTempMax}°C',
              style: const TextStyle(
                fontSize: 11,
                color: AppTheme.primaryGreen,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        trailing: const Icon(Icons.chevron_right, color: AppTheme.textSecondary),
      ),
    );
  }

  Widget _buildEmpty(String emoji, String msg) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(emoji, style: const TextStyle(fontSize: 64)),
          const SizedBox(height: 16),
          Text(msg, style: const TextStyle(
            fontSize: 16,
            color: AppTheme.textSecondary,
          )),
        ],
      ),
    );
  }

  Widget _buildError(String msg) {
    return Center(
      child: Text(msg, style: const TextStyle(color: Colors.red)),
    );
  }
}
