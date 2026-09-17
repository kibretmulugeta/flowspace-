import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../domain/schedule_model.dart';
import '../schedule_provider.dart';

class ScheduleCard extends ConsumerWidget {
  final ScheduleModel schedule;
  final VoidCallback? onTap;

  const ScheduleCard({
    super.key,
    required this.schedule,
    this.onTap,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final allSchedules = ref.watch(scheduleProvider).schedules;

    // Resolve prerequisite title if dependent
    String? prereqTitle;
    if (schedule.mode == ScheduleMode.dependent && schedule.prerequisiteId != null) {
      final parent = allSchedules.where((s) => s.id == schedule.prerequisiteId).firstOrNull;
      prereqTitle = parent?.title ?? 'Parent Schedule #${schedule.prerequisiteId!.substring(0, 6)}';
    }

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: schedule.isBlocked
              ? const Color(0xFFEF4444).withValues(alpha: 0.4)
              : (isDark ? const Color(0xFF2A2E39) : const Color(0xFFE5E7EB)),
          width: schedule.isBlocked ? 1.5 : 1,
        ),
      ),
      color: isDark ? const Color(0xFF1E222D) : Colors.white,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header: Mode Badge + Status
              Row(
                children: [
                  // Mode Badge
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: schedule.mode.color.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(schedule.mode.icon, size: 14, color: schedule.mode.color),
                        const SizedBox(width: 4),
                        Text(
                          schedule.mode.label,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: schedule.mode.color,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),

                  // Status Pill
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: schedule.status.color.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      schedule.status.label,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: schedule.status.color,
                      ),
                    ),
                  ),

                  const Spacer(),

                  // Complete Action
                  if (!schedule.isCompleted)
                    IconButton(
                      icon: Icon(
                        schedule.isBlocked ? Icons.lock_outline_rounded : Icons.check_circle_outline_rounded,
                        color: schedule.isBlocked ? Colors.grey : AppColors.accentIndigo,
                        size: 22,
                      ),
                      tooltip: schedule.isBlocked ? 'Blocked by prerequisite' : 'Mark Completed',
                      onPressed: schedule.isBlocked
                          ? () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Cannot complete: Blocked by "${prereqTitle ?? 'parent task'}"'),
                                  backgroundColor: const Color(0xFFEF4444),
                                ),
                              );
                            }
                          : () => ref.read(scheduleProvider.notifier).completeSchedule(schedule.id),
                    ),
                ],
              ),

              const SizedBox(height: 10),

              // Title
              Text(
                schedule.title,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  decoration: schedule.isCompleted ? TextDecoration.lineThrough : null,
                  color: schedule.isCompleted ? Colors.grey : (isDark ? Colors.white : Colors.black87),
                ),
              ),

              // Description
              if (schedule.description != null && schedule.description!.isNotEmpty) ...[
                const SizedBox(height: 4),
                Text(
                  schedule.description!,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 13,
                    color: isDark ? const Color(0xFF9CA3AF) : const Color(0xFF6B7280),
                  ),
                ),
              ],

              const SizedBox(height: 12),

              // Footer: Timing info / Dependency alert
              if (schedule.isBlocked && prereqTitle != null) ...[
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEF4444).withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.link_off_rounded, size: 14, color: Color(0xFFEF4444)),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          'Waiting on: $prereqTitle',
                          style: const TextStyle(fontSize: 12, color: Color(0xFFEF4444), fontWeight: FontWeight.w500),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              ] else ...[
                Row(
                  children: [
                    Icon(Icons.schedule_rounded, size: 14, color: Colors.grey[500]),
                    const SizedBox(width: 4),
                    Text(
                      schedule.timingDescription,
                      style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}