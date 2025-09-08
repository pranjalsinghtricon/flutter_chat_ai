import 'package:elysia/features/auth/service/service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Auth service provider
final authServiceProvider = Provider<AuthService>((ref) {
  return AuthService();
});

// Auth state provider
final authStateProvider = StateNotifierProvider<AuthStateNotifier, AuthState>((ref) {
  final authService = ref.watch(authServiceProvider);
  return AuthStateNotifier(authService);
});

// User info provider
final userInfoProvider = Provider<Map<String, dynamic>?>((ref) {
  final authState = ref.watch(authStateProvider);
  return authState.userInfo;
});

// Auth state classes
class AuthState {
  final bool isInitialized;
  final bool isLoading;
  final bool isLoggedIn;
  final String? userId;
  final Map<String, dynamic>? userInfo;
  final String? error;

  const AuthState({
    this.isInitialized = false,
    this.isLoading = false,
    this.isLoggedIn = false,
    this.userId,
    this.userInfo,
    this.error,
  });

  AuthState copyWith({
    bool? isInitialized,
    bool? isLoading,
    bool? isLoggedIn,
    String? userId,
    Map<String, dynamic>? userInfo,
    String? error,
  }) {
    return AuthState(
      isInitialized: isInitialized ?? this.isInitialized,
      isLoading: isLoading ?? this.isLoading,
      isLoggedIn: isLoggedIn ?? this.isLoggedIn,
      userId: userId ?? this.userId,
      userInfo: userInfo ?? this.userInfo,
      error: error,
    );
  }
}

class AuthStateNotifier extends StateNotifier<AuthState> {
  final AuthService _authService;

  AuthStateNotifier(this._authService) : super(const AuthState()) {
    _initialize();
  }

  Future<void> _initialize() async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final success = await _authService.initialize();
      if (success) {
        state = state.copyWith(
          isInitialized: true,
          isLoading: false,
          isLoggedIn: _authService.isLoggedIn,
          userId: _authService.currentUserId,
          userInfo: _authService.userInfo,
        );
      } else {
        state = state.copyWith(
          isLoading: false,
          error: 'Failed to initialize authentication service',
        );
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Initialization error: $e',
      );
    }
  }

  Future<void> signIn() async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final userInfo = await _authService.signIn();
      if (userInfo != null) {
        state = state.copyWith(
          isLoading: false,
          isLoggedIn: true,
          userId: userInfo['id'],
          userInfo: userInfo,
        );
      } else {
        state = state.copyWith(
          isLoading: false,
          error: 'Sign-in failed: No user information received',
        );
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Sign-in error: $e',
      );
    }
  }

  Future<void> signOut() async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      await _authService.signOut();
      state = state.copyWith(
        isLoading: false,
        isLoggedIn: false,
        userId: null,
        userInfo: null,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Sign-out error: $e',
      );
    }
  }

  void clearError() {
    state = state.copyWith(error: null);
  }
}