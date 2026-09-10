import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/auth_repository_impl.dart';
import '../domain/auth_repository.dart';
import '../domain/user_model.dart';
import '../domain/workspace_model.dart';

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepositoryImpl();
});

class AuthState {
  final User? user;
  final bool isLoading;
  final String? errorMessage;
  final bool isAuthenticated;

  const AuthState({
    this.user,
    this.isLoading = false,
    this.errorMessage,
    this.isAuthenticated = true, // Default pre-seeded Kibret logged in
  });

  AuthState copyWith({
    User? user,
    bool? isLoading,
    String? errorMessage,
    bool? isAuthenticated,
  }) {
    return AuthState(
      user: user ?? this.user,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
    );
  }
}

class AuthNotifier extends Notifier<AuthState> {
  late final AuthRepository _repository;

  @override
  AuthState build() {
    _repository = ref.read(authRepositoryProvider);
    Future.microtask(() => _init());
    return const AuthState();
  }

  Future<void> _init() async {
    final user = await _repository.getCurrentUser();
    state = state.copyWith(user: user, isAuthenticated: user != null);
  }

  Future<bool> signIn(String email, String password) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final user = await _repository.signIn(email, password);
      state = state.copyWith(user: user, isLoading: false, isAuthenticated: true);
      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
      return false;
    }
  }

  Future<bool> signUp(String email, String password, String displayName) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final user = await _repository.signUp(email, password, displayName);
      state = state.copyWith(user: user, isLoading: false, isAuthenticated: true);
      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
      return false;
    }
  }

  Future<void> continueAsGuest() async {
    state = state.copyWith(isLoading: true);
    final user = await _repository.continueAsGuest();
    state = state.copyWith(user: user, isLoading: false, isAuthenticated: true);
  }

  Future<void> sendPasswordReset(String email) async {
    await _repository.sendPasswordResetEmail(email);
  }

  Future<void> signOut() async {
    await _repository.signOut();
    state = const AuthState(user: null, isAuthenticated: false);
  }
}

final authProvider = NotifierProvider<AuthNotifier, AuthState>(AuthNotifier.new);

final workspacesProvider = FutureProvider<List<Workspace>>((ref) async {
  final repo = ref.watch(authRepositoryProvider);
  return repo.getWorkspaces();
});
