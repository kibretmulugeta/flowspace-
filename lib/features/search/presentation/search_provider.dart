import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../calendar/presentation/calendar_provider.dart';
import '../../notes/presentation/notes_provider.dart';
import '../../projects/presentation/project_provider.dart';
import '../../reminders/presentation/reminder_provider.dart';
import '../../tasks/presentation/task_provider.dart';

enum SearchFilterType {
  all,
  tasks,
  events,
  notes,
  projects,
  reminders;

  String get label {
    switch (this) {
      case SearchFilterType.all:
        return 'All';
      case SearchFilterType.tasks:
        return 'Tasks';
      case SearchFilterType.events:
        return 'Events';
      case SearchFilterType.notes:
        return 'Notes';
      case SearchFilterType.projects:
        return 'Projects';
      case SearchFilterType.reminders:
        return 'Reminders';
    }
  }
}

class SearchResultItem {
  final String id;
  final String title;
  final String subtitle;
  final SearchFilterType type;
  final String routePath;
  final DateTime? date;

  const SearchResultItem({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.type,
    required this.routePath,
    this.date,
  });
}

class SearchState {
  final String query;
  final SearchFilterType filterType;
  final List<SearchResultItem> results;
  final List<String> recentQueries;
  final bool isSearching;

  const SearchState({
    this.query = '',
    this.filterType = SearchFilterType.all,
    this.results = const [],
    this.recentQueries = const [
      'AI research',
      'Architecture',
      'Sprint sync',
      'ViT baseline',
    ],
    this.isSearching = false,
  });

  SearchState copyWith({
    String? query,
    SearchFilterType? filterType,
    List<SearchResultItem>? results,
    List<String>? recentQueries,
    bool? isSearching,
  }) {
    return SearchState(
      query: query ?? this.query,
      filterType: filterType ?? this.filterType,
      results: results ?? this.results,
      recentQueries: recentQueries ?? this.recentQueries,
      isSearching: isSearching ?? this.isSearching,
    );
  }
}

class SearchNotifier extends Notifier<SearchState> {
  @override
  SearchState build() {
    return const SearchState();
  }

  void setFilterType(SearchFilterType type) {
    state = state.copyWith(filterType: type);
    performSearch(state.query);
  }

  void performSearch(String query) {
    if (query.trim().isEmpty) {
      state = state.copyWith(query: '', results: const [], isSearching: false);
      return;
    }

    final cleanQuery = query.toLowerCase().trim();
    final results = <SearchResultItem>[];

    final taskState = ref.read(taskProvider);
    final calendarState = ref.read(calendarProvider);
    final notesState = ref.read(notesProvider);
    final projectState = ref.read(projectProvider);
    final reminderState = ref.read(reminderProvider);

    // Search Tasks
    if (state.filterType == SearchFilterType.all || state.filterType == SearchFilterType.tasks) {
      for (final t in taskState.tasks) {
        if (t.title.toLowerCase().contains(cleanQuery) ||
            t.description.toLowerCase().contains(cleanQuery) ||
            t.tags.any((tag) => tag.toLowerCase().contains(cleanQuery))) {
          results.add(SearchResultItem(
            id: t.id,
            title: t.title,
            subtitle: t.description.isNotEmpty ? t.description : 'Task • ${t.priority.label} priority',
            type: SearchFilterType.tasks,
            routePath: '/tasks',
            date: t.dueDate,
          ));
        }
      }
    }

    // Search Notes
    if (state.filterType == SearchFilterType.all || state.filterType == SearchFilterType.notes) {
      for (final p in notesState.pages) {
        if (p.isTrash) continue;
        final hasBlockMatch = p.blocks.any((b) => b.content.toLowerCase().contains(cleanQuery));
        if (p.title.toLowerCase().contains(cleanQuery) || hasBlockMatch) {
          results.add(SearchResultItem(
            id: p.id,
            title: '${p.icon} ${p.title}',
            subtitle: 'Note • ${p.blocks.length} blocks',
            type: SearchFilterType.notes,
            routePath: '/notes',
            date: p.updatedAt,
          ));
        }
      }
    }

    // Search Calendar Events
    if (state.filterType == SearchFilterType.all || state.filterType == SearchFilterType.events) {
      for (final e in calendarState.events) {
        if (e.title.toLowerCase().contains(cleanQuery) ||
            e.description.toLowerCase().contains(cleanQuery) ||
            (e.location?.toLowerCase().contains(cleanQuery) ?? false)) {
          results.add(SearchResultItem(
            id: e.id,
            title: e.title,
            subtitle: 'Event • ${e.location ?? 'No location specified'}',
            type: SearchFilterType.events,
            routePath: '/calendar',
            date: e.startDateTime,
          ));
        }
      }
    }

    // Search Projects
    if (state.filterType == SearchFilterType.all || state.filterType == SearchFilterType.projects) {
      for (final pr in projectState.projects) {
        if (pr.name.toLowerCase().contains(cleanQuery) ||
            pr.description.toLowerCase().contains(cleanQuery)) {
          results.add(SearchResultItem(
            id: pr.id,
            title: '${pr.icon} ${pr.name}',
            subtitle: 'Project • ${pr.status.label}',
            type: SearchFilterType.projects,
            routePath: '/projects',
            date: pr.dueDate,
          ));
        }
      }
    }

    // Search Reminders
    if (state.filterType == SearchFilterType.all || state.filterType == SearchFilterType.reminders) {
      for (final r in reminderState.reminders) {
        if (r.title.toLowerCase().contains(cleanQuery) ||
            r.description.toLowerCase().contains(cleanQuery)) {
          results.add(SearchResultItem(
            id: r.id,
            title: r.title,
            subtitle: 'Reminder • ${r.targetType.label}',
            type: SearchFilterType.reminders,
            routePath: '/reminders',
            date: r.scheduledAt,
          ));
        }
      }
    }

    // Update state & add to recent queries if not present
    final recent = List<String>.from(state.recentQueries);
    if (!recent.contains(query.trim()) && query.trim().length > 2) {
      recent.insert(0, query.trim());
      if (recent.length > 8) recent.removeLast();
    }

    state = state.copyWith(
      query: query,
      results: results,
      recentQueries: recent,
      isSearching: true,
    );
  }

  void clearRecentQueries() {
    state = state.copyWith(recentQueries: const []);
  }
}

final searchProvider = NotifierProvider<SearchNotifier, SearchState>(SearchNotifier.new);
