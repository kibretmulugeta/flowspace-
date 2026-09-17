import '../../../core/storage/local_database_service.dart';
import '../../../core/network/api_client.dart';
import '../../../core/network/sync_queue_manager.dart';
import '../domain/schedule_model.dart';
import '../domain/schedule_repository.dart';

/// Concrete offline-first ScheduleRepository backed by LocalDatabaseService and SyncQueueManager
class ScheduleRepositoryImpl implements ScheduleRepository {
  List<ScheduleModel>? _schedules;
  final LocalDatabaseService _db = LocalDatabaseService.instance;
  final SyncQueueManager? _syncQueue;

  ScheduleRepositoryImpl([this._syncQueue]);

  Future<List<ScheduleModel>> _ensureLoaded() async {
    _schedules ??= await _db.loadSchedules();
    return _schedules!;
  }

  @override
  Future<List<ScheduleModel>> getSchedules({
    ScheduleMode? mode,
    ScheduleStatus? status,
  }) async {
    final list = await _ensureLoaded();
    var filtered = List<ScheduleModel>.from(list);
    if (mode != null) {
      filtered = filtered.where((s) => s.mode == mode).toList();
    }
    if (status != null) {
      filtered = filtered.where((s) => s.status == status).toList();
    }
    return List.unmodifiable(filtered);
  }

  @override
  Future<ScheduleModel?> getScheduleById(String id) async {
    final list = await _ensureLoaded();
    try {
      return list.firstWhere((s) => s.id == id);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<ScheduleModel> createSchedule(ScheduleModel schedule) async {
    final list = await _ensureLoaded();

    // Auto-compute status if dependent
    var finalStatus = schedule.status;
    if (schedule.mode == ScheduleMode.dependent && schedule.prerequisiteId != null) {
      final prereq = list.where((s) => s.id == schedule.prerequisiteId).firstOrNull;
      if (prereq == null || !prereq.isCompleted) {
        finalStatus = ScheduleStatus.blocked;
      } else {
        finalStatus = ScheduleStatus.active;
      }
    }

    final toAdd = schedule.copyWith(status: finalStatus);
    list.insert(0, toAdd);
    await _db.saveSchedules(list);

    // Queue for cloud sync if syncQueue is available
    if (_syncQueue != null) {
      await _syncQueue.enqueue(
        SyncQueueItem(
          id: 'sync-${DateTime.now().millisecondsSinceEpoch}',
          entityType: 'schedule',
          action: 'create',
          payload: toAdd.toJson(),
          timestamp: DateTime.now(),
        ),
      );
    }

    return toAdd;
  }

  @override
  Future<ScheduleModel> updateSchedule(ScheduleModel schedule) async {
    final list = await _ensureLoaded();
    final index = list.indexWhere((s) => s.id == schedule.id);

    final isCompleting = schedule.status == ScheduleStatus.completed &&
        (index != -1 && list[index].status != ScheduleStatus.completed);

    var updated = schedule;
    if (isCompleting && schedule.completedAt == null) {
      updated = schedule.copyWith(completedAt: DateTime.now());
    }

    if (index != -1) {
      list[index] = updated;
    } else {
      list.insert(0, updated);
    }

    // If completed, automatically unblock dependent items!
    if (isCompleting) {
      for (int i = 0; i < list.length; i++) {
        if (list[i].prerequisiteId == updated.id && list[i].status == ScheduleStatus.blocked) {
          list[i] = list[i].copyWith(status: ScheduleStatus.active);
        }
      }
    }

    await _db.saveSchedules(list);

    if (_syncQueue != null) {
      await _syncQueue.enqueue(
        SyncQueueItem(
          id: 'sync-${DateTime.now().millisecondsSinceEpoch}',
          entityType: 'schedule',
          action: 'update',
          payload: updated.toJson(),
          timestamp: DateTime.now(),
        ),
      );
    }

    return updated;
  }

  @override
  Future<ScheduleModel> completeSchedule(String id) async {
    final list = await _ensureLoaded();
    final index = list.indexWhere((s) => s.id == id);
    if (index == -1) {
      throw Exception('Schedule not found');
    }

    final completed = list[index].copyWith(
      status: ScheduleStatus.completed,
      completedAt: DateTime.now(),
    );
    list[index] = completed;

    // Automatically unblock downstream dependents
    for (int i = 0; i < list.length; i++) {
      if (list[i].prerequisiteId == id && list[i].status == ScheduleStatus.blocked) {
        list[i] = list[i].copyWith(status: ScheduleStatus.active);
      }
    }

    await _db.saveSchedules(list);

    if (_syncQueue != null) {
      await _syncQueue.enqueue(
        SyncQueueItem(
          id: 'sync-${DateTime.now().millisecondsSinceEpoch}',
          entityType: 'schedule',
          action: 'update',
          payload: {'status': 'completed', 'completed_at': DateTime.now().toIso8601String()},
          timestamp: DateTime.now(),
        ),
      );
    }

    return completed;
  }

  @override
  Future<void> deleteSchedule(String id) async {
    final list = await _ensureLoaded();
    list.removeWhere((s) => s.id == id);
    await _db.saveSchedules(list);

    if (_syncQueue != null) {
      await _syncQueue.enqueue(
        SyncQueueItem(
          id: 'sync-${DateTime.now().millisecondsSinceEpoch}',
          entityType: 'schedule',
          action: 'delete',
          payload: {'id': id},
          timestamp: DateTime.now(),
        ),
      );
    }
  }

  @override
  Future<List<ScheduleModel>> getDependentSchedules(String prerequisiteId) async {
    final list = await _ensureLoaded();
    return list.where((s) => s.prerequisiteId == prerequisiteId).toList();
  }
}