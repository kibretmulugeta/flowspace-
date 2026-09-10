import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../../../core/widgets/custom_badge.dart';
import '../../domain/task_model.dart';

class TaskTile extends StatelessWidget {
  final Task task;
  final bool isSelected;
  final bool isSelectionMode;
  final VoidCallback onToggleComplete;
  final VoidCallback onTap;
  final VoidCallback onLongPress;
  final VoidCallback? onDelete;
  final String? categoryName;
  final Color? categoryColor;

  const TaskTile({
    super.key,
    required this.task,
    this.isSelected = false,
    this.isSelectionMode = false,
    required this.onToggleComplete,
    required this.onTap,
    required this.onLongPress,
    this.onDelete,
    this.categoryName,
    this.categoryColor,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final tileContent = InkWell(
      onTap: isSelectionMode ? onLongPress : onTap,
      onLongPress: onLongPress,
      borderRadius: BorderRadius.circular(12),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected
              ? Theme.of(context).colorScheme.primary.withValues(alpha: 0.08)
              : (isDark ? AppColors.darkCard : AppColors.lightCard),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? Theme.of(context).colorScheme.primary
                : (isDark ? AppColors.darkBorder : AppColors.lightBorder),
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Selection checkbox OR Task completion circle
            if (isSelectionMode)
              Padding(
                padding: const EdgeInsets.only(right: 12, top: 2),
                child: Icon(
                  isSelected ? Icons.check_box : Icons.check_box_outline_blank,
                  color: Theme.of(context).colorScheme.primary,
                  size: 22,
                ),
              )
            else
              GestureDetector(
                onTap: onToggleComplete,
                child: Padding(
                  padding: const EdgeInsets.only(right: 12, top: 2),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: 22,
                    height: 22,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: task.isCompleted
                          ? Theme.of(context).colorScheme.primary
                          : Colors.transparent,
                      border: Border.all(
                        color: task.isCompleted
                            ? Theme.of(context).colorScheme.primary
                            : task.priority.color,
                        width: 2,
                      ),
                    ),
                    child: task.isCompleted
                        ? const Icon(Icons.check, size: 14, color: Colors.white)
                        : null,
                  ),
                ),
              ),

            // Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title
                  Text(
                    task.title,
                    style: AppTypography.titleMedium.copyWith(
                      color: task.isCompleted
                          ? (isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted)
                          : (isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary),
                      decoration: task.isCompleted ? TextDecoration.lineThrough : null,
                    ),
                  ),

                  // Description snippet
                  if (task.description.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      task.description,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: AppTypography.bodySmall.copyWith(
                        color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                      ),
                    ),
                  ],

                  const SizedBox(height: 8),

                  // Metadata Badges Row: Date, Priority, Category, Subtasks
                  Wrap(
                    spacing: 6,
                    runSpacing: 4,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      // Due Date Badge
                      if (task.dueDate != null) ...[
                        _buildDateBadge(context, task.dueDate!, task.dueTime, isDark),
                      ],

                      // Priority Badge
                      if (task.priority != TaskPriority.none)
                        CustomBadge(
                          label: task.priority.label,
                          color: task.priority.color,
                        ),

                      // Category Chip
                      if (categoryName != null)
                        CustomBadge(
                          label: categoryName!,
                          color: categoryColor ?? AppColors.accentIndigo,
                          icon: Icons.label_outline,
                        ),

                      // Subtasks progress
                      if (task.subtasks.isNotEmpty) ...[
                        _buildSubtasksBadge(context, isDark),
                      ],

                      // Tags
                      for (final tag in task.tags.take(2))
                        CustomBadge(
                          label: '#$tag',
                          color: isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted,
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

    // Dismissible with swipe actions (swipe right = complete, swipe left = delete)
    if (isSelectionMode) return tileContent;

    return Dismissible(
      key: ValueKey(task.id),
      background: Container(
        margin: const EdgeInsets.symmetric(vertical: 4),
        padding: const EdgeInsets.symmetric(horizontal: 20),
        decoration: BoxDecoration(
          color: AppColors.accentEmerald,
          borderRadius: BorderRadius.circular(12),
        ),
        alignment: Alignment.centerLeft,
        child: const Icon(Icons.check, color: Colors.white, size: 24),
      ),
      secondaryBackground: Container(
        margin: const EdgeInsets.symmetric(vertical: 4),
        padding: const EdgeInsets.symmetric(horizontal: 20),
        decoration: BoxDecoration(
          color: AppColors.priorityUrgent,
          borderRadius: BorderRadius.circular(12),
        ),
        alignment: Alignment.centerRight,
        child: const Icon(Icons.delete_outline, color: Colors.white, size: 24),
      ),
      confirmDismiss: (direction) async {
        if (direction == DismissDirection.startToEnd) {
          onToggleComplete();
          return false; // Don't remove from widget tree immediately, let provider handle update
        } else {
          onDelete?.call();
          return true;
        }
      },
      child: tileContent,
    );
  }

  Widget _buildDateBadge(BuildContext context, DateTime date, String? time, bool isDark) {
    final isOverdue = !task.isCompleted && date.isBefore(DateTime.now().subtract(const Duration(days: 1)));
    final color = isOverdue
        ? AppColors.priorityUrgent
        : (isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary);

    final text = time != null
        ? '${DateFormatter.formatRelative(date)} at $time'
        : DateFormatter.formatRelative(date);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(5),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.calendar_today, size: 11, color: color),
          const SizedBox(width: 4),
          Text(
            text,
            style: AppTypography.labelSmall.copyWith(color: color, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }

  Widget _buildSubtasksBadge(BuildContext context, bool isDark) {
    final completedCount = task.subtasksCompleted.where((c) => c).length;
    final totalCount = task.subtasks.length;
    final color = isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(5),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.checklist, size: 12, color: color),
          const SizedBox(width: 4),
          Text(
            '$completedCount/$totalCount',
            style: AppTypography.labelSmall.copyWith(color: color),
          ),
        ],
      ),
    );
  }
}
