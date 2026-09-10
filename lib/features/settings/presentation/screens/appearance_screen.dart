import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../settings_provider.dart';

class AppearanceScreen extends ConsumerWidget {
  const AppearanceScreen({super.key});

  static const List<({String name, Color color})> accentColors = [
    (name: 'Indigo', color: AppColors.accentIndigo),
    (name: 'Emerald', color: AppColors.accentEmerald),
    (name: 'Violet', color: AppColors.accentViolet),
    (name: 'Rose', color: AppColors.accentRose),
    (name: 'Amber', color: AppColors.accentAmber),
    (name: 'Cyan', color: AppColors.accentCyan),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settingsState = ref.watch(settingsProvider);
    final settingsNotifier = ref.read(settingsProvider.notifier);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.appearance),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        children: [
          // Theme Mode Section
          Text('Theme Mode', style: AppTypography.labelLarge),
          const SizedBox(height: 12),
          Row(
            children: [
              _buildThemeOption(
                context,
                title: AppStrings.themeLight,
                icon: Icons.light_mode_outlined,
                isSelected: settingsState.themeMode == ThemeMode.light,
                onTap: () => settingsNotifier.setThemeMode(ThemeMode.light),
                isDark: isDark,
              ),
              const SizedBox(width: 10),
              _buildThemeOption(
                context,
                title: AppStrings.themeDark,
                icon: Icons.dark_mode_outlined,
                isSelected: settingsState.themeMode == ThemeMode.dark,
                onTap: () => settingsNotifier.setThemeMode(ThemeMode.dark),
                isDark: isDark,
              ),
              const SizedBox(width: 10),
              _buildThemeOption(
                context,
                title: AppStrings.themeSystem,
                icon: Icons.brightness_auto_outlined,
                isSelected: settingsState.themeMode == ThemeMode.system,
                onTap: () => settingsNotifier.setThemeMode(ThemeMode.system),
                isDark: isDark,
              ),
            ],
          ),
          const SizedBox(height: 32),

          // Accent Color Section
          Text(AppStrings.accentColor, style: AppTypography.labelLarge),
          const SizedBox(height: 6),
          Text(
            'Personalize buttons, badges, highlights, and focus indicators.',
            style: AppTypography.bodySmall.copyWith(
              color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
            ),
          ),
          const SizedBox(height: 16),

          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              childAspectRatio: 1.4,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
            ),
            itemCount: accentColors.length,
            itemBuilder: (context, index) {
              final item = accentColors[index];
              final isSelected = settingsState.accentColor.toARGB32() == item.color.toARGB32();

              return InkWell(
                onTap: () => settingsNotifier.setAccentColor(item.color),
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.darkCard : AppColors.lightCard,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isSelected
                          ? item.color
                          : (isDark ? AppColors.darkBorder : AppColors.lightBorder),
                      width: isSelected ? 2 : 1,
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 22,
                        height: 22,
                        decoration: BoxDecoration(
                          color: item.color,
                          shape: BoxShape.circle,
                        ),
                        child: isSelected
                            ? const Icon(Icons.check, size: 14, color: Colors.white)
                            : null,
                      ),
                      const SizedBox(height: 6),
                      Text(
                        item.name,
                        style: AppTypography.labelSmall.copyWith(
                          color: isSelected ? item.color : null,
                          fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildThemeOption(
    BuildContext context, {
    required String title,
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
    required bool isDark,
  }) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            color: isDark ? AppColors.darkCard : AppColors.lightCard,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected
                  ? Theme.of(context).colorScheme.primary
                  : (isDark ? AppColors.darkBorder : AppColors.lightBorder),
              width: isSelected ? 2 : 1,
            ),
          ),
          child: Column(
            children: [
              Icon(
                icon,
                color: isSelected
                    ? Theme.of(context).colorScheme.primary
                    : (isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary),
                size: 24,
              ),
              const SizedBox(height: 8),
              Text(
                title,
                style: AppTypography.labelSmall.copyWith(
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                  color: isSelected ? Theme.of(context).colorScheme.primary : null,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
