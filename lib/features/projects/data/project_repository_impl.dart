import '../../../core/constants/sample_data.dart';
import '../domain/project_model.dart';
import '../domain/project_repository.dart';

/// Concrete ProjectRepository implementation
class ProjectRepositoryImpl implements ProjectRepository {
  final List<Project> _projects = List.from(SampleData.projects);

  @override
  Future<List<Project>> getProjects() async {
    return List.unmodifiable(_projects);
  }

  @override
  Future<Project?> getProjectById(String id) async {
    try {
      return _projects.firstWhere((p) => p.id == id);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<Project> createProject(Project project) async {
    _projects.insert(0, project);
    return project;
  }

  @override
  Future<Project> updateProject(Project project) async {
    final index = _projects.indexWhere((p) => p.id == project.id);
    if (index != -1) {
      _projects[index] = project;
    } else {
      _projects.add(project);
    }
    return project;
  }

  @override
  Future<void> deleteProject(String id) async {
    _projects.removeWhere((p) => p.id == id);
  }
}
