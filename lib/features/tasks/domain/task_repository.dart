import '../domain/task_model.dart';

/// Task Repository interface
abstract class TaskRepository {
  Future<List<Task>> getTasks();
  Future<Task?> getTaskById(String id);
  Future<Task> createTask(Task task);
  Future<Task> updateTask(Task task);
  Future<void> deleteTask(String id);
  Future<void> bulkComplete(List<String> ids);
  Future<void> bulkDelete(List<String> ids);
  Future<void> reorderTasks(int oldIndex, int newIndex);
}
