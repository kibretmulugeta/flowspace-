import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../calendar/presentation/calendar_provider.dart';
import '../../../notes/presentation/notes_provider.dart';
import '../../../projects/presentation/project_provider.dart';
import '../../../tasks/presentation/task_provider.dart';

class AnalyticsScreen extends ConsumerWidget {
  const AnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final taskState = ref.watch(taskProvider);
    final calendarState = ref.watch(calendarProvider);
    final notesState = ref.watch(notesProvider);
    final projectState = ref.watch(projectProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final totalTasks = taskState.tasks.length;
    final completedTasks = taskState.tasks.where((t) => t.isCompleted).length;
    final pendingTasks = totalTasks - completedTasks;
    final completionPct = totalTasks > 0 ? (completedTasks / totalTasks * 100).toInt() : 100;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Productivity Analytics'),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        children: [
          // Weekly Velocity Score Card
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Theme.of(context).colorScheme.primary,
                  Theme.of(context).colorScheme.primary.withValues(alpha: 0.8),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Weekly Velocity Score',
                  style: AppTypography.titleMedium.copyWith(color: Colors.white70),
                ),
                const SizedBox(height: 6),
                Text(
                  '88 / 100',
                  style: AppTypography.displayLarge.copyWith(color: Colors.white, fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 8),
                Text(
                  'Top 5% consistency this week. You completed $completedTasks tasks and organized ${notesState.pages.length} wiki pages.',
                  style: AppTypography.bodySmall.copyWith(color: Colors.white.withValues(alpha: 0.9)),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Core Metrics Grid
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 1.4,
            children: [
              _buildStatCard(
                'Tasks Completed',
                '$completedTasks',
                '$completionPct% completion rate',
                AppColors.accentIndigo,
                isDark,
              ),
              _buildStatCard(
                'Pending Tasks',
                '$pendingTasks',
                'Active in pipeline',
                AppColors.accentAmber,
                isDark,
              ),
              _buildStatCard(
                'Scheduled Events',
                '${calendarState.events.length}',
                'Across 2 calendars',
                AppColors.accentEmerald,
                isDark,
              ),
              _buildStatCard(
                'Active Projects',
                '${projectState.projects.length}',
                '100% on schedule',
                AppColors.accentViolet,
                isDark,
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Simulated 7-day completion bar chart
          Text('7-Day Activity Velocity', style: AppTypography.labelLarge),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isDark ? AppColors.darkCard : AppColors.lightCard,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: isDark ? AppColors.darkBorder : AppColors.lightBorder),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                _buildBar('Mon', 0.6, isDark, Theme.of(context).colorScheme.primary),
                _buildBar('Tue', 0.8, isDark, Theme.of(context).colorScheme.primary),
                _buildBar('Wed', 0.4, isDark, Theme.of(context).colorScheme.primary),
                _buildBar('Thu', 0.9, isDark, Theme.of(context).colorScheme.primary),
                _buildBar('Fri', 0.7, isDark, Theme.of(context).colorScheme.primary),
                _buildBar('Sat', 0.3, isDark, Theme.of(context).colorScheme.primary),
                _buildBar('Sun', 0.5, isDark, Theme.of(context).colorScheme.primary),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String title, String value, String subtitle, Color color, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : AppColors.lightCard,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: isDark ? AppColors.darkBorder : AppColors.lightBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: AppTypography.labelSmall),
          Text(
            value,
            style: AppTypography.displaySmall.copyWith(
              color: color,
              fontWeight: FontWeight.w700,
            ),
          ),
          Text(
            subtitle,
            style: AppTypography.labelSmall.copyWith(
              color: isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBar(String label, double heightFraction, bool isDark, Color color) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 18,
          height: 100 * heightFraction,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.85),
            borderRadius: BorderRadius.circular(6),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: AppTypography.labelSmall.copyWith(
            color: isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted,
          ),
        ),
      ],
    );
  }
}
