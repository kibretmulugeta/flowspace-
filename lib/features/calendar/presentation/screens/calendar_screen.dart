import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../calendar_provider.dart';
import '../widgets/agenda_view_widget.dart';
import '../widgets/day_view_widget.dart';
import '../widgets/event_edit_sheet.dart';
import '../widgets/month_view_widget.dart';
import '../widgets/week_view_widget.dart';

class CalendarScreen extends ConsumerWidget {
  const CalendarScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final calState = ref.watch(calendarProvider);
    final calNotifier = ref.read(calendarProvider.notifier);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.navCalendar),
        actions: [
          // "Today" jump button
          TextButton(
            onPressed: () => calNotifier.setSelectedDate(DateTime.now()),
            child: Text(
              'Today',
              style: AppTypography.labelLarge.copyWith(
                color: Theme.of(context).colorScheme.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          // Filter calendars popup
          IconButton(
            icon: const Icon(Icons.tune),
            tooltip: 'Filter Calendars',
            onPressed: () => _showCalendarFilterSheet(context, ref),
          ),
        ],
      ),
      body: Column(
        children: [
          // View Switcher Bar (Day, Week, Month, Agenda)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
              border: Border(
                bottom: BorderSide(
                  color: isDark ? AppColors.darkBorderSubtle : AppColors.lightBorderSubtle,
                ),
              ),
            ),
            child: Row(
              children: CalendarViewType.values.map((v) {
                final isSelected = calState.viewType == v;
                return Expanded(
                  child: GestureDetector(
                    onTap: () => calNotifier.setViewType(v),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? Theme.of(context).colorScheme.primary.withValues(alpha: 0.12)
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        v.label,
                        textAlign: TextAlign.center,
                        style: AppTypography.labelMedium.copyWith(
                          color: isSelected
                              ? Theme.of(context).colorScheme.primary
                              : (isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary),
                          fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),

          // Main View Body
          Expanded(
            child: switch (calState.viewType) {
              CalendarViewType.month => const MonthViewWidget(),
              CalendarViewType.week => const WeekViewWidget(),
              CalendarViewType.day => const DayViewWidget(),
              CalendarViewType.agenda => const AgendaViewWidget(),
            },
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => EventEditSheet.show(context),
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showCalendarFilterSheet(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showModalBottomSheet(
      context: context,
      backgroundColor: isDark ? AppColors.darkSurface : AppColors.lightSurface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) {
        return Consumer(
          builder: (context, ref, _) {
            final calendars = ref.watch(calendarProvider).calendars;
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Calendars', style: AppTypography.titleLarge),
                  const SizedBox(height: 12),
                  for (final cal in calendars)
                    CheckboxListTile(
                      value: cal.isVisible,
                      title: Text(cal.name, style: AppTypography.bodyMedium),
                      secondary: Container(
                        width: 16,
                        height: 16,
                        decoration: BoxDecoration(
                          color: cal.color,
                          shape: BoxShape.circle,
                        ),
                      ),
                      onChanged: (_) {
                        ref.read(calendarProvider.notifier).toggleCalendarVisibility(cal.id);
                      },
                    ),
                  const SizedBox(height: 12),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
