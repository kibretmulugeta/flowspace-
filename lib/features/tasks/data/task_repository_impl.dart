import '../../../core/storage/local_database_service.dart';
import '../domain/task_model.dart';
import '../domain/task_repository.dart';

/// Concrete persistent TaskRepository backed by LocalDatabaseService
class TaskRepositoryImpl implements TaskRepository {
  List<Task>? _tasks;
  final LocalDatabaseService _db = LocalDatabaseService.instance;

  Future<List<Task>> _ensureLoaded() async {
    _tasks ??= await _db.loadTasks();
    return _tasks!;
  }

  @override
  Future<List<Task>> getTasks() async {
    final tasks = await _ensureLoaded();
    return List.unmodifiable(tasks);
  }

  @override
  Future<Task?> getTaskById(String id) async {
    final tasks = await _ensureLoaded();
    try {
      return tasks.firstWhere((t) => t.id == id);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<Task> createTask(Task task) async {
    final tasks = await _ensureLoaded();
    tasks.insert(0, task);
    await _db.saveTasks(tasks);
    return task;
  }

  @override
  Future<Task> updateTask(Task task) async {
    final tasks = await _ensureLoaded();
    final index = tasks.indexWhere((t) => t.id == task.id);
    if (index != -1) {
      tasks[index] = task;
    } else {
      tasks.insert(0, task);
    }
    await _db.saveTasks(tasks);
    return task;
  }

  @override
  Future<void> deleteTask(String id) async {
    final tasks = await _ensureLoaded();
    tasks.removeWhere((t) => t.id == id);
    await _db.saveTasks(tasks);
  }

  @override
  Future<void> bulkComplete(List<String> ids) async {
    final tasks = await _ensureLoaded();
    final now = DateTime.now();
    for (int i = 0; i < tasks.length; i++) {
      if (ids.contains(tasks[i].id)) {
        tasks[i] = tasks[i].copyWith(
          isCompleted: true,
          status: TaskStatus.completed,
          completedAt: now,
          updatedAt: now,
        );
      }
    }
    await _db.saveTasks(tasks);
  }

  @override
  Future<void> bulkDelete(List<String> ids) async {
    final tasks = await _ensureLoaded();
    tasks.removeWhere((t) => ids.contains(t.id));
    await _db.saveTasks(tasks);
  }

  @override
  Future<void> reorderTasks(int oldIndex, int newIndex) async {
    final tasks = await _ensureLoaded();
    if (oldIndex < newIndex) {
      newIndex -= 1;
    }
    final item = tasks.removeAt(oldIndex);
    tasks.insert(newIndex, item);
    await _db.saveTasks(tasks);
  }
}
