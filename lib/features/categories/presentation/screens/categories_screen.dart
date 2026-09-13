import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/empty_state_view.dart';
import '../../../tasks/presentation/task_provider.dart';
import '../../domain/category_model.dart';
import '../category_provider.dart';
import '../widgets/category_edit_sheet.dart';

class CategoriesScreen extends ConsumerWidget {
  const CategoriesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categoryState = ref.watch(categoryProvider);
    final taskState = ref.watch(taskProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final categories = categoryState.categories;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Categories'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            tooltip: 'Add Category',
            onPressed: () => CategoryEditSheet.show(context),
          ),
        ],
      ),
      body: categories.isEmpty
          ? EmptyStateView(
              icon: Icons.category_outlined,
              title: 'No Categories Yet',
              subtitle: 'Organize your tasks, notes, and projects into custom categories.',
              actionLabel: 'New Category',
              onAction: () => CategoryEditSheet.show(context),
            )
          : ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              itemCount: categories.length,
              itemBuilder: (context, index) {
                final cat = categories[index];
                final taskCount = taskState.tasks.where((t) => t.categoryId == cat.id).length;

                return Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.darkCard : AppColors.lightCard,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                    ),
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                    leading: Container(
                      width: 44,
                      height: 44,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: cat.color.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        cat.iconCode.isNotEmpty ? cat.iconCode : '📁',
                        style: const TextStyle(fontSize: 22),
                      ),
                    ),
                    title: Text(
                      cat.name,
                      style: AppTypography.titleMedium.copyWith(fontWeight: FontWeight.w600),
                    ),
                    subtitle: Text(
                      '$taskCount active task${taskCount == 1 ? '' : 's'}',
                      style: AppTypography.bodySmall.copyWith(
                        color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                      ),
                    ),
                    trailing: PopupMenuButton<String>(
                      icon: const Icon(Icons.more_vert, size: 20),
                      onSelected: (val) {
                        if (val == 'edit') {
                          CategoryEditSheet.show(context, existingCategory: cat);
                        } else if (val == 'delete') {
                          _confirmDelete(context, ref, cat);
                        }
                      },
                      itemBuilder: (_) => [
                        const PopupMenuItem(
                          value: 'edit',
                          child: Row(
                            children: [
                              Icon(Icons.edit_outlined, size: 18),
                              SizedBox(width: 8),
                              Text('Edit'),
                            ],
                          ),
                        ),
                        const PopupMenuItem(
                          value: 'delete',
                          child: Row(
                            children: [
                              Icon(Icons.delete_outline, size: 18, color: Colors.redAccent),
                              SizedBox(width: 8),
                              Text('Delete', style: TextStyle(color: Colors.redAccent)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => CategoryEditSheet.show(context),
        child: const Icon(Icons.add),
      ),
    );
  }

  void _confirmDelete(BuildContext context, WidgetRef ref, Category category) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Category?'),
        content: Text(
          'Are you sure you want to delete "${category.name}"? Tasks assigned to this category will not be deleted.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.redAccent),
            onPressed: () {
              ref.read(categoryProvider.notifier).deleteCategory(category.id);
              Navigator.of(ctx).pop();
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}
