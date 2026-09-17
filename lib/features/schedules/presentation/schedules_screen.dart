import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/empty_state_view.dart';
import '../domain/schedule_model.dart';
import 'schedule_provider.dart';
import 'widgets/schedule_card.dart';
import 'widgets/add_schedule_sheet.dart';

class SchedulesScreen extends ConsumerWidget {
  const SchedulesScreen({super.key});

  void _openAddSheet(BuildContext context, [ScheduleModel? existing]) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => AddScheduleSheet(existingSchedule: existing),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(scheduleProvider);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF13151B) : const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text('Advanced Schedules', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        elevation: 0,
        backgroundColor: isDark ? const Color(0xFF181B22) : Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            tooltip: 'Reload',
            onPressed: () => ref.read(scheduleProvider.notifier).loadSchedules(),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppColors.accentIndigo,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add_rounded),
        label: const Text('New Schedule'),
        onPressed: () => _openAddSheet(context),
      ),
      body: Column(
        children: [
          // 1. Metric KPI Cards Header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            color: isDark ? const Color(0xFF181B22) : Colors.white,
            child: Row(
              children: [
                _buildKpiCard('Active', '${state.activeCount}', const Color(0xFF10B981), Icons.bolt_rounded, isDark),
                const SizedBox(width: 8),
                _buildKpiCard('Blocked', '${state.blockedCount}', const Color(0xFFEF4444), Icons.lock_rounded, isDark),
                const SizedBox(width: 8),
                _buildKpiCard('Routines', '${state.recurrentCount}', const Color(0xFF3B82F6), Icons.repeat_rounded, isDark),
                const SizedBox(width: 8),
                _buildKpiCard('Done', '${state.completedCount}', const Color(0xFF6B7280), Icons.check_circle_rounded, isDark),
              ],
            ),
          ),

          // 2. Search Field
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search schedules, routines, dependencies...',
                prefixIcon: const Icon(Icons.search_rounded, size: 20),
                filled: true,
                fillColor: isDark ? const Color(0xFF1E222D) : Colors.white,
                contentPadding: const EdgeInsets.symmetric(vertical: 0),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: isDark ? const Color(0xFF2A2E39) : const Color(0xFFE5E7EB),
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: isDark ? const Color(0xFF2A2E39) : const Color(0xFFE5E7EB),
                  ),
                ),
              ),
              onChanged: (val) => ref.read(scheduleProvider.notifier).setSearchQuery(val),
            ),
          ),

          // 3. Filter Tabs
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: ScheduleViewFilter.values.map((filter) {
                final isSelected = state.activeFilter == filter;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: FilterChip(
                    label: Text(filter.label),
                    selected: isSelected,
                    selectedColor: AppColors.accentIndigo.withValues(alpha: 0.18),
                    checkmarkColor: AppColors.accentIndigo,
                    labelStyle: TextStyle(
                      color: isSelected ? AppColors.accentIndigo : (isDark ? Colors.white70 : Colors.black87),
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                      fontSize: 12,
                    ),
                    onSelected: (_) => ref.read(scheduleProvider.notifier).setFilter(filter),
                  ),
                );
              }).toList(),
            ),
          ),

          // 4. Schedules List
          Expanded(
            child: state.isLoading
                ? const Center(child: CircularProgressIndicator())
                : state.filteredSchedules.isEmpty
                    ? const EmptyStateView(
                        icon: Icons.calendar_today_outlined,
                        title: 'No Schedules Found',
                        subtitle: 'Create a delayed, bounded, routine, or dependent schedule.',
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.only(top: 4, bottom: 80),
                        itemCount: state.filteredSchedules.length,
                        itemBuilder: (context, index) {
                          final item = state.filteredSchedules[index];
                          return ScheduleCard(
                            schedule: item,
                            onTap: () => _openAddSheet(context, item),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildKpiCard(String label, String value, Color color, IconData icon, bool isDark) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withValues(alpha: 0.2)),
        ),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, size: 13, color: color),
                const SizedBox(width: 4),
                Text(value, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: color)),
              ],
            ),
            const SizedBox(height: 2),
            Text(label, style: TextStyle(fontSize: 11, color: isDark ? Colors.white60 : Colors.black54)),
          ],
        ),
      ),
    );
  }
}