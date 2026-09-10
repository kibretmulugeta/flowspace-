import '../../../core/constants/sample_data.dart';
import '../domain/task_model.dart';
import '../domain/task_repository.dart';

/// Concrete in-memory + offline-ready TaskRepository
class TaskRepositoryImpl implements TaskRepository {
  final List<Task> _tasks = List.from(SampleData.tasks);

  @override
  Future<List<Task>> getTasks() async {
    return List.unmodifiable(_tasks);
  }

  @override
  Future<Task?> getTaskById(String id) async {
    try {
      return _tasks.firstWhere((t) => t.id == id);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<Task> createTask(Task task) async {
    _tasks.insert(0, task);
    return task;
  }

  @override
  Future<Task> updateTask(Task task) async {
    final index = _tasks.indexWhere((t) => t.id == task.id);
    if (index != -1) {
      _tasks[index] = task;
    } else {
      _tasks.insert(0, task);
    }
    return task;
  }

  @override
  Future<void> deleteTask(String id) async {
    _tasks.removeWhere((t) => t.id == id);
  }

  @override
  Future<void> bulkComplete(List<String> ids) async {
    final now = DateTime.now();
    for (int i = 0; i < _tasks.length; i++) {
      if (ids.contains(_tasks[i].id)) {
        _tasks[i] = _tasks[i].copyWith(
          isCompleted: true,
          status: TaskStatus.completed,
          completedAt: now,
          updatedAt: now,
        );
      }
    }
  }

  @override
  Future<void> bulkDelete(List<String> ids) async {
    _tasks.removeWhere((t) => ids.contains(t.id));
  }

  @override
  Future<void> reorderTasks(int oldIndex, int newIndex) async {
    if (oldIndex < newIndex) {
      newIndex -= 1;
    }
    final item = _tasks.removeAt(oldIndex);
    _tasks.insert(newIndex, item);
  }
}
