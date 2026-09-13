import '../../../core/storage/local_database_service.dart';
import '../domain/project_model.dart';
import '../domain/project_repository.dart';

/// Concrete persistent ProjectRepository backed by LocalDatabaseService
class ProjectRepositoryImpl implements ProjectRepository {
  List<Project>? _projects;
  final LocalDatabaseService _db = LocalDatabaseService.instance;

  Future<List<Project>> _ensureLoaded() async {
    _projects ??= await _db.loadProjects();
    return _projects!;
  }

  @override
  Future<List<Project>> getProjects() async {
    final projects = await _ensureLoaded();
    return List.unmodifiable(projects);
  }

  @override
  Future<Project?> getProjectById(String id) async {
    final projects = await _ensureLoaded();
    try {
      return projects.firstWhere((p) => p.id == id);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<Project> createProject(Project project) async {
    final projects = await _ensureLoaded();
    projects.insert(0, project);
    await _db.saveProjects(projects);
    return project;
  }

  @override
  Future<Project> updateProject(Project project) async {
    final projects = await _ensureLoaded();
    final index = projects.indexWhere((p) => p.id == project.id);
    if (index != -1) {
      projects[index] = project;
    } else {
      projects.add(project);
    }
    await _db.saveProjects(projects);
    return project;
  }

  @override
  Future<void> deleteProject(String id) async {
    final projects = await _ensureLoaded();
    projects.removeWhere((p) => p.id == id);
    await _db.saveProjects(projects);
  }
}
