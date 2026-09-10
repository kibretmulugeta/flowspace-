import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../../../core/widgets/custom_badge.dart';
import '../../../../core/widgets/empty_state_view.dart';
import '../../domain/reminder_model.dart';
import '../reminder_provider.dart';
import '../widgets/reminder_edit_sheet.dart';

class RemindersScreen extends ConsumerWidget {
  const RemindersScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final reminderState = ref.watch(reminderProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final pending = reminderState.pendingReminders;
    final completed = reminderState.completedReminders;

    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.reminders),
      ),
      body: pending.isEmpty && completed.isEmpty
          ? EmptyStateView(
              icon: Icons.notifications_none,
              title: 'No reminders',
              subtitle: 'Schedule alerts with custom snooze durations.',
              actionLabel: 'New Reminder',
              onAction: () => ReminderEditSheet.show(context),
            )
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                if (pending.isNotEmpty) ...[
                  Padding(
                    padding: const EdgeInsets.only(left: 4, bottom: 8),
                    child: Text('Scheduled', style: AppTypography.titleMedium),
                  ),
                  for (final rem in pending)
                    _buildReminderCard(context, ref, rem, isDark),
                  const SizedBox(height: 20),
                ],
                if (completed.isNotEmpty) ...[
                  Padding(
                    padding: const EdgeInsets.only(left: 4, bottom: 8),
                    child: Text('Completed', style: AppTypography.titleMedium),
                  ),
                  for (final rem in completed)
                    _buildReminderCard(context, ref, rem, isDark),
                ],
              ],
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => ReminderEditSheet.show(context),
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildReminderCard(BuildContext context, WidgetRef ref, Reminder rem, bool isDark) {
    final reminderNotifier = ref.read(reminderProvider.notifier);

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : AppColors.lightCard,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: isDark ? AppColors.darkBorder : AppColors.lightBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              GestureDetector(
                onTap: () => reminderNotifier.completeReminder(rem.id),
                child: Container(
                  width: 20,
                  height: 20,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: rem.isCompleted ? Theme.of(context).colorScheme.primary : Colors.transparent,
                    border: Border.all(
                      color: rem.isCompleted
                          ? Theme.of(context).colorScheme.primary
                          : (isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted),
                      width: 2,
                    ),
                  ),
                  child: rem.isCompleted ? const Icon(Icons.check, size: 12, color: Colors.white) : null,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  rem.title,
                  style: AppTypography.titleMedium.copyWith(
                    decoration: rem.isCompleted ? TextDecoration.lineThrough : null,
                  ),
                ),
              ),
              CustomBadge(
                label: rem.targetType.label,
                color: AppColors.accentIndigo,
              ),
            ],
          ),
          if (rem.description.isNotEmpty) ...[
            const SizedBox(height: 6),
            Padding(
              padding: const EdgeInsets.only(left: 32),
              child: Text(rem.description, style: AppTypography.bodySmall),
            ),
          ],
          const SizedBox(height: 10),
          Padding(
            padding: const EdgeInsets.only(left: 32),
            child: Row(
              children: [
                Icon(
                  Icons.alarm,
                  size: 13,
                  color: rem.isSnoozed ? AppColors.accentAmber : Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 4),
                Text(
                  rem.isSnoozed && rem.snoozeUntil != null
                      ? 'Snoozed until ${DateFormatter.formatTime(rem.snoozeUntil!)}'
                      : '${DateFormatter.formatRelative(rem.scheduledAt)} at ${DateFormatter.formatTime(rem.scheduledAt)}',
                  style: AppTypography.labelSmall.copyWith(
                    color: rem.isSnoozed ? AppColors.accentAmber : null,
                  ),
                ),
                const Spacer(),
                if (!rem.isCompleted)
                  PopupMenuButton<Duration>(
                    tooltip: 'Snooze',
                    onSelected: (duration) {
                      reminderNotifier.snoozeReminder(rem.id, duration);
                    },
                    itemBuilder: (context) => const [
                      PopupMenuItem(value: Duration(minutes: 5), child: Text('5 minutes')),
                      PopupMenuItem(value: Duration(minutes: 15), child: Text('15 minutes')),
                      PopupMenuItem(value: Duration(minutes: 30), child: Text('30 minutes')),
                      PopupMenuItem(value: Duration(hours: 1), child: Text('1 hour')),
                      PopupMenuItem(value: Duration(days: 1), child: Text('Tomorrow')),
                    ],
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: isDark ? AppColors.darkSurfaceVariant : AppColors.lightSurfaceVariant,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: const [
                          Icon(Icons.snooze, size: 13),
                          SizedBox(width: 4),
                          Text('Snooze', style: TextStyle(fontSize: 11)),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
