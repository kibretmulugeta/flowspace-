import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../../../core/widgets/empty_state_view.dart';
import '../../domain/calendar_event_model.dart';
import '../calendar_provider.dart';
import 'event_edit_sheet.dart';

class AgendaViewWidget extends ConsumerWidget {
  const AgendaViewWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final calState = ref.watch(calendarProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final events = List<CalendarEvent>.from(calState.visibleEvents)
      ..sort((a, b) => a.startDateTime.compareTo(b.startDateTime));

    if (events.isEmpty) {
      return EmptyStateView(
        icon: Icons.event_busy,
        title: 'No upcoming events',
        subtitle: 'Tap + to schedule an event or review past days.',
        actionLabel: 'Schedule Event',
        onAction: () => EventEditSheet.show(context),
      );
    }

    // Group events by day
    final Map<String, List<CalendarEvent>> grouped = {};
    for (final ev in events) {
      final dateKey = DateFormatter.formatHeader(ev.startDateTime);
      grouped.putIfAbsent(dateKey, () => []).add(ev);
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      itemCount: grouped.keys.length,
      itemBuilder: (context, index) {
        final dateHeader = grouped.keys.elementAt(index);
        final dayEvents = grouped[dateHeader]!;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
              child: Text(
                dateHeader,
                style: AppTypography.titleMedium.copyWith(
                  color: Theme.of(context).colorScheme.primary,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            for (final ev in dayEvents)
              InkWell(
                onTap: () => EventEditSheet.show(context, existingEvent: ev),
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.darkCard : AppColors.lightCard,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 4,
                        height: 38,
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
                            Text(
                              ev.title,
                              style: AppTypography.titleMedium.copyWith(fontWeight: FontWeight.w600),
                            ),
                            const SizedBox(height: 3),
                            Row(
                              children: [
                                Text(
                                  '${DateFormatter.formatTime(ev.startDateTime)} - ${DateFormatter.formatTime(ev.endDateTime)}',
                                  style: AppTypography.bodySmall.copyWith(
                                    color: isDark
                                        ? AppColors.darkTextSecondary
                                        : AppColors.lightTextSecondary,
                                  ),
                                ),
                                if (ev.location != null) ...[
                                  const SizedBox(width: 8),
                                  const Text('•'),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      ev.location!,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: AppTypography.bodySmall.copyWith(
                                        color: isDark
                                            ? AppColors.darkTextMuted
                                            : AppColors.lightTextMuted,
                                      ),
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}
