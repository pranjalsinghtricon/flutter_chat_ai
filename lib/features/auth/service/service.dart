import 'dart:convert';
import 'dart:developer' as developer;
import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:amplify_auth_cognito/amplify_auth_cognito.dart';

class AuthService {
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  Map<String, dynamic>? _userInfo;

  bool get isInitialized => true; // Amplify is initialized in main.dart
  bool get isLoggedIn => _userInfo != null;
  Map<String, dynamic>? get userInfo => _userInfo;
  String? get currentUserId => _userInfo?['id'];

  Future<bool> initialize() async => true;

  /// Sign in using Cognito Hosted UI with Azure AD as IdP
  Future<Map<String, dynamic>?> signIn() async {
    try {
      developer.log('🚀 Starting Cognito Hosted UI sign-in', name: 'AuthService');

      // 👇 Replace values with your Cognito configuration
      const providerName = "azuread"; // IdP name in Cognito
      const clientId = "clientId"; // Cognito User Pool App Client ID 1pii8vb7lqo9j6st8p9ke8rjsd

      final res = await Amplify.Auth.signInWithWebUI(
        provider: AuthProvider.oidc("Azure-SSO", clientId),
      );

      if (res.isSignedIn) {
        final user = await Amplify.Auth.getCurrentUser();
        final session = await Amplify.Auth.fetchAuthSession() as CognitoAuthSession;

        final tokens = session.userPoolTokensResult.valueOrNull;

        _userInfo = {
          "id": user.userId,
          "username": user.username,
          "idToken": tokens?.idToken,
          "accessToken": tokens?.accessToken,
          "refreshToken": tokens?.refreshToken,
        };
        developer.log('✅ Sign-in successful -> ${jsonEncode(_userInfo)}', name: 'AuthService');
        // developer.log('✅ Sign-in successful -> $tokens', name: 'AuthService');
        return _userInfo;
      }

      developer.log('⚠️ Sign-in cancelled or failed', name: 'AuthService');
      return null;
    } catch (e, st) {
      developer.log('❌ Sign-in error: $e', name: 'AuthService');
      developer.log('$st', name: 'AuthService');
      return null;
    }
  }

  /// Sign out locally and from the IdP (Azure AD)
  Future<void> signOut() async {
    try {
      developer.log('🔴 Starting sign-out', name: 'AuthService');

      await Amplify.Auth.signOut(
        options: const SignOutOptions(globalSignOut: true), // invalidate everywhere
      );

      _userInfo = null;
      developer.log('✅ Signed out from Cognito + Azure AD', name: 'AuthService');
    } catch (e, st) {
      developer.log('⚠ Sign-out error: $e', name: 'AuthService');
      developer.log('$st', name: 'AuthService');
    }
  }
}
