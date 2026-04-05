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
                  return _buildFavoriteList(context, ref, favorites);
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
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () {
                // Navigate to fruit library (index 1)
                // The parent will handle this
              },
              icon: const Icon(Icons.eco, color: Colors.white),
              label: const Text('去水果库'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryGreen,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFavoriteList(
    BuildContext context,
    WidgetRef ref,
    List<FruitModel> favorites,
  ) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: favorites.length,
      itemBuilder: (context, index) {
        final fruit = favorites[index];
        return _buildFavoriteCard(context, ref, fruit);
      },
    );
  }

  Widget _buildFavoriteCard(
    BuildContext context,
    WidgetRef ref,
    FruitModel fruit,
  ) {
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
      child: ListTile(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => FruitDetailPage(fruit: fruit),
            ),
          );
        },
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            color: AppTheme.primaryGreen.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Center(
            child: Text(fruit.emoji, style: const TextStyle(fontSize: 32)),
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
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryGreen.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '成熟期: ${fruit.ripeningMonths.join("/")}月',
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
            ref.read(userFavoritesProvider.notifier).toggleFavorite(fruit.id);
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
    );
  }
}
