import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:elysia/features/auth/service/auth_service.dart';
import 'dart:developer' as developer;

final authServiceProvider = Provider<AuthService>((ref) {
  return AuthService();
});

final authStateProvider = StateNotifierProvider<AuthStateNotifier, AuthState>((ref) {
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

  // Helper method to get display name
  String getDisplayName() {
    if (userInfo == null) return 'User';

    // Priority: full_name > cleaned email > cleaned username
    final fullName = userInfo!['full_name'] as String?;
    if (fullName != null && fullName.isNotEmpty && fullName != 'Unknown Name') {
      return fullName;
    }

    final email = userInfo!['email'] as String?;
    if (email != null && email.isNotEmpty) {
      return email.split('@')[0].replaceAll('.', ' ').split('_').last;
    }

    final username = userInfo!['username'] as String?;
    if (username != null && username.isNotEmpty) {
      String cleanUsername = username;
      if (cleanUsername.contains('Azure-SSO_')) {
        cleanUsername = cleanUsername.split('Azure-SSO_').last;
      }
      if (cleanUsername.contains('@')) {
        cleanUsername = cleanUsername.split('@')[0];
      }
      return cleanUsername.replaceAll('.', ' ').replaceAll('_', ' ');
    }

    return 'User';
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
      state = state.copyWith(
        isInitialized: true,
        isLoading: false,
        isLoggedIn: success,
        userId: _authService.currentUserId,
        userInfo: _authService.userInfo,
      );

      developer.log('🔄 Auth initialized: $success', name: 'AuthStateNotifier');
    } catch (e) {
      developer.log('❌ Auth initialization error: $e', name: 'AuthStateNotifier');
      state = state.copyWith(
        isInitialized: true,
        isLoading: false,
        isLoggedIn: false,
        error: 'Initialization failed',
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
        developer.log('✅ Sign-in successful in state notifier', name: 'AuthStateNotifier');
      } else {
        state = state.copyWith(
            isLoading: false,
            error: 'Sign-in failed'
        );
        developer.log('⚠️ Sign-in failed in state notifier', name: 'AuthStateNotifier');
      }
    } catch (e) {
      developer.log('❌ Sign-in error in state notifier: $e', name: 'AuthStateNotifier');
      state = state.copyWith(
          isLoading: false,
          error: 'Sign-in error: $e'
      );
    }
  }

  Future<void> signOut() async {
    developer.log('🔴 Starting sign-out in state notifier', name: 'AuthStateNotifier');

    try {
      await _authService.signOut();

      // Reset state completely
      state = const AuthState(
        isInitialized: true,
        isLoading: false,
        isLoggedIn: false,
        userId: null,
        userInfo: null,
        error: null,
      );

      developer.log('✅ Sign-out completed in state notifier', name: 'AuthStateNotifier');
    } catch (e) {
      developer.log('❌ Sign-out error in state notifier: $e', name: 'AuthStateNotifier');

      // Force reset state even on error
      state = const AuthState(
        isInitialized: true,
        isLoading: false,
        isLoggedIn: false,
        userId: null,
        userInfo: null,
        error: null,
      );
    }
  }

  void clearError() {
    state = state.copyWith(error: null);
  }

  // Method to refresh profile data
  Future<void> refreshProfile() async {
    if (!state.isLoggedIn) return;

    state = state.copyWith(isLoading: true);
    try {
      await _authService.fetchUserProfile();
      state = state.copyWith(
        isLoading: false,
        userInfo: _authService.userInfo,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false);
      developer.log('❌ Profile refresh error: $e', name: 'AuthStateNotifier');
    }
  }
}