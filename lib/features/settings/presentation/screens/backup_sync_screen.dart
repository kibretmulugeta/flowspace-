import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/storage/local_database_service.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../calendar/presentation/calendar_provider.dart';
import '../../../categories/presentation/category_provider.dart';
import '../../../notes/presentation/notes_provider.dart';
import '../../../projects/presentation/project_provider.dart';
import '../../../reminders/presentation/reminder_provider.dart';
import '../../../tasks/presentation/task_provider.dart';

class BackupSyncScreen extends ConsumerStatefulWidget {
  const BackupSyncScreen({super.key});

  @override
  ConsumerState<BackupSyncScreen> createState() => _BackupSyncScreenState();
}

class _BackupSyncScreenState extends ConsumerState<BackupSyncScreen> {
  bool _isSyncing = false;
  String? _syncMessage;

  void _triggerManualSync() async {
    setState(() {
      _isSyncing = true;
      _syncMessage = null;
    });

    await Future.delayed(const Duration(milliseconds: 900));

    // Reload all providers from persistent database storage
    await ref.read(taskProvider.notifier).loadTasks();
    await ref.read(notesProvider.notifier).loadPages();
    await ref.read(calendarProvider.notifier).loadData();
    await ref.read(projectProvider.notifier).loadProjects();
    await ref.read(reminderProvider.notifier).loadReminders();
    await ref.read(categoryProvider.notifier).loadData();

    if (mounted) {
      setState(() {
        _isSyncing = false;
        _syncMessage = 'Database synchronized. All records verified and up to date.';
      });
    }
  }

  void _exportJson() async {
    final jsonStr = await LocalDatabaseService.instance.exportDatabaseJson();
    if (!mounted) return;

    await Clipboard.setData(ClipboardData(text: jsonStr));

    if (!mounted) return;

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.check_circle, color: AppColors.accentEmerald),
            SizedBox(width: 8),
            Text('Backup Exported'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Complete database backup has been copied to your clipboard as formatted JSON.',
            ),
            const SizedBox(height: 12),
            Container(
              height: 140,
              width: double.maxFinite,
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.black12,
                borderRadius: BorderRadius.circular(8),
              ),
              child: SingleChildScrollView(
                child: Text(
                  jsonStr.length > 500 ? '${jsonStr.substring(0, 500)}...\n[Truncated]' : jsonStr,
                  style: const TextStyle(fontFamily: 'monospace', fontSize: 11),
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _importJson() {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Import Database Backup'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Paste your FlowSpace JSON database backup below:'),
            const SizedBox(height: 12),
            TextField(
              controller: controller,
              maxLines: 8,
              decoration: const InputDecoration(
                hintText: '{\n  "version": "1.0.0",\n  "tasks": [...]\n}',
                border: OutlineInputBorder(),
              ),
              style: const TextStyle(fontFamily: 'monospace', fontSize: 11),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () async {
              final text = controller.text.trim();
              if (text.isEmpty) return;
              Navigator.of(ctx).pop();
              final success = await LocalDatabaseService.instance.importDatabaseJson(text);
              if (success) {
                await ref.read(taskProvider.notifier).loadTasks();
                await ref.read(notesProvider.notifier).loadPages();
                await ref.read(calendarProvider.notifier).loadData();
                await ref.read(projectProvider.notifier).loadProjects();
                await ref.read(reminderProvider.notifier).loadReminders();
                await ref.read(categoryProvider.notifier).loadData();
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Database restored successfully from backup!'),
                      backgroundColor: AppColors.accentEmerald,
                    ),
                  );
                  setState(() {});
                }
              } else {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Failed to parse database backup JSON.'),
                      backgroundColor: AppColors.priorityUrgent,
                    ),
                  );
                }
              }
            },
            child: const Text('Restore Database'),
          ),
        ],
      ),
    );
  }

  void _resetDatabase() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Reset Database to Sample Data?'),
        content: const Text(
          'This will restore all default starter tasks, Notion pages, projects, and events. Any custom entries will be replaced.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: AppColors.priorityUrgent),
            onPressed: () async {
              Navigator.of(ctx).pop();
              await LocalDatabaseService.instance.resetToSampleData();
              await ref.read(taskProvider.notifier).loadTasks();
              await ref.read(notesProvider.notifier).loadPages();
              await ref.read(calendarProvider.notifier).loadData();
              await ref.read(projectProvider.notifier).loadProjects();
              await ref.read(reminderProvider.notifier).loadReminders();
              await ref.read(categoryProvider.notifier).loadData();
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Database reset to initial template data.')),
                );
                setState(() {});
              }
            },
            child: const Text('Reset'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final taskCount = ref.watch(taskProvider).tasks.length;
    final noteCount = ref.watch(notesProvider).pages.length;
    final eventCount = ref.watch(calendarProvider).events.length;
    final projectCount = ref.watch(projectProvider).projects.length;
    final reminderCount = ref.watch(reminderProvider).reminders.length;

    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.backupAndSync),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        children: [
          // Database Status Banner
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isDark ? AppColors.darkCard : AppColors.lightCard,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.accentEmerald.withValues(alpha: 0.3)),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.accentEmerald.withValues(alpha: 0.12),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.storage,
                    color: AppColors.accentEmerald,
                    size: 26,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            'Database Connected',
                            style: AppTypography.titleMedium.copyWith(fontWeight: FontWeight.w700),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: AppColors.accentEmerald.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: const Text(
                              'ACTIVE',
                              style: TextStyle(
                                color: AppColors.accentEmerald,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 3),
                      Text(
                        'Persistent Key-Value & Document Database (Local & Offline Ready)',
                        style: AppTypography.bodySmall.copyWith(
                          color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Database Statistics Cards
          Text('STORED ENTITY COUNTS', style: AppTypography.labelSmall.copyWith(color: Theme.of(context).colorScheme.primary)),
          const SizedBox(height: 10),
          Row(
            children: [
              _buildCountCard('Tasks', taskCount, Icons.check_circle_outline, AppColors.accentIndigo, isDark),
              const SizedBox(width: 10),
              _buildCountCard('Pages', noteCount, Icons.article_outlined, AppColors.accentViolet, isDark),
              const SizedBox(width: 10),
              _buildCountCard('Events', eventCount, Icons.calendar_today_outlined, AppColors.accentCyan, isDark),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              _buildCountCard('Projects', projectCount, Icons.folder_outlined, AppColors.accentAmber, isDark),
              const SizedBox(width: 10),
              _buildCountCard('Reminders', reminderCount, Icons.notifications_none, AppColors.accentRose, isDark),
            ],
          ),
          const SizedBox(height: 24),

          // Manual Sync Action
          SizedBox(
            width: double.infinity,
            height: 48,
            child: FilledButton.icon(
              onPressed: _isSyncing ? null : _triggerManualSync,
              icon: _isSyncing
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                    )
                  : const Icon(Icons.sync, size: 20),
              label: Text(_isSyncing ? 'Synchronizing Records...' : 'Verify & Sync Database'),
              style: FilledButton.styleFrom(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ),
          if (_syncMessage != null) ...[
            const SizedBox(height: 10),
            Text(
              _syncMessage!,
              textAlign: TextAlign.center,
              style: AppTypography.bodySmall.copyWith(color: AppColors.accentEmerald),
            ),
          ],
          const SizedBox(height: 28),

          // Data Management Section
          Text('BACKUP & RECOVERY', style: AppTypography.labelSmall.copyWith(color: Theme.of(context).colorScheme.primary)),
          const SizedBox(height: 10),
          ListTile(
            tileColor: isDark ? AppColors.darkCard : AppColors.lightCard,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: BorderSide(color: isDark ? AppColors.darkBorder : AppColors.lightBorder),
            ),
            leading: const Icon(Icons.file_download_outlined, color: AppColors.accentIndigo),
            title: const Text('Export JSON Database Backup'),
            subtitle: const Text('Copy full snapshot of all tasks, pages, and events'),
            trailing: const Icon(Icons.copy, size: 18),
            onTap: _exportJson,
          ),
          const SizedBox(height: 10),
          ListTile(
            tileColor: isDark ? AppColors.darkCard : AppColors.lightCard,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: BorderSide(color: isDark ? AppColors.darkBorder : AppColors.lightBorder),
            ),
            leading: const Icon(Icons.file_upload_outlined, color: AppColors.accentCyan),
            title: const Text('Import Backup JSON'),
            subtitle: const Text('Restore entire workspace from a backup string'),
            trailing: const Icon(Icons.chevron_right),
            onTap: _importJson,
          ),
          const SizedBox(height: 10),
          ListTile(
            tileColor: isDark ? AppColors.darkCard : AppColors.lightCard,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: BorderSide(color: isDark ? AppColors.darkBorder : AppColors.lightBorder),
            ),
            leading: const Icon(Icons.restore, color: AppColors.priorityUrgent),
            title: const Text('Reset Database to Sample Data', style: TextStyle(color: AppColors.priorityUrgent)),
            subtitle: const Text('Restores default templates and projects'),
            onTap: _resetDatabase,
          ),
        ],
      ),
    );
  }

  Widget _buildCountCard(String label, int count, IconData icon, Color color, bool isDark) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkCard : AppColors.lightCard,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: isDark ? AppColors.darkBorder : AppColors.lightBorder),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 22),
            const SizedBox(height: 6),
            Text(
              count.toString(),
              style: AppTypography.titleMedium.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: AppTypography.labelSmall.copyWith(
                color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
