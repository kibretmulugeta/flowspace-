import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../../../core/widgets/custom_badge.dart';
import '../../../auth/presentation/auth_provider.dart';
import '../../../calendar/presentation/calendar_provider.dart';
import '../../../calendar/presentation/widgets/event_edit_sheet.dart';
import '../../../notes/presentation/notes_provider.dart';
import '../../../notes/presentation/screens/note_editor_screen.dart';
import '../../../reminders/presentation/reminder_provider.dart';
import '../../../reminders/presentation/widgets/reminder_edit_sheet.dart';
import '../../../tasks/presentation/task_provider.dart';
import '../../../tasks/presentation/widgets/task_edit_sheet.dart';
import '../../../tasks/presentation/widgets/task_tile.dart';

class HomeDashboardScreen extends ConsumerWidget {
  const HomeDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);
    final taskState = ref.watch(taskProvider);
    final calendarState = ref.watch(calendarProvider);
    final reminderState = ref.watch(reminderProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final userName = authState.user?.displayName ?? AppStrings.defaultUser;
    final now = DateTime.now();

    // Calculations for Productivity metrics
    final todayTasks = taskState.tasks.where((t) {
      if (t.dueDate == null) return false;
      return DateFormatter.isSameDay(t.dueDate!, now);
    }).toList();

    final completedToday = todayTasks.where((t) => t.isCompleted).length;
    final totalToday = todayTasks.length;
    final completionRate = totalToday > 0 ? (completedToday / totalToday) : 1.0;

    // Upcoming events / Next up items
    final upcomingEvents = List.from(calendarState.visibleEvents)
      ..sort((a, b) => a.startDateTime.compareTo(b.startDateTime));
    final nextEvents = upcomingEvents.take(4).toList();

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.space_dashboard_rounded, color: Colors.white, size: 18),
            ),
            const SizedBox(width: 10),
            Text(
              'FlowSpace',
              style: AppTypography.titleLarge.copyWith(fontWeight: FontWeight.w700),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            tooltip: 'Search',
            onPressed: () => Navigator.of(context).pushNamed('/search'),
          ),
          IconButton(
            icon: Badge.count(
              count: reminderState.pendingReminders.length,
              isLabelVisible: reminderState.pendingReminders.isNotEmpty,
              child: const Icon(Icons.notifications_none),
            ),
            tooltip: 'Reminders & Notifications',
            onPressed: () => Navigator.of(context).pushNamed('/reminders'),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          await ref.read(taskProvider.notifier).loadTasks();
          await ref.read(calendarProvider.notifier).loadData();
          await ref.read(reminderProvider.notifier).loadReminders();
        },
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          children: [
            // Greeting Banner
            Text(
              'Good ${DateFormatter.formatGreetingTime()}, $userName',
              style: AppTypography.displayMedium.copyWith(
                fontWeight: FontWeight.w700,
                color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              DateFormatter.formatHeader(now),
              style: AppTypography.bodyMedium.copyWith(
                color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
              ),
            ),
            const SizedBox(height: 20),

            // Quick Actions Horizontal Bar
            _buildQuickActions(context, ref, isDark),
            const SizedBox(height: 24),

            // Productivity Summary Card
            _buildProductivityCard(context, completionRate, completedToday, totalToday, isDark),
            const SizedBox(height: 24),

            // NEXT UP Section (Upcoming events & meetings)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(AppStrings.nextUpSection, style: AppTypography.titleLarge),
                GestureDetector(
                  onTap: () => Navigator.of(context).pushNamed('/calendar'),
                  child: Text(
                    'View Calendar',
                    style: AppTypography.labelSmall.copyWith(
                      color: Theme.of(context).colorScheme.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (nextEvents.isEmpty)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.darkCard : AppColors.lightCard,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: isDark ? AppColors.darkBorder : AppColors.lightBorder),
                ),
                child: Center(
                  child: Text(
                    'No scheduled events upcoming.',
                    style: AppTypography.bodySmall.copyWith(
                      color: isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted,
                    ),
                  ),
                ),
              )
            else
              for (final ev in nextEvents)
                _buildNextEventTile(context, ev, isDark),

            const SizedBox(height: 24),

            // TODAY Section (Today's Tasks)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(AppStrings.todaySection, style: AppTypography.titleLarge),
                GestureDetector(
                  onTap: () => Navigator.of(context).pushNamed('/tasks'),
                  child: Text(
                    'View All',
                    style: AppTypography.labelSmall.copyWith(
                      color: Theme.of(context).colorScheme.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (todayTasks.isEmpty)
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.darkCard : AppColors.lightCard,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: isDark ? AppColors.darkBorder : AppColors.lightBorder),
                ),
                child: Center(
                  child: Text(
                    'All tasks caught up for today!',
                    style: AppTypography.bodyMedium.copyWith(
                      color: isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted,
                    ),
                  ),
                ),
              )
            else
              for (final task in todayTasks.take(4))
                Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: TaskTile(
                    task: task,
                    onToggleComplete: () =>
                        ref.read(taskProvider.notifier).toggleTaskCompletion(task.id),
                    onTap: () => TaskEditSheet.show(context, existingTask: task),
                    onLongPress: () {},
                  ),
                ),

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActions(BuildContext context, WidgetRef ref, bool isDark) {
    final actions = [
      (
        label: AppStrings.quickAddTask,
        icon: Icons.check_circle_outline,
        color: AppColors.accentIndigo,
        onTap: () => TaskEditSheet.show(context),
      ),
      (
        label: AppStrings.quickAddEvent,
        icon: Icons.calendar_month_outlined,
        color: AppColors.accentEmerald,
        onTap: () => EventEditSheet.show(context),
      ),
      (
        label: AppStrings.quickAddReminder,
        icon: Icons.alarm,
        color: AppColors.accentAmber,
        onTap: () => ReminderEditSheet.show(context),
      ),
      (
        label: AppStrings.quickAddNote,
        icon: Icons.article_outlined,
        color: AppColors.accentViolet,
        onTap: () async {
          final page = await ref.read(notesProvider.notifier).createPage();
          if (context.mounted) {
            Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => NoteEditorScreen(pageId: page.id)),
            );
          }
        },
      ),
    ];

    return Row(
      children: actions.map((act) {
        return Expanded(
          child: GestureDetector(
            onTap: act.onTap,
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 4),
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkCard : AppColors.lightCard,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: act.color.withValues(alpha: 0.12),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(act.icon, size: 20, color: act.color),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '+ ${act.label}',
                    style: AppTypography.labelSmall.copyWith(fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildProductivityCard(
    BuildContext context,
    double rate,
    int completed,
    int total,
    bool isDark,
  ) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : AppColors.lightCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(AppStrings.productivitySection, style: AppTypography.titleMedium),
              CustomBadge(
                label: total > 0 ? '${(rate * 100).toInt()}% Done' : '100% On Track',
                color: AppColors.accentEmerald,
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              // Circular progress ring
              SizedBox(
                width: 64,
                height: 64,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    CircularProgressIndicator(
                      value: total > 0 ? rate : 1.0,
                      strokeWidth: 6,
                      backgroundColor: isDark
                          ? AppColors.darkSurfaceVariant
                          : AppColors.lightSurfaceVariant,
                      valueColor: AlwaysStoppedAnimation(
                        Theme.of(context).colorScheme.primary,
                      ),
                    ),
                    Center(
                      child: Text(
                        '$completed/$total',
                        style: AppTypography.labelLarge.copyWith(fontWeight: FontWeight.w700),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '$completed of $total daily targets achieved',
                      style: AppTypography.bodyMedium.copyWith(fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Estimated focus time today: 2h 45m',
                      style: AppTypography.bodySmall.copyWith(
                        color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildNextEventTile(BuildContext context, dynamic ev, bool isDark) {
    return InkWell(
      onTap: () => EventEditSheet.show(context, existingEvent: ev),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkCard : AppColors.lightCard,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: isDark ? AppColors.darkBorder : AppColors.lightBorder),
        ),
        child: Row(
          children: [
            Container(
              width: 4,
              height: 36,
              decoration: BoxDecoration(
                color: ev.color,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(ev.title, style: AppTypography.titleMedium.copyWith(fontWeight: FontWeight.w600)),
                  const SizedBox(height: 2),
                  Text(
                    '${DateFormatter.formatShort(ev.startDateTime)} • ${DateFormatter.formatTime(ev.startDateTime)}',
                    style: AppTypography.bodySmall.copyWith(
                      color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, size: 18),
          ],
        ),
      ),
    );
  }
}
