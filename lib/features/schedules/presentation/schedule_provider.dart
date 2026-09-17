import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../../../core/network/sync_queue_manager.dart';
import '../data/schedule_repository_impl.dart';
import '../domain/schedule_model.dart';
import '../domain/schedule_repository.dart';

final scheduleRepositoryProvider = Provider<ScheduleRepository>((ref) {
  final syncQueue = ref.watch(syncQueueManagerProvider);
  return ScheduleRepositoryImpl(syncQueue);
});

enum ScheduleViewFilter {
  all,
  active,
  delay,
  bounded,
  recurrent,
  dependent,
  blocked,
  completed;

  String get label {
    switch (this) {
      case ScheduleViewFilter.all:
        return 'All';
      case ScheduleViewFilter.active:
        return 'Active';
      case ScheduleViewFilter.delay:
        return 'Delay';
      case ScheduleViewFilter.bounded:
        return 'Window';
      case ScheduleViewFilter.recurrent:
        return 'Routines';
      case ScheduleViewFilter.dependent:
        return 'Prerequisites';
      case ScheduleViewFilter.blocked:
        return 'Blocked';
      case ScheduleViewFilter.completed:
        return 'Completed';
    }
  }
}

class ScheduleState {
  final List<ScheduleModel> schedules;
  final bool isLoading;
  final ScheduleViewFilter activeFilter;
  final String searchQuery;

  const ScheduleState({
    this.schedules = const [],
    this.isLoading = false,
    this.activeFilter = ScheduleViewFilter.all,
    this.searchQuery = '',
  });

  List<ScheduleModel> get filteredSchedules {
    var list = schedules;

    // Filter by tab
    switch (activeFilter) {
      case ScheduleViewFilter.all:
        break;
      case ScheduleViewFilter.active:
        list = list.where((s) => s.status == ScheduleStatus.active).toList();
        break;
      case ScheduleViewFilter.delay:
        list = list.where((s) => s.mode == ScheduleMode.delay).toList();
        break;
      case ScheduleViewFilter.bounded:
        list = list.where((s) => s.mode == ScheduleMode.bounded).toList();
        break;
      case ScheduleViewFilter.recurrent:
        list = list.where((s) => s.mode == ScheduleMode.recurrent).toList();
        break;
      case ScheduleViewFilter.dependent:
        list = list.where((s) => s.mode == ScheduleMode.dependent).toList();
        break;
      case ScheduleViewFilter.blocked:
        list = list.where((s) => s.status == ScheduleStatus.blocked).toList();
        break;
      case ScheduleViewFilter.completed:
        list = list.where((s) => s.status == ScheduleStatus.completed).toList();
        break;
    }

    // Filter by search query
    if (searchQuery.isNotEmpty) {
      final q = searchQuery.toLowerCase();
      list = list.where((s) =>
          s.title.toLowerCase().contains(q) ||
          (s.description?.toLowerCase().contains(q) ?? false)
      ).toList();
    }

    return list;
  }

  int get activeCount => schedules.where((s) => s.status == ScheduleStatus.active).length;
  int get blockedCount => schedules.where((s) => s.status == ScheduleStatus.blocked).length;
  int get recurrentCount => schedules.where((s) => s.mode == ScheduleMode.recurrent).length;
  int get completedCount => schedules.where((s) => s.status == ScheduleStatus.completed).length;

  ScheduleState copyWith({
    List<ScheduleModel>? schedules,
    bool? isLoading,
    ScheduleViewFilter? activeFilter,
    String? searchQuery,
  }) {
    return ScheduleState(
      schedules: schedules ?? this.schedules,
      isLoading: isLoading ?? this.isLoading,
      activeFilter: activeFilter ?? this.activeFilter,
      searchQuery: searchQuery ?? this.searchQuery,
    );
  }
}

class ScheduleNotifier extends Notifier<ScheduleState> {
  late final ScheduleRepository _repo;
  static const _uuid = Uuid();

  @override
  ScheduleState build() {
    _repo = ref.watch(scheduleRepositoryProvider);
    Future.microtask(() => loadSchedules());
    return const ScheduleState(isLoading: true);
  }

  Future<void> loadSchedules() async {
    state = state.copyWith(isLoading: true);
    try {
      final list = await _repo.getSchedules();
      state = state.copyWith(schedules: list, isLoading: false);
    } catch (_) {
      state = state.copyWith(isLoading: false);
    }
  }

  void setFilter(ScheduleViewFilter filter) {
    state = state.copyWith(activeFilter: filter);
  }

  void setSearchQuery(String query) {
    state = state.copyWith(searchQuery: query);
  }

  Future<ScheduleModel> createSchedule({
    required String title,
    String? description,
    String? categoryId,
    ScheduleMode mode = ScheduleMode.delay,
    String? delayOffset,
    DateTime? windowStart,
    DateTime? windowEnd,
    String? rrule,
    String? prerequisiteId,
    DateTime? nextRunAt,
  }) async {
    final now = DateTime.now();
    final newSchedule = ScheduleModel(
      id: 'sched-${_uuid.v4()}',
      userId: 'default_user',
      categoryId: categoryId,
      title: title,
      description: description,
      mode: mode,
      delayOffset: delayOffset,
      windowStart: windowStart,
      windowEnd: windowEnd,
      rrule: rrule,
      prerequisiteId: prerequisiteId,
      status: ScheduleStatus.pending,
      nextRunAt: nextRunAt,
      createdAt: now,
    );

    final created = await _repo.createSchedule(newSchedule);
    await loadSchedules();
    return created;
  }

  Future<void> updateSchedule(ScheduleModel schedule) async {
    await _repo.updateSchedule(schedule);
    await loadSchedules();
  }

  Future<void> completeSchedule(String id) async {
    await _repo.completeSchedule(id);
    await loadSchedules();
  }

  Future<void> deleteSchedule(String id) async {
    await _repo.deleteSchedule(id);
    await loadSchedules();
  }

  ScheduleModel? getSchedule(String id) {
    return state.schedules.where((s) => s.id == id).firstOrNull;
  }
}

final scheduleProvider = NotifierProvider<ScheduleNotifier, ScheduleState>(ScheduleNotifier.new);