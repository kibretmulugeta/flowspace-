import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../domain/calendar_event_model.dart';
import '../calendar_provider.dart';
import 'event_edit_sheet.dart';

class MonthViewWidget extends ConsumerWidget {
  const MonthViewWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final calState = ref.watch(calendarProvider);
    final calNotifier = ref.read(calendarProvider.notifier);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final selectedDate = calState.selectedDate;
    final firstDayOfMonth = DateTime(selectedDate.year, selectedDate.month, 1);
    final daysInMonth = DateTime(selectedDate.year, selectedDate.month + 1, 0).day;
    // 1 = Monday, 7 = Sunday
    final startingWeekday = firstDayOfMonth.weekday;

    final dayEvents = calState.eventsForSelectedDay;

    return Column(
      children: [
        // Month Navigation Header
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                icon: const Icon(Icons.chevron_left),
                onPressed: () {
                  calNotifier.setSelectedDate(
                    DateTime(selectedDate.year, selectedDate.month - 1, 1),
                  );
                },
              ),
              Text(
                '${_monthName(selectedDate.month)} ${selectedDate.year}',
                style: AppTypography.titleLarge.copyWith(
                  color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.chevron_right),
                onPressed: () {
                  calNotifier.setSelectedDate(
                    DateTime(selectedDate.year, selectedDate.month + 1, 1),
                  );
                },
              ),
            ],
          ),
        ),

        // Day of week labels
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: ['M', 'T', 'W', 'T', 'F', 'S', 'S'].map((day) {
              return SizedBox(
                width: 32,
                child: Text(
                  day,
                  textAlign: TextAlign.center,
                  style: AppTypography.labelSmall.copyWith(
                    color: isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted,
                  ),
                ),
              );
            }).toList(),
          ),
        ),
        const SizedBox(height: 8),

        // Calendar Grid
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 7,
              childAspectRatio: 1.15,
            ),
            itemCount: 42, // 6 weeks max
            itemBuilder: (context, index) {
              final dayOffset = index - (startingWeekday - 1);
              if (dayOffset < 0 || dayOffset >= daysInMonth) {
                return const SizedBox.shrink();
              }

              final dayNumber = dayOffset + 1;
              final currentDate = DateTime(selectedDate.year, selectedDate.month, dayNumber);
              final isSelected = DateFormatter.isSameDay(currentDate, selectedDate);
              final isToday = DateFormatter.isSameDay(currentDate, DateTime.now());

              // Check if day has events
              final hasEvents = calState.visibleEvents.any((e) =>
                  DateFormatter.isSameDay(e.startDateTime, currentDate));

              return GestureDetector(
                onTap: () => calNotifier.setSelectedDate(currentDate),
                child: Container(
                  margin: const EdgeInsets.all(2),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? Theme.of(context).colorScheme.primary
                        : (isToday
                            ? (isDark ? AppColors.darkSurfaceVariant : AppColors.lightSurfaceVariant)
                            : Colors.transparent),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        '$dayNumber',
                        style: AppTypography.bodySmall.copyWith(
                          color: isSelected
                              ? Colors.white
                              : (isToday
                                  ? Theme.of(context).colorScheme.primary
                                  : (isDark
                                      ? AppColors.darkTextPrimary
                                      : AppColors.lightTextPrimary)),
                          fontWeight: (isSelected || isToday) ? FontWeight.w700 : FontWeight.w400,
                        ),
                      ),
                      if (hasEvents) ...[
                        const SizedBox(height: 3),
                        Container(
                          width: 5,
                          height: 5,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: isSelected ? Colors.white : Theme.of(context).colorScheme.primary,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              );
            },
          ),
        ),

        const Divider(height: 20),

        // Selected Day Events Section
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                DateFormatter.formatHeader(selectedDate),
                style: AppTypography.titleMedium,
              ),
              Text(
                '${dayEvents.length} scheduled',
                style: AppTypography.bodySmall.copyWith(
                  color: isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted,
                ),
              ),
            ],
          ),
        ),

        // Event List for Selected Day
        Expanded(
          child: dayEvents.isEmpty
              ? Center(
                  child: Text(
                    'No events scheduled for this day',
                    style: AppTypography.bodyMedium.copyWith(
                      color: isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted,
                    ),
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  itemCount: dayEvents.length,
                  itemBuilder: (context, index) {
                    final event = dayEvents[index];
                    return _buildEventTile(context, event, isDark);
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildEventTile(BuildContext context, CalendarEvent event, bool isDark) {
    return InkWell(
      onTap: () => EventEditSheet.show(context, existingEvent: event),
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
                color: event.color,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    event.title,
                    style: AppTypography.titleMedium.copyWith(fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 3),
                  Row(
                    children: [
                      Text(
                        '${DateFormatter.formatTime(event.startDateTime)} - ${DateFormatter.formatTime(event.endDateTime)}',
                        style: AppTypography.bodySmall.copyWith(
                          color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                        ),
                      ),
                      if (event.location != null) ...[
                        const SizedBox(width: 8),
                        const Text('•'),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            event.location!,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: AppTypography.bodySmall.copyWith(
                              color: isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted,
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
    );
  }

  String _monthName(int month) {
    const months = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];
    return months[month - 1];
  }
}
