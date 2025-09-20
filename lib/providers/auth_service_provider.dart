import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:elysia/features/auth/service/auth_service.dart';
import 'dart:developer' as developer;

final authServiceProvider = Provider<AuthService>((ref) {
  return AuthService();
});

final authStateProvider =
StateNotifierProvider<AuthStateNotifier, AuthState>((ref) {
  final authService = ref.watch(authServiceProvider);
  return AuthStateNotifier(authService);
});

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
    final success = await _authService.initialize();
    state = state.copyWith(
      isInitialized: true,
      isLoading: false,
      isLoggedIn: success,
      userId: _authService.currentUserId,
      userInfo: _authService.userInfo,
    );
  }

  Future<void> signIn() async {
    state = state.copyWith(isLoading: true, error: null);
    final userInfo = await _authService.signIn();
    if (userInfo != null) {
      state = state.copyWith(
        isLoading: false,
        isLoggedIn: true,
        userId: userInfo['id'],
        userInfo: userInfo,
      );
      await _authService.fetchUserProfile();
    } else {
      state = state.copyWith(isLoading: false, error: 'Sign-in failed');
    }
  }

  Future<void> signOut() async {
    await _authService.signOut();
    state = state.copyWith(isLoggedIn: false, userId: null, userInfo: null);
  }

  void clearError() {
    state = state.copyWith(error: null);
  }
}
