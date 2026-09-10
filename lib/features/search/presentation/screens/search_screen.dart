import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../../../core/widgets/custom_badge.dart';
import '../../../../core/widgets/empty_state_view.dart';
import '../../../calendar/presentation/calendar_provider.dart';
import '../../../calendar/presentation/widgets/event_edit_sheet.dart';
import '../../../notes/presentation/screens/note_editor_screen.dart';
import '../../../projects/presentation/screens/project_detail_screen.dart';
import '../../../tasks/presentation/task_provider.dart';
import '../../../tasks/presentation/widgets/task_edit_sheet.dart';
import '../search_provider.dart';

class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key});

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  late final TextEditingController _searchController;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onResultTap(SearchResultItem item) {
    switch (item.type) {
      case SearchFilterType.tasks:
        final task = ref.read(taskProvider).tasks.cast<dynamic>().firstWhere(
              (t) => t.id == item.id,
              orElse: () => null,
            );
        if (task != null) TaskEditSheet.show(context, existingTask: task);
        break;
      case SearchFilterType.notes:
        Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => NoteEditorScreen(pageId: item.id)),
        );
        break;
      case SearchFilterType.events:
        final event = ref.read(calendarProvider).events.cast<dynamic>().firstWhere(
              (e) => e.id == item.id,
              orElse: () => null,
            );
        if (event != null) EventEditSheet.show(context, existingEvent: event);
        break;
      case SearchFilterType.projects:
        Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => ProjectDetailScreen(projectId: item.id)),
        );
        break;
      case SearchFilterType.reminders:
      case SearchFilterType.all:
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final searchState = ref.watch(searchProvider);
    final searchNotifier = ref.read(searchProvider.notifier);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        titleSpacing: 0,
        title: TextField(
          controller: _searchController,
          autofocus: true,
          onChanged: (val) => searchNotifier.performSearch(val),
          style: AppTypography.titleMedium,
          decoration: InputDecoration(
            hintText: AppStrings.searchPlaceholder,
            border: InputBorder.none,
            enabledBorder: InputBorder.none,
            focusedBorder: InputBorder.none,
            filled: false,
            hintStyle: AppTypography.bodyMedium.copyWith(
              color: isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted,
            ),
          ),
        ),
        actions: [
          if (_searchController.text.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.clear, size: 20),
              onPressed: () {
                _searchController.clear();
                searchNotifier.performSearch('');
              },
            ),
        ],
      ),
      body: Column(
        children: [
          // Filter Chips (All, Tasks, Notes, Events, Projects, Reminders)
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: SearchFilterType.values.map((f) {
                final isSelected = searchState.filterType == f;
                return Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: FilterChip(
                    label: Text(f.label),
                    selected: isSelected,
                    onSelected: (_) => searchNotifier.setFilterType(f),
                    showCheckmark: false,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                      side: BorderSide(
                        color: isSelected
                            ? Theme.of(context).colorScheme.primary
                            : (isDark ? AppColors.darkBorder : AppColors.lightBorder),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          const Divider(height: 1),

          // Search Results or Recent Searches
          Expanded(
            child: _searchController.text.trim().isEmpty
                ? _buildRecentSearches(context, ref, searchState, isDark)
                : _buildResultsList(context, searchState, isDark),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentSearches(
    BuildContext context,
    WidgetRef ref,
    SearchState searchState,
    bool isDark,
  ) {
    if (searchState.recentQueries.isEmpty) {
      return Center(
        child: Text(
          'Type keywords to search across FlowSpace',
          style: AppTypography.bodyMedium.copyWith(
            color: isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted,
          ),
        ),
      );
    }

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(AppStrings.searchRecent, style: AppTypography.titleMedium),
            TextButton(
              onPressed: () => ref.read(searchProvider.notifier).clearRecentQueries(),
              child: const Text('Clear'),
            ),
          ],
        ),
        const SizedBox(height: 8),
        for (final query in searchState.recentQueries)
          ListTile(
            leading: const Icon(Icons.history, size: 20),
            title: Text(query, style: AppTypography.bodyMedium),
            trailing: const Icon(Icons.north_west, size: 16),
            onTap: () {
              _searchController.text = query;
              ref.read(searchProvider.notifier).performSearch(query);
            },
          ),
      ],
    );
  }

  Widget _buildResultsList(BuildContext context, SearchState searchState, bool isDark) {
    if (searchState.results.isEmpty) {
      return const EmptyStateView(
        icon: Icons.search_off,
        title: AppStrings.noSearchResults,
        subtitle: 'Try searching with different terms or reset your filter.',
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      itemCount: searchState.results.length,
      itemBuilder: (context, index) {
        final item = searchState.results[index];

        Color badgeColor;
        switch (item.type) {
          case SearchFilterType.tasks:
            badgeColor = AppColors.accentIndigo;
            break;
          case SearchFilterType.events:
            badgeColor = AppColors.accentEmerald;
            break;
          case SearchFilterType.notes:
            badgeColor = AppColors.accentViolet;
            break;
          case SearchFilterType.projects:
            badgeColor = AppColors.accentAmber;
            break;
          case SearchFilterType.reminders:
            badgeColor = AppColors.priorityUrgent;
            break;
          case SearchFilterType.all:
            badgeColor = AppColors.accentIndigo;
            break;
        }

        return InkWell(
          onTap: () => _onResultTap(item),
          borderRadius: BorderRadius.circular(12),
          child: Container(
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isDark ? AppColors.darkCard : AppColors.lightCard,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: isDark ? AppColors.darkBorder : AppColors.lightBorder),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              item.title,
                              style: AppTypography.titleMedium.copyWith(fontWeight: FontWeight.w600),
                            ),
                          ),
                          CustomBadge(
                            label: item.type.label,
                            color: badgeColor,
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        item.subtitle,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTypography.bodySmall.copyWith(
                          color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                        ),
                      ),
                      if (item.date != null) ...[
                        const SizedBox(height: 4),
                        Text(
                          DateFormatter.formatShort(item.date!),
                          style: AppTypography.labelSmall.copyWith(
                            color: isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                const Icon(Icons.chevron_right, size: 18),
              ],
            ),
          ),
        );
      },
    );
  }
}
