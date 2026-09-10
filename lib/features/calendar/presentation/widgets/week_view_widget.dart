import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../domain/calendar_event_model.dart';
import '../calendar_provider.dart';
import 'event_edit_sheet.dart';

class WeekViewWidget extends ConsumerStatefulWidget {
  const WeekViewWidget({super.key});

  @override
  ConsumerState<WeekViewWidget> createState() => _WeekViewWidgetState();
}

class _WeekViewWidgetState extends ConsumerState<WeekViewWidget> {
  final ScrollController _scrollController = ScrollController();
  static const double hourHeight = 64.0;

  @override
  void initState() {
    super.initState();
    // Auto-scroll to 8 AM
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.jumpTo(hourHeight * 8);
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final calState = ref.watch(calendarProvider);
    final calNotifier = ref.read(calendarProvider.notifier);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final selectedDate = calState.selectedDate;
    // Calculate week start (Monday)
    final monday = selectedDate.subtract(Duration(days: selectedDate.weekday - 1));
    final weekDays = List.generate(7, (i) => monday.add(Duration(days: i)));

    final dayEvents = calState.eventsForSelectedDay;

    return Column(
      children: [
        // 7-day horizontal date selector strip
        Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
            border: Border(
              bottom: BorderSide(
                color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
              ),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: weekDays.map((day) {
              final isSelected = DateFormatter.isSameDay(day, selectedDate);
              final isToday = DateFormatter.isSameDay(day, DateTime.now());
              const dayLetters = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];

              return GestureDetector(
                onTap: () => calNotifier.setSelectedDate(day),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? Theme.of(context).colorScheme.primary
                        : (isToday
                            ? (isDark ? AppColors.darkSurfaceVariant : AppColors.lightSurfaceVariant)
                            : Colors.transparent),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    children: [
                      Text(
                        dayLetters[day.weekday - 1],
                        style: AppTypography.labelSmall.copyWith(
                          color: isSelected
                              ? Colors.white
                              : (isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${day.day}',
                        style: AppTypography.titleMedium.copyWith(
                          color: isSelected
                              ? Colors.white
                              : (isToday
                                  ? Theme.of(context).colorScheme.primary
                                  : (isDark
                                      ? AppColors.darkTextPrimary
                                      : AppColors.lightTextPrimary)),
                          fontWeight: (isSelected || isToday) ? FontWeight.w700 : FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ),

        // Scrollable Timeline for selected day
        Expanded(
          child: SingleChildScrollView(
            controller: _scrollController,
            child: SizedBox(
              height: hourHeight * 24,
              child: Stack(
                children: [
                  // Hour Grid lines and labels
                  for (int hour = 0; hour < 24; hour++) ...[
                    Positioned(
                      top: hour * hourHeight,
                      left: 0,
                      right: 0,
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(
                            width: 58,
                            child: Padding(
                              padding: const EdgeInsets.only(left: 12),
                              child: Text(
                                _formatHour(hour),
                                style: AppTypography.labelSmall.copyWith(
                                  color: isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted,
                                ),
                              ),
                            ),
                          ),
                          Expanded(
                            child: GestureDetector(
                              onTap: () {
                                final tappedDateTime = DateTime(
                                  selectedDate.year,
                                  selectedDate.month,
                                  selectedDate.day,
                                  hour,
                                );
                                EventEditSheet.show(context, defaultDate: tappedDateTime);
                              },
                              child: Container(
                                height: hourHeight,
                                decoration: BoxDecoration(
                                  border: Border(
                                    top: BorderSide(
                                      color: isDark ? AppColors.darkBorderSubtle : AppColors.lightBorderSubtle,
                                      width: 1,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],

                  // Current time line (if today)
                  if (DateFormatter.isSameDay(selectedDate, DateTime.now()))
                    _buildCurrentTimeIndicator(isDark),

                  // Event blocks placed on the timeline
                  ..._buildEventBlocks(context, dayEvents, isDark),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCurrentTimeIndicator(bool isDark) {
    final now = DateTime.now();
    final top = (now.hour + (now.minute / 60.0)) * hourHeight;

    return Positioned(
      top: top,
      left: 50,
      right: 0,
      child: Row(
        children: [
          Container(
            width: 10,
            height: 10,
            decoration: const BoxDecoration(
              color: AppColors.priorityUrgent,
              shape: BoxShape.circle,
            ),
          ),
          Expanded(
            child: Container(
              height: 2,
              color: AppColors.priorityUrgent,
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildEventBlocks(BuildContext context, List<CalendarEvent> events, bool isDark) {
    if (events.isEmpty) return [];

    // Sort events chronologically
    final sorted = List<CalendarEvent>.from(events)
      ..sort((a, b) => a.startDateTime.compareTo(b.startDateTime));

    // Simple collision grouping for overlapping display
    final List<List<CalendarEvent>> clusters = [];
    for (final event in sorted) {
      bool placed = false;
      for (final cluster in clusters) {
        if (cluster.any((e) =>
            e.startDateTime.isBefore(event.endDateTime) &&
            event.startDateTime.isBefore(e.endDateTime))) {
          cluster.add(event);
          placed = true;
          break;
        }
      }
      if (!placed) {
        clusters.add([event]);
      }
    }

    final List<Widget> widgets = [];

    for (final cluster in clusters) {
      final totalColumns = cluster.length;
      for (int i = 0; i < cluster.length; i++) {
        final ev = cluster[i];
        final startMinutes = ev.startDateTime.hour * 60 + ev.startDateTime.minute;
        final durationMinutes = ev.endDateTime.difference(ev.startDateTime).inMinutes.clamp(20, 1440);

        final top = (startMinutes / 60.0) * hourHeight;
        final height = (durationMinutes / 60.0) * hourHeight;

        widgets.add(
          Positioned(
            top: top,
            height: height,
            left: 60 + (i * ((MediaQuery.sizeOf(context).width - 70) / totalColumns)),
            width: ((MediaQuery.sizeOf(context).width - 70) / totalColumns) - 4,
            child: GestureDetector(
              onTap: () => EventEditSheet.show(context, existingEvent: ev),
              child: Container(
                margin: const EdgeInsets.only(right: 2),
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: ev.color.withValues(alpha: 0.18),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: ev.color, width: 1.5),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      ev.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTypography.titleMedium.copyWith(
                        color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    if (height > 35) ...[
                      const SizedBox(height: 2),
                      Text(
                        DateFormatter.formatTime(ev.startDateTime),
                        style: AppTypography.labelSmall.copyWith(
                          color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                          fontSize: 10,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        );
      }
    }

    return widgets;
  }

  String _formatHour(int hour) {
    if (hour == 0) return '12 AM';
    if (hour < 12) return '$hour AM';
    if (hour == 12) return '12 PM';
    return '${hour - 12} PM';
  }
}
