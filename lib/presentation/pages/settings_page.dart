import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_theme.dart';
import '../providers/fruit_providers.dart';
import 'city_select_page.dart';

class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedCity = ref.watch(selectedCityProvider);

    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  // 城市选择
                  _buildSection(
                    title: '位置设置',
                    children: [
                      _buildSettingTile(
                        icon: Icons.location_city,
                        iconColor: AppTheme.primaryGreen,
                        title: '当前城市',
                        subtitle: selectedCity?.name ?? '未选择',
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const CitySelectPage(),
                            ),
                          );
                        },
                        trailing: const Icon(Icons.chevron_right, color: AppTheme.textSecondary),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  // 缓存设置
                  _buildSection(
                    title: '数据管理',
                    children: [
                      _buildSettingTile(
                        icon: Icons.delete_outline,
                        iconColor: Colors.orange,
                        title: '清除缓存',
                        subtitle: '清除本地缓存数据',
                        onTap: () {
                          showDialog(
                            context: context,
                            builder: (ctx) => AlertDialog(
                              title: const Text('确认清除'),
                              content: const Text('确定要清除缓存数据吗？'),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(ctx),
                                  child: const Text('取消'),
                                ),
                                TextButton(
                                  onPressed: () {
                                    Navigator.pop(ctx);
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text('缓存已清除'),
                                        backgroundColor: AppTheme.primaryGreen,
                                      ),
                                    );
                                  },
                                  child: const Text('确定'),
                                ),
                              ],
                            ),
                          );
                        },
                        trailing: const Icon(Icons.chevron_right, color: AppTheme.textSecondary),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  // 关于
                  _buildSection(
                    title: '关于',
                    children: [
                      _buildSettingTile(
                        icon: Icons.info_outline,
                        iconColor: Colors.blue,
                        title: '版本信息',
                        subtitle: '1.0.0',
                        onTap: null,
                        trailing: null,
                      ),
                      _buildSettingTile(
                        icon: Icons.eco,
                        iconColor: AppTheme.primaryGreen,
                        title: '时令果园',
                        subtitle: '基于气候区的水果采摘/种植指南',
                        onTap: null,
                        trailing: null,
                      ),
                    ],
                  ),
                ],
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
          Text('⚙️', style: TextStyle(fontSize: 28)),
          SizedBox(width: 8),
          Text(
            '设置',
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

  Widget _buildSection({required String title, required List<Widget> children}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 8),
          child: Text(
            title,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppTheme.textSecondary,
            ),
          ),
        ),
        Container(
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
          child: Column(children: children),
        ),
      ],
    );
  }

  Widget _buildSettingTile({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required VoidCallback? onTap,
    required Widget? trailing,
  }) {
    return ListTile(
      onTap: onTap,
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: iconColor.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: iconColor, size: 20),
      ),
      title: Text(
        title,
        style: const TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w500,
          color: AppTheme.textPrimary,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: const TextStyle(
          fontSize: 12,
          color: AppTheme.textSecondary,
        ),
      ),
      trailing: trailing,
    );
  }
}
