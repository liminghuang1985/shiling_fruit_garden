import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_theme.dart';
import '../../data/models/fruit_model.dart';
import '../providers/fruit_providers.dart';
import 'fruit_detail_page.dart';

class MyGardenPage extends ConsumerWidget {
  const MyGardenPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final favoriteIds = ref.watch(userFavoritesProvider);
    final fruitsAsync = ref.watch(allFruitsProvider);
    final gardenRecords = ref.watch(gardenRecordsProvider);

    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            Expanded(
              child: fruitsAsync.when(
                data: (allFruits) {
                  final favorites = allFruits
                      .where((f) => favoriteIds.contains(f.id))
                      .toList();
                  if (favorites.isEmpty) {
                    return _buildEmpty(context);
                  }
                  return _buildContent(context, ref, favorites, gardenRecords);
                },
                loading: () => const Center(
                  child: CircularProgressIndicator(color: AppTheme.primaryGreen),
                ),
                error: (e, _) => Center(
                  child: Text('加载失败: $e',
                      style: const TextStyle(color: Colors.red)),
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
          Text('🏡', style: TextStyle(fontSize: 28)),
          SizedBox(width: 8),
          Text(
            '我的果园',
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

  Widget _buildContent(
    BuildContext context,
    WidgetRef ref,
    List<FruitModel> favorites,
    List<HarvestRecord> records,
  ) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // 收藏的水果
        const Text(
          '🍓 我的收藏',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: AppTheme.textPrimary,
          ),
        ),
        const SizedBox(height: 10),
        ...favorites.map((fruit) => _buildFavoriteCard(context, ref, fruit, records)),
        const SizedBox(height: 20),
        // 采摘记录
        if (records.isNotEmpty) ...[
          const Text(
            '📝 采摘记录',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 10),
          ..._buildHarvestRecords(context, ref, favorites, records),
        ],
      ],
    );
  }

  Widget _buildFavoriteCard(
    BuildContext context,
    WidgetRef ref,
    FruitModel fruit,
    List<HarvestRecord> records,
  ) {
    final fruitRecords = records.where((r) => r.fruitId == fruit.id).toList();

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
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
        children: [
          ListTile(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => FruitDetailPage(fruit: fruit),
                ),
              );
            },
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            leading: Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: AppTheme.primaryGreen.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Center(
                child: Image.asset(fruit.iconAsset, width: 30, height: 30, fit: BoxFit.contain, errorBuilder: (_, __, ___) => Image.asset(fruit.iconAsset, width: 24, height: 24, fit: BoxFit.contain, errorBuilder: (_, __, ___) => Text(fruit.emoji, style: const TextStyle(fontSize: 20)))),
              ),
            ),
            title: Text(
              fruit.name,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppTheme.textPrimary,
              ),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 2),
                Text(
                  fruit.category.label,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppTheme.textSecondary,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Container(
                      padding:
                          const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: AppTheme.primaryGreen.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        '成熟: ${fruit.ripeningMonths.join("/")}月',
                        style: const TextStyle(
                          fontSize: 11,
                          color: AppTheme.primaryGreen,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            trailing: IconButton(
              icon: const Icon(Icons.favorite, color: Colors.red),
              onPressed: () {
                ref
                    .read(userFavoritesProvider.notifier)
                    .toggleFavorite(fruit.id);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('已取消收藏'),
                    duration: Duration(seconds: 1),
                    backgroundColor: AppTheme.primaryGreen,
                  ),
                );
              },
            ),
          ),
          // 采摘记录按钮
          if (fruitRecords.isNotEmpty)
            Container(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
              child: Wrap(
                spacing: 8,
                runSpacing: 6,
                children: [
                  ...fruitRecords.map((r) => _buildRecordChip(
                        context,
                        ref,
                        fruit,
                        r,
                      )),
                  _buildAddRecordButton(context, ref, fruit),
                ],
              ),
            )
          else
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
              child: _buildAddRecordButton(context, ref, fruit),
            ),
        ],
      ),
    );
  }

  Widget _buildRecordChip(
    BuildContext context,
    WidgetRef ref,
    FruitModel fruit,
    HarvestRecord record,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.orange.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.orange.shade200),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.check_circle, size: 14, color: Colors.orange),
          const SizedBox(width: 4),
          Text(
            '${record.harvestDate.month}月${record.harvestDate.day}日采摘',
            style: TextStyle(
              fontSize: 11,
              color: Colors.orange.shade700,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(width: 4),
          GestureDetector(
            onTap: () {
              ref.read(gardenRecordsProvider.notifier).removeRecord(
                    fruit.id,
                    record.harvestDate,
                  );
            },
            child: Icon(Icons.close, size: 14, color: Colors.orange.shade400),
          ),
        ],
      ),
    );
  }

  Widget _buildAddRecordButton(
    BuildContext context,
    WidgetRef ref,
    FruitModel fruit,
  ) {
    return InkWell(
      onTap: () => _showAddHarvestDialog(context, ref, fruit),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: AppTheme.primaryGreen.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.add, size: 14, color: AppTheme.primaryGreen),
            const SizedBox(width: 4),
            Text(
              '记录采摘',
              style: TextStyle(
                fontSize: 11,
                color: AppTheme.primaryGreen,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showAddHarvestDialog(
    BuildContext context,
    WidgetRef ref,
    FruitModel fruit,
  ) {
    DateTime selectedDate = DateTime.now();
    final noteController = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setState) => AlertDialog(
          title: Text('记录采摘 - ${fruit.name}'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.calendar_today),
                title: Text(
                  '${selectedDate.year}年${selectedDate.month}月${selectedDate.day}日',
                ),
                onTap: () async {
                  final picked = await showDatePicker(
                    context: ctx,
                    initialDate: selectedDate,
                    firstDate: DateTime(2020),
                    lastDate: DateTime.now(),
                  );
                  if (picked != null) {
                    setState(() => selectedDate = picked);
                  }
                },
              ),
              const SizedBox(height: 12),
              TextField(
                controller: noteController,
                decoration: const InputDecoration(
                  labelText: '备注（选填）',
                  hintText: '如：甜度很好',
                ),
                maxLines: 2,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('取消'),
            ),
            ElevatedButton(
              onPressed: () {
                ref.read(gardenRecordsProvider.notifier).addRecord(
                      fruit.id,
                      selectedDate,
                      notes: noteController.text.isNotEmpty
                          ? noteController.text
                          : null,
                    );
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('采摘记录已添加'),
                    backgroundColor: AppTheme.primaryGreen,
                  ),
                );
              },
              child: const Text('保存'),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildHarvestRecords(
    BuildContext context,
    WidgetRef ref,
    List<FruitModel> favorites,
    List<HarvestRecord> records,
  ) {
    // Show all records, newest first
    final sorted = List<HarvestRecord>.from(records)
      ..sort((a, b) => b.harvestDate.compareTo(a.harvestDate));

    return sorted.map((record) {
      final fruit = favorites.cast<FruitModel?>().firstWhere(
            (f) => f?.id == record.fruitId,
            orElse: () => null,
          );
      if (fruit == null) return const SizedBox.shrink();
      return Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.orange.shade50,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.orange.shade100),
        ),
        child: Row(
          children: [
            Image.asset(fruit.iconAsset, width: 24, height: 24, fit: BoxFit.contain, errorBuilder: (_, __, ___) => Text(fruit.emoji, style: const TextStyle(fontSize: 20))),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    fruit.name,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  Text(
                    '${record.harvestDate.year}年${record.harvestDate.month}月${record.harvestDate.day}日采摘',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.orange.shade700,
                    ),
                  ),
                  if (record.notes != null)
                    Text(
                      record.notes!,
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppTheme.textSecondary,
                      ),
                    ),
                ],
              ),
            ),
            IconButton(
              icon: Icon(Icons.delete_outline,
                  size: 20, color: Colors.orange.shade400),
              onPressed: () {
                ref.read(gardenRecordsProvider.notifier).removeRecord(
                      fruit.id,
                      record.harvestDate,
                    );
              },
            ),
          ],
        ),
      );
    }).toList();
  }

  Widget _buildEmpty(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('🏡', style: TextStyle(fontSize: 64)),
            const SizedBox(height: 16),
            const Text(
              '还没有收藏水果',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppTheme.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              '去水果库逛逛，收藏你喜欢的果树吧',
              style: TextStyle(fontSize: 14, color: AppTheme.textSecondary),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
