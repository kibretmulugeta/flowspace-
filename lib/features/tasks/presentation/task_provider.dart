import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../data/task_repository_impl.dart';
import '../domain/task_model.dart';
import '../domain/task_repository.dart';

final taskRepositoryProvider = Provider<TaskRepository>((ref) {
  return TaskRepositoryImpl();
});

enum TaskViewFilter {
  inbox,
  today,
  upcoming,
  completed,
  all;

  String get label {
    switch (this) {
      case TaskViewFilter.inbox:
        return 'Inbox';
      case TaskViewFilter.today:
        return 'Today';
      case TaskViewFilter.upcoming:
        return 'Upcoming';
      case TaskViewFilter.completed:
        return 'Completed';
      case TaskViewFilter.all:
        return 'All';
    }
  }
}

class TaskState {
  final List<Task> tasks;
  final bool isLoading;
  final TaskViewFilter activeFilter;
  final String? selectedProjectId;
  final String? selectedCategoryId;
  final Set<String> selectedTaskIds; // For bulk selection
  final bool isSelectionMode;

  const TaskState({
    this.tasks = const [],
    this.isLoading = false,
    this.activeFilter = TaskViewFilter.today,
    this.selectedProjectId,
    this.selectedCategoryId,
    this.selectedTaskIds = const {},
    this.isSelectionMode = false,
  });

  TaskState copyWith({
    List<Task>? tasks,
    bool? isLoading,
    TaskViewFilter? activeFilter,
    String? selectedProjectId,
    String? selectedCategoryId,
    Set<String>? selectedTaskIds,
    bool? isSelectionMode,
    bool clearProject = false,
    bool clearCategory = false,
  }) {
    return TaskState(
      tasks: tasks ?? this.tasks,
      isLoading: isLoading ?? this.isLoading,
      activeFilter: activeFilter ?? this.activeFilter,
      selectedProjectId: clearProject ? null : (selectedProjectId ?? this.selectedProjectId),
      selectedCategoryId: clearCategory ? null : (selectedCategoryId ?? this.selectedCategoryId),
      selectedTaskIds: selectedTaskIds ?? this.selectedTaskIds,
      isSelectionMode: isSelectionMode ?? this.isSelectionMode,
    );
  }

  List<Task> get filteredTasks {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    return tasks.where((task) {
      // Project filter
      if (selectedProjectId != null && task.projectId != selectedProjectId) {
        return false;
      }
      // Category filter
      if (selectedCategoryId != null && task.categoryId != selectedCategoryId) {
        return false;
      }

      // View Tab filter
      switch (activeFilter) {
        case TaskViewFilter.inbox:
          return task.status == TaskStatus.inbox || (task.dueDate == null && !task.isCompleted);
        case TaskViewFilter.today:
          if (task.dueDate == null) return false;
          final taskDate = DateTime(task.dueDate!.year, task.dueDate!.month, task.dueDate!.day);
          return taskDate.isAtSameMomentAs(today) || (taskDate.isBefore(today) && !task.isCompleted);
        case TaskViewFilter.upcoming:
          if (task.dueDate == null || task.isCompleted) return false;
          final taskDate = DateTime(task.dueDate!.year, task.dueDate!.month, task.dueDate!.day);
          return taskDate.isAfter(today);
        case TaskViewFilter.completed:
          return task.isCompleted || task.status == TaskStatus.completed;
        case TaskViewFilter.all:
          return true;
      }
    }).toList();
  }
}

class TaskNotifier extends Notifier<TaskState> {
  late final TaskRepository _repository;
  final _uuid = const Uuid();

  @override
  TaskState build() {
    _repository = ref.read(taskRepositoryProvider);
    Future.microtask(() => loadTasks());
    return const TaskState();
  }

  Future<void> loadTasks() async {
    state = state.copyWith(isLoading: true);
    final list = await _repository.getTasks();
    state = state.copyWith(tasks: list, isLoading: false);
  }

  void setFilter(TaskViewFilter filter) {
    state = state.copyWith(activeFilter: filter);
  }

  void setProjectFilter(String? projectId) {
    if (projectId == null) {
      state = state.copyWith(clearProject: true);
    } else {
      state = state.copyWith(selectedProjectId: projectId);
    }
  }

  void setCategoryFilter(String? categoryId) {
    if (categoryId == null) {
      state = state.copyWith(clearCategory: true);
    } else {
      state = state.copyWith(selectedCategoryId: categoryId);
    }
  }

  Future<void> toggleTaskCompletion(String taskId) async {
    final taskIndex = state.tasks.indexWhere((t) => t.id == taskId);
    if (taskIndex == -1) return;

    final current = state.tasks[taskIndex];
    final updated = current.copyWith(
      isCompleted: !current.isCompleted,
      status: !current.isCompleted ? TaskStatus.completed : TaskStatus.todo,
      completedAt: !current.isCompleted ? DateTime.now() : null,
      updatedAt: DateTime.now(),
    );

    await _repository.updateTask(updated);
    final updatedList = List<Task>.from(state.tasks);
    updatedList[taskIndex] = updated;
    state = state.copyWith(tasks: updatedList);
  }

  Future<void> addTask({
    required String title,
    String description = '',
    DateTime? dueDate,
    String? dueTime,
    TaskPriority priority = TaskPriority.medium,
    TaskStatus status = TaskStatus.todo,
    String? projectId,
    String? categoryId,
    List<String> tags = const [],
    int estimatedMinutes = 30,
    List<String> subtasks = const [],
  }) async {
    final now = DateTime.now();
    final newTask = Task(
      id: _uuid.v4(),
      title: title,
      description: description,
      dueDate: dueDate ?? now,
      dueTime: dueTime,
      priority: priority,
      status: status,
      projectId: projectId ?? state.selectedProjectId,
      categoryId: categoryId ?? state.selectedCategoryId,
      tags: tags,
      estimatedDurationMinutes: estimatedMinutes,
      subtasks: subtasks,
      subtasksCompleted: List.filled(subtasks.length, false),
      createdAt: now,
      updatedAt: now,
    );

    await _repository.createTask(newTask);
    state = state.copyWith(tasks: [newTask, ...state.tasks]);
  }

  Future<void> updateTask(Task task) async {
    final updated = task.copyWith(updatedAt: DateTime.now());
    await _repository.updateTask(updated);
    final list = state.tasks.map((t) => t.id == updated.id ? updated : t).toList();
    state = state.copyWith(tasks: list);
  }

  Future<void> deleteTask(String taskId) async {
    await _repository.deleteTask(taskId);
    state = state.copyWith(
      tasks: state.tasks.where((t) => t.id != taskId).toList(),
      selectedTaskIds: state.selectedTaskIds.where((id) => id != taskId).toSet(),
    );
  }

  void toggleTaskSelection(String taskId) {
    final newSet = Set<String>.from(state.selectedTaskIds);
    if (newSet.contains(taskId)) {
      newSet.remove(taskId);
    } else {
      newSet.add(taskId);
    }
    state = state.copyWith(
      selectedTaskIds: newSet,
      isSelectionMode: newSet.isNotEmpty,
    );
  }

  void clearSelection() {
    state = state.copyWith(selectedTaskIds: const {}, isSelectionMode: false);
  }

  Future<void> bulkCompleteSelected() async {
    if (state.selectedTaskIds.isEmpty) return;
    await _repository.bulkComplete(state.selectedTaskIds.toList());
    await loadTasks();
    clearSelection();
  }

  Future<void> bulkDeleteSelected() async {
    if (state.selectedTaskIds.isEmpty) return;
    await _repository.bulkDelete(state.selectedTaskIds.toList());
    await loadTasks();
    clearSelection();
  }

  Future<void> reorderTasks(int oldIndex, int newIndex) async {
    await _repository.reorderTasks(oldIndex, newIndex);
    final list = List<Task>.from(state.tasks);
    if (oldIndex < newIndex) newIndex -= 1;
    final item = list.removeAt(oldIndex);
    list.insert(newIndex, item);
    state = state.copyWith(tasks: list);
  }

  Future<void> toggleSubtask(String taskId, int subtaskIndex) async {
    final taskIndex = state.tasks.indexWhere((t) => t.id == taskId);
    if (taskIndex == -1) return;

    final task = state.tasks[taskIndex];
    if (subtaskIndex >= task.subtasksCompleted.length) return;

    final newSubtaskStatus = List<bool>.from(task.subtasksCompleted);
    newSubtaskStatus[subtaskIndex] = !newSubtaskStatus[subtaskIndex];

    final updated = task.copyWith(
      subtasksCompleted: newSubtaskStatus,
      updatedAt: DateTime.now(),
    );
    await updateTask(updated);
  }
}

final taskProvider = NotifierProvider<TaskNotifier, TaskState>(TaskNotifier.new);
