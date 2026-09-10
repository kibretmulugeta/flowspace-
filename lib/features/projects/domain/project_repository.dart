import '../domain/project_model.dart';

/// Project repository interface
abstract class ProjectRepository {
  Future<List<Project>> getProjects();
  Future<Project?> getProjectById(String id);
  Future<Project> createProject(Project project);
  Future<Project> updateProject(Project project);
  Future<void> deleteProject(String id);
}
