import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../../../core/widgets/custom_badge.dart';
import '../../../calendar/presentation/calendar_provider.dart';
import '../../../calendar/presentation/widgets/event_edit_sheet.dart';
import '../../../notes/presentation/notes_provider.dart';
import '../../../notes/presentation/screens/note_editor_screen.dart';
import '../../../tasks/presentation/task_provider.dart';
import '../../../tasks/presentation/widgets/task_edit_sheet.dart';
import '../../../tasks/presentation/widgets/task_tile.dart';
import '../../domain/project_model.dart';
import '../project_provider.dart';
import '../widgets/project_edit_sheet.dart';

class ProjectDetailScreen extends ConsumerStatefulWidget {
  final String projectId;

  const ProjectDetailScreen({super.key, required this.projectId});

  @override
  ConsumerState<ProjectDetailScreen> createState() => _ProjectDetailScreenState();
}

class _ProjectDetailScreenState extends ConsumerState<ProjectDetailScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final projectState = ref.watch(projectProvider);
    final taskState = ref.watch(taskProvider);
    final notesState = ref.watch(notesProvider);
    final calendarState = ref.watch(calendarProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final project = projectState.projects.cast<Project?>().firstWhere(
          (p) => p?.id == widget.projectId,
          orElse: () => null,
        );

    if (project == null) {
      return Scaffold(
        appBar: AppBar(),
        body: const Center(child: Text('Project not found')),
      );
    }

    // Filter project-specific items
    final projectTasks = taskState.tasks.where((t) => t.projectId == project.id).toList();
    final projectNotes = notesState.pages.where((p) => p.projectId == project.id && !p.isTrash).toList();
    final projectEvents = calendarState.events.where((e) => e.projectId == project.id).toList();

    final completedTasks = projectTasks.where((t) => t.isCompleted).length;
    final progress = projectTasks.isNotEmpty ? completedTasks / projectTasks.length : 0.0;

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Text(project.icon, style: const TextStyle(fontSize: 20)),
            const SizedBox(width: 8),
            Expanded(child: Text(project.name, overflow: TextOverflow.ellipsis)),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            onPressed: () => ProjectEditSheet.show(context, existingProject: project),
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          tabAlignment: TabAlignment.start,
          tabs: const [
            Tab(text: 'Overview'),
            Tab(text: 'Tasks'),
            Tab(text: 'Notes'),
            Tab(text: 'Calendar'),
            Tab(text: 'Activity'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // 1. Overview Tab
          _buildOverviewTab(context, project, progress, completedTasks, projectTasks.length, isDark),

          // 2. Tasks Tab
          _buildTasksTab(context, projectTasks, isDark),

          // 3. Notes Tab
          _buildNotesTab(context, projectNotes, isDark),

          // 4. Calendar Tab
          _buildCalendarTab(context, projectEvents, isDark),

          // 5. Activity Tab
          _buildActivityTab(context, isDark),
        ],
      ),
    );
  }

  Widget _buildOverviewTab(
    BuildContext context,
    Project project,
    double progress,
    int completed,
    int total,
    bool isDark,
  ) {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        // Status and Due Date Card
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isDark ? AppColors.darkCard : AppColors.lightCard,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: isDark ? AppColors.darkBorder : AppColors.lightBorder),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  CustomBadge(
                    label: project.status.label,
                    color: project.status.color,
                    isFilled: true,
                  ),
                  if (project.dueDate != null)
                    Row(
                      children: [
                        const Icon(Icons.calendar_today, size: 14),
                        const SizedBox(width: 6),
                        Text(
                          'Due ${DateFormatter.formatShort(project.dueDate!)}',
                          style: AppTypography.bodySmall,
                        ),
                      ],
                    ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                project.description.isNotEmpty ? project.description : 'No description provided.',
                style: AppTypography.bodyMedium,
              ),
              const SizedBox(height: 16),

              // Progress Bar
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Task Progress', style: AppTypography.labelSmall),
                  Text('${(progress * 100).toInt()}% ($completed/$total)', style: AppTypography.labelSmall),
                ],
              ),
              const SizedBox(height: 6),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: progress,
                  minHeight: 8,
                  backgroundColor: isDark ? AppColors.darkSurfaceVariant : AppColors.lightSurfaceVariant,
                  valueColor: AlwaysStoppedAnimation(project.color),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),

        // Quick Stats Row
        Row(
          children: [
            Expanded(
              child: _buildMetricCard(
                context,
                icon: Icons.check_circle_outline,
                title: '$total',
                subtitle: 'Total Tasks',
                color: AppColors.accentIndigo,
                isDark: isDark,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildMetricCard(
                context,
                icon: Icons.article_outlined,
                title: '${project.notePageIds.length}',
                subtitle: 'Wiki Pages',
                color: AppColors.accentEmerald,
                isDark: isDark,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildMetricCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required bool isDark,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : AppColors.lightCard,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: isDark ? AppColors.darkBorder : AppColors.lightBorder),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 20, color: color),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: AppTypography.titleLarge.copyWith(fontWeight: FontWeight.w700)),
              Text(subtitle, style: AppTypography.labelSmall),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTasksTab(BuildContext context, List<dynamic> projectTasks, bool isDark) {
    final taskNotifier = ref.read(taskProvider.notifier);

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('${projectTasks.length} Project Tasks', style: AppTypography.titleMedium),
              FilledButton.tonalIcon(
                onPressed: () => TaskEditSheet.show(context),
                icon: const Icon(Icons.add, size: 16),
                label: const Text('Add Task'),
              ),
            ],
          ),
        ),
        Expanded(
          child: projectTasks.isEmpty
              ? const Center(child: Text('No tasks created for this project yet.'))
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  itemCount: projectTasks.length,
                  itemBuilder: (context, index) {
                    final t = projectTasks[index];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: TaskTile(
                        task: t,
                        onToggleComplete: () => taskNotifier.toggleTaskCompletion(t.id),
                        onTap: () => TaskEditSheet.show(context, existingTask: t),
                        onLongPress: () {},
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildNotesTab(BuildContext context, List<dynamic> projectNotes, bool isDark) {
    final notesNotifier = ref.read(notesProvider.notifier);

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('${projectNotes.length} Project Pages', style: AppTypography.titleMedium),
              FilledButton.tonalIcon(
                onPressed: () async {
                  final newPage = await notesNotifier.createPage(projectId: widget.projectId);
                  if (context.mounted) {
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => NoteEditorScreen(pageId: newPage.id)),
                    );
                  }
                },
                icon: const Icon(Icons.add, size: 16),
                label: const Text('New Page'),
              ),
            ],
          ),
        ),
        Expanded(
          child: projectNotes.isEmpty
              ? const Center(child: Text('No wiki notes attached to this project.'))
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  itemCount: projectNotes.length,
                  itemBuilder: (context, index) {
                    final note = projectNotes[index];
                    return ListTile(
                      leading: Text(note.icon, style: const TextStyle(fontSize: 22)),
                      title: Text(note.title),
                      subtitle: Text('${note.blocks.length} blocks'),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(builder: (_) => NoteEditorScreen(pageId: note.id)),
                        );
                      },
                    );
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildCalendarTab(BuildContext context, List<dynamic> projectEvents, bool isDark) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('${projectEvents.length} Scheduled Events', style: AppTypography.titleMedium),
              FilledButton.tonalIcon(
                onPressed: () => EventEditSheet.show(context),
                icon: const Icon(Icons.add, size: 16),
                label: const Text('Schedule'),
              ),
            ],
          ),
        ),
        Expanded(
          child: projectEvents.isEmpty
              ? const Center(child: Text('No calendar events scheduled for this project.'))
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  itemCount: projectEvents.length,
                  itemBuilder: (context, index) {
                    final ev = projectEvents[index];
                    return ListTile(
                      leading: Container(
                        width: 4,
                        height: 32,
                        color: ev.color,
                      ),
                      title: Text(ev.title),
                      subtitle: Text(
                        '${DateFormatter.formatShort(ev.startDateTime)} at ${DateFormatter.formatTime(ev.startDateTime)}',
                      ),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () => EventEditSheet.show(context, existingEvent: ev),
                    );
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildActivityTab(BuildContext context, bool isDark) {
    final activities = const [
      'Project milestones reviewed',
      'Validation ablation experiment completed',
      'Architecture design document drafted',
      'Initial task backlog populated',
    ];

    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: activities.length,
      itemBuilder: (context, index) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                margin: const EdgeInsets.only(top: 4),
                width: 10,
                height: 10,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(activities[index], style: AppTypography.titleMedium),
                    const SizedBox(height: 2),
                    Text(
                      '${index + 1} day ago by Kibret',
                      style: AppTypography.labelSmall.copyWith(
                        color: isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
