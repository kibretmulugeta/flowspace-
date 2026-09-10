import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/custom_badge.dart';
import '../../../../core/widgets/empty_state_view.dart';
import '../../../tasks/presentation/task_provider.dart';
import '../project_provider.dart';
import '../widgets/project_edit_sheet.dart';
import 'project_detail_screen.dart';

class ProjectsScreen extends ConsumerWidget {
  const ProjectsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final projectState = ref.watch(projectProvider);
    final taskState = ref.watch(taskProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final projects = projectState.projects;

    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.navProjects),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () => Navigator.of(context).pushNamed('/search'),
          ),
        ],
      ),
      body: projects.isEmpty
          ? EmptyStateView(
              icon: Icons.rocket_launch_outlined,
              title: AppStrings.emptyProjectsTitle,
              subtitle: AppStrings.emptyProjectsSubtitle,
              actionLabel: 'New Project',
              onAction: () => ProjectEditSheet.show(context),
            )
          : ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              itemCount: projects.length,
              itemBuilder: (context, index) {
                final proj = projects[index];
                final tasks = taskState.tasks.where((t) => t.projectId == proj.id).toList();
                final completed = tasks.where((t) => t.isCompleted).length;
                final progress = tasks.isNotEmpty ? completed / tasks.length : 0.0;

                return InkWell(
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => ProjectDetailScreen(projectId: proj.id),
                      ),
                    );
                  },
                  borderRadius: BorderRadius.circular(14),
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: isDark ? AppColors.darkCard : AppColors.lightCard,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: (isDark
                                        ? AppColors.darkSurfaceVariant
                                        : AppColors.lightSurfaceVariant)
                                    .withValues(alpha: 0.7),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text(proj.icon, style: const TextStyle(fontSize: 22)),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    proj.name,
                                    style: AppTypography.titleLarge.copyWith(fontWeight: FontWeight.w700),
                                  ),
                                  if (proj.description.isNotEmpty) ...[
                                    const SizedBox(height: 2),
                                    Text(
                                      proj.description,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: AppTypography.bodySmall.copyWith(
                                        color: isDark
                                            ? AppColors.darkTextSecondary
                                            : AppColors.lightTextSecondary,
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                            CustomBadge(
                              label: proj.status.label,
                              color: proj.status.color,
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),

                        // Progress Bar
                        ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: LinearProgressIndicator(
                            value: progress,
                            minHeight: 6,
                            backgroundColor: isDark
                                ? AppColors.darkSurfaceVariant
                                : AppColors.lightSurfaceVariant,
                            valueColor: AlwaysStoppedAnimation(proj.color),
                          ),
                        ),
                        const SizedBox(height: 8),

                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              '${tasks.length} tasks • $completed completed',
                              style: AppTypography.labelSmall.copyWith(
                                color: isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted,
                              ),
                            ),
                            Text(
                              '${(progress * 100).toInt()}%',
                              style: AppTypography.labelSmall.copyWith(
                                fontWeight: FontWeight.w600,
                                color: proj.color,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => ProjectEditSheet.show(context),
        child: const Icon(Icons.add),
      ),
    );
  }
}
