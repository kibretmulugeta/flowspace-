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
import '../../../categories/presentation/category_provider.dart';
import '../../../categories/presentation/widgets/category_edit_sheet.dart';
import '../../../notes/presentation/notes_provider.dart';
import '../../../notes/presentation/screens/note_editor_screen.dart';
import '../../../projects/presentation/project_provider.dart';
import '../../../projects/presentation/screens/project_detail_screen.dart';
import '../../../projects/presentation/widgets/project_edit_sheet.dart';
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
    final projectState = ref.watch(projectProvider);
    final categoryState = ref.watch(categoryProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final projects = projectState.projects;
    final categories = categoryState.categories;

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
          await ref.read(projectProvider.notifier).loadProjects();
          await ref.read(categoryProvider.notifier).loadCategories();
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

            const SizedBox(height: 24),

            // PROJECTS Section
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Projects', style: AppTypography.titleLarge),
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.add, size: 20),
                      tooltip: 'Add Project',
                      onPressed: () => ProjectEditSheet.show(context),
                    ),
                    GestureDetector(
                      onTap: () => Navigator.of(context).pushNamed('/projects'),
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
              ],
            ),
            const SizedBox(height: 12),
            _buildProjectsSection(context, projects, taskState.tasks, isDark),
            const SizedBox(height: 24),

            // CATEGORIES Section
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Categories', style: AppTypography.titleLarge),
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.add, size: 20),
                      tooltip: 'Add Category',
                      onPressed: () => CategoryEditSheet.show(context),
                    ),
                    GestureDetector(
                      onTap: () => Navigator.of(context).pushNamed('/categories'),
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
              ],
            ),
            const SizedBox(height: 12),
            _buildCategoriesSection(context, categories, taskState.tasks, isDark),

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

  Widget _buildProjectsSection(
    BuildContext context,
    List<dynamic> projects,
    List<dynamic> allTasks,
    bool isDark,
  ) {
    if (projects.isEmpty) {
      return InkWell(
        onTap: () => ProjectEditSheet.show(context),
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isDark ? AppColors.darkCard : AppColors.lightCard,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: isDark ? AppColors.darkBorder : AppColors.lightBorder),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.add_circle_outline, size: 20),
              const SizedBox(width: 8),
              Text(
                'Add your first project',
                style: AppTypography.bodyMedium.copyWith(
                  color: Theme.of(context).colorScheme.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return SizedBox(
      height: 140,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: projects.length + 1,
        itemBuilder: (context, index) {
          if (index == projects.length) {
            return InkWell(
              onTap: () => ProjectEditSheet.show(context),
              borderRadius: BorderRadius.circular(14),
              child: Container(
                width: 120,
                margin: const EdgeInsets.only(right: 12),
                decoration: BoxDecoration(
                  color: (isDark ? AppColors.darkSurfaceVariant : AppColors.lightSurfaceVariant)
                      .withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.add, size: 28, color: Theme.of(context).colorScheme.primary),
                    const SizedBox(height: 6),
                    Text(
                      'New Project',
                      style: AppTypography.labelSmall.copyWith(fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              ),
            );
          }

          final proj = projects[index];
          final tasks = allTasks.where((t) => t.projectId == proj.id).toList();
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
              width: 200,
              margin: const EdgeInsets.only(right: 12),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkCard : AppColors.lightCard,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Text(proj.icon, style: const TextStyle(fontSize: 20)),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          proj.name,
                          style: AppTypography.titleMedium.copyWith(fontWeight: FontWeight.w700),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(3),
                        child: LinearProgressIndicator(
                          value: progress,
                          minHeight: 4,
                          backgroundColor: isDark
                              ? AppColors.darkSurfaceVariant
                              : AppColors.lightSurfaceVariant,
                          valueColor: AlwaysStoppedAnimation(proj.color),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '$completed/${tasks.length} tasks',
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
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildCategoriesSection(
    BuildContext context,
    List<dynamic> categories,
    List<dynamic> allTasks,
    bool isDark,
  ) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          for (final cat in categories) ...[
            Padding(
              padding: const EdgeInsets.only(right: 8.0),
              child: ActionChip(
                avatar: Text(
                  cat.iconCode.isNotEmpty ? cat.iconCode : '📁',
                  style: const TextStyle(fontSize: 16),
                ),
                label: Text(
                  '${cat.name} (${allTasks.where((t) => t.categoryId == cat.id).length})',
                ),
                backgroundColor: isDark ? AppColors.darkCard : AppColors.lightCard,
                side: BorderSide(
                  color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                ),
                onPressed: () {
                  Navigator.of(context).pushNamed('/categories');
                },
              ),
            ),
          ],
          ActionChip(
            avatar: const Icon(Icons.add, size: 16),
            label: const Text('Add Category'),
            onPressed: () => CategoryEditSheet.show(context),
          ),
        ],
      ),
    );
  }
}
