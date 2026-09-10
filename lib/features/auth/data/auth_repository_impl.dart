import 'package:uuid/uuid.dart';
import '../../../core/constants/sample_data.dart';
import '../domain/auth_repository.dart';
import '../domain/user_model.dart';
import '../domain/workspace_model.dart';

/// Concrete offline-first AuthRepository implementation
class AuthRepositoryImpl implements AuthRepository {
  User? _currentUser = SampleData.currentUser;
  final List<Workspace> _workspaces = [SampleData.defaultWorkspace];
  final _uuid = const Uuid();

  @override
  Future<User?> getCurrentUser() async {
    return _currentUser;
  }

  @override
  Future<User> signIn(String email, String password) async {
    final now = DateTime.now();
    _currentUser = User(
      id: 'user-001',
      email: email,
      displayName: email.split('@').first,
      createdAt: now.subtract(const Duration(days: 30)),
      updatedAt: now,
    );
    return _currentUser!;
  }

  @override
  Future<User> signUp(String email, String password, String displayName) async {
    final now = DateTime.now();
    _currentUser = User(
      id: _uuid.v4(),
      email: email,
      displayName: displayName,
      createdAt: now,
      updatedAt: now,
    );
    return _currentUser!;
  }

  @override
  Future<User> continueAsGuest() async {
    final now = DateTime.now();
    _currentUser = User(
      id: 'guest-${_uuid.v4().substring(0, 8)}',
      email: 'guest@flowspace.local',
      displayName: 'Guest User',
      isGuest: true,
      createdAt: now,
      updatedAt: now,
    );
    return _currentUser!;
  }

  @override
  Future<void> sendPasswordResetEmail(String email) async {
    // Simulated async network request
    await Future.delayed(const Duration(milliseconds: 400));
  }

  @override
  Future<void> signOut() async {
    _currentUser = null;
  }

  @override
  Future<List<Workspace>> getWorkspaces() async {
    return List.unmodifiable(_workspaces);
  }

  @override
  Future<Workspace> createWorkspace(String name, String? icon) async {
    final now = DateTime.now();
    final ws = Workspace(
      id: _uuid.v4(),
      name: name,
      icon: icon ?? '💼',
      ownerId: _currentUser?.id ?? 'guest',
      memberIds: [_currentUser?.id ?? 'guest'],
      createdAt: now,
      updatedAt: now,
    );
    _workspaces.add(ws);
    return ws;
  }
}
