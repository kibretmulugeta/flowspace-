import 'user_model.dart';
import 'workspace_model.dart';

/// Authentication and Session repository contract
abstract class AuthRepository {
  Future<User?> getCurrentUser();
  Future<User> signIn(String email, String password);
  Future<User> signUp(String email, String password, String displayName);
  Future<User> continueAsGuest();
  Future<void> sendPasswordResetEmail(String email);
  Future<void> signOut();
  Future<List<Workspace>> getWorkspaces();
  Future<Workspace> createWorkspace(String name, String? icon);
}
