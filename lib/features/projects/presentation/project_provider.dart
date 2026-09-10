import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../data/project_repository_impl.dart';
import '../domain/project_model.dart';
import '../domain/project_repository.dart';

final projectRepositoryProvider = Provider<ProjectRepository>((ref) {
  return ProjectRepositoryImpl();
});

class ProjectState {
  final List<Project> projects;
  final String? activeProjectId;
  final bool isLoading;

  const ProjectState({
    this.projects = const [],
    this.activeProjectId,
    this.isLoading = false,
  });

  ProjectState copyWith({
    List<Project>? projects,
    String? activeProjectId,
    bool? isLoading,
    bool clearActiveProject = false,
  }) {
    return ProjectState(
      projects: projects ?? this.projects,
      activeProjectId: clearActiveProject ? null : (activeProjectId ?? this.activeProjectId),
      isLoading: isLoading ?? this.isLoading,
    );
  }

  Project? get activeProject {
    if (activeProjectId == null) return null;
    try {
      return projects.firstWhere((p) => p.id == activeProjectId);
    } catch (_) {
      return null;
    }
  }
}

class ProjectNotifier extends Notifier<ProjectState> {
  late final ProjectRepository _repository;
  final _uuid = const Uuid();

  @override
  ProjectState build() {
    _repository = ref.read(projectRepositoryProvider);
    Future.microtask(() => loadProjects());
    return const ProjectState();
  }

  Future<void> loadProjects() async {
    state = state.copyWith(isLoading: true);
    final list = await _repository.getProjects();
    state = state.copyWith(projects: list, isLoading: false);
  }

  void setActiveProject(String? id) {
    if (id == null) {
      state = state.copyWith(clearActiveProject: true);
    } else {
      state = state.copyWith(activeProjectId: id);
    }
  }

  Future<Project> createProject({
    required String name,
    String description = '',
    String icon = '📁',
    required Color color,
    ProjectStatus status = ProjectStatus.active,
    DateTime? startDate,
    DateTime? dueDate,
  }) async {
    final now = DateTime.now();
    final newProject = Project(
      id: _uuid.v4(),
      name: name,
      description: description,
      icon: icon,
      colorValue: color.toARGB32(),
      status: status,
      startDate: startDate ?? now,
      dueDate: dueDate,
      createdAt: now,
      updatedAt: now,
    );

    await _repository.createProject(newProject);
    state = state.copyWith(projects: [newProject, ...state.projects]);
    return newProject;
  }

  Future<void> updateProject(Project project) async {
    final updated = project.copyWith(updatedAt: DateTime.now());
    await _repository.updateProject(updated);
    final list = state.projects.map((p) => p.id == updated.id ? updated : p).toList();
    state = state.copyWith(projects: list);
  }

  Future<void> deleteProject(String projectId) async {
    await _repository.deleteProject(projectId);
    state = state.copyWith(
      projects: state.projects.where((p) => p.id != projectId).toList(),
      clearActiveProject: state.activeProjectId == projectId,
    );
  }
}

final projectProvider = NotifierProvider<ProjectNotifier, ProjectState>(ProjectNotifier.new);
