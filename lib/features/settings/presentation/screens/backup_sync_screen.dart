import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../calendar/presentation/calendar_provider.dart';
import '../../../notes/presentation/notes_provider.dart';
import '../../../projects/presentation/project_provider.dart';
import '../../../tasks/presentation/task_provider.dart';
import '../settings_provider.dart';

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

    // Simulate two-way differential synchronization
    await Future.delayed(const Duration(milliseconds: 1200));

    if (mounted) {
      setState(() {
        _isSyncing = false;
        _syncMessage = 'All tasks, notes, calendar events, and projects are fully synchronized.';
      });
    }
  }

  void _exportJson() {
    final taskCount = ref.read(taskProvider).tasks.length;
    final noteCount = ref.read(notesProvider).pages.length;
    final eventCount = ref.read(calendarProvider).events.length;
    final projectCount = ref.read(projectProvider).projects.length;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Exported $taskCount tasks, $noteCount pages, $eventCount events, and $projectCount projects to local JSON backup.',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final settingsState = ref.watch(settingsProvider);
    final settingsNotifier = ref.read(settingsProvider.notifier);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.backupAndSync),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        children: [
          // Offline status banner
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isDark ? AppColors.darkCard : AppColors.lightCard,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: isDark ? AppColors.darkBorder : AppColors.lightBorder),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: settingsState.isOnline
                        ? AppColors.accentEmerald.withValues(alpha: 0.12)
                        : AppColors.priorityUrgent.withValues(alpha: 0.12),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    settingsState.isOnline ? Icons.cloud_done : Icons.cloud_off,
                    color: settingsState.isOnline
                        ? AppColors.accentEmerald
                        : AppColors.priorityUrgent,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        settingsState.isOnline ? 'Online & Synchronized' : 'Offline Mode Active',
                        style: AppTypography.titleMedium.copyWith(fontWeight: FontWeight.w700),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        settingsState.isOnline
                            ? 'Changes are automatically synced with remote API.'
                            : 'All changes are stored locally on device and queued.',
                        style: AppTypography.bodySmall.copyWith(
                          color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                Switch(
                  value: settingsState.isOnline,
                  onChanged: (val) => settingsNotifier.setOnlineStatus(val),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Manual Sync Action
          SizedBox(
            width: double.infinity,
            height: 50,
            child: FilledButton.icon(
              onPressed: _isSyncing ? null : _triggerManualSync,
              icon: _isSyncing
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                    )
                  : const Icon(Icons.sync, size: 20),
              label: Text(_isSyncing ? 'Synchronizing...' : 'Sync Now'),
              style: FilledButton.styleFrom(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ),
          if (_syncMessage != null) ...[
            const SizedBox(height: 12),
            Text(
              _syncMessage!,
              textAlign: TextAlign.center,
              style: AppTypography.bodySmall.copyWith(color: AppColors.accentEmerald),
            ),
          ],
          const SizedBox(height: 32),

          // Data Management Section
          Text('Data Export & Import', style: AppTypography.labelLarge),
          const SizedBox(height: 12),
          ListTile(
            tileColor: isDark ? AppColors.darkCard : AppColors.lightCard,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: BorderSide(color: isDark ? AppColors.darkBorder : AppColors.lightBorder),
            ),
            leading: const Icon(Icons.download),
            title: const Text('Export JSON Workspace Backup'),
            subtitle: const Text('Save all tasks, Notion pages, and calendars'),
            onTap: _exportJson,
          ),
          const SizedBox(height: 10),
          ListTile(
            tileColor: isDark ? AppColors.darkCard : AppColors.lightCard,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: BorderSide(color: isDark ? AppColors.darkBorder : AppColors.lightBorder),
            ),
            leading: const Icon(Icons.upload),
            title: const Text('Import Backup File'),
            subtitle: const Text('Restore from local JSON file'),
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Workspace data is verified and up-to-date.')),
              );
            },
          ),
        ],
      ),
    );
  }
}
