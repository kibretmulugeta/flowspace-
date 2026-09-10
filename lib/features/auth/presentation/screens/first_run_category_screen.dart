import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../categories/presentation/category_provider.dart';

class FirstRunCategoryScreen extends ConsumerStatefulWidget {
  const FirstRunCategoryScreen({super.key});

  @override
  ConsumerState<FirstRunCategoryScreen> createState() => _FirstRunCategoryScreenState();
}

class _FirstRunCategoryScreenState extends ConsumerState<FirstRunCategoryScreen> {
  final Set<String> _selectedCategories = {'Work', 'Research', 'Personal'};

  final List<({String name, IconData icon, Color color})> _options = const [
    (name: 'Work', icon: Icons.work_outline, color: AppColors.accentIndigo),
    (name: 'Research', icon: Icons.biotech_outlined, color: AppColors.accentViolet),
    (name: 'Study', icon: Icons.school_outlined, color: AppColors.accentEmerald),
    (name: 'Personal', icon: Icons.person_outline, color: AppColors.accentAmber),
    (name: 'Projects', icon: Icons.rocket_launch_outlined, color: AppColors.accentCyan),
    (name: 'Finance', icon: Icons.account_balance_wallet_outlined, color: Color(0xFF14B8A6)),
    (name: 'Health', icon: Icons.favorite_outline, color: AppColors.priorityUrgent),
  ];

  void _toggleCategory(String name) {
    setState(() {
      if (_selectedCategories.contains(name)) {
        if (_selectedCategories.length > 1) {
          _selectedCategories.remove(name);
        }
      } else {
        _selectedCategories.add(name);
      }
    });
  }

  void _finishSetup() async {
    // Optionally create any extra categories chosen
    final catNotifier = ref.read(categoryProvider.notifier);
    for (final opt in _options) {
      if (_selectedCategories.contains(opt.name)) {
        final exists = ref.read(categoryProvider).categories.any((c) => c.name == opt.name);
        if (!exists) {
          await catNotifier.addCategory(
            name: opt.name,
            color: opt.color,
            iconCode: opt.icon.codePoint.toString(),
          );
        }
      }
    }

    if (mounted) {
      Navigator.of(context).pushReplacementNamed('/');
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.auto_awesome,
                  color: Theme.of(context).colorScheme.primary,
                  size: 28,
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'What would you like\nto organize?',
                style: AppTypography.displayMedium.copyWith(
                  fontWeight: FontWeight.w700,
                  color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                'FlowSpace will customize your default workspace and productivity views based on your focus.',
                style: AppTypography.bodyMedium.copyWith(
                  color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                ),
              ),
              const SizedBox(height: 28),

              // Selection Grid
              Expanded(
                child: GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 1.6,
                    crossAxisSpacing: 14,
                    mainAxisSpacing: 14,
                  ),
                  itemCount: _options.length,
                  itemBuilder: (context, index) {
                    final item = _options[index];
                    final isSelected = _selectedCategories.contains(item.name);

                    return InkWell(
                      onTap: () => _toggleCategory(item.name),
                      borderRadius: BorderRadius.circular(14),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? item.color.withValues(alpha: 0.12)
                              : (isDark ? AppColors.darkSurface : AppColors.lightSurface),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: isSelected
                                ? item.color
                                : (isDark ? AppColors.darkBorder : AppColors.lightBorder),
                            width: isSelected ? 2 : 1,
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Icon(item.icon, color: item.color, size: 24),
                                if (isSelected)
                                  Icon(Icons.check_circle, color: item.color, size: 20),
                              ],
                            ),
                            Text(
                              item.name,
                              style: AppTypography.titleMedium.copyWith(
                                fontWeight: FontWeight.w600,
                                color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),

              // Finish Setup Button
              SizedBox(
                width: double.infinity,
                height: 52,
                child: FilledButton(
                  onPressed: _finishSetup,
                  style: FilledButton.styleFrom(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Launch FlowSpace',
                        style: AppTypography.titleMedium.copyWith(color: Colors.white),
                      ),
                      const SizedBox(width: 8),
                      const Icon(Icons.arrow_forward, size: 18, color: Colors.white),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }
}
