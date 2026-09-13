import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/empty_state_view.dart';
import '../../../categories/presentation/category_provider.dart';
import '../../../categories/presentation/widgets/category_edit_sheet.dart';
import '../../../projects/presentation/project_provider.dart';
import '../../../projects/presentation/widgets/project_edit_sheet.dart';
import '../task_provider.dart';
import '../widgets/task_edit_sheet.dart';
import '../widgets/task_tile.dart';

class TasksScreen extends ConsumerWidget {
  const TasksScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final taskState = ref.watch(taskProvider);
    final taskNotifier = ref.read(taskProvider.notifier);
    final categories = ref.watch(categoryProvider).categories;
    final projects = ref.watch(projectProvider).projects;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final filteredTasks = taskState.filteredTasks;

    return Scaffold(
      appBar: AppBar(
        title: taskState.isSelectionMode
            ? Text('${taskState.selectedTaskIds.length} Selected')
            : const Text(AppStrings.navTasks),
        leading: taskState.isSelectionMode
            ? IconButton(
                icon: const Icon(Icons.close),
                onPressed: taskNotifier.clearSelection,
              )
            : null,
        actions: [
          if (taskState.isSelectionMode) ...[
            IconButton(
              icon: const Icon(Icons.check_circle_outline),
              tooltip: 'Complete selected',
              onPressed: taskNotifier.bulkCompleteSelected,
            ),
            IconButton(
              icon: const Icon(Icons.delete_outline),
              tooltip: 'Delete selected',
              onPressed: taskNotifier.bulkDeleteSelected,
            ),
          ] else ...[
            IconButton(
              icon: const Icon(Icons.search),
              tooltip: 'Search',
              onPressed: () => Navigator.of(context).pushNamed('/search'),
            ),
          ],
        ],
      ),
      body: Column(
        children: [
          // Filter Tabs (Inbox, Today, Upcoming, Completed)
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: TaskViewFilter.values.map((filter) {
                final isSelected = taskState.activeFilter == filter;
                return Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: FilterChip(
                    label: Text(filter.label),
                    selected: isSelected,
                    onSelected: (_) => taskNotifier.setFilter(filter),
                    showCheckmark: false,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                      side: BorderSide(
                        color: isSelected
                            ? Theme.of(context).colorScheme.primary
                            : (isDark ? AppColors.darkBorder : AppColors.lightBorder),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),

          // Secondary Filter (Project / Category pills with Quick Add)
          Container(
            height: 36,
            margin: const EdgeInsets.only(bottom: 6),
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: [
                // All filter chip
                Padding(
                  padding: const EdgeInsets.only(right: 6.0),
                  child: ChoiceChip(
                    label: const Text('All Focus'),
                    selected: taskState.selectedProjectId == null &&
                        taskState.selectedCategoryId == null,
                    onSelected: (_) {
                      taskNotifier.setProjectFilter(null);
                      taskNotifier.setCategoryFilter(null);
                    },
                  ),
                ),
                for (final proj in projects)
                  Padding(
                    padding: const EdgeInsets.only(right: 6.0),
                    child: ChoiceChip(
                      label: Text('${proj.icon} ${proj.name}'),
                      selected: taskState.selectedProjectId == proj.id,
                      onSelected: (selected) {
                        taskNotifier.setProjectFilter(selected ? proj.id : null);
                      },
                    ),
                  ),
                for (final cat in categories)
                  Padding(
                    padding: const EdgeInsets.only(right: 6.0),
                    child: ChoiceChip(
                      label: Text(cat.name),
                      selected: taskState.selectedCategoryId == cat.id,
                      onSelected: (selected) {
                        taskNotifier.setCategoryFilter(selected ? cat.id : null);
                      },
                    ),
                  ),
                // Quick Add Category Chip
                Padding(
                  padding: const EdgeInsets.only(right: 6.0),
                  child: ActionChip(
                    avatar: const Icon(Icons.add, size: 14),
                    label: const Text('Category'),
                    onPressed: () => CategoryEditSheet.show(context),
                  ),
                ),
                // Quick Add Project Chip
                Padding(
                  padding: const EdgeInsets.only(right: 6.0),
                  child: ActionChip(
                    avatar: const Icon(Icons.add, size: 14),
                    label: const Text('Project'),
                    onPressed: () => ProjectEditSheet.show(context),
                  ),
                ),
              ],
            ),
          ),

          const Divider(height: 1),

          // Task List or Empty State
          Expanded(
            child: filteredTasks.isEmpty
                ? EmptyStateView(
                    icon: Icons.check_circle_outline,
                    title: AppStrings.emptyTasksTitle,
                    subtitle: AppStrings.emptyTasksSubtitle,
                    actionLabel: 'New Task',
                    onAction: () => TaskEditSheet.show(context),
                  )
                : ReorderableListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    itemCount: filteredTasks.length,
                    // ignore: deprecated_member_use
                    onReorder: (oldIdx, newIdx) => taskNotifier.reorderTasks(oldIdx, newIdx),
                    itemBuilder: (context, index) {
                      final task = filteredTasks[index];
                      final category = categories.cast<dynamic>().firstWhere(
                            (c) => c.id == task.categoryId,
                            orElse: () => null,
                          );

                      return Padding(
                        key: ValueKey(task.id),
                        padding: const EdgeInsets.only(bottom: 8),
                        child: TaskTile(
                          task: task,
                          isSelected: taskState.selectedTaskIds.contains(task.id),
                          isSelectionMode: taskState.isSelectionMode,
                          categoryName: category?.name,
                          categoryColor: category?.color,
                          onToggleComplete: () => taskNotifier.toggleTaskCompletion(task.id),
                          onTap: () => TaskEditSheet.show(context, existingTask: task),
                          onLongPress: () => taskNotifier.toggleTaskSelection(task.id),
                          onDelete: () => taskNotifier.deleteTask(task.id),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => TaskEditSheet.show(context),
        child: const Icon(Icons.add),
      ),
    );
  }
}
