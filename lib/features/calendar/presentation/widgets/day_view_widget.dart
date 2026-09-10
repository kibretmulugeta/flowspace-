import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/date_formatter.dart';
import '../calendar_provider.dart';
import 'event_edit_sheet.dart';

class DayViewWidget extends ConsumerStatefulWidget {
  const DayViewWidget({super.key});

  @override
  ConsumerState<DayViewWidget> createState() => _DayViewWidgetState();
}

class _DayViewWidgetState extends ConsumerState<DayViewWidget> {
  final ScrollController _scrollController = ScrollController();
  static const double hourHeight = 72.0;

  @override
  void initState() {
    super.initState();
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
    final dayEvents = calState.eventsForSelectedDay;

    return Column(
      children: [
        // Day Navigator Banner
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
            border: Border(
              bottom: BorderSide(color: isDark ? AppColors.darkBorder : AppColors.lightBorder),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                icon: const Icon(Icons.chevron_left),
                onPressed: () {
                  calNotifier.setSelectedDate(selectedDate.subtract(const Duration(days: 1)));
                },
              ),
              Column(
                children: [
                  Text(
                    DateFormatter.formatHeader(selectedDate),
                    style: AppTypography.titleMedium.copyWith(fontWeight: FontWeight.w700),
                  ),
                  Text(
                    '${dayEvents.length} events today',
                    style: AppTypography.labelSmall.copyWith(
                      color: isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted,
                    ),
                  ),
                ],
              ),
              IconButton(
                icon: const Icon(Icons.chevron_right),
                onPressed: () {
                  calNotifier.setSelectedDate(selectedDate.add(const Duration(days: 1)));
                },
              ),
            ],
          ),
        ),

        // Timeline
        Expanded(
          child: SingleChildScrollView(
            controller: _scrollController,
            child: SizedBox(
              height: hourHeight * 24,
              child: Stack(
                children: [
                  for (int h = 0; h < 24; h++) ...[
                    Positioned(
                      top: h * hourHeight,
                      left: 0,
                      right: 0,
                      child: Row(
                        children: [
                          SizedBox(
                            width: 65,
                            child: Padding(
                              padding: const EdgeInsets.only(left: 12),
                              child: Text(
                                _formatHour(h),
                                style: AppTypography.labelSmall.copyWith(
                                  color: isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted,
                                ),
                              ),
                            ),
                          ),
                          Expanded(
                            child: InkWell(
                              onTap: () {
                                final d = DateTime(
                                  selectedDate.year,
                                  selectedDate.month,
                                  selectedDate.day,
                                  h,
                                );
                                EventEditSheet.show(context, defaultDate: d);
                              },
                              child: Container(
                                height: hourHeight,
                                decoration: BoxDecoration(
                                  border: Border(
                                    top: BorderSide(
                                      color: isDark
                                          ? AppColors.darkBorderSubtle
                                          : AppColors.lightBorderSubtle,
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

                  // Red Current Time Line
                  if (DateFormatter.isSameDay(selectedDate, DateTime.now()))
                    Positioned(
                      top: (DateTime.now().hour + (DateTime.now().minute / 60.0)) * hourHeight,
                      left: 56,
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
                            child: Container(height: 2, color: AppColors.priorityUrgent),
                          ),
                        ],
                      ),
                    ),

                  // Event Blocks
                  for (final ev in dayEvents) ...[
                    Positioned(
                      top: (ev.startDateTime.hour + (ev.startDateTime.minute / 60.0)) * hourHeight,
                      height: (ev.endDateTime.difference(ev.startDateTime).inMinutes.clamp(30, 720) /
                              60.0) *
                          hourHeight,
                      left: 70,
                      right: 16,
                      child: GestureDetector(
                        onTap: () => EventEditSheet.show(context, existingEvent: ev),
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: ev.color.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: ev.color, width: 2),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                ev.title,
                                style: AppTypography.titleMedium.copyWith(
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '${DateFormatter.formatTime(ev.startDateTime)} - ${DateFormatter.formatTime(ev.endDateTime)}',
                                style: AppTypography.bodySmall.copyWith(
                                  color: isDark
                                      ? AppColors.darkTextSecondary
                                      : AppColors.lightTextSecondary,
                                ),
                              ),
                              if (ev.location != null) ...[
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    Icon(
                                      Icons.location_on,
                                      size: 13,
                                      color: isDark
                                          ? AppColors.darkTextMuted
                                          : AppColors.lightTextMuted,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      ev.location!,
                                      style: AppTypography.bodySmall.copyWith(
                                        color: isDark
                                            ? AppColors.darkTextMuted
                                            : AppColors.lightTextMuted,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  String _formatHour(int h) {
    if (h == 0) return '12 AM';
    if (h < 12) return '$h AM';
    if (h == 12) return '12 PM';
    return '${h - 12} PM';
  }
}
